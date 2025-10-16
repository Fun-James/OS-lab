#include <slub_pmm.h>
#include <buddy_pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <pmm.h>
#include <default_pmm.h>


/* SLUB分配器实现
 * 基于两层架构:
 * 1. 底层使用buddy_pmm_manager进行页级分配
 * 2. 上层使用slab机制管理小对象的分配
 */

// 底层页分配器(使用buddy算法)
static const struct pmm_manager *base_pmm = &buddy_pmm_manager;

// 预定义的kmem_cache数组,支持不同大小的对象
struct kmem_cache kmem_caches[SLUB_CACHE_NUM];

// cache大小配置: 16, 32, 64, 128, 256, 512, 1024, 2048 字节
static const size_t cache_sizes[SLUB_CACHE_NUM] = {
    16, 32, 64, 128, 256, 512, 1024, 2048
};

/* ========== SLUB初始化 ========== */

void slub_init(void) {
    base_pmm->init();
    
    // 初始化每个kmem_cache
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
        kmem_caches[i].objsize = cache_sizes[i];
        // 计算每个slab(一页)能容纳的对象数量
        // 需要预留slab结构体的空间
        size_t page_size = PGSIZE;
        size_t slab_struct_size = SLUB_ALIGN_SIZE(sizeof(struct slab));
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
        
        list_init(&kmem_caches[i].slabs_full);
        list_init(&kmem_caches[i].slabs_partial);
        list_init(&kmem_caches[i].slabs_free);
        
        // 设置cache名称
        static char names[SLUB_CACHE_NUM][32];
        snprintf(names[i], 32, "kmem_cache_%lu", cache_sizes[i]);
        kmem_caches[i].name = names[i];
    }
    
    cprintf("SLUB allocator initialized\n");
    cprintf("Cache configurations:\n");
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
        cprintf("  %s: objsize=%lu, num_per_slab=%lu\n", 
                kmem_caches[i].name, 
                kmem_caches[i].objsize, 
                kmem_caches[i].num);
    }
}

void slub_init_memmap(struct Page *base, size_t n) {
    base_pmm->init_memmap(base, n);
}

struct Page *slub_alloc_pages(size_t n) {
    return base_pmm->alloc_pages(n);
}

void slub_free_pages(struct Page *base, size_t n) {
    base_pmm->free_pages(base, n);
}

size_t slub_nr_free_pages(void) {
    return base_pmm->nr_free_pages();
}

/* ========== SLAB管理 ========== */

/* 从kmem_cache中分配一个新的slab */
static struct slab *kmem_cache_grow(struct kmem_cache *cache) {
    // 分配一页作为slab
    struct Page *page = slub_alloc_pages(1);
    if (page == NULL) {
        return NULL;
    }
    
    // 将Page转换为内核虚拟地址
    void *kva = page2kva(page);
    
    // slab结构放在页的开头
    struct slab *slab = (struct slab *)kva;
    slab->s_mem = (void *)((uintptr_t)kva + SLUB_ALIGN_SIZE(sizeof(struct slab)));
    slab->inuse = 0;
    slab->free = 0;
    slab->cache = cache;
    
    // 初始化freelist - 将所有对象链接成链表
    void *objp = slab->s_mem;
    for (size_t i = 0; i < cache->num - 1; i++) {
        struct freelist_node *node = (struct freelist_node *)objp;
        node->next = (struct freelist_node *)((uintptr_t)objp + cache->objsize);
        objp = (void *)node->next;
    }
    // 最后一个对象指向NULL
    struct freelist_node *last_node = (struct freelist_node *)objp;
    last_node->next = NULL;
    
    // 将slab添加到free链表
    list_add(&cache->slabs_free, &slab->slab_link);
    
    return slab;
}

/* 销毁一个slab */
static void kmem_cache_destroy_slab(struct slab *slab) {
    // 从链表中移除
    list_del(&slab->slab_link);
    
    // 计算slab对应的Page
    void *kva = (void *)slab;
    struct Page *page = kva2page(kva);
    
    // 释放页
    slub_free_pages(page, 1);
}

/* ========== 对象分配与释放 ========== */

/* 从kmem_cache中分配一个对象 */
void *kmem_cache_alloc(struct kmem_cache *cache) {
    struct slab *slab = NULL;
    
    // 1. 优先从partial链表中分配
    if (!list_empty(&cache->slabs_partial)) {
        slab = le2slab(list_next(&cache->slabs_partial), slab_link);
    }
    // 2. 如果没有partial slab,从free链表中分配
    else if (!list_empty(&cache->slabs_free)) {
        slab = le2slab(list_next(&cache->slabs_free), slab_link);
        // 将slab从free链表移到partial链表
        list_del(&slab->slab_link);
        list_add(&cache->slabs_partial, &slab->slab_link);
    }
    // 3. 如果没有可用slab,创建新的
    else {
        slab = kmem_cache_grow(cache);
        if (slab == NULL) {
            return NULL;
        }
        // 新slab已经在free链表中,移到partial链表
        list_del(&slab->slab_link);
        list_add(&cache->slabs_partial, &slab->slab_link);
    }
    
    // 从slab的freelist中分配对象
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
    struct freelist_node *node = (struct freelist_node *)objp;
    
    // 更新freelist
    if (node->next != NULL) {
        // 计算下一个空闲对象的索引
        uintptr_t next_addr = (uintptr_t)node->next;
        uintptr_t base_addr = (uintptr_t)slab->s_mem;
        slab->free = (next_addr - base_addr) / cache->objsize;
    } else {
        slab->free = -1; // 没有更多空闲对象
    }
    
    slab->inuse++;
    
    // 如果slab满了,移到full链表
    if (slab->inuse == cache->num) {
        list_del(&slab->slab_link);
        list_add(&cache->slabs_full, &slab->slab_link);
    }
    
    // 清零对象内存
    memset(objp, 0, cache->objsize);
    
    return objp;
}

/* 释放一个对象到kmem_cache */
void kmem_cache_free(struct kmem_cache *cache, void *objp) {
    if (objp == NULL) {
        return;
    }
    
    // 根据对象地址找到所属的slab
    // slab结构在页的开头
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
    struct slab *slab = (struct slab *)page_addr;
    
    // 验证slab是否属于此cache
    if (slab->cache != cache) {
        cprintf("Error: object %p does not belong to cache %s\n", objp, cache->name);
        return;
    }
    
    // 计算对象的索引
    uintptr_t offset = (uintptr_t)objp - (uintptr_t)slab->s_mem;
    int obj_index = offset / cache->objsize;
    
    // 将对象添加回freelist
    struct freelist_node *node = (struct freelist_node *)objp;
    if (slab->free >= 0) {
        void *next_free = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
        node->next = (struct freelist_node *)next_free;
    } else {
        node->next = NULL;
    }
    slab->free = obj_index;
    
    int was_full = (slab->inuse == cache->num);
    slab->inuse--;
    
    // 根据使用情况调整slab在链表中的位置
    if (slab->inuse == 0) {
        // slab完全空闲,移到free链表
        list_del(&slab->slab_link);
        list_add(&cache->slabs_free, &slab->slab_link);
    } else if (was_full) {
        // slab从full变为partial
        list_del(&slab->slab_link);
        list_add(&cache->slabs_partial, &slab->slab_link);
    }
}

/* ========== 通用内存分配接口 ========== */

/* 根据大小获取合适的kmem_cache */
struct kmem_cache *get_kmem_cache(size_t size) {
    // 对齐大小
    size = SLUB_ALIGN_SIZE(size);
    
    // 查找合适的cache
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
        if (cache_sizes[i] >= size) {
            return &kmem_caches[i];
        }
    }
    
    return NULL; // 大小超出范围
}

/* 分配任意大小的内存(类似kmalloc) */
void *slub_alloc(size_t size) {
    if (size == 0) {
        return NULL;
    }
    
    if (size > SLUB_MAX_SIZE) {
        // 大于最大对象大小,直接分配页
        size_t n = ROUNDUP(size, PGSIZE) / PGSIZE;
        struct Page *page = slub_alloc_pages(n);
        if (page == NULL) {
            return NULL;
        }
        return page2kva(page);
    }
    
    struct kmem_cache *cache = get_kmem_cache(size);
    if (cache == NULL) {
        return NULL;
    }
    
    return kmem_cache_alloc(cache);
}

/* 释放由slub_alloc分配的内存(类似kfree) */
void slub_free(void *objp) {
    if (objp == NULL) {
        return;
    }
    
    // 获取对象所在的页
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
    struct slab *slab = (struct slab *)page_addr;
    
    // 简单检查:如果页的开头看起来像slab结构,则使用kmem_cache_free
    // 否则假设是直接页分配
    if (slab->cache != NULL && 
        slab->cache >= &kmem_caches[0] && 
        slab->cache < &kmem_caches[SLUB_CACHE_NUM]) {
        kmem_cache_free(slab->cache, objp);
    } else {
        // 直接页分配的情况,这里简化处理
        // 实际应该记录分配的页数
        cprintf("Warning: slub_free called on direct page allocation\n");
    }
}

/* ========== 测试函数 ========== */

void slub_check(void) {
    cprintf("=== SLUB allocator check begin ===\n");
    
    // 测试1: 基本的分配和释放
    cprintf("Test 1: Basic allocation and free\n");
    void *p1 = slub_alloc(32);
    void *p2 = slub_alloc(32);
    void *p3 = slub_alloc(64);
    assert(p1 != NULL && p2 != NULL && p3 != NULL);
    assert(p1 != p2);
    cprintf("  Allocated: p1=%p, p2=%p, p3=%p\n", p1, p2, p3);
    
    slub_free(p1);
    slub_free(p2);
    slub_free(p3);
    cprintf("  Test 1 passed!\n");
    
    // 测试2: 重复分配释放
    cprintf("Test 2: Repeated allocation and free\n");
    void *ptrs[10];
    for (int i = 0; i < 10; i++) {
        ptrs[i] = slub_alloc(128);
        assert(ptrs[i] != NULL);
    }
    for (int i = 0; i < 10; i++) {
        slub_free(ptrs[i]);
    }
    cprintf("  Test 2 passed!\n");
    
    // 测试3: 不同大小的分配
    cprintf("Test 3: Different sizes\n");
    void *p16 = slub_alloc(16);
    void *p32 = slub_alloc(32);
    void *p64 = slub_alloc(64);
    void *p128 = slub_alloc(128);
    void *p256 = slub_alloc(256);
    void *p512 = slub_alloc(512);
    void *p1024 = slub_alloc(1024);
    void *p2048 = slub_alloc(2048);
    
    assert(p16 != NULL && p32 != NULL && p64 != NULL && p128 != NULL);
    assert(p256 != NULL && p512 != NULL && p1024 != NULL && p2048 != NULL);
    
    cprintf("  Allocated sizes: 16=%p, 32=%p, 64=%p, 128=%p\n", p16, p32, p64, p128);
    cprintf("                   256=%p, 512=%p, 1024=%p, 2048=%p\n", p256, p512, p1024, p2048);
    
    slub_free(p16);
    slub_free(p32);
    slub_free(p64);
    slub_free(p128);
    slub_free(p256);
    slub_free(p512);
    slub_free(p1024);
    slub_free(p2048);
    cprintf("  Test 3 passed!\n");
    
    // 测试4: 填充slab(触发slab扩展)
    cprintf("Test 4: Fill slab (trigger slab growth)\n");
    struct kmem_cache *cache = get_kmem_cache(64);
    int num_objs = cache->num * 3; // 分配3个slab的对象
    void **objs = (void **)slub_alloc(num_objs * sizeof(void *));
    
    for (int i = 0; i < num_objs; i++) {
        objs[i] = kmem_cache_alloc(cache);
        assert(objs[i] != NULL);
    }
    cprintf("  Allocated %d objects from cache_%lu\n", num_objs, cache->objsize);
    
    // 检查链表状态
    int full_count = 0, partial_count = 0, free_count = 0;
    list_entry_t *le;
    
    for (le = list_next(&cache->slabs_full); le != &cache->slabs_full; le = list_next(le)) {
        full_count++;
    }
    for (le = list_next(&cache->slabs_partial); le != &cache->slabs_partial; le = list_next(le)) {
        partial_count++;
    }
    for (le = list_next(&cache->slabs_free); le != &cache->slabs_free; le = list_next(le)) {
        free_count++;
    }
    
    cprintf("  Slab lists: full=%d, partial=%d, free=%d\n", full_count, partial_count, free_count);
    
    // 释放所有对象
    for (int i = 0; i < num_objs; i++) {
        kmem_cache_free(cache, objs[i]);
    }
    slub_free(objs);
    cprintf("  Test 4 passed!\n");
    
    // 测试5: 边界情况
    cprintf("Test 5: Edge cases\n");
    void *p_zero = slub_alloc(0);
    assert(p_zero == NULL);
    slub_free(NULL); // 不应崩溃
    
    void *p_small = slub_alloc(1); // 最小分配
    assert(p_small != NULL);
    slub_free(p_small);
    
    void *p_max = slub_alloc(SLUB_MAX_SIZE); // 最大对象
    assert(p_max != NULL);
    slub_free(p_max);
    cprintf("  Test 5 passed!\n");
    
    // 测试6: 内存写入测试
    cprintf("Test 6: Memory write test\n");
    int *pi = (int *)slub_alloc(sizeof(int) * 10);
    assert(pi != NULL);
    for (int i = 0; i < 10; i++) {
        pi[i] = i * i;
    }
    for (int i = 0; i < 10; i++) {
        assert(pi[i] == i * i);
    }
    slub_free(pi);
    cprintf("  Test 6 passed!\n");
    
    cprintf("=== SLUB allocator check passed! ===\n");
}

/* ========== SLUB PMM管理器 ========== */

const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check = slub_check,
};

