// kern/mm/buddy_pmm.c

#include <buddy_pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>

// 表示伙伴系统中块大小的最大阶数 (2^15 * 4KB = 128MB)
#define MAX_ORDER 15

// 用于管理不同大小空闲块的链表数组
static free_area_t free_area[MAX_ORDER];
// 记录总的空闲页数
static size_t nr_free;

// 检查 n 是否是 2 的幂
#define IS_POWER_OF_2(n) (!((n) & ((n)-1)))

// 计算满足 n 个页所需的最小阶数
static inline uint32_t get_order(size_t n) {
    uint32_t order = 0;
    while ((1 << order) < n) {
        order++;
    }
    return order;
}

// 初始化伙伴系统
static void buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
    }
    nr_free = 0;
}

// 初始化内存映射，将可用内存块加入伙伴系统
static void buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    
    // 将所有页面标记为可用
    for (struct Page *p = base; p < base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        // 在此处，我们只是初始化它，设为0即可。
        p->property = 0; 
        set_page_ref(p, 0);
    }
    
    size_t total_pages = n;
    struct Page *p = base;

    // 将大块内存切分成 2^k 大小的块，并加入相应的空闲链表
    while (total_pages > 0) {
        size_t order = 0;
        // 找到能放入剩余空间的最大阶数
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
            order++;
        }
        
        // 将这个最大块的头页面加入对应阶数的空闲链表
        list_add(&(free_area[order].free_list), &(p->page_link));
        free_area[order].nr_free++;
        nr_free += (1 << order);

        // 标记块头页的阶数，并设置其为空闲块头标志
        p->property = order;
        SetPageProperty(p); // 标记它是一个空闲块的头部
        
        p += (1 << order);
        total_pages -= (1 << order);
    }
}

// 分配页面
static struct Page *buddy_alloc_pages(size_t n) {
    if (n == 0) return NULL;
    if (n > nr_free) return NULL;
    
    // 计算所需最小阶数
    uint32_t order = get_order(n);
    uint32_t current_order;

    // 从所需阶数开始，向上查找可用的更大块
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
        if (!list_empty(&(free_area[current_order].free_list))) {
            break;
        }
    }

    if (current_order == MAX_ORDER) { // 没找到
        return NULL;
    }

    // 从找到的空闲链表中取出一个块
    list_entry_t *le = list_next(&(free_area[current_order].free_list));
    struct Page *page = le2page(le, page_link);
    list_del(le);
    free_area[current_order].nr_free--;

    // 如果找到的块比需要的大，则进行切分
    while (current_order > order) {
        current_order--;
        // 切分后的另一半（伙伴）
        struct Page *buddy = page + (1 << current_order);
        buddy->property = current_order; // 记录伙伴的阶数
        list_add(&(free_area[current_order].free_list), &(buddy->page_link));
        free_area[current_order].nr_free++;
    }

    // 标记分配出去的块为非空闲，并记录其阶数
    ClearPageProperty(page); 
    page->property = order;
    nr_free -= (1 << order);
    
    return page;
}

// 释放页面
static void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    
    // 修正：从 Page 结构体自身获取真实的阶数，而不是依赖n
    // 因为 alloc_pages(3) 会分配一个阶数为2的块，但调用者可能用 free_pages(p, 3) 来释放
    uint32_t order = base->property;

    // 修正：在函数开头，只为当前被释放的块增加空闲页计数
    nr_free += (1 << order);

    struct Page *p = base;
    // 将释放的页面标记为非保留和非分配状态
    for (; p != base + (1 << order); p++) {
        assert(!PageReserved(p));
        // 注意不能断言 !PageProperty(p)
        // 因为 base 页面（p=base时）的 PageProperty 可能是1，代表它是一个已分配块的头
        p->flags = 0;
        set_page_ref(p, 0);
    }
    
    // 开始循环合并
    while (order < MAX_ORDER - 1) {
        uintptr_t page_idx = page2ppn(base);
        uintptr_t buddy_idx = page_idx ^ (1 << order);
        struct Page *buddy = pa2page(buddy_idx * PGSIZE);
        
        // 检查伙伴是否是空闲块的头，并且阶数相同
        if (!PageProperty(buddy) || buddy->property != order) {
            break; // 不满足合并条件，跳出循环
        }

        // 从空闲链表中移除伙伴，准备合并
        list_del(&(buddy->page_link));
        free_area[order].nr_free--;
        ClearPageProperty(buddy); // 伙伴不再是空闲块头

        // 更新基地址，确保 base 指向地址较小的那个页
        if (buddy < base) {
            base = buddy;
        }
        
        // 阶数加一，进入下一轮合并尝试
        order++;
    }
    
    // 将最终的块（可能已合并）加入到正确的空闲链表中
    base->property = order;
    SetPageProperty(base); // 标记它是一个新的空闲块头
    list_add(&(free_area[order].free_list), &(base->page_link));
    free_area[order].nr_free++;
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}


// 查找当前系统中最大的可分配块的阶数
static int find_max_order(void) {
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
        if (!list_empty(&(free_area[i].free_list))) {
            return i;
        }
    }
    return -1;
}

static void show_buddy_info(const char *label) {
    cprintf("   --- %s ---\n", label);
    for (int i = 0; i < MAX_ORDER; i++) {
        if (free_area[i].nr_free > 0) {
            cprintf("     阶数 %2d (大小 %4d): %d 个空闲块\n", i, 1 << i, free_area[i].nr_free);
        }
    }
    cprintf("   --------------------------------\n");
}

static void buddy_check(void) {
    cprintf("=== 开始伙伴系统测试 ===\n");
    size_t initial_free = buddy_nr_free_pages();
    cprintf("初始空闲页数: %d\n\n", initial_free);

    
    // 1. 测试简单请求和释放操作
    
    cprintf("1. 简单的分配和释放操作\n");
    show_buddy_info("初始状态");
    struct Page *p1 = alloc_pages(16);
    show_buddy_info("分配 16 页后");
    assert(p1 != NULL);
    assert(buddy_nr_free_pages() == initial_free - 16);
    cprintf("   - 已分配 16 页。通过。\n");

    free_pages(p1, 16);
    show_buddy_info("释放 16 页后");
    assert(buddy_nr_free_pages() == initial_free);
    cprintf("   - 已释放 16 页。通过。\n");


    
    // 2. 测试复杂请求和释放操作 (碎片化与合并)
    
    cprintf("2. 复杂的分配和释放操作\n");
    show_buddy_info("初始状态");
    struct Page *p2 = alloc_pages(3);  // 消耗4页
    show_buddy_info("分配 3 页后");
    struct Page *p3 = alloc_pages(10); // 消耗16页
    show_buddy_info("分配 10 页后");
    assert(p2 != NULL && p3 != NULL);
    assert(buddy_nr_free_pages() == initial_free - 4 - 16);
    cprintf("   - 已分配 3 页块 (实际消耗 4 页) 和 10 页块 (实际消耗 16 页)。通过。\n");
    
    // 逆序释放,测试合并逻辑
    free_pages(p3, 10);
    show_buddy_info("释放 10 页后");
    assert(buddy_nr_free_pages() == initial_free - 4);
    cprintf("   - 已释放 10 页块。通过。\n");
    
    free_pages(p2, 3);
    show_buddy_info("释放 3 页后");
    assert(buddy_nr_free_pages() == initial_free);
    cprintf("   - 已释放 3 页块。通过。\n");


    
    // 3. 测试请求和释放最小单元操作 (可视化分割与合并)

    cprintf("3. 最小单元操作 \n");
    show_buddy_info("初始状态");

    // 分配一个最小单元
    struct Page *p_min1 = alloc_pages(1);
    struct Page *p_min2 = alloc_pages(1);
    assert(p_min1 != NULL && p_min2 != NULL);
    cprintf("   - 已分配两次 1 页。通过。\n");
    show_buddy_info("分配两次 1 页后");

    // 释放这个最小单元
    free_pages(p_min1, 1);
    free_pages(p_min2, 1);
    cprintf("   - 已释放两次 1 页。通过。\n");
    show_buddy_info("释放两次 1 页后");
    
    // 检查内存是否完全恢复
    assert(buddy_nr_free_pages() == initial_free);
    cprintf("   - 测试通过: 最小单元操作正确。\n\n");


    
    // 4. 测试请求和释放最大单元操作
    
    cprintf("4. 最大单元操作\n");
    int max_order = find_max_order();
    show_buddy_info("初始状态");
    int max_block_size = (1 << max_order);
    // 分配这个最大的块
    struct Page *p_max = alloc_pages(max_block_size);
    show_buddy_info("分配最大块后");
    assert(p_max != NULL);
    cprintf("   - 已分配最大块。通过。\n");
    assert(buddy_nr_free_pages() == initial_free - max_block_size);

    // 释放这个最大的块
    free_pages(p_max, max_block_size);
    show_buddy_info("释放最大块后");
    assert(buddy_nr_free_pages() == initial_free);
    cprintf("   - 已释放最大块。通过。\n");
    
    // 再次查找最大块,阶数应该和之前一样
    assert(find_max_order() == max_order);
    cprintf("   - 验证通过: 最大块再次可用。\n");

    cprintf("5. “穿插打孔”碎片化与合并\n");
    show_buddy_info("初始状态");
    const int ALLOC_COUNT = 20;
    const int ALLOC_SIZE = 4;
    struct Page *allocated[ALLOC_COUNT];

    for (int i = 0; i < ALLOC_COUNT; i++) {
        allocated[i] = alloc_pages(ALLOC_SIZE);
        assert(allocated[i] != NULL);
    }
    show_buddy_info("分配 20 个 4 页块后");
    cprintf("   - 连续分配了 %d 个 %d 页大小的块. OK.\n", ALLOC_COUNT, ALLOC_SIZE);
    // 释放偶数块，制造孔洞
    for (int i = 0; i < ALLOC_COUNT; i += 2) {
        free_pages(allocated[i], ALLOC_SIZE);
    }
    show_buddy_info("释放所有偶数块后");
    cprintf("   - 释放了所有偶数块，制造碎片. OK.\n");
    assert(buddy_nr_free_pages() == initial_free - (ALLOC_COUNT / 2) * ALLOC_SIZE);

    // 释放奇数块，触发合并
    for (int i = 1; i < ALLOC_COUNT; i += 2) {
        free_pages(allocated[i], ALLOC_SIZE);
    }
    show_buddy_info("释放所有奇数块后");
    cprintf("   - 释放了所有奇数块，触发合并. OK.\n");

    assert(buddy_nr_free_pages() == initial_free);
    cprintf("   - PASS: 碎片化合并测试正确.\n\n");

    cprintf("=== 伙伴系统测试完成 ===\n");
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};