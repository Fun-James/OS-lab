张奥喆（2313447） 余俊辉（2313486） 杨李泽（2313851）

***

# 练习1: 完成读文件操作的实现（需要编码）

## 1.打开文件的处理流程分析

在 uCore 中，打开文件是一个从用户态到内核态，再从虚拟文件系统（VFS）到具体文件系统（SFS）的层层递进过程。主要流程如下：

1. **用户态 (`open`)**: 用户程序调用 `open(path, open_flags)` 函数。此函数会触发 `SYS_open` 系统调用，将控制权转移给内核。

2. **系统调用层 (`sys_open`)**: 内核收到中断后，进入 `sys_open`。它主要负责从用户空间获取参数（路径字符串和标志位），然后调用 VFS 层的接口 `vfs_open`。

3. **VFS 层 (`vfs_open`)**: `vfs_open` 是文件系统无关的通用接口。它主要完成以下工作：

   * **分配 file 结构**: 在当前进程的文件描述符表中分配一个空的 `file` 结构。

   * **路径查找 (`vfs_lookup`)**: 根据文件路径，调用 `vfs_lookup` 找到该文件对应的 inode（索引节点）。如果文件不存在且有创建标志，则会调用 `vop_create` 创建文件。

   * **关联 inode**: 将找到的 `inode` 与分配的 `file` 结构关联起来。

   * **打开文件 (`vop_open`)**: 调用具体文件系统的打开函数。对于 SFS 而言，就是 `sfs_open`。

4. **SFS 层 (`sfs_open`)**: 在 SFS 中，`sfs_open` 主要检查打开模式与 inode 的类型是否匹配（例如不能以写模式打开目录），通过检查后，文件即成功打开，返回文件描述符 `fd` 给用户。

## 2.文件读写操作的过程分析

读文件的流程与打开文件类似，也是通过 VFS 分发到具体的 SFS 实现：

1. **用户态 (`read`)**: 调用 `read(fd, base, len)`。

2. **系统调用层 (`sys_read`)**: 解析参数，根据 `fd` 找到对应的 `file` 结构，调用 `file_read`。

3. **文件层 (`file_read`)**: 检查权限和缓冲区有效性，调用 `vfs_read` -> `vop_read`。

4. **SFS 层 (`sfs_read`)**:

   * `sfs_read` 实际上是 `sfs_io` 的封装。

   * `sfs_io` 会先获取 inode 的信号量锁（保证互斥访问），然后调用核心函数 `sfs_io_nolock` 进行实际的数据传输。

   * **练习的核心就在于 `sfs_io_nolock` 的实现**。它负责将磁盘块中的数据通过缓冲区拷贝到内存中，或者反之。

## 3. `sfs_io_nolock` 函数实现

该函数位于 `kern/fs/sfs/sfs_inode.c` 中。其核心在于处理**不以块对齐**的读写请求，将操作分为三个阶段：起始部分、中间完整块、结尾部分。

```c
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, off_t offset, size_t *alenp, bool write) {
    // ... (省略参数校验、边界检查和 endpos 计算等) ...

    // (1) 处理第一个块（可能不对齐）
    blkoff = offset % SFS_BLKSIZE;  // 在第一个块内的偏移
    if (blkoff != 0) {
        // 第一个块不对齐，需要用 sfs_buf_op 处理部分块
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
        // 获取第一个块的磁盘块号
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        // 读/写部分块
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
            goto out;
        }
        alen += size;
        buf += size;
        blkno++;
        if (nblks > 0) {
            nblks--;
        }
    }

    // (2) 处理中间的完整块
    if (nblks > 0) {
        while (nblks > 0) {
            // 获取磁盘块号
            if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
                goto out;
            }
            // 读/写整个块 (注意这里使用 sfs_block_op 优化)
            if ((ret = sfs_block_op(sfs, buf, ino, 1)) != 0) {
                goto out;
            }
            alen += SFS_BLKSIZE;
            buf += SFS_BLKSIZE;
            blkno++;
            nblks--;
        }
    }

    // (3) 处理最后一个块（可能不对齐）
    size = endpos % SFS_BLKSIZE;
    if (size != 0) {
        // 最后一个块不对齐
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        // 读/写部分块（从块开头到 endpos % SFS_BLKSIZE）
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        alen += size;
    }

out:
    *alenp = alen;
    // ... (更新 inode 大小等元数据) ...
    return ret;
}
```

## 4. 实现逻辑详细说明

该实现采用了**分段处理**的策略，针对文件读写在块边界上的不同情况分别处理，比单一循环逻辑更清晰且能利用块操作优化：

1. **处理起始段 (Head)**: 检查起始偏移 `offset` 是否在块中间 (`blkoff != 0`)。如果是，则当前块为“非对齐块”。

   * 计算需要处理的字节数 `size`：如果这既是第一块也是最后一块，长度为 `endpos - offset`；否则长度为该块剩余部分 `SFS_BLKSIZE - blkoff`。

   * 调用 `sfs_buf_op` 处理这部分数据。

   * 处理完后，将逻辑块号 `blkno` 加 1，并维护剩余完整块计数 `nblks`。

2. **处理中间完整块 (Body)**: 对于中间完全被覆盖的块（`nblks > 0`），直接进行整块操作。

   * 循环处理这些块。

   * **优化点**：这里使用了 `sfs_block_op` 而不是 `sfs_buf_op`。`sfs_block_op` 专门用于整块传输，效率更高。

3. **处理结束段 (Tail)**: 检查结束位置 `endpos` 是否对齐块边界。如果不对齐 (`size = endpos % SFS_BLKSIZE != 0`)，说明最后一个块只需要读写开头的一部分。

   * 调用 `sfs_buf_op` 处理从块头开始的 `size` 字节。

这种写法将不对齐的边界情况与中间的高速整块传输分离开来，逻辑上更加严谨。

***

# 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）

## 1. 设计思路与实现流程

本练习的目标是改写 `kern/process/proc.c` 中的 `load_icode` 函数，使其能够从文件系统（通过文件描述符 `fd`）读取 ELF 格式的应用程序，并将其加载到内存中执行。这与之前实验中直接从内存镜像加载程序不同，需要结合文件 I/O 接口与虚拟内存管理。

**主要执行流程如下：**

1. **建立内存管理结构 (`mm_struct`)**：

   * 为当前进程创建一个新的 `mm` 结构。

   * 初始化页目录表 (`pgdir`)，并拷贝内核空间的页表映射，确保内核空间在用户进程中可用。

2. **读取并校验 ELF 头**：

   * 利用 `load_icode_read` 函数（封装了 `sysfile_read` 和 `sysfile_seek`）从文件描述符 `fd` 中读取 ELF Header。

   * 校验 ELF 魔数 (`e_magic`)，确保文件格式正确。

3. **加载程序段 (Segments)**：

   * 遍历 ELF 的 Program Headers (`ph`)。

   * 对于类型为 `ELF_PT_LOAD` 的段，根据 ELF 头中的标志位 (`p_flags`) 设置虚拟内存权限 (`vm_flags`)，如可读、可写、可执行。

   * 调用 `mm_map` 建立虚拟地址空间 (VMA)。

   * **内存分配与内容读取**：

     * 分配物理页 (`pgdir_alloc_page`)。

     * 计算文件偏移量，将文件内容读取到对应的物理页中。

     * **BSS 段处理**：对于内存大小 (`memsz`) 大于文件大小 (`filesz`) 的部分（通常是 BSS 段），将其初始化为 0。

4. **建立用户栈**：

   * 调用 `mm_map` 映射用户栈空间 (`USTACKTOP`)。

   * 预先分配若干物理页以防止缺页异常。

5. **处理用户参数 (`argc`/`argv`)**：

   * 这是本实验的重要新增功能。需要将传入的参数字符串拷贝到用户栈的顶部。

   * 计算每个参数的地址，并在栈上构建 `argv` 指针数组。

6. **上下文切换准备**：

   * 更新当前进程的 `mm` 和 `cr3` (页表基址)。

   * 设置中断帧 (`TrapFrame`)：

     * `sp`：指向用户栈顶（经过参数压栈后的位置）。

     * `epc`：指向 ELF 的入口地址 (`e_entry`)。

     * `status`：清除 `SSTATUS_SPP`（确保返回用户态），设置 `SSTATUS_SPIE`（允许中断）。

## 练习2 代码分析：load\_icode 函数深度解析

在 Lab 8 中，`load_icode` 函数是操作系统加载用户程序的核心。它实现了从文件系统读取 ELF 格式二进制文件、建立虚拟内存映射、并将代码与数据加载到内存执行的完整过程。与之前实验直接从内存镜像加载不同，本实验引入了文件系统接口，涉及频繁的 I/O 操作。

### 1. 辅助函数 `load_icode_read` 的引入

为了适配文件系统的读取接口，实验封装了 `load_icode_read` 函数，作为文件读取的通用适配器。

**关键代码：**

```c
static int load_icode_read(int fd, void *buf, size_t len, off_t offset) {
 int ret;
     if ((ret = sysfile_seek(fd, offset, LSEEK_SET)) != 0) { // 移动文件指针
         return ret;
     }
     size_t copied = len;
     if ((ret = sysfile_read(fd, buf, len, &copied)) != 0) { // 读取数据
         return ret;
     }
     return (copied != len) ? -1 : 0;
 }
```

**实现逻辑：**

* **模拟内存操作**：该函数的作用是模拟类似 `memcpy` 的行为，但针对的是文件。

* **游标定位**：首先调用 `sysfile_seek` 将文件描述符 `fd` 的读写指针移动到指定的 `offset` 绝对位置。

* **数据读取**：随后调用 `sysfile_read` 从当前位置读取 `len` 长度的数据到内存缓冲区 `buf` 中。

* **屏蔽差异**：通过此封装，`load_icode` 在解析 ELF 头或读取段数据时，无需关心底层文件系统的游标状态，可以像操作内存数组一样随机访问文件内容。

***

### 2. `load_icode` 核心流程逐行解析

`load_icode` 的执行过程错综复杂，可以细分为以下六个关键阶段：

#### 阶段一：建立新内存空间

**关键代码：**

```c
 // (1) 创建新的 mm_struct
 if ((mm = mm_create()) == NULL) { goto bad_mm; }
 
 // (2) 创建页目录表，并拷贝内核页表映射
 if ((ret = setup_pgdir(mm)) != 0) { goto bad_pgdir_cleanup_mm; }
```

**实现逻辑：**

* **管理结构初始化**：首先调用 `mm_create` 为当前进程分配并初始化一个新的内存管理结构 `mm_struct`。

* **内核空间映射**：调用 `setup_pgdir` 分配页目录表（Page Directory）。此处至关重要的一步是拷贝内核页表的映射关系，确保用户进程在陷入内核态（如系统调用、中断）时，依然能够正确寻址内核空间的代码和数据。

#### 阶段二：解析 ELF Header

**关键代码：**

```c
 struct elfhdr elf;
 // 读取文件头
 if ((ret = load_icode_read(fd, &elf, sizeof(elf), 0)) != 0) { ... }
 // 校验魔数
 if (elf.e_magic != ELF_MAGIC) { ret = -E_INVAL_ELF; ... }
```

**实现逻辑：**

* **读取元数据**：利用辅助函数读取文件起始处的 `sizeof(struct elfhdr)` 字节。

* **格式校验**：检查读取到的 `e_magic` 是否等于 ELF 标准魔数（`0x464C457F`），以确保当前文件是合法的 ELF 可执行文件，防止加载错误格式导致系统崩溃。

#### 阶段三：加载程序段（Program Segments）

这是函数中最复杂的部分，主要负责将磁盘上的代码和数据映射到虚拟内存。

**3.1 读取 Program Header**

**关键代码：**

```c
 struct proghdr ph;
 load_icode_read(fd, &ph, sizeof(ph), elf.e_phoff + i * sizeof(ph));
```

**实现逻辑：**

* 根据 ELF 头中记录的程序头表偏移量 `e_phoff` 和当前遍历的索引 `i`，计算出当前段头在文件中的位置，并读取段的元数据（如虚拟地址、文件偏移、大小、权限等）。

**3.2 权限位转换（ELF -> VMM -> PTE）**

**关键代码：**

```c
// 1. ELF 标志 -> VMM 标志
 if (ph.p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
 if (ph.p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
 if (ph.p_flags & ELF_PF_R) vm_flags |= VM_READ;
 
 // 2. VMM 标志 -> RISC-V 硬件 PTE 标志
 if (vm_flags & VM_READ) perm |= PTE_R;
 if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
 if (vm_flags & VM_EXEC) perm |= PTE_X;
```

**实现逻辑：**

* **抽象转换**：将文件格式定义的抽象权限（`ELF_PF_*`）转换为操作系统内部 VMM 管理的权限标志（`VM_*`）。

* **硬件适配**：将 OS 的权限标志转换为 RISC-V 硬件页表项（PTE）能识别的控制位。例如，可写权限通常隐含可读权限。

**3.3 建立虚拟内存映射 (VMA)**

**关键代码：**

```c
 mm_map(mm, ph.p_va, ph.p_memsz, vm_flags, NULL);
```

**实现逻辑：**

* 调用 `mm_map` 在 `mm` 结构中登记该段的合法虚拟地址范围 `[ph.p_va, ph.p_va + ph.p_memsz)`，确立逻辑上的地址空间所有权。

**3.4 物理内存分配与内容拷贝 (TEXT/DATA)**

**关键代码：**

```c
while (start < end) {
     if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) { ... } // 分配物理页

     off = start - la;      // 计算页内偏移
     size = PGSIZE - off;   // 计算本页写入量

     // 从文件读取数据到物理页对应的内核虚拟地址
     load_icode_read(fd, page2kva(page) + off, size, ph.p_offset + (start - ph.p_va));

     start += size;
     la += PGSIZE;
 }
```

**实现逻辑：**

* **按页处理**：由于文件段可能跨越多个物理页，代码使用循环逐页处理。

* **分配与映射**：调用 `pgdir_alloc_page` 分配物理内存并建立页表映射。

* **数据加载**：计算当前虚拟地址对应的文件偏移量，直接将磁盘上的代码或数据读取到物理页中。注意这里使用了 `page2kva` 将物理页转换为内核虚拟地址以便内核操作。

**3.5 BSS 段处理 (Zero-init)**

**关键代码：**

```c
// 处理上一页剩余部分的 BSS
 if (end < la) {
     memset(page2kva(page) + off, 0, size);
 }
 // 为剩余的纯 BSS 数据分配新页并清零
 while (start < end) {
     if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) { ... }
     memset(page2kva(page) + off, 0, size);
 }
```

**实现逻辑：**

* **零初始化**：ELF 文件中 BSS 段（未初始化数据）在磁盘上不占空间（`p_memsz > p_filesz`），但在内存中需要占位且初始值为 0。

* **清理残留**：先将 TEXT/DATA 段最后一页中超出文件大小的部分清零；如果 BSS 段很大，则继续分配新的物理页并进行全页清零。

#### 阶段四：建立用户栈

**关键代码：**

```c
// 映射用户栈 VMA
 vm_flags = VM_READ | VM_WRITE | VM_STACK;
 mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL);
 
 // 预分配物理页
 for (i = 1; i <= 4; i++) {
     pgdir_alloc_page(mm->pgdir, USTACKTOP - i * PGSIZE, PTE_USER);
 }
```

**实现逻辑：**

* **界定范围**：设置用户栈顶为 `USTACKTOP`，建立对应的 VMA。

* **预分配**：为了防止后续向栈压入参数（Argv）时立即触发缺页异常（此时异常处理机制可能尚未完全就绪），代码预先分配了 4 页物理内存并建立映射。

#### 阶段五：构建参数栈（Argc/Argv）

这是 Lab 8 的关键新增功能，负责将 Shell 传入的参数传递给用户程序。

**5.1 切换页表**

**关键代码：**

```c
lsatp(PADDR(mm->pgdir)); // 切换页表基址寄存器
 flush_tlb();             // 刷新 TLB
```

**实现逻辑：**

* 在向用户栈写入数据前，必须激活新进程的地址空间。通过重设 `satp` 寄存器并刷新 TLB，CPU 开始使用新进程的页表，使得后续对 `ustack` 等虚拟地址的访问能正确映射到刚才分配的物理内存。

**5.2 压入参数字符串**

**关键代码：**

```c
uintptr_t ustack = USTACKTOP - 32; // 预留安全空间
 for (i = argc - 1; i >= 0; i--) {  // 逆序压栈
     size_t slen = strnlen(kargv[i], EXEC_MAX_ARG_LEN) + 1;
     ustack -= slen;
     ustack = ROUNDDOWN(ustack, sizeof(uintptr_t)); // 内存对齐
     memcpy((void *)ustack, kargv[i], slen);        // 拷贝字符串
     uargv_store[i] = ustack;                       // 记录地址
 }
```

**实现逻辑：**

* **逆序拷贝**：从高地址向低地址增长，将具体的参数字符串内容拷贝到用户栈上。

* **对齐与记录**：确保每个字符串地址满足对齐要求，并将其在栈上的地址临时保存在 `uargv_store` 数组中，供后续构建指针数组使用。

**5.3 压入参数指针数组 (argv\[])**

**关键代码：**

```c
 ustack -= (argc + 1) * sizeof(uintptr_t);      // 腾出数组空间
 ustack = ROUNDDOWN(ustack, 16);                // RISC-V 栈对齐
 memcpy((void *)ustack, uargv_store, (argc + 1) * sizeof(uintptr_t));
```

**实现逻辑：**

* 在字符串内容下方，构建 `argv` 指针数组。该数组包含指向上述字符串的指针，并以 `NULL` 结尾。

* **RISC-V 对齐**：严格遵守 RISC-V 架构要求，确保最终的栈指针是 16 字节对齐的。

#### 阶段六：设置中断帧（Trapframe）

**关键代码：**

```c
struct trapframe *tf = current->tf;
 memset(tf, 0, sizeof(struct trapframe));
 tf->gpr.sp = ustack;       // 设置用户栈指针
 tf->gpr.a0 = argc;         // 参数 1：argc
 tf->gpr.a1 = ustack;       // 参数 2：argv (即指针数组的起始地址)
 tf->epc = elf.e_entry;     // 设置入口地址
 tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE; // 用户态 + 开中断
```

**实现逻辑：**

* **上下文准备**：构造中断帧，以便通过 `sret` 指令返回用户态时，CPU 能够进入正确的状态。

* **入口与栈**：`epc` 指向 ELF 文件的入口点，`sp` 指向构建好参数后的栈顶 `ustack`。

* **参数传递**：根据 RISC-V 调用约定，将 `argc` 存入 `a0`，将 `argv` 数组的地址存入 `a1`，使 `main` 函数能正确接收参数。

### 3. 资源清理

**关键代码：**

```c
 sysfile_close(fd);
```

**实现逻辑：**

* **防止泄漏**：无论加载成功与否，函数返回前都必须关闭打开的文件描述符，释放文件系统资源。

***

# 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案

## 1. **概要设计**

UNIX 管道（Pipe）是一种进程间通信（IPC）机制，允许一个进程的输出作为另一个进程的输入。在 ucore 中，管道可以被视为一种特殊的文件，它不对应磁盘上的数据块，而是对应内核中的一段内存缓冲区。

设计核心思想：

* **内存文件**：管道本质上是一个内存缓冲区，通过文件描述符（fd）进行访问。

* **生产者-消费者模型**：写进程向缓冲区写入数据（生产者），读进程从缓冲区读取数据（消费者）。

* **FIFO**：数据先进先出。

* **同步与互斥**：需要处理缓冲区满（写阻塞）、缓冲区空（读阻塞）以及并发读写时的互斥问题。

## **2. 数据结构设计**

我们需要定义一个 `pipe_inode_info` 结构体来管理管道的状态，并将其集成到 ucore 的 `inode` 结构中。

```c
// kern/fs/pipe/pipe.h

#define PIPE_SIZE 4096 // 管道缓冲区大小

/* 管道信息结构体 */
struct pipe_inode_info {
    char *base;             // 缓冲区基地址 (内核虚拟地址)
    uint16_t start;         // 读指针 (相对于 base 的偏移)
    uint16_t end;           // 写指针 (相对于 base 的偏移)
    bool is_closed;         // 管道是否已关闭
    
    /* 同步互斥机制 */
    semaphore_t mutex;      // 互斥锁，保护缓冲区操作
    semaphore_t wait_read;  // 读等待信号量 (缓冲区空时等待)
    semaphore_t wait_write; // 写等待信号量 (缓冲区满时等待)
    
    /* 引用计数 */
    int readers;            // 读端引用计数
    int writers;            // 写端引用计数
};
```

同时，需要修改 `kern/fs/vfs/inode.h` 中的 `struct inode`，加入管道信息的联合体成员：

```c
// kern/fs/vfs/inode.h

struct inode {
    union {
        struct device __device_info;
        struct sfs_inode __sfs_inode_info;
        struct pipe_inode_info __pipe_inode_info; // 新增：管道信息
    } in_info;
    enum {
        inode_type_device_info = 0x1234,
        inode_type_sfs_inode_info,
        inode_type_pipe_inode_info, // 新增：管道类型标识
    } in_type;
    // ... 其他原有字段
};
```

## **3. 接口设计**

我们需要实现一组针对管道的 `inode_ops` 操作函数，并提供创建管道的系统调用接口。

#### **3.1 系统调用接口**

```c
/* 
 * 创建管道
 * fd_store: 用于返回两个文件描述符，fd_store[0]用于读，fd_store[1]用于写
 * 返回值: 0 成功, <0 失败
 */
int sys_pipe(int *fd_store);
```

#### **3.2 VFS 接口 (inode\_ops)**

```c
/* 管道的 inode 操作函数表 */
struct inode_ops pipe_node_ops = {
    .vop_magic = VOP_MAGIC,
    .vop_open = pipe_open,
    .vop_close = pipe_close,
    .vop_read = pipe_read,
    .vop_write = pipe_write,
    .vop_fstat = pipe_fstat,
    // 其他操作如 seek, ioctl 等对管道通常无效或需特殊处理
};

/* 语义描述 */

// 从管道读取数据
// 如果缓冲区为空且写端未关闭，则阻塞等待 wait_read
// 如果缓冲区为空且写端已关闭，返回 0 (EOF)
int pipe_read(struct inode *node, struct iobuf *iob);

// 向管道写入数据
// 如果缓冲区已满且读端未关闭，则阻塞等待 wait_write
// 如果读端已关闭，发送 SIGPIPE 信号或返回错误 (EPIPE)
int pipe_write(struct inode *node, struct iobuf *iob);

// 关闭管道的一端
// 如果是读端关闭，减少 readers 计数；如果是写端关闭，减少 writers 计数
// 如果 readers 或 writers 降为 0，唤醒相应的等待队列
// 当两者都为 0 时，释放 pipe_inode_info 及缓冲区
int pipe_close(struct inode *node);
```

## **4. 同步互斥处理**

* **互斥访问**：使用`mutex`信号量保护`start`, `end` 指针以及缓冲区内容的读写操作。任何对缓冲区的修改前必须获取 `mutex`。

* **读阻塞**：在 `pipe_read` 中，如果 `start == end` (缓冲区空)，且 `writers > 0`，则调用 `down(&wait_read)` 进入睡眠。写进程写入数据后，调用 `up(&wait_read)` 唤醒读进程。

* **写阻塞**：在 `pipe_write` 中，如果缓冲区满 ( `(end + 1) % PIPE_SIZE == start` )，且`readers > 0`，则调用 `down(&wait_write)` 进入睡眠。读进程读取数据腾出空间后，调用 `up(&wait_write)` 唤醒写进程。

* **原子性**：对于小于 `PIPE_BUF`(通常 4KB) 的写入操作，必须保证原子性，即数据连续写入，不被其他进程的写入穿插。这通过在整个写入过程中持有 `mutex` 来实现。

***

# 扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案

### **1. 概要设计**

**硬链接**：在文件系统中创建多个目录项指向同一个 inode。所有硬链接共享相同的 inode number 和数据块。删除一个硬链接只是减少 inode 的引用计数，只有当引用计数为 0 时才真正删除文件。

**软链接**：一种特殊类型的文件，其数据块中存储的是另一个文件的路径。访问软链接时，内核会读取其内容并重定向到目标路径。

### **2. 数据结构设计**

#### **2.1 硬链接**

硬链接不需要新的数据结构，主要依赖于现有的 `sfs_disk_inode` 中的 `nlinks` 字段。

```c
// kern/fs/sfs/sfs.h (已有)
struct sfs_disk_inode {
    // ...
    uint16_t nlinks;   /* 硬链接计数 */
    // ...
};
```

#### **2.2 软链接**

软链接需要一种新的文件类型标识。

```c
// kern/fs/sfs/sfs.h

/* 文件类型定义 */
#define SFS_TYPE_INVAL  0
#define SFS_TYPE_FILE   1
#define SFS_TYPE_DIR    2
#define SFS_TYPE_LINK   3  // 软链接类型
```

软链接的 inode 结构与普通文件相同，只是 `type` 字段为 `SFS_TYPE_LINK`，且其数据块内容被解释为路径字符串。

### **3. 接口设计**

#### **3.1 系统调用接口**

```c
/*
 * 创建硬链接
 * old_path: 现有的文件路径
 * new_path: 新的硬链接路径
 */
int sys_link(const char *old_path, const char *new_path);

/*
 * 删除链接 (unlink)
 * path: 要删除的路径
 * 如果是硬链接，减少 nlinks；如果 nlinks=0，删除文件。
 */
int sys_unlink(const char *path);

/*
 * 创建软链接
 * target: 目标路径 (内容)
 * linkpath: 软链接文件路径
 */
int sys_symlink(const char *target, const char *linkpath);

/*
 * 读取软链接内容
 * path: 软链接路径
 * buf: 缓冲区
 * len: 缓冲区大小
 */
int sys_readlink(const char *path, char *buf, size_t len);
```

#### **3.2 VFS/SFS 内部实现逻辑**

**硬链接实现 (`sfs_link`)**:

1. 解析 `old_path` 获取 `old_inode`。

2. 检查 `old_inode` 类型（通常不允许对目录创建硬链接以避免环路）。

3) 解析 `new_path` 的父目录 `dir_inode`。

4) 在 `dir_inode` 中创建一个新目录项（entry），名称为 `new_path` 的文件名部分，inode 编号为 `old_inode->ino`。

5. `old_inode->nlinks++`。

6. 将 `old_inode` 和 `dir_inode` 刷回磁盘。

**软链接实现 (`sfs_symlink`)**:

1. 解析 `linkpath` 的父目录。

2. 分配一个新的 inode，类型设为 `SFS_TYPE_LINK`。

3) 将 `target` 字符串写入新 inode 的数据块中。

4) 在父目录中创建目录项指向新 inode。

**软链接读取 (`sfs_readlink`)**:

1. 类似于 `sfs_read`，但仅对 `SFS_TYPE_LINK` 类型的 inode 有效。

2. 直接从数据块读取内容返回给用户。

**路径解析支持**:

需要修改 `vfs_lookup` 逻辑。当遇到 `SFS_TYPE_LINK` 类型的 inode 时：

1. 读取其内容（目标路径）。

2. 如果是绝对路径，从根目录重新开始解析。

3) 如果是相对路径，从当前目录继续解析。

4) 需要设置最大递归深度（如 `MAX_SYMLINKS 8`）以防止死循环。

### **4. 同步互斥处理**

* **目录操作互斥**：创建链接（硬/软）和删除链接都涉及对目录项的修改。必须持有父目录的信号量或文件系统的全局互斥锁（如 `sfs_fs->mutex_sem`），以防止两个进程同时在同一目录下创建同名文件或破坏目录结构。

* **Inode 更新互斥**：修改 `nlinks` 时，需要持有 inode 的锁（`sfs_inode->sem`），确保引用计数的更新是原子的。

* **死锁避免**：在 `sys_link` 中，可能需要同时锁定两个 inode（源文件 inode 和目标目录 inode）。应遵循固定的加锁顺序（例如按 inode 编号大小顺序，或先锁目录再锁文件）来避免死锁。但在 SFS 的简单实现中，通常使用一个大锁（`sfs_fs->mutex_sem`）保护所有目录结构的变更操作即可简化问题。

***

# 实验知识点与操作系统原理知识点的对应与分析

## 本实验中重要的知识点及其与 OS 原理的对应关系

在本实验（Lab 8）中，我们主要完成了文件系统的抽象层（VFS）、简单的磁盘文件系统（SFS）的读写操作以及可执行文件的加载。这些实践内容深刻地体现了操作系统原理中关于文件管理和设备管理的以下核心概念：

1. **虚拟文件系统（VFS）与分层设计**

   * **实验内容**：实验中涉及了 `file`、`inode`、`vfs` 等数据结构，并且要求实现通用文件读写接口（如 `sfs_io_nolock`）。这些接口屏蔽了底层具体文件系统（SFS）和设备（Device）的差异。

   * **OS原理对应**：对应关于“虚拟文件系统 (VFS)”的章节。原理上，OS 通过 VFS 提供统一的系统调用接口（open, read, write），将对特定文件系统的操作映射到物理文件系统中。实验中的 `vfs_dev_t` 和 `inode_ops` 正是这一抽象层的具体实现，体现了“多文件系统兼容”和“接口标准化”的设计思想。

2. **索引节点（Inode）与文件分配方式**

   * **实验内容**：在 SFS 的实现中，我们需要操作 `sfs_disk_inode`，其中包含了文件大小、数据块索引等信息。特别是在 `sfs_io_nolock` 中，通过索引块（direct, indirect blocks）来定位文件数据在磁盘上的物理位置。

   * **OS原理对应**：对中关于“文件控制块 (FCB/Inode)”和“磁盘空间管理”的知识点。实验采用了类 Unix 的**索引分配**（Indexed Allocation）策略，而非连续分配或链接分配。这验证了原理中关于利用索引节点高效支持随机访问和动态增长的理论。

3. **设备独立性与“一切皆文件”**

   * **实验内容**：实验要求处理串口设备（stdin/stdout），将其包装成文件系统中的节点，使得用户进程可以通过 `read/write` 文件的方式来操作控制台。

   * **OS原理对应**：对应中“设备的标准化”和 **PPT 6.2** 中关于设备文件的概念。Unix 哲学中的“一切皆文件”在实验中通过将设备驱动程序的接口通过函数指针挂载到 inode 的操作接口上得以实现，从而实现了应用程序与具体硬件细节的解耦。

4. **可执行文件格式与进程加载（ELF）**

   * **实验内容**：实现了 `load_icode` 函数，该函数从磁盘上读取 ELF 格式的二进制文件，解析 program header，并将代码段、数据段加载到内存中建立用户进程。

   * **OS原理对应**：对应提到的 **ELF 文件格式**以及 OS 如何解析文件逻辑结构。实验将文件管理与内存管理（虚存映射）结合起来，展示了程序是如何从磁盘上的静态“文件”变为内存中动态“进程”的全过程。

5. **目录结构与路径解析**

   * **实验内容**：虽然 SFS 结构简单，但仍实现了根目录和文件的层级关系，内核需要能够根据路径名找到对应的 inode。

   * **OS原理对应**：对应“目录结构”。实验模拟了最基本的树形目录结构，验证了目录本质上是一种特殊的“包含文件索引表的文件”这一理论。

## OS 原理中很重要，但在实验中没有对应上的知识点

受限于 ucore 教学操作系统的复杂度与实验环境（基于 QEMU 模拟器），以下操作系统原理中的关键技术在本实验中未涉及或进行了大幅简化：

1. **复杂的磁盘调度算法**

   * **OS原理**：**PPT&#x20;**&#x8BE6;细介绍了 FCFS, SSTF, SCAN, C-SCAN 等磁盘调度算法，目的是通过优化磁头移动路径来减少寻道时间，提高吞吐量。

   * **缺失原因**：本实验中，磁盘操作由模拟器直接完成，ucore 作为一个教学内核，在 Lab 8 中主要关注文件系统的逻辑结构，并未实现通过请求队列对磁盘 I/O 请求进行重排和调度的逻辑。

2. **高级空闲空间管理**

   * **OS原理**：**PPT&#x20;**&#x8BA8;论了空闲块管理（Bitmap, Linked List, Grouping 等）。

   * **缺失原因**：虽然 SFS 使用了 Bitmap 来管理空闲块，但并未涉及成组链接法等更适合大型文件系统的高级管理策略，也未涉及碎片整理机制。

