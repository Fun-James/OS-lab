#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__

#include <defs.h>
#include <list.h>
#include <pmm.h>

/* SLUB分配器 - 两层架构的高效内存单元分配
 * 第一层: 基于页大小的内存分配(使用底层pmm_manager)
 * 第二层: 在第一层基础上实现基于任意大小的内存分配
 */

// SLUB配置常量
#define SLUB_MIN_SIZE       16      // 最小分配单元(字节)
#define SLUB_MAX_SIZE       2048    // 最大分配单元(字节)
#define SLUB_ALIGN          8       // 对齐大小
#define SLUB_CACHE_NUM      8       // kmem_cache数量

// 计算对齐后的大小
#define SLUB_ALIGN_SIZE(size) (((size) + SLUB_ALIGN - 1) & ~(SLUB_ALIGN - 1))

#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })

#define page2kva(page) (KADDR(page2pa(page)))
#define kva2page(kva) (pa2page(PADDR(kva)))

#define le2slab(le, member) \
    to_struct((le), struct slab, member)
    
/* kmem_cache结构 - 管理特定大小的对象
 * 每个kmem_cache管理一组相同大小的对象
 * 类似Linux的kmem_cache结构
 */
struct kmem_cache {
    size_t objsize;              // 对象大小(字节)
    size_t num;                  // 每个slab中的对象数量
    list_entry_t slabs_full;     // 完全分配的slab链表
    list_entry_t slabs_partial;  // 部分分配的slab链表
    list_entry_t slabs_free;     // 完全空闲的slab链表
    const char *name;            // cache名称(用于调试)
};

/* slab结构 - 一个物理页面,包含多个相同大小的对象
 * 每个slab管理一页(或多页)内存,将其分割为固定大小的对象
 */
struct slab {
    list_entry_t slab_link;      // 用于链接到kmem_cache的链表
    void *s_mem;                 // slab中第一个对象的地址
    int inuse;                   // 已使用的对象数量
    int free;                    // 下一个空闲对象的索引
    struct kmem_cache *cache;    // 所属的kmem_cache
};

/* freelist节点 - 用于管理slab中的空闲对象 */
struct freelist_node {
    struct freelist_node *next;  // 指向下一个空闲对象
};

// SLUB分配器接口
void slub_init(void);
void slub_init_memmap(struct Page *base, size_t n);
struct Page *slub_alloc_pages(size_t n);
void slub_free_pages(struct Page *base, size_t n);
size_t slub_nr_free_pages(void);
void slub_check(void);

// 对象分配接口
void *kmem_cache_alloc(struct kmem_cache *cache);
void kmem_cache_free(struct kmem_cache *cache, void *objp);

// 通用内存分配接口(类似kmalloc/kfree)
void *slub_alloc(size_t size);
void slub_free(void *objp);

// 获取预定义的kmem_cache
struct kmem_cache *get_kmem_cache(size_t size);

// SLUB管理器实例
extern const struct pmm_manager slub_pmm_manager;
extern struct kmem_cache kmem_caches[SLUB_CACHE_NUM];

#endif /* !__KERN_MM_SLUB_PMM_H__ */
