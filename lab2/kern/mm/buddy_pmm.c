// kern/mm/buddy_pmm.c

#include <pmm.h>
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
    uint32_t order = get_order(n);
    struct Page *p = base;

    // 恢复页面的初始状态
    for (; p != base + (1 << order); p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    
    // 开始尝试合并
    while (order < MAX_ORDER -1) {
        // 计算伙伴页的索引
        uintptr_t page_idx = page2ppn(base);
        uintptr_t buddy_idx = page_idx ^ (1 << order);
        struct Page *buddy = pa2page(buddy_idx * PGSIZE);
        
        // 检查伙伴是否空闲且阶数相同
        if (!PageProperty(buddy) || buddy->property != order) {
            break; // 伙伴不满足合并条件
        }

        // 从空闲链表中移除伙伴
        list_del(&(buddy->page_link));
        free_area[order].nr_free--;
        ClearPageProperty(buddy);

        // 合并后，新的大块起始于地址较小的那个页
        if (buddy < base) {
            base = buddy;
        }
        
        order++; // 阶数加一，继续向上尝试合并
    }
    
    // 将最终的块加入空闲链表
    base->property = order;
    SetPageProperty(base);
    list_add(&(free_area[order].free_list), &(base->page_link));
    free_area[order].nr_free++;
    nr_free += (1 << order);
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}

// 检查函数，用于测试
static void buddy_check(void) {
    //待添加
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