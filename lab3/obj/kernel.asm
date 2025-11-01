
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0206337          	lui	t1,0xc0206
    addi t1, t1, %lo(bootstacktop)
ffffffffc0200044:	00030313          	mv	t1,t1
    # 2. 将精确地址一次性地、安全地传给 sp
    mv sp, t1
ffffffffc0200048:	811a                	mv	sp,t1
    # 现在栈指针已经完美设置，可以安全地调用任何C函数了
    # 然后跳转到 kern_init (不再返回)
    lui t0, %hi(kern_init)
ffffffffc020004a:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020004e:	05428293          	addi	t0,t0,84 # ffffffffc0200054 <kern_init>
    jr t0
ffffffffc0200052:	8282                	jr	t0

ffffffffc0200054 <kern_init>:
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    // 先清零 BSS，再读取并保存 DTB 的内存信息，避免被清零覆盖（为了解释变化 正式上传时我觉得应该删去这句话）
    memset(edata, 0, end - edata);
ffffffffc0200054:	00007517          	auipc	a0,0x7
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0207028 <free_area>
ffffffffc020005c:	00007617          	auipc	a2,0x7
ffffffffc0200060:	44460613          	addi	a2,a2,1092 # ffffffffc02074a0 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	6eb010ef          	jal	ra,ffffffffc0201f56 <memset>
    dtb_init();
ffffffffc0200070:	45c000ef          	jal	ra,ffffffffc02004cc <dtb_init>
    cons_init();  // init the console
ffffffffc0200074:	44a000ef          	jal	ra,ffffffffc02004be <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	fe850513          	addi	a0,a0,-24 # ffffffffc0202060 <etext+0xf8>
ffffffffc0200080:	0de000ef          	jal	ra,ffffffffc020015e <cputs>

    print_kerninfo();
ffffffffc0200084:	12a000ef          	jal	ra,ffffffffc02001ae <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200088:	001000ef          	jal	ra,ffffffffc0200888 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020008c:	74e010ef          	jal	ra,ffffffffc02017da <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc0200090:	7f8000ef          	jal	ra,ffffffffc0200888 <idt_init>

    
    intr_enable();  // enable irq interrupt
ffffffffc0200094:	7e8000ef          	jal	ra,ffffffffc020087c <intr_enable>

    // LAB3 CHALLENGE3: 测试异常处理
    cprintf("Testing exception handling...\n");
ffffffffc0200098:	00002517          	auipc	a0,0x2
ffffffffc020009c:	ed050513          	addi	a0,a0,-304 # ffffffffc0201f68 <etext>
ffffffffc02000a0:	086000ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    // 测试断点异常
    cprintf("\n=== Test 1: Breakpoint Exception ===\n");
ffffffffc02000a4:	00002517          	auipc	a0,0x2
ffffffffc02000a8:	ee450513          	addi	a0,a0,-284 # ffffffffc0201f88 <etext+0x20>
ffffffffc02000ac:	07a000ef          	jal	ra,ffffffffc0200126 <cprintf>
    asm volatile("ebreak");
ffffffffc02000b0:	9002                	ebreak
    cprintf("After ebreak exception handled.\n");
ffffffffc02000b2:	00002517          	auipc	a0,0x2
ffffffffc02000b6:	efe50513          	addi	a0,a0,-258 # ffffffffc0201fb0 <etext+0x48>
ffffffffc02000ba:	06c000ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    // 测试非法指令异常
    cprintf("\n=== Test 2: Illegal Instruction Exception ===\n");
ffffffffc02000be:	00002517          	auipc	a0,0x2
ffffffffc02000c2:	f1a50513          	addi	a0,a0,-230 # ffffffffc0201fd8 <etext+0x70>
ffffffffc02000c6:	060000ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc02000ca:	0000                	unimp
ffffffffc02000cc:	0000                	unimp
    asm volatile(".word 0x00000000");  // 全0是非法指令
    cprintf("After illegal instruction exception handled.\n");
ffffffffc02000ce:	00002517          	auipc	a0,0x2
ffffffffc02000d2:	f3a50513          	addi	a0,a0,-198 # ffffffffc0202008 <etext+0xa0>
ffffffffc02000d6:	050000ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    cprintf("\nException handling test completed!\n\n");
ffffffffc02000da:	00002517          	auipc	a0,0x2
ffffffffc02000de:	f5e50513          	addi	a0,a0,-162 # ffffffffc0202038 <etext+0xd0>
ffffffffc02000e2:	044000ef          	jal	ra,ffffffffc0200126 <cprintf>
    clock_init();   // init clock interrupt
ffffffffc02000e6:	396000ef          	jal	ra,ffffffffc020047c <clock_init>
    
    /* do nothing */
    while (1)
ffffffffc02000ea:	a001                	j	ffffffffc02000ea <kern_init+0x96>

ffffffffc02000ec <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc02000ec:	1141                	addi	sp,sp,-16
ffffffffc02000ee:	e022                	sd	s0,0(sp)
ffffffffc02000f0:	e406                	sd	ra,8(sp)
ffffffffc02000f2:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000f4:	3cc000ef          	jal	ra,ffffffffc02004c0 <cons_putc>
    (*cnt) ++;
ffffffffc02000f8:	401c                	lw	a5,0(s0)
}
ffffffffc02000fa:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000fc:	2785                	addiw	a5,a5,1
ffffffffc02000fe:	c01c                	sw	a5,0(s0)
}
ffffffffc0200100:	6402                	ld	s0,0(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200106:	1101                	addi	sp,sp,-32
ffffffffc0200108:	862a                	mv	a2,a0
ffffffffc020010a:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020010c:	00000517          	auipc	a0,0x0
ffffffffc0200110:	fe050513          	addi	a0,a0,-32 # ffffffffc02000ec <cputch>
ffffffffc0200114:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200116:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200118:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020011a:	10d010ef          	jal	ra,ffffffffc0201a26 <vprintfmt>
    return cnt;
}
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	4532                	lw	a0,12(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret

ffffffffc0200126 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200126:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200128:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc020012c:	8e2a                	mv	t3,a0
ffffffffc020012e:	f42e                	sd	a1,40(sp)
ffffffffc0200130:	f832                	sd	a2,48(sp)
ffffffffc0200132:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200134:	00000517          	auipc	a0,0x0
ffffffffc0200138:	fb850513          	addi	a0,a0,-72 # ffffffffc02000ec <cputch>
ffffffffc020013c:	004c                	addi	a1,sp,4
ffffffffc020013e:	869a                	mv	a3,t1
ffffffffc0200140:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200142:	ec06                	sd	ra,24(sp)
ffffffffc0200144:	e0ba                	sd	a4,64(sp)
ffffffffc0200146:	e4be                	sd	a5,72(sp)
ffffffffc0200148:	e8c2                	sd	a6,80(sp)
ffffffffc020014a:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc020014c:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc020014e:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200150:	0d7010ef          	jal	ra,ffffffffc0201a26 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200154:	60e2                	ld	ra,24(sp)
ffffffffc0200156:	4512                	lw	a0,4(sp)
ffffffffc0200158:	6125                	addi	sp,sp,96
ffffffffc020015a:	8082                	ret

ffffffffc020015c <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc020015c:	a695                	j	ffffffffc02004c0 <cons_putc>

ffffffffc020015e <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020015e:	1101                	addi	sp,sp,-32
ffffffffc0200160:	e822                	sd	s0,16(sp)
ffffffffc0200162:	ec06                	sd	ra,24(sp)
ffffffffc0200164:	e426                	sd	s1,8(sp)
ffffffffc0200166:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200168:	00054503          	lbu	a0,0(a0)
ffffffffc020016c:	c51d                	beqz	a0,ffffffffc020019a <cputs+0x3c>
ffffffffc020016e:	0405                	addi	s0,s0,1
ffffffffc0200170:	4485                	li	s1,1
ffffffffc0200172:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200174:	34c000ef          	jal	ra,ffffffffc02004c0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200178:	00044503          	lbu	a0,0(s0)
ffffffffc020017c:	008487bb          	addw	a5,s1,s0
ffffffffc0200180:	0405                	addi	s0,s0,1
ffffffffc0200182:	f96d                	bnez	a0,ffffffffc0200174 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200184:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200188:	4529                	li	a0,10
ffffffffc020018a:	336000ef          	jal	ra,ffffffffc02004c0 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020018e:	60e2                	ld	ra,24(sp)
ffffffffc0200190:	8522                	mv	a0,s0
ffffffffc0200192:	6442                	ld	s0,16(sp)
ffffffffc0200194:	64a2                	ld	s1,8(sp)
ffffffffc0200196:	6105                	addi	sp,sp,32
ffffffffc0200198:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020019a:	4405                	li	s0,1
ffffffffc020019c:	b7f5                	j	ffffffffc0200188 <cputs+0x2a>

ffffffffc020019e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001a2:	326000ef          	jal	ra,ffffffffc02004c8 <cons_getc>
ffffffffc02001a6:	dd75                	beqz	a0,ffffffffc02001a2 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001a8:	60a2                	ld	ra,8(sp)
ffffffffc02001aa:	0141                	addi	sp,sp,16
ffffffffc02001ac:	8082                	ret

ffffffffc02001ae <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001ae:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001b0:	00002517          	auipc	a0,0x2
ffffffffc02001b4:	ed050513          	addi	a0,a0,-304 # ffffffffc0202080 <etext+0x118>
void print_kerninfo(void) {
ffffffffc02001b8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001ba:	f6dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001be:	00000597          	auipc	a1,0x0
ffffffffc02001c2:	e9658593          	addi	a1,a1,-362 # ffffffffc0200054 <kern_init>
ffffffffc02001c6:	00002517          	auipc	a0,0x2
ffffffffc02001ca:	eda50513          	addi	a0,a0,-294 # ffffffffc02020a0 <etext+0x138>
ffffffffc02001ce:	f59ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001d2:	00002597          	auipc	a1,0x2
ffffffffc02001d6:	d9658593          	addi	a1,a1,-618 # ffffffffc0201f68 <etext>
ffffffffc02001da:	00002517          	auipc	a0,0x2
ffffffffc02001de:	ee650513          	addi	a0,a0,-282 # ffffffffc02020c0 <etext+0x158>
ffffffffc02001e2:	f45ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001e6:	00007597          	auipc	a1,0x7
ffffffffc02001ea:	e4258593          	addi	a1,a1,-446 # ffffffffc0207028 <free_area>
ffffffffc02001ee:	00002517          	auipc	a0,0x2
ffffffffc02001f2:	ef250513          	addi	a0,a0,-270 # ffffffffc02020e0 <etext+0x178>
ffffffffc02001f6:	f31ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001fa:	00007597          	auipc	a1,0x7
ffffffffc02001fe:	2a658593          	addi	a1,a1,678 # ffffffffc02074a0 <end>
ffffffffc0200202:	00002517          	auipc	a0,0x2
ffffffffc0200206:	efe50513          	addi	a0,a0,-258 # ffffffffc0202100 <etext+0x198>
ffffffffc020020a:	f1dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020020e:	00007597          	auipc	a1,0x7
ffffffffc0200212:	69158593          	addi	a1,a1,1681 # ffffffffc020789f <end+0x3ff>
ffffffffc0200216:	00000797          	auipc	a5,0x0
ffffffffc020021a:	e3e78793          	addi	a5,a5,-450 # ffffffffc0200054 <kern_init>
ffffffffc020021e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200226:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200228:	3ff5f593          	andi	a1,a1,1023
ffffffffc020022c:	95be                	add	a1,a1,a5
ffffffffc020022e:	85a9                	srai	a1,a1,0xa
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	ef050513          	addi	a0,a0,-272 # ffffffffc0202120 <etext+0x1b8>
}
ffffffffc0200238:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023a:	b5f5                	j	ffffffffc0200126 <cprintf>

ffffffffc020023c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020023c:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020023e:	00002617          	auipc	a2,0x2
ffffffffc0200242:	f1260613          	addi	a2,a2,-238 # ffffffffc0202150 <etext+0x1e8>
ffffffffc0200246:	04d00593          	li	a1,77
ffffffffc020024a:	00002517          	auipc	a0,0x2
ffffffffc020024e:	f1e50513          	addi	a0,a0,-226 # ffffffffc0202168 <etext+0x200>
void print_stackframe(void) {
ffffffffc0200252:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200254:	1cc000ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc0200258 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200258:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025a:	00002617          	auipc	a2,0x2
ffffffffc020025e:	f2660613          	addi	a2,a2,-218 # ffffffffc0202180 <etext+0x218>
ffffffffc0200262:	00002597          	auipc	a1,0x2
ffffffffc0200266:	f3e58593          	addi	a1,a1,-194 # ffffffffc02021a0 <etext+0x238>
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	f3e50513          	addi	a0,a0,-194 # ffffffffc02021a8 <etext+0x240>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200274:	eb3ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc0200278:	00002617          	auipc	a2,0x2
ffffffffc020027c:	f4060613          	addi	a2,a2,-192 # ffffffffc02021b8 <etext+0x250>
ffffffffc0200280:	00002597          	auipc	a1,0x2
ffffffffc0200284:	f6058593          	addi	a1,a1,-160 # ffffffffc02021e0 <etext+0x278>
ffffffffc0200288:	00002517          	auipc	a0,0x2
ffffffffc020028c:	f2050513          	addi	a0,a0,-224 # ffffffffc02021a8 <etext+0x240>
ffffffffc0200290:	e97ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc0200294:	00002617          	auipc	a2,0x2
ffffffffc0200298:	f5c60613          	addi	a2,a2,-164 # ffffffffc02021f0 <etext+0x288>
ffffffffc020029c:	00002597          	auipc	a1,0x2
ffffffffc02002a0:	f7458593          	addi	a1,a1,-140 # ffffffffc0202210 <etext+0x2a8>
ffffffffc02002a4:	00002517          	auipc	a0,0x2
ffffffffc02002a8:	f0450513          	addi	a0,a0,-252 # ffffffffc02021a8 <etext+0x240>
ffffffffc02002ac:	e7bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    }
    return 0;
}
ffffffffc02002b0:	60a2                	ld	ra,8(sp)
ffffffffc02002b2:	4501                	li	a0,0
ffffffffc02002b4:	0141                	addi	sp,sp,16
ffffffffc02002b6:	8082                	ret

ffffffffc02002b8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b8:	1141                	addi	sp,sp,-16
ffffffffc02002ba:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002bc:	ef3ff0ef          	jal	ra,ffffffffc02001ae <print_kerninfo>
    return 0;
}
ffffffffc02002c0:	60a2                	ld	ra,8(sp)
ffffffffc02002c2:	4501                	li	a0,0
ffffffffc02002c4:	0141                	addi	sp,sp,16
ffffffffc02002c6:	8082                	ret

ffffffffc02002c8 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c8:	1141                	addi	sp,sp,-16
ffffffffc02002ca:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002cc:	f71ff0ef          	jal	ra,ffffffffc020023c <print_stackframe>
    return 0;
}
ffffffffc02002d0:	60a2                	ld	ra,8(sp)
ffffffffc02002d2:	4501                	li	a0,0
ffffffffc02002d4:	0141                	addi	sp,sp,16
ffffffffc02002d6:	8082                	ret

ffffffffc02002d8 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	7115                	addi	sp,sp,-224
ffffffffc02002da:	ed5e                	sd	s7,152(sp)
ffffffffc02002dc:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002de:	00002517          	auipc	a0,0x2
ffffffffc02002e2:	f4250513          	addi	a0,a0,-190 # ffffffffc0202220 <etext+0x2b8>
kmonitor(struct trapframe *tf) {
ffffffffc02002e6:	ed86                	sd	ra,216(sp)
ffffffffc02002e8:	e9a2                	sd	s0,208(sp)
ffffffffc02002ea:	e5a6                	sd	s1,200(sp)
ffffffffc02002ec:	e1ca                	sd	s2,192(sp)
ffffffffc02002ee:	fd4e                	sd	s3,184(sp)
ffffffffc02002f0:	f952                	sd	s4,176(sp)
ffffffffc02002f2:	f556                	sd	s5,168(sp)
ffffffffc02002f4:	f15a                	sd	s6,160(sp)
ffffffffc02002f6:	e962                	sd	s8,144(sp)
ffffffffc02002f8:	e566                	sd	s9,136(sp)
ffffffffc02002fa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002fc:	e2bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200300:	00002517          	auipc	a0,0x2
ffffffffc0200304:	f4850513          	addi	a0,a0,-184 # ffffffffc0202248 <etext+0x2e0>
ffffffffc0200308:	e1fff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    if (tf != NULL) {
ffffffffc020030c:	000b8563          	beqz	s7,ffffffffc0200316 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200310:	855e                	mv	a0,s7
ffffffffc0200312:	756000ef          	jal	ra,ffffffffc0200a68 <print_trapframe>
ffffffffc0200316:	00002c17          	auipc	s8,0x2
ffffffffc020031a:	fa2c0c13          	addi	s8,s8,-94 # ffffffffc02022b8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020031e:	00002917          	auipc	s2,0x2
ffffffffc0200322:	f5290913          	addi	s2,s2,-174 # ffffffffc0202270 <etext+0x308>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200326:	00002497          	auipc	s1,0x2
ffffffffc020032a:	f5248493          	addi	s1,s1,-174 # ffffffffc0202278 <etext+0x310>
        if (argc == MAXARGS - 1) {
ffffffffc020032e:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200330:	00002b17          	auipc	s6,0x2
ffffffffc0200334:	f50b0b13          	addi	s6,s6,-176 # ffffffffc0202280 <etext+0x318>
        argv[argc ++] = buf;
ffffffffc0200338:	00002a17          	auipc	s4,0x2
ffffffffc020033c:	e68a0a13          	addi	s4,s4,-408 # ffffffffc02021a0 <etext+0x238>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200340:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200342:	854a                	mv	a0,s2
ffffffffc0200344:	265010ef          	jal	ra,ffffffffc0201da8 <readline>
ffffffffc0200348:	842a                	mv	s0,a0
ffffffffc020034a:	dd65                	beqz	a0,ffffffffc0200342 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200350:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	e1bd                	bnez	a1,ffffffffc02003b8 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200354:	fe0c87e3          	beqz	s9,ffffffffc0200342 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200358:	6582                	ld	a1,0(sp)
ffffffffc020035a:	00002d17          	auipc	s10,0x2
ffffffffc020035e:	f5ed0d13          	addi	s10,s10,-162 # ffffffffc02022b8 <commands>
        argv[argc ++] = buf;
ffffffffc0200362:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200364:	4401                	li	s0,0
ffffffffc0200366:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200368:	395010ef          	jal	ra,ffffffffc0201efc <strcmp>
ffffffffc020036c:	c919                	beqz	a0,ffffffffc0200382 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020036e:	2405                	addiw	s0,s0,1
ffffffffc0200370:	0b540063          	beq	s0,s5,ffffffffc0200410 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200374:	000d3503          	ld	a0,0(s10)
ffffffffc0200378:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020037a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	381010ef          	jal	ra,ffffffffc0201efc <strcmp>
ffffffffc0200380:	f57d                	bnez	a0,ffffffffc020036e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200382:	00141793          	slli	a5,s0,0x1
ffffffffc0200386:	97a2                	add	a5,a5,s0
ffffffffc0200388:	078e                	slli	a5,a5,0x3
ffffffffc020038a:	97e2                	add	a5,a5,s8
ffffffffc020038c:	6b9c                	ld	a5,16(a5)
ffffffffc020038e:	865e                	mv	a2,s7
ffffffffc0200390:	002c                	addi	a1,sp,8
ffffffffc0200392:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200396:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200398:	fa0555e3          	bgez	a0,ffffffffc0200342 <kmonitor+0x6a>
}
ffffffffc020039c:	60ee                	ld	ra,216(sp)
ffffffffc020039e:	644e                	ld	s0,208(sp)
ffffffffc02003a0:	64ae                	ld	s1,200(sp)
ffffffffc02003a2:	690e                	ld	s2,192(sp)
ffffffffc02003a4:	79ea                	ld	s3,184(sp)
ffffffffc02003a6:	7a4a                	ld	s4,176(sp)
ffffffffc02003a8:	7aaa                	ld	s5,168(sp)
ffffffffc02003aa:	7b0a                	ld	s6,160(sp)
ffffffffc02003ac:	6bea                	ld	s7,152(sp)
ffffffffc02003ae:	6c4a                	ld	s8,144(sp)
ffffffffc02003b0:	6caa                	ld	s9,136(sp)
ffffffffc02003b2:	6d0a                	ld	s10,128(sp)
ffffffffc02003b4:	612d                	addi	sp,sp,224
ffffffffc02003b6:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	8526                	mv	a0,s1
ffffffffc02003ba:	387010ef          	jal	ra,ffffffffc0201f40 <strchr>
ffffffffc02003be:	c901                	beqz	a0,ffffffffc02003ce <kmonitor+0xf6>
ffffffffc02003c0:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003c4:	00040023          	sb	zero,0(s0)
ffffffffc02003c8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ca:	d5c9                	beqz	a1,ffffffffc0200354 <kmonitor+0x7c>
ffffffffc02003cc:	b7f5                	j	ffffffffc02003b8 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003ce:	00044783          	lbu	a5,0(s0)
ffffffffc02003d2:	d3c9                	beqz	a5,ffffffffc0200354 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003d4:	033c8963          	beq	s9,s3,ffffffffc0200406 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003d8:	003c9793          	slli	a5,s9,0x3
ffffffffc02003dc:	0118                	addi	a4,sp,128
ffffffffc02003de:	97ba                	add	a5,a5,a4
ffffffffc02003e0:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003e4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003e8:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003ea:	e591                	bnez	a1,ffffffffc02003f6 <kmonitor+0x11e>
ffffffffc02003ec:	b7b5                	j	ffffffffc0200358 <kmonitor+0x80>
ffffffffc02003ee:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003f2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003f4:	d1a5                	beqz	a1,ffffffffc0200354 <kmonitor+0x7c>
ffffffffc02003f6:	8526                	mv	a0,s1
ffffffffc02003f8:	349010ef          	jal	ra,ffffffffc0201f40 <strchr>
ffffffffc02003fc:	d96d                	beqz	a0,ffffffffc02003ee <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003fe:	00044583          	lbu	a1,0(s0)
ffffffffc0200402:	d9a9                	beqz	a1,ffffffffc0200354 <kmonitor+0x7c>
ffffffffc0200404:	bf55                	j	ffffffffc02003b8 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200406:	45c1                	li	a1,16
ffffffffc0200408:	855a                	mv	a0,s6
ffffffffc020040a:	d1dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
ffffffffc020040e:	b7e9                	j	ffffffffc02003d8 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200410:	6582                	ld	a1,0(sp)
ffffffffc0200412:	00002517          	auipc	a0,0x2
ffffffffc0200416:	e8e50513          	addi	a0,a0,-370 # ffffffffc02022a0 <etext+0x338>
ffffffffc020041a:	d0dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    return 0;
ffffffffc020041e:	b715                	j	ffffffffc0200342 <kmonitor+0x6a>

ffffffffc0200420 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200420:	00007317          	auipc	t1,0x7
ffffffffc0200424:	02030313          	addi	t1,t1,32 # ffffffffc0207440 <is_panic>
ffffffffc0200428:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020042c:	715d                	addi	sp,sp,-80
ffffffffc020042e:	ec06                	sd	ra,24(sp)
ffffffffc0200430:	e822                	sd	s0,16(sp)
ffffffffc0200432:	f436                	sd	a3,40(sp)
ffffffffc0200434:	f83a                	sd	a4,48(sp)
ffffffffc0200436:	fc3e                	sd	a5,56(sp)
ffffffffc0200438:	e0c2                	sd	a6,64(sp)
ffffffffc020043a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020043c:	020e1a63          	bnez	t3,ffffffffc0200470 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200440:	4785                	li	a5,1
ffffffffc0200442:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200446:	8432                	mv	s0,a2
ffffffffc0200448:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020044a:	862e                	mv	a2,a1
ffffffffc020044c:	85aa                	mv	a1,a0
ffffffffc020044e:	00002517          	auipc	a0,0x2
ffffffffc0200452:	eb250513          	addi	a0,a0,-334 # ffffffffc0202300 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200456:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200458:	ccfff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020045c:	65a2                	ld	a1,8(sp)
ffffffffc020045e:	8522                	mv	a0,s0
ffffffffc0200460:	ca7ff0ef          	jal	ra,ffffffffc0200106 <vcprintf>
    cprintf("\n");
ffffffffc0200464:	00002517          	auipc	a0,0x2
ffffffffc0200468:	ce450513          	addi	a0,a0,-796 # ffffffffc0202148 <etext+0x1e0>
ffffffffc020046c:	cbbff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200470:	412000ef          	jal	ra,ffffffffc0200882 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200474:	4501                	li	a0,0
ffffffffc0200476:	e63ff0ef          	jal	ra,ffffffffc02002d8 <kmonitor>
    while (1) {
ffffffffc020047a:	bfed                	j	ffffffffc0200474 <__panic+0x54>

ffffffffc020047c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020047c:	1141                	addi	sp,sp,-16
ffffffffc020047e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200480:	02000793          	li	a5,32
ffffffffc0200484:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200488:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020048c:	67e1                	lui	a5,0x18
ffffffffc020048e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200492:	953e                	add	a0,a0,a5
ffffffffc0200494:	1e3010ef          	jal	ra,ffffffffc0201e76 <sbi_set_timer>
}
ffffffffc0200498:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020049a:	00007797          	auipc	a5,0x7
ffffffffc020049e:	fa07b723          	sd	zero,-82(a5) # ffffffffc0207448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	e7e50513          	addi	a0,a0,-386 # ffffffffc0202320 <commands+0x68>
}
ffffffffc02004aa:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc02004ac:	b9ad                	j	ffffffffc0200126 <cprintf>

ffffffffc02004ae <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ae:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004b2:	67e1                	lui	a5,0x18
ffffffffc02004b4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004b8:	953e                	add	a0,a0,a5
ffffffffc02004ba:	1bd0106f          	j	ffffffffc0201e76 <sbi_set_timer>

ffffffffc02004be <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004be:	8082                	ret

ffffffffc02004c0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc02004c0:	0ff57513          	zext.b	a0,a0
ffffffffc02004c4:	1990106f          	j	ffffffffc0201e5c <sbi_console_putchar>

ffffffffc02004c8 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc02004c8:	1c90106f          	j	ffffffffc0201e90 <sbi_console_getchar>

ffffffffc02004cc <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02004cc:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc02004ce:	00002517          	auipc	a0,0x2
ffffffffc02004d2:	e7250513          	addi	a0,a0,-398 # ffffffffc0202340 <commands+0x88>
void dtb_init(void) {
ffffffffc02004d6:	fc86                	sd	ra,120(sp)
ffffffffc02004d8:	f8a2                	sd	s0,112(sp)
ffffffffc02004da:	e8d2                	sd	s4,80(sp)
ffffffffc02004dc:	f4a6                	sd	s1,104(sp)
ffffffffc02004de:	f0ca                	sd	s2,96(sp)
ffffffffc02004e0:	ecce                	sd	s3,88(sp)
ffffffffc02004e2:	e4d6                	sd	s5,72(sp)
ffffffffc02004e4:	e0da                	sd	s6,64(sp)
ffffffffc02004e6:	fc5e                	sd	s7,56(sp)
ffffffffc02004e8:	f862                	sd	s8,48(sp)
ffffffffc02004ea:	f466                	sd	s9,40(sp)
ffffffffc02004ec:	f06a                	sd	s10,32(sp)
ffffffffc02004ee:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc02004f0:	c37ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02004f4:	00007597          	auipc	a1,0x7
ffffffffc02004f8:	b0c5b583          	ld	a1,-1268(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc02004fc:	00002517          	auipc	a0,0x2
ffffffffc0200500:	e5450513          	addi	a0,a0,-428 # ffffffffc0202350 <commands+0x98>
ffffffffc0200504:	c23ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200508:	00007417          	auipc	s0,0x7
ffffffffc020050c:	b0040413          	addi	s0,s0,-1280 # ffffffffc0207008 <boot_dtb>
ffffffffc0200510:	600c                	ld	a1,0(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	e4e50513          	addi	a0,a0,-434 # ffffffffc0202360 <commands+0xa8>
ffffffffc020051a:	c0dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020051e:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200522:	00002517          	auipc	a0,0x2
ffffffffc0200526:	e5650513          	addi	a0,a0,-426 # ffffffffc0202378 <commands+0xc0>
    if (boot_dtb == 0) {
ffffffffc020052a:	120a0463          	beqz	s4,ffffffffc0200652 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc020052e:	57f5                	li	a5,-3
ffffffffc0200530:	07fa                	slli	a5,a5,0x1e
ffffffffc0200532:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200536:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200538:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020053c:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020053e:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200542:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200546:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020054a:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020054e:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200552:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200554:	8ec9                	or	a3,a3,a0
ffffffffc0200556:	0087979b          	slliw	a5,a5,0x8
ffffffffc020055a:	1b7d                	addi	s6,s6,-1
ffffffffc020055c:	0167f7b3          	and	a5,a5,s6
ffffffffc0200560:	8dd5                	or	a1,a1,a3
ffffffffc0200562:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200564:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200568:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc020056a:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed8a4d>
ffffffffc020056e:	10f59163          	bne	a1,a5,ffffffffc0200670 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc0200572:	471c                	lw	a5,8(a4)
ffffffffc0200574:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200576:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200578:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020057c:	0086d51b          	srliw	a0,a3,0x8
ffffffffc0200580:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200584:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200588:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020058c:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200590:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200594:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200598:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020059c:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a0:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005a2:	01146433          	or	s0,s0,a7
ffffffffc02005a6:	0086969b          	slliw	a3,a3,0x8
ffffffffc02005aa:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ae:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b0:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005b4:	8c49                	or	s0,s0,a0
ffffffffc02005b6:	0166f6b3          	and	a3,a3,s6
ffffffffc02005ba:	00ca6a33          	or	s4,s4,a2
ffffffffc02005be:	0167f7b3          	and	a5,a5,s6
ffffffffc02005c2:	8c55                	or	s0,s0,a3
ffffffffc02005c4:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005c8:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005ca:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005cc:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005ce:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005d2:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005d4:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005d6:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc02005da:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02005dc:	00002917          	auipc	s2,0x2
ffffffffc02005e0:	dec90913          	addi	s2,s2,-532 # ffffffffc02023c8 <commands+0x110>
ffffffffc02005e4:	49bd                	li	s3,15
        switch (token) {
ffffffffc02005e6:	4d91                	li	s11,4
ffffffffc02005e8:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005ea:	00002497          	auipc	s1,0x2
ffffffffc02005ee:	dd648493          	addi	s1,s1,-554 # ffffffffc02023c0 <commands+0x108>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005f2:	000a2703          	lw	a4,0(s4)
ffffffffc02005f6:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005fa:	0087569b          	srliw	a3,a4,0x8
ffffffffc02005fe:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200602:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200606:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020060a:	0107571b          	srliw	a4,a4,0x10
ffffffffc020060e:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200610:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200614:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200618:	8fd5                	or	a5,a5,a3
ffffffffc020061a:	00eb7733          	and	a4,s6,a4
ffffffffc020061e:	8fd9                	or	a5,a5,a4
ffffffffc0200620:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200622:	09778c63          	beq	a5,s7,ffffffffc02006ba <dtb_init+0x1ee>
ffffffffc0200626:	00fbea63          	bltu	s7,a5,ffffffffc020063a <dtb_init+0x16e>
ffffffffc020062a:	07a78663          	beq	a5,s10,ffffffffc0200696 <dtb_init+0x1ca>
ffffffffc020062e:	4709                	li	a4,2
ffffffffc0200630:	00e79763          	bne	a5,a4,ffffffffc020063e <dtb_init+0x172>
ffffffffc0200634:	4c81                	li	s9,0
ffffffffc0200636:	8a56                	mv	s4,s5
ffffffffc0200638:	bf6d                	j	ffffffffc02005f2 <dtb_init+0x126>
ffffffffc020063a:	ffb78ee3          	beq	a5,s11,ffffffffc0200636 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc020063e:	00002517          	auipc	a0,0x2
ffffffffc0200642:	e0250513          	addi	a0,a0,-510 # ffffffffc0202440 <commands+0x188>
ffffffffc0200646:	ae1ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	e2e50513          	addi	a0,a0,-466 # ffffffffc0202478 <commands+0x1c0>
}
ffffffffc0200652:	7446                	ld	s0,112(sp)
ffffffffc0200654:	70e6                	ld	ra,120(sp)
ffffffffc0200656:	74a6                	ld	s1,104(sp)
ffffffffc0200658:	7906                	ld	s2,96(sp)
ffffffffc020065a:	69e6                	ld	s3,88(sp)
ffffffffc020065c:	6a46                	ld	s4,80(sp)
ffffffffc020065e:	6aa6                	ld	s5,72(sp)
ffffffffc0200660:	6b06                	ld	s6,64(sp)
ffffffffc0200662:	7be2                	ld	s7,56(sp)
ffffffffc0200664:	7c42                	ld	s8,48(sp)
ffffffffc0200666:	7ca2                	ld	s9,40(sp)
ffffffffc0200668:	7d02                	ld	s10,32(sp)
ffffffffc020066a:	6de2                	ld	s11,24(sp)
ffffffffc020066c:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc020066e:	bc65                	j	ffffffffc0200126 <cprintf>
}
ffffffffc0200670:	7446                	ld	s0,112(sp)
ffffffffc0200672:	70e6                	ld	ra,120(sp)
ffffffffc0200674:	74a6                	ld	s1,104(sp)
ffffffffc0200676:	7906                	ld	s2,96(sp)
ffffffffc0200678:	69e6                	ld	s3,88(sp)
ffffffffc020067a:	6a46                	ld	s4,80(sp)
ffffffffc020067c:	6aa6                	ld	s5,72(sp)
ffffffffc020067e:	6b06                	ld	s6,64(sp)
ffffffffc0200680:	7be2                	ld	s7,56(sp)
ffffffffc0200682:	7c42                	ld	s8,48(sp)
ffffffffc0200684:	7ca2                	ld	s9,40(sp)
ffffffffc0200686:	7d02                	ld	s10,32(sp)
ffffffffc0200688:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0202398 <commands+0xe0>
}
ffffffffc0200692:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200694:	bc49                	j	ffffffffc0200126 <cprintf>
                int name_len = strlen(name);
ffffffffc0200696:	8556                	mv	a0,s5
ffffffffc0200698:	02f010ef          	jal	ra,ffffffffc0201ec6 <strlen>
ffffffffc020069c:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020069e:	4619                	li	a2,6
ffffffffc02006a0:	85a6                	mv	a1,s1
ffffffffc02006a2:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02006a4:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006a6:	075010ef          	jal	ra,ffffffffc0201f1a <strncmp>
ffffffffc02006aa:	e111                	bnez	a0,ffffffffc02006ae <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc02006ac:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006ae:	0a91                	addi	s5,s5,4
ffffffffc02006b0:	9ad2                	add	s5,s5,s4
ffffffffc02006b2:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02006b6:	8a56                	mv	s4,s5
ffffffffc02006b8:	bf2d                	j	ffffffffc02005f2 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006ba:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006be:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c2:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02006c6:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ca:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ce:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d2:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02006d6:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006da:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006de:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006e2:	00eaeab3          	or	s5,s5,a4
ffffffffc02006e6:	00fb77b3          	and	a5,s6,a5
ffffffffc02006ea:	00faeab3          	or	s5,s5,a5
ffffffffc02006ee:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006f0:	000c9c63          	bnez	s9,ffffffffc0200708 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02006f4:	1a82                	slli	s5,s5,0x20
ffffffffc02006f6:	00368793          	addi	a5,a3,3
ffffffffc02006fa:	020ada93          	srli	s5,s5,0x20
ffffffffc02006fe:	9abe                	add	s5,s5,a5
ffffffffc0200700:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200704:	8a56                	mv	s4,s5
ffffffffc0200706:	b5f5                	j	ffffffffc02005f2 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200708:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020070c:	85ca                	mv	a1,s2
ffffffffc020070e:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200710:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200714:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200718:	0187971b          	slliw	a4,a5,0x18
ffffffffc020071c:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200720:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200724:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200726:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020072a:	0087979b          	slliw	a5,a5,0x8
ffffffffc020072e:	8d59                	or	a0,a0,a4
ffffffffc0200730:	00fb77b3          	and	a5,s6,a5
ffffffffc0200734:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200736:	1502                	slli	a0,a0,0x20
ffffffffc0200738:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020073a:	9522                	add	a0,a0,s0
ffffffffc020073c:	7c0010ef          	jal	ra,ffffffffc0201efc <strcmp>
ffffffffc0200740:	66a2                	ld	a3,8(sp)
ffffffffc0200742:	f94d                	bnez	a0,ffffffffc02006f4 <dtb_init+0x228>
ffffffffc0200744:	fb59f8e3          	bgeu	s3,s5,ffffffffc02006f4 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200748:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020074c:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200750:	00002517          	auipc	a0,0x2
ffffffffc0200754:	c8050513          	addi	a0,a0,-896 # ffffffffc02023d0 <commands+0x118>
           fdt32_to_cpu(x >> 32);
ffffffffc0200758:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020075c:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200760:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200764:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200768:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020076c:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200770:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200774:	0187d693          	srli	a3,a5,0x18
ffffffffc0200778:	01861f1b          	slliw	t5,a2,0x18
ffffffffc020077c:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200780:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200784:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200788:	010f6f33          	or	t5,t5,a6
ffffffffc020078c:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200790:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200794:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200798:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079c:	0186f6b3          	and	a3,a3,s8
ffffffffc02007a0:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02007a4:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a8:	0107581b          	srliw	a6,a4,0x10
ffffffffc02007ac:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007b0:	8361                	srli	a4,a4,0x18
ffffffffc02007b2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007b6:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02007ba:	01e6e6b3          	or	a3,a3,t5
ffffffffc02007be:	00cb7633          	and	a2,s6,a2
ffffffffc02007c2:	0088181b          	slliw	a6,a6,0x8
ffffffffc02007c6:	0085959b          	slliw	a1,a1,0x8
ffffffffc02007ca:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ce:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d2:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007d6:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007da:	0088989b          	slliw	a7,a7,0x8
ffffffffc02007de:	011b78b3          	and	a7,s6,a7
ffffffffc02007e2:	005eeeb3          	or	t4,t4,t0
ffffffffc02007e6:	00c6e733          	or	a4,a3,a2
ffffffffc02007ea:	006c6c33          	or	s8,s8,t1
ffffffffc02007ee:	010b76b3          	and	a3,s6,a6
ffffffffc02007f2:	00bb7b33          	and	s6,s6,a1
ffffffffc02007f6:	01d7e7b3          	or	a5,a5,t4
ffffffffc02007fa:	016c6b33          	or	s6,s8,s6
ffffffffc02007fe:	01146433          	or	s0,s0,a7
ffffffffc0200802:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200804:	1702                	slli	a4,a4,0x20
ffffffffc0200806:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200808:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020080a:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020080c:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020080e:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200812:	0167eb33          	or	s6,a5,s6
ffffffffc0200816:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200818:	90fff0ef          	jal	ra,ffffffffc0200126 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020081c:	85a2                	mv	a1,s0
ffffffffc020081e:	00002517          	auipc	a0,0x2
ffffffffc0200822:	bd250513          	addi	a0,a0,-1070 # ffffffffc02023f0 <commands+0x138>
ffffffffc0200826:	901ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020082a:	014b5613          	srli	a2,s6,0x14
ffffffffc020082e:	85da                	mv	a1,s6
ffffffffc0200830:	00002517          	auipc	a0,0x2
ffffffffc0200834:	bd850513          	addi	a0,a0,-1064 # ffffffffc0202408 <commands+0x150>
ffffffffc0200838:	8efff0ef          	jal	ra,ffffffffc0200126 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020083c:	008b05b3          	add	a1,s6,s0
ffffffffc0200840:	15fd                	addi	a1,a1,-1
ffffffffc0200842:	00002517          	auipc	a0,0x2
ffffffffc0200846:	be650513          	addi	a0,a0,-1050 # ffffffffc0202428 <commands+0x170>
ffffffffc020084a:	8ddff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020084e:	00002517          	auipc	a0,0x2
ffffffffc0200852:	c2a50513          	addi	a0,a0,-982 # ffffffffc0202478 <commands+0x1c0>
        memory_base = mem_base;
ffffffffc0200856:	00007797          	auipc	a5,0x7
ffffffffc020085a:	be87bd23          	sd	s0,-1030(a5) # ffffffffc0207450 <memory_base>
        memory_size = mem_size;
ffffffffc020085e:	00007797          	auipc	a5,0x7
ffffffffc0200862:	bf67bd23          	sd	s6,-1030(a5) # ffffffffc0207458 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200866:	b3f5                	j	ffffffffc0200652 <dtb_init+0x186>

ffffffffc0200868 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200868:	00007517          	auipc	a0,0x7
ffffffffc020086c:	be853503          	ld	a0,-1048(a0) # ffffffffc0207450 <memory_base>
ffffffffc0200870:	8082                	ret

ffffffffc0200872 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc0200872:	00007517          	auipc	a0,0x7
ffffffffc0200876:	be653503          	ld	a0,-1050(a0) # ffffffffc0207458 <memory_size>
ffffffffc020087a:	8082                	ret

ffffffffc020087c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020087c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200880:	8082                	ret

ffffffffc0200882 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200882:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200886:	8082                	ret

ffffffffc0200888 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200888:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020088c:	00000797          	auipc	a5,0x0
ffffffffc0200890:	3d478793          	addi	a5,a5,980 # ffffffffc0200c60 <__alltraps>
ffffffffc0200894:	10579073          	csrw	stvec,a5
}
ffffffffc0200898:	8082                	ret

ffffffffc020089a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020089a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020089c:	1141                	addi	sp,sp,-16
ffffffffc020089e:	e022                	sd	s0,0(sp)
ffffffffc02008a0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02008a2:	00002517          	auipc	a0,0x2
ffffffffc02008a6:	bee50513          	addi	a0,a0,-1042 # ffffffffc0202490 <commands+0x1d8>
void print_regs(struct pushregs *gpr) {
ffffffffc02008aa:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02008ac:	87bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02008b0:	640c                	ld	a1,8(s0)
ffffffffc02008b2:	00002517          	auipc	a0,0x2
ffffffffc02008b6:	bf650513          	addi	a0,a0,-1034 # ffffffffc02024a8 <commands+0x1f0>
ffffffffc02008ba:	86dff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02008be:	680c                	ld	a1,16(s0)
ffffffffc02008c0:	00002517          	auipc	a0,0x2
ffffffffc02008c4:	c0050513          	addi	a0,a0,-1024 # ffffffffc02024c0 <commands+0x208>
ffffffffc02008c8:	85fff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02008cc:	6c0c                	ld	a1,24(s0)
ffffffffc02008ce:	00002517          	auipc	a0,0x2
ffffffffc02008d2:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02024d8 <commands+0x220>
ffffffffc02008d6:	851ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02008da:	700c                	ld	a1,32(s0)
ffffffffc02008dc:	00002517          	auipc	a0,0x2
ffffffffc02008e0:	c1450513          	addi	a0,a0,-1004 # ffffffffc02024f0 <commands+0x238>
ffffffffc02008e4:	843ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02008e8:	740c                	ld	a1,40(s0)
ffffffffc02008ea:	00002517          	auipc	a0,0x2
ffffffffc02008ee:	c1e50513          	addi	a0,a0,-994 # ffffffffc0202508 <commands+0x250>
ffffffffc02008f2:	835ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02008f6:	780c                	ld	a1,48(s0)
ffffffffc02008f8:	00002517          	auipc	a0,0x2
ffffffffc02008fc:	c2850513          	addi	a0,a0,-984 # ffffffffc0202520 <commands+0x268>
ffffffffc0200900:	827ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200904:	7c0c                	ld	a1,56(s0)
ffffffffc0200906:	00002517          	auipc	a0,0x2
ffffffffc020090a:	c3250513          	addi	a0,a0,-974 # ffffffffc0202538 <commands+0x280>
ffffffffc020090e:	819ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200912:	602c                	ld	a1,64(s0)
ffffffffc0200914:	00002517          	auipc	a0,0x2
ffffffffc0200918:	c3c50513          	addi	a0,a0,-964 # ffffffffc0202550 <commands+0x298>
ffffffffc020091c:	80bff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200920:	642c                	ld	a1,72(s0)
ffffffffc0200922:	00002517          	auipc	a0,0x2
ffffffffc0200926:	c4650513          	addi	a0,a0,-954 # ffffffffc0202568 <commands+0x2b0>
ffffffffc020092a:	ffcff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020092e:	682c                	ld	a1,80(s0)
ffffffffc0200930:	00002517          	auipc	a0,0x2
ffffffffc0200934:	c5050513          	addi	a0,a0,-944 # ffffffffc0202580 <commands+0x2c8>
ffffffffc0200938:	feeff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020093c:	6c2c                	ld	a1,88(s0)
ffffffffc020093e:	00002517          	auipc	a0,0x2
ffffffffc0200942:	c5a50513          	addi	a0,a0,-934 # ffffffffc0202598 <commands+0x2e0>
ffffffffc0200946:	fe0ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020094a:	702c                	ld	a1,96(s0)
ffffffffc020094c:	00002517          	auipc	a0,0x2
ffffffffc0200950:	c6450513          	addi	a0,a0,-924 # ffffffffc02025b0 <commands+0x2f8>
ffffffffc0200954:	fd2ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200958:	742c                	ld	a1,104(s0)
ffffffffc020095a:	00002517          	auipc	a0,0x2
ffffffffc020095e:	c6e50513          	addi	a0,a0,-914 # ffffffffc02025c8 <commands+0x310>
ffffffffc0200962:	fc4ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200966:	782c                	ld	a1,112(s0)
ffffffffc0200968:	00002517          	auipc	a0,0x2
ffffffffc020096c:	c7850513          	addi	a0,a0,-904 # ffffffffc02025e0 <commands+0x328>
ffffffffc0200970:	fb6ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200974:	7c2c                	ld	a1,120(s0)
ffffffffc0200976:	00002517          	auipc	a0,0x2
ffffffffc020097a:	c8250513          	addi	a0,a0,-894 # ffffffffc02025f8 <commands+0x340>
ffffffffc020097e:	fa8ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200982:	604c                	ld	a1,128(s0)
ffffffffc0200984:	00002517          	auipc	a0,0x2
ffffffffc0200988:	c8c50513          	addi	a0,a0,-884 # ffffffffc0202610 <commands+0x358>
ffffffffc020098c:	f9aff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200990:	644c                	ld	a1,136(s0)
ffffffffc0200992:	00002517          	auipc	a0,0x2
ffffffffc0200996:	c9650513          	addi	a0,a0,-874 # ffffffffc0202628 <commands+0x370>
ffffffffc020099a:	f8cff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020099e:	684c                	ld	a1,144(s0)
ffffffffc02009a0:	00002517          	auipc	a0,0x2
ffffffffc02009a4:	ca050513          	addi	a0,a0,-864 # ffffffffc0202640 <commands+0x388>
ffffffffc02009a8:	f7eff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02009ac:	6c4c                	ld	a1,152(s0)
ffffffffc02009ae:	00002517          	auipc	a0,0x2
ffffffffc02009b2:	caa50513          	addi	a0,a0,-854 # ffffffffc0202658 <commands+0x3a0>
ffffffffc02009b6:	f70ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02009ba:	704c                	ld	a1,160(s0)
ffffffffc02009bc:	00002517          	auipc	a0,0x2
ffffffffc02009c0:	cb450513          	addi	a0,a0,-844 # ffffffffc0202670 <commands+0x3b8>
ffffffffc02009c4:	f62ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02009c8:	744c                	ld	a1,168(s0)
ffffffffc02009ca:	00002517          	auipc	a0,0x2
ffffffffc02009ce:	cbe50513          	addi	a0,a0,-834 # ffffffffc0202688 <commands+0x3d0>
ffffffffc02009d2:	f54ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02009d6:	784c                	ld	a1,176(s0)
ffffffffc02009d8:	00002517          	auipc	a0,0x2
ffffffffc02009dc:	cc850513          	addi	a0,a0,-824 # ffffffffc02026a0 <commands+0x3e8>
ffffffffc02009e0:	f46ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02009e4:	7c4c                	ld	a1,184(s0)
ffffffffc02009e6:	00002517          	auipc	a0,0x2
ffffffffc02009ea:	cd250513          	addi	a0,a0,-814 # ffffffffc02026b8 <commands+0x400>
ffffffffc02009ee:	f38ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02009f2:	606c                	ld	a1,192(s0)
ffffffffc02009f4:	00002517          	auipc	a0,0x2
ffffffffc02009f8:	cdc50513          	addi	a0,a0,-804 # ffffffffc02026d0 <commands+0x418>
ffffffffc02009fc:	f2aff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a00:	646c                	ld	a1,200(s0)
ffffffffc0200a02:	00002517          	auipc	a0,0x2
ffffffffc0200a06:	ce650513          	addi	a0,a0,-794 # ffffffffc02026e8 <commands+0x430>
ffffffffc0200a0a:	f1cff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a0e:	686c                	ld	a1,208(s0)
ffffffffc0200a10:	00002517          	auipc	a0,0x2
ffffffffc0200a14:	cf050513          	addi	a0,a0,-784 # ffffffffc0202700 <commands+0x448>
ffffffffc0200a18:	f0eff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200a1c:	6c6c                	ld	a1,216(s0)
ffffffffc0200a1e:	00002517          	auipc	a0,0x2
ffffffffc0200a22:	cfa50513          	addi	a0,a0,-774 # ffffffffc0202718 <commands+0x460>
ffffffffc0200a26:	f00ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200a2a:	706c                	ld	a1,224(s0)
ffffffffc0200a2c:	00002517          	auipc	a0,0x2
ffffffffc0200a30:	d0450513          	addi	a0,a0,-764 # ffffffffc0202730 <commands+0x478>
ffffffffc0200a34:	ef2ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200a38:	746c                	ld	a1,232(s0)
ffffffffc0200a3a:	00002517          	auipc	a0,0x2
ffffffffc0200a3e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0202748 <commands+0x490>
ffffffffc0200a42:	ee4ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200a46:	786c                	ld	a1,240(s0)
ffffffffc0200a48:	00002517          	auipc	a0,0x2
ffffffffc0200a4c:	d1850513          	addi	a0,a0,-744 # ffffffffc0202760 <commands+0x4a8>
ffffffffc0200a50:	ed6ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a54:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a56:	6402                	ld	s0,0(sp)
ffffffffc0200a58:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a5a:	00002517          	auipc	a0,0x2
ffffffffc0200a5e:	d1e50513          	addi	a0,a0,-738 # ffffffffc0202778 <commands+0x4c0>
}
ffffffffc0200a62:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a64:	ec2ff06f          	j	ffffffffc0200126 <cprintf>

ffffffffc0200a68 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a68:	1141                	addi	sp,sp,-16
ffffffffc0200a6a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a6c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a6e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a70:	00002517          	auipc	a0,0x2
ffffffffc0200a74:	d2050513          	addi	a0,a0,-736 # ffffffffc0202790 <commands+0x4d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a78:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a7a:	eacff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200a7e:	8522                	mv	a0,s0
ffffffffc0200a80:	e1bff0ef          	jal	ra,ffffffffc020089a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200a84:	10043583          	ld	a1,256(s0)
ffffffffc0200a88:	00002517          	auipc	a0,0x2
ffffffffc0200a8c:	d2050513          	addi	a0,a0,-736 # ffffffffc02027a8 <commands+0x4f0>
ffffffffc0200a90:	e96ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200a94:	10843583          	ld	a1,264(s0)
ffffffffc0200a98:	00002517          	auipc	a0,0x2
ffffffffc0200a9c:	d2850513          	addi	a0,a0,-728 # ffffffffc02027c0 <commands+0x508>
ffffffffc0200aa0:	e86ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200aa4:	11043583          	ld	a1,272(s0)
ffffffffc0200aa8:	00002517          	auipc	a0,0x2
ffffffffc0200aac:	d3050513          	addi	a0,a0,-720 # ffffffffc02027d8 <commands+0x520>
ffffffffc0200ab0:	e76ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200ab4:	11843583          	ld	a1,280(s0)
}
ffffffffc0200ab8:	6402                	ld	s0,0(sp)
ffffffffc0200aba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200abc:	00002517          	auipc	a0,0x2
ffffffffc0200ac0:	d3450513          	addi	a0,a0,-716 # ffffffffc02027f0 <commands+0x538>
}
ffffffffc0200ac4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200ac6:	e60ff06f          	j	ffffffffc0200126 <cprintf>

ffffffffc0200aca <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200aca:	11853783          	ld	a5,280(a0)
ffffffffc0200ace:	472d                	li	a4,11
ffffffffc0200ad0:	0786                	slli	a5,a5,0x1
ffffffffc0200ad2:	8385                	srli	a5,a5,0x1
ffffffffc0200ad4:	08f76463          	bltu	a4,a5,ffffffffc0200b5c <interrupt_handler+0x92>
ffffffffc0200ad8:	00002717          	auipc	a4,0x2
ffffffffc0200adc:	df870713          	addi	a4,a4,-520 # ffffffffc02028d0 <commands+0x618>
ffffffffc0200ae0:	078a                	slli	a5,a5,0x2
ffffffffc0200ae2:	97ba                	add	a5,a5,a4
ffffffffc0200ae4:	439c                	lw	a5,0(a5)
ffffffffc0200ae6:	97ba                	add	a5,a5,a4
ffffffffc0200ae8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200aea:	00002517          	auipc	a0,0x2
ffffffffc0200aee:	d7e50513          	addi	a0,a0,-642 # ffffffffc0202868 <commands+0x5b0>
ffffffffc0200af2:	e34ff06f          	j	ffffffffc0200126 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc0200af6:	00002517          	auipc	a0,0x2
ffffffffc0200afa:	d5250513          	addi	a0,a0,-686 # ffffffffc0202848 <commands+0x590>
ffffffffc0200afe:	e28ff06f          	j	ffffffffc0200126 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200b02:	00002517          	auipc	a0,0x2
ffffffffc0200b06:	d0650513          	addi	a0,a0,-762 # ffffffffc0202808 <commands+0x550>
ffffffffc0200b0a:	e1cff06f          	j	ffffffffc0200126 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc0200b0e:	00002517          	auipc	a0,0x2
ffffffffc0200b12:	d7a50513          	addi	a0,a0,-646 # ffffffffc0202888 <commands+0x5d0>
ffffffffc0200b16:	e10ff06f          	j	ffffffffc0200126 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200b1a:	1141                	addi	sp,sp,-16
ffffffffc0200b1c:	e022                	sd	s0,0(sp)
ffffffffc0200b1e:	e406                	sd	ra,8(sp)
            // (1) 设置下一次时钟中断
            clock_set_next_event();

            // (2) 计数器（ticks）加一
            // (3) 判断是否达到了 TICK_NUM (100)
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200b20:	00007417          	auipc	s0,0x7
ffffffffc0200b24:	92840413          	addi	s0,s0,-1752 # ffffffffc0207448 <ticks>
            clock_set_next_event();
ffffffffc0200b28:	987ff0ef          	jal	ra,ffffffffc02004ae <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200b2c:	601c                	ld	a5,0(s0)
ffffffffc0200b2e:	06400713          	li	a4,100
ffffffffc0200b32:	0785                	addi	a5,a5,1
ffffffffc0200b34:	02e7f733          	remu	a4,a5,a4
ffffffffc0200b38:	e01c                	sd	a5,0(s0)
ffffffffc0200b3a:	c315                	beqz	a4,ffffffffc0200b5e <interrupt_handler+0x94>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200b3c:	60a2                	ld	ra,8(sp)
ffffffffc0200b3e:	6402                	ld	s0,0(sp)
ffffffffc0200b40:	0141                	addi	sp,sp,16
ffffffffc0200b42:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200b44:	00002517          	auipc	a0,0x2
ffffffffc0200b48:	d6c50513          	addi	a0,a0,-660 # ffffffffc02028b0 <commands+0x5f8>
ffffffffc0200b4c:	ddaff06f          	j	ffffffffc0200126 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200b50:	00002517          	auipc	a0,0x2
ffffffffc0200b54:	cd850513          	addi	a0,a0,-808 # ffffffffc0202828 <commands+0x570>
ffffffffc0200b58:	dceff06f          	j	ffffffffc0200126 <cprintf>
            print_trapframe(tf);
ffffffffc0200b5c:	b731                	j	ffffffffc0200a68 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b5e:	06400593          	li	a1,100
ffffffffc0200b62:	00002517          	auipc	a0,0x2
ffffffffc0200b66:	d3e50513          	addi	a0,a0,-706 # ffffffffc02028a0 <commands+0x5e8>
ffffffffc0200b6a:	dbcff0ef          	jal	ra,ffffffffc0200126 <cprintf>
                print_count++;
ffffffffc0200b6e:	00007717          	auipc	a4,0x7
ffffffffc0200b72:	8f270713          	addi	a4,a4,-1806 # ffffffffc0207460 <print_count>
ffffffffc0200b76:	431c                	lw	a5,0(a4)
                if (print_count == 10) {
ffffffffc0200b78:	46a9                	li	a3,10
                print_count++;
ffffffffc0200b7a:	0017861b          	addiw	a2,a5,1
ffffffffc0200b7e:	c310                	sw	a2,0(a4)
                if (print_count == 10) {
ffffffffc0200b80:	00d60c63          	beq	a2,a3,ffffffffc0200b98 <interrupt_handler+0xce>
                if (ticks >= TICK_NUM * 10) {
ffffffffc0200b84:	6018                	ld	a4,0(s0)
ffffffffc0200b86:	3e700793          	li	a5,999
ffffffffc0200b8a:	fae7f9e3          	bgeu	a5,a4,ffffffffc0200b3c <interrupt_handler+0x72>
                    ticks = 0;
ffffffffc0200b8e:	00007797          	auipc	a5,0x7
ffffffffc0200b92:	8a07bd23          	sd	zero,-1862(a5) # ffffffffc0207448 <ticks>
ffffffffc0200b96:	b75d                	j	ffffffffc0200b3c <interrupt_handler+0x72>
                    sbi_shutdown(); // 关机
ffffffffc0200b98:	314010ef          	jal	ra,ffffffffc0201eac <sbi_shutdown>
ffffffffc0200b9c:	b7e5                	j	ffffffffc0200b84 <interrupt_handler+0xba>

ffffffffc0200b9e <exception_handler>:

void exception_handler(struct trapframe *tf) {
ffffffffc0200b9e:	1101                	addi	sp,sp,-32
ffffffffc0200ba0:	e822                	sd	s0,16(sp)
    switch (tf->cause) {
ffffffffc0200ba2:	11853403          	ld	s0,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200ba6:	e426                	sd	s1,8(sp)
ffffffffc0200ba8:	e04a                	sd	s2,0(sp)
ffffffffc0200baa:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200bac:	490d                	li	s2,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200bae:	84aa                	mv	s1,a0
    switch (tf->cause) {
ffffffffc0200bb0:	05240f63          	beq	s0,s2,ffffffffc0200c0e <exception_handler+0x70>
ffffffffc0200bb4:	04896363          	bltu	s2,s0,ffffffffc0200bfa <exception_handler+0x5c>
ffffffffc0200bb8:	4789                	li	a5,2
ffffffffc0200bba:	02f41a63          	bne	s0,a5,ffffffffc0200bee <exception_handler+0x50>
             /* LAB3 CHALLENGE3   YOUR CODE : 2313447 */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type: Illegal instruction\n");
ffffffffc0200bbe:	00002517          	auipc	a0,0x2
ffffffffc0200bc2:	d4250513          	addi	a0,a0,-702 # ffffffffc0202900 <commands+0x648>
ffffffffc0200bc6:	d60ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200bca:	1084b583          	ld	a1,264(s1)
ffffffffc0200bce:	00002517          	auipc	a0,0x2
ffffffffc0200bd2:	d5a50513          	addi	a0,a0,-678 # ffffffffc0202928 <commands+0x670>
ffffffffc0200bd6:	d50ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            // 读取指令判断长度: RISC-V指令最低2位为11表示32位指令，否则为16位压缩指令
            uint16_t instr = *(uint16_t*)(tf->epc);
ffffffffc0200bda:	1084b783          	ld	a5,264(s1)
            tf->epc += (instr & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200bde:	0007d703          	lhu	a4,0(a5)
ffffffffc0200be2:	8b0d                	andi	a4,a4,3
ffffffffc0200be4:	07270563          	beq	a4,s2,ffffffffc0200c4e <exception_handler+0xb0>
ffffffffc0200be8:	97a2                	add	a5,a5,s0
ffffffffc0200bea:	10f4b423          	sd	a5,264(s1)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200bee:	60e2                	ld	ra,24(sp)
ffffffffc0200bf0:	6442                	ld	s0,16(sp)
ffffffffc0200bf2:	64a2                	ld	s1,8(sp)
ffffffffc0200bf4:	6902                	ld	s2,0(sp)
ffffffffc0200bf6:	6105                	addi	sp,sp,32
ffffffffc0200bf8:	8082                	ret
    switch (tf->cause) {
ffffffffc0200bfa:	1471                	addi	s0,s0,-4
ffffffffc0200bfc:	479d                	li	a5,7
ffffffffc0200bfe:	fe87f8e3          	bgeu	a5,s0,ffffffffc0200bee <exception_handler+0x50>
}
ffffffffc0200c02:	6442                	ld	s0,16(sp)
ffffffffc0200c04:	60e2                	ld	ra,24(sp)
ffffffffc0200c06:	64a2                	ld	s1,8(sp)
ffffffffc0200c08:	6902                	ld	s2,0(sp)
ffffffffc0200c0a:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c0c:	bdb1                	j	ffffffffc0200a68 <print_trapframe>
            cprintf("Exception type: breakpoint\n");
ffffffffc0200c0e:	00002517          	auipc	a0,0x2
ffffffffc0200c12:	d4250513          	addi	a0,a0,-702 # ffffffffc0202950 <commands+0x698>
ffffffffc0200c16:	d10ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc0200c1a:	1084b583          	ld	a1,264(s1)
ffffffffc0200c1e:	00002517          	auipc	a0,0x2
ffffffffc0200c22:	d5250513          	addi	a0,a0,-686 # ffffffffc0202970 <commands+0x6b8>
ffffffffc0200c26:	d00ff0ef          	jal	ra,ffffffffc0200126 <cprintf>
            uint16_t instr_bp = *(uint16_t*)(tf->epc);
ffffffffc0200c2a:	1084b783          	ld	a5,264(s1)
            tf->epc += (instr_bp & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200c2e:	4691                	li	a3,4
ffffffffc0200c30:	0007d703          	lhu	a4,0(a5)
ffffffffc0200c34:	8b0d                	andi	a4,a4,3
ffffffffc0200c36:	00870363          	beq	a4,s0,ffffffffc0200c3c <exception_handler+0x9e>
ffffffffc0200c3a:	4689                	li	a3,2
}
ffffffffc0200c3c:	60e2                	ld	ra,24(sp)
ffffffffc0200c3e:	6442                	ld	s0,16(sp)
            tf->epc += (instr_bp & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200c40:	97b6                	add	a5,a5,a3
ffffffffc0200c42:	10f4b423          	sd	a5,264(s1)
}
ffffffffc0200c46:	6902                	ld	s2,0(sp)
ffffffffc0200c48:	64a2                	ld	s1,8(sp)
ffffffffc0200c4a:	6105                	addi	sp,sp,32
ffffffffc0200c4c:	8082                	ret
            tf->epc += (instr & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200c4e:	4411                	li	s0,4
ffffffffc0200c50:	bf61                	j	ffffffffc0200be8 <exception_handler+0x4a>

ffffffffc0200c52 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c52:	11853783          	ld	a5,280(a0)
ffffffffc0200c56:	0007c363          	bltz	a5,ffffffffc0200c5c <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200c5a:	b791                	j	ffffffffc0200b9e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200c5c:	b5bd                	j	ffffffffc0200aca <interrupt_handler>
	...

ffffffffc0200c60 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200c60:	14011073          	csrw	sscratch,sp
ffffffffc0200c64:	712d                	addi	sp,sp,-288
ffffffffc0200c66:	e002                	sd	zero,0(sp)
ffffffffc0200c68:	e406                	sd	ra,8(sp)
ffffffffc0200c6a:	ec0e                	sd	gp,24(sp)
ffffffffc0200c6c:	f012                	sd	tp,32(sp)
ffffffffc0200c6e:	f416                	sd	t0,40(sp)
ffffffffc0200c70:	f81a                	sd	t1,48(sp)
ffffffffc0200c72:	fc1e                	sd	t2,56(sp)
ffffffffc0200c74:	e0a2                	sd	s0,64(sp)
ffffffffc0200c76:	e4a6                	sd	s1,72(sp)
ffffffffc0200c78:	e8aa                	sd	a0,80(sp)
ffffffffc0200c7a:	ecae                	sd	a1,88(sp)
ffffffffc0200c7c:	f0b2                	sd	a2,96(sp)
ffffffffc0200c7e:	f4b6                	sd	a3,104(sp)
ffffffffc0200c80:	f8ba                	sd	a4,112(sp)
ffffffffc0200c82:	fcbe                	sd	a5,120(sp)
ffffffffc0200c84:	e142                	sd	a6,128(sp)
ffffffffc0200c86:	e546                	sd	a7,136(sp)
ffffffffc0200c88:	e94a                	sd	s2,144(sp)
ffffffffc0200c8a:	ed4e                	sd	s3,152(sp)
ffffffffc0200c8c:	f152                	sd	s4,160(sp)
ffffffffc0200c8e:	f556                	sd	s5,168(sp)
ffffffffc0200c90:	f95a                	sd	s6,176(sp)
ffffffffc0200c92:	fd5e                	sd	s7,184(sp)
ffffffffc0200c94:	e1e2                	sd	s8,192(sp)
ffffffffc0200c96:	e5e6                	sd	s9,200(sp)
ffffffffc0200c98:	e9ea                	sd	s10,208(sp)
ffffffffc0200c9a:	edee                	sd	s11,216(sp)
ffffffffc0200c9c:	f1f2                	sd	t3,224(sp)
ffffffffc0200c9e:	f5f6                	sd	t4,232(sp)
ffffffffc0200ca0:	f9fa                	sd	t5,240(sp)
ffffffffc0200ca2:	fdfe                	sd	t6,248(sp)
ffffffffc0200ca4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ca8:	100024f3          	csrr	s1,sstatus
ffffffffc0200cac:	14102973          	csrr	s2,sepc
ffffffffc0200cb0:	143029f3          	csrr	s3,stval
ffffffffc0200cb4:	14202a73          	csrr	s4,scause
ffffffffc0200cb8:	e822                	sd	s0,16(sp)
ffffffffc0200cba:	e226                	sd	s1,256(sp)
ffffffffc0200cbc:	e64a                	sd	s2,264(sp)
ffffffffc0200cbe:	ea4e                	sd	s3,272(sp)
ffffffffc0200cc0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cc2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cc4:	f8fff0ef          	jal	ra,ffffffffc0200c52 <trap>

ffffffffc0200cc8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cc8:	6492                	ld	s1,256(sp)
ffffffffc0200cca:	6932                	ld	s2,264(sp)
ffffffffc0200ccc:	10049073          	csrw	sstatus,s1
ffffffffc0200cd0:	14191073          	csrw	sepc,s2
ffffffffc0200cd4:	60a2                	ld	ra,8(sp)
ffffffffc0200cd6:	61e2                	ld	gp,24(sp)
ffffffffc0200cd8:	7202                	ld	tp,32(sp)
ffffffffc0200cda:	72a2                	ld	t0,40(sp)
ffffffffc0200cdc:	7342                	ld	t1,48(sp)
ffffffffc0200cde:	73e2                	ld	t2,56(sp)
ffffffffc0200ce0:	6406                	ld	s0,64(sp)
ffffffffc0200ce2:	64a6                	ld	s1,72(sp)
ffffffffc0200ce4:	6546                	ld	a0,80(sp)
ffffffffc0200ce6:	65e6                	ld	a1,88(sp)
ffffffffc0200ce8:	7606                	ld	a2,96(sp)
ffffffffc0200cea:	76a6                	ld	a3,104(sp)
ffffffffc0200cec:	7746                	ld	a4,112(sp)
ffffffffc0200cee:	77e6                	ld	a5,120(sp)
ffffffffc0200cf0:	680a                	ld	a6,128(sp)
ffffffffc0200cf2:	68aa                	ld	a7,136(sp)
ffffffffc0200cf4:	694a                	ld	s2,144(sp)
ffffffffc0200cf6:	69ea                	ld	s3,152(sp)
ffffffffc0200cf8:	7a0a                	ld	s4,160(sp)
ffffffffc0200cfa:	7aaa                	ld	s5,168(sp)
ffffffffc0200cfc:	7b4a                	ld	s6,176(sp)
ffffffffc0200cfe:	7bea                	ld	s7,184(sp)
ffffffffc0200d00:	6c0e                	ld	s8,192(sp)
ffffffffc0200d02:	6cae                	ld	s9,200(sp)
ffffffffc0200d04:	6d4e                	ld	s10,208(sp)
ffffffffc0200d06:	6dee                	ld	s11,216(sp)
ffffffffc0200d08:	7e0e                	ld	t3,224(sp)
ffffffffc0200d0a:	7eae                	ld	t4,232(sp)
ffffffffc0200d0c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d0e:	7fee                	ld	t6,248(sp)
ffffffffc0200d10:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d12:	10200073          	sret

ffffffffc0200d16 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200d16:	00006797          	auipc	a5,0x6
ffffffffc0200d1a:	31278793          	addi	a5,a5,786 # ffffffffc0207028 <free_area>
ffffffffc0200d1e:	e79c                	sd	a5,8(a5)
ffffffffc0200d20:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200d22:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200d26:	8082                	ret

ffffffffc0200d28 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200d28:	00006517          	auipc	a0,0x6
ffffffffc0200d2c:	31056503          	lwu	a0,784(a0) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200d30:	8082                	ret

ffffffffc0200d32 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200d32:	c14d                	beqz	a0,ffffffffc0200dd4 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200d34:	00006617          	auipc	a2,0x6
ffffffffc0200d38:	2f460613          	addi	a2,a2,756 # ffffffffc0207028 <free_area>
ffffffffc0200d3c:	01062803          	lw	a6,16(a2)
ffffffffc0200d40:	86aa                	mv	a3,a0
ffffffffc0200d42:	02081793          	slli	a5,a6,0x20
ffffffffc0200d46:	9381                	srli	a5,a5,0x20
ffffffffc0200d48:	08a7e463          	bltu	a5,a0,ffffffffc0200dd0 <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200d4c:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200d4e:	0018059b          	addiw	a1,a6,1
ffffffffc0200d52:	1582                	slli	a1,a1,0x20
ffffffffc0200d54:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200d56:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d58:	06c78b63          	beq	a5,a2,ffffffffc0200dce <best_fit_alloc_pages+0x9c>
        if (p->property >= n) {
ffffffffc0200d5c:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200d60:	00d76763          	bltu	a4,a3,ffffffffc0200d6e <best_fit_alloc_pages+0x3c>
            if (p->property < min_size) {
ffffffffc0200d64:	00b77563          	bgeu	a4,a1,ffffffffc0200d6e <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200d68:	fe878513          	addi	a0,a5,-24
ffffffffc0200d6c:	85ba                	mv	a1,a4
ffffffffc0200d6e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d70:	fec796e3          	bne	a5,a2,ffffffffc0200d5c <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200d74:	cd29                	beqz	a0,ffffffffc0200dce <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d76:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200d78:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200d7a:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200d7c:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d80:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200d82:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200d84:	02059793          	slli	a5,a1,0x20
ffffffffc0200d88:	9381                	srli	a5,a5,0x20
ffffffffc0200d8a:	02f6f863          	bgeu	a3,a5,ffffffffc0200dba <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200d8e:	00269793          	slli	a5,a3,0x2
ffffffffc0200d92:	97b6                	add	a5,a5,a3
ffffffffc0200d94:	078e                	slli	a5,a5,0x3
ffffffffc0200d96:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200d98:	411585bb          	subw	a1,a1,a7
ffffffffc0200d9c:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d9e:	4689                	li	a3,2
ffffffffc0200da0:	00878593          	addi	a1,a5,8
ffffffffc0200da4:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200da8:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200daa:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc0200dae:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200db2:	e28c                	sd	a1,0(a3)
ffffffffc0200db4:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200db6:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200db8:	ef98                	sd	a4,24(a5)
ffffffffc0200dba:	4118083b          	subw	a6,a6,a7
ffffffffc0200dbe:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200dc2:	57f5                	li	a5,-3
ffffffffc0200dc4:	00850713          	addi	a4,a0,8
ffffffffc0200dc8:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200dcc:	8082                	ret
}
ffffffffc0200dce:	8082                	ret
        return NULL;
ffffffffc0200dd0:	4501                	li	a0,0
ffffffffc0200dd2:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200dd4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200dd6:	00002697          	auipc	a3,0x2
ffffffffc0200dda:	bba68693          	addi	a3,a3,-1094 # ffffffffc0202990 <commands+0x6d8>
ffffffffc0200dde:	00002617          	auipc	a2,0x2
ffffffffc0200de2:	bba60613          	addi	a2,a2,-1094 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0200de6:	06d00593          	li	a1,109
ffffffffc0200dea:	00002517          	auipc	a0,0x2
ffffffffc0200dee:	bc650513          	addi	a0,a0,-1082 # ffffffffc02029b0 <commands+0x6f8>
best_fit_alloc_pages(size_t n) {
ffffffffc0200df2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200df4:	e2cff0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc0200df8 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200df8:	715d                	addi	sp,sp,-80
ffffffffc0200dfa:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200dfc:	00006417          	auipc	s0,0x6
ffffffffc0200e00:	22c40413          	addi	s0,s0,556 # ffffffffc0207028 <free_area>
ffffffffc0200e04:	641c                	ld	a5,8(s0)
ffffffffc0200e06:	e486                	sd	ra,72(sp)
ffffffffc0200e08:	fc26                	sd	s1,56(sp)
ffffffffc0200e0a:	f84a                	sd	s2,48(sp)
ffffffffc0200e0c:	f44e                	sd	s3,40(sp)
ffffffffc0200e0e:	f052                	sd	s4,32(sp)
ffffffffc0200e10:	ec56                	sd	s5,24(sp)
ffffffffc0200e12:	e85a                	sd	s6,16(sp)
ffffffffc0200e14:	e45e                	sd	s7,8(sp)
ffffffffc0200e16:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e18:	26878b63          	beq	a5,s0,ffffffffc020108e <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200e1c:	4481                	li	s1,0
ffffffffc0200e1e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e20:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e24:	8b09                	andi	a4,a4,2
ffffffffc0200e26:	26070863          	beqz	a4,ffffffffc0201096 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200e2a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e2e:	679c                	ld	a5,8(a5)
ffffffffc0200e30:	2905                	addiw	s2,s2,1
ffffffffc0200e32:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e34:	fe8796e3          	bne	a5,s0,ffffffffc0200e20 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e38:	89a6                	mv	s3,s1
ffffffffc0200e3a:	167000ef          	jal	ra,ffffffffc02017a0 <nr_free_pages>
ffffffffc0200e3e:	33351c63          	bne	a0,s3,ffffffffc0201176 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e42:	4505                	li	a0,1
ffffffffc0200e44:	0df000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200e48:	8a2a                	mv	s4,a0
ffffffffc0200e4a:	36050663          	beqz	a0,ffffffffc02011b6 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e4e:	4505                	li	a0,1
ffffffffc0200e50:	0d3000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200e54:	89aa                	mv	s3,a0
ffffffffc0200e56:	34050063          	beqz	a0,ffffffffc0201196 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e5a:	4505                	li	a0,1
ffffffffc0200e5c:	0c7000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200e60:	8aaa                	mv	s5,a0
ffffffffc0200e62:	2c050a63          	beqz	a0,ffffffffc0201136 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e66:	253a0863          	beq	s4,s3,ffffffffc02010b6 <best_fit_check+0x2be>
ffffffffc0200e6a:	24aa0663          	beq	s4,a0,ffffffffc02010b6 <best_fit_check+0x2be>
ffffffffc0200e6e:	24a98463          	beq	s3,a0,ffffffffc02010b6 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e72:	000a2783          	lw	a5,0(s4)
ffffffffc0200e76:	26079063          	bnez	a5,ffffffffc02010d6 <best_fit_check+0x2de>
ffffffffc0200e7a:	0009a783          	lw	a5,0(s3)
ffffffffc0200e7e:	24079c63          	bnez	a5,ffffffffc02010d6 <best_fit_check+0x2de>
ffffffffc0200e82:	411c                	lw	a5,0(a0)
ffffffffc0200e84:	24079963          	bnez	a5,ffffffffc02010d6 <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e88:	00006797          	auipc	a5,0x6
ffffffffc0200e8c:	5e87b783          	ld	a5,1512(a5) # ffffffffc0207470 <pages>
ffffffffc0200e90:	40fa0733          	sub	a4,s4,a5
ffffffffc0200e94:	870d                	srai	a4,a4,0x3
ffffffffc0200e96:	00002597          	auipc	a1,0x2
ffffffffc0200e9a:	20a5b583          	ld	a1,522(a1) # ffffffffc02030a0 <error_string+0x38>
ffffffffc0200e9e:	02b70733          	mul	a4,a4,a1
ffffffffc0200ea2:	00002617          	auipc	a2,0x2
ffffffffc0200ea6:	20663603          	ld	a2,518(a2) # ffffffffc02030a8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eaa:	00006697          	auipc	a3,0x6
ffffffffc0200eae:	5be6b683          	ld	a3,1470(a3) # ffffffffc0207468 <npage>
ffffffffc0200eb2:	06b2                	slli	a3,a3,0xc
ffffffffc0200eb4:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eb6:	0732                	slli	a4,a4,0xc
ffffffffc0200eb8:	22d77f63          	bgeu	a4,a3,ffffffffc02010f6 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ebc:	40f98733          	sub	a4,s3,a5
ffffffffc0200ec0:	870d                	srai	a4,a4,0x3
ffffffffc0200ec2:	02b70733          	mul	a4,a4,a1
ffffffffc0200ec6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ec8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eca:	3ed77663          	bgeu	a4,a3,ffffffffc02012b6 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ece:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ed2:	878d                	srai	a5,a5,0x3
ffffffffc0200ed4:	02b787b3          	mul	a5,a5,a1
ffffffffc0200ed8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eda:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200edc:	3ad7fd63          	bgeu	a5,a3,ffffffffc0201296 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200ee0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ee2:	00043c03          	ld	s8,0(s0)
ffffffffc0200ee6:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200eea:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200eee:	e400                	sd	s0,8(s0)
ffffffffc0200ef0:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200ef2:	00006797          	auipc	a5,0x6
ffffffffc0200ef6:	1407a323          	sw	zero,326(a5) # ffffffffc0207038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200efa:	029000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200efe:	36051c63          	bnez	a0,ffffffffc0201276 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200f02:	4585                	li	a1,1
ffffffffc0200f04:	8552                	mv	a0,s4
ffffffffc0200f06:	05b000ef          	jal	ra,ffffffffc0201760 <free_pages>
    free_page(p1);
ffffffffc0200f0a:	4585                	li	a1,1
ffffffffc0200f0c:	854e                	mv	a0,s3
ffffffffc0200f0e:	053000ef          	jal	ra,ffffffffc0201760 <free_pages>
    free_page(p2);
ffffffffc0200f12:	4585                	li	a1,1
ffffffffc0200f14:	8556                	mv	a0,s5
ffffffffc0200f16:	04b000ef          	jal	ra,ffffffffc0201760 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f1a:	4818                	lw	a4,16(s0)
ffffffffc0200f1c:	478d                	li	a5,3
ffffffffc0200f1e:	32f71c63          	bne	a4,a5,ffffffffc0201256 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f22:	4505                	li	a0,1
ffffffffc0200f24:	7fe000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200f28:	89aa                	mv	s3,a0
ffffffffc0200f2a:	30050663          	beqz	a0,ffffffffc0201236 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f2e:	4505                	li	a0,1
ffffffffc0200f30:	7f2000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200f34:	8aaa                	mv	s5,a0
ffffffffc0200f36:	2e050063          	beqz	a0,ffffffffc0201216 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f3a:	4505                	li	a0,1
ffffffffc0200f3c:	7e6000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200f40:	8a2a                	mv	s4,a0
ffffffffc0200f42:	2a050a63          	beqz	a0,ffffffffc02011f6 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200f46:	4505                	li	a0,1
ffffffffc0200f48:	7da000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200f4c:	28051563          	bnez	a0,ffffffffc02011d6 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200f50:	4585                	li	a1,1
ffffffffc0200f52:	854e                	mv	a0,s3
ffffffffc0200f54:	00d000ef          	jal	ra,ffffffffc0201760 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f58:	641c                	ld	a5,8(s0)
ffffffffc0200f5a:	1a878e63          	beq	a5,s0,ffffffffc0201116 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200f5e:	4505                	li	a0,1
ffffffffc0200f60:	7c2000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200f64:	52a99963          	bne	s3,a0,ffffffffc0201496 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200f68:	4505                	li	a0,1
ffffffffc0200f6a:	7b8000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200f6e:	50051463          	bnez	a0,ffffffffc0201476 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200f72:	481c                	lw	a5,16(s0)
ffffffffc0200f74:	4e079163          	bnez	a5,ffffffffc0201456 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200f78:	854e                	mv	a0,s3
ffffffffc0200f7a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f7c:	01843023          	sd	s8,0(s0)
ffffffffc0200f80:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f84:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f88:	7d8000ef          	jal	ra,ffffffffc0201760 <free_pages>
    free_page(p1);
ffffffffc0200f8c:	4585                	li	a1,1
ffffffffc0200f8e:	8556                	mv	a0,s5
ffffffffc0200f90:	7d0000ef          	jal	ra,ffffffffc0201760 <free_pages>
    free_page(p2);
ffffffffc0200f94:	4585                	li	a1,1
ffffffffc0200f96:	8552                	mv	a0,s4
ffffffffc0200f98:	7c8000ef          	jal	ra,ffffffffc0201760 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200f9c:	4515                	li	a0,5
ffffffffc0200f9e:	784000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200fa2:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fa4:	48050963          	beqz	a0,ffffffffc0201436 <best_fit_check+0x63e>
ffffffffc0200fa8:	651c                	ld	a5,8(a0)
ffffffffc0200faa:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200fac:	8b85                	andi	a5,a5,1
ffffffffc0200fae:	46079463          	bnez	a5,ffffffffc0201416 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fb2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fb4:	00043a83          	ld	s5,0(s0)
ffffffffc0200fb8:	00843a03          	ld	s4,8(s0)
ffffffffc0200fbc:	e000                	sd	s0,0(s0)
ffffffffc0200fbe:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200fc0:	762000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200fc4:	42051963          	bnez	a0,ffffffffc02013f6 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200fc8:	4589                	li	a1,2
ffffffffc0200fca:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200fce:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200fd2:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200fd6:	00006797          	auipc	a5,0x6
ffffffffc0200fda:	0607a123          	sw	zero,98(a5) # ffffffffc0207038 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200fde:	782000ef          	jal	ra,ffffffffc0201760 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200fe2:	8562                	mv	a0,s8
ffffffffc0200fe4:	4585                	li	a1,1
ffffffffc0200fe6:	77a000ef          	jal	ra,ffffffffc0201760 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fea:	4511                	li	a0,4
ffffffffc0200fec:	736000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0200ff0:	3e051363          	bnez	a0,ffffffffc02013d6 <best_fit_check+0x5de>
ffffffffc0200ff4:	0309b783          	ld	a5,48(s3)
ffffffffc0200ff8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ffa:	8b85                	andi	a5,a5,1
ffffffffc0200ffc:	3a078d63          	beqz	a5,ffffffffc02013b6 <best_fit_check+0x5be>
ffffffffc0201000:	0389a703          	lw	a4,56(s3)
ffffffffc0201004:	4789                	li	a5,2
ffffffffc0201006:	3af71863          	bne	a4,a5,ffffffffc02013b6 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020100a:	4505                	li	a0,1
ffffffffc020100c:	716000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0201010:	8baa                	mv	s7,a0
ffffffffc0201012:	38050263          	beqz	a0,ffffffffc0201396 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201016:	4509                	li	a0,2
ffffffffc0201018:	70a000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc020101c:	34050d63          	beqz	a0,ffffffffc0201376 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0201020:	337c1b63          	bne	s8,s7,ffffffffc0201356 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0201024:	854e                	mv	a0,s3
ffffffffc0201026:	4595                	li	a1,5
ffffffffc0201028:	738000ef          	jal	ra,ffffffffc0201760 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020102c:	4515                	li	a0,5
ffffffffc020102e:	6f4000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc0201032:	89aa                	mv	s3,a0
ffffffffc0201034:	30050163          	beqz	a0,ffffffffc0201336 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0201038:	4505                	li	a0,1
ffffffffc020103a:	6e8000ef          	jal	ra,ffffffffc0201722 <alloc_pages>
ffffffffc020103e:	2c051c63          	bnez	a0,ffffffffc0201316 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0201042:	481c                	lw	a5,16(s0)
ffffffffc0201044:	2a079963          	bnez	a5,ffffffffc02012f6 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201048:	4595                	li	a1,5
ffffffffc020104a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020104c:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0201050:	01543023          	sd	s5,0(s0)
ffffffffc0201054:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0201058:	708000ef          	jal	ra,ffffffffc0201760 <free_pages>
    return listelm->next;
ffffffffc020105c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020105e:	00878963          	beq	a5,s0,ffffffffc0201070 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201062:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201066:	679c                	ld	a5,8(a5)
ffffffffc0201068:	397d                	addiw	s2,s2,-1
ffffffffc020106a:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020106c:	fe879be3          	bne	a5,s0,ffffffffc0201062 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0201070:	26091363          	bnez	s2,ffffffffc02012d6 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0201074:	e0ed                	bnez	s1,ffffffffc0201156 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0201076:	60a6                	ld	ra,72(sp)
ffffffffc0201078:	6406                	ld	s0,64(sp)
ffffffffc020107a:	74e2                	ld	s1,56(sp)
ffffffffc020107c:	7942                	ld	s2,48(sp)
ffffffffc020107e:	79a2                	ld	s3,40(sp)
ffffffffc0201080:	7a02                	ld	s4,32(sp)
ffffffffc0201082:	6ae2                	ld	s5,24(sp)
ffffffffc0201084:	6b42                	ld	s6,16(sp)
ffffffffc0201086:	6ba2                	ld	s7,8(sp)
ffffffffc0201088:	6c02                	ld	s8,0(sp)
ffffffffc020108a:	6161                	addi	sp,sp,80
ffffffffc020108c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020108e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201090:	4481                	li	s1,0
ffffffffc0201092:	4901                	li	s2,0
ffffffffc0201094:	b35d                	j	ffffffffc0200e3a <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0201096:	00002697          	auipc	a3,0x2
ffffffffc020109a:	93268693          	addi	a3,a3,-1742 # ffffffffc02029c8 <commands+0x710>
ffffffffc020109e:	00002617          	auipc	a2,0x2
ffffffffc02010a2:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02010a6:	11400593          	li	a1,276
ffffffffc02010aa:	00002517          	auipc	a0,0x2
ffffffffc02010ae:	90650513          	addi	a0,a0,-1786 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02010b2:	b6eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02010b6:	00002697          	auipc	a3,0x2
ffffffffc02010ba:	9a268693          	addi	a3,a3,-1630 # ffffffffc0202a58 <commands+0x7a0>
ffffffffc02010be:	00002617          	auipc	a2,0x2
ffffffffc02010c2:	8da60613          	addi	a2,a2,-1830 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02010c6:	0e000593          	li	a1,224
ffffffffc02010ca:	00002517          	auipc	a0,0x2
ffffffffc02010ce:	8e650513          	addi	a0,a0,-1818 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02010d2:	b4eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02010d6:	00002697          	auipc	a3,0x2
ffffffffc02010da:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0202a80 <commands+0x7c8>
ffffffffc02010de:	00002617          	auipc	a2,0x2
ffffffffc02010e2:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02010e6:	0e100593          	li	a1,225
ffffffffc02010ea:	00002517          	auipc	a0,0x2
ffffffffc02010ee:	8c650513          	addi	a0,a0,-1850 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02010f2:	b2eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02010f6:	00002697          	auipc	a3,0x2
ffffffffc02010fa:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0202ac0 <commands+0x808>
ffffffffc02010fe:	00002617          	auipc	a2,0x2
ffffffffc0201102:	89a60613          	addi	a2,a2,-1894 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201106:	0e300593          	li	a1,227
ffffffffc020110a:	00002517          	auipc	a0,0x2
ffffffffc020110e:	8a650513          	addi	a0,a0,-1882 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201112:	b0eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201116:	00002697          	auipc	a3,0x2
ffffffffc020111a:	a3268693          	addi	a3,a3,-1486 # ffffffffc0202b48 <commands+0x890>
ffffffffc020111e:	00002617          	auipc	a2,0x2
ffffffffc0201122:	87a60613          	addi	a2,a2,-1926 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201126:	0fc00593          	li	a1,252
ffffffffc020112a:	00002517          	auipc	a0,0x2
ffffffffc020112e:	88650513          	addi	a0,a0,-1914 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201132:	aeeff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201136:	00002697          	auipc	a3,0x2
ffffffffc020113a:	90268693          	addi	a3,a3,-1790 # ffffffffc0202a38 <commands+0x780>
ffffffffc020113e:	00002617          	auipc	a2,0x2
ffffffffc0201142:	85a60613          	addi	a2,a2,-1958 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201146:	0de00593          	li	a1,222
ffffffffc020114a:	00002517          	auipc	a0,0x2
ffffffffc020114e:	86650513          	addi	a0,a0,-1946 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201152:	aceff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(total == 0);
ffffffffc0201156:	00002697          	auipc	a3,0x2
ffffffffc020115a:	b2268693          	addi	a3,a3,-1246 # ffffffffc0202c78 <commands+0x9c0>
ffffffffc020115e:	00002617          	auipc	a2,0x2
ffffffffc0201162:	83a60613          	addi	a2,a2,-1990 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201166:	15600593          	li	a1,342
ffffffffc020116a:	00002517          	auipc	a0,0x2
ffffffffc020116e:	84650513          	addi	a0,a0,-1978 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201172:	aaeff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201176:	00002697          	auipc	a3,0x2
ffffffffc020117a:	86268693          	addi	a3,a3,-1950 # ffffffffc02029d8 <commands+0x720>
ffffffffc020117e:	00002617          	auipc	a2,0x2
ffffffffc0201182:	81a60613          	addi	a2,a2,-2022 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201186:	11700593          	li	a1,279
ffffffffc020118a:	00002517          	auipc	a0,0x2
ffffffffc020118e:	82650513          	addi	a0,a0,-2010 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201192:	a8eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201196:	00002697          	auipc	a3,0x2
ffffffffc020119a:	88268693          	addi	a3,a3,-1918 # ffffffffc0202a18 <commands+0x760>
ffffffffc020119e:	00001617          	auipc	a2,0x1
ffffffffc02011a2:	7fa60613          	addi	a2,a2,2042 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02011a6:	0dd00593          	li	a1,221
ffffffffc02011aa:	00002517          	auipc	a0,0x2
ffffffffc02011ae:	80650513          	addi	a0,a0,-2042 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02011b2:	a6eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011b6:	00002697          	auipc	a3,0x2
ffffffffc02011ba:	84268693          	addi	a3,a3,-1982 # ffffffffc02029f8 <commands+0x740>
ffffffffc02011be:	00001617          	auipc	a2,0x1
ffffffffc02011c2:	7da60613          	addi	a2,a2,2010 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02011c6:	0dc00593          	li	a1,220
ffffffffc02011ca:	00001517          	auipc	a0,0x1
ffffffffc02011ce:	7e650513          	addi	a0,a0,2022 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02011d2:	a4eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d6:	00002697          	auipc	a3,0x2
ffffffffc02011da:	94a68693          	addi	a3,a3,-1718 # ffffffffc0202b20 <commands+0x868>
ffffffffc02011de:	00001617          	auipc	a2,0x1
ffffffffc02011e2:	7ba60613          	addi	a2,a2,1978 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02011e6:	0f900593          	li	a1,249
ffffffffc02011ea:	00001517          	auipc	a0,0x1
ffffffffc02011ee:	7c650513          	addi	a0,a0,1990 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02011f2:	a2eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02011f6:	00002697          	auipc	a3,0x2
ffffffffc02011fa:	84268693          	addi	a3,a3,-1982 # ffffffffc0202a38 <commands+0x780>
ffffffffc02011fe:	00001617          	auipc	a2,0x1
ffffffffc0201202:	79a60613          	addi	a2,a2,1946 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201206:	0f700593          	li	a1,247
ffffffffc020120a:	00001517          	auipc	a0,0x1
ffffffffc020120e:	7a650513          	addi	a0,a0,1958 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201212:	a0eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201216:	00002697          	auipc	a3,0x2
ffffffffc020121a:	80268693          	addi	a3,a3,-2046 # ffffffffc0202a18 <commands+0x760>
ffffffffc020121e:	00001617          	auipc	a2,0x1
ffffffffc0201222:	77a60613          	addi	a2,a2,1914 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201226:	0f600593          	li	a1,246
ffffffffc020122a:	00001517          	auipc	a0,0x1
ffffffffc020122e:	78650513          	addi	a0,a0,1926 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201232:	9eeff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201236:	00001697          	auipc	a3,0x1
ffffffffc020123a:	7c268693          	addi	a3,a3,1986 # ffffffffc02029f8 <commands+0x740>
ffffffffc020123e:	00001617          	auipc	a2,0x1
ffffffffc0201242:	75a60613          	addi	a2,a2,1882 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201246:	0f500593          	li	a1,245
ffffffffc020124a:	00001517          	auipc	a0,0x1
ffffffffc020124e:	76650513          	addi	a0,a0,1894 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201252:	9ceff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(nr_free == 3);
ffffffffc0201256:	00002697          	auipc	a3,0x2
ffffffffc020125a:	8e268693          	addi	a3,a3,-1822 # ffffffffc0202b38 <commands+0x880>
ffffffffc020125e:	00001617          	auipc	a2,0x1
ffffffffc0201262:	73a60613          	addi	a2,a2,1850 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201266:	0f300593          	li	a1,243
ffffffffc020126a:	00001517          	auipc	a0,0x1
ffffffffc020126e:	74650513          	addi	a0,a0,1862 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201272:	9aeff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201276:	00002697          	auipc	a3,0x2
ffffffffc020127a:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0202b20 <commands+0x868>
ffffffffc020127e:	00001617          	auipc	a2,0x1
ffffffffc0201282:	71a60613          	addi	a2,a2,1818 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201286:	0ee00593          	li	a1,238
ffffffffc020128a:	00001517          	auipc	a0,0x1
ffffffffc020128e:	72650513          	addi	a0,a0,1830 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201292:	98eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201296:	00002697          	auipc	a3,0x2
ffffffffc020129a:	86a68693          	addi	a3,a3,-1942 # ffffffffc0202b00 <commands+0x848>
ffffffffc020129e:	00001617          	auipc	a2,0x1
ffffffffc02012a2:	6fa60613          	addi	a2,a2,1786 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02012a6:	0e500593          	li	a1,229
ffffffffc02012aa:	00001517          	auipc	a0,0x1
ffffffffc02012ae:	70650513          	addi	a0,a0,1798 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02012b2:	96eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02012b6:	00002697          	auipc	a3,0x2
ffffffffc02012ba:	82a68693          	addi	a3,a3,-2006 # ffffffffc0202ae0 <commands+0x828>
ffffffffc02012be:	00001617          	auipc	a2,0x1
ffffffffc02012c2:	6da60613          	addi	a2,a2,1754 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02012c6:	0e400593          	li	a1,228
ffffffffc02012ca:	00001517          	auipc	a0,0x1
ffffffffc02012ce:	6e650513          	addi	a0,a0,1766 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02012d2:	94eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(count == 0);
ffffffffc02012d6:	00002697          	auipc	a3,0x2
ffffffffc02012da:	99268693          	addi	a3,a3,-1646 # ffffffffc0202c68 <commands+0x9b0>
ffffffffc02012de:	00001617          	auipc	a2,0x1
ffffffffc02012e2:	6ba60613          	addi	a2,a2,1722 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02012e6:	15500593          	li	a1,341
ffffffffc02012ea:	00001517          	auipc	a0,0x1
ffffffffc02012ee:	6c650513          	addi	a0,a0,1734 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02012f2:	92eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(nr_free == 0);
ffffffffc02012f6:	00002697          	auipc	a3,0x2
ffffffffc02012fa:	88a68693          	addi	a3,a3,-1910 # ffffffffc0202b80 <commands+0x8c8>
ffffffffc02012fe:	00001617          	auipc	a2,0x1
ffffffffc0201302:	69a60613          	addi	a2,a2,1690 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201306:	14a00593          	li	a1,330
ffffffffc020130a:	00001517          	auipc	a0,0x1
ffffffffc020130e:	6a650513          	addi	a0,a0,1702 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201312:	90eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201316:	00002697          	auipc	a3,0x2
ffffffffc020131a:	80a68693          	addi	a3,a3,-2038 # ffffffffc0202b20 <commands+0x868>
ffffffffc020131e:	00001617          	auipc	a2,0x1
ffffffffc0201322:	67a60613          	addi	a2,a2,1658 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201326:	14400593          	li	a1,324
ffffffffc020132a:	00001517          	auipc	a0,0x1
ffffffffc020132e:	68650513          	addi	a0,a0,1670 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201332:	8eeff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201336:	00002697          	auipc	a3,0x2
ffffffffc020133a:	91268693          	addi	a3,a3,-1774 # ffffffffc0202c48 <commands+0x990>
ffffffffc020133e:	00001617          	auipc	a2,0x1
ffffffffc0201342:	65a60613          	addi	a2,a2,1626 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201346:	14300593          	li	a1,323
ffffffffc020134a:	00001517          	auipc	a0,0x1
ffffffffc020134e:	66650513          	addi	a0,a0,1638 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201352:	8ceff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0201356:	00002697          	auipc	a3,0x2
ffffffffc020135a:	8e268693          	addi	a3,a3,-1822 # ffffffffc0202c38 <commands+0x980>
ffffffffc020135e:	00001617          	auipc	a2,0x1
ffffffffc0201362:	63a60613          	addi	a2,a2,1594 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201366:	13b00593          	li	a1,315
ffffffffc020136a:	00001517          	auipc	a0,0x1
ffffffffc020136e:	64650513          	addi	a0,a0,1606 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201372:	8aeff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201376:	00002697          	auipc	a3,0x2
ffffffffc020137a:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0202c20 <commands+0x968>
ffffffffc020137e:	00001617          	auipc	a2,0x1
ffffffffc0201382:	61a60613          	addi	a2,a2,1562 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201386:	13a00593          	li	a1,314
ffffffffc020138a:	00001517          	auipc	a0,0x1
ffffffffc020138e:	62650513          	addi	a0,a0,1574 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201392:	88eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201396:	00002697          	auipc	a3,0x2
ffffffffc020139a:	86a68693          	addi	a3,a3,-1942 # ffffffffc0202c00 <commands+0x948>
ffffffffc020139e:	00001617          	auipc	a2,0x1
ffffffffc02013a2:	5fa60613          	addi	a2,a2,1530 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02013a6:	13900593          	li	a1,313
ffffffffc02013aa:	00001517          	auipc	a0,0x1
ffffffffc02013ae:	60650513          	addi	a0,a0,1542 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02013b2:	86eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02013b6:	00002697          	auipc	a3,0x2
ffffffffc02013ba:	81a68693          	addi	a3,a3,-2022 # ffffffffc0202bd0 <commands+0x918>
ffffffffc02013be:	00001617          	auipc	a2,0x1
ffffffffc02013c2:	5da60613          	addi	a2,a2,1498 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02013c6:	13700593          	li	a1,311
ffffffffc02013ca:	00001517          	auipc	a0,0x1
ffffffffc02013ce:	5e650513          	addi	a0,a0,1510 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02013d2:	84eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02013d6:	00001697          	auipc	a3,0x1
ffffffffc02013da:	7e268693          	addi	a3,a3,2018 # ffffffffc0202bb8 <commands+0x900>
ffffffffc02013de:	00001617          	auipc	a2,0x1
ffffffffc02013e2:	5ba60613          	addi	a2,a2,1466 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02013e6:	13600593          	li	a1,310
ffffffffc02013ea:	00001517          	auipc	a0,0x1
ffffffffc02013ee:	5c650513          	addi	a0,a0,1478 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02013f2:	82eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013f6:	00001697          	auipc	a3,0x1
ffffffffc02013fa:	72a68693          	addi	a3,a3,1834 # ffffffffc0202b20 <commands+0x868>
ffffffffc02013fe:	00001617          	auipc	a2,0x1
ffffffffc0201402:	59a60613          	addi	a2,a2,1434 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201406:	12a00593          	li	a1,298
ffffffffc020140a:	00001517          	auipc	a0,0x1
ffffffffc020140e:	5a650513          	addi	a0,a0,1446 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201412:	80eff0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201416:	00001697          	auipc	a3,0x1
ffffffffc020141a:	78a68693          	addi	a3,a3,1930 # ffffffffc0202ba0 <commands+0x8e8>
ffffffffc020141e:	00001617          	auipc	a2,0x1
ffffffffc0201422:	57a60613          	addi	a2,a2,1402 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201426:	12100593          	li	a1,289
ffffffffc020142a:	00001517          	auipc	a0,0x1
ffffffffc020142e:	58650513          	addi	a0,a0,1414 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201432:	feffe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(p0 != NULL);
ffffffffc0201436:	00001697          	auipc	a3,0x1
ffffffffc020143a:	75a68693          	addi	a3,a3,1882 # ffffffffc0202b90 <commands+0x8d8>
ffffffffc020143e:	00001617          	auipc	a2,0x1
ffffffffc0201442:	55a60613          	addi	a2,a2,1370 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201446:	12000593          	li	a1,288
ffffffffc020144a:	00001517          	auipc	a0,0x1
ffffffffc020144e:	56650513          	addi	a0,a0,1382 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201452:	fcffe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(nr_free == 0);
ffffffffc0201456:	00001697          	auipc	a3,0x1
ffffffffc020145a:	72a68693          	addi	a3,a3,1834 # ffffffffc0202b80 <commands+0x8c8>
ffffffffc020145e:	00001617          	auipc	a2,0x1
ffffffffc0201462:	53a60613          	addi	a2,a2,1338 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201466:	10200593          	li	a1,258
ffffffffc020146a:	00001517          	auipc	a0,0x1
ffffffffc020146e:	54650513          	addi	a0,a0,1350 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201472:	faffe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201476:	00001697          	auipc	a3,0x1
ffffffffc020147a:	6aa68693          	addi	a3,a3,1706 # ffffffffc0202b20 <commands+0x868>
ffffffffc020147e:	00001617          	auipc	a2,0x1
ffffffffc0201482:	51a60613          	addi	a2,a2,1306 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201486:	10000593          	li	a1,256
ffffffffc020148a:	00001517          	auipc	a0,0x1
ffffffffc020148e:	52650513          	addi	a0,a0,1318 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc0201492:	f8ffe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201496:	00001697          	auipc	a3,0x1
ffffffffc020149a:	6ca68693          	addi	a3,a3,1738 # ffffffffc0202b60 <commands+0x8a8>
ffffffffc020149e:	00001617          	auipc	a2,0x1
ffffffffc02014a2:	4fa60613          	addi	a2,a2,1274 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02014a6:	0ff00593          	li	a1,255
ffffffffc02014aa:	00001517          	auipc	a0,0x1
ffffffffc02014ae:	50650513          	addi	a0,a0,1286 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02014b2:	f6ffe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc02014b6 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02014b6:	1141                	addi	sp,sp,-16
ffffffffc02014b8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014ba:	14058a63          	beqz	a1,ffffffffc020160e <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02014be:	00259693          	slli	a3,a1,0x2
ffffffffc02014c2:	96ae                	add	a3,a3,a1
ffffffffc02014c4:	068e                	slli	a3,a3,0x3
ffffffffc02014c6:	96aa                	add	a3,a3,a0
ffffffffc02014c8:	87aa                	mv	a5,a0
ffffffffc02014ca:	02d50263          	beq	a0,a3,ffffffffc02014ee <best_fit_free_pages+0x38>
ffffffffc02014ce:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014d0:	8b05                	andi	a4,a4,1
ffffffffc02014d2:	10071e63          	bnez	a4,ffffffffc02015ee <best_fit_free_pages+0x138>
ffffffffc02014d6:	6798                	ld	a4,8(a5)
ffffffffc02014d8:	8b09                	andi	a4,a4,2
ffffffffc02014da:	10071a63          	bnez	a4,ffffffffc02015ee <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc02014de:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02014e2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014e6:	02878793          	addi	a5,a5,40
ffffffffc02014ea:	fed792e3          	bne	a5,a3,ffffffffc02014ce <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc02014ee:	2581                	sext.w	a1,a1
ffffffffc02014f0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02014f2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014f6:	4789                	li	a5,2
ffffffffc02014f8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02014fc:	00006697          	auipc	a3,0x6
ffffffffc0201500:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0207028 <free_area>
ffffffffc0201504:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201506:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201508:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020150c:	9db9                	addw	a1,a1,a4
ffffffffc020150e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201510:	0ad78863          	beq	a5,a3,ffffffffc02015c0 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201514:	fe878713          	addi	a4,a5,-24
ffffffffc0201518:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020151c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020151e:	00e56a63          	bltu	a0,a4,ffffffffc0201532 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0201522:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201524:	06d70263          	beq	a4,a3,ffffffffc0201588 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201528:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020152a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020152e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201522 <best_fit_free_pages+0x6c>
ffffffffc0201532:	c199                	beqz	a1,ffffffffc0201538 <best_fit_free_pages+0x82>
ffffffffc0201534:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201538:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020153a:	e390                	sd	a2,0(a5)
ffffffffc020153c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020153e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201540:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201542:	02d70063          	beq	a4,a3,ffffffffc0201562 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201546:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020154a:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc020154e:	02081613          	slli	a2,a6,0x20
ffffffffc0201552:	9201                	srli	a2,a2,0x20
ffffffffc0201554:	00261793          	slli	a5,a2,0x2
ffffffffc0201558:	97b2                	add	a5,a5,a2
ffffffffc020155a:	078e                	slli	a5,a5,0x3
ffffffffc020155c:	97ae                	add	a5,a5,a1
ffffffffc020155e:	02f50f63          	beq	a0,a5,ffffffffc020159c <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0201562:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201564:	00d70f63          	beq	a4,a3,ffffffffc0201582 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201568:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc020156a:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020156e:	02059613          	slli	a2,a1,0x20
ffffffffc0201572:	9201                	srli	a2,a2,0x20
ffffffffc0201574:	00261793          	slli	a5,a2,0x2
ffffffffc0201578:	97b2                	add	a5,a5,a2
ffffffffc020157a:	078e                	slli	a5,a5,0x3
ffffffffc020157c:	97aa                	add	a5,a5,a0
ffffffffc020157e:	04f68863          	beq	a3,a5,ffffffffc02015ce <best_fit_free_pages+0x118>
}
ffffffffc0201582:	60a2                	ld	ra,8(sp)
ffffffffc0201584:	0141                	addi	sp,sp,16
ffffffffc0201586:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201588:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020158a:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020158c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020158e:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201590:	02d70563          	beq	a4,a3,ffffffffc02015ba <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201594:	8832                	mv	a6,a2
ffffffffc0201596:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201598:	87ba                	mv	a5,a4
ffffffffc020159a:	bf41                	j	ffffffffc020152a <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc020159c:	491c                	lw	a5,16(a0)
ffffffffc020159e:	0107883b          	addw	a6,a5,a6
ffffffffc02015a2:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02015a6:	57f5                	li	a5,-3
ffffffffc02015a8:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015ac:	6d10                	ld	a2,24(a0)
ffffffffc02015ae:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02015b0:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02015b2:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02015b4:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02015b6:	e390                	sd	a2,0(a5)
ffffffffc02015b8:	b775                	j	ffffffffc0201564 <best_fit_free_pages+0xae>
ffffffffc02015ba:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015bc:	873e                	mv	a4,a5
ffffffffc02015be:	b761                	j	ffffffffc0201546 <best_fit_free_pages+0x90>
}
ffffffffc02015c0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015c2:	e390                	sd	a2,0(a5)
ffffffffc02015c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015c8:	ed1c                	sd	a5,24(a0)
ffffffffc02015ca:	0141                	addi	sp,sp,16
ffffffffc02015cc:	8082                	ret
            base->property += p->property;
ffffffffc02015ce:	ff872783          	lw	a5,-8(a4)
ffffffffc02015d2:	ff070693          	addi	a3,a4,-16
ffffffffc02015d6:	9dbd                	addw	a1,a1,a5
ffffffffc02015d8:	c90c                	sw	a1,16(a0)
ffffffffc02015da:	57f5                	li	a5,-3
ffffffffc02015dc:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015e0:	6314                	ld	a3,0(a4)
ffffffffc02015e2:	671c                	ld	a5,8(a4)
}
ffffffffc02015e4:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02015e6:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02015e8:	e394                	sd	a3,0(a5)
ffffffffc02015ea:	0141                	addi	sp,sp,16
ffffffffc02015ec:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015ee:	00001697          	auipc	a3,0x1
ffffffffc02015f2:	69a68693          	addi	a3,a3,1690 # ffffffffc0202c88 <commands+0x9d0>
ffffffffc02015f6:	00001617          	auipc	a2,0x1
ffffffffc02015fa:	3a260613          	addi	a2,a2,930 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02015fe:	09a00593          	li	a1,154
ffffffffc0201602:	00001517          	auipc	a0,0x1
ffffffffc0201606:	3ae50513          	addi	a0,a0,942 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc020160a:	e17fe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(n > 0);
ffffffffc020160e:	00001697          	auipc	a3,0x1
ffffffffc0201612:	38268693          	addi	a3,a3,898 # ffffffffc0202990 <commands+0x6d8>
ffffffffc0201616:	00001617          	auipc	a2,0x1
ffffffffc020161a:	38260613          	addi	a2,a2,898 # ffffffffc0202998 <commands+0x6e0>
ffffffffc020161e:	09700593          	li	a1,151
ffffffffc0201622:	00001517          	auipc	a0,0x1
ffffffffc0201626:	38e50513          	addi	a0,a0,910 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc020162a:	df7fe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc020162e <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020162e:	1141                	addi	sp,sp,-16
ffffffffc0201630:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201632:	c9e1                	beqz	a1,ffffffffc0201702 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201634:	00259693          	slli	a3,a1,0x2
ffffffffc0201638:	96ae                	add	a3,a3,a1
ffffffffc020163a:	068e                	slli	a3,a3,0x3
ffffffffc020163c:	96aa                	add	a3,a3,a0
ffffffffc020163e:	87aa                	mv	a5,a0
ffffffffc0201640:	00d50f63          	beq	a0,a3,ffffffffc020165e <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201644:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201646:	8b05                	andi	a4,a4,1
ffffffffc0201648:	cf49                	beqz	a4,ffffffffc02016e2 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc020164a:	0007a823          	sw	zero,16(a5)
ffffffffc020164e:	0007b423          	sd	zero,8(a5)
ffffffffc0201652:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201656:	02878793          	addi	a5,a5,40
ffffffffc020165a:	fed795e3          	bne	a5,a3,ffffffffc0201644 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020165e:	2581                	sext.w	a1,a1
ffffffffc0201660:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201662:	4789                	li	a5,2
ffffffffc0201664:	00850713          	addi	a4,a0,8
ffffffffc0201668:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020166c:	00006697          	auipc	a3,0x6
ffffffffc0201670:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0207028 <free_area>
ffffffffc0201674:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201676:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201678:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020167c:	9db9                	addw	a1,a1,a4
ffffffffc020167e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201680:	04d78a63          	beq	a5,a3,ffffffffc02016d4 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201684:	fe878713          	addi	a4,a5,-24
ffffffffc0201688:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020168c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020168e:	00e56a63          	bltu	a0,a4,ffffffffc02016a2 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201692:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201694:	02d70263          	beq	a4,a3,ffffffffc02016b8 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201698:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020169a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020169e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201692 <best_fit_init_memmap+0x64>
ffffffffc02016a2:	c199                	beqz	a1,ffffffffc02016a8 <best_fit_init_memmap+0x7a>
ffffffffc02016a4:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016a8:	6398                	ld	a4,0(a5)
}
ffffffffc02016aa:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016ac:	e390                	sd	a2,0(a5)
ffffffffc02016ae:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02016b0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016b2:	ed18                	sd	a4,24(a0)
ffffffffc02016b4:	0141                	addi	sp,sp,16
ffffffffc02016b6:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016b8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016ba:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02016bc:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016be:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016c0:	00d70663          	beq	a4,a3,ffffffffc02016cc <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02016c4:	8832                	mv	a6,a2
ffffffffc02016c6:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02016c8:	87ba                	mv	a5,a4
ffffffffc02016ca:	bfc1                	j	ffffffffc020169a <best_fit_init_memmap+0x6c>
}
ffffffffc02016cc:	60a2                	ld	ra,8(sp)
ffffffffc02016ce:	e290                	sd	a2,0(a3)
ffffffffc02016d0:	0141                	addi	sp,sp,16
ffffffffc02016d2:	8082                	ret
ffffffffc02016d4:	60a2                	ld	ra,8(sp)
ffffffffc02016d6:	e390                	sd	a2,0(a5)
ffffffffc02016d8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016da:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016dc:	ed1c                	sd	a5,24(a0)
ffffffffc02016de:	0141                	addi	sp,sp,16
ffffffffc02016e0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02016e2:	00001697          	auipc	a3,0x1
ffffffffc02016e6:	5ce68693          	addi	a3,a3,1486 # ffffffffc0202cb0 <commands+0x9f8>
ffffffffc02016ea:	00001617          	auipc	a2,0x1
ffffffffc02016ee:	2ae60613          	addi	a2,a2,686 # ffffffffc0202998 <commands+0x6e0>
ffffffffc02016f2:	04a00593          	li	a1,74
ffffffffc02016f6:	00001517          	auipc	a0,0x1
ffffffffc02016fa:	2ba50513          	addi	a0,a0,698 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc02016fe:	d23fe0ef          	jal	ra,ffffffffc0200420 <__panic>
    assert(n > 0);
ffffffffc0201702:	00001697          	auipc	a3,0x1
ffffffffc0201706:	28e68693          	addi	a3,a3,654 # ffffffffc0202990 <commands+0x6d8>
ffffffffc020170a:	00001617          	auipc	a2,0x1
ffffffffc020170e:	28e60613          	addi	a2,a2,654 # ffffffffc0202998 <commands+0x6e0>
ffffffffc0201712:	04700593          	li	a1,71
ffffffffc0201716:	00001517          	auipc	a0,0x1
ffffffffc020171a:	29a50513          	addi	a0,a0,666 # ffffffffc02029b0 <commands+0x6f8>
ffffffffc020171e:	d03fe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc0201722 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201722:	100027f3          	csrr	a5,sstatus
ffffffffc0201726:	8b89                	andi	a5,a5,2
ffffffffc0201728:	e799                	bnez	a5,ffffffffc0201736 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020172a:	00006797          	auipc	a5,0x6
ffffffffc020172e:	d4e7b783          	ld	a5,-690(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201732:	6f9c                	ld	a5,24(a5)
ffffffffc0201734:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201736:	1141                	addi	sp,sp,-16
ffffffffc0201738:	e406                	sd	ra,8(sp)
ffffffffc020173a:	e022                	sd	s0,0(sp)
ffffffffc020173c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020173e:	944ff0ef          	jal	ra,ffffffffc0200882 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201742:	00006797          	auipc	a5,0x6
ffffffffc0201746:	d367b783          	ld	a5,-714(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc020174a:	6f9c                	ld	a5,24(a5)
ffffffffc020174c:	8522                	mv	a0,s0
ffffffffc020174e:	9782                	jalr	a5
ffffffffc0201750:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201752:	92aff0ef          	jal	ra,ffffffffc020087c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201756:	60a2                	ld	ra,8(sp)
ffffffffc0201758:	8522                	mv	a0,s0
ffffffffc020175a:	6402                	ld	s0,0(sp)
ffffffffc020175c:	0141                	addi	sp,sp,16
ffffffffc020175e:	8082                	ret

ffffffffc0201760 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201760:	100027f3          	csrr	a5,sstatus
ffffffffc0201764:	8b89                	andi	a5,a5,2
ffffffffc0201766:	e799                	bnez	a5,ffffffffc0201774 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201768:	00006797          	auipc	a5,0x6
ffffffffc020176c:	d107b783          	ld	a5,-752(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0201770:	739c                	ld	a5,32(a5)
ffffffffc0201772:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201774:	1101                	addi	sp,sp,-32
ffffffffc0201776:	ec06                	sd	ra,24(sp)
ffffffffc0201778:	e822                	sd	s0,16(sp)
ffffffffc020177a:	e426                	sd	s1,8(sp)
ffffffffc020177c:	842a                	mv	s0,a0
ffffffffc020177e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201780:	902ff0ef          	jal	ra,ffffffffc0200882 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201784:	00006797          	auipc	a5,0x6
ffffffffc0201788:	cf47b783          	ld	a5,-780(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc020178c:	739c                	ld	a5,32(a5)
ffffffffc020178e:	85a6                	mv	a1,s1
ffffffffc0201790:	8522                	mv	a0,s0
ffffffffc0201792:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201794:	6442                	ld	s0,16(sp)
ffffffffc0201796:	60e2                	ld	ra,24(sp)
ffffffffc0201798:	64a2                	ld	s1,8(sp)
ffffffffc020179a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020179c:	8e0ff06f          	j	ffffffffc020087c <intr_enable>

ffffffffc02017a0 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017a0:	100027f3          	csrr	a5,sstatus
ffffffffc02017a4:	8b89                	andi	a5,a5,2
ffffffffc02017a6:	e799                	bnez	a5,ffffffffc02017b4 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02017a8:	00006797          	auipc	a5,0x6
ffffffffc02017ac:	cd07b783          	ld	a5,-816(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc02017b0:	779c                	ld	a5,40(a5)
ffffffffc02017b2:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02017b4:	1141                	addi	sp,sp,-16
ffffffffc02017b6:	e406                	sd	ra,8(sp)
ffffffffc02017b8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02017ba:	8c8ff0ef          	jal	ra,ffffffffc0200882 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02017be:	00006797          	auipc	a5,0x6
ffffffffc02017c2:	cba7b783          	ld	a5,-838(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc02017c6:	779c                	ld	a5,40(a5)
ffffffffc02017c8:	9782                	jalr	a5
ffffffffc02017ca:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02017cc:	8b0ff0ef          	jal	ra,ffffffffc020087c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017d0:	60a2                	ld	ra,8(sp)
ffffffffc02017d2:	8522                	mv	a0,s0
ffffffffc02017d4:	6402                	ld	s0,0(sp)
ffffffffc02017d6:	0141                	addi	sp,sp,16
ffffffffc02017d8:	8082                	ret

ffffffffc02017da <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02017da:	00001797          	auipc	a5,0x1
ffffffffc02017de:	4fe78793          	addi	a5,a5,1278 # ffffffffc0202cd8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017e2:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02017e4:	7179                	addi	sp,sp,-48
ffffffffc02017e6:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017e8:	00001517          	auipc	a0,0x1
ffffffffc02017ec:	52850513          	addi	a0,a0,1320 # ffffffffc0202d10 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02017f0:	00006417          	auipc	s0,0x6
ffffffffc02017f4:	c8840413          	addi	s0,s0,-888 # ffffffffc0207478 <pmm_manager>
void pmm_init(void) {
ffffffffc02017f8:	f406                	sd	ra,40(sp)
ffffffffc02017fa:	ec26                	sd	s1,24(sp)
ffffffffc02017fc:	e44e                	sd	s3,8(sp)
ffffffffc02017fe:	e84a                	sd	s2,16(sp)
ffffffffc0201800:	e052                	sd	s4,0(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201802:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201804:	923fe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    pmm_manager->init();
ffffffffc0201808:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020180a:	00006497          	auipc	s1,0x6
ffffffffc020180e:	c8648493          	addi	s1,s1,-890 # ffffffffc0207490 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201812:	679c                	ld	a5,8(a5)
ffffffffc0201814:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201816:	57f5                	li	a5,-3
ffffffffc0201818:	07fa                	slli	a5,a5,0x1e
ffffffffc020181a:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc020181c:	84cff0ef          	jal	ra,ffffffffc0200868 <get_memory_base>
ffffffffc0201820:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0201822:	850ff0ef          	jal	ra,ffffffffc0200872 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0201826:	16050163          	beqz	a0,ffffffffc0201988 <pmm_init+0x1ae>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020182a:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc020182c:	00001517          	auipc	a0,0x1
ffffffffc0201830:	52c50513          	addi	a0,a0,1324 # ffffffffc0202d58 <best_fit_pmm_manager+0x80>
ffffffffc0201834:	8f3fe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0201838:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020183c:	864e                	mv	a2,s3
ffffffffc020183e:	fffa0693          	addi	a3,s4,-1
ffffffffc0201842:	85ca                	mv	a1,s2
ffffffffc0201844:	00001517          	auipc	a0,0x1
ffffffffc0201848:	52c50513          	addi	a0,a0,1324 # ffffffffc0202d70 <best_fit_pmm_manager+0x98>
ffffffffc020184c:	8dbfe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0201850:	c80007b7          	lui	a5,0xc8000
ffffffffc0201854:	8652                	mv	a2,s4
ffffffffc0201856:	0d47e863          	bltu	a5,s4,ffffffffc0201926 <pmm_init+0x14c>
ffffffffc020185a:	00007797          	auipc	a5,0x7
ffffffffc020185e:	c4578793          	addi	a5,a5,-955 # ffffffffc020849f <end+0xfff>
ffffffffc0201862:	757d                	lui	a0,0xfffff
ffffffffc0201864:	8d7d                	and	a0,a0,a5
ffffffffc0201866:	8231                	srli	a2,a2,0xc
ffffffffc0201868:	00006597          	auipc	a1,0x6
ffffffffc020186c:	c0058593          	addi	a1,a1,-1024 # ffffffffc0207468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201870:	00006817          	auipc	a6,0x6
ffffffffc0201874:	c0080813          	addi	a6,a6,-1024 # ffffffffc0207470 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201878:	e190                	sd	a2,0(a1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020187a:	00a83023          	sd	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020187e:	000807b7          	lui	a5,0x80
ffffffffc0201882:	02f60663          	beq	a2,a5,ffffffffc02018ae <pmm_init+0xd4>
ffffffffc0201886:	4701                	li	a4,0
ffffffffc0201888:	4781                	li	a5,0
ffffffffc020188a:	4305                	li	t1,1
ffffffffc020188c:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0201890:	953a                	add	a0,a0,a4
ffffffffc0201892:	00850693          	addi	a3,a0,8 # fffffffffffff008 <end+0x3fdf7b68>
ffffffffc0201896:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020189a:	6190                	ld	a2,0(a1)
ffffffffc020189c:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc020189e:	00083503          	ld	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02018a2:	011606b3          	add	a3,a2,a7
ffffffffc02018a6:	02870713          	addi	a4,a4,40
ffffffffc02018aa:	fed7e3e3          	bltu	a5,a3,ffffffffc0201890 <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02018ae:	00261693          	slli	a3,a2,0x2
ffffffffc02018b2:	96b2                	add	a3,a3,a2
ffffffffc02018b4:	fec007b7          	lui	a5,0xfec00
ffffffffc02018b8:	97aa                	add	a5,a5,a0
ffffffffc02018ba:	068e                	slli	a3,a3,0x3
ffffffffc02018bc:	96be                	add	a3,a3,a5
ffffffffc02018be:	c02007b7          	lui	a5,0xc0200
ffffffffc02018c2:	0af6e763          	bltu	a3,a5,ffffffffc0201970 <pmm_init+0x196>
ffffffffc02018c6:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02018c8:	77fd                	lui	a5,0xfffff
ffffffffc02018ca:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02018ce:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02018d0:	04b6ee63          	bltu	a3,a1,ffffffffc020192c <pmm_init+0x152>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02018d4:	601c                	ld	a5,0(s0)
ffffffffc02018d6:	7b9c                	ld	a5,48(a5)
ffffffffc02018d8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02018da:	00001517          	auipc	a0,0x1
ffffffffc02018de:	51e50513          	addi	a0,a0,1310 # ffffffffc0202df8 <best_fit_pmm_manager+0x120>
ffffffffc02018e2:	845fe0ef          	jal	ra,ffffffffc0200126 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02018e6:	00004597          	auipc	a1,0x4
ffffffffc02018ea:	71a58593          	addi	a1,a1,1818 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc02018ee:	00006797          	auipc	a5,0x6
ffffffffc02018f2:	b8b7bd23          	sd	a1,-1126(a5) # ffffffffc0207488 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02018f6:	c02007b7          	lui	a5,0xc0200
ffffffffc02018fa:	0af5e363          	bltu	a1,a5,ffffffffc02019a0 <pmm_init+0x1c6>
ffffffffc02018fe:	6090                	ld	a2,0(s1)
}
ffffffffc0201900:	7402                	ld	s0,32(sp)
ffffffffc0201902:	70a2                	ld	ra,40(sp)
ffffffffc0201904:	64e2                	ld	s1,24(sp)
ffffffffc0201906:	6942                	ld	s2,16(sp)
ffffffffc0201908:	69a2                	ld	s3,8(sp)
ffffffffc020190a:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020190c:	40c58633          	sub	a2,a1,a2
ffffffffc0201910:	00006797          	auipc	a5,0x6
ffffffffc0201914:	b6c7b823          	sd	a2,-1168(a5) # ffffffffc0207480 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201918:	00001517          	auipc	a0,0x1
ffffffffc020191c:	50050513          	addi	a0,a0,1280 # ffffffffc0202e18 <best_fit_pmm_manager+0x140>
}
ffffffffc0201920:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201922:	805fe06f          	j	ffffffffc0200126 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0201926:	c8000637          	lui	a2,0xc8000
ffffffffc020192a:	bf05                	j	ffffffffc020185a <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020192c:	6705                	lui	a4,0x1
ffffffffc020192e:	177d                	addi	a4,a4,-1
ffffffffc0201930:	96ba                	add	a3,a3,a4
ffffffffc0201932:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201934:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201938:	02c7f063          	bgeu	a5,a2,ffffffffc0201958 <pmm_init+0x17e>
    pmm_manager->init_memmap(base, n);
ffffffffc020193c:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020193e:	fff80737          	lui	a4,0xfff80
ffffffffc0201942:	973e                	add	a4,a4,a5
ffffffffc0201944:	00271793          	slli	a5,a4,0x2
ffffffffc0201948:	97ba                	add	a5,a5,a4
ffffffffc020194a:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020194c:	8d95                	sub	a1,a1,a3
ffffffffc020194e:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201950:	81b1                	srli	a1,a1,0xc
ffffffffc0201952:	953e                	add	a0,a0,a5
ffffffffc0201954:	9702                	jalr	a4
}
ffffffffc0201956:	bfbd                	j	ffffffffc02018d4 <pmm_init+0xfa>
        panic("pa2page called with invalid pa");
ffffffffc0201958:	00001617          	auipc	a2,0x1
ffffffffc020195c:	47060613          	addi	a2,a2,1136 # ffffffffc0202dc8 <best_fit_pmm_manager+0xf0>
ffffffffc0201960:	06b00593          	li	a1,107
ffffffffc0201964:	00001517          	auipc	a0,0x1
ffffffffc0201968:	48450513          	addi	a0,a0,1156 # ffffffffc0202de8 <best_fit_pmm_manager+0x110>
ffffffffc020196c:	ab5fe0ef          	jal	ra,ffffffffc0200420 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201970:	00001617          	auipc	a2,0x1
ffffffffc0201974:	43060613          	addi	a2,a2,1072 # ffffffffc0202da0 <best_fit_pmm_manager+0xc8>
ffffffffc0201978:	07100593          	li	a1,113
ffffffffc020197c:	00001517          	auipc	a0,0x1
ffffffffc0201980:	3cc50513          	addi	a0,a0,972 # ffffffffc0202d48 <best_fit_pmm_manager+0x70>
ffffffffc0201984:	a9dfe0ef          	jal	ra,ffffffffc0200420 <__panic>
        panic("DTB memory info not available");
ffffffffc0201988:	00001617          	auipc	a2,0x1
ffffffffc020198c:	3a060613          	addi	a2,a2,928 # ffffffffc0202d28 <best_fit_pmm_manager+0x50>
ffffffffc0201990:	05a00593          	li	a1,90
ffffffffc0201994:	00001517          	auipc	a0,0x1
ffffffffc0201998:	3b450513          	addi	a0,a0,948 # ffffffffc0202d48 <best_fit_pmm_manager+0x70>
ffffffffc020199c:	a85fe0ef          	jal	ra,ffffffffc0200420 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02019a0:	86ae                	mv	a3,a1
ffffffffc02019a2:	00001617          	auipc	a2,0x1
ffffffffc02019a6:	3fe60613          	addi	a2,a2,1022 # ffffffffc0202da0 <best_fit_pmm_manager+0xc8>
ffffffffc02019aa:	08c00593          	li	a1,140
ffffffffc02019ae:	00001517          	auipc	a0,0x1
ffffffffc02019b2:	39a50513          	addi	a0,a0,922 # ffffffffc0202d48 <best_fit_pmm_manager+0x70>
ffffffffc02019b6:	a6bfe0ef          	jal	ra,ffffffffc0200420 <__panic>

ffffffffc02019ba <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02019ba:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019be:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02019c0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019c4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02019c6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019ca:	f022                	sd	s0,32(sp)
ffffffffc02019cc:	ec26                	sd	s1,24(sp)
ffffffffc02019ce:	e84a                	sd	s2,16(sp)
ffffffffc02019d0:	f406                	sd	ra,40(sp)
ffffffffc02019d2:	e44e                	sd	s3,8(sp)
ffffffffc02019d4:	84aa                	mv	s1,a0
ffffffffc02019d6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02019d8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02019dc:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02019de:	03067e63          	bgeu	a2,a6,ffffffffc0201a1a <printnum+0x60>
ffffffffc02019e2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02019e4:	00805763          	blez	s0,ffffffffc02019f2 <printnum+0x38>
ffffffffc02019e8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02019ea:	85ca                	mv	a1,s2
ffffffffc02019ec:	854e                	mv	a0,s3
ffffffffc02019ee:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02019f0:	fc65                	bnez	s0,ffffffffc02019e8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019f2:	1a02                	slli	s4,s4,0x20
ffffffffc02019f4:	00001797          	auipc	a5,0x1
ffffffffc02019f8:	46478793          	addi	a5,a5,1124 # ffffffffc0202e58 <best_fit_pmm_manager+0x180>
ffffffffc02019fc:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201a00:	9a3e                	add	s4,s4,a5
}
ffffffffc0201a02:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a04:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201a08:	70a2                	ld	ra,40(sp)
ffffffffc0201a0a:	69a2                	ld	s3,8(sp)
ffffffffc0201a0c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a0e:	85ca                	mv	a1,s2
ffffffffc0201a10:	87a6                	mv	a5,s1
}
ffffffffc0201a12:	6942                	ld	s2,16(sp)
ffffffffc0201a14:	64e2                	ld	s1,24(sp)
ffffffffc0201a16:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a18:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201a1a:	03065633          	divu	a2,a2,a6
ffffffffc0201a1e:	8722                	mv	a4,s0
ffffffffc0201a20:	f9bff0ef          	jal	ra,ffffffffc02019ba <printnum>
ffffffffc0201a24:	b7f9                	j	ffffffffc02019f2 <printnum+0x38>

ffffffffc0201a26 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201a26:	7119                	addi	sp,sp,-128
ffffffffc0201a28:	f4a6                	sd	s1,104(sp)
ffffffffc0201a2a:	f0ca                	sd	s2,96(sp)
ffffffffc0201a2c:	ecce                	sd	s3,88(sp)
ffffffffc0201a2e:	e8d2                	sd	s4,80(sp)
ffffffffc0201a30:	e4d6                	sd	s5,72(sp)
ffffffffc0201a32:	e0da                	sd	s6,64(sp)
ffffffffc0201a34:	fc5e                	sd	s7,56(sp)
ffffffffc0201a36:	f06a                	sd	s10,32(sp)
ffffffffc0201a38:	fc86                	sd	ra,120(sp)
ffffffffc0201a3a:	f8a2                	sd	s0,112(sp)
ffffffffc0201a3c:	f862                	sd	s8,48(sp)
ffffffffc0201a3e:	f466                	sd	s9,40(sp)
ffffffffc0201a40:	ec6e                	sd	s11,24(sp)
ffffffffc0201a42:	892a                	mv	s2,a0
ffffffffc0201a44:	84ae                	mv	s1,a1
ffffffffc0201a46:	8d32                	mv	s10,a2
ffffffffc0201a48:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a4a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201a4e:	5b7d                	li	s6,-1
ffffffffc0201a50:	00001a97          	auipc	s5,0x1
ffffffffc0201a54:	43ca8a93          	addi	s5,s5,1084 # ffffffffc0202e8c <best_fit_pmm_manager+0x1b4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a58:	00001b97          	auipc	s7,0x1
ffffffffc0201a5c:	610b8b93          	addi	s7,s7,1552 # ffffffffc0203068 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a60:	000d4503          	lbu	a0,0(s10)
ffffffffc0201a64:	001d0413          	addi	s0,s10,1
ffffffffc0201a68:	01350a63          	beq	a0,s3,ffffffffc0201a7c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201a6c:	c121                	beqz	a0,ffffffffc0201aac <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201a6e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a70:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201a72:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a74:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201a78:	ff351ae3          	bne	a0,s3,ffffffffc0201a6c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a7c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201a80:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201a84:	4c81                	li	s9,0
ffffffffc0201a86:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201a88:	5c7d                	li	s8,-1
ffffffffc0201a8a:	5dfd                	li	s11,-1
ffffffffc0201a8c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201a90:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a92:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201a96:	0ff5f593          	zext.b	a1,a1
ffffffffc0201a9a:	00140d13          	addi	s10,s0,1
ffffffffc0201a9e:	04b56263          	bltu	a0,a1,ffffffffc0201ae2 <vprintfmt+0xbc>
ffffffffc0201aa2:	058a                	slli	a1,a1,0x2
ffffffffc0201aa4:	95d6                	add	a1,a1,s5
ffffffffc0201aa6:	4194                	lw	a3,0(a1)
ffffffffc0201aa8:	96d6                	add	a3,a3,s5
ffffffffc0201aaa:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201aac:	70e6                	ld	ra,120(sp)
ffffffffc0201aae:	7446                	ld	s0,112(sp)
ffffffffc0201ab0:	74a6                	ld	s1,104(sp)
ffffffffc0201ab2:	7906                	ld	s2,96(sp)
ffffffffc0201ab4:	69e6                	ld	s3,88(sp)
ffffffffc0201ab6:	6a46                	ld	s4,80(sp)
ffffffffc0201ab8:	6aa6                	ld	s5,72(sp)
ffffffffc0201aba:	6b06                	ld	s6,64(sp)
ffffffffc0201abc:	7be2                	ld	s7,56(sp)
ffffffffc0201abe:	7c42                	ld	s8,48(sp)
ffffffffc0201ac0:	7ca2                	ld	s9,40(sp)
ffffffffc0201ac2:	7d02                	ld	s10,32(sp)
ffffffffc0201ac4:	6de2                	ld	s11,24(sp)
ffffffffc0201ac6:	6109                	addi	sp,sp,128
ffffffffc0201ac8:	8082                	ret
            padc = '0';
ffffffffc0201aca:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201acc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ad0:	846a                	mv	s0,s10
ffffffffc0201ad2:	00140d13          	addi	s10,s0,1
ffffffffc0201ad6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201ada:	0ff5f593          	zext.b	a1,a1
ffffffffc0201ade:	fcb572e3          	bgeu	a0,a1,ffffffffc0201aa2 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201ae2:	85a6                	mv	a1,s1
ffffffffc0201ae4:	02500513          	li	a0,37
ffffffffc0201ae8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201aea:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201aee:	8d22                	mv	s10,s0
ffffffffc0201af0:	f73788e3          	beq	a5,s3,ffffffffc0201a60 <vprintfmt+0x3a>
ffffffffc0201af4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201af8:	1d7d                	addi	s10,s10,-1
ffffffffc0201afa:	ff379de3          	bne	a5,s3,ffffffffc0201af4 <vprintfmt+0xce>
ffffffffc0201afe:	b78d                	j	ffffffffc0201a60 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201b00:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201b04:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b08:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201b0a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201b0e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201b12:	02d86463          	bltu	a6,a3,ffffffffc0201b3a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201b16:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201b1a:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201b1e:	0186873b          	addw	a4,a3,s8
ffffffffc0201b22:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201b26:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201b28:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201b2c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201b2e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201b32:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201b36:	fed870e3          	bgeu	a6,a3,ffffffffc0201b16 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201b3a:	f40ddce3          	bgez	s11,ffffffffc0201a92 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201b3e:	8de2                	mv	s11,s8
ffffffffc0201b40:	5c7d                	li	s8,-1
ffffffffc0201b42:	bf81                	j	ffffffffc0201a92 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201b44:	fffdc693          	not	a3,s11
ffffffffc0201b48:	96fd                	srai	a3,a3,0x3f
ffffffffc0201b4a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b4e:	00144603          	lbu	a2,1(s0)
ffffffffc0201b52:	2d81                	sext.w	s11,s11
ffffffffc0201b54:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b56:	bf35                	j	ffffffffc0201a92 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201b58:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b5c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201b60:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b62:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201b64:	bfd9                	j	ffffffffc0201b3a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201b66:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b68:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b6c:	01174463          	blt	a4,a7,ffffffffc0201b74 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201b70:	1a088e63          	beqz	a7,ffffffffc0201d2c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201b74:	000a3603          	ld	a2,0(s4)
ffffffffc0201b78:	46c1                	li	a3,16
ffffffffc0201b7a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201b7c:	2781                	sext.w	a5,a5
ffffffffc0201b7e:	876e                	mv	a4,s11
ffffffffc0201b80:	85a6                	mv	a1,s1
ffffffffc0201b82:	854a                	mv	a0,s2
ffffffffc0201b84:	e37ff0ef          	jal	ra,ffffffffc02019ba <printnum>
            break;
ffffffffc0201b88:	bde1                	j	ffffffffc0201a60 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201b8a:	000a2503          	lw	a0,0(s4)
ffffffffc0201b8e:	85a6                	mv	a1,s1
ffffffffc0201b90:	0a21                	addi	s4,s4,8
ffffffffc0201b92:	9902                	jalr	s2
            break;
ffffffffc0201b94:	b5f1                	j	ffffffffc0201a60 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201b96:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b98:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b9c:	01174463          	blt	a4,a7,ffffffffc0201ba4 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201ba0:	18088163          	beqz	a7,ffffffffc0201d22 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201ba4:	000a3603          	ld	a2,0(s4)
ffffffffc0201ba8:	46a9                	li	a3,10
ffffffffc0201baa:	8a2e                	mv	s4,a1
ffffffffc0201bac:	bfc1                	j	ffffffffc0201b7c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bae:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201bb2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bb4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201bb6:	bdf1                	j	ffffffffc0201a92 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201bb8:	85a6                	mv	a1,s1
ffffffffc0201bba:	02500513          	li	a0,37
ffffffffc0201bbe:	9902                	jalr	s2
            break;
ffffffffc0201bc0:	b545                	j	ffffffffc0201a60 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bc2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201bc6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bc8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201bca:	b5e1                	j	ffffffffc0201a92 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201bcc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201bce:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201bd2:	01174463          	blt	a4,a7,ffffffffc0201bda <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201bd6:	14088163          	beqz	a7,ffffffffc0201d18 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201bda:	000a3603          	ld	a2,0(s4)
ffffffffc0201bde:	46a1                	li	a3,8
ffffffffc0201be0:	8a2e                	mv	s4,a1
ffffffffc0201be2:	bf69                	j	ffffffffc0201b7c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201be4:	03000513          	li	a0,48
ffffffffc0201be8:	85a6                	mv	a1,s1
ffffffffc0201bea:	e03e                	sd	a5,0(sp)
ffffffffc0201bec:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201bee:	85a6                	mv	a1,s1
ffffffffc0201bf0:	07800513          	li	a0,120
ffffffffc0201bf4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201bf6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201bf8:	6782                	ld	a5,0(sp)
ffffffffc0201bfa:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201bfc:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201c00:	bfb5                	j	ffffffffc0201b7c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c02:	000a3403          	ld	s0,0(s4)
ffffffffc0201c06:	008a0713          	addi	a4,s4,8
ffffffffc0201c0a:	e03a                	sd	a4,0(sp)
ffffffffc0201c0c:	14040263          	beqz	s0,ffffffffc0201d50 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201c10:	0fb05763          	blez	s11,ffffffffc0201cfe <vprintfmt+0x2d8>
ffffffffc0201c14:	02d00693          	li	a3,45
ffffffffc0201c18:	0cd79163          	bne	a5,a3,ffffffffc0201cda <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c1c:	00044783          	lbu	a5,0(s0)
ffffffffc0201c20:	0007851b          	sext.w	a0,a5
ffffffffc0201c24:	cf85                	beqz	a5,ffffffffc0201c5c <vprintfmt+0x236>
ffffffffc0201c26:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c2a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c2e:	000c4563          	bltz	s8,ffffffffc0201c38 <vprintfmt+0x212>
ffffffffc0201c32:	3c7d                	addiw	s8,s8,-1
ffffffffc0201c34:	036c0263          	beq	s8,s6,ffffffffc0201c58 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201c38:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c3a:	0e0c8e63          	beqz	s9,ffffffffc0201d36 <vprintfmt+0x310>
ffffffffc0201c3e:	3781                	addiw	a5,a5,-32
ffffffffc0201c40:	0ef47b63          	bgeu	s0,a5,ffffffffc0201d36 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201c44:	03f00513          	li	a0,63
ffffffffc0201c48:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c4a:	000a4783          	lbu	a5,0(s4)
ffffffffc0201c4e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201c50:	0a05                	addi	s4,s4,1
ffffffffc0201c52:	0007851b          	sext.w	a0,a5
ffffffffc0201c56:	ffe1                	bnez	a5,ffffffffc0201c2e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201c58:	01b05963          	blez	s11,ffffffffc0201c6a <vprintfmt+0x244>
ffffffffc0201c5c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201c5e:	85a6                	mv	a1,s1
ffffffffc0201c60:	02000513          	li	a0,32
ffffffffc0201c64:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201c66:	fe0d9be3          	bnez	s11,ffffffffc0201c5c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c6a:	6a02                	ld	s4,0(sp)
ffffffffc0201c6c:	bbd5                	j	ffffffffc0201a60 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c6e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c70:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201c74:	01174463          	blt	a4,a7,ffffffffc0201c7c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201c78:	08088d63          	beqz	a7,ffffffffc0201d12 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201c7c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201c80:	0a044d63          	bltz	s0,ffffffffc0201d3a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201c84:	8622                	mv	a2,s0
ffffffffc0201c86:	8a66                	mv	s4,s9
ffffffffc0201c88:	46a9                	li	a3,10
ffffffffc0201c8a:	bdcd                	j	ffffffffc0201b7c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201c8c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c90:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201c92:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201c94:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201c98:	8fb5                	xor	a5,a5,a3
ffffffffc0201c9a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c9e:	02d74163          	blt	a4,a3,ffffffffc0201cc0 <vprintfmt+0x29a>
ffffffffc0201ca2:	00369793          	slli	a5,a3,0x3
ffffffffc0201ca6:	97de                	add	a5,a5,s7
ffffffffc0201ca8:	639c                	ld	a5,0(a5)
ffffffffc0201caa:	cb99                	beqz	a5,ffffffffc0201cc0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201cac:	86be                	mv	a3,a5
ffffffffc0201cae:	00001617          	auipc	a2,0x1
ffffffffc0201cb2:	1da60613          	addi	a2,a2,474 # ffffffffc0202e88 <best_fit_pmm_manager+0x1b0>
ffffffffc0201cb6:	85a6                	mv	a1,s1
ffffffffc0201cb8:	854a                	mv	a0,s2
ffffffffc0201cba:	0ce000ef          	jal	ra,ffffffffc0201d88 <printfmt>
ffffffffc0201cbe:	b34d                	j	ffffffffc0201a60 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201cc0:	00001617          	auipc	a2,0x1
ffffffffc0201cc4:	1b860613          	addi	a2,a2,440 # ffffffffc0202e78 <best_fit_pmm_manager+0x1a0>
ffffffffc0201cc8:	85a6                	mv	a1,s1
ffffffffc0201cca:	854a                	mv	a0,s2
ffffffffc0201ccc:	0bc000ef          	jal	ra,ffffffffc0201d88 <printfmt>
ffffffffc0201cd0:	bb41                	j	ffffffffc0201a60 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201cd2:	00001417          	auipc	s0,0x1
ffffffffc0201cd6:	19e40413          	addi	s0,s0,414 # ffffffffc0202e70 <best_fit_pmm_manager+0x198>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cda:	85e2                	mv	a1,s8
ffffffffc0201cdc:	8522                	mv	a0,s0
ffffffffc0201cde:	e43e                	sd	a5,8(sp)
ffffffffc0201ce0:	200000ef          	jal	ra,ffffffffc0201ee0 <strnlen>
ffffffffc0201ce4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201ce8:	01b05b63          	blez	s11,ffffffffc0201cfe <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201cec:	67a2                	ld	a5,8(sp)
ffffffffc0201cee:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cf2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201cf4:	85a6                	mv	a1,s1
ffffffffc0201cf6:	8552                	mv	a0,s4
ffffffffc0201cf8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cfa:	fe0d9ce3          	bnez	s11,ffffffffc0201cf2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cfe:	00044783          	lbu	a5,0(s0)
ffffffffc0201d02:	00140a13          	addi	s4,s0,1
ffffffffc0201d06:	0007851b          	sext.w	a0,a5
ffffffffc0201d0a:	d3a5                	beqz	a5,ffffffffc0201c6a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d0c:	05e00413          	li	s0,94
ffffffffc0201d10:	bf39                	j	ffffffffc0201c2e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201d12:	000a2403          	lw	s0,0(s4)
ffffffffc0201d16:	b7ad                	j	ffffffffc0201c80 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201d18:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d1c:	46a1                	li	a3,8
ffffffffc0201d1e:	8a2e                	mv	s4,a1
ffffffffc0201d20:	bdb1                	j	ffffffffc0201b7c <vprintfmt+0x156>
ffffffffc0201d22:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d26:	46a9                	li	a3,10
ffffffffc0201d28:	8a2e                	mv	s4,a1
ffffffffc0201d2a:	bd89                	j	ffffffffc0201b7c <vprintfmt+0x156>
ffffffffc0201d2c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d30:	46c1                	li	a3,16
ffffffffc0201d32:	8a2e                	mv	s4,a1
ffffffffc0201d34:	b5a1                	j	ffffffffc0201b7c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201d36:	9902                	jalr	s2
ffffffffc0201d38:	bf09                	j	ffffffffc0201c4a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201d3a:	85a6                	mv	a1,s1
ffffffffc0201d3c:	02d00513          	li	a0,45
ffffffffc0201d40:	e03e                	sd	a5,0(sp)
ffffffffc0201d42:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201d44:	6782                	ld	a5,0(sp)
ffffffffc0201d46:	8a66                	mv	s4,s9
ffffffffc0201d48:	40800633          	neg	a2,s0
ffffffffc0201d4c:	46a9                	li	a3,10
ffffffffc0201d4e:	b53d                	j	ffffffffc0201b7c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201d50:	03b05163          	blez	s11,ffffffffc0201d72 <vprintfmt+0x34c>
ffffffffc0201d54:	02d00693          	li	a3,45
ffffffffc0201d58:	f6d79de3          	bne	a5,a3,ffffffffc0201cd2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201d5c:	00001417          	auipc	s0,0x1
ffffffffc0201d60:	11440413          	addi	s0,s0,276 # ffffffffc0202e70 <best_fit_pmm_manager+0x198>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d64:	02800793          	li	a5,40
ffffffffc0201d68:	02800513          	li	a0,40
ffffffffc0201d6c:	00140a13          	addi	s4,s0,1
ffffffffc0201d70:	bd6d                	j	ffffffffc0201c2a <vprintfmt+0x204>
ffffffffc0201d72:	00001a17          	auipc	s4,0x1
ffffffffc0201d76:	0ffa0a13          	addi	s4,s4,255 # ffffffffc0202e71 <best_fit_pmm_manager+0x199>
ffffffffc0201d7a:	02800513          	li	a0,40
ffffffffc0201d7e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d82:	05e00413          	li	s0,94
ffffffffc0201d86:	b565                	j	ffffffffc0201c2e <vprintfmt+0x208>

ffffffffc0201d88 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d88:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201d8a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d8e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d90:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d92:	ec06                	sd	ra,24(sp)
ffffffffc0201d94:	f83a                	sd	a4,48(sp)
ffffffffc0201d96:	fc3e                	sd	a5,56(sp)
ffffffffc0201d98:	e0c2                	sd	a6,64(sp)
ffffffffc0201d9a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201d9c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d9e:	c89ff0ef          	jal	ra,ffffffffc0201a26 <vprintfmt>
}
ffffffffc0201da2:	60e2                	ld	ra,24(sp)
ffffffffc0201da4:	6161                	addi	sp,sp,80
ffffffffc0201da6:	8082                	ret

ffffffffc0201da8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201da8:	715d                	addi	sp,sp,-80
ffffffffc0201daa:	e486                	sd	ra,72(sp)
ffffffffc0201dac:	e0a6                	sd	s1,64(sp)
ffffffffc0201dae:	fc4a                	sd	s2,56(sp)
ffffffffc0201db0:	f84e                	sd	s3,48(sp)
ffffffffc0201db2:	f452                	sd	s4,40(sp)
ffffffffc0201db4:	f056                	sd	s5,32(sp)
ffffffffc0201db6:	ec5a                	sd	s6,24(sp)
ffffffffc0201db8:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201dba:	c901                	beqz	a0,ffffffffc0201dca <readline+0x22>
ffffffffc0201dbc:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201dbe:	00001517          	auipc	a0,0x1
ffffffffc0201dc2:	0ca50513          	addi	a0,a0,202 # ffffffffc0202e88 <best_fit_pmm_manager+0x1b0>
ffffffffc0201dc6:	b60fe0ef          	jal	ra,ffffffffc0200126 <cprintf>
readline(const char *prompt) {
ffffffffc0201dca:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201dcc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201dce:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201dd0:	4aa9                	li	s5,10
ffffffffc0201dd2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201dd4:	00005b97          	auipc	s7,0x5
ffffffffc0201dd8:	26cb8b93          	addi	s7,s7,620 # ffffffffc0207040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ddc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201de0:	bbefe0ef          	jal	ra,ffffffffc020019e <getchar>
        if (c < 0) {
ffffffffc0201de4:	00054a63          	bltz	a0,ffffffffc0201df8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201de8:	00a95a63          	bge	s2,a0,ffffffffc0201dfc <readline+0x54>
ffffffffc0201dec:	029a5263          	bge	s4,s1,ffffffffc0201e10 <readline+0x68>
        c = getchar();
ffffffffc0201df0:	baefe0ef          	jal	ra,ffffffffc020019e <getchar>
        if (c < 0) {
ffffffffc0201df4:	fe055ae3          	bgez	a0,ffffffffc0201de8 <readline+0x40>
            return NULL;
ffffffffc0201df8:	4501                	li	a0,0
ffffffffc0201dfa:	a091                	j	ffffffffc0201e3e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201dfc:	03351463          	bne	a0,s3,ffffffffc0201e24 <readline+0x7c>
ffffffffc0201e00:	e8a9                	bnez	s1,ffffffffc0201e52 <readline+0xaa>
        c = getchar();
ffffffffc0201e02:	b9cfe0ef          	jal	ra,ffffffffc020019e <getchar>
        if (c < 0) {
ffffffffc0201e06:	fe0549e3          	bltz	a0,ffffffffc0201df8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e0a:	fea959e3          	bge	s2,a0,ffffffffc0201dfc <readline+0x54>
ffffffffc0201e0e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201e10:	e42a                	sd	a0,8(sp)
ffffffffc0201e12:	b4afe0ef          	jal	ra,ffffffffc020015c <cputchar>
            buf[i ++] = c;
ffffffffc0201e16:	6522                	ld	a0,8(sp)
ffffffffc0201e18:	009b87b3          	add	a5,s7,s1
ffffffffc0201e1c:	2485                	addiw	s1,s1,1
ffffffffc0201e1e:	00a78023          	sb	a0,0(a5)
ffffffffc0201e22:	bf7d                	j	ffffffffc0201de0 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201e24:	01550463          	beq	a0,s5,ffffffffc0201e2c <readline+0x84>
ffffffffc0201e28:	fb651ce3          	bne	a0,s6,ffffffffc0201de0 <readline+0x38>
            cputchar(c);
ffffffffc0201e2c:	b30fe0ef          	jal	ra,ffffffffc020015c <cputchar>
            buf[i] = '\0';
ffffffffc0201e30:	00005517          	auipc	a0,0x5
ffffffffc0201e34:	21050513          	addi	a0,a0,528 # ffffffffc0207040 <buf>
ffffffffc0201e38:	94aa                	add	s1,s1,a0
ffffffffc0201e3a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201e3e:	60a6                	ld	ra,72(sp)
ffffffffc0201e40:	6486                	ld	s1,64(sp)
ffffffffc0201e42:	7962                	ld	s2,56(sp)
ffffffffc0201e44:	79c2                	ld	s3,48(sp)
ffffffffc0201e46:	7a22                	ld	s4,40(sp)
ffffffffc0201e48:	7a82                	ld	s5,32(sp)
ffffffffc0201e4a:	6b62                	ld	s6,24(sp)
ffffffffc0201e4c:	6bc2                	ld	s7,16(sp)
ffffffffc0201e4e:	6161                	addi	sp,sp,80
ffffffffc0201e50:	8082                	ret
            cputchar(c);
ffffffffc0201e52:	4521                	li	a0,8
ffffffffc0201e54:	b08fe0ef          	jal	ra,ffffffffc020015c <cputchar>
            i --;
ffffffffc0201e58:	34fd                	addiw	s1,s1,-1
ffffffffc0201e5a:	b759                	j	ffffffffc0201de0 <readline+0x38>

ffffffffc0201e5c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201e5c:	4781                	li	a5,0
ffffffffc0201e5e:	00005717          	auipc	a4,0x5
ffffffffc0201e62:	1ba73703          	ld	a4,442(a4) # ffffffffc0207018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201e66:	88ba                	mv	a7,a4
ffffffffc0201e68:	852a                	mv	a0,a0
ffffffffc0201e6a:	85be                	mv	a1,a5
ffffffffc0201e6c:	863e                	mv	a2,a5
ffffffffc0201e6e:	00000073          	ecall
ffffffffc0201e72:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201e74:	8082                	ret

ffffffffc0201e76 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201e76:	4781                	li	a5,0
ffffffffc0201e78:	00005717          	auipc	a4,0x5
ffffffffc0201e7c:	62073703          	ld	a4,1568(a4) # ffffffffc0207498 <SBI_SET_TIMER>
ffffffffc0201e80:	88ba                	mv	a7,a4
ffffffffc0201e82:	852a                	mv	a0,a0
ffffffffc0201e84:	85be                	mv	a1,a5
ffffffffc0201e86:	863e                	mv	a2,a5
ffffffffc0201e88:	00000073          	ecall
ffffffffc0201e8c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201e8e:	8082                	ret

ffffffffc0201e90 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201e90:	4501                	li	a0,0
ffffffffc0201e92:	00005797          	auipc	a5,0x5
ffffffffc0201e96:	17e7b783          	ld	a5,382(a5) # ffffffffc0207010 <SBI_CONSOLE_GETCHAR>
ffffffffc0201e9a:	88be                	mv	a7,a5
ffffffffc0201e9c:	852a                	mv	a0,a0
ffffffffc0201e9e:	85aa                	mv	a1,a0
ffffffffc0201ea0:	862a                	mv	a2,a0
ffffffffc0201ea2:	00000073          	ecall
ffffffffc0201ea6:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201ea8:	2501                	sext.w	a0,a0
ffffffffc0201eaa:	8082                	ret

ffffffffc0201eac <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201eac:	4781                	li	a5,0
ffffffffc0201eae:	00005717          	auipc	a4,0x5
ffffffffc0201eb2:	17273703          	ld	a4,370(a4) # ffffffffc0207020 <SBI_SHUTDOWN>
ffffffffc0201eb6:	88ba                	mv	a7,a4
ffffffffc0201eb8:	853e                	mv	a0,a5
ffffffffc0201eba:	85be                	mv	a1,a5
ffffffffc0201ebc:	863e                	mv	a2,a5
ffffffffc0201ebe:	00000073          	ecall
ffffffffc0201ec2:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201ec4:	8082                	ret

ffffffffc0201ec6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201ec6:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201eca:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201ecc:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201ece:	cb81                	beqz	a5,ffffffffc0201ede <strlen+0x18>
        cnt ++;
ffffffffc0201ed0:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201ed2:	00a707b3          	add	a5,a4,a0
ffffffffc0201ed6:	0007c783          	lbu	a5,0(a5)
ffffffffc0201eda:	fbfd                	bnez	a5,ffffffffc0201ed0 <strlen+0xa>
ffffffffc0201edc:	8082                	ret
    }
    return cnt;
}
ffffffffc0201ede:	8082                	ret

ffffffffc0201ee0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201ee0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201ee2:	e589                	bnez	a1,ffffffffc0201eec <strnlen+0xc>
ffffffffc0201ee4:	a811                	j	ffffffffc0201ef8 <strnlen+0x18>
        cnt ++;
ffffffffc0201ee6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201ee8:	00f58863          	beq	a1,a5,ffffffffc0201ef8 <strnlen+0x18>
ffffffffc0201eec:	00f50733          	add	a4,a0,a5
ffffffffc0201ef0:	00074703          	lbu	a4,0(a4)
ffffffffc0201ef4:	fb6d                	bnez	a4,ffffffffc0201ee6 <strnlen+0x6>
ffffffffc0201ef6:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201ef8:	852e                	mv	a0,a1
ffffffffc0201efa:	8082                	ret

ffffffffc0201efc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201efc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f00:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201f04:	cb89                	beqz	a5,ffffffffc0201f16 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201f06:	0505                	addi	a0,a0,1
ffffffffc0201f08:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201f0a:	fee789e3          	beq	a5,a4,ffffffffc0201efc <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f0e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201f12:	9d19                	subw	a0,a0,a4
ffffffffc0201f14:	8082                	ret
ffffffffc0201f16:	4501                	li	a0,0
ffffffffc0201f18:	bfed                	j	ffffffffc0201f12 <strcmp+0x16>

ffffffffc0201f1a <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201f1a:	c20d                	beqz	a2,ffffffffc0201f3c <strncmp+0x22>
ffffffffc0201f1c:	962e                	add	a2,a2,a1
ffffffffc0201f1e:	a031                	j	ffffffffc0201f2a <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201f20:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201f22:	00e79a63          	bne	a5,a4,ffffffffc0201f36 <strncmp+0x1c>
ffffffffc0201f26:	00b60b63          	beq	a2,a1,ffffffffc0201f3c <strncmp+0x22>
ffffffffc0201f2a:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201f2e:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201f30:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201f34:	f7f5                	bnez	a5,ffffffffc0201f20 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f36:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201f3a:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f3c:	4501                	li	a0,0
ffffffffc0201f3e:	8082                	ret

ffffffffc0201f40 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201f40:	00054783          	lbu	a5,0(a0)
ffffffffc0201f44:	c799                	beqz	a5,ffffffffc0201f52 <strchr+0x12>
        if (*s == c) {
ffffffffc0201f46:	00f58763          	beq	a1,a5,ffffffffc0201f54 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201f4a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201f4e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201f50:	fbfd                	bnez	a5,ffffffffc0201f46 <strchr+0x6>
    }
    return NULL;
ffffffffc0201f52:	4501                	li	a0,0
}
ffffffffc0201f54:	8082                	ret

ffffffffc0201f56 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201f56:	ca01                	beqz	a2,ffffffffc0201f66 <memset+0x10>
ffffffffc0201f58:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201f5a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201f5c:	0785                	addi	a5,a5,1
ffffffffc0201f5e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201f62:	fec79de3          	bne	a5,a2,ffffffffc0201f5c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201f66:	8082                	ret
