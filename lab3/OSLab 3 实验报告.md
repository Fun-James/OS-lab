**姓名**： 张奥喆（2313447） 余俊辉（2313486） 杨李泽（2313851）

------

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

1. **初始化设置：**内核启动时，`idt_init()` 函数被调用来设置异常处理的入口点。它首先声明了汇编中定义的全局异常入口点 `__alltraps`，然后设置 `stvec` 寄存器：`write_csr(stvec, &__alltraps)`。无论在 S-mode 下发生任何类型的中断或异常，都应该立即跳转到 `__alltraps` 这个地址去执行。
2. **硬件响应与保存上下文：**一个异常或中断发生时，硬件会自动跳转，CPU 硬件自动保存 `pc` 到 `sepc`，设置 `scause` 等 CSRs，然后强制跳转到 `stvec` 指向的地址，即 `__alltraps`。`__alltraps` 的第一条指令就是执行 `SAVE_ALL` 宏，这个宏执行了上下文保存操作：
   1. `csrw sscratch, sp` 将当前的栈指针 `sp` 暂存到 `sscratch` 寄存器中。
   2. `addi sp, sp, -36 * REGBYTES` 在内核栈上为 `trapframe` 分配空间。
   3. `STORE x0`, `STORE x1`, `STORE x3`... 将 $$x0,x1,x3-x31$$ 这31 个通用寄存器保存到栈帧的相应位置。
   4. `csrrw s0, sscratch, x0` 将 `sscratch`的值读入 `s0`，并将 `sscratch` 清零。然后 `STORE s0, 2*REGBYTES(sp)` 将原始 `sp`保存到栈帧中 `x2` 对应的位置。
   5. `csrr` 指令读取 `sstatus`, `sepc`, `sbadaddr`, `scause` 到临时寄存器，然后 `STORE` 指令将其存入`trapfame`。
3. **C 代码分发处理：**`SAVE_ALL` 执行完毕后，`trapentry.S` 执行 `move a0, sp`，然后 `jal trap`。`trap()` 函数 被调用，接收 `a0` 传来的 `trapframe` 指针，并调用 `trap_dispatch(tf)`。`trap_dispatch()` 函数检查 `tf->cause` 的最高位来区分是中断还是异常。
4.  **恢复上下文与返回：**`trap()` 函数执行完毕后，返回到 `jal` 的下一条指令 `__trapret` 处。调用 `RESTORE_ALL` 宏，恢复`CSRs`、`GSRs`、`sp`的值。最后执行 `sret`指令。硬件会读取 `sepc` 和 `sstatus`的值，返回到被中断的代码，并恢复到中断前的特权级和中断使能状态。

## 2.2 `mov a0, sp` 的目的

目的是传递参数给`trap` 函数。

在 `SAVE_ALL` 宏执行完毕后，`sp`（栈指针）寄存器指向的是刚刚在内核栈上构建的 `struct trapframe` 的起始地址，而`a0` 寄存器用于传递函数的第一个参数。因此，`mov a0, sp` 的作用就是将 `trapframe` 的地址复制到 `a0` 中，作为第一个参数传递给 `trap` 函数。

## 2.3 `SAVE_ALL` 中寄存器保存在栈中的位置是什么确定的

是由 `struct trapframe` 结构体的定义 和 `SAVE_ALL` 宏的实现 共同确定的。

`kern/trap/trap.h`中有`struct trapframe` 的定义，它规定了所有寄存器的存储顺序和偏移量。

```C
struct trapframe {
    struct pushregs gpr;
    uintptr_t status;
    uintptr_t epc;
    uintptr_t badvaddr;
    uintptr_t cause;
};
```

`SAVE_ALL` 宏需要按照 `struct trapframe` 中定义的相同顺序和偏移量来保存寄存器。

## 2.4 对于任何中断，`__alltraps` 中都需要保存所有寄存器吗？

对于任何中断，`__alltraps` 中都需要保存所有寄存器。

理由：

1. **C 函数调用会覆盖原有的值：**`__alltraps` 的目的是调用一个 C 语言函数（`trap_dispatch`）来处理异常。C 编译器在编译 C 函数时，会认为它可以自由使用所有的调用者保存寄存器。如果 `__alltraps` 不保存这些寄存器，那么 `trap_dispatch`或它调用的任何子函数几乎肯定会覆盖掉被中断程序正在使用的值。
2. **不知道上下文：**`__alltraps` 是一个统一的入口点。它不知道它中断的是哪段代码，也不知道那段代码正在使用哪些寄存器。
3. **保证异常处理的透明性：** 中断/异常处理的核心原则是透明性，即被中断的程序不应该感知到自己被中断过。为了实现这一点，当中断处理返回时，所有寄存器的状态都必须恢复到中断发生前的瞬间。

# 三、扩展练习 Challenge2：理解上下文切换机制

## 3.1 `csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 的操作与目的

- **操作分析：**

`csrw sscratch, sp`将 `sp`寄存器的当前值，写入到 `sscratch` 这个 CSR 寄存器中。此时的 `sp` 是 `__alltraps` 刚进入时的栈指针，这个指针指向内核栈的栈顶。

`csrrw s0, sscratch, x0`读取 `sscratch` 的旧值并将其写入 寄存器，并将 `x0` 寄存器的值写入 `sscratch`。执行完毕后，`s0` 中保存了*原始的* *`sp`*，而 `sscratch` 被清零。

- **目的：**

`SAVE_ALL` 宏需要保存所有通用寄存器，包括 `sp`。但是，它又必须使用 `sp` 来分配栈帧。

`csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 巧妙地使用 `sscratch` 寄存器作为临时暂存器，来存储即将被 `addi` 指令修改的 `sp` 的原始值，并最终将其安全地存入 `trapframe` 中 `x2` 对应的位置。

## 3.2 为什么 `SAVE_ALL` 保存了 CSR ，而 `RESTORE_ALL` 不还原它们？

**因为这些 CSR 的用途不同。**

- `sstatus` 和 `sepc`必须恢复：

`sstatus`包含了中断前的特权级和中断使能状态。`sepc`则包含了中断发生时被卡住的指令地址，即返回地址。`RESTORE_ALL` 必须把它们加载回来，并写回 CSR。最后的 `sret` 指令会隐式使用这两个寄存器的值，来正确地返回到被中断的程序、恢复其特权级并重新使能中断。

而且，C 语言的 `trap` 函数可能会修改 `trapframe` 中的 `sepc`。因此，`RESTORE_ALL` 必须加载 C 代码修改后的新值。

- `scause` 和 `sbadaddr`只用来读取，无需恢复：

`scause` 由硬件写入，用于告诉 OS 发生了什么。`sbadaddr`/ `stval`由硬件写入，提供了异常的附加信息。`SAVE_ALL` 将它们保存到 `trapframe`，目的是为了把这些信息传递给 C 语言的 `trap` 函数。C 代码会读取 `tf->scause` 和 `tf->sbadaddr` 来判断异常类型并进行相应处理。

它们不需要被恢复它们只在异常发生的那一刻由硬件设置，用于向 OS 传递信息。当 `sret` 返回后，这些 CSR 的旧值是多少并不重要；当下一次异常发生时，硬件会用新值自动覆盖它们。

## 3.3 这样store的意义是什么？

C 语言的 `trap` 函数可能会修改 `trapframe` 中的 `sepc`。因此，`RESTORE_ALL` 必须加载 C 代码修改后的新值。而`scause` 和 `sbadaddr`这两个寄存器对于被中断的程序上下文来说没有意义。它们只在异常发生的那一刻由硬件设置，用于向 OS 传递信息。当 `sret` 返回后，这些 CSR 的旧值是多少并不重要；当*下一次*异常发生时，硬件会用新值自动覆盖它们。

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

# 五、实验重要知识点与OS原理的对应关系

## 知识点一：中断/异常处理机制

- **实验中的知识点：**
  - **含义：** 在`ucore`中实现一个具体的中断/异常处理流程。这包括：
    1. **设置中断向量表：** 在`init.c`中调用`idt_init()`（在x86中）或在RISC-V中设置`stvec`寄存器（如`trap.c`中的`trap_init`），指向`trapentry.S`中定义的统一入口点。
    2. **统一处理入口：** `trapentry.S`中的`__alltraps`作为所有中断和异常的入口，它不区分中断类型，立即开始保存上下文。
    3. **中断分发：** 在`trap.c`的`trap`函数中，根据`tf->cause`（RISC-V）或来识别中断/异常的具体原因（如时钟中断、断点异常）。
    4. **具体处理：** 调用相应的处理函数，例如`trap_dispatch`函数中对时钟中断（`IRQ_TIMER`）和断点异常（`T_BRKPT`）的`case`处理。
- **对应的OS原理：**
  - **含义：** **中断和异常** 是操作系统设计的基石。
    - **中断（Interrupt）：** 来自硬件的异步事件（如I/O完成、时钟滴答），打断当前CPU的执行。
    - **异常（Exception）：** CPU在执行指令时同步产生的事件（如除零错误、缺页、系统调用）。

## 知识点二：上下文保存与恢复

- **实验中的知识点：**
  - **含义：** 在`trapentry.S`中，通过汇编代码将所有CPU的通用寄存器（`x1-x31`）以及`sepc`（程序计数器）和`sstatus`（状态寄存器）等控制寄存器，按照`struct TrapFrame`（定义于`trap.h`）规定的顺序，压入到当前进程的内核栈中。中断处理完成后，再从栈中按相反顺序恢复这些值。
  - **目的：** 确保中断处理函数（C语言）可以安全执行，并且在中断返回后，被中断的程序（无论是用户态还是内核态）能从“毫不知情”的断点处无缝恢复执行。
- **对应的OS原理：**
  - **含义：** **进程上下文切换**。
  - 原理课中的“上下文切换”通常指**从进程A切换到进程B**。这包括：
    1. 保存进程A的完整状态（寄存器、PC、栈指针、页表基址等）到其PCB（进程控制块）中。
    2. 加载进程B的状态到CPU中。
    3. `switch_to`函数是实现这一过程的典型代表，它只在两个进程（或内核线程）之间切换。

## 知识点三：时钟中断

- **实验中的知识点：**
  - **含义：** 在`clock.c`中，通过调用SBI（`sbi_set_timer`），设置一个“下一次”中断的时间点。当时间到达，CPU触发一个`IRQ_TIMER`中断，在`trap_dispatch`中被捕获。
  - **处理：** 实验中的处理很简单，主要是调用`clock_set_next_event()`来“续上”下一次时钟中断，并打印一个信息，然后就返回了。
- **对应的OS原理：**
  - 时钟是实现**分时系统** 和 **抢占式调度**的物理基础
  - **作用：** 时钟中断定期地将CPU控制权“抢”回到OS手中，使OS有机会运行调度程序，从而防止单个进程“霸占”CPU，实现了CPU时间的公平分配。
- **关系与差异：**
  - **关系：** 实验实现了OS原理中抢占式调度的**硬件机制**。
  - **差异：** Lab 3只实现了时钟中断的**“机制”**（即能按时中断）。但它没有实现建立在该机制之上的**“策略”**（Policy）。

------

# 六、OS原理中重要但在实验中未体现的知识点

1. **进程调度策略**
   - **原理：**
     - 如前所述，时钟中断（Lab 3）提供了**抢占的时机**，但OS还需要**调度算法**（如FIFO、Round-Robin、Priority-based）来决定**下一个**应该运行哪个进程。
   - **实验中缺失：** Lab 3的中断处理完后，总是返回到**被中断的同一个进程**。实验中没有“进程队列”，没有`schedule()`函数，也没有`switch_to`（进程切换）的调用。
