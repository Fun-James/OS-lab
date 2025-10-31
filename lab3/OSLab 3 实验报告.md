# 一、练习1：完善中断处理

## 1.1 实验目的

编程实现 `trap.c` 中的时钟中断处理函数 `interrupt_handler`，使其能够：

* 正确设置下一次时钟中断，使其周期性触发。

* 每 100 次时钟中断（`TICK_NUM`）后，调用 `print_ticks()` 在屏幕上打印 "100 ticks"。

* 在 "100 ticks" 打印 10 次后，调用 `sbi_shutdown()` 函数关闭系统。

## 1.2 实验原理

本次实验的核心是让操作系统内核能够响应**时钟中断**。这套机制涉及硬件、汇编和 C 语言的紧密配合。

### RISC-V 中断处理机制

当一个中断或异常发生时，RISC-V 硬件会以原子方式执行以下操作：

1. **保存 `pc`**：将当前程序计数器 `pc`保存到 `sepc`寄存器中。

2. **记录原因**：将中断/异常的原因编码写入 `scause` 寄存器。

   * `scause` 的最高位为 1 表示“中断”，为 0 表示“异常”。

   * 对于 S 模式时钟中断，`scause` 的值为 `1...000...0101` 。

3. **更新状态**：将 `sstatus` 寄存器中的 `SIE`位保存到 `SPIE`，然后将 `SIE` 清零，即**自动关闭中断**，防止中断嵌套。

4. **跳转**：无条件跳转到 `stvec` (Supervisor Trap Vector) 寄存器所指向的地址，开始执行中断处理程序。

在我们的实验中，`idt_init()` 函数通过 `write_csr(stvec, &__alltraps)` 指令，将 `stvec` 设置为了汇编代码 `kern/trap/trapentry.S` 中的 `__alltraps` 标签地址。

### 汇编与 C 的协同流程

当中断发生，CPU 跳转到 `__alltraps` 后，软件流程开始：

1. **`trapentry.S`&#x20;**：

   * `SAVE_ALL` 宏：在内核栈上分配 `struct trapframe` 所需的空间，并将全部 32 个通用寄存器以及 `sstatus`, `sepc` 等 4 个 CSR 保存到该结构体中。

   * `move a0, sp`：将 `sp`存入 `a0` 寄存器，作为第一个参数传递给 C 函数。

   * `jal trap`：跳转并链接，调用 `trap.c` 中的 `trap()` 函数。

2. **`trap.c`&#x20;**：

   * `trap(struct trapframe *tf)` 被调用。

   * `trap_dispatch(tf)` 根据 `tf->cause` 的最高位（`< 0`）判断是中断还是异常。

   * `interrupt_handler(tf)` 被调用，它根据 `tf->cause` 的值 `switch` 到 `case IRQ_S_TIMER:`。

   * 执行时钟中断的特定逻辑。

   * C 函数逐层返回。

3. **`trapentry.S`**：

   * `__trapret`：`trap()` 函数返回后执行到这里。

   * `RESTORE_ALL` 宏：从 `trapframe` 中将所有寄存器（包括 `sepc` 和 `sstatus`）的值加载回 CPU。

   * `sret` 指令：这是一个特权指令，它原子地执行：

     * `pc = sepc`跳回到被打断的地方。

     * `sstatus.SIE = sstatus.SPIE`恢复中断前的使能状态，即重新开中断。

     * 恢复到 `sstatus.SPP` 所记录的特权级。

### 时钟中断原理

我们希望时钟“周期性”触发，但 OpenSBI 提供的 `sbi_set_timer(value)` 接口是一个“一次性”闹钟。它接受一个**绝对时刻** `value`，当硬件 `time` 寄存器的值达到 `value` 时，触发一次时钟中断。

我们的解决方案是：**在每次时钟中断处理程序中，设置下一次时钟中断。**

* `clock.c` 中的 `timebase`是根据 QEMU 的时钟频率（10MHz）计算得出的时间间隔，用于实现 100Hz的中断频率。

* `clock_set_next_event()` 函数通过 `sbi_set_timer(get_time() + timebase)` 来设置**下一次**闹钟。

* 因此，在 `interrupt_handler` 中**必须**调用 `clock_set_next_event()`，才能形成“闭环”，使时钟中断周而复始。

## 1.3 实验实现

本次实验需要修改 `kern/trap/trap.c` 文件，共三处：

1. **添加 `sbi.h` 头文件**

为了能够调用关机函数 `sbi_shutdown()`，在文件的开头部分（`#include` 区域）添加：

* **添加静态打印计数器**

为了跟踪 `print_ticks()` 的调用次数，在 `TICK_NUM` 宏定义的下方，添加一个静态全局变量 `print_count`：

* **完善 `interrupt_handler` 函数**

在 `interrupt_handler` 函数中，找到 `case IRQ_S_TIMER:` 分支，添加以下实现代码：

**代码说明**

* `clock_set_next_event();` 是第一条指令，确保无论后续逻辑如何，下一次中断都已被正确设置。

* 使用在 `clock.c` 中定义的全局变量 `ticks`进行计数。

* 使用在 `trap.c` 中定义的静态变量 `print_count`来跟踪打印的行数。静态变量只初始化一次，其值在函数调用（中断）之间保持不变。

* 当 `print_count` 达到 10 时，调用 `sbi_shutdown()`，QEMU 将退出。

## 1.4 实验结果

修改 `trap.c` 文件后，在 lab3 根目录下执行 `make qemu` 命令。系统编译通过并开始运行，QEMU 窗口输出如下：

**结果分析：**

1. 内核启动后，成功打印 `++ setup timer interrupts`，表明 `clock_init()` 已被调用。

2. 屏幕上大约每隔 1 秒打印一次 "100 ticks"。

3. 打印 10 次 "100 ticks" 后，QEMU 窗口自动关闭。

该输出结果与实验要求的 "每秒输出一次，输出 10 行后关机" 完全一致，表明实验成功。

***

# 二、扩展练习 Challenge1：描述与理解中断流程

## 2.1 ucore 中断异常处理流程

1. CPU 硬件响应：当异常发生时，RISC-V CPU 硬件会将当前的程序计数器 `pc` 保存到 `sepc` 寄存器中，在 `scause` 寄存器中记录异常的原因，在 `stval` 寄存器中记录额外信息，将 `pc` 设置为 `stvec` 寄存器指向的地址。

2. 软件保存上下文：`stvec` 指向的就是 ucore 的统一异常入口点，通常是 `__alltraps`。硬件只保存了 `pc`，但 C 语言函数需要使用通用寄存器。为了保证 C 函数（`trap_dispatch`）可以安全运行而不破坏被中断程序的上下文，我们必须在进入 C 代码之前保存所有的通用寄存器。 `SAVE_ALL` 首先在内核栈上分配一个 `struct trapframe` 的空间，然后将 32 个通用寄存器按照 `struct trapframe` 定义的顺序，逐一存储到这个栈帧中。

3. C 代码分发处理：现在`sp` 寄存器指向 `struct trapframe` 的起始地址，执行 `mov a0`，调用 C 语言的 `trap` 函数。trap 函数通过 `tf->scause`的值来判断异常的类型，分发到具体的处理函数。

4. &#x20;软件恢复上下文：调用 `RESTORE_ALL` 宏，从 `sp` 指向的 `trapframe` 中，将所有寄存器（`ra`, `sp`, `t0`...）的值通过 `ld` 指令加载回来。

5. 硬件返回：最后，执行 `sret` 指令，将 `sepc` 寄存器中的值恢复到 `pc`，恢复 `sstatus` 寄存器，恢复到中断前的特权级。

## 2.2 `mov a0, sp` 的目的

目的是传递参数给`trap` 函数。

在 `SAVE_ALL` 宏执行完毕后，`sp`（栈指针）寄存器指向的是刚刚在内核栈上构建的 `struct trapframe` 的起始地址，而`a0` 寄存器用于传递函数的第一个参数。因此，`mov a0, sp` 的作用就是将 `trapframe` 的地址复制到 `a0` 中，作为第一个参数传递给 `trap` 函数。

## 2.3 `SAVE_ALL` 中寄存器保存在栈中的位置是什么确定的

是由 `struct trapframe` 结构体的定义 和 `SAVE_ALL` 宏的实现 共同确定的。

`kern/trap/trap.h`中有`struct trapframe` 的定义，它规定了所有寄存器的存储顺序和偏移量。

`SAVE_ALL` 宏需要按照 `struct trapframe` 中定义的相同顺序和偏移量来保存寄存器。

## 2.4 对于任何中断，`__alltraps` 中都需要保存所有寄存器吗？

对于任何中断，`__alltraps` 中都需要保存所有寄存器。

理由：

1. **C 函数调用会覆盖原有的值：**`__alltraps` 的目的是调用一个 C 语言函数（`trap_dispatch`）来处理异常。C 编译器在编译 C 函数时，会认为它可以自由使用所有的调用者保存寄存器。如果 `__alltraps` 不保存这些寄存器，那么 `trap_dispatch`或它调用的任何子函数几乎肯定会覆盖掉被中断程序正在使用的值。

2. **不知道上下文：**`__alltraps` 是一个统一的入口点。它不知道它中断的是哪段代码，也不知道那段代码正在使用哪些寄存器。

3. **保证异常处理的透明性：** 中断/异常处理的核心原则是透明性，即被中断的程序不应该感知到自己被中断过。为了实现这一点，当中断处理返回时，所有寄存器的状态都必须恢复到中断发生前的瞬间。

***

# 三、扩展练习 Challenge2：理解上下文切换机制

## 3.1 `csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 的操作与目的

* **操作分析：**

`csrw sscratch, sp`将 `sp`寄存器的当前值，写入到 `sscratch` 这个 CSR 寄存器中。此时的 `sp` 是 `__alltraps` 刚进入时的栈指针，这个指针指向内核栈的栈顶。

`csrrw s0, sscratch, x0`读取 `sscratch` 的旧值并将其写入 `s0`寄存器，并将 `x0` 寄存器的值写入 `sscratch`。执行完毕后，`s0` 中保存了*原始的 `sp`*，而 `sscratch` 被清零。

* **目的：**

`SAVE_ALL` 宏需要保存所有通用寄存器，包括 `sp`。但是，它又必须使用 `sp` 来分配栈帧。

`csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 巧妙地使用 `sscratch` 寄存器作为临时暂存器，来存储即将被 `addi` 指令修改的 `sp` 的原始值，并最终将其安全地存入 `trapframe` 中 `x2` 对应的位置。

## 3.2 为什么 `SAVE_ALL` 保存了 CSR ，而 `RESTORE_ALL` 不还原它们？

**因为这些 CSR 的用途不同。**

* `sstatus` 和 `sepc`必须恢复：

`sstatus`包含了中断前的特权级和中断使能状态。`sepc`则包含了中断发生时被卡住的指令地址，即返回地址。`RESTORE_ALL` 必须把它们加载回来，并写回 CSR。最后的 `sret` 指令会隐式使用这两个寄存器的值，来正确地返回到被中断的程序、恢复其特权级并重新使能中断。

而且，C 语言的 `trap` 函数可能会修改 `trapframe` 中的 `sepc`。因此，`RESTORE_ALL` 必须加载 C 代码修改后的新值。

* `scause` 和 `sbadaddr`只用来读取，无需恢复：

`scause` 由硬件写入，用于告诉 OS 发生了什么。`sbadaddr`/ `stval`由硬件写入，提供了异常的附加信息。`SAVE_ALL` 将它们保存到 `trapframe`，目的是为了把这些信息传递给 C 语言的 `trap` 函数。C 代码会读取 `tf->scause` 和 `tf->sbadaddr` 来判断异常类型并进行相应处理。

它们不需要被恢复它们只在异常发生的那一刻由硬件设置，用于向 OS 传递信息。当 `sret` 返回后，这些 CSR 的旧值是多少并不重要；当下一次异常发生时，硬件会用新值自动覆盖它们。

***

# 四、扩展练习Challenge3：完善异常中断

## 4.1 目标

本次挑战的目标是扩展 RISC-V 内核的异常处理能力，使其能够正确捕获和处理两种特定的异常类型：

1. **非法指令 (Illegal Instruction)**：当 CPU 尝试执行一条未定义或非法的指令时触发。

2. **断点 (Breakpoint)**：由 `ebreak` 指令触发，通常用于调试。

在 `kern/trap/trap.c` 中的异常处理函数中捕获这两种异常，并按照指定格式输出异常类型和异常发生的地址（`sepc`）。

## 4.2 实现简述

实验的核心是修改 `kern/trap/trap.c` 文件中的 `exception_handler` 函数。

1. **识别异常类型**：通过检查传递的 `trapframe` 结构体中的 `scause`（异常原因）寄存器的值，来判断异常的具体类型。

   * 根据 RISC-V 规范，`scause` 值为 `CAUSE_ILLEGAL_INSTRUCTION` 时，代表非法指令异常。

   * `scause` 值为 `CAUSE_BREAKPOINT` 时，代表断点异常。

2. **处理断点异常 (`CAUSE_BREAKPOINT`)**：

   * 在 `exception_handler` `switch(trapframe->cause)` 语句中添加 `case CAUSE_BREAKPOINT:`。

   * 在此 `case` 中，首先打印信息：`Exception type: breakpoint`。

   * 然后使用 `cprintf` 打印信息：`ebreak caught at 0x%08x\n`，其中地址从 `trapframe->sepc` 中获取。

   * **关键处理**：为了使内核在处理完 `ebreak` 后能够继续执行，必须手动将 `sepc` 更新为下一条指令的地址。标准指令是 4 字节的，但是我发现这个系统中的`ebreak` 是一条 **2 字节指令**，这是一种压缩指令。因此 epc 需要自增 2 字节。

   * **参考代码**：

3. **处理非法指令异常 (`CAUSE_ILLEGAL_INSTRUCTION`)**：

   * 添加 `case CAUSE_ILLEGAL_INSTRUCTION:`。

   * 打印信息：`Exception type: Illegal instruction`。

   * 打印信息：`Illegal instruction caught at 0x%08x\n`，地址同样从 `trapframe->sepc` 获取。

   * **关键处理**：测试代码中使用的非法指令是 2 字节（压缩指令）或 4 字节。为了跳过这些指令，需要将 `sepc` 增加，这步和处理断点异常一致。

   * **参考代码**：

## 4.3 验证 & 实验结果

在系统内核初始化完成后，我加入了测试指令，使用了 C 语言的内联汇编功能，以`asm volatile`的形式**人为触发**了两种特定的异常：

1. `asm volatile("ebreak");`

   * **作用**：在代码中插入一条 `ebreak`（断点）汇编指令。

   * **目的**：`ebreak` 是一条**合法**的 RISC-V 指令，专门用于触发**断点异常**。

2. `asm volatile(".word 0x00000000");`

   * **作用**：这不是一条指令，而是一个汇编器**伪指令**。它强制汇编器在当前代码位置插入一个特定值。

   * **目的**：这个值在 RISC-V 规范中并**不是一条合法的指令编码**。当 CPU 试图将这个数据当作指令来解码执行时，会失败并触发**非法指令异常。**

执行 `make qemu` 编译并运行内核，得到的输结果如下。测试代码（位于 `kern/init/init.c`）被正确执行，并触发了我们预期的异常。

1. **断点异常测试 (Test 1)**：

   * 内核成功捕获了 `ebreak` 指令。

   * 打印了 "Exception type: breakpoint"。

   * 打印了 "ebreak caught at 0xc02000b4"，地址 `0xc02000b4` 与测试代码中 `ebreak` 的位置一致。

   * 成功打印 "After ebreak exception handled."，内核恢复执行并继续运行。

2. **非法指令测试 (Test 2)**：

   * 内核成功捕获了第一条非法指令。

   * 打印了 "Exception type: Illegal instruction"。

   * 打印了 "Illegal instruction caught at 0xc02000ce"。

   * 内核恢复执行后（`sepc` + 2），遇到了第二条非法指令。

   * 再次打印 "Exception type: Illegal instruction" 和 "Illegal instruction caught at 0xc02000d0"。

   * 成功打印 "After illegal instruction exception handled."，表明两条非法指令均被成功捕获并跳过，内核最终恢复了正常执行。

**结论**：实验成功。`trap.c` 中的异常处理程序被正确修改，能够分类处理 `Breakpoint` 和 `Illegal Instruction` 异常，按要求打印信息，并通过修改 `sepc` 保证了内核在异常处理后可以继续运行。

