
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00009297          	auipc	t0,0x9
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0209000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00009297          	auipc	t0,0x9
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0209008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02082b7          	lui	t0,0xc0208
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
ffffffffc020003c:	c0208137          	lui	sp,0xc0208

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	00009517          	auipc	a0,0x9
ffffffffc020004e:	fe650513          	addi	a0,a0,-26 # ffffffffc0209030 <buf>
ffffffffc0200052:	0000d617          	auipc	a2,0xd
ffffffffc0200056:	49a60613          	addi	a2,a2,1178 # ffffffffc020d4ec <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	637030ef          	jal	ra,ffffffffc0203e98 <memset>
    dtb_init();
ffffffffc0200066:	514000ef          	jal	ra,ffffffffc020057a <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	49e000ef          	jal	ra,ffffffffc0200508 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00004597          	auipc	a1,0x4
ffffffffc0200072:	e7a58593          	addi	a1,a1,-390 # ffffffffc0203ee8 <etext+0x2>
ffffffffc0200076:	00004517          	auipc	a0,0x4
ffffffffc020007a:	e9250513          	addi	a0,a0,-366 # ffffffffc0203f08 <etext+0x22>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	15a000ef          	jal	ra,ffffffffc02001dc <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	0e4020ef          	jal	ra,ffffffffc020216a <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	0ad000ef          	jal	ra,ffffffffc0200936 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	0ab000ef          	jal	ra,ffffffffc0200938 <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	64d020ef          	jal	ra,ffffffffc0202ede <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	5c2030ef          	jal	ra,ffffffffc0203658 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	41c000ef          	jal	ra,ffffffffc02004b6 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	08d000ef          	jal	ra,ffffffffc020092a <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	005030ef          	jal	ra,ffffffffc02038a6 <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	715d                	addi	sp,sp,-80
ffffffffc02000a8:	e486                	sd	ra,72(sp)
ffffffffc02000aa:	e0a6                	sd	s1,64(sp)
ffffffffc02000ac:	fc4a                	sd	s2,56(sp)
ffffffffc02000ae:	f84e                	sd	s3,48(sp)
ffffffffc02000b0:	f452                	sd	s4,40(sp)
ffffffffc02000b2:	f056                	sd	s5,32(sp)
ffffffffc02000b4:	ec5a                	sd	s6,24(sp)
ffffffffc02000b6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000b8:	c901                	beqz	a0,ffffffffc02000c8 <readline+0x22>
ffffffffc02000ba:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000bc:	00004517          	auipc	a0,0x4
ffffffffc02000c0:	e5450513          	addi	a0,a0,-428 # ffffffffc0203f10 <etext+0x2a>
ffffffffc02000c4:	0d0000ef          	jal	ra,ffffffffc0200194 <cprintf>
readline(const char *prompt) {
ffffffffc02000c8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ca:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000cc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ce:	4aa9                	li	s5,10
ffffffffc02000d0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000d2:	00009b97          	auipc	s7,0x9
ffffffffc02000d6:	f5eb8b93          	addi	s7,s7,-162 # ffffffffc0209030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000de:	0ee000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc02000e2:	00054a63          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e6:	00a95a63          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc02000ea:	029a5263          	bge	s4,s1,ffffffffc020010e <readline+0x68>
        c = getchar();
ffffffffc02000ee:	0de000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc02000f2:	fe055ae3          	bgez	a0,ffffffffc02000e6 <readline+0x40>
            return NULL;
ffffffffc02000f6:	4501                	li	a0,0
ffffffffc02000f8:	a091                	j	ffffffffc020013c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000fa:	03351463          	bne	a0,s3,ffffffffc0200122 <readline+0x7c>
ffffffffc02000fe:	e8a9                	bnez	s1,ffffffffc0200150 <readline+0xaa>
        c = getchar();
ffffffffc0200100:	0cc000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc0200104:	fe0549e3          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200108:	fea959e3          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc020010c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010e:	e42a                	sd	a0,8(sp)
ffffffffc0200110:	0ba000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i ++] = c;
ffffffffc0200114:	6522                	ld	a0,8(sp)
ffffffffc0200116:	009b87b3          	add	a5,s7,s1
ffffffffc020011a:	2485                	addiw	s1,s1,1
ffffffffc020011c:	00a78023          	sb	a0,0(a5)
ffffffffc0200120:	bf7d                	j	ffffffffc02000de <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200122:	01550463          	beq	a0,s5,ffffffffc020012a <readline+0x84>
ffffffffc0200126:	fb651ce3          	bne	a0,s6,ffffffffc02000de <readline+0x38>
            cputchar(c);
ffffffffc020012a:	0a0000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i] = '\0';
ffffffffc020012e:	00009517          	auipc	a0,0x9
ffffffffc0200132:	f0250513          	addi	a0,a0,-254 # ffffffffc0209030 <buf>
ffffffffc0200136:	94aa                	add	s1,s1,a0
ffffffffc0200138:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020013c:	60a6                	ld	ra,72(sp)
ffffffffc020013e:	6486                	ld	s1,64(sp)
ffffffffc0200140:	7962                	ld	s2,56(sp)
ffffffffc0200142:	79c2                	ld	s3,48(sp)
ffffffffc0200144:	7a22                	ld	s4,40(sp)
ffffffffc0200146:	7a82                	ld	s5,32(sp)
ffffffffc0200148:	6b62                	ld	s6,24(sp)
ffffffffc020014a:	6bc2                	ld	s7,16(sp)
ffffffffc020014c:	6161                	addi	sp,sp,80
ffffffffc020014e:	8082                	ret
            cputchar(c);
ffffffffc0200150:	4521                	li	a0,8
ffffffffc0200152:	078000ef          	jal	ra,ffffffffc02001ca <cputchar>
            i --;
ffffffffc0200156:	34fd                	addiw	s1,s1,-1
ffffffffc0200158:	b759                	j	ffffffffc02000de <readline+0x38>

ffffffffc020015a <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e022                	sd	s0,0(sp)
ffffffffc020015e:	e406                	sd	ra,8(sp)
ffffffffc0200160:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200162:	3a8000ef          	jal	ra,ffffffffc020050a <cons_putc>
    (*cnt)++;
ffffffffc0200166:	401c                	lw	a5,0(s0)
}
ffffffffc0200168:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc020016a:	2785                	addiw	a5,a5,1
ffffffffc020016c:	c01c                	sw	a5,0(s0)
}
ffffffffc020016e:	6402                	ld	s0,0(sp)
ffffffffc0200170:	0141                	addi	sp,sp,16
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe050513          	addi	a0,a0,-32 # ffffffffc020015a <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	0ed030ef          	jal	ra,ffffffffc0203a74 <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
{
ffffffffc020019a:	8e2a                	mv	t3,a0
ffffffffc020019c:	f42e                	sd	a1,40(sp)
ffffffffc020019e:	f832                	sd	a2,48(sp)
ffffffffc02001a0:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb850513          	addi	a0,a0,-72 # ffffffffc020015a <cputch>
ffffffffc02001aa:	004c                	addi	a1,sp,4
ffffffffc02001ac:	869a                	mv	a3,t1
ffffffffc02001ae:	8672                	mv	a2,t3
{
ffffffffc02001b0:	ec06                	sd	ra,24(sp)
ffffffffc02001b2:	e0ba                	sd	a4,64(sp)
ffffffffc02001b4:	e4be                	sd	a5,72(sp)
ffffffffc02001b6:	e8c2                	sd	a6,80(sp)
ffffffffc02001b8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001bc:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001be:	0b7030ef          	jal	ra,ffffffffc0203a74 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c2:	60e2                	ld	ra,24(sp)
ffffffffc02001c4:	4512                	lw	a0,4(sp)
ffffffffc02001c6:	6125                	addi	sp,sp,96
ffffffffc02001c8:	8082                	ret

ffffffffc02001ca <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001ca:	a681                	j	ffffffffc020050a <cons_putc>

ffffffffc02001cc <getchar>:
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc02001cc:	1141                	addi	sp,sp,-16
ffffffffc02001ce:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001d0:	36e000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001d4:	dd75                	beqz	a0,ffffffffc02001d0 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
ffffffffc02001d8:	0141                	addi	sp,sp,16
ffffffffc02001da:	8082                	ret

ffffffffc02001dc <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc02001dc:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001de:	00004517          	auipc	a0,0x4
ffffffffc02001e2:	d3a50513          	addi	a0,a0,-710 # ffffffffc0203f18 <etext+0x32>
{
ffffffffc02001e6:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e8:	fadff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001ec:	00000597          	auipc	a1,0x0
ffffffffc02001f0:	e5e58593          	addi	a1,a1,-418 # ffffffffc020004a <kern_init>
ffffffffc02001f4:	00004517          	auipc	a0,0x4
ffffffffc02001f8:	d4450513          	addi	a0,a0,-700 # ffffffffc0203f38 <etext+0x52>
ffffffffc02001fc:	f99ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200200:	00004597          	auipc	a1,0x4
ffffffffc0200204:	ce658593          	addi	a1,a1,-794 # ffffffffc0203ee6 <etext>
ffffffffc0200208:	00004517          	auipc	a0,0x4
ffffffffc020020c:	d5050513          	addi	a0,a0,-688 # ffffffffc0203f58 <etext+0x72>
ffffffffc0200210:	f85ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200214:	00009597          	auipc	a1,0x9
ffffffffc0200218:	e1c58593          	addi	a1,a1,-484 # ffffffffc0209030 <buf>
ffffffffc020021c:	00004517          	auipc	a0,0x4
ffffffffc0200220:	d5c50513          	addi	a0,a0,-676 # ffffffffc0203f78 <etext+0x92>
ffffffffc0200224:	f71ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200228:	0000d597          	auipc	a1,0xd
ffffffffc020022c:	2c458593          	addi	a1,a1,708 # ffffffffc020d4ec <end>
ffffffffc0200230:	00004517          	auipc	a0,0x4
ffffffffc0200234:	d6850513          	addi	a0,a0,-664 # ffffffffc0203f98 <etext+0xb2>
ffffffffc0200238:	f5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020023c:	0000d597          	auipc	a1,0xd
ffffffffc0200240:	6af58593          	addi	a1,a1,1711 # ffffffffc020d8eb <end+0x3ff>
ffffffffc0200244:	00000797          	auipc	a5,0x0
ffffffffc0200248:	e0678793          	addi	a5,a5,-506 # ffffffffc020004a <kern_init>
ffffffffc020024c:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200254:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200256:	3ff5f593          	andi	a1,a1,1023
ffffffffc020025a:	95be                	add	a1,a1,a5
ffffffffc020025c:	85a9                	srai	a1,a1,0xa
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	d5a50513          	addi	a0,a0,-678 # ffffffffc0203fb8 <etext+0xd2>
}
ffffffffc0200266:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200268:	b735                	j	ffffffffc0200194 <cprintf>

ffffffffc020026a <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc020026a:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020026c:	00004617          	auipc	a2,0x4
ffffffffc0200270:	d7c60613          	addi	a2,a2,-644 # ffffffffc0203fe8 <etext+0x102>
ffffffffc0200274:	04900593          	li	a1,73
ffffffffc0200278:	00004517          	auipc	a0,0x4
ffffffffc020027c:	d8850513          	addi	a0,a0,-632 # ffffffffc0204000 <etext+0x11a>
{
ffffffffc0200280:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200282:	1d8000ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0200286 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200286:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200288:	00004617          	auipc	a2,0x4
ffffffffc020028c:	d9060613          	addi	a2,a2,-624 # ffffffffc0204018 <etext+0x132>
ffffffffc0200290:	00004597          	auipc	a1,0x4
ffffffffc0200294:	da858593          	addi	a1,a1,-600 # ffffffffc0204038 <etext+0x152>
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	da850513          	addi	a0,a0,-600 # ffffffffc0204040 <etext+0x15a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002a2:	ef3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002a6:	00004617          	auipc	a2,0x4
ffffffffc02002aa:	daa60613          	addi	a2,a2,-598 # ffffffffc0204050 <etext+0x16a>
ffffffffc02002ae:	00004597          	auipc	a1,0x4
ffffffffc02002b2:	dca58593          	addi	a1,a1,-566 # ffffffffc0204078 <etext+0x192>
ffffffffc02002b6:	00004517          	auipc	a0,0x4
ffffffffc02002ba:	d8a50513          	addi	a0,a0,-630 # ffffffffc0204040 <etext+0x15a>
ffffffffc02002be:	ed7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002c2:	00004617          	auipc	a2,0x4
ffffffffc02002c6:	dc660613          	addi	a2,a2,-570 # ffffffffc0204088 <etext+0x1a2>
ffffffffc02002ca:	00004597          	auipc	a1,0x4
ffffffffc02002ce:	dde58593          	addi	a1,a1,-546 # ffffffffc02040a8 <etext+0x1c2>
ffffffffc02002d2:	00004517          	auipc	a0,0x4
ffffffffc02002d6:	d6e50513          	addi	a0,a0,-658 # ffffffffc0204040 <etext+0x15a>
ffffffffc02002da:	ebbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    return 0;
}
ffffffffc02002de:	60a2                	ld	ra,8(sp)
ffffffffc02002e0:	4501                	li	a0,0
ffffffffc02002e2:	0141                	addi	sp,sp,16
ffffffffc02002e4:	8082                	ret

ffffffffc02002e6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e6:	1141                	addi	sp,sp,-16
ffffffffc02002e8:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ea:	ef3ff0ef          	jal	ra,ffffffffc02001dc <print_kerninfo>
    return 0;
}
ffffffffc02002ee:	60a2                	ld	ra,8(sp)
ffffffffc02002f0:	4501                	li	a0,0
ffffffffc02002f2:	0141                	addi	sp,sp,16
ffffffffc02002f4:	8082                	ret

ffffffffc02002f6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f6:	1141                	addi	sp,sp,-16
ffffffffc02002f8:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002fa:	f71ff0ef          	jal	ra,ffffffffc020026a <print_stackframe>
    return 0;
}
ffffffffc02002fe:	60a2                	ld	ra,8(sp)
ffffffffc0200300:	4501                	li	a0,0
ffffffffc0200302:	0141                	addi	sp,sp,16
ffffffffc0200304:	8082                	ret

ffffffffc0200306 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200306:	7115                	addi	sp,sp,-224
ffffffffc0200308:	ed5e                	sd	s7,152(sp)
ffffffffc020030a:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020030c:	00004517          	auipc	a0,0x4
ffffffffc0200310:	dac50513          	addi	a0,a0,-596 # ffffffffc02040b8 <etext+0x1d2>
kmonitor(struct trapframe *tf) {
ffffffffc0200314:	ed86                	sd	ra,216(sp)
ffffffffc0200316:	e9a2                	sd	s0,208(sp)
ffffffffc0200318:	e5a6                	sd	s1,200(sp)
ffffffffc020031a:	e1ca                	sd	s2,192(sp)
ffffffffc020031c:	fd4e                	sd	s3,184(sp)
ffffffffc020031e:	f952                	sd	s4,176(sp)
ffffffffc0200320:	f556                	sd	s5,168(sp)
ffffffffc0200322:	f15a                	sd	s6,160(sp)
ffffffffc0200324:	e962                	sd	s8,144(sp)
ffffffffc0200326:	e566                	sd	s9,136(sp)
ffffffffc0200328:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020032a:	e6bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032e:	00004517          	auipc	a0,0x4
ffffffffc0200332:	db250513          	addi	a0,a0,-590 # ffffffffc02040e0 <etext+0x1fa>
ffffffffc0200336:	e5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL) {
ffffffffc020033a:	000b8563          	beqz	s7,ffffffffc0200344 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033e:	855e                	mv	a0,s7
ffffffffc0200340:	7e0000ef          	jal	ra,ffffffffc0200b20 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200344:	4501                	li	a0,0
ffffffffc0200346:	4581                	li	a1,0
ffffffffc0200348:	4601                	li	a2,0
ffffffffc020034a:	48a1                	li	a7,8
ffffffffc020034c:	00000073          	ecall
ffffffffc0200350:	00004c17          	auipc	s8,0x4
ffffffffc0200354:	e00c0c13          	addi	s8,s8,-512 # ffffffffc0204150 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200358:	00004917          	auipc	s2,0x4
ffffffffc020035c:	db090913          	addi	s2,s2,-592 # ffffffffc0204108 <etext+0x222>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200360:	00004497          	auipc	s1,0x4
ffffffffc0200364:	db048493          	addi	s1,s1,-592 # ffffffffc0204110 <etext+0x22a>
        if (argc == MAXARGS - 1) {
ffffffffc0200368:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020036a:	00004b17          	auipc	s6,0x4
ffffffffc020036e:	daeb0b13          	addi	s6,s6,-594 # ffffffffc0204118 <etext+0x232>
        argv[argc ++] = buf;
ffffffffc0200372:	00004a17          	auipc	s4,0x4
ffffffffc0200376:	cc6a0a13          	addi	s4,s4,-826 # ffffffffc0204038 <etext+0x152>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020037a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020037c:	854a                	mv	a0,s2
ffffffffc020037e:	d29ff0ef          	jal	ra,ffffffffc02000a6 <readline>
ffffffffc0200382:	842a                	mv	s0,a0
ffffffffc0200384:	dd65                	beqz	a0,ffffffffc020037c <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200386:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020038a:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038c:	e1bd                	bnez	a1,ffffffffc02003f2 <kmonitor+0xec>
    if (argc == 0) {
ffffffffc020038e:	fe0c87e3          	beqz	s9,ffffffffc020037c <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200392:	6582                	ld	a1,0(sp)
ffffffffc0200394:	00004d17          	auipc	s10,0x4
ffffffffc0200398:	dbcd0d13          	addi	s10,s10,-580 # ffffffffc0204150 <commands>
        argv[argc ++] = buf;
ffffffffc020039c:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039e:	4401                	li	s0,0
ffffffffc02003a0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a2:	29d030ef          	jal	ra,ffffffffc0203e3e <strcmp>
ffffffffc02003a6:	c919                	beqz	a0,ffffffffc02003bc <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a8:	2405                	addiw	s0,s0,1
ffffffffc02003aa:	0b540063          	beq	s0,s5,ffffffffc020044a <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ae:	000d3503          	ld	a0,0(s10)
ffffffffc02003b2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b6:	289030ef          	jal	ra,ffffffffc0203e3e <strcmp>
ffffffffc02003ba:	f57d                	bnez	a0,ffffffffc02003a8 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003bc:	00141793          	slli	a5,s0,0x1
ffffffffc02003c0:	97a2                	add	a5,a5,s0
ffffffffc02003c2:	078e                	slli	a5,a5,0x3
ffffffffc02003c4:	97e2                	add	a5,a5,s8
ffffffffc02003c6:	6b9c                	ld	a5,16(a5)
ffffffffc02003c8:	865e                	mv	a2,s7
ffffffffc02003ca:	002c                	addi	a1,sp,8
ffffffffc02003cc:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003d0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003d2:	fa0555e3          	bgez	a0,ffffffffc020037c <kmonitor+0x76>
}
ffffffffc02003d6:	60ee                	ld	ra,216(sp)
ffffffffc02003d8:	644e                	ld	s0,208(sp)
ffffffffc02003da:	64ae                	ld	s1,200(sp)
ffffffffc02003dc:	690e                	ld	s2,192(sp)
ffffffffc02003de:	79ea                	ld	s3,184(sp)
ffffffffc02003e0:	7a4a                	ld	s4,176(sp)
ffffffffc02003e2:	7aaa                	ld	s5,168(sp)
ffffffffc02003e4:	7b0a                	ld	s6,160(sp)
ffffffffc02003e6:	6bea                	ld	s7,152(sp)
ffffffffc02003e8:	6c4a                	ld	s8,144(sp)
ffffffffc02003ea:	6caa                	ld	s9,136(sp)
ffffffffc02003ec:	6d0a                	ld	s10,128(sp)
ffffffffc02003ee:	612d                	addi	sp,sp,224
ffffffffc02003f0:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f2:	8526                	mv	a0,s1
ffffffffc02003f4:	28f030ef          	jal	ra,ffffffffc0203e82 <strchr>
ffffffffc02003f8:	c901                	beqz	a0,ffffffffc0200408 <kmonitor+0x102>
ffffffffc02003fa:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003fe:	00040023          	sb	zero,0(s0)
ffffffffc0200402:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200404:	d5c9                	beqz	a1,ffffffffc020038e <kmonitor+0x88>
ffffffffc0200406:	b7f5                	j	ffffffffc02003f2 <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc0200408:	00044783          	lbu	a5,0(s0)
ffffffffc020040c:	d3c9                	beqz	a5,ffffffffc020038e <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc020040e:	033c8963          	beq	s9,s3,ffffffffc0200440 <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc0200412:	003c9793          	slli	a5,s9,0x3
ffffffffc0200416:	0118                	addi	a4,sp,128
ffffffffc0200418:	97ba                	add	a5,a5,a4
ffffffffc020041a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200422:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200424:	e591                	bnez	a1,ffffffffc0200430 <kmonitor+0x12a>
ffffffffc0200426:	b7b5                	j	ffffffffc0200392 <kmonitor+0x8c>
ffffffffc0200428:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020042c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020042e:	d1a5                	beqz	a1,ffffffffc020038e <kmonitor+0x88>
ffffffffc0200430:	8526                	mv	a0,s1
ffffffffc0200432:	251030ef          	jal	ra,ffffffffc0203e82 <strchr>
ffffffffc0200436:	d96d                	beqz	a0,ffffffffc0200428 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200438:	00044583          	lbu	a1,0(s0)
ffffffffc020043c:	d9a9                	beqz	a1,ffffffffc020038e <kmonitor+0x88>
ffffffffc020043e:	bf55                	j	ffffffffc02003f2 <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200440:	45c1                	li	a1,16
ffffffffc0200442:	855a                	mv	a0,s6
ffffffffc0200444:	d51ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0200448:	b7e9                	j	ffffffffc0200412 <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020044a:	6582                	ld	a1,0(sp)
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	cec50513          	addi	a0,a0,-788 # ffffffffc0204138 <etext+0x252>
ffffffffc0200454:	d41ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
ffffffffc0200458:	b715                	j	ffffffffc020037c <kmonitor+0x76>

ffffffffc020045a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020045a:	0000d317          	auipc	t1,0xd
ffffffffc020045e:	00e30313          	addi	t1,t1,14 # ffffffffc020d468 <is_panic>
ffffffffc0200462:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200466:	715d                	addi	sp,sp,-80
ffffffffc0200468:	ec06                	sd	ra,24(sp)
ffffffffc020046a:	e822                	sd	s0,16(sp)
ffffffffc020046c:	f436                	sd	a3,40(sp)
ffffffffc020046e:	f83a                	sd	a4,48(sp)
ffffffffc0200470:	fc3e                	sd	a5,56(sp)
ffffffffc0200472:	e0c2                	sd	a6,64(sp)
ffffffffc0200474:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200476:	020e1a63          	bnez	t3,ffffffffc02004aa <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020047a:	4785                	li	a5,1
ffffffffc020047c:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200480:	8432                	mv	s0,a2
ffffffffc0200482:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200484:	862e                	mv	a2,a1
ffffffffc0200486:	85aa                	mv	a1,a0
ffffffffc0200488:	00004517          	auipc	a0,0x4
ffffffffc020048c:	d1050513          	addi	a0,a0,-752 # ffffffffc0204198 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200490:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200492:	d03ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200496:	65a2                	ld	a1,8(sp)
ffffffffc0200498:	8522                	mv	a0,s0
ffffffffc020049a:	cdbff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc020049e:	00005517          	auipc	a0,0x5
ffffffffc02004a2:	daa50513          	addi	a0,a0,-598 # ffffffffc0205248 <default_pmm_manager+0x530>
ffffffffc02004a6:	cefff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004aa:	486000ef          	jal	ra,ffffffffc0200930 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004ae:	4501                	li	a0,0
ffffffffc02004b0:	e57ff0ef          	jal	ra,ffffffffc0200306 <kmonitor>
    while (1) {
ffffffffc02004b4:	bfed                	j	ffffffffc02004ae <__panic+0x54>

ffffffffc02004b6 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004b6:	67e1                	lui	a5,0x18
ffffffffc02004b8:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004bc:	0000d717          	auipc	a4,0xd
ffffffffc02004c0:	faf73e23          	sd	a5,-68(a4) # ffffffffc020d478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004c4:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004c8:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004ca:	953e                	add	a0,a0,a5
ffffffffc02004cc:	4601                	li	a2,0
ffffffffc02004ce:	4881                	li	a7,0
ffffffffc02004d0:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004d4:	02000793          	li	a5,32
ffffffffc02004d8:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004dc:	00004517          	auipc	a0,0x4
ffffffffc02004e0:	cdc50513          	addi	a0,a0,-804 # ffffffffc02041b8 <commands+0x68>
    ticks = 0;
ffffffffc02004e4:	0000d797          	auipc	a5,0xd
ffffffffc02004e8:	f807b623          	sd	zero,-116(a5) # ffffffffc020d470 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004ec:	b165                	j	ffffffffc0200194 <cprintf>

ffffffffc02004ee <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ee:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004f2:	0000d797          	auipc	a5,0xd
ffffffffc02004f6:	f867b783          	ld	a5,-122(a5) # ffffffffc020d478 <timebase>
ffffffffc02004fa:	953e                	add	a0,a0,a5
ffffffffc02004fc:	4581                	li	a1,0
ffffffffc02004fe:	4601                	li	a2,0
ffffffffc0200500:	4881                	li	a7,0
ffffffffc0200502:	00000073          	ecall
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200508:	8082                	ret

ffffffffc020050a <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020050a:	100027f3          	csrr	a5,sstatus
ffffffffc020050e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200510:	0ff57513          	zext.b	a0,a0
ffffffffc0200514:	e799                	bnez	a5,ffffffffc0200522 <cons_putc+0x18>
ffffffffc0200516:	4581                	li	a1,0
ffffffffc0200518:	4601                	li	a2,0
ffffffffc020051a:	4885                	li	a7,1
ffffffffc020051c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200520:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200522:	1101                	addi	sp,sp,-32
ffffffffc0200524:	ec06                	sd	ra,24(sp)
ffffffffc0200526:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200528:	408000ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020052c:	6522                	ld	a0,8(sp)
ffffffffc020052e:	4581                	li	a1,0
ffffffffc0200530:	4601                	li	a2,0
ffffffffc0200532:	4885                	li	a7,1
ffffffffc0200534:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200538:	60e2                	ld	ra,24(sp)
ffffffffc020053a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020053c:	a6fd                	j	ffffffffc020092a <intr_enable>

ffffffffc020053e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200554:	8082                	ret
int cons_getc(void) {
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020055a:	3d6000ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020056e:	3bc000ef          	jal	ra,ffffffffc020092a <intr_enable>
}
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc020057a:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc020057c:	00004517          	auipc	a0,0x4
ffffffffc0200580:	c5c50513          	addi	a0,a0,-932 # ffffffffc02041d8 <commands+0x88>
void dtb_init(void) {
ffffffffc0200584:	fc86                	sd	ra,120(sp)
ffffffffc0200586:	f8a2                	sd	s0,112(sp)
ffffffffc0200588:	e8d2                	sd	s4,80(sp)
ffffffffc020058a:	f4a6                	sd	s1,104(sp)
ffffffffc020058c:	f0ca                	sd	s2,96(sp)
ffffffffc020058e:	ecce                	sd	s3,88(sp)
ffffffffc0200590:	e4d6                	sd	s5,72(sp)
ffffffffc0200592:	e0da                	sd	s6,64(sp)
ffffffffc0200594:	fc5e                	sd	s7,56(sp)
ffffffffc0200596:	f862                	sd	s8,48(sp)
ffffffffc0200598:	f466                	sd	s9,40(sp)
ffffffffc020059a:	f06a                	sd	s10,32(sp)
ffffffffc020059c:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc020059e:	bf7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005a2:	00009597          	auipc	a1,0x9
ffffffffc02005a6:	a5e5b583          	ld	a1,-1442(a1) # ffffffffc0209000 <boot_hartid>
ffffffffc02005aa:	00004517          	auipc	a0,0x4
ffffffffc02005ae:	c3e50513          	addi	a0,a0,-962 # ffffffffc02041e8 <commands+0x98>
ffffffffc02005b2:	be3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005b6:	00009417          	auipc	s0,0x9
ffffffffc02005ba:	a5240413          	addi	s0,s0,-1454 # ffffffffc0209008 <boot_dtb>
ffffffffc02005be:	600c                	ld	a1,0(s0)
ffffffffc02005c0:	00004517          	auipc	a0,0x4
ffffffffc02005c4:	c3850513          	addi	a0,a0,-968 # ffffffffc02041f8 <commands+0xa8>
ffffffffc02005c8:	bcdff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02005cc:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02005d0:	00004517          	auipc	a0,0x4
ffffffffc02005d4:	c4050513          	addi	a0,a0,-960 # ffffffffc0204210 <commands+0xc0>
    if (boot_dtb == 0) {
ffffffffc02005d8:	120a0463          	beqz	s4,ffffffffc0200700 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc02005dc:	57f5                	li	a5,-3
ffffffffc02005de:	07fa                	slli	a5,a5,0x1e
ffffffffc02005e0:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc02005e4:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e6:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ea:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ec:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005f0:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f4:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f8:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005fc:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200600:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200602:	8ec9                	or	a3,a3,a0
ffffffffc0200604:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200608:	1b7d                	addi	s6,s6,-1
ffffffffc020060a:	0167f7b3          	and	a5,a5,s6
ffffffffc020060e:	8dd5                	or	a1,a1,a3
ffffffffc0200610:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200612:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200616:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc0200618:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed2a01>
ffffffffc020061c:	10f59163          	bne	a1,a5,ffffffffc020071e <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc0200620:	471c                	lw	a5,8(a4)
ffffffffc0200622:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200624:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200626:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020062a:	0086d51b          	srliw	a0,a3,0x8
ffffffffc020062e:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200632:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200636:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020063a:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020063e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200642:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200646:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020064a:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020064e:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200650:	01146433          	or	s0,s0,a7
ffffffffc0200654:	0086969b          	slliw	a3,a3,0x8
ffffffffc0200658:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020065c:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020065e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200662:	8c49                	or	s0,s0,a0
ffffffffc0200664:	0166f6b3          	and	a3,a3,s6
ffffffffc0200668:	00ca6a33          	or	s4,s4,a2
ffffffffc020066c:	0167f7b3          	and	a5,a5,s6
ffffffffc0200670:	8c55                	or	s0,s0,a3
ffffffffc0200672:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200676:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200678:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020067a:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020067c:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200680:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200682:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200684:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc0200688:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020068a:	00004917          	auipc	s2,0x4
ffffffffc020068e:	bd690913          	addi	s2,s2,-1066 # ffffffffc0204260 <commands+0x110>
ffffffffc0200692:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200694:	4d91                	li	s11,4
ffffffffc0200696:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200698:	00004497          	auipc	s1,0x4
ffffffffc020069c:	bc048493          	addi	s1,s1,-1088 # ffffffffc0204258 <commands+0x108>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006a0:	000a2703          	lw	a4,0(s4)
ffffffffc02006a4:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a8:	0087569b          	srliw	a3,a4,0x8
ffffffffc02006ac:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b0:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006b4:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b8:	0107571b          	srliw	a4,a4,0x10
ffffffffc02006bc:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006be:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006c2:	0087171b          	slliw	a4,a4,0x8
ffffffffc02006c6:	8fd5                	or	a5,a5,a3
ffffffffc02006c8:	00eb7733          	and	a4,s6,a4
ffffffffc02006cc:	8fd9                	or	a5,a5,a4
ffffffffc02006ce:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc02006d0:	09778c63          	beq	a5,s7,ffffffffc0200768 <dtb_init+0x1ee>
ffffffffc02006d4:	00fbea63          	bltu	s7,a5,ffffffffc02006e8 <dtb_init+0x16e>
ffffffffc02006d8:	07a78663          	beq	a5,s10,ffffffffc0200744 <dtb_init+0x1ca>
ffffffffc02006dc:	4709                	li	a4,2
ffffffffc02006de:	00e79763          	bne	a5,a4,ffffffffc02006ec <dtb_init+0x172>
ffffffffc02006e2:	4c81                	li	s9,0
ffffffffc02006e4:	8a56                	mv	s4,s5
ffffffffc02006e6:	bf6d                	j	ffffffffc02006a0 <dtb_init+0x126>
ffffffffc02006e8:	ffb78ee3          	beq	a5,s11,ffffffffc02006e4 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02006ec:	00004517          	auipc	a0,0x4
ffffffffc02006f0:	bec50513          	addi	a0,a0,-1044 # ffffffffc02042d8 <commands+0x188>
ffffffffc02006f4:	aa1ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	c1850513          	addi	a0,a0,-1000 # ffffffffc0204310 <commands+0x1c0>
}
ffffffffc0200700:	7446                	ld	s0,112(sp)
ffffffffc0200702:	70e6                	ld	ra,120(sp)
ffffffffc0200704:	74a6                	ld	s1,104(sp)
ffffffffc0200706:	7906                	ld	s2,96(sp)
ffffffffc0200708:	69e6                	ld	s3,88(sp)
ffffffffc020070a:	6a46                	ld	s4,80(sp)
ffffffffc020070c:	6aa6                	ld	s5,72(sp)
ffffffffc020070e:	6b06                	ld	s6,64(sp)
ffffffffc0200710:	7be2                	ld	s7,56(sp)
ffffffffc0200712:	7c42                	ld	s8,48(sp)
ffffffffc0200714:	7ca2                	ld	s9,40(sp)
ffffffffc0200716:	7d02                	ld	s10,32(sp)
ffffffffc0200718:	6de2                	ld	s11,24(sp)
ffffffffc020071a:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc020071c:	bca5                	j	ffffffffc0200194 <cprintf>
}
ffffffffc020071e:	7446                	ld	s0,112(sp)
ffffffffc0200720:	70e6                	ld	ra,120(sp)
ffffffffc0200722:	74a6                	ld	s1,104(sp)
ffffffffc0200724:	7906                	ld	s2,96(sp)
ffffffffc0200726:	69e6                	ld	s3,88(sp)
ffffffffc0200728:	6a46                	ld	s4,80(sp)
ffffffffc020072a:	6aa6                	ld	s5,72(sp)
ffffffffc020072c:	6b06                	ld	s6,64(sp)
ffffffffc020072e:	7be2                	ld	s7,56(sp)
ffffffffc0200730:	7c42                	ld	s8,48(sp)
ffffffffc0200732:	7ca2                	ld	s9,40(sp)
ffffffffc0200734:	7d02                	ld	s10,32(sp)
ffffffffc0200736:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200738:	00004517          	auipc	a0,0x4
ffffffffc020073c:	af850513          	addi	a0,a0,-1288 # ffffffffc0204230 <commands+0xe0>
}
ffffffffc0200740:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200742:	bc89                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc0200744:	8556                	mv	a0,s5
ffffffffc0200746:	6b0030ef          	jal	ra,ffffffffc0203df6 <strlen>
ffffffffc020074a:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020074c:	4619                	li	a2,6
ffffffffc020074e:	85a6                	mv	a1,s1
ffffffffc0200750:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200752:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200754:	708030ef          	jal	ra,ffffffffc0203e5c <strncmp>
ffffffffc0200758:	e111                	bnez	a0,ffffffffc020075c <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc020075a:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020075c:	0a91                	addi	s5,s5,4
ffffffffc020075e:	9ad2                	add	s5,s5,s4
ffffffffc0200760:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200764:	8a56                	mv	s4,s5
ffffffffc0200766:	bf2d                	j	ffffffffc02006a0 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200768:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020076c:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200770:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200774:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200778:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020077c:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200780:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200784:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200788:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020078c:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200790:	00eaeab3          	or	s5,s5,a4
ffffffffc0200794:	00fb77b3          	and	a5,s6,a5
ffffffffc0200798:	00faeab3          	or	s5,s5,a5
ffffffffc020079c:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020079e:	000c9c63          	bnez	s9,ffffffffc02007b6 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02007a2:	1a82                	slli	s5,s5,0x20
ffffffffc02007a4:	00368793          	addi	a5,a3,3
ffffffffc02007a8:	020ada93          	srli	s5,s5,0x20
ffffffffc02007ac:	9abe                	add	s5,s5,a5
ffffffffc02007ae:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007b2:	8a56                	mv	s4,s5
ffffffffc02007b4:	b5f5                	j	ffffffffc02006a0 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007b6:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007ba:	85ca                	mv	a1,s2
ffffffffc02007bc:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007be:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007c2:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007c6:	0187971b          	slliw	a4,a5,0x18
ffffffffc02007ca:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007ce:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02007d2:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007d4:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d8:	0087979b          	slliw	a5,a5,0x8
ffffffffc02007dc:	8d59                	or	a0,a0,a4
ffffffffc02007de:	00fb77b3          	and	a5,s6,a5
ffffffffc02007e2:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02007e4:	1502                	slli	a0,a0,0x20
ffffffffc02007e6:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007e8:	9522                	add	a0,a0,s0
ffffffffc02007ea:	654030ef          	jal	ra,ffffffffc0203e3e <strcmp>
ffffffffc02007ee:	66a2                	ld	a3,8(sp)
ffffffffc02007f0:	f94d                	bnez	a0,ffffffffc02007a2 <dtb_init+0x228>
ffffffffc02007f2:	fb59f8e3          	bgeu	s3,s5,ffffffffc02007a2 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007f6:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007fa:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007fe:	00004517          	auipc	a0,0x4
ffffffffc0200802:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0204268 <commands+0x118>
           fdt32_to_cpu(x >> 32);
ffffffffc0200806:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080a:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc020080e:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200812:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200816:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020081a:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020081e:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200822:	0187d693          	srli	a3,a5,0x18
ffffffffc0200826:	01861f1b          	slliw	t5,a2,0x18
ffffffffc020082a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020082e:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200832:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200836:	010f6f33          	or	t5,t5,a6
ffffffffc020083a:	0187529b          	srliw	t0,a4,0x18
ffffffffc020083e:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200842:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200846:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020084a:	0186f6b3          	and	a3,a3,s8
ffffffffc020084e:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200852:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200856:	0107581b          	srliw	a6,a4,0x10
ffffffffc020085a:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020085e:	8361                	srli	a4,a4,0x18
ffffffffc0200860:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200864:	0105d59b          	srliw	a1,a1,0x10
ffffffffc0200868:	01e6e6b3          	or	a3,a3,t5
ffffffffc020086c:	00cb7633          	and	a2,s6,a2
ffffffffc0200870:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200874:	0085959b          	slliw	a1,a1,0x8
ffffffffc0200878:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020087c:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200880:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200884:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200888:	0088989b          	slliw	a7,a7,0x8
ffffffffc020088c:	011b78b3          	and	a7,s6,a7
ffffffffc0200890:	005eeeb3          	or	t4,t4,t0
ffffffffc0200894:	00c6e733          	or	a4,a3,a2
ffffffffc0200898:	006c6c33          	or	s8,s8,t1
ffffffffc020089c:	010b76b3          	and	a3,s6,a6
ffffffffc02008a0:	00bb7b33          	and	s6,s6,a1
ffffffffc02008a4:	01d7e7b3          	or	a5,a5,t4
ffffffffc02008a8:	016c6b33          	or	s6,s8,s6
ffffffffc02008ac:	01146433          	or	s0,s0,a7
ffffffffc02008b0:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc02008b2:	1702                	slli	a4,a4,0x20
ffffffffc02008b4:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02008b6:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02008b8:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02008ba:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02008bc:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02008c0:	0167eb33          	or	s6,a5,s6
ffffffffc02008c4:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc02008c6:	8cfff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc02008ca:	85a2                	mv	a1,s0
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0204288 <commands+0x138>
ffffffffc02008d4:	8c1ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02008d8:	014b5613          	srli	a2,s6,0x14
ffffffffc02008dc:	85da                	mv	a1,s6
ffffffffc02008de:	00004517          	auipc	a0,0x4
ffffffffc02008e2:	9c250513          	addi	a0,a0,-1598 # ffffffffc02042a0 <commands+0x150>
ffffffffc02008e6:	8afff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008ea:	008b05b3          	add	a1,s6,s0
ffffffffc02008ee:	15fd                	addi	a1,a1,-1
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	9d050513          	addi	a0,a0,-1584 # ffffffffc02042c0 <commands+0x170>
ffffffffc02008f8:	89dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02008fc:	00004517          	auipc	a0,0x4
ffffffffc0200900:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204310 <commands+0x1c0>
        memory_base = mem_base;
ffffffffc0200904:	0000d797          	auipc	a5,0xd
ffffffffc0200908:	b687be23          	sd	s0,-1156(a5) # ffffffffc020d480 <memory_base>
        memory_size = mem_size;
ffffffffc020090c:	0000d797          	auipc	a5,0xd
ffffffffc0200910:	b767be23          	sd	s6,-1156(a5) # ffffffffc020d488 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200914:	b3f5                	j	ffffffffc0200700 <dtb_init+0x186>

ffffffffc0200916 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200916:	0000d517          	auipc	a0,0xd
ffffffffc020091a:	b6a53503          	ld	a0,-1174(a0) # ffffffffc020d480 <memory_base>
ffffffffc020091e:	8082                	ret

ffffffffc0200920 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc0200920:	0000d517          	auipc	a0,0xd
ffffffffc0200924:	b6853503          	ld	a0,-1176(a0) # ffffffffc020d488 <memory_size>
ffffffffc0200928:	8082                	ret

ffffffffc020092a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020092a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020092e:	8082                	ret

ffffffffc0200930 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200930:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200934:	8082                	ret

ffffffffc0200936 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200936:	8082                	ret

ffffffffc0200938 <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200938:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020093c:	00000797          	auipc	a5,0x0
ffffffffc0200940:	3f478793          	addi	a5,a5,1012 # ffffffffc0200d30 <__alltraps>
ffffffffc0200944:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200948:	000407b7          	lui	a5,0x40
ffffffffc020094c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200950:	8082                	ret

ffffffffc0200952 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200952:	610c                	ld	a1,0(a0)
{
ffffffffc0200954:	1141                	addi	sp,sp,-16
ffffffffc0200956:	e022                	sd	s0,0(sp)
ffffffffc0200958:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0204328 <commands+0x1d8>
{
ffffffffc0200962:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200964:	831ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200968:	640c                	ld	a1,8(s0)
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0204340 <commands+0x1f0>
ffffffffc0200972:	823ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200976:	680c                	ld	a1,16(s0)
ffffffffc0200978:	00004517          	auipc	a0,0x4
ffffffffc020097c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204358 <commands+0x208>
ffffffffc0200980:	815ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200984:	6c0c                	ld	a1,24(s0)
ffffffffc0200986:	00004517          	auipc	a0,0x4
ffffffffc020098a:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0204370 <commands+0x220>
ffffffffc020098e:	807ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200992:	700c                	ld	a1,32(s0)
ffffffffc0200994:	00004517          	auipc	a0,0x4
ffffffffc0200998:	9f450513          	addi	a0,a0,-1548 # ffffffffc0204388 <commands+0x238>
ffffffffc020099c:	ff8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02009a0:	740c                	ld	a1,40(s0)
ffffffffc02009a2:	00004517          	auipc	a0,0x4
ffffffffc02009a6:	9fe50513          	addi	a0,a0,-1538 # ffffffffc02043a0 <commands+0x250>
ffffffffc02009aa:	feaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02009ae:	780c                	ld	a1,48(s0)
ffffffffc02009b0:	00004517          	auipc	a0,0x4
ffffffffc02009b4:	a0850513          	addi	a0,a0,-1528 # ffffffffc02043b8 <commands+0x268>
ffffffffc02009b8:	fdcff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02009bc:	7c0c                	ld	a1,56(s0)
ffffffffc02009be:	00004517          	auipc	a0,0x4
ffffffffc02009c2:	a1250513          	addi	a0,a0,-1518 # ffffffffc02043d0 <commands+0x280>
ffffffffc02009c6:	fceff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02009ca:	602c                	ld	a1,64(s0)
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02043e8 <commands+0x298>
ffffffffc02009d4:	fc0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009d8:	642c                	ld	a1,72(s0)
ffffffffc02009da:	00004517          	auipc	a0,0x4
ffffffffc02009de:	a2650513          	addi	a0,a0,-1498 # ffffffffc0204400 <commands+0x2b0>
ffffffffc02009e2:	fb2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009e6:	682c                	ld	a1,80(s0)
ffffffffc02009e8:	00004517          	auipc	a0,0x4
ffffffffc02009ec:	a3050513          	addi	a0,a0,-1488 # ffffffffc0204418 <commands+0x2c8>
ffffffffc02009f0:	fa4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009f4:	6c2c                	ld	a1,88(s0)
ffffffffc02009f6:	00004517          	auipc	a0,0x4
ffffffffc02009fa:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0204430 <commands+0x2e0>
ffffffffc02009fe:	f96ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a02:	702c                	ld	a1,96(s0)
ffffffffc0200a04:	00004517          	auipc	a0,0x4
ffffffffc0200a08:	a4450513          	addi	a0,a0,-1468 # ffffffffc0204448 <commands+0x2f8>
ffffffffc0200a0c:	f88ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a10:	742c                	ld	a1,104(s0)
ffffffffc0200a12:	00004517          	auipc	a0,0x4
ffffffffc0200a16:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0204460 <commands+0x310>
ffffffffc0200a1a:	f7aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a1e:	782c                	ld	a1,112(s0)
ffffffffc0200a20:	00004517          	auipc	a0,0x4
ffffffffc0200a24:	a5850513          	addi	a0,a0,-1448 # ffffffffc0204478 <commands+0x328>
ffffffffc0200a28:	f6cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a2c:	7c2c                	ld	a1,120(s0)
ffffffffc0200a2e:	00004517          	auipc	a0,0x4
ffffffffc0200a32:	a6250513          	addi	a0,a0,-1438 # ffffffffc0204490 <commands+0x340>
ffffffffc0200a36:	f5eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a3a:	604c                	ld	a1,128(s0)
ffffffffc0200a3c:	00004517          	auipc	a0,0x4
ffffffffc0200a40:	a6c50513          	addi	a0,a0,-1428 # ffffffffc02044a8 <commands+0x358>
ffffffffc0200a44:	f50ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a48:	644c                	ld	a1,136(s0)
ffffffffc0200a4a:	00004517          	auipc	a0,0x4
ffffffffc0200a4e:	a7650513          	addi	a0,a0,-1418 # ffffffffc02044c0 <commands+0x370>
ffffffffc0200a52:	f42ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a56:	684c                	ld	a1,144(s0)
ffffffffc0200a58:	00004517          	auipc	a0,0x4
ffffffffc0200a5c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02044d8 <commands+0x388>
ffffffffc0200a60:	f34ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a64:	6c4c                	ld	a1,152(s0)
ffffffffc0200a66:	00004517          	auipc	a0,0x4
ffffffffc0200a6a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc02044f0 <commands+0x3a0>
ffffffffc0200a6e:	f26ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a72:	704c                	ld	a1,160(s0)
ffffffffc0200a74:	00004517          	auipc	a0,0x4
ffffffffc0200a78:	a9450513          	addi	a0,a0,-1388 # ffffffffc0204508 <commands+0x3b8>
ffffffffc0200a7c:	f18ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a80:	744c                	ld	a1,168(s0)
ffffffffc0200a82:	00004517          	auipc	a0,0x4
ffffffffc0200a86:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0204520 <commands+0x3d0>
ffffffffc0200a8a:	f0aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a8e:	784c                	ld	a1,176(s0)
ffffffffc0200a90:	00004517          	auipc	a0,0x4
ffffffffc0200a94:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204538 <commands+0x3e8>
ffffffffc0200a98:	efcff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a9c:	7c4c                	ld	a1,184(s0)
ffffffffc0200a9e:	00004517          	auipc	a0,0x4
ffffffffc0200aa2:	ab250513          	addi	a0,a0,-1358 # ffffffffc0204550 <commands+0x400>
ffffffffc0200aa6:	eeeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200aaa:	606c                	ld	a1,192(s0)
ffffffffc0200aac:	00004517          	auipc	a0,0x4
ffffffffc0200ab0:	abc50513          	addi	a0,a0,-1348 # ffffffffc0204568 <commands+0x418>
ffffffffc0200ab4:	ee0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200ab8:	646c                	ld	a1,200(s0)
ffffffffc0200aba:	00004517          	auipc	a0,0x4
ffffffffc0200abe:	ac650513          	addi	a0,a0,-1338 # ffffffffc0204580 <commands+0x430>
ffffffffc0200ac2:	ed2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200ac6:	686c                	ld	a1,208(s0)
ffffffffc0200ac8:	00004517          	auipc	a0,0x4
ffffffffc0200acc:	ad050513          	addi	a0,a0,-1328 # ffffffffc0204598 <commands+0x448>
ffffffffc0200ad0:	ec4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200ad4:	6c6c                	ld	a1,216(s0)
ffffffffc0200ad6:	00004517          	auipc	a0,0x4
ffffffffc0200ada:	ada50513          	addi	a0,a0,-1318 # ffffffffc02045b0 <commands+0x460>
ffffffffc0200ade:	eb6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ae2:	706c                	ld	a1,224(s0)
ffffffffc0200ae4:	00004517          	auipc	a0,0x4
ffffffffc0200ae8:	ae450513          	addi	a0,a0,-1308 # ffffffffc02045c8 <commands+0x478>
ffffffffc0200aec:	ea8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200af0:	746c                	ld	a1,232(s0)
ffffffffc0200af2:	00004517          	auipc	a0,0x4
ffffffffc0200af6:	aee50513          	addi	a0,a0,-1298 # ffffffffc02045e0 <commands+0x490>
ffffffffc0200afa:	e9aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200afe:	786c                	ld	a1,240(s0)
ffffffffc0200b00:	00004517          	auipc	a0,0x4
ffffffffc0200b04:	af850513          	addi	a0,a0,-1288 # ffffffffc02045f8 <commands+0x4a8>
ffffffffc0200b08:	e8cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b0c:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b0e:	6402                	ld	s0,0(sp)
ffffffffc0200b10:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b12:	00004517          	auipc	a0,0x4
ffffffffc0200b16:	afe50513          	addi	a0,a0,-1282 # ffffffffc0204610 <commands+0x4c0>
}
ffffffffc0200b1a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b1c:	e78ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b20 <print_trapframe>:
{
ffffffffc0200b20:	1141                	addi	sp,sp,-16
ffffffffc0200b22:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b24:	85aa                	mv	a1,a0
{
ffffffffc0200b26:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b28:	00004517          	auipc	a0,0x4
ffffffffc0200b2c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204628 <commands+0x4d8>
{
ffffffffc0200b30:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b32:	e62ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b36:	8522                	mv	a0,s0
ffffffffc0200b38:	e1bff0ef          	jal	ra,ffffffffc0200952 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b3c:	10043583          	ld	a1,256(s0)
ffffffffc0200b40:	00004517          	auipc	a0,0x4
ffffffffc0200b44:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204640 <commands+0x4f0>
ffffffffc0200b48:	e4cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b4c:	10843583          	ld	a1,264(s0)
ffffffffc0200b50:	00004517          	auipc	a0,0x4
ffffffffc0200b54:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204658 <commands+0x508>
ffffffffc0200b58:	e3cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200b5c:	11043583          	ld	a1,272(s0)
ffffffffc0200b60:	00004517          	auipc	a0,0x4
ffffffffc0200b64:	b1050513          	addi	a0,a0,-1264 # ffffffffc0204670 <commands+0x520>
ffffffffc0200b68:	e2cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b6c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b70:	6402                	ld	s0,0(sp)
ffffffffc0200b72:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b74:	00004517          	auipc	a0,0x4
ffffffffc0200b78:	b1450513          	addi	a0,a0,-1260 # ffffffffc0204688 <commands+0x538>
}
ffffffffc0200b7c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b7e:	e16ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b82 <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200b82:	11853783          	ld	a5,280(a0)
ffffffffc0200b86:	472d                	li	a4,11
ffffffffc0200b88:	0786                	slli	a5,a5,0x1
ffffffffc0200b8a:	8385                	srli	a5,a5,0x1
ffffffffc0200b8c:	06f76e63          	bltu	a4,a5,ffffffffc0200c08 <interrupt_handler+0x86>
ffffffffc0200b90:	00004717          	auipc	a4,0x4
ffffffffc0200b94:	bc070713          	addi	a4,a4,-1088 # ffffffffc0204750 <commands+0x600>
ffffffffc0200b98:	078a                	slli	a5,a5,0x2
ffffffffc0200b9a:	97ba                	add	a5,a5,a4
ffffffffc0200b9c:	439c                	lw	a5,0(a5)
ffffffffc0200b9e:	97ba                	add	a5,a5,a4
ffffffffc0200ba0:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200ba2:	00004517          	auipc	a0,0x4
ffffffffc0200ba6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0204700 <commands+0x5b0>
ffffffffc0200baa:	deaff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200bae:	00004517          	auipc	a0,0x4
ffffffffc0200bb2:	b3250513          	addi	a0,a0,-1230 # ffffffffc02046e0 <commands+0x590>
ffffffffc0200bb6:	ddeff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200bba:	00004517          	auipc	a0,0x4
ffffffffc0200bbe:	ae650513          	addi	a0,a0,-1306 # ffffffffc02046a0 <commands+0x550>
ffffffffc0200bc2:	dd2ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200bc6:	00004517          	auipc	a0,0x4
ffffffffc0200bca:	afa50513          	addi	a0,a0,-1286 # ffffffffc02046c0 <commands+0x570>
ffffffffc0200bce:	dc6ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200bd2:	1141                	addi	sp,sp,-16
ffffffffc0200bd4:	e022                	sd	s0,0(sp)
ffffffffc0200bd6:	e406                	sd	ra,8(sp)
        // (1) 设置下一次时钟中断
        clock_set_next_event();

        // (2) 计数器（ticks）加一
        // (3) 判断是否达到了 TICK_NUM (100)
        if (++ticks % TICK_NUM == 0) {
ffffffffc0200bd8:	0000d417          	auipc	s0,0xd
ffffffffc0200bdc:	89840413          	addi	s0,s0,-1896 # ffffffffc020d470 <ticks>
        clock_set_next_event();
ffffffffc0200be0:	90fff0ef          	jal	ra,ffffffffc02004ee <clock_set_next_event>
        if (++ticks % TICK_NUM == 0) {
ffffffffc0200be4:	601c                	ld	a5,0(s0)
ffffffffc0200be6:	06400713          	li	a4,100
ffffffffc0200bea:	0785                	addi	a5,a5,1
ffffffffc0200bec:	02e7f733          	remu	a4,a5,a4
ffffffffc0200bf0:	e01c                	sd	a5,0(s0)
ffffffffc0200bf2:	cf01                	beqz	a4,ffffffffc0200c0a <interrupt_handler+0x88>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200bf4:	60a2                	ld	ra,8(sp)
ffffffffc0200bf6:	6402                	ld	s0,0(sp)
ffffffffc0200bf8:	0141                	addi	sp,sp,16
ffffffffc0200bfa:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200bfc:	00004517          	auipc	a0,0x4
ffffffffc0200c00:	b3450513          	addi	a0,a0,-1228 # ffffffffc0204730 <commands+0x5e0>
ffffffffc0200c04:	d90ff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c08:	bf21                	j	ffffffffc0200b20 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c0a:	06400593          	li	a1,100
ffffffffc0200c0e:	00004517          	auipc	a0,0x4
ffffffffc0200c12:	b1250513          	addi	a0,a0,-1262 # ffffffffc0204720 <commands+0x5d0>
ffffffffc0200c16:	d7eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
            print_count++;
ffffffffc0200c1a:	0000d717          	auipc	a4,0xd
ffffffffc0200c1e:	87670713          	addi	a4,a4,-1930 # ffffffffc020d490 <print_count>
ffffffffc0200c22:	431c                	lw	a5,0(a4)
            if (print_count == 10) {
ffffffffc0200c24:	46a9                	li	a3,10
            print_count++;
ffffffffc0200c26:	0017861b          	addiw	a2,a5,1
ffffffffc0200c2a:	c310                	sw	a2,0(a4)
            if (print_count == 10) {
ffffffffc0200c2c:	00d61863          	bne	a2,a3,ffffffffc0200c3c <interrupt_handler+0xba>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c30:	4501                	li	a0,0
ffffffffc0200c32:	4581                	li	a1,0
ffffffffc0200c34:	4601                	li	a2,0
ffffffffc0200c36:	48a1                	li	a7,8
ffffffffc0200c38:	00000073          	ecall
            if (ticks >= TICK_NUM * 10) {
ffffffffc0200c3c:	6018                	ld	a4,0(s0)
ffffffffc0200c3e:	3e700793          	li	a5,999
ffffffffc0200c42:	fae7f9e3          	bgeu	a5,a4,ffffffffc0200bf4 <interrupt_handler+0x72>
                ticks = 0;
ffffffffc0200c46:	0000d797          	auipc	a5,0xd
ffffffffc0200c4a:	8207b523          	sd	zero,-2006(a5) # ffffffffc020d470 <ticks>
ffffffffc0200c4e:	b75d                	j	ffffffffc0200bf4 <interrupt_handler+0x72>

ffffffffc0200c50 <exception_handler>:

void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c50:	11853783          	ld	a5,280(a0)
ffffffffc0200c54:	473d                	li	a4,15
ffffffffc0200c56:	0cf76563          	bltu	a4,a5,ffffffffc0200d20 <exception_handler+0xd0>
ffffffffc0200c5a:	00004717          	auipc	a4,0x4
ffffffffc0200c5e:	cbe70713          	addi	a4,a4,-834 # ffffffffc0204918 <commands+0x7c8>
ffffffffc0200c62:	078a                	slli	a5,a5,0x2
ffffffffc0200c64:	97ba                	add	a5,a5,a4
ffffffffc0200c66:	439c                	lw	a5,0(a5)
ffffffffc0200c68:	97ba                	add	a5,a5,a4
ffffffffc0200c6a:	8782                	jr	a5
        break;
    case CAUSE_LOAD_PAGE_FAULT:
        cprintf("Load page fault\n");
        break;
    case CAUSE_STORE_PAGE_FAULT:
        cprintf("Store/AMO page fault\n");
ffffffffc0200c6c:	00004517          	auipc	a0,0x4
ffffffffc0200c70:	c9450513          	addi	a0,a0,-876 # ffffffffc0204900 <commands+0x7b0>
ffffffffc0200c74:	d20ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Instruction address misaligned\n");
ffffffffc0200c78:	00004517          	auipc	a0,0x4
ffffffffc0200c7c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204780 <commands+0x630>
ffffffffc0200c80:	d14ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Instruction access fault\n");
ffffffffc0200c84:	00004517          	auipc	a0,0x4
ffffffffc0200c88:	b1c50513          	addi	a0,a0,-1252 # ffffffffc02047a0 <commands+0x650>
ffffffffc0200c8c:	d08ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Illegal instruction\n");
ffffffffc0200c90:	00004517          	auipc	a0,0x4
ffffffffc0200c94:	b3050513          	addi	a0,a0,-1232 # ffffffffc02047c0 <commands+0x670>
ffffffffc0200c98:	cfcff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Breakpoint\n");
ffffffffc0200c9c:	00004517          	auipc	a0,0x4
ffffffffc0200ca0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02047d8 <commands+0x688>
ffffffffc0200ca4:	cf0ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Load address misaligned\n");
ffffffffc0200ca8:	00004517          	auipc	a0,0x4
ffffffffc0200cac:	b4050513          	addi	a0,a0,-1216 # ffffffffc02047e8 <commands+0x698>
ffffffffc0200cb0:	ce4ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Load access fault\n");
ffffffffc0200cb4:	00004517          	auipc	a0,0x4
ffffffffc0200cb8:	b5450513          	addi	a0,a0,-1196 # ffffffffc0204808 <commands+0x6b8>
ffffffffc0200cbc:	cd8ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("AMO address misaligned\n");
ffffffffc0200cc0:	00004517          	auipc	a0,0x4
ffffffffc0200cc4:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204820 <commands+0x6d0>
ffffffffc0200cc8:	cccff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Store/AMO access fault\n");
ffffffffc0200ccc:	00004517          	auipc	a0,0x4
ffffffffc0200cd0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0204838 <commands+0x6e8>
ffffffffc0200cd4:	cc0ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from U-mode\n");
ffffffffc0200cd8:	00004517          	auipc	a0,0x4
ffffffffc0200cdc:	b7850513          	addi	a0,a0,-1160 # ffffffffc0204850 <commands+0x700>
ffffffffc0200ce0:	cb4ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from S-mode\n");
ffffffffc0200ce4:	00004517          	auipc	a0,0x4
ffffffffc0200ce8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0204870 <commands+0x720>
ffffffffc0200cec:	ca8ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from H-mode\n");
ffffffffc0200cf0:	00004517          	auipc	a0,0x4
ffffffffc0200cf4:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204890 <commands+0x740>
ffffffffc0200cf8:	c9cff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200cfc:	00004517          	auipc	a0,0x4
ffffffffc0200d00:	bb450513          	addi	a0,a0,-1100 # ffffffffc02048b0 <commands+0x760>
ffffffffc0200d04:	c90ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Instruction page fault\n");
ffffffffc0200d08:	00004517          	auipc	a0,0x4
ffffffffc0200d0c:	bc850513          	addi	a0,a0,-1080 # ffffffffc02048d0 <commands+0x780>
ffffffffc0200d10:	c84ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Load page fault\n");
ffffffffc0200d14:	00004517          	auipc	a0,0x4
ffffffffc0200d18:	bd450513          	addi	a0,a0,-1068 # ffffffffc02048e8 <commands+0x798>
ffffffffc0200d1c:	c78ff06f          	j	ffffffffc0200194 <cprintf>
        break;
    default:
        print_trapframe(tf);
ffffffffc0200d20:	b501                	j	ffffffffc0200b20 <print_trapframe>

ffffffffc0200d22 <trap>:
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
ffffffffc0200d22:	11853783          	ld	a5,280(a0)
ffffffffc0200d26:	0007c363          	bltz	a5,ffffffffc0200d2c <trap+0xa>
        interrupt_handler(tf);
    }
    else
    {
        // exceptions
        exception_handler(tf);
ffffffffc0200d2a:	b71d                	j	ffffffffc0200c50 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200d2c:	bd99                	j	ffffffffc0200b82 <interrupt_handler>
	...

ffffffffc0200d30 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d30:	14011073          	csrw	sscratch,sp
ffffffffc0200d34:	712d                	addi	sp,sp,-288
ffffffffc0200d36:	e406                	sd	ra,8(sp)
ffffffffc0200d38:	ec0e                	sd	gp,24(sp)
ffffffffc0200d3a:	f012                	sd	tp,32(sp)
ffffffffc0200d3c:	f416                	sd	t0,40(sp)
ffffffffc0200d3e:	f81a                	sd	t1,48(sp)
ffffffffc0200d40:	fc1e                	sd	t2,56(sp)
ffffffffc0200d42:	e0a2                	sd	s0,64(sp)
ffffffffc0200d44:	e4a6                	sd	s1,72(sp)
ffffffffc0200d46:	e8aa                	sd	a0,80(sp)
ffffffffc0200d48:	ecae                	sd	a1,88(sp)
ffffffffc0200d4a:	f0b2                	sd	a2,96(sp)
ffffffffc0200d4c:	f4b6                	sd	a3,104(sp)
ffffffffc0200d4e:	f8ba                	sd	a4,112(sp)
ffffffffc0200d50:	fcbe                	sd	a5,120(sp)
ffffffffc0200d52:	e142                	sd	a6,128(sp)
ffffffffc0200d54:	e546                	sd	a7,136(sp)
ffffffffc0200d56:	e94a                	sd	s2,144(sp)
ffffffffc0200d58:	ed4e                	sd	s3,152(sp)
ffffffffc0200d5a:	f152                	sd	s4,160(sp)
ffffffffc0200d5c:	f556                	sd	s5,168(sp)
ffffffffc0200d5e:	f95a                	sd	s6,176(sp)
ffffffffc0200d60:	fd5e                	sd	s7,184(sp)
ffffffffc0200d62:	e1e2                	sd	s8,192(sp)
ffffffffc0200d64:	e5e6                	sd	s9,200(sp)
ffffffffc0200d66:	e9ea                	sd	s10,208(sp)
ffffffffc0200d68:	edee                	sd	s11,216(sp)
ffffffffc0200d6a:	f1f2                	sd	t3,224(sp)
ffffffffc0200d6c:	f5f6                	sd	t4,232(sp)
ffffffffc0200d6e:	f9fa                	sd	t5,240(sp)
ffffffffc0200d70:	fdfe                	sd	t6,248(sp)
ffffffffc0200d72:	14002473          	csrr	s0,sscratch
ffffffffc0200d76:	100024f3          	csrr	s1,sstatus
ffffffffc0200d7a:	14102973          	csrr	s2,sepc
ffffffffc0200d7e:	143029f3          	csrr	s3,stval
ffffffffc0200d82:	14202a73          	csrr	s4,scause
ffffffffc0200d86:	e822                	sd	s0,16(sp)
ffffffffc0200d88:	e226                	sd	s1,256(sp)
ffffffffc0200d8a:	e64a                	sd	s2,264(sp)
ffffffffc0200d8c:	ea4e                	sd	s3,272(sp)
ffffffffc0200d8e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d90:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d92:	f91ff0ef          	jal	ra,ffffffffc0200d22 <trap>

ffffffffc0200d96 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d96:	6492                	ld	s1,256(sp)
ffffffffc0200d98:	6932                	ld	s2,264(sp)
ffffffffc0200d9a:	10049073          	csrw	sstatus,s1
ffffffffc0200d9e:	14191073          	csrw	sepc,s2
ffffffffc0200da2:	60a2                	ld	ra,8(sp)
ffffffffc0200da4:	61e2                	ld	gp,24(sp)
ffffffffc0200da6:	7202                	ld	tp,32(sp)
ffffffffc0200da8:	72a2                	ld	t0,40(sp)
ffffffffc0200daa:	7342                	ld	t1,48(sp)
ffffffffc0200dac:	73e2                	ld	t2,56(sp)
ffffffffc0200dae:	6406                	ld	s0,64(sp)
ffffffffc0200db0:	64a6                	ld	s1,72(sp)
ffffffffc0200db2:	6546                	ld	a0,80(sp)
ffffffffc0200db4:	65e6                	ld	a1,88(sp)
ffffffffc0200db6:	7606                	ld	a2,96(sp)
ffffffffc0200db8:	76a6                	ld	a3,104(sp)
ffffffffc0200dba:	7746                	ld	a4,112(sp)
ffffffffc0200dbc:	77e6                	ld	a5,120(sp)
ffffffffc0200dbe:	680a                	ld	a6,128(sp)
ffffffffc0200dc0:	68aa                	ld	a7,136(sp)
ffffffffc0200dc2:	694a                	ld	s2,144(sp)
ffffffffc0200dc4:	69ea                	ld	s3,152(sp)
ffffffffc0200dc6:	7a0a                	ld	s4,160(sp)
ffffffffc0200dc8:	7aaa                	ld	s5,168(sp)
ffffffffc0200dca:	7b4a                	ld	s6,176(sp)
ffffffffc0200dcc:	7bea                	ld	s7,184(sp)
ffffffffc0200dce:	6c0e                	ld	s8,192(sp)
ffffffffc0200dd0:	6cae                	ld	s9,200(sp)
ffffffffc0200dd2:	6d4e                	ld	s10,208(sp)
ffffffffc0200dd4:	6dee                	ld	s11,216(sp)
ffffffffc0200dd6:	7e0e                	ld	t3,224(sp)
ffffffffc0200dd8:	7eae                	ld	t4,232(sp)
ffffffffc0200dda:	7f4e                	ld	t5,240(sp)
ffffffffc0200ddc:	7fee                	ld	t6,248(sp)
ffffffffc0200dde:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200de0:	10200073          	sret

ffffffffc0200de4 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200de4:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200de6:	bf45                	j	ffffffffc0200d96 <__trapret>
	...

ffffffffc0200dea <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200dea:	00008797          	auipc	a5,0x8
ffffffffc0200dee:	64678793          	addi	a5,a5,1606 # ffffffffc0209430 <free_area>
ffffffffc0200df2:	e79c                	sd	a5,8(a5)
ffffffffc0200df4:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200df6:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200dfa:	8082                	ret

ffffffffc0200dfc <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200dfc:	00008517          	auipc	a0,0x8
ffffffffc0200e00:	64456503          	lwu	a0,1604(a0) # ffffffffc0209440 <free_area+0x10>
ffffffffc0200e04:	8082                	ret

ffffffffc0200e06 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e06:	715d                	addi	sp,sp,-80
ffffffffc0200e08:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e0a:	00008417          	auipc	s0,0x8
ffffffffc0200e0e:	62640413          	addi	s0,s0,1574 # ffffffffc0209430 <free_area>
ffffffffc0200e12:	641c                	ld	a5,8(s0)
ffffffffc0200e14:	e486                	sd	ra,72(sp)
ffffffffc0200e16:	fc26                	sd	s1,56(sp)
ffffffffc0200e18:	f84a                	sd	s2,48(sp)
ffffffffc0200e1a:	f44e                	sd	s3,40(sp)
ffffffffc0200e1c:	f052                	sd	s4,32(sp)
ffffffffc0200e1e:	ec56                	sd	s5,24(sp)
ffffffffc0200e20:	e85a                	sd	s6,16(sp)
ffffffffc0200e22:	e45e                	sd	s7,8(sp)
ffffffffc0200e24:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e26:	2a878d63          	beq	a5,s0,ffffffffc02010e0 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e2a:	4481                	li	s1,0
ffffffffc0200e2c:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e2e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e32:	8b09                	andi	a4,a4,2
ffffffffc0200e34:	2a070a63          	beqz	a4,ffffffffc02010e8 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e38:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e3c:	679c                	ld	a5,8(a5)
ffffffffc0200e3e:	2905                	addiw	s2,s2,1
ffffffffc0200e40:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e42:	fe8796e3          	bne	a5,s0,ffffffffc0200e2e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e46:	89a6                	mv	s3,s1
ffffffffc0200e48:	6db000ef          	jal	ra,ffffffffc0201d22 <nr_free_pages>
ffffffffc0200e4c:	6f351e63          	bne	a0,s3,ffffffffc0201548 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e50:	4505                	li	a0,1
ffffffffc0200e52:	653000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200e56:	8aaa                	mv	s5,a0
ffffffffc0200e58:	42050863          	beqz	a0,ffffffffc0201288 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e5c:	4505                	li	a0,1
ffffffffc0200e5e:	647000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200e62:	89aa                	mv	s3,a0
ffffffffc0200e64:	70050263          	beqz	a0,ffffffffc0201568 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e68:	4505                	li	a0,1
ffffffffc0200e6a:	63b000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200e6e:	8a2a                	mv	s4,a0
ffffffffc0200e70:	48050c63          	beqz	a0,ffffffffc0201308 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e74:	293a8a63          	beq	s5,s3,ffffffffc0201108 <default_check+0x302>
ffffffffc0200e78:	28aa8863          	beq	s5,a0,ffffffffc0201108 <default_check+0x302>
ffffffffc0200e7c:	28a98663          	beq	s3,a0,ffffffffc0201108 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e80:	000aa783          	lw	a5,0(s5)
ffffffffc0200e84:	2a079263          	bnez	a5,ffffffffc0201128 <default_check+0x322>
ffffffffc0200e88:	0009a783          	lw	a5,0(s3)
ffffffffc0200e8c:	28079e63          	bnez	a5,ffffffffc0201128 <default_check+0x322>
ffffffffc0200e90:	411c                	lw	a5,0(a0)
ffffffffc0200e92:	28079b63          	bnez	a5,ffffffffc0201128 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200e96:	0000c797          	auipc	a5,0xc
ffffffffc0200e9a:	6227b783          	ld	a5,1570(a5) # ffffffffc020d4b8 <pages>
ffffffffc0200e9e:	40fa8733          	sub	a4,s5,a5
ffffffffc0200ea2:	00005617          	auipc	a2,0x5
ffffffffc0200ea6:	b8e63603          	ld	a2,-1138(a2) # ffffffffc0205a30 <nbase>
ffffffffc0200eaa:	8719                	srai	a4,a4,0x6
ffffffffc0200eac:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eae:	0000c697          	auipc	a3,0xc
ffffffffc0200eb2:	6026b683          	ld	a3,1538(a3) # ffffffffc020d4b0 <npage>
ffffffffc0200eb6:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eb8:	0732                	slli	a4,a4,0xc
ffffffffc0200eba:	28d77763          	bgeu	a4,a3,ffffffffc0201148 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ebe:	40f98733          	sub	a4,s3,a5
ffffffffc0200ec2:	8719                	srai	a4,a4,0x6
ffffffffc0200ec4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ec6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ec8:	4cd77063          	bgeu	a4,a3,ffffffffc0201388 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200ecc:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ed0:	8799                	srai	a5,a5,0x6
ffffffffc0200ed2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ed4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ed6:	30d7f963          	bgeu	a5,a3,ffffffffc02011e8 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200eda:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200edc:	00043c03          	ld	s8,0(s0)
ffffffffc0200ee0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ee4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200ee8:	e400                	sd	s0,8(s0)
ffffffffc0200eea:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200eec:	00008797          	auipc	a5,0x8
ffffffffc0200ef0:	5407aa23          	sw	zero,1364(a5) # ffffffffc0209440 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	5b1000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200ef8:	2c051863          	bnez	a0,ffffffffc02011c8 <default_check+0x3c2>
    free_page(p0);
ffffffffc0200efc:	4585                	li	a1,1
ffffffffc0200efe:	8556                	mv	a0,s5
ffffffffc0200f00:	5e3000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    free_page(p1);
ffffffffc0200f04:	4585                	li	a1,1
ffffffffc0200f06:	854e                	mv	a0,s3
ffffffffc0200f08:	5db000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    free_page(p2);
ffffffffc0200f0c:	4585                	li	a1,1
ffffffffc0200f0e:	8552                	mv	a0,s4
ffffffffc0200f10:	5d3000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f14:	4818                	lw	a4,16(s0)
ffffffffc0200f16:	478d                	li	a5,3
ffffffffc0200f18:	28f71863          	bne	a4,a5,ffffffffc02011a8 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f1c:	4505                	li	a0,1
ffffffffc0200f1e:	587000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200f22:	89aa                	mv	s3,a0
ffffffffc0200f24:	26050263          	beqz	a0,ffffffffc0201188 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f28:	4505                	li	a0,1
ffffffffc0200f2a:	57b000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200f2e:	8aaa                	mv	s5,a0
ffffffffc0200f30:	3a050c63          	beqz	a0,ffffffffc02012e8 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f34:	4505                	li	a0,1
ffffffffc0200f36:	56f000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200f3a:	8a2a                	mv	s4,a0
ffffffffc0200f3c:	38050663          	beqz	a0,ffffffffc02012c8 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f40:	4505                	li	a0,1
ffffffffc0200f42:	563000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200f46:	36051163          	bnez	a0,ffffffffc02012a8 <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f4a:	4585                	li	a1,1
ffffffffc0200f4c:	854e                	mv	a0,s3
ffffffffc0200f4e:	595000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f52:	641c                	ld	a5,8(s0)
ffffffffc0200f54:	20878a63          	beq	a5,s0,ffffffffc0201168 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f58:	4505                	li	a0,1
ffffffffc0200f5a:	54b000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200f5e:	30a99563          	bne	s3,a0,ffffffffc0201268 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f62:	4505                	li	a0,1
ffffffffc0200f64:	541000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200f68:	2e051063          	bnez	a0,ffffffffc0201248 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200f6c:	481c                	lw	a5,16(s0)
ffffffffc0200f6e:	2a079d63          	bnez	a5,ffffffffc0201228 <default_check+0x422>
    free_page(p);
ffffffffc0200f72:	854e                	mv	a0,s3
ffffffffc0200f74:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f76:	01843023          	sd	s8,0(s0)
ffffffffc0200f7a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f7e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f82:	561000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    free_page(p1);
ffffffffc0200f86:	4585                	li	a1,1
ffffffffc0200f88:	8556                	mv	a0,s5
ffffffffc0200f8a:	559000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    free_page(p2);
ffffffffc0200f8e:	4585                	li	a1,1
ffffffffc0200f90:	8552                	mv	a0,s4
ffffffffc0200f92:	551000ef          	jal	ra,ffffffffc0201ce2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200f96:	4515                	li	a0,5
ffffffffc0200f98:	50d000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200f9c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200f9e:	26050563          	beqz	a0,ffffffffc0201208 <default_check+0x402>
ffffffffc0200fa2:	651c                	ld	a5,8(a0)
ffffffffc0200fa4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200fa6:	8b85                	andi	a5,a5,1
ffffffffc0200fa8:	54079063          	bnez	a5,ffffffffc02014e8 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fac:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fae:	00043b03          	ld	s6,0(s0)
ffffffffc0200fb2:	00843a83          	ld	s5,8(s0)
ffffffffc0200fb6:	e000                	sd	s0,0(s0)
ffffffffc0200fb8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200fba:	4eb000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200fbe:	50051563          	bnez	a0,ffffffffc02014c8 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200fc2:	08098a13          	addi	s4,s3,128
ffffffffc0200fc6:	8552                	mv	a0,s4
ffffffffc0200fc8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200fca:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200fce:	00008797          	auipc	a5,0x8
ffffffffc0200fd2:	4607a923          	sw	zero,1138(a5) # ffffffffc0209440 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200fd6:	50d000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fda:	4511                	li	a0,4
ffffffffc0200fdc:	4c9000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0200fe0:	4c051463          	bnez	a0,ffffffffc02014a8 <default_check+0x6a2>
ffffffffc0200fe4:	0889b783          	ld	a5,136(s3)
ffffffffc0200fe8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200fea:	8b85                	andi	a5,a5,1
ffffffffc0200fec:	48078e63          	beqz	a5,ffffffffc0201488 <default_check+0x682>
ffffffffc0200ff0:	0909a703          	lw	a4,144(s3)
ffffffffc0200ff4:	478d                	li	a5,3
ffffffffc0200ff6:	48f71963          	bne	a4,a5,ffffffffc0201488 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200ffa:	450d                	li	a0,3
ffffffffc0200ffc:	4a9000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0201000:	8c2a                	mv	s8,a0
ffffffffc0201002:	46050363          	beqz	a0,ffffffffc0201468 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201006:	4505                	li	a0,1
ffffffffc0201008:	49d000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc020100c:	42051e63          	bnez	a0,ffffffffc0201448 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201010:	418a1c63          	bne	s4,s8,ffffffffc0201428 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201014:	4585                	li	a1,1
ffffffffc0201016:	854e                	mv	a0,s3
ffffffffc0201018:	4cb000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    free_pages(p1, 3);
ffffffffc020101c:	458d                	li	a1,3
ffffffffc020101e:	8552                	mv	a0,s4
ffffffffc0201020:	4c3000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
ffffffffc0201024:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201028:	04098c13          	addi	s8,s3,64
ffffffffc020102c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020102e:	8b85                	andi	a5,a5,1
ffffffffc0201030:	3c078c63          	beqz	a5,ffffffffc0201408 <default_check+0x602>
ffffffffc0201034:	0109a703          	lw	a4,16(s3)
ffffffffc0201038:	4785                	li	a5,1
ffffffffc020103a:	3cf71763          	bne	a4,a5,ffffffffc0201408 <default_check+0x602>
ffffffffc020103e:	008a3783          	ld	a5,8(s4)
ffffffffc0201042:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201044:	8b85                	andi	a5,a5,1
ffffffffc0201046:	3a078163          	beqz	a5,ffffffffc02013e8 <default_check+0x5e2>
ffffffffc020104a:	010a2703          	lw	a4,16(s4)
ffffffffc020104e:	478d                	li	a5,3
ffffffffc0201050:	38f71c63          	bne	a4,a5,ffffffffc02013e8 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201054:	4505                	li	a0,1
ffffffffc0201056:	44f000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc020105a:	36a99763          	bne	s3,a0,ffffffffc02013c8 <default_check+0x5c2>
    free_page(p0);
ffffffffc020105e:	4585                	li	a1,1
ffffffffc0201060:	483000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201064:	4509                	li	a0,2
ffffffffc0201066:	43f000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc020106a:	32aa1f63          	bne	s4,a0,ffffffffc02013a8 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020106e:	4589                	li	a1,2
ffffffffc0201070:	473000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    free_page(p2);
ffffffffc0201074:	4585                	li	a1,1
ffffffffc0201076:	8562                	mv	a0,s8
ffffffffc0201078:	46b000ef          	jal	ra,ffffffffc0201ce2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020107c:	4515                	li	a0,5
ffffffffc020107e:	427000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc0201082:	89aa                	mv	s3,a0
ffffffffc0201084:	48050263          	beqz	a0,ffffffffc0201508 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201088:	4505                	li	a0,1
ffffffffc020108a:	41b000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
ffffffffc020108e:	2c051d63          	bnez	a0,ffffffffc0201368 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0201092:	481c                	lw	a5,16(s0)
ffffffffc0201094:	2a079a63          	bnez	a5,ffffffffc0201348 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201098:	4595                	li	a1,5
ffffffffc020109a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020109c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02010a0:	01643023          	sd	s6,0(s0)
ffffffffc02010a4:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02010a8:	43b000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
    return listelm->next;
ffffffffc02010ac:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010ae:	00878963          	beq	a5,s0,ffffffffc02010c0 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010b2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010b6:	679c                	ld	a5,8(a5)
ffffffffc02010b8:	397d                	addiw	s2,s2,-1
ffffffffc02010ba:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010bc:	fe879be3          	bne	a5,s0,ffffffffc02010b2 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010c0:	26091463          	bnez	s2,ffffffffc0201328 <default_check+0x522>
    assert(total == 0);
ffffffffc02010c4:	46049263          	bnez	s1,ffffffffc0201528 <default_check+0x722>
}
ffffffffc02010c8:	60a6                	ld	ra,72(sp)
ffffffffc02010ca:	6406                	ld	s0,64(sp)
ffffffffc02010cc:	74e2                	ld	s1,56(sp)
ffffffffc02010ce:	7942                	ld	s2,48(sp)
ffffffffc02010d0:	79a2                	ld	s3,40(sp)
ffffffffc02010d2:	7a02                	ld	s4,32(sp)
ffffffffc02010d4:	6ae2                	ld	s5,24(sp)
ffffffffc02010d6:	6b42                	ld	s6,16(sp)
ffffffffc02010d8:	6ba2                	ld	s7,8(sp)
ffffffffc02010da:	6c02                	ld	s8,0(sp)
ffffffffc02010dc:	6161                	addi	sp,sp,80
ffffffffc02010de:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010e0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02010e2:	4481                	li	s1,0
ffffffffc02010e4:	4901                	li	s2,0
ffffffffc02010e6:	b38d                	j	ffffffffc0200e48 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	87068693          	addi	a3,a3,-1936 # ffffffffc0204958 <commands+0x808>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	87860613          	addi	a2,a2,-1928 # ffffffffc0204968 <commands+0x818>
ffffffffc02010f8:	0f000593          	li	a1,240
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	88450513          	addi	a0,a0,-1916 # ffffffffc0204980 <commands+0x830>
ffffffffc0201104:	b56ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	91068693          	addi	a3,a3,-1776 # ffffffffc0204a18 <commands+0x8c8>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	85860613          	addi	a2,a2,-1960 # ffffffffc0204968 <commands+0x818>
ffffffffc0201118:	0bd00593          	li	a1,189
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	86450513          	addi	a0,a0,-1948 # ffffffffc0204980 <commands+0x830>
ffffffffc0201124:	b36ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	91868693          	addi	a3,a3,-1768 # ffffffffc0204a40 <commands+0x8f0>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	83860613          	addi	a2,a2,-1992 # ffffffffc0204968 <commands+0x818>
ffffffffc0201138:	0be00593          	li	a1,190
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	84450513          	addi	a0,a0,-1980 # ffffffffc0204980 <commands+0x830>
ffffffffc0201144:	b16ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	93868693          	addi	a3,a3,-1736 # ffffffffc0204a80 <commands+0x930>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	81860613          	addi	a2,a2,-2024 # ffffffffc0204968 <commands+0x818>
ffffffffc0201158:	0c000593          	li	a1,192
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	82450513          	addi	a0,a0,-2012 # ffffffffc0204980 <commands+0x830>
ffffffffc0201164:	af6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201168:	00004697          	auipc	a3,0x4
ffffffffc020116c:	9a068693          	addi	a3,a3,-1632 # ffffffffc0204b08 <commands+0x9b8>
ffffffffc0201170:	00003617          	auipc	a2,0x3
ffffffffc0201174:	7f860613          	addi	a2,a2,2040 # ffffffffc0204968 <commands+0x818>
ffffffffc0201178:	0d900593          	li	a1,217
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	80450513          	addi	a0,a0,-2044 # ffffffffc0204980 <commands+0x830>
ffffffffc0201184:	ad6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201188:	00004697          	auipc	a3,0x4
ffffffffc020118c:	83068693          	addi	a3,a3,-2000 # ffffffffc02049b8 <commands+0x868>
ffffffffc0201190:	00003617          	auipc	a2,0x3
ffffffffc0201194:	7d860613          	addi	a2,a2,2008 # ffffffffc0204968 <commands+0x818>
ffffffffc0201198:	0d200593          	li	a1,210
ffffffffc020119c:	00003517          	auipc	a0,0x3
ffffffffc02011a0:	7e450513          	addi	a0,a0,2020 # ffffffffc0204980 <commands+0x830>
ffffffffc02011a4:	ab6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(nr_free == 3);
ffffffffc02011a8:	00004697          	auipc	a3,0x4
ffffffffc02011ac:	95068693          	addi	a3,a3,-1712 # ffffffffc0204af8 <commands+0x9a8>
ffffffffc02011b0:	00003617          	auipc	a2,0x3
ffffffffc02011b4:	7b860613          	addi	a2,a2,1976 # ffffffffc0204968 <commands+0x818>
ffffffffc02011b8:	0d000593          	li	a1,208
ffffffffc02011bc:	00003517          	auipc	a0,0x3
ffffffffc02011c0:	7c450513          	addi	a0,a0,1988 # ffffffffc0204980 <commands+0x830>
ffffffffc02011c4:	a96ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011c8:	00004697          	auipc	a3,0x4
ffffffffc02011cc:	91868693          	addi	a3,a3,-1768 # ffffffffc0204ae0 <commands+0x990>
ffffffffc02011d0:	00003617          	auipc	a2,0x3
ffffffffc02011d4:	79860613          	addi	a2,a2,1944 # ffffffffc0204968 <commands+0x818>
ffffffffc02011d8:	0cb00593          	li	a1,203
ffffffffc02011dc:	00003517          	auipc	a0,0x3
ffffffffc02011e0:	7a450513          	addi	a0,a0,1956 # ffffffffc0204980 <commands+0x830>
ffffffffc02011e4:	a76ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	8d868693          	addi	a3,a3,-1832 # ffffffffc0204ac0 <commands+0x970>
ffffffffc02011f0:	00003617          	auipc	a2,0x3
ffffffffc02011f4:	77860613          	addi	a2,a2,1912 # ffffffffc0204968 <commands+0x818>
ffffffffc02011f8:	0c200593          	li	a1,194
ffffffffc02011fc:	00003517          	auipc	a0,0x3
ffffffffc0201200:	78450513          	addi	a0,a0,1924 # ffffffffc0204980 <commands+0x830>
ffffffffc0201204:	a56ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(p0 != NULL);
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	94868693          	addi	a3,a3,-1720 # ffffffffc0204b50 <commands+0xa00>
ffffffffc0201210:	00003617          	auipc	a2,0x3
ffffffffc0201214:	75860613          	addi	a2,a2,1880 # ffffffffc0204968 <commands+0x818>
ffffffffc0201218:	0f800593          	li	a1,248
ffffffffc020121c:	00003517          	auipc	a0,0x3
ffffffffc0201220:	76450513          	addi	a0,a0,1892 # ffffffffc0204980 <commands+0x830>
ffffffffc0201224:	a36ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(nr_free == 0);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	91868693          	addi	a3,a3,-1768 # ffffffffc0204b40 <commands+0x9f0>
ffffffffc0201230:	00003617          	auipc	a2,0x3
ffffffffc0201234:	73860613          	addi	a2,a2,1848 # ffffffffc0204968 <commands+0x818>
ffffffffc0201238:	0df00593          	li	a1,223
ffffffffc020123c:	00003517          	auipc	a0,0x3
ffffffffc0201240:	74450513          	addi	a0,a0,1860 # ffffffffc0204980 <commands+0x830>
ffffffffc0201244:	a16ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	89868693          	addi	a3,a3,-1896 # ffffffffc0204ae0 <commands+0x990>
ffffffffc0201250:	00003617          	auipc	a2,0x3
ffffffffc0201254:	71860613          	addi	a2,a2,1816 # ffffffffc0204968 <commands+0x818>
ffffffffc0201258:	0dd00593          	li	a1,221
ffffffffc020125c:	00003517          	auipc	a0,0x3
ffffffffc0201260:	72450513          	addi	a0,a0,1828 # ffffffffc0204980 <commands+0x830>
ffffffffc0201264:	9f6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201268:	00004697          	auipc	a3,0x4
ffffffffc020126c:	8b868693          	addi	a3,a3,-1864 # ffffffffc0204b20 <commands+0x9d0>
ffffffffc0201270:	00003617          	auipc	a2,0x3
ffffffffc0201274:	6f860613          	addi	a2,a2,1784 # ffffffffc0204968 <commands+0x818>
ffffffffc0201278:	0dc00593          	li	a1,220
ffffffffc020127c:	00003517          	auipc	a0,0x3
ffffffffc0201280:	70450513          	addi	a0,a0,1796 # ffffffffc0204980 <commands+0x830>
ffffffffc0201284:	9d6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201288:	00003697          	auipc	a3,0x3
ffffffffc020128c:	73068693          	addi	a3,a3,1840 # ffffffffc02049b8 <commands+0x868>
ffffffffc0201290:	00003617          	auipc	a2,0x3
ffffffffc0201294:	6d860613          	addi	a2,a2,1752 # ffffffffc0204968 <commands+0x818>
ffffffffc0201298:	0b900593          	li	a1,185
ffffffffc020129c:	00003517          	auipc	a0,0x3
ffffffffc02012a0:	6e450513          	addi	a0,a0,1764 # ffffffffc0204980 <commands+0x830>
ffffffffc02012a4:	9b6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012a8:	00004697          	auipc	a3,0x4
ffffffffc02012ac:	83868693          	addi	a3,a3,-1992 # ffffffffc0204ae0 <commands+0x990>
ffffffffc02012b0:	00003617          	auipc	a2,0x3
ffffffffc02012b4:	6b860613          	addi	a2,a2,1720 # ffffffffc0204968 <commands+0x818>
ffffffffc02012b8:	0d600593          	li	a1,214
ffffffffc02012bc:	00003517          	auipc	a0,0x3
ffffffffc02012c0:	6c450513          	addi	a0,a0,1732 # ffffffffc0204980 <commands+0x830>
ffffffffc02012c4:	996ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012c8:	00003697          	auipc	a3,0x3
ffffffffc02012cc:	73068693          	addi	a3,a3,1840 # ffffffffc02049f8 <commands+0x8a8>
ffffffffc02012d0:	00003617          	auipc	a2,0x3
ffffffffc02012d4:	69860613          	addi	a2,a2,1688 # ffffffffc0204968 <commands+0x818>
ffffffffc02012d8:	0d400593          	li	a1,212
ffffffffc02012dc:	00003517          	auipc	a0,0x3
ffffffffc02012e0:	6a450513          	addi	a0,a0,1700 # ffffffffc0204980 <commands+0x830>
ffffffffc02012e4:	976ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012e8:	00003697          	auipc	a3,0x3
ffffffffc02012ec:	6f068693          	addi	a3,a3,1776 # ffffffffc02049d8 <commands+0x888>
ffffffffc02012f0:	00003617          	auipc	a2,0x3
ffffffffc02012f4:	67860613          	addi	a2,a2,1656 # ffffffffc0204968 <commands+0x818>
ffffffffc02012f8:	0d300593          	li	a1,211
ffffffffc02012fc:	00003517          	auipc	a0,0x3
ffffffffc0201300:	68450513          	addi	a0,a0,1668 # ffffffffc0204980 <commands+0x830>
ffffffffc0201304:	956ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201308:	00003697          	auipc	a3,0x3
ffffffffc020130c:	6f068693          	addi	a3,a3,1776 # ffffffffc02049f8 <commands+0x8a8>
ffffffffc0201310:	00003617          	auipc	a2,0x3
ffffffffc0201314:	65860613          	addi	a2,a2,1624 # ffffffffc0204968 <commands+0x818>
ffffffffc0201318:	0bb00593          	li	a1,187
ffffffffc020131c:	00003517          	auipc	a0,0x3
ffffffffc0201320:	66450513          	addi	a0,a0,1636 # ffffffffc0204980 <commands+0x830>
ffffffffc0201324:	936ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(count == 0);
ffffffffc0201328:	00004697          	auipc	a3,0x4
ffffffffc020132c:	97868693          	addi	a3,a3,-1672 # ffffffffc0204ca0 <commands+0xb50>
ffffffffc0201330:	00003617          	auipc	a2,0x3
ffffffffc0201334:	63860613          	addi	a2,a2,1592 # ffffffffc0204968 <commands+0x818>
ffffffffc0201338:	12500593          	li	a1,293
ffffffffc020133c:	00003517          	auipc	a0,0x3
ffffffffc0201340:	64450513          	addi	a0,a0,1604 # ffffffffc0204980 <commands+0x830>
ffffffffc0201344:	916ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(nr_free == 0);
ffffffffc0201348:	00003697          	auipc	a3,0x3
ffffffffc020134c:	7f868693          	addi	a3,a3,2040 # ffffffffc0204b40 <commands+0x9f0>
ffffffffc0201350:	00003617          	auipc	a2,0x3
ffffffffc0201354:	61860613          	addi	a2,a2,1560 # ffffffffc0204968 <commands+0x818>
ffffffffc0201358:	11a00593          	li	a1,282
ffffffffc020135c:	00003517          	auipc	a0,0x3
ffffffffc0201360:	62450513          	addi	a0,a0,1572 # ffffffffc0204980 <commands+0x830>
ffffffffc0201364:	8f6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201368:	00003697          	auipc	a3,0x3
ffffffffc020136c:	77868693          	addi	a3,a3,1912 # ffffffffc0204ae0 <commands+0x990>
ffffffffc0201370:	00003617          	auipc	a2,0x3
ffffffffc0201374:	5f860613          	addi	a2,a2,1528 # ffffffffc0204968 <commands+0x818>
ffffffffc0201378:	11800593          	li	a1,280
ffffffffc020137c:	00003517          	auipc	a0,0x3
ffffffffc0201380:	60450513          	addi	a0,a0,1540 # ffffffffc0204980 <commands+0x830>
ffffffffc0201384:	8d6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201388:	00003697          	auipc	a3,0x3
ffffffffc020138c:	71868693          	addi	a3,a3,1816 # ffffffffc0204aa0 <commands+0x950>
ffffffffc0201390:	00003617          	auipc	a2,0x3
ffffffffc0201394:	5d860613          	addi	a2,a2,1496 # ffffffffc0204968 <commands+0x818>
ffffffffc0201398:	0c100593          	li	a1,193
ffffffffc020139c:	00003517          	auipc	a0,0x3
ffffffffc02013a0:	5e450513          	addi	a0,a0,1508 # ffffffffc0204980 <commands+0x830>
ffffffffc02013a4:	8b6ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013a8:	00004697          	auipc	a3,0x4
ffffffffc02013ac:	8b868693          	addi	a3,a3,-1864 # ffffffffc0204c60 <commands+0xb10>
ffffffffc02013b0:	00003617          	auipc	a2,0x3
ffffffffc02013b4:	5b860613          	addi	a2,a2,1464 # ffffffffc0204968 <commands+0x818>
ffffffffc02013b8:	11200593          	li	a1,274
ffffffffc02013bc:	00003517          	auipc	a0,0x3
ffffffffc02013c0:	5c450513          	addi	a0,a0,1476 # ffffffffc0204980 <commands+0x830>
ffffffffc02013c4:	896ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013c8:	00004697          	auipc	a3,0x4
ffffffffc02013cc:	87868693          	addi	a3,a3,-1928 # ffffffffc0204c40 <commands+0xaf0>
ffffffffc02013d0:	00003617          	auipc	a2,0x3
ffffffffc02013d4:	59860613          	addi	a2,a2,1432 # ffffffffc0204968 <commands+0x818>
ffffffffc02013d8:	11000593          	li	a1,272
ffffffffc02013dc:	00003517          	auipc	a0,0x3
ffffffffc02013e0:	5a450513          	addi	a0,a0,1444 # ffffffffc0204980 <commands+0x830>
ffffffffc02013e4:	876ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02013e8:	00004697          	auipc	a3,0x4
ffffffffc02013ec:	83068693          	addi	a3,a3,-2000 # ffffffffc0204c18 <commands+0xac8>
ffffffffc02013f0:	00003617          	auipc	a2,0x3
ffffffffc02013f4:	57860613          	addi	a2,a2,1400 # ffffffffc0204968 <commands+0x818>
ffffffffc02013f8:	10e00593          	li	a1,270
ffffffffc02013fc:	00003517          	auipc	a0,0x3
ffffffffc0201400:	58450513          	addi	a0,a0,1412 # ffffffffc0204980 <commands+0x830>
ffffffffc0201404:	856ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201408:	00003697          	auipc	a3,0x3
ffffffffc020140c:	7e868693          	addi	a3,a3,2024 # ffffffffc0204bf0 <commands+0xaa0>
ffffffffc0201410:	00003617          	auipc	a2,0x3
ffffffffc0201414:	55860613          	addi	a2,a2,1368 # ffffffffc0204968 <commands+0x818>
ffffffffc0201418:	10d00593          	li	a1,269
ffffffffc020141c:	00003517          	auipc	a0,0x3
ffffffffc0201420:	56450513          	addi	a0,a0,1380 # ffffffffc0204980 <commands+0x830>
ffffffffc0201424:	836ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201428:	00003697          	auipc	a3,0x3
ffffffffc020142c:	7b868693          	addi	a3,a3,1976 # ffffffffc0204be0 <commands+0xa90>
ffffffffc0201430:	00003617          	auipc	a2,0x3
ffffffffc0201434:	53860613          	addi	a2,a2,1336 # ffffffffc0204968 <commands+0x818>
ffffffffc0201438:	10800593          	li	a1,264
ffffffffc020143c:	00003517          	auipc	a0,0x3
ffffffffc0201440:	54450513          	addi	a0,a0,1348 # ffffffffc0204980 <commands+0x830>
ffffffffc0201444:	816ff0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201448:	00003697          	auipc	a3,0x3
ffffffffc020144c:	69868693          	addi	a3,a3,1688 # ffffffffc0204ae0 <commands+0x990>
ffffffffc0201450:	00003617          	auipc	a2,0x3
ffffffffc0201454:	51860613          	addi	a2,a2,1304 # ffffffffc0204968 <commands+0x818>
ffffffffc0201458:	10700593          	li	a1,263
ffffffffc020145c:	00003517          	auipc	a0,0x3
ffffffffc0201460:	52450513          	addi	a0,a0,1316 # ffffffffc0204980 <commands+0x830>
ffffffffc0201464:	ff7fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201468:	00003697          	auipc	a3,0x3
ffffffffc020146c:	75868693          	addi	a3,a3,1880 # ffffffffc0204bc0 <commands+0xa70>
ffffffffc0201470:	00003617          	auipc	a2,0x3
ffffffffc0201474:	4f860613          	addi	a2,a2,1272 # ffffffffc0204968 <commands+0x818>
ffffffffc0201478:	10600593          	li	a1,262
ffffffffc020147c:	00003517          	auipc	a0,0x3
ffffffffc0201480:	50450513          	addi	a0,a0,1284 # ffffffffc0204980 <commands+0x830>
ffffffffc0201484:	fd7fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201488:	00003697          	auipc	a3,0x3
ffffffffc020148c:	70868693          	addi	a3,a3,1800 # ffffffffc0204b90 <commands+0xa40>
ffffffffc0201490:	00003617          	auipc	a2,0x3
ffffffffc0201494:	4d860613          	addi	a2,a2,1240 # ffffffffc0204968 <commands+0x818>
ffffffffc0201498:	10500593          	li	a1,261
ffffffffc020149c:	00003517          	auipc	a0,0x3
ffffffffc02014a0:	4e450513          	addi	a0,a0,1252 # ffffffffc0204980 <commands+0x830>
ffffffffc02014a4:	fb7fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014a8:	00003697          	auipc	a3,0x3
ffffffffc02014ac:	6d068693          	addi	a3,a3,1744 # ffffffffc0204b78 <commands+0xa28>
ffffffffc02014b0:	00003617          	auipc	a2,0x3
ffffffffc02014b4:	4b860613          	addi	a2,a2,1208 # ffffffffc0204968 <commands+0x818>
ffffffffc02014b8:	10400593          	li	a1,260
ffffffffc02014bc:	00003517          	auipc	a0,0x3
ffffffffc02014c0:	4c450513          	addi	a0,a0,1220 # ffffffffc0204980 <commands+0x830>
ffffffffc02014c4:	f97fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014c8:	00003697          	auipc	a3,0x3
ffffffffc02014cc:	61868693          	addi	a3,a3,1560 # ffffffffc0204ae0 <commands+0x990>
ffffffffc02014d0:	00003617          	auipc	a2,0x3
ffffffffc02014d4:	49860613          	addi	a2,a2,1176 # ffffffffc0204968 <commands+0x818>
ffffffffc02014d8:	0fe00593          	li	a1,254
ffffffffc02014dc:	00003517          	auipc	a0,0x3
ffffffffc02014e0:	4a450513          	addi	a0,a0,1188 # ffffffffc0204980 <commands+0x830>
ffffffffc02014e4:	f77fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(!PageProperty(p0));
ffffffffc02014e8:	00003697          	auipc	a3,0x3
ffffffffc02014ec:	67868693          	addi	a3,a3,1656 # ffffffffc0204b60 <commands+0xa10>
ffffffffc02014f0:	00003617          	auipc	a2,0x3
ffffffffc02014f4:	47860613          	addi	a2,a2,1144 # ffffffffc0204968 <commands+0x818>
ffffffffc02014f8:	0f900593          	li	a1,249
ffffffffc02014fc:	00003517          	auipc	a0,0x3
ffffffffc0201500:	48450513          	addi	a0,a0,1156 # ffffffffc0204980 <commands+0x830>
ffffffffc0201504:	f57fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201508:	00003697          	auipc	a3,0x3
ffffffffc020150c:	77868693          	addi	a3,a3,1912 # ffffffffc0204c80 <commands+0xb30>
ffffffffc0201510:	00003617          	auipc	a2,0x3
ffffffffc0201514:	45860613          	addi	a2,a2,1112 # ffffffffc0204968 <commands+0x818>
ffffffffc0201518:	11700593          	li	a1,279
ffffffffc020151c:	00003517          	auipc	a0,0x3
ffffffffc0201520:	46450513          	addi	a0,a0,1124 # ffffffffc0204980 <commands+0x830>
ffffffffc0201524:	f37fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(total == 0);
ffffffffc0201528:	00003697          	auipc	a3,0x3
ffffffffc020152c:	78868693          	addi	a3,a3,1928 # ffffffffc0204cb0 <commands+0xb60>
ffffffffc0201530:	00003617          	auipc	a2,0x3
ffffffffc0201534:	43860613          	addi	a2,a2,1080 # ffffffffc0204968 <commands+0x818>
ffffffffc0201538:	12600593          	li	a1,294
ffffffffc020153c:	00003517          	auipc	a0,0x3
ffffffffc0201540:	44450513          	addi	a0,a0,1092 # ffffffffc0204980 <commands+0x830>
ffffffffc0201544:	f17fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(total == nr_free_pages());
ffffffffc0201548:	00003697          	auipc	a3,0x3
ffffffffc020154c:	45068693          	addi	a3,a3,1104 # ffffffffc0204998 <commands+0x848>
ffffffffc0201550:	00003617          	auipc	a2,0x3
ffffffffc0201554:	41860613          	addi	a2,a2,1048 # ffffffffc0204968 <commands+0x818>
ffffffffc0201558:	0f300593          	li	a1,243
ffffffffc020155c:	00003517          	auipc	a0,0x3
ffffffffc0201560:	42450513          	addi	a0,a0,1060 # ffffffffc0204980 <commands+0x830>
ffffffffc0201564:	ef7fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201568:	00003697          	auipc	a3,0x3
ffffffffc020156c:	47068693          	addi	a3,a3,1136 # ffffffffc02049d8 <commands+0x888>
ffffffffc0201570:	00003617          	auipc	a2,0x3
ffffffffc0201574:	3f860613          	addi	a2,a2,1016 # ffffffffc0204968 <commands+0x818>
ffffffffc0201578:	0ba00593          	li	a1,186
ffffffffc020157c:	00003517          	auipc	a0,0x3
ffffffffc0201580:	40450513          	addi	a0,a0,1028 # ffffffffc0204980 <commands+0x830>
ffffffffc0201584:	ed7fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201588 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201588:	1141                	addi	sp,sp,-16
ffffffffc020158a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020158c:	14058463          	beqz	a1,ffffffffc02016d4 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0201590:	00659693          	slli	a3,a1,0x6
ffffffffc0201594:	96aa                	add	a3,a3,a0
ffffffffc0201596:	87aa                	mv	a5,a0
ffffffffc0201598:	02d50263          	beq	a0,a3,ffffffffc02015bc <default_free_pages+0x34>
ffffffffc020159c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020159e:	8b05                	andi	a4,a4,1
ffffffffc02015a0:	10071a63          	bnez	a4,ffffffffc02016b4 <default_free_pages+0x12c>
ffffffffc02015a4:	6798                	ld	a4,8(a5)
ffffffffc02015a6:	8b09                	andi	a4,a4,2
ffffffffc02015a8:	10071663          	bnez	a4,ffffffffc02016b4 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015ac:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02015b0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015b4:	04078793          	addi	a5,a5,64
ffffffffc02015b8:	fed792e3          	bne	a5,a3,ffffffffc020159c <default_free_pages+0x14>
    base->property = n;
ffffffffc02015bc:	2581                	sext.w	a1,a1
ffffffffc02015be:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015c0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015c4:	4789                	li	a5,2
ffffffffc02015c6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02015ca:	00008697          	auipc	a3,0x8
ffffffffc02015ce:	e6668693          	addi	a3,a3,-410 # ffffffffc0209430 <free_area>
ffffffffc02015d2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015d4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02015d6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02015da:	9db9                	addw	a1,a1,a4
ffffffffc02015dc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015de:	0ad78463          	beq	a5,a3,ffffffffc0201686 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02015e2:	fe878713          	addi	a4,a5,-24
ffffffffc02015e6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ea:	4581                	li	a1,0
            if (base < page) {
ffffffffc02015ec:	00e56a63          	bltu	a0,a4,ffffffffc0201600 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02015f0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015f2:	04d70c63          	beq	a4,a3,ffffffffc020164a <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02015f6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015f8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02015fc:	fee57ae3          	bgeu	a0,a4,ffffffffc02015f0 <default_free_pages+0x68>
ffffffffc0201600:	c199                	beqz	a1,ffffffffc0201606 <default_free_pages+0x7e>
ffffffffc0201602:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201606:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201608:	e390                	sd	a2,0(a5)
ffffffffc020160a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020160c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020160e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201610:	00d70d63          	beq	a4,a3,ffffffffc020162a <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201614:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201618:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc020161c:	02059813          	slli	a6,a1,0x20
ffffffffc0201620:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201624:	97b2                	add	a5,a5,a2
ffffffffc0201626:	02f50c63          	beq	a0,a5,ffffffffc020165e <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020162a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020162c:	00d78c63          	beq	a5,a3,ffffffffc0201644 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201630:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201632:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201636:	02061593          	slli	a1,a2,0x20
ffffffffc020163a:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020163e:	972a                	add	a4,a4,a0
ffffffffc0201640:	04e68a63          	beq	a3,a4,ffffffffc0201694 <default_free_pages+0x10c>
}
ffffffffc0201644:	60a2                	ld	ra,8(sp)
ffffffffc0201646:	0141                	addi	sp,sp,16
ffffffffc0201648:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020164a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020164c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020164e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201650:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201652:	02d70763          	beq	a4,a3,ffffffffc0201680 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201656:	8832                	mv	a6,a2
ffffffffc0201658:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020165a:	87ba                	mv	a5,a4
ffffffffc020165c:	bf71                	j	ffffffffc02015f8 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020165e:	491c                	lw	a5,16(a0)
ffffffffc0201660:	9dbd                	addw	a1,a1,a5
ffffffffc0201662:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201666:	57f5                	li	a5,-3
ffffffffc0201668:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020166c:	01853803          	ld	a6,24(a0)
ffffffffc0201670:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201672:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201674:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201678:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020167a:	0105b023          	sd	a6,0(a1)
ffffffffc020167e:	b77d                	j	ffffffffc020162c <default_free_pages+0xa4>
ffffffffc0201680:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201682:	873e                	mv	a4,a5
ffffffffc0201684:	bf41                	j	ffffffffc0201614 <default_free_pages+0x8c>
}
ffffffffc0201686:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201688:	e390                	sd	a2,0(a5)
ffffffffc020168a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020168c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020168e:	ed1c                	sd	a5,24(a0)
ffffffffc0201690:	0141                	addi	sp,sp,16
ffffffffc0201692:	8082                	ret
            base->property += p->property;
ffffffffc0201694:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201698:	ff078693          	addi	a3,a5,-16
ffffffffc020169c:	9e39                	addw	a2,a2,a4
ffffffffc020169e:	c910                	sw	a2,16(a0)
ffffffffc02016a0:	5775                	li	a4,-3
ffffffffc02016a2:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016a6:	6398                	ld	a4,0(a5)
ffffffffc02016a8:	679c                	ld	a5,8(a5)
}
ffffffffc02016aa:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016ac:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016ae:	e398                	sd	a4,0(a5)
ffffffffc02016b0:	0141                	addi	sp,sp,16
ffffffffc02016b2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016b4:	00003697          	auipc	a3,0x3
ffffffffc02016b8:	61468693          	addi	a3,a3,1556 # ffffffffc0204cc8 <commands+0xb78>
ffffffffc02016bc:	00003617          	auipc	a2,0x3
ffffffffc02016c0:	2ac60613          	addi	a2,a2,684 # ffffffffc0204968 <commands+0x818>
ffffffffc02016c4:	08300593          	li	a1,131
ffffffffc02016c8:	00003517          	auipc	a0,0x3
ffffffffc02016cc:	2b850513          	addi	a0,a0,696 # ffffffffc0204980 <commands+0x830>
ffffffffc02016d0:	d8bfe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(n > 0);
ffffffffc02016d4:	00003697          	auipc	a3,0x3
ffffffffc02016d8:	5ec68693          	addi	a3,a3,1516 # ffffffffc0204cc0 <commands+0xb70>
ffffffffc02016dc:	00003617          	auipc	a2,0x3
ffffffffc02016e0:	28c60613          	addi	a2,a2,652 # ffffffffc0204968 <commands+0x818>
ffffffffc02016e4:	08000593          	li	a1,128
ffffffffc02016e8:	00003517          	auipc	a0,0x3
ffffffffc02016ec:	29850513          	addi	a0,a0,664 # ffffffffc0204980 <commands+0x830>
ffffffffc02016f0:	d6bfe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc02016f4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02016f4:	c941                	beqz	a0,ffffffffc0201784 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02016f6:	00008597          	auipc	a1,0x8
ffffffffc02016fa:	d3a58593          	addi	a1,a1,-710 # ffffffffc0209430 <free_area>
ffffffffc02016fe:	0105a803          	lw	a6,16(a1)
ffffffffc0201702:	872a                	mv	a4,a0
ffffffffc0201704:	02081793          	slli	a5,a6,0x20
ffffffffc0201708:	9381                	srli	a5,a5,0x20
ffffffffc020170a:	00a7ee63          	bltu	a5,a0,ffffffffc0201726 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020170e:	87ae                	mv	a5,a1
ffffffffc0201710:	a801                	j	ffffffffc0201720 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201712:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201716:	02069613          	slli	a2,a3,0x20
ffffffffc020171a:	9201                	srli	a2,a2,0x20
ffffffffc020171c:	00e67763          	bgeu	a2,a4,ffffffffc020172a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201720:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201722:	feb798e3          	bne	a5,a1,ffffffffc0201712 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201726:	4501                	li	a0,0
}
ffffffffc0201728:	8082                	ret
    return listelm->prev;
ffffffffc020172a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020172e:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201732:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201736:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020173a:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020173e:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201742:	02c77863          	bgeu	a4,a2,ffffffffc0201772 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201746:	071a                	slli	a4,a4,0x6
ffffffffc0201748:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020174a:	41c686bb          	subw	a3,a3,t3
ffffffffc020174e:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201750:	00870613          	addi	a2,a4,8
ffffffffc0201754:	4689                	li	a3,2
ffffffffc0201756:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020175a:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020175e:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201762:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201766:	e290                	sd	a2,0(a3)
ffffffffc0201768:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020176c:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc020176e:	01173c23          	sd	a7,24(a4)
ffffffffc0201772:	41c8083b          	subw	a6,a6,t3
ffffffffc0201776:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020177a:	5775                	li	a4,-3
ffffffffc020177c:	17c1                	addi	a5,a5,-16
ffffffffc020177e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201782:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201784:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201786:	00003697          	auipc	a3,0x3
ffffffffc020178a:	53a68693          	addi	a3,a3,1338 # ffffffffc0204cc0 <commands+0xb70>
ffffffffc020178e:	00003617          	auipc	a2,0x3
ffffffffc0201792:	1da60613          	addi	a2,a2,474 # ffffffffc0204968 <commands+0x818>
ffffffffc0201796:	06200593          	li	a1,98
ffffffffc020179a:	00003517          	auipc	a0,0x3
ffffffffc020179e:	1e650513          	addi	a0,a0,486 # ffffffffc0204980 <commands+0x830>
default_alloc_pages(size_t n) {
ffffffffc02017a2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017a4:	cb7fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc02017a8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017a8:	1141                	addi	sp,sp,-16
ffffffffc02017aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017ac:	c5f1                	beqz	a1,ffffffffc0201878 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017ae:	00659693          	slli	a3,a1,0x6
ffffffffc02017b2:	96aa                	add	a3,a3,a0
ffffffffc02017b4:	87aa                	mv	a5,a0
ffffffffc02017b6:	00d50f63          	beq	a0,a3,ffffffffc02017d4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017ba:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02017bc:	8b05                	andi	a4,a4,1
ffffffffc02017be:	cf49                	beqz	a4,ffffffffc0201858 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017c0:	0007a823          	sw	zero,16(a5)
ffffffffc02017c4:	0007b423          	sd	zero,8(a5)
ffffffffc02017c8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02017cc:	04078793          	addi	a5,a5,64
ffffffffc02017d0:	fed795e3          	bne	a5,a3,ffffffffc02017ba <default_init_memmap+0x12>
    base->property = n;
ffffffffc02017d4:	2581                	sext.w	a1,a1
ffffffffc02017d6:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017d8:	4789                	li	a5,2
ffffffffc02017da:	00850713          	addi	a4,a0,8
ffffffffc02017de:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02017e2:	00008697          	auipc	a3,0x8
ffffffffc02017e6:	c4e68693          	addi	a3,a3,-946 # ffffffffc0209430 <free_area>
ffffffffc02017ea:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02017ec:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02017ee:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02017f2:	9db9                	addw	a1,a1,a4
ffffffffc02017f4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02017f6:	04d78a63          	beq	a5,a3,ffffffffc020184a <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc02017fa:	fe878713          	addi	a4,a5,-24
ffffffffc02017fe:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201802:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201804:	00e56a63          	bltu	a0,a4,ffffffffc0201818 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201808:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020180a:	02d70263          	beq	a4,a3,ffffffffc020182e <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc020180e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201810:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201814:	fee57ae3          	bgeu	a0,a4,ffffffffc0201808 <default_init_memmap+0x60>
ffffffffc0201818:	c199                	beqz	a1,ffffffffc020181e <default_init_memmap+0x76>
ffffffffc020181a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020181e:	6398                	ld	a4,0(a5)
}
ffffffffc0201820:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201822:	e390                	sd	a2,0(a5)
ffffffffc0201824:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201826:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201828:	ed18                	sd	a4,24(a0)
ffffffffc020182a:	0141                	addi	sp,sp,16
ffffffffc020182c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020182e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201830:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201832:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201834:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201836:	00d70663          	beq	a4,a3,ffffffffc0201842 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020183a:	8832                	mv	a6,a2
ffffffffc020183c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020183e:	87ba                	mv	a5,a4
ffffffffc0201840:	bfc1                	j	ffffffffc0201810 <default_init_memmap+0x68>
}
ffffffffc0201842:	60a2                	ld	ra,8(sp)
ffffffffc0201844:	e290                	sd	a2,0(a3)
ffffffffc0201846:	0141                	addi	sp,sp,16
ffffffffc0201848:	8082                	ret
ffffffffc020184a:	60a2                	ld	ra,8(sp)
ffffffffc020184c:	e390                	sd	a2,0(a5)
ffffffffc020184e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201850:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201852:	ed1c                	sd	a5,24(a0)
ffffffffc0201854:	0141                	addi	sp,sp,16
ffffffffc0201856:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201858:	00003697          	auipc	a3,0x3
ffffffffc020185c:	49868693          	addi	a3,a3,1176 # ffffffffc0204cf0 <commands+0xba0>
ffffffffc0201860:	00003617          	auipc	a2,0x3
ffffffffc0201864:	10860613          	addi	a2,a2,264 # ffffffffc0204968 <commands+0x818>
ffffffffc0201868:	04900593          	li	a1,73
ffffffffc020186c:	00003517          	auipc	a0,0x3
ffffffffc0201870:	11450513          	addi	a0,a0,276 # ffffffffc0204980 <commands+0x830>
ffffffffc0201874:	be7fe0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(n > 0);
ffffffffc0201878:	00003697          	auipc	a3,0x3
ffffffffc020187c:	44868693          	addi	a3,a3,1096 # ffffffffc0204cc0 <commands+0xb70>
ffffffffc0201880:	00003617          	auipc	a2,0x3
ffffffffc0201884:	0e860613          	addi	a2,a2,232 # ffffffffc0204968 <commands+0x818>
ffffffffc0201888:	04600593          	li	a1,70
ffffffffc020188c:	00003517          	auipc	a0,0x3
ffffffffc0201890:	0f450513          	addi	a0,a0,244 # ffffffffc0204980 <commands+0x830>
ffffffffc0201894:	bc7fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201898 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201898:	c94d                	beqz	a0,ffffffffc020194a <slob_free+0xb2>
{
ffffffffc020189a:	1141                	addi	sp,sp,-16
ffffffffc020189c:	e022                	sd	s0,0(sp)
ffffffffc020189e:	e406                	sd	ra,8(sp)
ffffffffc02018a0:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018a2:	e9c1                	bnez	a1,ffffffffc0201932 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018a4:	100027f3          	csrr	a5,sstatus
ffffffffc02018a8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018aa:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018ac:	ebd9                	bnez	a5,ffffffffc0201942 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018ae:	00007617          	auipc	a2,0x7
ffffffffc02018b2:	77260613          	addi	a2,a2,1906 # ffffffffc0209020 <slobfree>
ffffffffc02018b6:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018b8:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018ba:	679c                	ld	a5,8(a5)
ffffffffc02018bc:	02877a63          	bgeu	a4,s0,ffffffffc02018f0 <slob_free+0x58>
ffffffffc02018c0:	00f46463          	bltu	s0,a5,ffffffffc02018c8 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018c4:	fef76ae3          	bltu	a4,a5,ffffffffc02018b8 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc02018c8:	400c                	lw	a1,0(s0)
ffffffffc02018ca:	00459693          	slli	a3,a1,0x4
ffffffffc02018ce:	96a2                	add	a3,a3,s0
ffffffffc02018d0:	02d78a63          	beq	a5,a3,ffffffffc0201904 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc02018d4:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02018d6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02018d8:	00469793          	slli	a5,a3,0x4
ffffffffc02018dc:	97ba                	add	a5,a5,a4
ffffffffc02018de:	02f40e63          	beq	s0,a5,ffffffffc020191a <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc02018e2:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02018e4:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02018e6:	e129                	bnez	a0,ffffffffc0201928 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02018e8:	60a2                	ld	ra,8(sp)
ffffffffc02018ea:	6402                	ld	s0,0(sp)
ffffffffc02018ec:	0141                	addi	sp,sp,16
ffffffffc02018ee:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018f0:	fcf764e3          	bltu	a4,a5,ffffffffc02018b8 <slob_free+0x20>
ffffffffc02018f4:	fcf472e3          	bgeu	s0,a5,ffffffffc02018b8 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc02018f8:	400c                	lw	a1,0(s0)
ffffffffc02018fa:	00459693          	slli	a3,a1,0x4
ffffffffc02018fe:	96a2                	add	a3,a3,s0
ffffffffc0201900:	fcd79ae3          	bne	a5,a3,ffffffffc02018d4 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201904:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201906:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201908:	9db5                	addw	a1,a1,a3
ffffffffc020190a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc020190c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020190e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201910:	00469793          	slli	a5,a3,0x4
ffffffffc0201914:	97ba                	add	a5,a5,a4
ffffffffc0201916:	fcf416e3          	bne	s0,a5,ffffffffc02018e2 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020191a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020191c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020191e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201920:	9ebd                	addw	a3,a3,a5
ffffffffc0201922:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201924:	e70c                	sd	a1,8(a4)
ffffffffc0201926:	d169                	beqz	a0,ffffffffc02018e8 <slob_free+0x50>
}
ffffffffc0201928:	6402                	ld	s0,0(sp)
ffffffffc020192a:	60a2                	ld	ra,8(sp)
ffffffffc020192c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020192e:	ffdfe06f          	j	ffffffffc020092a <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201932:	25bd                	addiw	a1,a1,15
ffffffffc0201934:	8191                	srli	a1,a1,0x4
ffffffffc0201936:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201938:	100027f3          	csrr	a5,sstatus
ffffffffc020193c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020193e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201940:	d7bd                	beqz	a5,ffffffffc02018ae <slob_free+0x16>
        intr_disable();
ffffffffc0201942:	feffe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        return 1;
ffffffffc0201946:	4505                	li	a0,1
ffffffffc0201948:	b79d                	j	ffffffffc02018ae <slob_free+0x16>
ffffffffc020194a:	8082                	ret

ffffffffc020194c <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc020194c:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020194e:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201950:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201954:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201956:	34e000ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
	if (!page)
ffffffffc020195a:	c91d                	beqz	a0,ffffffffc0201990 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020195c:	0000c697          	auipc	a3,0xc
ffffffffc0201960:	b5c6b683          	ld	a3,-1188(a3) # ffffffffc020d4b8 <pages>
ffffffffc0201964:	8d15                	sub	a0,a0,a3
ffffffffc0201966:	8519                	srai	a0,a0,0x6
ffffffffc0201968:	00004697          	auipc	a3,0x4
ffffffffc020196c:	0c86b683          	ld	a3,200(a3) # ffffffffc0205a30 <nbase>
ffffffffc0201970:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201972:	00c51793          	slli	a5,a0,0xc
ffffffffc0201976:	83b1                	srli	a5,a5,0xc
ffffffffc0201978:	0000c717          	auipc	a4,0xc
ffffffffc020197c:	b3873703          	ld	a4,-1224(a4) # ffffffffc020d4b0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201980:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201982:	00e7fa63          	bgeu	a5,a4,ffffffffc0201996 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201986:	0000c697          	auipc	a3,0xc
ffffffffc020198a:	b426b683          	ld	a3,-1214(a3) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc020198e:	9536                	add	a0,a0,a3
}
ffffffffc0201990:	60a2                	ld	ra,8(sp)
ffffffffc0201992:	0141                	addi	sp,sp,16
ffffffffc0201994:	8082                	ret
ffffffffc0201996:	86aa                	mv	a3,a0
ffffffffc0201998:	00003617          	auipc	a2,0x3
ffffffffc020199c:	3b860613          	addi	a2,a2,952 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc02019a0:	07100593          	li	a1,113
ffffffffc02019a4:	00003517          	auipc	a0,0x3
ffffffffc02019a8:	3d450513          	addi	a0,a0,980 # ffffffffc0204d78 <default_pmm_manager+0x60>
ffffffffc02019ac:	aaffe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc02019b0 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019b0:	1101                	addi	sp,sp,-32
ffffffffc02019b2:	ec06                	sd	ra,24(sp)
ffffffffc02019b4:	e822                	sd	s0,16(sp)
ffffffffc02019b6:	e426                	sd	s1,8(sp)
ffffffffc02019b8:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc02019ba:	01050713          	addi	a4,a0,16
ffffffffc02019be:	6785                	lui	a5,0x1
ffffffffc02019c0:	0cf77363          	bgeu	a4,a5,ffffffffc0201a86 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019c4:	00f50493          	addi	s1,a0,15
ffffffffc02019c8:	8091                	srli	s1,s1,0x4
ffffffffc02019ca:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019cc:	10002673          	csrr	a2,sstatus
ffffffffc02019d0:	8a09                	andi	a2,a2,2
ffffffffc02019d2:	e25d                	bnez	a2,ffffffffc0201a78 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02019d4:	00007917          	auipc	s2,0x7
ffffffffc02019d8:	64c90913          	addi	s2,s2,1612 # ffffffffc0209020 <slobfree>
ffffffffc02019dc:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02019e0:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc02019e2:	4398                	lw	a4,0(a5)
ffffffffc02019e4:	08975e63          	bge	a4,s1,ffffffffc0201a80 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc02019e8:	00d78b63          	beq	a5,a3,ffffffffc02019fe <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02019ec:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc02019ee:	4018                	lw	a4,0(s0)
ffffffffc02019f0:	02975a63          	bge	a4,s1,ffffffffc0201a24 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc02019f4:	00093683          	ld	a3,0(s2)
ffffffffc02019f8:	87a2                	mv	a5,s0
ffffffffc02019fa:	fed799e3          	bne	a5,a3,ffffffffc02019ec <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc02019fe:	ee31                	bnez	a2,ffffffffc0201a5a <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a00:	4501                	li	a0,0
ffffffffc0201a02:	f4bff0ef          	jal	ra,ffffffffc020194c <__slob_get_free_pages.constprop.0>
ffffffffc0201a06:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a08:	cd05                	beqz	a0,ffffffffc0201a40 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a0a:	6585                	lui	a1,0x1
ffffffffc0201a0c:	e8dff0ef          	jal	ra,ffffffffc0201898 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a10:	10002673          	csrr	a2,sstatus
ffffffffc0201a14:	8a09                	andi	a2,a2,2
ffffffffc0201a16:	ee05                	bnez	a2,ffffffffc0201a4e <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a18:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a1c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201a1e:	4018                	lw	a4,0(s0)
ffffffffc0201a20:	fc974ae3          	blt	a4,s1,ffffffffc02019f4 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201a24:	04e48763          	beq	s1,a4,ffffffffc0201a72 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a28:	00449693          	slli	a3,s1,0x4
ffffffffc0201a2c:	96a2                	add	a3,a3,s0
ffffffffc0201a2e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a30:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a32:	9f05                	subw	a4,a4,s1
ffffffffc0201a34:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a36:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a38:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a3a:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a3e:	e20d                	bnez	a2,ffffffffc0201a60 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a40:	60e2                	ld	ra,24(sp)
ffffffffc0201a42:	8522                	mv	a0,s0
ffffffffc0201a44:	6442                	ld	s0,16(sp)
ffffffffc0201a46:	64a2                	ld	s1,8(sp)
ffffffffc0201a48:	6902                	ld	s2,0(sp)
ffffffffc0201a4a:	6105                	addi	sp,sp,32
ffffffffc0201a4c:	8082                	ret
        intr_disable();
ffffffffc0201a4e:	ee3fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
			cur = slobfree;
ffffffffc0201a52:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a56:	4605                	li	a2,1
ffffffffc0201a58:	b7d1                	j	ffffffffc0201a1c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a5a:	ed1fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201a5e:	b74d                	j	ffffffffc0201a00 <slob_alloc.constprop.0+0x50>
ffffffffc0201a60:	ecbfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
}
ffffffffc0201a64:	60e2                	ld	ra,24(sp)
ffffffffc0201a66:	8522                	mv	a0,s0
ffffffffc0201a68:	6442                	ld	s0,16(sp)
ffffffffc0201a6a:	64a2                	ld	s1,8(sp)
ffffffffc0201a6c:	6902                	ld	s2,0(sp)
ffffffffc0201a6e:	6105                	addi	sp,sp,32
ffffffffc0201a70:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201a72:	6418                	ld	a4,8(s0)
ffffffffc0201a74:	e798                	sd	a4,8(a5)
ffffffffc0201a76:	b7d1                	j	ffffffffc0201a3a <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201a78:	eb9fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        return 1;
ffffffffc0201a7c:	4605                	li	a2,1
ffffffffc0201a7e:	bf99                	j	ffffffffc02019d4 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201a80:	843e                	mv	s0,a5
ffffffffc0201a82:	87b6                	mv	a5,a3
ffffffffc0201a84:	b745                	j	ffffffffc0201a24 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201a86:	00003697          	auipc	a3,0x3
ffffffffc0201a8a:	30268693          	addi	a3,a3,770 # ffffffffc0204d88 <default_pmm_manager+0x70>
ffffffffc0201a8e:	00003617          	auipc	a2,0x3
ffffffffc0201a92:	eda60613          	addi	a2,a2,-294 # ffffffffc0204968 <commands+0x818>
ffffffffc0201a96:	06400593          	li	a1,100
ffffffffc0201a9a:	00003517          	auipc	a0,0x3
ffffffffc0201a9e:	30e50513          	addi	a0,a0,782 # ffffffffc0204da8 <default_pmm_manager+0x90>
ffffffffc0201aa2:	9b9fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201aa6 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201aa6:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201aa8:	00003517          	auipc	a0,0x3
ffffffffc0201aac:	31850513          	addi	a0,a0,792 # ffffffffc0204dc0 <default_pmm_manager+0xa8>
{
ffffffffc0201ab0:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201ab2:	ee2fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201ab6:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ab8:	00003517          	auipc	a0,0x3
ffffffffc0201abc:	32050513          	addi	a0,a0,800 # ffffffffc0204dd8 <default_pmm_manager+0xc0>
}
ffffffffc0201ac0:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ac2:	ed2fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201ac6 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201ac6:	1101                	addi	sp,sp,-32
ffffffffc0201ac8:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201aca:	6905                	lui	s2,0x1
{
ffffffffc0201acc:	e822                	sd	s0,16(sp)
ffffffffc0201ace:	ec06                	sd	ra,24(sp)
ffffffffc0201ad0:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201ad2:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0201ad6:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201ad8:	04a7f963          	bgeu	a5,a0,ffffffffc0201b2a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201adc:	4561                	li	a0,24
ffffffffc0201ade:	ed3ff0ef          	jal	ra,ffffffffc02019b0 <slob_alloc.constprop.0>
ffffffffc0201ae2:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201ae4:	c929                	beqz	a0,ffffffffc0201b36 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201ae6:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201aea:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201aec:	00f95763          	bge	s2,a5,ffffffffc0201afa <kmalloc+0x34>
ffffffffc0201af0:	6705                	lui	a4,0x1
ffffffffc0201af2:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201af4:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201af6:	fef74ee3          	blt	a4,a5,ffffffffc0201af2 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201afa:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201afc:	e51ff0ef          	jal	ra,ffffffffc020194c <__slob_get_free_pages.constprop.0>
ffffffffc0201b00:	e488                	sd	a0,8(s1)
ffffffffc0201b02:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201b04:	c525                	beqz	a0,ffffffffc0201b6c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b06:	100027f3          	csrr	a5,sstatus
ffffffffc0201b0a:	8b89                	andi	a5,a5,2
ffffffffc0201b0c:	ef8d                	bnez	a5,ffffffffc0201b46 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b0e:	0000c797          	auipc	a5,0xc
ffffffffc0201b12:	98a78793          	addi	a5,a5,-1654 # ffffffffc020d498 <bigblocks>
ffffffffc0201b16:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b18:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b1a:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201b1c:	60e2                	ld	ra,24(sp)
ffffffffc0201b1e:	8522                	mv	a0,s0
ffffffffc0201b20:	6442                	ld	s0,16(sp)
ffffffffc0201b22:	64a2                	ld	s1,8(sp)
ffffffffc0201b24:	6902                	ld	s2,0(sp)
ffffffffc0201b26:	6105                	addi	sp,sp,32
ffffffffc0201b28:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b2a:	0541                	addi	a0,a0,16
ffffffffc0201b2c:	e85ff0ef          	jal	ra,ffffffffc02019b0 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b30:	01050413          	addi	s0,a0,16
ffffffffc0201b34:	f565                	bnez	a0,ffffffffc0201b1c <kmalloc+0x56>
ffffffffc0201b36:	4401                	li	s0,0
}
ffffffffc0201b38:	60e2                	ld	ra,24(sp)
ffffffffc0201b3a:	8522                	mv	a0,s0
ffffffffc0201b3c:	6442                	ld	s0,16(sp)
ffffffffc0201b3e:	64a2                	ld	s1,8(sp)
ffffffffc0201b40:	6902                	ld	s2,0(sp)
ffffffffc0201b42:	6105                	addi	sp,sp,32
ffffffffc0201b44:	8082                	ret
        intr_disable();
ffffffffc0201b46:	debfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b4a:	0000c797          	auipc	a5,0xc
ffffffffc0201b4e:	94e78793          	addi	a5,a5,-1714 # ffffffffc020d498 <bigblocks>
ffffffffc0201b52:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b54:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b56:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b58:	dd3fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
		return bb->pages;
ffffffffc0201b5c:	6480                	ld	s0,8(s1)
}
ffffffffc0201b5e:	60e2                	ld	ra,24(sp)
ffffffffc0201b60:	64a2                	ld	s1,8(sp)
ffffffffc0201b62:	8522                	mv	a0,s0
ffffffffc0201b64:	6442                	ld	s0,16(sp)
ffffffffc0201b66:	6902                	ld	s2,0(sp)
ffffffffc0201b68:	6105                	addi	sp,sp,32
ffffffffc0201b6a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b6c:	45e1                	li	a1,24
ffffffffc0201b6e:	8526                	mv	a0,s1
ffffffffc0201b70:	d29ff0ef          	jal	ra,ffffffffc0201898 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201b74:	b765                	j	ffffffffc0201b1c <kmalloc+0x56>

ffffffffc0201b76 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201b76:	c169                	beqz	a0,ffffffffc0201c38 <kfree+0xc2>
{
ffffffffc0201b78:	1101                	addi	sp,sp,-32
ffffffffc0201b7a:	e822                	sd	s0,16(sp)
ffffffffc0201b7c:	ec06                	sd	ra,24(sp)
ffffffffc0201b7e:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201b80:	03451793          	slli	a5,a0,0x34
ffffffffc0201b84:	842a                	mv	s0,a0
ffffffffc0201b86:	e3d9                	bnez	a5,ffffffffc0201c0c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b88:	100027f3          	csrr	a5,sstatus
ffffffffc0201b8c:	8b89                	andi	a5,a5,2
ffffffffc0201b8e:	e7d9                	bnez	a5,ffffffffc0201c1c <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201b90:	0000c797          	auipc	a5,0xc
ffffffffc0201b94:	9087b783          	ld	a5,-1784(a5) # ffffffffc020d498 <bigblocks>
    return 0;
ffffffffc0201b98:	4601                	li	a2,0
ffffffffc0201b9a:	cbad                	beqz	a5,ffffffffc0201c0c <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201b9c:	0000c697          	auipc	a3,0xc
ffffffffc0201ba0:	8fc68693          	addi	a3,a3,-1796 # ffffffffc020d498 <bigblocks>
ffffffffc0201ba4:	a021                	j	ffffffffc0201bac <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ba6:	01048693          	addi	a3,s1,16
ffffffffc0201baa:	c3a5                	beqz	a5,ffffffffc0201c0a <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201bac:	6798                	ld	a4,8(a5)
ffffffffc0201bae:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201bb0:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201bb2:	fe871ae3          	bne	a4,s0,ffffffffc0201ba6 <kfree+0x30>
				*last = bb->next;
ffffffffc0201bb6:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201bb8:	ee2d                	bnez	a2,ffffffffc0201c32 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bba:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bbe:	4098                	lw	a4,0(s1)
ffffffffc0201bc0:	08f46963          	bltu	s0,a5,ffffffffc0201c52 <kfree+0xdc>
ffffffffc0201bc4:	0000c697          	auipc	a3,0xc
ffffffffc0201bc8:	9046b683          	ld	a3,-1788(a3) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc0201bcc:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201bce:	8031                	srli	s0,s0,0xc
ffffffffc0201bd0:	0000c797          	auipc	a5,0xc
ffffffffc0201bd4:	8e07b783          	ld	a5,-1824(a5) # ffffffffc020d4b0 <npage>
ffffffffc0201bd8:	06f47163          	bgeu	s0,a5,ffffffffc0201c3a <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bdc:	00004517          	auipc	a0,0x4
ffffffffc0201be0:	e5453503          	ld	a0,-428(a0) # ffffffffc0205a30 <nbase>
ffffffffc0201be4:	8c09                	sub	s0,s0,a0
ffffffffc0201be6:	041a                	slli	s0,s0,0x6
    free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201be8:	0000c517          	auipc	a0,0xc
ffffffffc0201bec:	8d053503          	ld	a0,-1840(a0) # ffffffffc020d4b8 <pages>
ffffffffc0201bf0:	4585                	li	a1,1
ffffffffc0201bf2:	9522                	add	a0,a0,s0
ffffffffc0201bf4:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201bf8:	0ea000ef          	jal	ra,ffffffffc0201ce2 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201bfc:	6442                	ld	s0,16(sp)
ffffffffc0201bfe:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c00:	8526                	mv	a0,s1
}
ffffffffc0201c02:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c04:	45e1                	li	a1,24
}
ffffffffc0201c06:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c08:	b941                	j	ffffffffc0201898 <slob_free>
ffffffffc0201c0a:	e20d                	bnez	a2,ffffffffc0201c2c <kfree+0xb6>
ffffffffc0201c0c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c10:	6442                	ld	s0,16(sp)
ffffffffc0201c12:	60e2                	ld	ra,24(sp)
ffffffffc0201c14:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c16:	4581                	li	a1,0
}
ffffffffc0201c18:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c1a:	b9bd                	j	ffffffffc0201898 <slob_free>
        intr_disable();
ffffffffc0201c1c:	d15fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c20:	0000c797          	auipc	a5,0xc
ffffffffc0201c24:	8787b783          	ld	a5,-1928(a5) # ffffffffc020d498 <bigblocks>
        return 1;
ffffffffc0201c28:	4605                	li	a2,1
ffffffffc0201c2a:	fbad                	bnez	a5,ffffffffc0201b9c <kfree+0x26>
        intr_enable();
ffffffffc0201c2c:	cfffe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201c30:	bff1                	j	ffffffffc0201c0c <kfree+0x96>
ffffffffc0201c32:	cf9fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201c36:	b751                	j	ffffffffc0201bba <kfree+0x44>
ffffffffc0201c38:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c3a:	00003617          	auipc	a2,0x3
ffffffffc0201c3e:	1e660613          	addi	a2,a2,486 # ffffffffc0204e20 <default_pmm_manager+0x108>
ffffffffc0201c42:	06900593          	li	a1,105
ffffffffc0201c46:	00003517          	auipc	a0,0x3
ffffffffc0201c4a:	13250513          	addi	a0,a0,306 # ffffffffc0204d78 <default_pmm_manager+0x60>
ffffffffc0201c4e:	80dfe0ef          	jal	ra,ffffffffc020045a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c52:	86a2                	mv	a3,s0
ffffffffc0201c54:	00003617          	auipc	a2,0x3
ffffffffc0201c58:	1a460613          	addi	a2,a2,420 # ffffffffc0204df8 <default_pmm_manager+0xe0>
ffffffffc0201c5c:	07700593          	li	a1,119
ffffffffc0201c60:	00003517          	auipc	a0,0x3
ffffffffc0201c64:	11850513          	addi	a0,a0,280 # ffffffffc0204d78 <default_pmm_manager+0x60>
ffffffffc0201c68:	ff2fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201c6c <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201c6c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201c6e:	00003617          	auipc	a2,0x3
ffffffffc0201c72:	1b260613          	addi	a2,a2,434 # ffffffffc0204e20 <default_pmm_manager+0x108>
ffffffffc0201c76:	06900593          	li	a1,105
ffffffffc0201c7a:	00003517          	auipc	a0,0x3
ffffffffc0201c7e:	0fe50513          	addi	a0,a0,254 # ffffffffc0204d78 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201c82:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c84:	fd6fe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201c88 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201c88:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201c8a:	00003617          	auipc	a2,0x3
ffffffffc0201c8e:	1b660613          	addi	a2,a2,438 # ffffffffc0204e40 <default_pmm_manager+0x128>
ffffffffc0201c92:	07f00593          	li	a1,127
ffffffffc0201c96:	00003517          	auipc	a0,0x3
ffffffffc0201c9a:	0e250513          	addi	a0,a0,226 # ffffffffc0204d78 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201c9e:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201ca0:	fbafe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201ca4 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ca4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ca8:	8b89                	andi	a5,a5,2
ffffffffc0201caa:	e799                	bnez	a5,ffffffffc0201cb8 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201cac:	0000c797          	auipc	a5,0xc
ffffffffc0201cb0:	8147b783          	ld	a5,-2028(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201cb4:	6f9c                	ld	a5,24(a5)
ffffffffc0201cb6:	8782                	jr	a5
{
ffffffffc0201cb8:	1141                	addi	sp,sp,-16
ffffffffc0201cba:	e406                	sd	ra,8(sp)
ffffffffc0201cbc:	e022                	sd	s0,0(sp)
ffffffffc0201cbe:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201cc0:	c71fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201cc4:	0000b797          	auipc	a5,0xb
ffffffffc0201cc8:	7fc7b783          	ld	a5,2044(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201ccc:	6f9c                	ld	a5,24(a5)
ffffffffc0201cce:	8522                	mv	a0,s0
ffffffffc0201cd0:	9782                	jalr	a5
ffffffffc0201cd2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201cd4:	c57fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201cd8:	60a2                	ld	ra,8(sp)
ffffffffc0201cda:	8522                	mv	a0,s0
ffffffffc0201cdc:	6402                	ld	s0,0(sp)
ffffffffc0201cde:	0141                	addi	sp,sp,16
ffffffffc0201ce0:	8082                	ret

ffffffffc0201ce2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ce2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ce6:	8b89                	andi	a5,a5,2
ffffffffc0201ce8:	e799                	bnez	a5,ffffffffc0201cf6 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201cea:	0000b797          	auipc	a5,0xb
ffffffffc0201cee:	7d67b783          	ld	a5,2006(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201cf2:	739c                	ld	a5,32(a5)
ffffffffc0201cf4:	8782                	jr	a5
{
ffffffffc0201cf6:	1101                	addi	sp,sp,-32
ffffffffc0201cf8:	ec06                	sd	ra,24(sp)
ffffffffc0201cfa:	e822                	sd	s0,16(sp)
ffffffffc0201cfc:	e426                	sd	s1,8(sp)
ffffffffc0201cfe:	842a                	mv	s0,a0
ffffffffc0201d00:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d02:	c2ffe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d06:	0000b797          	auipc	a5,0xb
ffffffffc0201d0a:	7ba7b783          	ld	a5,1978(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201d0e:	739c                	ld	a5,32(a5)
ffffffffc0201d10:	85a6                	mv	a1,s1
ffffffffc0201d12:	8522                	mv	a0,s0
ffffffffc0201d14:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201d16:	6442                	ld	s0,16(sp)
ffffffffc0201d18:	60e2                	ld	ra,24(sp)
ffffffffc0201d1a:	64a2                	ld	s1,8(sp)
ffffffffc0201d1c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201d1e:	c0dfe06f          	j	ffffffffc020092a <intr_enable>

ffffffffc0201d22 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d22:	100027f3          	csrr	a5,sstatus
ffffffffc0201d26:	8b89                	andi	a5,a5,2
ffffffffc0201d28:	e799                	bnez	a5,ffffffffc0201d36 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d2a:	0000b797          	auipc	a5,0xb
ffffffffc0201d2e:	7967b783          	ld	a5,1942(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201d32:	779c                	ld	a5,40(a5)
ffffffffc0201d34:	8782                	jr	a5
{
ffffffffc0201d36:	1141                	addi	sp,sp,-16
ffffffffc0201d38:	e406                	sd	ra,8(sp)
ffffffffc0201d3a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201d3c:	bf5fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d40:	0000b797          	auipc	a5,0xb
ffffffffc0201d44:	7807b783          	ld	a5,1920(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201d48:	779c                	ld	a5,40(a5)
ffffffffc0201d4a:	9782                	jalr	a5
ffffffffc0201d4c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d4e:	bddfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201d52:	60a2                	ld	ra,8(sp)
ffffffffc0201d54:	8522                	mv	a0,s0
ffffffffc0201d56:	6402                	ld	s0,0(sp)
ffffffffc0201d58:	0141                	addi	sp,sp,16
ffffffffc0201d5a:	8082                	ret

ffffffffc0201d5c <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201d5c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201d60:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201d64:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201d66:	078e                	slli	a5,a5,0x3
{
ffffffffc0201d68:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201d6a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201d6e:	6094                	ld	a3,0(s1)
{
ffffffffc0201d70:	f04a                	sd	s2,32(sp)
ffffffffc0201d72:	ec4e                	sd	s3,24(sp)
ffffffffc0201d74:	e852                	sd	s4,16(sp)
ffffffffc0201d76:	fc06                	sd	ra,56(sp)
ffffffffc0201d78:	f822                	sd	s0,48(sp)
ffffffffc0201d7a:	e456                	sd	s5,8(sp)
ffffffffc0201d7c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201d7e:	0016f793          	andi	a5,a3,1
{
ffffffffc0201d82:	892e                	mv	s2,a1
ffffffffc0201d84:	8a32                	mv	s4,a2
ffffffffc0201d86:	0000b997          	auipc	s3,0xb
ffffffffc0201d8a:	72a98993          	addi	s3,s3,1834 # ffffffffc020d4b0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201d8e:	efbd                	bnez	a5,ffffffffc0201e0c <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201d90:	14060c63          	beqz	a2,ffffffffc0201ee8 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d94:	100027f3          	csrr	a5,sstatus
ffffffffc0201d98:	8b89                	andi	a5,a5,2
ffffffffc0201d9a:	14079963          	bnez	a5,ffffffffc0201eec <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201d9e:	0000b797          	auipc	a5,0xb
ffffffffc0201da2:	7227b783          	ld	a5,1826(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201da6:	6f9c                	ld	a5,24(a5)
ffffffffc0201da8:	4505                	li	a0,1
ffffffffc0201daa:	9782                	jalr	a5
ffffffffc0201dac:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201dae:	12040d63          	beqz	s0,ffffffffc0201ee8 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201db2:	0000bb17          	auipc	s6,0xb
ffffffffc0201db6:	706b0b13          	addi	s6,s6,1798 # ffffffffc020d4b8 <pages>
ffffffffc0201dba:	000b3503          	ld	a0,0(s6)
ffffffffc0201dbe:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201dc2:	0000b997          	auipc	s3,0xb
ffffffffc0201dc6:	6ee98993          	addi	s3,s3,1774 # ffffffffc020d4b0 <npage>
ffffffffc0201dca:	40a40533          	sub	a0,s0,a0
ffffffffc0201dce:	8519                	srai	a0,a0,0x6
ffffffffc0201dd0:	9556                	add	a0,a0,s5
ffffffffc0201dd2:	0009b703          	ld	a4,0(s3)
ffffffffc0201dd6:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201dda:	4685                	li	a3,1
ffffffffc0201ddc:	c014                	sw	a3,0(s0)
ffffffffc0201dde:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201de0:	0532                	slli	a0,a0,0xc
ffffffffc0201de2:	16e7f763          	bgeu	a5,a4,ffffffffc0201f50 <get_pte+0x1f4>
ffffffffc0201de6:	0000b797          	auipc	a5,0xb
ffffffffc0201dea:	6e27b783          	ld	a5,1762(a5) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc0201dee:	6605                	lui	a2,0x1
ffffffffc0201df0:	4581                	li	a1,0
ffffffffc0201df2:	953e                	add	a0,a0,a5
ffffffffc0201df4:	0a4020ef          	jal	ra,ffffffffc0203e98 <memset>
    return page - pages + nbase;
ffffffffc0201df8:	000b3683          	ld	a3,0(s6)
ffffffffc0201dfc:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e00:	8699                	srai	a3,a3,0x6
ffffffffc0201e02:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e04:	06aa                	slli	a3,a3,0xa
ffffffffc0201e06:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e0a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e0c:	77fd                	lui	a5,0xfffff
ffffffffc0201e0e:	068a                	slli	a3,a3,0x2
ffffffffc0201e10:	0009b703          	ld	a4,0(s3)
ffffffffc0201e14:	8efd                	and	a3,a3,a5
ffffffffc0201e16:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e1a:	10e7ff63          	bgeu	a5,a4,ffffffffc0201f38 <get_pte+0x1dc>
ffffffffc0201e1e:	0000ba97          	auipc	s5,0xb
ffffffffc0201e22:	6aaa8a93          	addi	s5,s5,1706 # ffffffffc020d4c8 <va_pa_offset>
ffffffffc0201e26:	000ab403          	ld	s0,0(s5)
ffffffffc0201e2a:	01595793          	srli	a5,s2,0x15
ffffffffc0201e2e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e32:	96a2                	add	a3,a3,s0
ffffffffc0201e34:	00379413          	slli	s0,a5,0x3
ffffffffc0201e38:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201e3a:	6014                	ld	a3,0(s0)
ffffffffc0201e3c:	0016f793          	andi	a5,a3,1
ffffffffc0201e40:	ebad                	bnez	a5,ffffffffc0201eb2 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201e42:	0a0a0363          	beqz	s4,ffffffffc0201ee8 <get_pte+0x18c>
ffffffffc0201e46:	100027f3          	csrr	a5,sstatus
ffffffffc0201e4a:	8b89                	andi	a5,a5,2
ffffffffc0201e4c:	efcd                	bnez	a5,ffffffffc0201f06 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e4e:	0000b797          	auipc	a5,0xb
ffffffffc0201e52:	6727b783          	ld	a5,1650(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201e56:	6f9c                	ld	a5,24(a5)
ffffffffc0201e58:	4505                	li	a0,1
ffffffffc0201e5a:	9782                	jalr	a5
ffffffffc0201e5c:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201e5e:	c4c9                	beqz	s1,ffffffffc0201ee8 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201e60:	0000bb17          	auipc	s6,0xb
ffffffffc0201e64:	658b0b13          	addi	s6,s6,1624 # ffffffffc020d4b8 <pages>
ffffffffc0201e68:	000b3503          	ld	a0,0(s6)
ffffffffc0201e6c:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e70:	0009b703          	ld	a4,0(s3)
ffffffffc0201e74:	40a48533          	sub	a0,s1,a0
ffffffffc0201e78:	8519                	srai	a0,a0,0x6
ffffffffc0201e7a:	9552                	add	a0,a0,s4
ffffffffc0201e7c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e80:	4685                	li	a3,1
ffffffffc0201e82:	c094                	sw	a3,0(s1)
ffffffffc0201e84:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e86:	0532                	slli	a0,a0,0xc
ffffffffc0201e88:	0ee7f163          	bgeu	a5,a4,ffffffffc0201f6a <get_pte+0x20e>
ffffffffc0201e8c:	000ab783          	ld	a5,0(s5)
ffffffffc0201e90:	6605                	lui	a2,0x1
ffffffffc0201e92:	4581                	li	a1,0
ffffffffc0201e94:	953e                	add	a0,a0,a5
ffffffffc0201e96:	002020ef          	jal	ra,ffffffffc0203e98 <memset>
    return page - pages + nbase;
ffffffffc0201e9a:	000b3683          	ld	a3,0(s6)
ffffffffc0201e9e:	40d486b3          	sub	a3,s1,a3
ffffffffc0201ea2:	8699                	srai	a3,a3,0x6
ffffffffc0201ea4:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ea6:	06aa                	slli	a3,a3,0xa
ffffffffc0201ea8:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201eac:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201eae:	0009b703          	ld	a4,0(s3)
ffffffffc0201eb2:	068a                	slli	a3,a3,0x2
ffffffffc0201eb4:	757d                	lui	a0,0xfffff
ffffffffc0201eb6:	8ee9                	and	a3,a3,a0
ffffffffc0201eb8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201ebc:	06e7f263          	bgeu	a5,a4,ffffffffc0201f20 <get_pte+0x1c4>
ffffffffc0201ec0:	000ab503          	ld	a0,0(s5)
ffffffffc0201ec4:	00c95913          	srli	s2,s2,0xc
ffffffffc0201ec8:	1ff97913          	andi	s2,s2,511
ffffffffc0201ecc:	96aa                	add	a3,a3,a0
ffffffffc0201ece:	00391513          	slli	a0,s2,0x3
ffffffffc0201ed2:	9536                	add	a0,a0,a3
}
ffffffffc0201ed4:	70e2                	ld	ra,56(sp)
ffffffffc0201ed6:	7442                	ld	s0,48(sp)
ffffffffc0201ed8:	74a2                	ld	s1,40(sp)
ffffffffc0201eda:	7902                	ld	s2,32(sp)
ffffffffc0201edc:	69e2                	ld	s3,24(sp)
ffffffffc0201ede:	6a42                	ld	s4,16(sp)
ffffffffc0201ee0:	6aa2                	ld	s5,8(sp)
ffffffffc0201ee2:	6b02                	ld	s6,0(sp)
ffffffffc0201ee4:	6121                	addi	sp,sp,64
ffffffffc0201ee6:	8082                	ret
            return NULL;
ffffffffc0201ee8:	4501                	li	a0,0
ffffffffc0201eea:	b7ed                	j	ffffffffc0201ed4 <get_pte+0x178>
        intr_disable();
ffffffffc0201eec:	a45fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ef0:	0000b797          	auipc	a5,0xb
ffffffffc0201ef4:	5d07b783          	ld	a5,1488(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201ef8:	6f9c                	ld	a5,24(a5)
ffffffffc0201efa:	4505                	li	a0,1
ffffffffc0201efc:	9782                	jalr	a5
ffffffffc0201efe:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f00:	a2bfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201f04:	b56d                	j	ffffffffc0201dae <get_pte+0x52>
        intr_disable();
ffffffffc0201f06:	a2bfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0201f0a:	0000b797          	auipc	a5,0xb
ffffffffc0201f0e:	5b67b783          	ld	a5,1462(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0201f12:	6f9c                	ld	a5,24(a5)
ffffffffc0201f14:	4505                	li	a0,1
ffffffffc0201f16:	9782                	jalr	a5
ffffffffc0201f18:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0201f1a:	a11fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0201f1e:	b781                	j	ffffffffc0201e5e <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f20:	00003617          	auipc	a2,0x3
ffffffffc0201f24:	e3060613          	addi	a2,a2,-464 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0201f28:	0fb00593          	li	a1,251
ffffffffc0201f2c:	00003517          	auipc	a0,0x3
ffffffffc0201f30:	f3c50513          	addi	a0,a0,-196 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0201f34:	d26fe0ef          	jal	ra,ffffffffc020045a <__panic>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f38:	00003617          	auipc	a2,0x3
ffffffffc0201f3c:	e1860613          	addi	a2,a2,-488 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0201f40:	0ee00593          	li	a1,238
ffffffffc0201f44:	00003517          	auipc	a0,0x3
ffffffffc0201f48:	f2450513          	addi	a0,a0,-220 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0201f4c:	d0efe0ef          	jal	ra,ffffffffc020045a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f50:	86aa                	mv	a3,a0
ffffffffc0201f52:	00003617          	auipc	a2,0x3
ffffffffc0201f56:	dfe60613          	addi	a2,a2,-514 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0201f5a:	0eb00593          	li	a1,235
ffffffffc0201f5e:	00003517          	auipc	a0,0x3
ffffffffc0201f62:	f0a50513          	addi	a0,a0,-246 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0201f66:	cf4fe0ef          	jal	ra,ffffffffc020045a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f6a:	86aa                	mv	a3,a0
ffffffffc0201f6c:	00003617          	auipc	a2,0x3
ffffffffc0201f70:	de460613          	addi	a2,a2,-540 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0201f74:	0f800593          	li	a1,248
ffffffffc0201f78:	00003517          	auipc	a0,0x3
ffffffffc0201f7c:	ef050513          	addi	a0,a0,-272 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0201f80:	cdafe0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0201f84 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0201f84:	1141                	addi	sp,sp,-16
ffffffffc0201f86:	e022                	sd	s0,0(sp)
ffffffffc0201f88:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f8a:	4601                	li	a2,0
{
ffffffffc0201f8c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f8e:	dcfff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
    if (ptep_store != NULL)
ffffffffc0201f92:	c011                	beqz	s0,ffffffffc0201f96 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0201f94:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201f96:	c511                	beqz	a0,ffffffffc0201fa2 <get_page+0x1e>
ffffffffc0201f98:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201f9a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201f9c:	0017f713          	andi	a4,a5,1
ffffffffc0201fa0:	e709                	bnez	a4,ffffffffc0201faa <get_page+0x26>
}
ffffffffc0201fa2:	60a2                	ld	ra,8(sp)
ffffffffc0201fa4:	6402                	ld	s0,0(sp)
ffffffffc0201fa6:	0141                	addi	sp,sp,16
ffffffffc0201fa8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201faa:	078a                	slli	a5,a5,0x2
ffffffffc0201fac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201fae:	0000b717          	auipc	a4,0xb
ffffffffc0201fb2:	50273703          	ld	a4,1282(a4) # ffffffffc020d4b0 <npage>
ffffffffc0201fb6:	00e7ff63          	bgeu	a5,a4,ffffffffc0201fd4 <get_page+0x50>
ffffffffc0201fba:	60a2                	ld	ra,8(sp)
ffffffffc0201fbc:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201fbe:	fff80537          	lui	a0,0xfff80
ffffffffc0201fc2:	97aa                	add	a5,a5,a0
ffffffffc0201fc4:	079a                	slli	a5,a5,0x6
ffffffffc0201fc6:	0000b517          	auipc	a0,0xb
ffffffffc0201fca:	4f253503          	ld	a0,1266(a0) # ffffffffc020d4b8 <pages>
ffffffffc0201fce:	953e                	add	a0,a0,a5
ffffffffc0201fd0:	0141                	addi	sp,sp,16
ffffffffc0201fd2:	8082                	ret
ffffffffc0201fd4:	c99ff0ef          	jal	ra,ffffffffc0201c6c <pa2page.part.0>

ffffffffc0201fd8 <page_remove>:
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
ffffffffc0201fd8:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fda:	4601                	li	a2,0
{
ffffffffc0201fdc:	ec26                	sd	s1,24(sp)
ffffffffc0201fde:	f406                	sd	ra,40(sp)
ffffffffc0201fe0:	f022                	sd	s0,32(sp)
ffffffffc0201fe2:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fe4:	d79ff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
    if (ptep != NULL)
ffffffffc0201fe8:	c511                	beqz	a0,ffffffffc0201ff4 <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0201fea:	611c                	ld	a5,0(a0)
ffffffffc0201fec:	842a                	mv	s0,a0
ffffffffc0201fee:	0017f713          	andi	a4,a5,1
ffffffffc0201ff2:	e711                	bnez	a4,ffffffffc0201ffe <page_remove+0x26>
    {
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201ff4:	70a2                	ld	ra,40(sp)
ffffffffc0201ff6:	7402                	ld	s0,32(sp)
ffffffffc0201ff8:	64e2                	ld	s1,24(sp)
ffffffffc0201ffa:	6145                	addi	sp,sp,48
ffffffffc0201ffc:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ffe:	078a                	slli	a5,a5,0x2
ffffffffc0202000:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202002:	0000b717          	auipc	a4,0xb
ffffffffc0202006:	4ae73703          	ld	a4,1198(a4) # ffffffffc020d4b0 <npage>
ffffffffc020200a:	06e7f363          	bgeu	a5,a4,ffffffffc0202070 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc020200e:	fff80537          	lui	a0,0xfff80
ffffffffc0202012:	97aa                	add	a5,a5,a0
ffffffffc0202014:	079a                	slli	a5,a5,0x6
ffffffffc0202016:	0000b517          	auipc	a0,0xb
ffffffffc020201a:	4a253503          	ld	a0,1186(a0) # ffffffffc020d4b8 <pages>
ffffffffc020201e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202020:	411c                	lw	a5,0(a0)
ffffffffc0202022:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202026:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202028:	cb11                	beqz	a4,ffffffffc020203c <page_remove+0x64>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc020202a:	00043023          	sd	zero,0(s0)
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020202e:	12048073          	sfence.vma	s1
}
ffffffffc0202032:	70a2                	ld	ra,40(sp)
ffffffffc0202034:	7402                	ld	s0,32(sp)
ffffffffc0202036:	64e2                	ld	s1,24(sp)
ffffffffc0202038:	6145                	addi	sp,sp,48
ffffffffc020203a:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020203c:	100027f3          	csrr	a5,sstatus
ffffffffc0202040:	8b89                	andi	a5,a5,2
ffffffffc0202042:	eb89                	bnez	a5,ffffffffc0202054 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202044:	0000b797          	auipc	a5,0xb
ffffffffc0202048:	47c7b783          	ld	a5,1148(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc020204c:	739c                	ld	a5,32(a5)
ffffffffc020204e:	4585                	li	a1,1
ffffffffc0202050:	9782                	jalr	a5
    if (flag) {
ffffffffc0202052:	bfe1                	j	ffffffffc020202a <page_remove+0x52>
        intr_disable();
ffffffffc0202054:	e42a                	sd	a0,8(sp)
ffffffffc0202056:	8dbfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020205a:	0000b797          	auipc	a5,0xb
ffffffffc020205e:	4667b783          	ld	a5,1126(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc0202062:	739c                	ld	a5,32(a5)
ffffffffc0202064:	6522                	ld	a0,8(sp)
ffffffffc0202066:	4585                	li	a1,1
ffffffffc0202068:	9782                	jalr	a5
        intr_enable();
ffffffffc020206a:	8c1fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020206e:	bf75                	j	ffffffffc020202a <page_remove+0x52>
ffffffffc0202070:	bfdff0ef          	jal	ra,ffffffffc0201c6c <pa2page.part.0>

ffffffffc0202074 <page_insert>:
{
ffffffffc0202074:	7139                	addi	sp,sp,-64
ffffffffc0202076:	e852                	sd	s4,16(sp)
ffffffffc0202078:	8a32                	mv	s4,a2
ffffffffc020207a:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020207c:	4605                	li	a2,1
{
ffffffffc020207e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202080:	85d2                	mv	a1,s4
{
ffffffffc0202082:	f426                	sd	s1,40(sp)
ffffffffc0202084:	fc06                	sd	ra,56(sp)
ffffffffc0202086:	f04a                	sd	s2,32(sp)
ffffffffc0202088:	ec4e                	sd	s3,24(sp)
ffffffffc020208a:	e456                	sd	s5,8(sp)
ffffffffc020208c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020208e:	ccfff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
    if (ptep == NULL)
ffffffffc0202092:	c961                	beqz	a0,ffffffffc0202162 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202094:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202096:	611c                	ld	a5,0(a0)
ffffffffc0202098:	89aa                	mv	s3,a0
ffffffffc020209a:	0016871b          	addiw	a4,a3,1
ffffffffc020209e:	c018                	sw	a4,0(s0)
ffffffffc02020a0:	0017f713          	andi	a4,a5,1
ffffffffc02020a4:	ef05                	bnez	a4,ffffffffc02020dc <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02020a6:	0000b717          	auipc	a4,0xb
ffffffffc02020aa:	41273703          	ld	a4,1042(a4) # ffffffffc020d4b8 <pages>
ffffffffc02020ae:	8c19                	sub	s0,s0,a4
ffffffffc02020b0:	000807b7          	lui	a5,0x80
ffffffffc02020b4:	8419                	srai	s0,s0,0x6
ffffffffc02020b6:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02020b8:	042a                	slli	s0,s0,0xa
ffffffffc02020ba:	8cc1                	or	s1,s1,s0
ffffffffc02020bc:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02020c0:	0099b023          	sd	s1,0(s3)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020c4:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02020c8:	4501                	li	a0,0
}
ffffffffc02020ca:	70e2                	ld	ra,56(sp)
ffffffffc02020cc:	7442                	ld	s0,48(sp)
ffffffffc02020ce:	74a2                	ld	s1,40(sp)
ffffffffc02020d0:	7902                	ld	s2,32(sp)
ffffffffc02020d2:	69e2                	ld	s3,24(sp)
ffffffffc02020d4:	6a42                	ld	s4,16(sp)
ffffffffc02020d6:	6aa2                	ld	s5,8(sp)
ffffffffc02020d8:	6121                	addi	sp,sp,64
ffffffffc02020da:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02020dc:	078a                	slli	a5,a5,0x2
ffffffffc02020de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02020e0:	0000b717          	auipc	a4,0xb
ffffffffc02020e4:	3d073703          	ld	a4,976(a4) # ffffffffc020d4b0 <npage>
ffffffffc02020e8:	06e7ff63          	bgeu	a5,a4,ffffffffc0202166 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02020ec:	0000ba97          	auipc	s5,0xb
ffffffffc02020f0:	3cca8a93          	addi	s5,s5,972 # ffffffffc020d4b8 <pages>
ffffffffc02020f4:	000ab703          	ld	a4,0(s5)
ffffffffc02020f8:	fff80937          	lui	s2,0xfff80
ffffffffc02020fc:	993e                	add	s2,s2,a5
ffffffffc02020fe:	091a                	slli	s2,s2,0x6
ffffffffc0202100:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc0202102:	01240c63          	beq	s0,s2,ffffffffc020211a <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202106:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd72b14>
ffffffffc020210a:	fff7869b          	addiw	a3,a5,-1
ffffffffc020210e:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202112:	c691                	beqz	a3,ffffffffc020211e <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202114:	120a0073          	sfence.vma	s4
}
ffffffffc0202118:	bf59                	j	ffffffffc02020ae <page_insert+0x3a>
ffffffffc020211a:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020211c:	bf49                	j	ffffffffc02020ae <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020211e:	100027f3          	csrr	a5,sstatus
ffffffffc0202122:	8b89                	andi	a5,a5,2
ffffffffc0202124:	ef91                	bnez	a5,ffffffffc0202140 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202126:	0000b797          	auipc	a5,0xb
ffffffffc020212a:	39a7b783          	ld	a5,922(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc020212e:	739c                	ld	a5,32(a5)
ffffffffc0202130:	4585                	li	a1,1
ffffffffc0202132:	854a                	mv	a0,s2
ffffffffc0202134:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202136:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020213a:	120a0073          	sfence.vma	s4
ffffffffc020213e:	bf85                	j	ffffffffc02020ae <page_insert+0x3a>
        intr_disable();
ffffffffc0202140:	ff0fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202144:	0000b797          	auipc	a5,0xb
ffffffffc0202148:	37c7b783          	ld	a5,892(a5) # ffffffffc020d4c0 <pmm_manager>
ffffffffc020214c:	739c                	ld	a5,32(a5)
ffffffffc020214e:	4585                	li	a1,1
ffffffffc0202150:	854a                	mv	a0,s2
ffffffffc0202152:	9782                	jalr	a5
        intr_enable();
ffffffffc0202154:	fd6fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202158:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020215c:	120a0073          	sfence.vma	s4
ffffffffc0202160:	b7b9                	j	ffffffffc02020ae <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202162:	5571                	li	a0,-4
ffffffffc0202164:	b79d                	j	ffffffffc02020ca <page_insert+0x56>
ffffffffc0202166:	b07ff0ef          	jal	ra,ffffffffc0201c6c <pa2page.part.0>

ffffffffc020216a <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020216a:	00003797          	auipc	a5,0x3
ffffffffc020216e:	bae78793          	addi	a5,a5,-1106 # ffffffffc0204d18 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202172:	638c                	ld	a1,0(a5)
{
ffffffffc0202174:	7159                	addi	sp,sp,-112
ffffffffc0202176:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202178:	00003517          	auipc	a0,0x3
ffffffffc020217c:	d0050513          	addi	a0,a0,-768 # ffffffffc0204e78 <default_pmm_manager+0x160>
    pmm_manager = &default_pmm_manager;
ffffffffc0202180:	0000bb17          	auipc	s6,0xb
ffffffffc0202184:	340b0b13          	addi	s6,s6,832 # ffffffffc020d4c0 <pmm_manager>
{
ffffffffc0202188:	f486                	sd	ra,104(sp)
ffffffffc020218a:	e8ca                	sd	s2,80(sp)
ffffffffc020218c:	e4ce                	sd	s3,72(sp)
ffffffffc020218e:	f0a2                	sd	s0,96(sp)
ffffffffc0202190:	eca6                	sd	s1,88(sp)
ffffffffc0202192:	e0d2                	sd	s4,64(sp)
ffffffffc0202194:	fc56                	sd	s5,56(sp)
ffffffffc0202196:	f45e                	sd	s7,40(sp)
ffffffffc0202198:	f062                	sd	s8,32(sp)
ffffffffc020219a:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020219c:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02021a0:	ff5fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc02021a4:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02021a8:	0000b997          	auipc	s3,0xb
ffffffffc02021ac:	32098993          	addi	s3,s3,800 # ffffffffc020d4c8 <va_pa_offset>
    pmm_manager->init();
ffffffffc02021b0:	679c                	ld	a5,8(a5)
ffffffffc02021b2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02021b4:	57f5                	li	a5,-3
ffffffffc02021b6:	07fa                	slli	a5,a5,0x1e
ffffffffc02021b8:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02021bc:	f5afe0ef          	jal	ra,ffffffffc0200916 <get_memory_base>
ffffffffc02021c0:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02021c2:	f5efe0ef          	jal	ra,ffffffffc0200920 <get_memory_size>
    if (mem_size == 0) {
ffffffffc02021c6:	200505e3          	beqz	a0,ffffffffc0202bd0 <pmm_init+0xa66>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02021ca:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02021cc:	00003517          	auipc	a0,0x3
ffffffffc02021d0:	ce450513          	addi	a0,a0,-796 # ffffffffc0204eb0 <default_pmm_manager+0x198>
ffffffffc02021d4:	fc1fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02021d8:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02021dc:	fff40693          	addi	a3,s0,-1
ffffffffc02021e0:	864a                	mv	a2,s2
ffffffffc02021e2:	85a6                	mv	a1,s1
ffffffffc02021e4:	00003517          	auipc	a0,0x3
ffffffffc02021e8:	ce450513          	addi	a0,a0,-796 # ffffffffc0204ec8 <default_pmm_manager+0x1b0>
ffffffffc02021ec:	fa9fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02021f0:	c8000737          	lui	a4,0xc8000
ffffffffc02021f4:	87a2                	mv	a5,s0
ffffffffc02021f6:	54876163          	bltu	a4,s0,ffffffffc0202738 <pmm_init+0x5ce>
ffffffffc02021fa:	757d                	lui	a0,0xfffff
ffffffffc02021fc:	0000c617          	auipc	a2,0xc
ffffffffc0202200:	2ef60613          	addi	a2,a2,751 # ffffffffc020e4eb <end+0xfff>
ffffffffc0202204:	8e69                	and	a2,a2,a0
ffffffffc0202206:	0000b497          	auipc	s1,0xb
ffffffffc020220a:	2aa48493          	addi	s1,s1,682 # ffffffffc020d4b0 <npage>
ffffffffc020220e:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202212:	0000bb97          	auipc	s7,0xb
ffffffffc0202216:	2a6b8b93          	addi	s7,s7,678 # ffffffffc020d4b8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020221a:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020221c:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202220:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202224:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202226:	02f50863          	beq	a0,a5,ffffffffc0202256 <pmm_init+0xec>
ffffffffc020222a:	4781                	li	a5,0
ffffffffc020222c:	4585                	li	a1,1
ffffffffc020222e:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202232:	00679513          	slli	a0,a5,0x6
ffffffffc0202236:	9532                	add	a0,a0,a2
ffffffffc0202238:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fdf1b1c>
ffffffffc020223c:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202240:	6088                	ld	a0,0(s1)
ffffffffc0202242:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0202244:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202248:	00d50733          	add	a4,a0,a3
ffffffffc020224c:	fee7e3e3          	bltu	a5,a4,ffffffffc0202232 <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202250:	071a                	slli	a4,a4,0x6
ffffffffc0202252:	00e606b3          	add	a3,a2,a4
ffffffffc0202256:	c02007b7          	lui	a5,0xc0200
ffffffffc020225a:	2ef6ece3          	bltu	a3,a5,ffffffffc0202d52 <pmm_init+0xbe8>
ffffffffc020225e:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202262:	77fd                	lui	a5,0xfffff
ffffffffc0202264:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202266:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202268:	5086eb63          	bltu	a3,s0,ffffffffc020277e <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc020226c:	00003517          	auipc	a0,0x3
ffffffffc0202270:	c8450513          	addi	a0,a0,-892 # ffffffffc0204ef0 <default_pmm_manager+0x1d8>
ffffffffc0202274:	f21fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202278:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020227c:	0000b917          	auipc	s2,0xb
ffffffffc0202280:	22c90913          	addi	s2,s2,556 # ffffffffc020d4a8 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0202284:	7b9c                	ld	a5,48(a5)
ffffffffc0202286:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202288:	00003517          	auipc	a0,0x3
ffffffffc020228c:	c8050513          	addi	a0,a0,-896 # ffffffffc0204f08 <default_pmm_manager+0x1f0>
ffffffffc0202290:	f05fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202294:	00006697          	auipc	a3,0x6
ffffffffc0202298:	d6c68693          	addi	a3,a3,-660 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc020229c:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02022a0:	c02007b7          	lui	a5,0xc0200
ffffffffc02022a4:	28f6ebe3          	bltu	a3,a5,ffffffffc0202d3a <pmm_init+0xbd0>
ffffffffc02022a8:	0009b783          	ld	a5,0(s3)
ffffffffc02022ac:	8e9d                	sub	a3,a3,a5
ffffffffc02022ae:	0000b797          	auipc	a5,0xb
ffffffffc02022b2:	1ed7b923          	sd	a3,498(a5) # ffffffffc020d4a0 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022b6:	100027f3          	csrr	a5,sstatus
ffffffffc02022ba:	8b89                	andi	a5,a5,2
ffffffffc02022bc:	4a079763          	bnez	a5,ffffffffc020276a <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc02022c0:	000b3783          	ld	a5,0(s6)
ffffffffc02022c4:	779c                	ld	a5,40(a5)
ffffffffc02022c6:	9782                	jalr	a5
ffffffffc02022c8:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02022ca:	6098                	ld	a4,0(s1)
ffffffffc02022cc:	c80007b7          	lui	a5,0xc8000
ffffffffc02022d0:	83b1                	srli	a5,a5,0xc
ffffffffc02022d2:	66e7e363          	bltu	a5,a4,ffffffffc0202938 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02022d6:	00093503          	ld	a0,0(s2)
ffffffffc02022da:	62050f63          	beqz	a0,ffffffffc0202918 <pmm_init+0x7ae>
ffffffffc02022de:	03451793          	slli	a5,a0,0x34
ffffffffc02022e2:	62079b63          	bnez	a5,ffffffffc0202918 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02022e6:	4601                	li	a2,0
ffffffffc02022e8:	4581                	li	a1,0
ffffffffc02022ea:	c9bff0ef          	jal	ra,ffffffffc0201f84 <get_page>
ffffffffc02022ee:	60051563          	bnez	a0,ffffffffc02028f8 <pmm_init+0x78e>
ffffffffc02022f2:	100027f3          	csrr	a5,sstatus
ffffffffc02022f6:	8b89                	andi	a5,a5,2
ffffffffc02022f8:	44079e63          	bnez	a5,ffffffffc0202754 <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc02022fc:	000b3783          	ld	a5,0(s6)
ffffffffc0202300:	4505                	li	a0,1
ffffffffc0202302:	6f9c                	ld	a5,24(a5)
ffffffffc0202304:	9782                	jalr	a5
ffffffffc0202306:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202308:	00093503          	ld	a0,0(s2)
ffffffffc020230c:	4681                	li	a3,0
ffffffffc020230e:	4601                	li	a2,0
ffffffffc0202310:	85d2                	mv	a1,s4
ffffffffc0202312:	d63ff0ef          	jal	ra,ffffffffc0202074 <page_insert>
ffffffffc0202316:	26051ae3          	bnez	a0,ffffffffc0202d8a <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc020231a:	00093503          	ld	a0,0(s2)
ffffffffc020231e:	4601                	li	a2,0
ffffffffc0202320:	4581                	li	a1,0
ffffffffc0202322:	a3bff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
ffffffffc0202326:	240502e3          	beqz	a0,ffffffffc0202d6a <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc020232a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc020232c:	0017f713          	andi	a4,a5,1
ffffffffc0202330:	5a070263          	beqz	a4,ffffffffc02028d4 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0202334:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202336:	078a                	slli	a5,a5,0x2
ffffffffc0202338:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020233a:	58e7fb63          	bgeu	a5,a4,ffffffffc02028d0 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020233e:	000bb683          	ld	a3,0(s7)
ffffffffc0202342:	fff80637          	lui	a2,0xfff80
ffffffffc0202346:	97b2                	add	a5,a5,a2
ffffffffc0202348:	079a                	slli	a5,a5,0x6
ffffffffc020234a:	97b6                	add	a5,a5,a3
ffffffffc020234c:	14fa17e3          	bne	s4,a5,ffffffffc0202c9a <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202350:	000a2683          	lw	a3,0(s4) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0202354:	4785                	li	a5,1
ffffffffc0202356:	12f692e3          	bne	a3,a5,ffffffffc0202c7a <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020235a:	00093503          	ld	a0,0(s2)
ffffffffc020235e:	77fd                	lui	a5,0xfffff
ffffffffc0202360:	6114                	ld	a3,0(a0)
ffffffffc0202362:	068a                	slli	a3,a3,0x2
ffffffffc0202364:	8efd                	and	a3,a3,a5
ffffffffc0202366:	00c6d613          	srli	a2,a3,0xc
ffffffffc020236a:	0ee67ce3          	bgeu	a2,a4,ffffffffc0202c62 <pmm_init+0xaf8>
ffffffffc020236e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202372:	96e2                	add	a3,a3,s8
ffffffffc0202374:	0006ba83          	ld	s5,0(a3)
ffffffffc0202378:	0a8a                	slli	s5,s5,0x2
ffffffffc020237a:	00fafab3          	and	s5,s5,a5
ffffffffc020237e:	00cad793          	srli	a5,s5,0xc
ffffffffc0202382:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0202c48 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202386:	4601                	li	a2,0
ffffffffc0202388:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020238a:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020238c:	9d1ff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202390:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202392:	55551363          	bne	a0,s5,ffffffffc02028d8 <pmm_init+0x76e>
ffffffffc0202396:	100027f3          	csrr	a5,sstatus
ffffffffc020239a:	8b89                	andi	a5,a5,2
ffffffffc020239c:	3a079163          	bnez	a5,ffffffffc020273e <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02023a0:	000b3783          	ld	a5,0(s6)
ffffffffc02023a4:	4505                	li	a0,1
ffffffffc02023a6:	6f9c                	ld	a5,24(a5)
ffffffffc02023a8:	9782                	jalr	a5
ffffffffc02023aa:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02023ac:	00093503          	ld	a0,0(s2)
ffffffffc02023b0:	46d1                	li	a3,20
ffffffffc02023b2:	6605                	lui	a2,0x1
ffffffffc02023b4:	85e2                	mv	a1,s8
ffffffffc02023b6:	cbfff0ef          	jal	ra,ffffffffc0202074 <page_insert>
ffffffffc02023ba:	060517e3          	bnez	a0,ffffffffc0202c28 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02023be:	00093503          	ld	a0,0(s2)
ffffffffc02023c2:	4601                	li	a2,0
ffffffffc02023c4:	6585                	lui	a1,0x1
ffffffffc02023c6:	997ff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
ffffffffc02023ca:	02050fe3          	beqz	a0,ffffffffc0202c08 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc02023ce:	611c                	ld	a5,0(a0)
ffffffffc02023d0:	0107f713          	andi	a4,a5,16
ffffffffc02023d4:	7c070e63          	beqz	a4,ffffffffc0202bb0 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc02023d8:	8b91                	andi	a5,a5,4
ffffffffc02023da:	7a078b63          	beqz	a5,ffffffffc0202b90 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02023de:	00093503          	ld	a0,0(s2)
ffffffffc02023e2:	611c                	ld	a5,0(a0)
ffffffffc02023e4:	8bc1                	andi	a5,a5,16
ffffffffc02023e6:	78078563          	beqz	a5,ffffffffc0202b70 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc02023ea:	000c2703          	lw	a4,0(s8) # ff0000 <kern_entry-0xffffffffbf210000>
ffffffffc02023ee:	4785                	li	a5,1
ffffffffc02023f0:	76f71063          	bne	a4,a5,ffffffffc0202b50 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02023f4:	4681                	li	a3,0
ffffffffc02023f6:	6605                	lui	a2,0x1
ffffffffc02023f8:	85d2                	mv	a1,s4
ffffffffc02023fa:	c7bff0ef          	jal	ra,ffffffffc0202074 <page_insert>
ffffffffc02023fe:	72051963          	bnez	a0,ffffffffc0202b30 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0202402:	000a2703          	lw	a4,0(s4)
ffffffffc0202406:	4789                	li	a5,2
ffffffffc0202408:	70f71463          	bne	a4,a5,ffffffffc0202b10 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc020240c:	000c2783          	lw	a5,0(s8)
ffffffffc0202410:	6e079063          	bnez	a5,ffffffffc0202af0 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202414:	00093503          	ld	a0,0(s2)
ffffffffc0202418:	4601                	li	a2,0
ffffffffc020241a:	6585                	lui	a1,0x1
ffffffffc020241c:	941ff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
ffffffffc0202420:	6a050863          	beqz	a0,ffffffffc0202ad0 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202424:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202426:	00177793          	andi	a5,a4,1
ffffffffc020242a:	4a078563          	beqz	a5,ffffffffc02028d4 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc020242e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202430:	00271793          	slli	a5,a4,0x2
ffffffffc0202434:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202436:	48d7fd63          	bgeu	a5,a3,ffffffffc02028d0 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020243a:	000bb683          	ld	a3,0(s7)
ffffffffc020243e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202442:	97d6                	add	a5,a5,s5
ffffffffc0202444:	079a                	slli	a5,a5,0x6
ffffffffc0202446:	97b6                	add	a5,a5,a3
ffffffffc0202448:	66fa1463          	bne	s4,a5,ffffffffc0202ab0 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc020244c:	8b41                	andi	a4,a4,16
ffffffffc020244e:	64071163          	bnez	a4,ffffffffc0202a90 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202452:	00093503          	ld	a0,0(s2)
ffffffffc0202456:	4581                	li	a1,0
ffffffffc0202458:	b81ff0ef          	jal	ra,ffffffffc0201fd8 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020245c:	000a2c83          	lw	s9,0(s4)
ffffffffc0202460:	4785                	li	a5,1
ffffffffc0202462:	60fc9763          	bne	s9,a5,ffffffffc0202a70 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0202466:	000c2783          	lw	a5,0(s8)
ffffffffc020246a:	5e079363          	bnez	a5,ffffffffc0202a50 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc020246e:	00093503          	ld	a0,0(s2)
ffffffffc0202472:	6585                	lui	a1,0x1
ffffffffc0202474:	b65ff0ef          	jal	ra,ffffffffc0201fd8 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202478:	000a2783          	lw	a5,0(s4)
ffffffffc020247c:	52079a63          	bnez	a5,ffffffffc02029b0 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202480:	000c2783          	lw	a5,0(s8)
ffffffffc0202484:	50079663          	bnez	a5,ffffffffc0202990 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202488:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc020248c:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020248e:	000a3683          	ld	a3,0(s4)
ffffffffc0202492:	068a                	slli	a3,a3,0x2
ffffffffc0202494:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202496:	42b6fd63          	bgeu	a3,a1,ffffffffc02028d0 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020249a:	000bb503          	ld	a0,0(s7)
ffffffffc020249e:	96d6                	add	a3,a3,s5
ffffffffc02024a0:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02024a2:	00d507b3          	add	a5,a0,a3
ffffffffc02024a6:	439c                	lw	a5,0(a5)
ffffffffc02024a8:	4d979463          	bne	a5,s9,ffffffffc0202970 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc02024ac:	8699                	srai	a3,a3,0x6
ffffffffc02024ae:	00080637          	lui	a2,0x80
ffffffffc02024b2:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02024b4:	00c69713          	slli	a4,a3,0xc
ffffffffc02024b8:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02024ba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024bc:	48b77e63          	bgeu	a4,a1,ffffffffc0202958 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02024c0:	0009b703          	ld	a4,0(s3)
ffffffffc02024c4:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02024c6:	629c                	ld	a5,0(a3)
ffffffffc02024c8:	078a                	slli	a5,a5,0x2
ffffffffc02024ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024cc:	40b7f263          	bgeu	a5,a1,ffffffffc02028d0 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02024d0:	8f91                	sub	a5,a5,a2
ffffffffc02024d2:	079a                	slli	a5,a5,0x6
ffffffffc02024d4:	953e                	add	a0,a0,a5
ffffffffc02024d6:	100027f3          	csrr	a5,sstatus
ffffffffc02024da:	8b89                	andi	a5,a5,2
ffffffffc02024dc:	30079963          	bnez	a5,ffffffffc02027ee <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc02024e0:	000b3783          	ld	a5,0(s6)
ffffffffc02024e4:	4585                	li	a1,1
ffffffffc02024e6:	739c                	ld	a5,32(a5)
ffffffffc02024e8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02024ea:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02024ee:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024f0:	078a                	slli	a5,a5,0x2
ffffffffc02024f2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024f4:	3ce7fe63          	bgeu	a5,a4,ffffffffc02028d0 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02024f8:	000bb503          	ld	a0,0(s7)
ffffffffc02024fc:	fff80737          	lui	a4,0xfff80
ffffffffc0202500:	97ba                	add	a5,a5,a4
ffffffffc0202502:	079a                	slli	a5,a5,0x6
ffffffffc0202504:	953e                	add	a0,a0,a5
ffffffffc0202506:	100027f3          	csrr	a5,sstatus
ffffffffc020250a:	8b89                	andi	a5,a5,2
ffffffffc020250c:	2c079563          	bnez	a5,ffffffffc02027d6 <pmm_init+0x66c>
ffffffffc0202510:	000b3783          	ld	a5,0(s6)
ffffffffc0202514:	4585                	li	a1,1
ffffffffc0202516:	739c                	ld	a5,32(a5)
ffffffffc0202518:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc020251a:	00093783          	ld	a5,0(s2)
ffffffffc020251e:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdf1b14>
    asm volatile("sfence.vma");
ffffffffc0202522:	12000073          	sfence.vma
ffffffffc0202526:	100027f3          	csrr	a5,sstatus
ffffffffc020252a:	8b89                	andi	a5,a5,2
ffffffffc020252c:	28079b63          	bnez	a5,ffffffffc02027c2 <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202530:	000b3783          	ld	a5,0(s6)
ffffffffc0202534:	779c                	ld	a5,40(a5)
ffffffffc0202536:	9782                	jalr	a5
ffffffffc0202538:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc020253a:	4b441b63          	bne	s0,s4,ffffffffc02029f0 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	cf250513          	addi	a0,a0,-782 # ffffffffc0205230 <default_pmm_manager+0x518>
ffffffffc0202546:	c4ffd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020254a:	100027f3          	csrr	a5,sstatus
ffffffffc020254e:	8b89                	andi	a5,a5,2
ffffffffc0202550:	24079f63          	bnez	a5,ffffffffc02027ae <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202554:	000b3783          	ld	a5,0(s6)
ffffffffc0202558:	779c                	ld	a5,40(a5)
ffffffffc020255a:	9782                	jalr	a5
ffffffffc020255c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020255e:	6098                	ld	a4,0(s1)
ffffffffc0202560:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202564:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202566:	00c71793          	slli	a5,a4,0xc
ffffffffc020256a:	6a05                	lui	s4,0x1
ffffffffc020256c:	02f47c63          	bgeu	s0,a5,ffffffffc02025a4 <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202570:	00c45793          	srli	a5,s0,0xc
ffffffffc0202574:	00093503          	ld	a0,0(s2)
ffffffffc0202578:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202876 <pmm_init+0x70c>
ffffffffc020257c:	0009b583          	ld	a1,0(s3)
ffffffffc0202580:	4601                	li	a2,0
ffffffffc0202582:	95a2                	add	a1,a1,s0
ffffffffc0202584:	fd8ff0ef          	jal	ra,ffffffffc0201d5c <get_pte>
ffffffffc0202588:	32050463          	beqz	a0,ffffffffc02028b0 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020258c:	611c                	ld	a5,0(a0)
ffffffffc020258e:	078a                	slli	a5,a5,0x2
ffffffffc0202590:	0157f7b3          	and	a5,a5,s5
ffffffffc0202594:	2e879e63          	bne	a5,s0,ffffffffc0202890 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202598:	6098                	ld	a4,0(s1)
ffffffffc020259a:	9452                	add	s0,s0,s4
ffffffffc020259c:	00c71793          	slli	a5,a4,0xc
ffffffffc02025a0:	fcf468e3          	bltu	s0,a5,ffffffffc0202570 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc02025a4:	00093783          	ld	a5,0(s2)
ffffffffc02025a8:	639c                	ld	a5,0(a5)
ffffffffc02025aa:	42079363          	bnez	a5,ffffffffc02029d0 <pmm_init+0x866>
ffffffffc02025ae:	100027f3          	csrr	a5,sstatus
ffffffffc02025b2:	8b89                	andi	a5,a5,2
ffffffffc02025b4:	24079963          	bnez	a5,ffffffffc0202806 <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02025b8:	000b3783          	ld	a5,0(s6)
ffffffffc02025bc:	4505                	li	a0,1
ffffffffc02025be:	6f9c                	ld	a5,24(a5)
ffffffffc02025c0:	9782                	jalr	a5
ffffffffc02025c2:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025c4:	00093503          	ld	a0,0(s2)
ffffffffc02025c8:	4699                	li	a3,6
ffffffffc02025ca:	10000613          	li	a2,256
ffffffffc02025ce:	85d2                	mv	a1,s4
ffffffffc02025d0:	aa5ff0ef          	jal	ra,ffffffffc0202074 <page_insert>
ffffffffc02025d4:	44051e63          	bnez	a0,ffffffffc0202a30 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc02025d8:	000a2703          	lw	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02025dc:	4785                	li	a5,1
ffffffffc02025de:	42f71963          	bne	a4,a5,ffffffffc0202a10 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025e2:	00093503          	ld	a0,0(s2)
ffffffffc02025e6:	6405                	lui	s0,0x1
ffffffffc02025e8:	4699                	li	a3,6
ffffffffc02025ea:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02025ee:	85d2                	mv	a1,s4
ffffffffc02025f0:	a85ff0ef          	jal	ra,ffffffffc0202074 <page_insert>
ffffffffc02025f4:	72051363          	bnez	a0,ffffffffc0202d1a <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc02025f8:	000a2703          	lw	a4,0(s4)
ffffffffc02025fc:	4789                	li	a5,2
ffffffffc02025fe:	6ef71e63          	bne	a4,a5,ffffffffc0202cfa <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202602:	00003597          	auipc	a1,0x3
ffffffffc0202606:	d7658593          	addi	a1,a1,-650 # ffffffffc0205378 <default_pmm_manager+0x660>
ffffffffc020260a:	10000513          	li	a0,256
ffffffffc020260e:	01f010ef          	jal	ra,ffffffffc0203e2c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202612:	10040593          	addi	a1,s0,256
ffffffffc0202616:	10000513          	li	a0,256
ffffffffc020261a:	025010ef          	jal	ra,ffffffffc0203e3e <strcmp>
ffffffffc020261e:	6a051e63          	bnez	a0,ffffffffc0202cda <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202622:	000bb683          	ld	a3,0(s7)
ffffffffc0202626:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc020262a:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc020262c:	40da06b3          	sub	a3,s4,a3
ffffffffc0202630:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202632:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202634:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202636:	8031                	srli	s0,s0,0xc
ffffffffc0202638:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc020263c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020263e:	30f77d63          	bgeu	a4,a5,ffffffffc0202958 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202642:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202646:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020264a:	96be                	add	a3,a3,a5
ffffffffc020264c:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202650:	7a6010ef          	jal	ra,ffffffffc0203df6 <strlen>
ffffffffc0202654:	66051363          	bnez	a0,ffffffffc0202cba <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202658:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc020265c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020265e:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fdf1b14>
ffffffffc0202662:	068a                	slli	a3,a3,0x2
ffffffffc0202664:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202666:	26f6f563          	bgeu	a3,a5,ffffffffc02028d0 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc020266a:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020266c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020266e:	2ef47563          	bgeu	s0,a5,ffffffffc0202958 <pmm_init+0x7ee>
ffffffffc0202672:	0009b403          	ld	s0,0(s3)
ffffffffc0202676:	9436                	add	s0,s0,a3
ffffffffc0202678:	100027f3          	csrr	a5,sstatus
ffffffffc020267c:	8b89                	andi	a5,a5,2
ffffffffc020267e:	1e079163          	bnez	a5,ffffffffc0202860 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202682:	000b3783          	ld	a5,0(s6)
ffffffffc0202686:	4585                	li	a1,1
ffffffffc0202688:	8552                	mv	a0,s4
ffffffffc020268a:	739c                	ld	a5,32(a5)
ffffffffc020268c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020268e:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202690:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202692:	078a                	slli	a5,a5,0x2
ffffffffc0202694:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202696:	22e7fd63          	bgeu	a5,a4,ffffffffc02028d0 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020269a:	000bb503          	ld	a0,0(s7)
ffffffffc020269e:	fff80737          	lui	a4,0xfff80
ffffffffc02026a2:	97ba                	add	a5,a5,a4
ffffffffc02026a4:	079a                	slli	a5,a5,0x6
ffffffffc02026a6:	953e                	add	a0,a0,a5
ffffffffc02026a8:	100027f3          	csrr	a5,sstatus
ffffffffc02026ac:	8b89                	andi	a5,a5,2
ffffffffc02026ae:	18079d63          	bnez	a5,ffffffffc0202848 <pmm_init+0x6de>
ffffffffc02026b2:	000b3783          	ld	a5,0(s6)
ffffffffc02026b6:	4585                	li	a1,1
ffffffffc02026b8:	739c                	ld	a5,32(a5)
ffffffffc02026ba:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02026bc:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc02026c0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02026c2:	078a                	slli	a5,a5,0x2
ffffffffc02026c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02026c6:	20e7f563          	bgeu	a5,a4,ffffffffc02028d0 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02026ca:	000bb503          	ld	a0,0(s7)
ffffffffc02026ce:	fff80737          	lui	a4,0xfff80
ffffffffc02026d2:	97ba                	add	a5,a5,a4
ffffffffc02026d4:	079a                	slli	a5,a5,0x6
ffffffffc02026d6:	953e                	add	a0,a0,a5
ffffffffc02026d8:	100027f3          	csrr	a5,sstatus
ffffffffc02026dc:	8b89                	andi	a5,a5,2
ffffffffc02026de:	14079963          	bnez	a5,ffffffffc0202830 <pmm_init+0x6c6>
ffffffffc02026e2:	000b3783          	ld	a5,0(s6)
ffffffffc02026e6:	4585                	li	a1,1
ffffffffc02026e8:	739c                	ld	a5,32(a5)
ffffffffc02026ea:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02026ec:	00093783          	ld	a5,0(s2)
ffffffffc02026f0:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc02026f4:	12000073          	sfence.vma
ffffffffc02026f8:	100027f3          	csrr	a5,sstatus
ffffffffc02026fc:	8b89                	andi	a5,a5,2
ffffffffc02026fe:	10079f63          	bnez	a5,ffffffffc020281c <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202702:	000b3783          	ld	a5,0(s6)
ffffffffc0202706:	779c                	ld	a5,40(a5)
ffffffffc0202708:	9782                	jalr	a5
ffffffffc020270a:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc020270c:	4c8c1e63          	bne	s8,s0,ffffffffc0202be8 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202710:	00003517          	auipc	a0,0x3
ffffffffc0202714:	ce050513          	addi	a0,a0,-800 # ffffffffc02053f0 <default_pmm_manager+0x6d8>
ffffffffc0202718:	a7dfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc020271c:	7406                	ld	s0,96(sp)
ffffffffc020271e:	70a6                	ld	ra,104(sp)
ffffffffc0202720:	64e6                	ld	s1,88(sp)
ffffffffc0202722:	6946                	ld	s2,80(sp)
ffffffffc0202724:	69a6                	ld	s3,72(sp)
ffffffffc0202726:	6a06                	ld	s4,64(sp)
ffffffffc0202728:	7ae2                	ld	s5,56(sp)
ffffffffc020272a:	7b42                	ld	s6,48(sp)
ffffffffc020272c:	7ba2                	ld	s7,40(sp)
ffffffffc020272e:	7c02                	ld	s8,32(sp)
ffffffffc0202730:	6ce2                	ld	s9,24(sp)
ffffffffc0202732:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202734:	b72ff06f          	j	ffffffffc0201aa6 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202738:	c80007b7          	lui	a5,0xc8000
ffffffffc020273c:	bc7d                	j	ffffffffc02021fa <pmm_init+0x90>
        intr_disable();
ffffffffc020273e:	9f2fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202742:	000b3783          	ld	a5,0(s6)
ffffffffc0202746:	4505                	li	a0,1
ffffffffc0202748:	6f9c                	ld	a5,24(a5)
ffffffffc020274a:	9782                	jalr	a5
ffffffffc020274c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020274e:	9dcfe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202752:	b9a9                	j	ffffffffc02023ac <pmm_init+0x242>
        intr_disable();
ffffffffc0202754:	9dcfe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202758:	000b3783          	ld	a5,0(s6)
ffffffffc020275c:	4505                	li	a0,1
ffffffffc020275e:	6f9c                	ld	a5,24(a5)
ffffffffc0202760:	9782                	jalr	a5
ffffffffc0202762:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202764:	9c6fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202768:	b645                	j	ffffffffc0202308 <pmm_init+0x19e>
        intr_disable();
ffffffffc020276a:	9c6fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020276e:	000b3783          	ld	a5,0(s6)
ffffffffc0202772:	779c                	ld	a5,40(a5)
ffffffffc0202774:	9782                	jalr	a5
ffffffffc0202776:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202778:	9b2fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020277c:	b6b9                	j	ffffffffc02022ca <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020277e:	6705                	lui	a4,0x1
ffffffffc0202780:	177d                	addi	a4,a4,-1
ffffffffc0202782:	96ba                	add	a3,a3,a4
ffffffffc0202784:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202786:	00c7d713          	srli	a4,a5,0xc
ffffffffc020278a:	14a77363          	bgeu	a4,a0,ffffffffc02028d0 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc020278e:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202792:	fff80537          	lui	a0,0xfff80
ffffffffc0202796:	972a                	add	a4,a4,a0
ffffffffc0202798:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020279a:	8c1d                	sub	s0,s0,a5
ffffffffc020279c:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02027a0:	00c45593          	srli	a1,s0,0xc
ffffffffc02027a4:	9532                	add	a0,a0,a2
ffffffffc02027a6:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02027a8:	0009b583          	ld	a1,0(s3)
}
ffffffffc02027ac:	b4c1                	j	ffffffffc020226c <pmm_init+0x102>
        intr_disable();
ffffffffc02027ae:	982fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02027b2:	000b3783          	ld	a5,0(s6)
ffffffffc02027b6:	779c                	ld	a5,40(a5)
ffffffffc02027b8:	9782                	jalr	a5
ffffffffc02027ba:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02027bc:	96efe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02027c0:	bb79                	j	ffffffffc020255e <pmm_init+0x3f4>
        intr_disable();
ffffffffc02027c2:	96efe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02027c6:	000b3783          	ld	a5,0(s6)
ffffffffc02027ca:	779c                	ld	a5,40(a5)
ffffffffc02027cc:	9782                	jalr	a5
ffffffffc02027ce:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02027d0:	95afe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02027d4:	b39d                	j	ffffffffc020253a <pmm_init+0x3d0>
ffffffffc02027d6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02027d8:	958fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02027dc:	000b3783          	ld	a5,0(s6)
ffffffffc02027e0:	6522                	ld	a0,8(sp)
ffffffffc02027e2:	4585                	li	a1,1
ffffffffc02027e4:	739c                	ld	a5,32(a5)
ffffffffc02027e6:	9782                	jalr	a5
        intr_enable();
ffffffffc02027e8:	942fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc02027ec:	b33d                	j	ffffffffc020251a <pmm_init+0x3b0>
ffffffffc02027ee:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02027f0:	940fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc02027f4:	000b3783          	ld	a5,0(s6)
ffffffffc02027f8:	6522                	ld	a0,8(sp)
ffffffffc02027fa:	4585                	li	a1,1
ffffffffc02027fc:	739c                	ld	a5,32(a5)
ffffffffc02027fe:	9782                	jalr	a5
        intr_enable();
ffffffffc0202800:	92afe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202804:	b1dd                	j	ffffffffc02024ea <pmm_init+0x380>
        intr_disable();
ffffffffc0202806:	92afe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020280a:	000b3783          	ld	a5,0(s6)
ffffffffc020280e:	4505                	li	a0,1
ffffffffc0202810:	6f9c                	ld	a5,24(a5)
ffffffffc0202812:	9782                	jalr	a5
ffffffffc0202814:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202816:	914fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020281a:	b36d                	j	ffffffffc02025c4 <pmm_init+0x45a>
        intr_disable();
ffffffffc020281c:	914fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202820:	000b3783          	ld	a5,0(s6)
ffffffffc0202824:	779c                	ld	a5,40(a5)
ffffffffc0202826:	9782                	jalr	a5
ffffffffc0202828:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020282a:	900fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020282e:	bdf9                	j	ffffffffc020270c <pmm_init+0x5a2>
ffffffffc0202830:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202832:	8fefe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202836:	000b3783          	ld	a5,0(s6)
ffffffffc020283a:	6522                	ld	a0,8(sp)
ffffffffc020283c:	4585                	li	a1,1
ffffffffc020283e:	739c                	ld	a5,32(a5)
ffffffffc0202840:	9782                	jalr	a5
        intr_enable();
ffffffffc0202842:	8e8fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202846:	b55d                	j	ffffffffc02026ec <pmm_init+0x582>
ffffffffc0202848:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020284a:	8e6fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc020284e:	000b3783          	ld	a5,0(s6)
ffffffffc0202852:	6522                	ld	a0,8(sp)
ffffffffc0202854:	4585                	li	a1,1
ffffffffc0202856:	739c                	ld	a5,32(a5)
ffffffffc0202858:	9782                	jalr	a5
        intr_enable();
ffffffffc020285a:	8d0fe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc020285e:	bdb9                	j	ffffffffc02026bc <pmm_init+0x552>
        intr_disable();
ffffffffc0202860:	8d0fe0ef          	jal	ra,ffffffffc0200930 <intr_disable>
ffffffffc0202864:	000b3783          	ld	a5,0(s6)
ffffffffc0202868:	4585                	li	a1,1
ffffffffc020286a:	8552                	mv	a0,s4
ffffffffc020286c:	739c                	ld	a5,32(a5)
ffffffffc020286e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202870:	8bafe0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0202874:	bd29                	j	ffffffffc020268e <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202876:	86a2                	mv	a3,s0
ffffffffc0202878:	00002617          	auipc	a2,0x2
ffffffffc020287c:	4d860613          	addi	a2,a2,1240 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0202880:	1a400593          	li	a1,420
ffffffffc0202884:	00002517          	auipc	a0,0x2
ffffffffc0202888:	5e450513          	addi	a0,a0,1508 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc020288c:	bcffd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202890:	00003697          	auipc	a3,0x3
ffffffffc0202894:	a0068693          	addi	a3,a3,-1536 # ffffffffc0205290 <default_pmm_manager+0x578>
ffffffffc0202898:	00002617          	auipc	a2,0x2
ffffffffc020289c:	0d060613          	addi	a2,a2,208 # ffffffffc0204968 <commands+0x818>
ffffffffc02028a0:	1a500593          	li	a1,421
ffffffffc02028a4:	00002517          	auipc	a0,0x2
ffffffffc02028a8:	5c450513          	addi	a0,a0,1476 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc02028ac:	baffd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02028b0:	00003697          	auipc	a3,0x3
ffffffffc02028b4:	9a068693          	addi	a3,a3,-1632 # ffffffffc0205250 <default_pmm_manager+0x538>
ffffffffc02028b8:	00002617          	auipc	a2,0x2
ffffffffc02028bc:	0b060613          	addi	a2,a2,176 # ffffffffc0204968 <commands+0x818>
ffffffffc02028c0:	1a400593          	li	a1,420
ffffffffc02028c4:	00002517          	auipc	a0,0x2
ffffffffc02028c8:	5a450513          	addi	a0,a0,1444 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc02028cc:	b8ffd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02028d0:	b9cff0ef          	jal	ra,ffffffffc0201c6c <pa2page.part.0>
ffffffffc02028d4:	bb4ff0ef          	jal	ra,ffffffffc0201c88 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02028d8:	00002697          	auipc	a3,0x2
ffffffffc02028dc:	77068693          	addi	a3,a3,1904 # ffffffffc0205048 <default_pmm_manager+0x330>
ffffffffc02028e0:	00002617          	auipc	a2,0x2
ffffffffc02028e4:	08860613          	addi	a2,a2,136 # ffffffffc0204968 <commands+0x818>
ffffffffc02028e8:	17400593          	li	a1,372
ffffffffc02028ec:	00002517          	auipc	a0,0x2
ffffffffc02028f0:	57c50513          	addi	a0,a0,1404 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc02028f4:	b67fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02028f8:	00002697          	auipc	a3,0x2
ffffffffc02028fc:	69068693          	addi	a3,a3,1680 # ffffffffc0204f88 <default_pmm_manager+0x270>
ffffffffc0202900:	00002617          	auipc	a2,0x2
ffffffffc0202904:	06860613          	addi	a2,a2,104 # ffffffffc0204968 <commands+0x818>
ffffffffc0202908:	16700593          	li	a1,359
ffffffffc020290c:	00002517          	auipc	a0,0x2
ffffffffc0202910:	55c50513          	addi	a0,a0,1372 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202914:	b47fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202918:	00002697          	auipc	a3,0x2
ffffffffc020291c:	63068693          	addi	a3,a3,1584 # ffffffffc0204f48 <default_pmm_manager+0x230>
ffffffffc0202920:	00002617          	auipc	a2,0x2
ffffffffc0202924:	04860613          	addi	a2,a2,72 # ffffffffc0204968 <commands+0x818>
ffffffffc0202928:	16600593          	li	a1,358
ffffffffc020292c:	00002517          	auipc	a0,0x2
ffffffffc0202930:	53c50513          	addi	a0,a0,1340 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202934:	b27fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202938:	00002697          	auipc	a3,0x2
ffffffffc020293c:	5f068693          	addi	a3,a3,1520 # ffffffffc0204f28 <default_pmm_manager+0x210>
ffffffffc0202940:	00002617          	auipc	a2,0x2
ffffffffc0202944:	02860613          	addi	a2,a2,40 # ffffffffc0204968 <commands+0x818>
ffffffffc0202948:	16500593          	li	a1,357
ffffffffc020294c:	00002517          	auipc	a0,0x2
ffffffffc0202950:	51c50513          	addi	a0,a0,1308 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202954:	b07fd0ef          	jal	ra,ffffffffc020045a <__panic>
    return KADDR(page2pa(page));
ffffffffc0202958:	00002617          	auipc	a2,0x2
ffffffffc020295c:	3f860613          	addi	a2,a2,1016 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0202960:	07100593          	li	a1,113
ffffffffc0202964:	00002517          	auipc	a0,0x2
ffffffffc0202968:	41450513          	addi	a0,a0,1044 # ffffffffc0204d78 <default_pmm_manager+0x60>
ffffffffc020296c:	aeffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202970:	00003697          	auipc	a3,0x3
ffffffffc0202974:	86868693          	addi	a3,a3,-1944 # ffffffffc02051d8 <default_pmm_manager+0x4c0>
ffffffffc0202978:	00002617          	auipc	a2,0x2
ffffffffc020297c:	ff060613          	addi	a2,a2,-16 # ffffffffc0204968 <commands+0x818>
ffffffffc0202980:	18d00593          	li	a1,397
ffffffffc0202984:	00002517          	auipc	a0,0x2
ffffffffc0202988:	4e450513          	addi	a0,a0,1252 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc020298c:	acffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202990:	00003697          	auipc	a3,0x3
ffffffffc0202994:	80068693          	addi	a3,a3,-2048 # ffffffffc0205190 <default_pmm_manager+0x478>
ffffffffc0202998:	00002617          	auipc	a2,0x2
ffffffffc020299c:	fd060613          	addi	a2,a2,-48 # ffffffffc0204968 <commands+0x818>
ffffffffc02029a0:	18b00593          	li	a1,395
ffffffffc02029a4:	00002517          	auipc	a0,0x2
ffffffffc02029a8:	4c450513          	addi	a0,a0,1220 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc02029ac:	aaffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02029b0:	00003697          	auipc	a3,0x3
ffffffffc02029b4:	81068693          	addi	a3,a3,-2032 # ffffffffc02051c0 <default_pmm_manager+0x4a8>
ffffffffc02029b8:	00002617          	auipc	a2,0x2
ffffffffc02029bc:	fb060613          	addi	a2,a2,-80 # ffffffffc0204968 <commands+0x818>
ffffffffc02029c0:	18a00593          	li	a1,394
ffffffffc02029c4:	00002517          	auipc	a0,0x2
ffffffffc02029c8:	4a450513          	addi	a0,a0,1188 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc02029cc:	a8ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02029d0:	00003697          	auipc	a3,0x3
ffffffffc02029d4:	8d868693          	addi	a3,a3,-1832 # ffffffffc02052a8 <default_pmm_manager+0x590>
ffffffffc02029d8:	00002617          	auipc	a2,0x2
ffffffffc02029dc:	f9060613          	addi	a2,a2,-112 # ffffffffc0204968 <commands+0x818>
ffffffffc02029e0:	1a800593          	li	a1,424
ffffffffc02029e4:	00002517          	auipc	a0,0x2
ffffffffc02029e8:	48450513          	addi	a0,a0,1156 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc02029ec:	a6ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02029f0:	00003697          	auipc	a3,0x3
ffffffffc02029f4:	81868693          	addi	a3,a3,-2024 # ffffffffc0205208 <default_pmm_manager+0x4f0>
ffffffffc02029f8:	00002617          	auipc	a2,0x2
ffffffffc02029fc:	f7060613          	addi	a2,a2,-144 # ffffffffc0204968 <commands+0x818>
ffffffffc0202a00:	19500593          	li	a1,405
ffffffffc0202a04:	00002517          	auipc	a0,0x2
ffffffffc0202a08:	46450513          	addi	a0,a0,1124 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202a0c:	a4ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202a10:	00003697          	auipc	a3,0x3
ffffffffc0202a14:	8f068693          	addi	a3,a3,-1808 # ffffffffc0205300 <default_pmm_manager+0x5e8>
ffffffffc0202a18:	00002617          	auipc	a2,0x2
ffffffffc0202a1c:	f5060613          	addi	a2,a2,-176 # ffffffffc0204968 <commands+0x818>
ffffffffc0202a20:	1ad00593          	li	a1,429
ffffffffc0202a24:	00002517          	auipc	a0,0x2
ffffffffc0202a28:	44450513          	addi	a0,a0,1092 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202a2c:	a2ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a30:	00003697          	auipc	a3,0x3
ffffffffc0202a34:	89068693          	addi	a3,a3,-1904 # ffffffffc02052c0 <default_pmm_manager+0x5a8>
ffffffffc0202a38:	00002617          	auipc	a2,0x2
ffffffffc0202a3c:	f3060613          	addi	a2,a2,-208 # ffffffffc0204968 <commands+0x818>
ffffffffc0202a40:	1ac00593          	li	a1,428
ffffffffc0202a44:	00002517          	auipc	a0,0x2
ffffffffc0202a48:	42450513          	addi	a0,a0,1060 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202a4c:	a0ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202a50:	00002697          	auipc	a3,0x2
ffffffffc0202a54:	74068693          	addi	a3,a3,1856 # ffffffffc0205190 <default_pmm_manager+0x478>
ffffffffc0202a58:	00002617          	auipc	a2,0x2
ffffffffc0202a5c:	f1060613          	addi	a2,a2,-240 # ffffffffc0204968 <commands+0x818>
ffffffffc0202a60:	18700593          	li	a1,391
ffffffffc0202a64:	00002517          	auipc	a0,0x2
ffffffffc0202a68:	40450513          	addi	a0,a0,1028 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202a6c:	9effd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202a70:	00002697          	auipc	a3,0x2
ffffffffc0202a74:	5c068693          	addi	a3,a3,1472 # ffffffffc0205030 <default_pmm_manager+0x318>
ffffffffc0202a78:	00002617          	auipc	a2,0x2
ffffffffc0202a7c:	ef060613          	addi	a2,a2,-272 # ffffffffc0204968 <commands+0x818>
ffffffffc0202a80:	18600593          	li	a1,390
ffffffffc0202a84:	00002517          	auipc	a0,0x2
ffffffffc0202a88:	3e450513          	addi	a0,a0,996 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202a8c:	9cffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a90:	00002697          	auipc	a3,0x2
ffffffffc0202a94:	71868693          	addi	a3,a3,1816 # ffffffffc02051a8 <default_pmm_manager+0x490>
ffffffffc0202a98:	00002617          	auipc	a2,0x2
ffffffffc0202a9c:	ed060613          	addi	a2,a2,-304 # ffffffffc0204968 <commands+0x818>
ffffffffc0202aa0:	18300593          	li	a1,387
ffffffffc0202aa4:	00002517          	auipc	a0,0x2
ffffffffc0202aa8:	3c450513          	addi	a0,a0,964 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202aac:	9affd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202ab0:	00002697          	auipc	a3,0x2
ffffffffc0202ab4:	56868693          	addi	a3,a3,1384 # ffffffffc0205018 <default_pmm_manager+0x300>
ffffffffc0202ab8:	00002617          	auipc	a2,0x2
ffffffffc0202abc:	eb060613          	addi	a2,a2,-336 # ffffffffc0204968 <commands+0x818>
ffffffffc0202ac0:	18200593          	li	a1,386
ffffffffc0202ac4:	00002517          	auipc	a0,0x2
ffffffffc0202ac8:	3a450513          	addi	a0,a0,932 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202acc:	98ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202ad0:	00002697          	auipc	a3,0x2
ffffffffc0202ad4:	5e868693          	addi	a3,a3,1512 # ffffffffc02050b8 <default_pmm_manager+0x3a0>
ffffffffc0202ad8:	00002617          	auipc	a2,0x2
ffffffffc0202adc:	e9060613          	addi	a2,a2,-368 # ffffffffc0204968 <commands+0x818>
ffffffffc0202ae0:	18100593          	li	a1,385
ffffffffc0202ae4:	00002517          	auipc	a0,0x2
ffffffffc0202ae8:	38450513          	addi	a0,a0,900 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202aec:	96ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202af0:	00002697          	auipc	a3,0x2
ffffffffc0202af4:	6a068693          	addi	a3,a3,1696 # ffffffffc0205190 <default_pmm_manager+0x478>
ffffffffc0202af8:	00002617          	auipc	a2,0x2
ffffffffc0202afc:	e7060613          	addi	a2,a2,-400 # ffffffffc0204968 <commands+0x818>
ffffffffc0202b00:	18000593          	li	a1,384
ffffffffc0202b04:	00002517          	auipc	a0,0x2
ffffffffc0202b08:	36450513          	addi	a0,a0,868 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202b0c:	94ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202b10:	00002697          	auipc	a3,0x2
ffffffffc0202b14:	66868693          	addi	a3,a3,1640 # ffffffffc0205178 <default_pmm_manager+0x460>
ffffffffc0202b18:	00002617          	auipc	a2,0x2
ffffffffc0202b1c:	e5060613          	addi	a2,a2,-432 # ffffffffc0204968 <commands+0x818>
ffffffffc0202b20:	17f00593          	li	a1,383
ffffffffc0202b24:	00002517          	auipc	a0,0x2
ffffffffc0202b28:	34450513          	addi	a0,a0,836 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202b2c:	92ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202b30:	00002697          	auipc	a3,0x2
ffffffffc0202b34:	61868693          	addi	a3,a3,1560 # ffffffffc0205148 <default_pmm_manager+0x430>
ffffffffc0202b38:	00002617          	auipc	a2,0x2
ffffffffc0202b3c:	e3060613          	addi	a2,a2,-464 # ffffffffc0204968 <commands+0x818>
ffffffffc0202b40:	17e00593          	li	a1,382
ffffffffc0202b44:	00002517          	auipc	a0,0x2
ffffffffc0202b48:	32450513          	addi	a0,a0,804 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202b4c:	90ffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202b50:	00002697          	auipc	a3,0x2
ffffffffc0202b54:	5e068693          	addi	a3,a3,1504 # ffffffffc0205130 <default_pmm_manager+0x418>
ffffffffc0202b58:	00002617          	auipc	a2,0x2
ffffffffc0202b5c:	e1060613          	addi	a2,a2,-496 # ffffffffc0204968 <commands+0x818>
ffffffffc0202b60:	17c00593          	li	a1,380
ffffffffc0202b64:	00002517          	auipc	a0,0x2
ffffffffc0202b68:	30450513          	addi	a0,a0,772 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202b6c:	8effd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202b70:	00002697          	auipc	a3,0x2
ffffffffc0202b74:	5a068693          	addi	a3,a3,1440 # ffffffffc0205110 <default_pmm_manager+0x3f8>
ffffffffc0202b78:	00002617          	auipc	a2,0x2
ffffffffc0202b7c:	df060613          	addi	a2,a2,-528 # ffffffffc0204968 <commands+0x818>
ffffffffc0202b80:	17b00593          	li	a1,379
ffffffffc0202b84:	00002517          	auipc	a0,0x2
ffffffffc0202b88:	2e450513          	addi	a0,a0,740 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202b8c:	8cffd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202b90:	00002697          	auipc	a3,0x2
ffffffffc0202b94:	57068693          	addi	a3,a3,1392 # ffffffffc0205100 <default_pmm_manager+0x3e8>
ffffffffc0202b98:	00002617          	auipc	a2,0x2
ffffffffc0202b9c:	dd060613          	addi	a2,a2,-560 # ffffffffc0204968 <commands+0x818>
ffffffffc0202ba0:	17a00593          	li	a1,378
ffffffffc0202ba4:	00002517          	auipc	a0,0x2
ffffffffc0202ba8:	2c450513          	addi	a0,a0,708 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202bac:	8affd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202bb0:	00002697          	auipc	a3,0x2
ffffffffc0202bb4:	54068693          	addi	a3,a3,1344 # ffffffffc02050f0 <default_pmm_manager+0x3d8>
ffffffffc0202bb8:	00002617          	auipc	a2,0x2
ffffffffc0202bbc:	db060613          	addi	a2,a2,-592 # ffffffffc0204968 <commands+0x818>
ffffffffc0202bc0:	17900593          	li	a1,377
ffffffffc0202bc4:	00002517          	auipc	a0,0x2
ffffffffc0202bc8:	2a450513          	addi	a0,a0,676 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202bcc:	88ffd0ef          	jal	ra,ffffffffc020045a <__panic>
        panic("DTB memory info not available");
ffffffffc0202bd0:	00002617          	auipc	a2,0x2
ffffffffc0202bd4:	2c060613          	addi	a2,a2,704 # ffffffffc0204e90 <default_pmm_manager+0x178>
ffffffffc0202bd8:	06400593          	li	a1,100
ffffffffc0202bdc:	00002517          	auipc	a0,0x2
ffffffffc0202be0:	28c50513          	addi	a0,a0,652 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202be4:	877fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202be8:	00002697          	auipc	a3,0x2
ffffffffc0202bec:	62068693          	addi	a3,a3,1568 # ffffffffc0205208 <default_pmm_manager+0x4f0>
ffffffffc0202bf0:	00002617          	auipc	a2,0x2
ffffffffc0202bf4:	d7860613          	addi	a2,a2,-648 # ffffffffc0204968 <commands+0x818>
ffffffffc0202bf8:	1bf00593          	li	a1,447
ffffffffc0202bfc:	00002517          	auipc	a0,0x2
ffffffffc0202c00:	26c50513          	addi	a0,a0,620 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202c04:	857fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202c08:	00002697          	auipc	a3,0x2
ffffffffc0202c0c:	4b068693          	addi	a3,a3,1200 # ffffffffc02050b8 <default_pmm_manager+0x3a0>
ffffffffc0202c10:	00002617          	auipc	a2,0x2
ffffffffc0202c14:	d5860613          	addi	a2,a2,-680 # ffffffffc0204968 <commands+0x818>
ffffffffc0202c18:	17800593          	li	a1,376
ffffffffc0202c1c:	00002517          	auipc	a0,0x2
ffffffffc0202c20:	24c50513          	addi	a0,a0,588 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202c24:	837fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202c28:	00002697          	auipc	a3,0x2
ffffffffc0202c2c:	45068693          	addi	a3,a3,1104 # ffffffffc0205078 <default_pmm_manager+0x360>
ffffffffc0202c30:	00002617          	auipc	a2,0x2
ffffffffc0202c34:	d3860613          	addi	a2,a2,-712 # ffffffffc0204968 <commands+0x818>
ffffffffc0202c38:	17700593          	li	a1,375
ffffffffc0202c3c:	00002517          	auipc	a0,0x2
ffffffffc0202c40:	22c50513          	addi	a0,a0,556 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202c44:	817fd0ef          	jal	ra,ffffffffc020045a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202c48:	86d6                	mv	a3,s5
ffffffffc0202c4a:	00002617          	auipc	a2,0x2
ffffffffc0202c4e:	10660613          	addi	a2,a2,262 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0202c52:	17300593          	li	a1,371
ffffffffc0202c56:	00002517          	auipc	a0,0x2
ffffffffc0202c5a:	21250513          	addi	a0,a0,530 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202c5e:	ffcfd0ef          	jal	ra,ffffffffc020045a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202c62:	00002617          	auipc	a2,0x2
ffffffffc0202c66:	0ee60613          	addi	a2,a2,238 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc0202c6a:	17200593          	li	a1,370
ffffffffc0202c6e:	00002517          	auipc	a0,0x2
ffffffffc0202c72:	1fa50513          	addi	a0,a0,506 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202c76:	fe4fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202c7a:	00002697          	auipc	a3,0x2
ffffffffc0202c7e:	3b668693          	addi	a3,a3,950 # ffffffffc0205030 <default_pmm_manager+0x318>
ffffffffc0202c82:	00002617          	auipc	a2,0x2
ffffffffc0202c86:	ce660613          	addi	a2,a2,-794 # ffffffffc0204968 <commands+0x818>
ffffffffc0202c8a:	17000593          	li	a1,368
ffffffffc0202c8e:	00002517          	auipc	a0,0x2
ffffffffc0202c92:	1da50513          	addi	a0,a0,474 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202c96:	fc4fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c9a:	00002697          	auipc	a3,0x2
ffffffffc0202c9e:	37e68693          	addi	a3,a3,894 # ffffffffc0205018 <default_pmm_manager+0x300>
ffffffffc0202ca2:	00002617          	auipc	a2,0x2
ffffffffc0202ca6:	cc660613          	addi	a2,a2,-826 # ffffffffc0204968 <commands+0x818>
ffffffffc0202caa:	16f00593          	li	a1,367
ffffffffc0202cae:	00002517          	auipc	a0,0x2
ffffffffc0202cb2:	1ba50513          	addi	a0,a0,442 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202cb6:	fa4fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202cba:	00002697          	auipc	a3,0x2
ffffffffc0202cbe:	70e68693          	addi	a3,a3,1806 # ffffffffc02053c8 <default_pmm_manager+0x6b0>
ffffffffc0202cc2:	00002617          	auipc	a2,0x2
ffffffffc0202cc6:	ca660613          	addi	a2,a2,-858 # ffffffffc0204968 <commands+0x818>
ffffffffc0202cca:	1b600593          	li	a1,438
ffffffffc0202cce:	00002517          	auipc	a0,0x2
ffffffffc0202cd2:	19a50513          	addi	a0,a0,410 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202cd6:	f84fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202cda:	00002697          	auipc	a3,0x2
ffffffffc0202cde:	6b668693          	addi	a3,a3,1718 # ffffffffc0205390 <default_pmm_manager+0x678>
ffffffffc0202ce2:	00002617          	auipc	a2,0x2
ffffffffc0202ce6:	c8660613          	addi	a2,a2,-890 # ffffffffc0204968 <commands+0x818>
ffffffffc0202cea:	1b300593          	li	a1,435
ffffffffc0202cee:	00002517          	auipc	a0,0x2
ffffffffc0202cf2:	17a50513          	addi	a0,a0,378 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202cf6:	f64fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202cfa:	00002697          	auipc	a3,0x2
ffffffffc0202cfe:	66668693          	addi	a3,a3,1638 # ffffffffc0205360 <default_pmm_manager+0x648>
ffffffffc0202d02:	00002617          	auipc	a2,0x2
ffffffffc0202d06:	c6660613          	addi	a2,a2,-922 # ffffffffc0204968 <commands+0x818>
ffffffffc0202d0a:	1af00593          	li	a1,431
ffffffffc0202d0e:	00002517          	auipc	a0,0x2
ffffffffc0202d12:	15a50513          	addi	a0,a0,346 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202d16:	f44fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202d1a:	00002697          	auipc	a3,0x2
ffffffffc0202d1e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0205318 <default_pmm_manager+0x600>
ffffffffc0202d22:	00002617          	auipc	a2,0x2
ffffffffc0202d26:	c4660613          	addi	a2,a2,-954 # ffffffffc0204968 <commands+0x818>
ffffffffc0202d2a:	1ae00593          	li	a1,430
ffffffffc0202d2e:	00002517          	auipc	a0,0x2
ffffffffc0202d32:	13a50513          	addi	a0,a0,314 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202d36:	f24fd0ef          	jal	ra,ffffffffc020045a <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202d3a:	00002617          	auipc	a2,0x2
ffffffffc0202d3e:	0be60613          	addi	a2,a2,190 # ffffffffc0204df8 <default_pmm_manager+0xe0>
ffffffffc0202d42:	0cb00593          	li	a1,203
ffffffffc0202d46:	00002517          	auipc	a0,0x2
ffffffffc0202d4a:	12250513          	addi	a0,a0,290 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202d4e:	f0cfd0ef          	jal	ra,ffffffffc020045a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202d52:	00002617          	auipc	a2,0x2
ffffffffc0202d56:	0a660613          	addi	a2,a2,166 # ffffffffc0204df8 <default_pmm_manager+0xe0>
ffffffffc0202d5a:	08000593          	li	a1,128
ffffffffc0202d5e:	00002517          	auipc	a0,0x2
ffffffffc0202d62:	10a50513          	addi	a0,a0,266 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202d66:	ef4fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202d6a:	00002697          	auipc	a3,0x2
ffffffffc0202d6e:	27e68693          	addi	a3,a3,638 # ffffffffc0204fe8 <default_pmm_manager+0x2d0>
ffffffffc0202d72:	00002617          	auipc	a2,0x2
ffffffffc0202d76:	bf660613          	addi	a2,a2,-1034 # ffffffffc0204968 <commands+0x818>
ffffffffc0202d7a:	16e00593          	li	a1,366
ffffffffc0202d7e:	00002517          	auipc	a0,0x2
ffffffffc0202d82:	0ea50513          	addi	a0,a0,234 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202d86:	ed4fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202d8a:	00002697          	auipc	a3,0x2
ffffffffc0202d8e:	22e68693          	addi	a3,a3,558 # ffffffffc0204fb8 <default_pmm_manager+0x2a0>
ffffffffc0202d92:	00002617          	auipc	a2,0x2
ffffffffc0202d96:	bd660613          	addi	a2,a2,-1066 # ffffffffc0204968 <commands+0x818>
ffffffffc0202d9a:	16b00593          	li	a1,363
ffffffffc0202d9e:	00002517          	auipc	a0,0x2
ffffffffc0202da2:	0ca50513          	addi	a0,a0,202 # ffffffffc0204e68 <default_pmm_manager+0x150>
ffffffffc0202da6:	eb4fd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0202daa <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0202daa:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202dac:	00002697          	auipc	a3,0x2
ffffffffc0202db0:	66468693          	addi	a3,a3,1636 # ffffffffc0205410 <default_pmm_manager+0x6f8>
ffffffffc0202db4:	00002617          	auipc	a2,0x2
ffffffffc0202db8:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204968 <commands+0x818>
ffffffffc0202dbc:	08800593          	li	a1,136
ffffffffc0202dc0:	00002517          	auipc	a0,0x2
ffffffffc0202dc4:	67050513          	addi	a0,a0,1648 # ffffffffc0205430 <default_pmm_manager+0x718>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0202dc8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0202dca:	e90fd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0202dce <find_vma>:
{
ffffffffc0202dce:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0202dd0:	c505                	beqz	a0,ffffffffc0202df8 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0202dd2:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0202dd4:	c501                	beqz	a0,ffffffffc0202ddc <find_vma+0xe>
ffffffffc0202dd6:	651c                	ld	a5,8(a0)
ffffffffc0202dd8:	02f5f263          	bgeu	a1,a5,ffffffffc0202dfc <find_vma+0x2e>
    return listelm->next;
ffffffffc0202ddc:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0202dde:	00f68d63          	beq	a3,a5,ffffffffc0202df8 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0202de2:	fe87b703          	ld	a4,-24(a5) # ffffffffc7ffffe8 <end+0x7df2afc>
ffffffffc0202de6:	00e5e663          	bltu	a1,a4,ffffffffc0202df2 <find_vma+0x24>
ffffffffc0202dea:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202dee:	00e5ec63          	bltu	a1,a4,ffffffffc0202e06 <find_vma+0x38>
ffffffffc0202df2:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0202df4:	fef697e3          	bne	a3,a5,ffffffffc0202de2 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0202df8:	4501                	li	a0,0
}
ffffffffc0202dfa:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0202dfc:	691c                	ld	a5,16(a0)
ffffffffc0202dfe:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202ddc <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202e02:	ea88                	sd	a0,16(a3)
ffffffffc0202e04:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0202e06:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0202e0a:	ea88                	sd	a0,16(a3)
ffffffffc0202e0c:	8082                	ret

ffffffffc0202e0e <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202e0e:	6590                	ld	a2,8(a1)
ffffffffc0202e10:	0105b803          	ld	a6,16(a1)
{
ffffffffc0202e14:	1141                	addi	sp,sp,-16
ffffffffc0202e16:	e406                	sd	ra,8(sp)
ffffffffc0202e18:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202e1a:	01066763          	bltu	a2,a6,ffffffffc0202e28 <insert_vma_struct+0x1a>
ffffffffc0202e1e:	a085                	j	ffffffffc0202e7e <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0202e20:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202e24:	04e66863          	bltu	a2,a4,ffffffffc0202e74 <insert_vma_struct+0x66>
ffffffffc0202e28:	86be                	mv	a3,a5
ffffffffc0202e2a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0202e2c:	fef51ae3          	bne	a0,a5,ffffffffc0202e20 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0202e30:	02a68463          	beq	a3,a0,ffffffffc0202e58 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202e34:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202e38:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202e3c:	08e8f163          	bgeu	a7,a4,ffffffffc0202ebe <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202e40:	04e66f63          	bltu	a2,a4,ffffffffc0202e9e <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0202e44:	00f50a63          	beq	a0,a5,ffffffffc0202e58 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0202e48:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202e4c:	05076963          	bltu	a4,a6,ffffffffc0202e9e <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0202e50:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202e54:	02c77363          	bgeu	a4,a2,ffffffffc0202e7a <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0202e58:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0202e5a:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202e5c:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0202e60:	e390                	sd	a2,0(a5)
ffffffffc0202e62:	e690                	sd	a2,8(a3)
}
ffffffffc0202e64:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202e66:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202e68:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0202e6a:	0017079b          	addiw	a5,a4,1
ffffffffc0202e6e:	d11c                	sw	a5,32(a0)
}
ffffffffc0202e70:	0141                	addi	sp,sp,16
ffffffffc0202e72:	8082                	ret
    if (le_prev != list)
ffffffffc0202e74:	fca690e3          	bne	a3,a0,ffffffffc0202e34 <insert_vma_struct+0x26>
ffffffffc0202e78:	bfd1                	j	ffffffffc0202e4c <insert_vma_struct+0x3e>
ffffffffc0202e7a:	f31ff0ef          	jal	ra,ffffffffc0202daa <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202e7e:	00002697          	auipc	a3,0x2
ffffffffc0202e82:	5c268693          	addi	a3,a3,1474 # ffffffffc0205440 <default_pmm_manager+0x728>
ffffffffc0202e86:	00002617          	auipc	a2,0x2
ffffffffc0202e8a:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204968 <commands+0x818>
ffffffffc0202e8e:	08e00593          	li	a1,142
ffffffffc0202e92:	00002517          	auipc	a0,0x2
ffffffffc0202e96:	59e50513          	addi	a0,a0,1438 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0202e9a:	dc0fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202e9e:	00002697          	auipc	a3,0x2
ffffffffc0202ea2:	5e268693          	addi	a3,a3,1506 # ffffffffc0205480 <default_pmm_manager+0x768>
ffffffffc0202ea6:	00002617          	auipc	a2,0x2
ffffffffc0202eaa:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204968 <commands+0x818>
ffffffffc0202eae:	08700593          	li	a1,135
ffffffffc0202eb2:	00002517          	auipc	a0,0x2
ffffffffc0202eb6:	57e50513          	addi	a0,a0,1406 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0202eba:	da0fd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202ebe:	00002697          	auipc	a3,0x2
ffffffffc0202ec2:	5a268693          	addi	a3,a3,1442 # ffffffffc0205460 <default_pmm_manager+0x748>
ffffffffc0202ec6:	00002617          	auipc	a2,0x2
ffffffffc0202eca:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204968 <commands+0x818>
ffffffffc0202ece:	08600593          	li	a1,134
ffffffffc0202ed2:	00002517          	auipc	a0,0x2
ffffffffc0202ed6:	55e50513          	addi	a0,a0,1374 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0202eda:	d80fd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0202ede <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0202ede:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202ee0:	03000513          	li	a0,48
{
ffffffffc0202ee4:	fc06                	sd	ra,56(sp)
ffffffffc0202ee6:	f822                	sd	s0,48(sp)
ffffffffc0202ee8:	f426                	sd	s1,40(sp)
ffffffffc0202eea:	f04a                	sd	s2,32(sp)
ffffffffc0202eec:	ec4e                	sd	s3,24(sp)
ffffffffc0202eee:	e852                	sd	s4,16(sp)
ffffffffc0202ef0:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202ef2:	bd5fe0ef          	jal	ra,ffffffffc0201ac6 <kmalloc>
    if (mm != NULL)
ffffffffc0202ef6:	2e050f63          	beqz	a0,ffffffffc02031f4 <vmm_init+0x316>
ffffffffc0202efa:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0202efc:	e508                	sd	a0,8(a0)
ffffffffc0202efe:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202f00:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202f04:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202f08:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0202f0c:	02053423          	sd	zero,40(a0)
ffffffffc0202f10:	03200413          	li	s0,50
ffffffffc0202f14:	a811                	j	ffffffffc0202f28 <vmm_init+0x4a>
        vma->vm_start = vm_start;
ffffffffc0202f16:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202f18:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202f1a:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0202f1e:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202f20:	8526                	mv	a0,s1
ffffffffc0202f22:	eedff0ef          	jal	ra,ffffffffc0202e0e <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0202f26:	c80d                	beqz	s0,ffffffffc0202f58 <vmm_init+0x7a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202f28:	03000513          	li	a0,48
ffffffffc0202f2c:	b9bfe0ef          	jal	ra,ffffffffc0201ac6 <kmalloc>
ffffffffc0202f30:	85aa                	mv	a1,a0
ffffffffc0202f32:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0202f36:	f165                	bnez	a0,ffffffffc0202f16 <vmm_init+0x38>
        assert(vma != NULL);
ffffffffc0202f38:	00002697          	auipc	a3,0x2
ffffffffc0202f3c:	6e068693          	addi	a3,a3,1760 # ffffffffc0205618 <default_pmm_manager+0x900>
ffffffffc0202f40:	00002617          	auipc	a2,0x2
ffffffffc0202f44:	a2860613          	addi	a2,a2,-1496 # ffffffffc0204968 <commands+0x818>
ffffffffc0202f48:	0da00593          	li	a1,218
ffffffffc0202f4c:	00002517          	auipc	a0,0x2
ffffffffc0202f50:	4e450513          	addi	a0,a0,1252 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0202f54:	d06fd0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc0202f58:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f5c:	1f900913          	li	s2,505
ffffffffc0202f60:	a819                	j	ffffffffc0202f76 <vmm_init+0x98>
        vma->vm_start = vm_start;
ffffffffc0202f62:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202f64:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202f66:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f6a:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202f6c:	8526                	mv	a0,s1
ffffffffc0202f6e:	ea1ff0ef          	jal	ra,ffffffffc0202e0e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f72:	03240a63          	beq	s0,s2,ffffffffc0202fa6 <vmm_init+0xc8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202f76:	03000513          	li	a0,48
ffffffffc0202f7a:	b4dfe0ef          	jal	ra,ffffffffc0201ac6 <kmalloc>
ffffffffc0202f7e:	85aa                	mv	a1,a0
ffffffffc0202f80:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0202f84:	fd79                	bnez	a0,ffffffffc0202f62 <vmm_init+0x84>
        assert(vma != NULL);
ffffffffc0202f86:	00002697          	auipc	a3,0x2
ffffffffc0202f8a:	69268693          	addi	a3,a3,1682 # ffffffffc0205618 <default_pmm_manager+0x900>
ffffffffc0202f8e:	00002617          	auipc	a2,0x2
ffffffffc0202f92:	9da60613          	addi	a2,a2,-1574 # ffffffffc0204968 <commands+0x818>
ffffffffc0202f96:	0e100593          	li	a1,225
ffffffffc0202f9a:	00002517          	auipc	a0,0x2
ffffffffc0202f9e:	49650513          	addi	a0,a0,1174 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0202fa2:	cb8fd0ef          	jal	ra,ffffffffc020045a <__panic>
    return listelm->next;
ffffffffc0202fa6:	649c                	ld	a5,8(s1)
ffffffffc0202fa8:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0202faa:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0202fae:	18f48363          	beq	s1,a5,ffffffffc0203134 <vmm_init+0x256>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202fb2:	fe87b603          	ld	a2,-24(a5)
ffffffffc0202fb6:	ffe70693          	addi	a3,a4,-2 # ffe <kern_entry-0xffffffffc01ff002>
ffffffffc0202fba:	10d61d63          	bne	a2,a3,ffffffffc02030d4 <vmm_init+0x1f6>
ffffffffc0202fbe:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202fc2:	10e69963          	bne	a3,a4,ffffffffc02030d4 <vmm_init+0x1f6>
    for (i = 1; i <= step2; i++)
ffffffffc0202fc6:	0715                	addi	a4,a4,5
ffffffffc0202fc8:	679c                	ld	a5,8(a5)
ffffffffc0202fca:	feb712e3          	bne	a4,a1,ffffffffc0202fae <vmm_init+0xd0>
ffffffffc0202fce:	4a1d                	li	s4,7
ffffffffc0202fd0:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202fd2:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202fd6:	85a2                	mv	a1,s0
ffffffffc0202fd8:	8526                	mv	a0,s1
ffffffffc0202fda:	df5ff0ef          	jal	ra,ffffffffc0202dce <find_vma>
ffffffffc0202fde:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202fe0:	18050a63          	beqz	a0,ffffffffc0203174 <vmm_init+0x296>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0202fe4:	00140593          	addi	a1,s0,1
ffffffffc0202fe8:	8526                	mv	a0,s1
ffffffffc0202fea:	de5ff0ef          	jal	ra,ffffffffc0202dce <find_vma>
ffffffffc0202fee:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202ff0:	16050263          	beqz	a0,ffffffffc0203154 <vmm_init+0x276>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0202ff4:	85d2                	mv	a1,s4
ffffffffc0202ff6:	8526                	mv	a0,s1
ffffffffc0202ff8:	dd7ff0ef          	jal	ra,ffffffffc0202dce <find_vma>
        assert(vma3 == NULL);
ffffffffc0202ffc:	18051c63          	bnez	a0,ffffffffc0203194 <vmm_init+0x2b6>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203000:	00340593          	addi	a1,s0,3
ffffffffc0203004:	8526                	mv	a0,s1
ffffffffc0203006:	dc9ff0ef          	jal	ra,ffffffffc0202dce <find_vma>
        assert(vma4 == NULL);
ffffffffc020300a:	1c051563          	bnez	a0,ffffffffc02031d4 <vmm_init+0x2f6>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc020300e:	00440593          	addi	a1,s0,4
ffffffffc0203012:	8526                	mv	a0,s1
ffffffffc0203014:	dbbff0ef          	jal	ra,ffffffffc0202dce <find_vma>
        assert(vma5 == NULL);
ffffffffc0203018:	18051e63          	bnez	a0,ffffffffc02031b4 <vmm_init+0x2d6>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc020301c:	00893783          	ld	a5,8(s2)
ffffffffc0203020:	0c879a63          	bne	a5,s0,ffffffffc02030f4 <vmm_init+0x216>
ffffffffc0203024:	01093783          	ld	a5,16(s2)
ffffffffc0203028:	0d479663          	bne	a5,s4,ffffffffc02030f4 <vmm_init+0x216>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc020302c:	0089b783          	ld	a5,8(s3)
ffffffffc0203030:	0e879263          	bne	a5,s0,ffffffffc0203114 <vmm_init+0x236>
ffffffffc0203034:	0109b783          	ld	a5,16(s3)
ffffffffc0203038:	0d479e63          	bne	a5,s4,ffffffffc0203114 <vmm_init+0x236>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020303c:	0415                	addi	s0,s0,5
ffffffffc020303e:	0a15                	addi	s4,s4,5
ffffffffc0203040:	f9541be3          	bne	s0,s5,ffffffffc0202fd6 <vmm_init+0xf8>
ffffffffc0203044:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203046:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203048:	85a2                	mv	a1,s0
ffffffffc020304a:	8526                	mv	a0,s1
ffffffffc020304c:	d83ff0ef          	jal	ra,ffffffffc0202dce <find_vma>
ffffffffc0203050:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203054:	c90d                	beqz	a0,ffffffffc0203086 <vmm_init+0x1a8>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203056:	6914                	ld	a3,16(a0)
ffffffffc0203058:	6510                	ld	a2,8(a0)
ffffffffc020305a:	00002517          	auipc	a0,0x2
ffffffffc020305e:	54650513          	addi	a0,a0,1350 # ffffffffc02055a0 <default_pmm_manager+0x888>
ffffffffc0203062:	932fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203066:	00002697          	auipc	a3,0x2
ffffffffc020306a:	56268693          	addi	a3,a3,1378 # ffffffffc02055c8 <default_pmm_manager+0x8b0>
ffffffffc020306e:	00002617          	auipc	a2,0x2
ffffffffc0203072:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0204968 <commands+0x818>
ffffffffc0203076:	10700593          	li	a1,263
ffffffffc020307a:	00002517          	auipc	a0,0x2
ffffffffc020307e:	3b650513          	addi	a0,a0,950 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0203082:	bd8fd0ef          	jal	ra,ffffffffc020045a <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203086:	147d                	addi	s0,s0,-1
ffffffffc0203088:	fd2410e3          	bne	s0,s2,ffffffffc0203048 <vmm_init+0x16a>
ffffffffc020308c:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc020308e:	00a48c63          	beq	s1,a0,ffffffffc02030a6 <vmm_init+0x1c8>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203092:	6118                	ld	a4,0(a0)
ffffffffc0203094:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0203096:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203098:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020309a:	e398                	sd	a4,0(a5)
ffffffffc020309c:	adbfe0ef          	jal	ra,ffffffffc0201b76 <kfree>
    return listelm->next;
ffffffffc02030a0:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc02030a2:	fea498e3          	bne	s1,a0,ffffffffc0203092 <vmm_init+0x1b4>
    kfree(mm); // kfree mm
ffffffffc02030a6:	8526                	mv	a0,s1
ffffffffc02030a8:	acffe0ef          	jal	ra,ffffffffc0201b76 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02030ac:	00002517          	auipc	a0,0x2
ffffffffc02030b0:	53450513          	addi	a0,a0,1332 # ffffffffc02055e0 <default_pmm_manager+0x8c8>
ffffffffc02030b4:	8e0fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc02030b8:	7442                	ld	s0,48(sp)
ffffffffc02030ba:	70e2                	ld	ra,56(sp)
ffffffffc02030bc:	74a2                	ld	s1,40(sp)
ffffffffc02030be:	7902                	ld	s2,32(sp)
ffffffffc02030c0:	69e2                	ld	s3,24(sp)
ffffffffc02030c2:	6a42                	ld	s4,16(sp)
ffffffffc02030c4:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02030c6:	00002517          	auipc	a0,0x2
ffffffffc02030ca:	53a50513          	addi	a0,a0,1338 # ffffffffc0205600 <default_pmm_manager+0x8e8>
}
ffffffffc02030ce:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02030d0:	8c4fd06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02030d4:	00002697          	auipc	a3,0x2
ffffffffc02030d8:	3e468693          	addi	a3,a3,996 # ffffffffc02054b8 <default_pmm_manager+0x7a0>
ffffffffc02030dc:	00002617          	auipc	a2,0x2
ffffffffc02030e0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0204968 <commands+0x818>
ffffffffc02030e4:	0eb00593          	li	a1,235
ffffffffc02030e8:	00002517          	auipc	a0,0x2
ffffffffc02030ec:	34850513          	addi	a0,a0,840 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc02030f0:	b6afd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02030f4:	00002697          	auipc	a3,0x2
ffffffffc02030f8:	44c68693          	addi	a3,a3,1100 # ffffffffc0205540 <default_pmm_manager+0x828>
ffffffffc02030fc:	00002617          	auipc	a2,0x2
ffffffffc0203100:	86c60613          	addi	a2,a2,-1940 # ffffffffc0204968 <commands+0x818>
ffffffffc0203104:	0fc00593          	li	a1,252
ffffffffc0203108:	00002517          	auipc	a0,0x2
ffffffffc020310c:	32850513          	addi	a0,a0,808 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0203110:	b4afd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203114:	00002697          	auipc	a3,0x2
ffffffffc0203118:	45c68693          	addi	a3,a3,1116 # ffffffffc0205570 <default_pmm_manager+0x858>
ffffffffc020311c:	00002617          	auipc	a2,0x2
ffffffffc0203120:	84c60613          	addi	a2,a2,-1972 # ffffffffc0204968 <commands+0x818>
ffffffffc0203124:	0fd00593          	li	a1,253
ffffffffc0203128:	00002517          	auipc	a0,0x2
ffffffffc020312c:	30850513          	addi	a0,a0,776 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0203130:	b2afd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203134:	00002697          	auipc	a3,0x2
ffffffffc0203138:	36c68693          	addi	a3,a3,876 # ffffffffc02054a0 <default_pmm_manager+0x788>
ffffffffc020313c:	00002617          	auipc	a2,0x2
ffffffffc0203140:	82c60613          	addi	a2,a2,-2004 # ffffffffc0204968 <commands+0x818>
ffffffffc0203144:	0e900593          	li	a1,233
ffffffffc0203148:	00002517          	auipc	a0,0x2
ffffffffc020314c:	2e850513          	addi	a0,a0,744 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0203150:	b0afd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(vma2 != NULL);
ffffffffc0203154:	00002697          	auipc	a3,0x2
ffffffffc0203158:	3ac68693          	addi	a3,a3,940 # ffffffffc0205500 <default_pmm_manager+0x7e8>
ffffffffc020315c:	00002617          	auipc	a2,0x2
ffffffffc0203160:	80c60613          	addi	a2,a2,-2036 # ffffffffc0204968 <commands+0x818>
ffffffffc0203164:	0f400593          	li	a1,244
ffffffffc0203168:	00002517          	auipc	a0,0x2
ffffffffc020316c:	2c850513          	addi	a0,a0,712 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0203170:	aeafd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(vma1 != NULL);
ffffffffc0203174:	00002697          	auipc	a3,0x2
ffffffffc0203178:	37c68693          	addi	a3,a3,892 # ffffffffc02054f0 <default_pmm_manager+0x7d8>
ffffffffc020317c:	00001617          	auipc	a2,0x1
ffffffffc0203180:	7ec60613          	addi	a2,a2,2028 # ffffffffc0204968 <commands+0x818>
ffffffffc0203184:	0f200593          	li	a1,242
ffffffffc0203188:	00002517          	auipc	a0,0x2
ffffffffc020318c:	2a850513          	addi	a0,a0,680 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0203190:	acafd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(vma3 == NULL);
ffffffffc0203194:	00002697          	auipc	a3,0x2
ffffffffc0203198:	37c68693          	addi	a3,a3,892 # ffffffffc0205510 <default_pmm_manager+0x7f8>
ffffffffc020319c:	00001617          	auipc	a2,0x1
ffffffffc02031a0:	7cc60613          	addi	a2,a2,1996 # ffffffffc0204968 <commands+0x818>
ffffffffc02031a4:	0f600593          	li	a1,246
ffffffffc02031a8:	00002517          	auipc	a0,0x2
ffffffffc02031ac:	28850513          	addi	a0,a0,648 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc02031b0:	aaafd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(vma5 == NULL);
ffffffffc02031b4:	00002697          	auipc	a3,0x2
ffffffffc02031b8:	37c68693          	addi	a3,a3,892 # ffffffffc0205530 <default_pmm_manager+0x818>
ffffffffc02031bc:	00001617          	auipc	a2,0x1
ffffffffc02031c0:	7ac60613          	addi	a2,a2,1964 # ffffffffc0204968 <commands+0x818>
ffffffffc02031c4:	0fa00593          	li	a1,250
ffffffffc02031c8:	00002517          	auipc	a0,0x2
ffffffffc02031cc:	26850513          	addi	a0,a0,616 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc02031d0:	a8afd0ef          	jal	ra,ffffffffc020045a <__panic>
        assert(vma4 == NULL);
ffffffffc02031d4:	00002697          	auipc	a3,0x2
ffffffffc02031d8:	34c68693          	addi	a3,a3,844 # ffffffffc0205520 <default_pmm_manager+0x808>
ffffffffc02031dc:	00001617          	auipc	a2,0x1
ffffffffc02031e0:	78c60613          	addi	a2,a2,1932 # ffffffffc0204968 <commands+0x818>
ffffffffc02031e4:	0f800593          	li	a1,248
ffffffffc02031e8:	00002517          	auipc	a0,0x2
ffffffffc02031ec:	24850513          	addi	a0,a0,584 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc02031f0:	a6afd0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(mm != NULL);
ffffffffc02031f4:	00002697          	auipc	a3,0x2
ffffffffc02031f8:	43468693          	addi	a3,a3,1076 # ffffffffc0205628 <default_pmm_manager+0x910>
ffffffffc02031fc:	00001617          	auipc	a2,0x1
ffffffffc0203200:	76c60613          	addi	a2,a2,1900 # ffffffffc0204968 <commands+0x818>
ffffffffc0203204:	0d200593          	li	a1,210
ffffffffc0203208:	00002517          	auipc	a0,0x2
ffffffffc020320c:	22850513          	addi	a0,a0,552 # ffffffffc0205430 <default_pmm_manager+0x718>
ffffffffc0203210:	a4afd0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0203214 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203214:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203216:	9402                	jalr	s0

	jal do_exit
ffffffffc0203218:	424000ef          	jal	ra,ffffffffc020363c <do_exit>

ffffffffc020321c <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc020321c:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020321e:	0e800513          	li	a0,232
{
ffffffffc0203222:	e022                	sd	s0,0(sp)
ffffffffc0203224:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203226:	8a1fe0ef          	jal	ra,ffffffffc0201ac6 <kmalloc>
ffffffffc020322a:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc020322c:	c521                	beqz	a0,ffffffffc0203274 <alloc_proc+0x58>
         *       uintptr_t pgdir;                            // the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        
        proc->state = PROC_UNINIT;      // 设置进程状态为未初始化
ffffffffc020322e:	57fd                	li	a5,-1
ffffffffc0203230:	1782                	slli	a5,a5,0x20
ffffffffc0203232:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                 // 运行时间初始化为 0
        proc->kstack = 0;               // 内核栈地址初始化为 0，后续由 setup_kstack 分配
        proc->need_resched = 0;         // 不需要调度
        proc->parent = NULL;            // 父进程为空
        proc->mm = NULL;                // 内存管理结构为空（内核线程通常没有 mm）
        memset(&(proc->context), 0, sizeof(struct context)); // 清空上下文
ffffffffc0203234:	07000613          	li	a2,112
ffffffffc0203238:	4581                	li	a1,0
        proc->runs = 0;                 // 运行时间初始化为 0
ffffffffc020323a:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;               // 内核栈地址初始化为 0，后续由 setup_kstack 分配
ffffffffc020323e:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;         // 不需要调度
ffffffffc0203242:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;            // 父进程为空
ffffffffc0203246:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                // 内存管理结构为空（内核线程通常没有 mm）
ffffffffc020324a:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 清空上下文
ffffffffc020324e:	03050513          	addi	a0,a0,48
ffffffffc0203252:	447000ef          	jal	ra,ffffffffc0203e98 <memset>
        proc->tf = NULL;                // 中断帧指针为空
        proc->pgdir = boot_pgdir_pa;    // 页目录表基址设为内核页目录表（重要：proc_init 检查要求）
ffffffffc0203256:	0000a797          	auipc	a5,0xa
ffffffffc020325a:	24a7b783          	ld	a5,586(a5) # ffffffffc020d4a0 <boot_pgdir_pa>
        proc->tf = NULL;                // 中断帧指针为空
ffffffffc020325e:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;    // 页目录表基址设为内核页目录表（重要：proc_init 检查要求）
ffffffffc0203262:	f45c                	sd	a5,168(s0)
        proc->flags = 0;                // 标志位清零
ffffffffc0203264:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN + 1); // 进程名清空
ffffffffc0203268:	4641                	li	a2,16
ffffffffc020326a:	4581                	li	a1,0
ffffffffc020326c:	0b440513          	addi	a0,s0,180
ffffffffc0203270:	429000ef          	jal	ra,ffffffffc0203e98 <memset>
        
    }
    return proc;
}
ffffffffc0203274:	60a2                	ld	ra,8(sp)
ffffffffc0203276:	8522                	mv	a0,s0
ffffffffc0203278:	6402                	ld	s0,0(sp)
ffffffffc020327a:	0141                	addi	sp,sp,16
ffffffffc020327c:	8082                	ret

ffffffffc020327e <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc020327e:	0000a797          	auipc	a5,0xa
ffffffffc0203282:	2527b783          	ld	a5,594(a5) # ffffffffc020d4d0 <current>
ffffffffc0203286:	73c8                	ld	a0,160(a5)
ffffffffc0203288:	b5dfd06f          	j	ffffffffc0200de4 <forkrets>

ffffffffc020328c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc020328c:	7179                	addi	sp,sp,-48
ffffffffc020328e:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0203290:	0000a497          	auipc	s1,0xa
ffffffffc0203294:	1b848493          	addi	s1,s1,440 # ffffffffc020d448 <name.2>
{
ffffffffc0203298:	f022                	sd	s0,32(sp)
ffffffffc020329a:	e84a                	sd	s2,16(sp)
ffffffffc020329c:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020329e:	0000a917          	auipc	s2,0xa
ffffffffc02032a2:	23293903          	ld	s2,562(s2) # ffffffffc020d4d0 <current>
    memset(name, 0, sizeof(name));
ffffffffc02032a6:	4641                	li	a2,16
ffffffffc02032a8:	4581                	li	a1,0
ffffffffc02032aa:	8526                	mv	a0,s1
{
ffffffffc02032ac:	f406                	sd	ra,40(sp)
ffffffffc02032ae:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02032b0:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc02032b4:	3e5000ef          	jal	ra,ffffffffc0203e98 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02032b8:	0b490593          	addi	a1,s2,180
ffffffffc02032bc:	463d                	li	a2,15
ffffffffc02032be:	8526                	mv	a0,s1
ffffffffc02032c0:	3eb000ef          	jal	ra,ffffffffc0203eaa <memcpy>
ffffffffc02032c4:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02032c6:	85ce                	mv	a1,s3
ffffffffc02032c8:	00002517          	auipc	a0,0x2
ffffffffc02032cc:	37050513          	addi	a0,a0,880 # ffffffffc0205638 <default_pmm_manager+0x920>
ffffffffc02032d0:	ec5fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02032d4:	85a2                	mv	a1,s0
ffffffffc02032d6:	00002517          	auipc	a0,0x2
ffffffffc02032da:	38a50513          	addi	a0,a0,906 # ffffffffc0205660 <default_pmm_manager+0x948>
ffffffffc02032de:	eb7fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02032e2:	00002517          	auipc	a0,0x2
ffffffffc02032e6:	38e50513          	addi	a0,a0,910 # ffffffffc0205670 <default_pmm_manager+0x958>
ffffffffc02032ea:	eabfc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc02032ee:	70a2                	ld	ra,40(sp)
ffffffffc02032f0:	7402                	ld	s0,32(sp)
ffffffffc02032f2:	64e2                	ld	s1,24(sp)
ffffffffc02032f4:	6942                	ld	s2,16(sp)
ffffffffc02032f6:	69a2                	ld	s3,8(sp)
ffffffffc02032f8:	4501                	li	a0,0
ffffffffc02032fa:	6145                	addi	sp,sp,48
ffffffffc02032fc:	8082                	ret

ffffffffc02032fe <proc_run>:
{
ffffffffc02032fe:	7179                	addi	sp,sp,-48
ffffffffc0203300:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0203302:	0000a917          	auipc	s2,0xa
ffffffffc0203306:	1ce90913          	addi	s2,s2,462 # ffffffffc020d4d0 <current>
{
ffffffffc020330a:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc020330c:	00093483          	ld	s1,0(s2)
{
ffffffffc0203310:	f406                	sd	ra,40(sp)
ffffffffc0203312:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc0203314:	02a48963          	beq	s1,a0,ffffffffc0203346 <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203318:	100027f3          	csrr	a5,sstatus
ffffffffc020331c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020331e:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203320:	e3a1                	bnez	a5,ffffffffc0203360 <proc_run+0x62>
            lsatp(next->pgdir);
ffffffffc0203322:	755c                	ld	a5,168(a0)
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned int pgdir)
{
  write_csr(satp, SATP32_MODE | (pgdir >> RISCV_PGSHIFT));
ffffffffc0203324:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc0203328:	00a93023          	sd	a0,0(s2)
ffffffffc020332c:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0203330:	8fd9                	or	a5,a5,a4
ffffffffc0203332:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0203336:	03050593          	addi	a1,a0,48
ffffffffc020333a:	03048513          	addi	a0,s1,48
ffffffffc020333e:	584000ef          	jal	ra,ffffffffc02038c2 <switch_to>
    if (flag) {
ffffffffc0203342:	00099863          	bnez	s3,ffffffffc0203352 <proc_run+0x54>
}
ffffffffc0203346:	70a2                	ld	ra,40(sp)
ffffffffc0203348:	7482                	ld	s1,32(sp)
ffffffffc020334a:	6962                	ld	s2,24(sp)
ffffffffc020334c:	69c2                	ld	s3,16(sp)
ffffffffc020334e:	6145                	addi	sp,sp,48
ffffffffc0203350:	8082                	ret
ffffffffc0203352:	70a2                	ld	ra,40(sp)
ffffffffc0203354:	7482                	ld	s1,32(sp)
ffffffffc0203356:	6962                	ld	s2,24(sp)
ffffffffc0203358:	69c2                	ld	s3,16(sp)
ffffffffc020335a:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020335c:	dcefd06f          	j	ffffffffc020092a <intr_enable>
ffffffffc0203360:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203362:	dcefd0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        return 1;
ffffffffc0203366:	6522                	ld	a0,8(sp)
ffffffffc0203368:	4985                	li	s3,1
ffffffffc020336a:	bf65                	j	ffffffffc0203322 <proc_run+0x24>

ffffffffc020336c <do_fork>:
{
ffffffffc020336c:	7179                	addi	sp,sp,-48
ffffffffc020336e:	ec26                	sd	s1,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203370:	0000a497          	auipc	s1,0xa
ffffffffc0203374:	17848493          	addi	s1,s1,376 # ffffffffc020d4e8 <nr_process>
ffffffffc0203378:	4098                	lw	a4,0(s1)
{
ffffffffc020337a:	f406                	sd	ra,40(sp)
ffffffffc020337c:	f022                	sd	s0,32(sp)
ffffffffc020337e:	e84a                	sd	s2,16(sp)
ffffffffc0203380:	e44e                	sd	s3,8(sp)
ffffffffc0203382:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203384:	6785                	lui	a5,0x1
ffffffffc0203386:	22f75063          	bge	a4,a5,ffffffffc02035a6 <do_fork+0x23a>
ffffffffc020338a:	892e                	mv	s2,a1
ffffffffc020338c:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc020338e:	e8fff0ef          	jal	ra,ffffffffc020321c <alloc_proc>
ffffffffc0203392:	89aa                	mv	s3,a0
ffffffffc0203394:	20050e63          	beqz	a0,ffffffffc02035b0 <do_fork+0x244>
    proc->parent = current;
ffffffffc0203398:	0000aa17          	auipc	s4,0xa
ffffffffc020339c:	138a0a13          	addi	s4,s4,312 # ffffffffc020d4d0 <current>
ffffffffc02033a0:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02033a4:	4509                	li	a0,2
    proc->parent = current;
ffffffffc02033a6:	02f9b023          	sd	a5,32(s3)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02033aa:	8fbfe0ef          	jal	ra,ffffffffc0201ca4 <alloc_pages>
    if (page != NULL)
ffffffffc02033ae:	1e050763          	beqz	a0,ffffffffc020359c <do_fork+0x230>
    return page - pages + nbase;
ffffffffc02033b2:	0000a697          	auipc	a3,0xa
ffffffffc02033b6:	1066b683          	ld	a3,262(a3) # ffffffffc020d4b8 <pages>
ffffffffc02033ba:	40d506b3          	sub	a3,a0,a3
ffffffffc02033be:	8699                	srai	a3,a3,0x6
ffffffffc02033c0:	00002517          	auipc	a0,0x2
ffffffffc02033c4:	67053503          	ld	a0,1648(a0) # ffffffffc0205a30 <nbase>
ffffffffc02033c8:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02033ca:	00c69793          	slli	a5,a3,0xc
ffffffffc02033ce:	83b1                	srli	a5,a5,0xc
ffffffffc02033d0:	0000a717          	auipc	a4,0xa
ffffffffc02033d4:	0e073703          	ld	a4,224(a4) # ffffffffc020d4b0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02033d8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02033da:	1ee7fd63          	bgeu	a5,a4,ffffffffc02035d4 <do_fork+0x268>
    assert(current->mm == NULL);
ffffffffc02033de:	000a3783          	ld	a5,0(s4)
ffffffffc02033e2:	0000a717          	auipc	a4,0xa
ffffffffc02033e6:	0e673703          	ld	a4,230(a4) # ffffffffc020d4c8 <va_pa_offset>
ffffffffc02033ea:	96ba                	add	a3,a3,a4
ffffffffc02033ec:	779c                	ld	a5,40(a5)
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02033ee:	00d9b823          	sd	a3,16(s3)
    assert(current->mm == NULL);
ffffffffc02033f2:	1c079163          	bnez	a5,ffffffffc02035b4 <do_fork+0x248>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02033f6:	6789                	lui	a5,0x2
ffffffffc02033f8:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc02033fc:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02033fe:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203400:	0ad9b023          	sd	a3,160(s3)
    *(proc->tf) = *tf;
ffffffffc0203404:	87b6                	mv	a5,a3
ffffffffc0203406:	12040893          	addi	a7,s0,288
ffffffffc020340a:	00063803          	ld	a6,0(a2)
ffffffffc020340e:	6608                	ld	a0,8(a2)
ffffffffc0203410:	6a0c                	ld	a1,16(a2)
ffffffffc0203412:	6e18                	ld	a4,24(a2)
ffffffffc0203414:	0107b023          	sd	a6,0(a5)
ffffffffc0203418:	e788                	sd	a0,8(a5)
ffffffffc020341a:	eb8c                	sd	a1,16(a5)
ffffffffc020341c:	ef98                	sd	a4,24(a5)
ffffffffc020341e:	02060613          	addi	a2,a2,32
ffffffffc0203422:	02078793          	addi	a5,a5,32
ffffffffc0203426:	ff1612e3          	bne	a2,a7,ffffffffc020340a <do_fork+0x9e>
    proc->tf->gpr.a0 = 0;
ffffffffc020342a:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020342e:	12090563          	beqz	s2,ffffffffc0203558 <do_fork+0x1ec>
ffffffffc0203432:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203436:	00000797          	auipc	a5,0x0
ffffffffc020343a:	e4878793          	addi	a5,a5,-440 # ffffffffc020327e <forkret>
ffffffffc020343e:	02f9b823          	sd	a5,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203442:	02d9bc23          	sd	a3,56(s3)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203446:	100027f3          	csrr	a5,sstatus
ffffffffc020344a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020344c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020344e:	12079663          	bnez	a5,ffffffffc020357a <do_fork+0x20e>
    if (++last_pid >= MAX_PID)
ffffffffc0203452:	00006817          	auipc	a6,0x6
ffffffffc0203456:	bd680813          	addi	a6,a6,-1066 # ffffffffc0209028 <last_pid.1>
ffffffffc020345a:	00082783          	lw	a5,0(a6)
ffffffffc020345e:	6709                	lui	a4,0x2
ffffffffc0203460:	0017851b          	addiw	a0,a5,1
ffffffffc0203464:	00a82023          	sw	a0,0(a6)
ffffffffc0203468:	08e55163          	bge	a0,a4,ffffffffc02034ea <do_fork+0x17e>
    if (last_pid >= next_safe)
ffffffffc020346c:	00006317          	auipc	t1,0x6
ffffffffc0203470:	bc030313          	addi	t1,t1,-1088 # ffffffffc020902c <next_safe.0>
ffffffffc0203474:	00032783          	lw	a5,0(t1)
ffffffffc0203478:	0000a417          	auipc	s0,0xa
ffffffffc020347c:	fe040413          	addi	s0,s0,-32 # ffffffffc020d458 <proc_list>
ffffffffc0203480:	06f55d63          	bge	a0,a5,ffffffffc02034fa <do_fork+0x18e>
        proc->pid = get_pid();    // 分配唯一的 PID
ffffffffc0203484:	00a9a223          	sw	a0,4(s3)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203488:	45a9                	li	a1,10
ffffffffc020348a:	2501                	sext.w	a0,a0
ffffffffc020348c:	566000ef          	jal	ra,ffffffffc02039f2 <hash32>
ffffffffc0203490:	02051793          	slli	a5,a0,0x20
ffffffffc0203494:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0203498:	00006797          	auipc	a5,0x6
ffffffffc020349c:	fb078793          	addi	a5,a5,-80 # ffffffffc0209448 <hash_list>
ffffffffc02034a0:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02034a2:	6510                	ld	a2,8(a0)
ffffffffc02034a4:	0d898793          	addi	a5,s3,216
ffffffffc02034a8:	6414                	ld	a3,8(s0)
        nr_process++;             // 进程数量加1
ffffffffc02034aa:	4098                	lw	a4,0(s1)
    prev->next = next->prev = elm;
ffffffffc02034ac:	e21c                	sd	a5,0(a2)
ffffffffc02034ae:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc02034b0:	0ec9b023          	sd	a2,224(s3)
        list_add(&proc_list, &(proc->list_link));  // 加入进程链表
ffffffffc02034b4:	0c898793          	addi	a5,s3,200
    elm->prev = prev;
ffffffffc02034b8:	0ca9bc23          	sd	a0,216(s3)
    prev->next = next->prev = elm;
ffffffffc02034bc:	e29c                	sd	a5,0(a3)
        nr_process++;             // 进程数量加1
ffffffffc02034be:	2705                	addiw	a4,a4,1
ffffffffc02034c0:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02034c2:	0cd9b823          	sd	a3,208(s3)
    elm->prev = prev;
ffffffffc02034c6:	0c89b423          	sd	s0,200(s3)
ffffffffc02034ca:	c098                	sw	a4,0(s1)
    if (flag) {
ffffffffc02034cc:	0a091b63          	bnez	s2,ffffffffc0203582 <do_fork+0x216>
    wakeup_proc(proc);
ffffffffc02034d0:	854e                	mv	a0,s3
ffffffffc02034d2:	45a000ef          	jal	ra,ffffffffc020392c <wakeup_proc>
    ret = proc->pid;
ffffffffc02034d6:	0049a503          	lw	a0,4(s3)
}
ffffffffc02034da:	70a2                	ld	ra,40(sp)
ffffffffc02034dc:	7402                	ld	s0,32(sp)
ffffffffc02034de:	64e2                	ld	s1,24(sp)
ffffffffc02034e0:	6942                	ld	s2,16(sp)
ffffffffc02034e2:	69a2                	ld	s3,8(sp)
ffffffffc02034e4:	6a02                	ld	s4,0(sp)
ffffffffc02034e6:	6145                	addi	sp,sp,48
ffffffffc02034e8:	8082                	ret
        last_pid = 1;
ffffffffc02034ea:	4785                	li	a5,1
ffffffffc02034ec:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02034f0:	4505                	li	a0,1
ffffffffc02034f2:	00006317          	auipc	t1,0x6
ffffffffc02034f6:	b3a30313          	addi	t1,t1,-1222 # ffffffffc020902c <next_safe.0>
    return listelm->next;
ffffffffc02034fa:	0000a417          	auipc	s0,0xa
ffffffffc02034fe:	f5e40413          	addi	s0,s0,-162 # ffffffffc020d458 <proc_list>
ffffffffc0203502:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0203506:	6789                	lui	a5,0x2
ffffffffc0203508:	00f32023          	sw	a5,0(t1)
ffffffffc020350c:	86aa                	mv	a3,a0
ffffffffc020350e:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0203510:	6e89                	lui	t4,0x2
ffffffffc0203512:	088e0063          	beq	t3,s0,ffffffffc0203592 <do_fork+0x226>
ffffffffc0203516:	88ae                	mv	a7,a1
ffffffffc0203518:	87f2                	mv	a5,t3
ffffffffc020351a:	6609                	lui	a2,0x2
ffffffffc020351c:	a811                	j	ffffffffc0203530 <do_fork+0x1c4>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020351e:	00e6d663          	bge	a3,a4,ffffffffc020352a <do_fork+0x1be>
ffffffffc0203522:	00c75463          	bge	a4,a2,ffffffffc020352a <do_fork+0x1be>
ffffffffc0203526:	863a                	mv	a2,a4
ffffffffc0203528:	4885                	li	a7,1
ffffffffc020352a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020352c:	00878d63          	beq	a5,s0,ffffffffc0203546 <do_fork+0x1da>
            if (proc->pid == last_pid)
ffffffffc0203530:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc0203534:	fed715e3          	bne	a4,a3,ffffffffc020351e <do_fork+0x1b2>
                if (++last_pid >= next_safe)
ffffffffc0203538:	2685                	addiw	a3,a3,1
ffffffffc020353a:	04c6d763          	bge	a3,a2,ffffffffc0203588 <do_fork+0x21c>
ffffffffc020353e:	679c                	ld	a5,8(a5)
ffffffffc0203540:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0203542:	fe8797e3          	bne	a5,s0,ffffffffc0203530 <do_fork+0x1c4>
ffffffffc0203546:	c581                	beqz	a1,ffffffffc020354e <do_fork+0x1e2>
ffffffffc0203548:	00d82023          	sw	a3,0(a6)
ffffffffc020354c:	8536                	mv	a0,a3
ffffffffc020354e:	f2088be3          	beqz	a7,ffffffffc0203484 <do_fork+0x118>
ffffffffc0203552:	00c32023          	sw	a2,0(t1)
ffffffffc0203556:	b73d                	j	ffffffffc0203484 <do_fork+0x118>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203558:	8936                	mv	s2,a3
ffffffffc020355a:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020355e:	00000797          	auipc	a5,0x0
ffffffffc0203562:	d2078793          	addi	a5,a5,-736 # ffffffffc020327e <forkret>
ffffffffc0203566:	02f9b823          	sd	a5,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020356a:	02d9bc23          	sd	a3,56(s3)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020356e:	100027f3          	csrr	a5,sstatus
ffffffffc0203572:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203574:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203576:	ec078ee3          	beqz	a5,ffffffffc0203452 <do_fork+0xe6>
        intr_disable();
ffffffffc020357a:	bb6fd0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        return 1;
ffffffffc020357e:	4905                	li	s2,1
ffffffffc0203580:	bdc9                	j	ffffffffc0203452 <do_fork+0xe6>
        intr_enable();
ffffffffc0203582:	ba8fd0ef          	jal	ra,ffffffffc020092a <intr_enable>
ffffffffc0203586:	b7a9                	j	ffffffffc02034d0 <do_fork+0x164>
                    if (last_pid >= MAX_PID)
ffffffffc0203588:	01d6c363          	blt	a3,t4,ffffffffc020358e <do_fork+0x222>
                        last_pid = 1;
ffffffffc020358c:	4685                	li	a3,1
                    goto repeat;
ffffffffc020358e:	4585                	li	a1,1
ffffffffc0203590:	b749                	j	ffffffffc0203512 <do_fork+0x1a6>
ffffffffc0203592:	cd81                	beqz	a1,ffffffffc02035aa <do_fork+0x23e>
ffffffffc0203594:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0203598:	8536                	mv	a0,a3
ffffffffc020359a:	b5ed                	j	ffffffffc0203484 <do_fork+0x118>
    kfree(proc);
ffffffffc020359c:	854e                	mv	a0,s3
ffffffffc020359e:	dd8fe0ef          	jal	ra,ffffffffc0201b76 <kfree>
    ret = -E_NO_MEM;
ffffffffc02035a2:	5571                	li	a0,-4
    goto fork_out;
ffffffffc02035a4:	bf1d                	j	ffffffffc02034da <do_fork+0x16e>
    int ret = -E_NO_FREE_PROC;
ffffffffc02035a6:	556d                	li	a0,-5
ffffffffc02035a8:	bf0d                	j	ffffffffc02034da <do_fork+0x16e>
    return last_pid;
ffffffffc02035aa:	00082503          	lw	a0,0(a6)
ffffffffc02035ae:	bdd9                	j	ffffffffc0203484 <do_fork+0x118>
    ret = -E_NO_MEM;
ffffffffc02035b0:	5571                	li	a0,-4
    return ret;
ffffffffc02035b2:	b725                	j	ffffffffc02034da <do_fork+0x16e>
    assert(current->mm == NULL);
ffffffffc02035b4:	00002697          	auipc	a3,0x2
ffffffffc02035b8:	0dc68693          	addi	a3,a3,220 # ffffffffc0205690 <default_pmm_manager+0x978>
ffffffffc02035bc:	00001617          	auipc	a2,0x1
ffffffffc02035c0:	3ac60613          	addi	a2,a2,940 # ffffffffc0204968 <commands+0x818>
ffffffffc02035c4:	12b00593          	li	a1,299
ffffffffc02035c8:	00002517          	auipc	a0,0x2
ffffffffc02035cc:	0e050513          	addi	a0,a0,224 # ffffffffc02056a8 <default_pmm_manager+0x990>
ffffffffc02035d0:	e8bfc0ef          	jal	ra,ffffffffc020045a <__panic>
ffffffffc02035d4:	00001617          	auipc	a2,0x1
ffffffffc02035d8:	77c60613          	addi	a2,a2,1916 # ffffffffc0204d50 <default_pmm_manager+0x38>
ffffffffc02035dc:	07100593          	li	a1,113
ffffffffc02035e0:	00001517          	auipc	a0,0x1
ffffffffc02035e4:	79850513          	addi	a0,a0,1944 # ffffffffc0204d78 <default_pmm_manager+0x60>
ffffffffc02035e8:	e73fc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc02035ec <kernel_thread>:
{
ffffffffc02035ec:	7129                	addi	sp,sp,-320
ffffffffc02035ee:	fa22                	sd	s0,304(sp)
ffffffffc02035f0:	f626                	sd	s1,296(sp)
ffffffffc02035f2:	f24a                	sd	s2,288(sp)
ffffffffc02035f4:	84ae                	mv	s1,a1
ffffffffc02035f6:	892a                	mv	s2,a0
ffffffffc02035f8:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02035fa:	4581                	li	a1,0
ffffffffc02035fc:	12000613          	li	a2,288
ffffffffc0203600:	850a                	mv	a0,sp
{
ffffffffc0203602:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0203604:	095000ef          	jal	ra,ffffffffc0203e98 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0203608:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020360a:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020360c:	100027f3          	csrr	a5,sstatus
ffffffffc0203610:	edd7f793          	andi	a5,a5,-291
ffffffffc0203614:	1207e793          	ori	a5,a5,288
ffffffffc0203618:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020361a:	860a                	mv	a2,sp
ffffffffc020361c:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0203620:	00000797          	auipc	a5,0x0
ffffffffc0203624:	bf478793          	addi	a5,a5,-1036 # ffffffffc0203214 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0203628:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020362a:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020362c:	d41ff0ef          	jal	ra,ffffffffc020336c <do_fork>
}
ffffffffc0203630:	70f2                	ld	ra,312(sp)
ffffffffc0203632:	7452                	ld	s0,304(sp)
ffffffffc0203634:	74b2                	ld	s1,296(sp)
ffffffffc0203636:	7912                	ld	s2,288(sp)
ffffffffc0203638:	6131                	addi	sp,sp,320
ffffffffc020363a:	8082                	ret

ffffffffc020363c <do_exit>:
{
ffffffffc020363c:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc020363e:	00002617          	auipc	a2,0x2
ffffffffc0203642:	08260613          	addi	a2,a2,130 # ffffffffc02056c0 <default_pmm_manager+0x9a8>
ffffffffc0203646:	19e00593          	li	a1,414
ffffffffc020364a:	00002517          	auipc	a0,0x2
ffffffffc020364e:	05e50513          	addi	a0,a0,94 # ffffffffc02056a8 <default_pmm_manager+0x990>
{
ffffffffc0203652:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0203654:	e07fc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc0203658 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0203658:	7179                	addi	sp,sp,-48
ffffffffc020365a:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc020365c:	0000a797          	auipc	a5,0xa
ffffffffc0203660:	dfc78793          	addi	a5,a5,-516 # ffffffffc020d458 <proc_list>
ffffffffc0203664:	f406                	sd	ra,40(sp)
ffffffffc0203666:	f022                	sd	s0,32(sp)
ffffffffc0203668:	e84a                	sd	s2,16(sp)
ffffffffc020366a:	e44e                	sd	s3,8(sp)
ffffffffc020366c:	00006497          	auipc	s1,0x6
ffffffffc0203670:	ddc48493          	addi	s1,s1,-548 # ffffffffc0209448 <hash_list>
ffffffffc0203674:	e79c                	sd	a5,8(a5)
ffffffffc0203676:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0203678:	0000a717          	auipc	a4,0xa
ffffffffc020367c:	dd070713          	addi	a4,a4,-560 # ffffffffc020d448 <name.2>
ffffffffc0203680:	87a6                	mv	a5,s1
ffffffffc0203682:	e79c                	sd	a5,8(a5)
ffffffffc0203684:	e39c                	sd	a5,0(a5)
ffffffffc0203686:	07c1                	addi	a5,a5,16
ffffffffc0203688:	fef71de3          	bne	a4,a5,ffffffffc0203682 <proc_init+0x2a>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc020368c:	b91ff0ef          	jal	ra,ffffffffc020321c <alloc_proc>
ffffffffc0203690:	0000a917          	auipc	s2,0xa
ffffffffc0203694:	e4890913          	addi	s2,s2,-440 # ffffffffc020d4d8 <idleproc>
ffffffffc0203698:	00a93023          	sd	a0,0(s2)
ffffffffc020369c:	18050d63          	beqz	a0,ffffffffc0203836 <proc_init+0x1de>
    {
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc02036a0:	07000513          	li	a0,112
ffffffffc02036a4:	c22fe0ef          	jal	ra,ffffffffc0201ac6 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02036a8:	07000613          	li	a2,112
ffffffffc02036ac:	4581                	li	a1,0
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc02036ae:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02036b0:	7e8000ef          	jal	ra,ffffffffc0203e98 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02036b4:	00093503          	ld	a0,0(s2)
ffffffffc02036b8:	85a2                	mv	a1,s0
ffffffffc02036ba:	07000613          	li	a2,112
ffffffffc02036be:	03050513          	addi	a0,a0,48
ffffffffc02036c2:	001000ef          	jal	ra,ffffffffc0203ec2 <memcmp>
ffffffffc02036c6:	89aa                	mv	s3,a0

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc02036c8:	453d                	li	a0,15
ffffffffc02036ca:	bfcfe0ef          	jal	ra,ffffffffc0201ac6 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02036ce:	463d                	li	a2,15
ffffffffc02036d0:	4581                	li	a1,0
    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc02036d2:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02036d4:	7c4000ef          	jal	ra,ffffffffc0203e98 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02036d8:	00093503          	ld	a0,0(s2)
ffffffffc02036dc:	463d                	li	a2,15
ffffffffc02036de:	85a2                	mv	a1,s0
ffffffffc02036e0:	0b450513          	addi	a0,a0,180
ffffffffc02036e4:	7de000ef          	jal	ra,ffffffffc0203ec2 <memcmp>

    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
ffffffffc02036e8:	00093783          	ld	a5,0(s2)
ffffffffc02036ec:	0000a717          	auipc	a4,0xa
ffffffffc02036f0:	db473703          	ld	a4,-588(a4) # ffffffffc020d4a0 <boot_pgdir_pa>
ffffffffc02036f4:	77d4                	ld	a3,168(a5)
ffffffffc02036f6:	0ee68463          	beq	a3,a4,ffffffffc02037de <proc_init+0x186>
    {
        cprintf("alloc_proc() correct!\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02036fa:	4709                	li	a4,2
ffffffffc02036fc:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02036fe:	00003717          	auipc	a4,0x3
ffffffffc0203702:	90270713          	addi	a4,a4,-1790 # ffffffffc0206000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203706:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc020370a:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc020370c:	4705                	li	a4,1
ffffffffc020370e:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203710:	4641                	li	a2,16
ffffffffc0203712:	4581                	li	a1,0
ffffffffc0203714:	8522                	mv	a0,s0
ffffffffc0203716:	782000ef          	jal	ra,ffffffffc0203e98 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020371a:	463d                	li	a2,15
ffffffffc020371c:	00002597          	auipc	a1,0x2
ffffffffc0203720:	fec58593          	addi	a1,a1,-20 # ffffffffc0205708 <default_pmm_manager+0x9f0>
ffffffffc0203724:	8522                	mv	a0,s0
ffffffffc0203726:	784000ef          	jal	ra,ffffffffc0203eaa <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc020372a:	0000a717          	auipc	a4,0xa
ffffffffc020372e:	dbe70713          	addi	a4,a4,-578 # ffffffffc020d4e8 <nr_process>
ffffffffc0203732:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0203734:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0203738:	4601                	li	a2,0
    nr_process++;
ffffffffc020373a:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020373c:	00002597          	auipc	a1,0x2
ffffffffc0203740:	fd458593          	addi	a1,a1,-44 # ffffffffc0205710 <default_pmm_manager+0x9f8>
ffffffffc0203744:	00000517          	auipc	a0,0x0
ffffffffc0203748:	b4850513          	addi	a0,a0,-1208 # ffffffffc020328c <init_main>
    nr_process++;
ffffffffc020374c:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020374e:	0000a797          	auipc	a5,0xa
ffffffffc0203752:	d8d7b123          	sd	a3,-638(a5) # ffffffffc020d4d0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0203756:	e97ff0ef          	jal	ra,ffffffffc02035ec <kernel_thread>
ffffffffc020375a:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc020375c:	0ea05963          	blez	a0,ffffffffc020384e <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID)
ffffffffc0203760:	6789                	lui	a5,0x2
ffffffffc0203762:	fff5071b          	addiw	a4,a0,-1
ffffffffc0203766:	17f9                	addi	a5,a5,-2
ffffffffc0203768:	2501                	sext.w	a0,a0
ffffffffc020376a:	02e7e363          	bltu	a5,a4,ffffffffc0203790 <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020376e:	45a9                	li	a1,10
ffffffffc0203770:	282000ef          	jal	ra,ffffffffc02039f2 <hash32>
ffffffffc0203774:	02051793          	slli	a5,a0,0x20
ffffffffc0203778:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020377c:	96a6                	add	a3,a3,s1
ffffffffc020377e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0203780:	a029                	j	ffffffffc020378a <proc_init+0x132>
            if (proc->pid == pid)
ffffffffc0203782:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc0203786:	0a870563          	beq	a4,s0,ffffffffc0203830 <proc_init+0x1d8>
    return listelm->next;
ffffffffc020378a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020378c:	fef69be3          	bne	a3,a5,ffffffffc0203782 <proc_init+0x12a>
    return NULL;
ffffffffc0203790:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203792:	0b478493          	addi	s1,a5,180
ffffffffc0203796:	4641                	li	a2,16
ffffffffc0203798:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020379a:	0000a417          	auipc	s0,0xa
ffffffffc020379e:	d4640413          	addi	s0,s0,-698 # ffffffffc020d4e0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037a2:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02037a4:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037a6:	6f2000ef          	jal	ra,ffffffffc0203e98 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02037aa:	463d                	li	a2,15
ffffffffc02037ac:	00002597          	auipc	a1,0x2
ffffffffc02037b0:	f9458593          	addi	a1,a1,-108 # ffffffffc0205740 <default_pmm_manager+0xa28>
ffffffffc02037b4:	8526                	mv	a0,s1
ffffffffc02037b6:	6f4000ef          	jal	ra,ffffffffc0203eaa <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02037ba:	00093783          	ld	a5,0(s2)
ffffffffc02037be:	c7e1                	beqz	a5,ffffffffc0203886 <proc_init+0x22e>
ffffffffc02037c0:	43dc                	lw	a5,4(a5)
ffffffffc02037c2:	e3f1                	bnez	a5,ffffffffc0203886 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02037c4:	601c                	ld	a5,0(s0)
ffffffffc02037c6:	c3c5                	beqz	a5,ffffffffc0203866 <proc_init+0x20e>
ffffffffc02037c8:	43d8                	lw	a4,4(a5)
ffffffffc02037ca:	4785                	li	a5,1
ffffffffc02037cc:	08f71d63          	bne	a4,a5,ffffffffc0203866 <proc_init+0x20e>
}
ffffffffc02037d0:	70a2                	ld	ra,40(sp)
ffffffffc02037d2:	7402                	ld	s0,32(sp)
ffffffffc02037d4:	64e2                	ld	s1,24(sp)
ffffffffc02037d6:	6942                	ld	s2,16(sp)
ffffffffc02037d8:	69a2                	ld	s3,8(sp)
ffffffffc02037da:	6145                	addi	sp,sp,48
ffffffffc02037dc:	8082                	ret
    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
ffffffffc02037de:	73d8                	ld	a4,160(a5)
ffffffffc02037e0:	ff09                	bnez	a4,ffffffffc02036fa <proc_init+0xa2>
ffffffffc02037e2:	f0099ce3          	bnez	s3,ffffffffc02036fa <proc_init+0xa2>
ffffffffc02037e6:	6394                	ld	a3,0(a5)
ffffffffc02037e8:	577d                	li	a4,-1
ffffffffc02037ea:	1702                	slli	a4,a4,0x20
ffffffffc02037ec:	f0e697e3          	bne	a3,a4,ffffffffc02036fa <proc_init+0xa2>
ffffffffc02037f0:	4798                	lw	a4,8(a5)
ffffffffc02037f2:	f00714e3          	bnez	a4,ffffffffc02036fa <proc_init+0xa2>
ffffffffc02037f6:	6b98                	ld	a4,16(a5)
ffffffffc02037f8:	f00711e3          	bnez	a4,ffffffffc02036fa <proc_init+0xa2>
ffffffffc02037fc:	4f98                	lw	a4,24(a5)
ffffffffc02037fe:	2701                	sext.w	a4,a4
ffffffffc0203800:	ee071de3          	bnez	a4,ffffffffc02036fa <proc_init+0xa2>
ffffffffc0203804:	7398                	ld	a4,32(a5)
ffffffffc0203806:	ee071ae3          	bnez	a4,ffffffffc02036fa <proc_init+0xa2>
ffffffffc020380a:	7798                	ld	a4,40(a5)
ffffffffc020380c:	ee0717e3          	bnez	a4,ffffffffc02036fa <proc_init+0xa2>
ffffffffc0203810:	0b07a703          	lw	a4,176(a5)
ffffffffc0203814:	8d59                	or	a0,a0,a4
ffffffffc0203816:	0005071b          	sext.w	a4,a0
ffffffffc020381a:	ee0710e3          	bnez	a4,ffffffffc02036fa <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc020381e:	00002517          	auipc	a0,0x2
ffffffffc0203822:	ed250513          	addi	a0,a0,-302 # ffffffffc02056f0 <default_pmm_manager+0x9d8>
ffffffffc0203826:	96ffc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    idleproc->pid = 0;
ffffffffc020382a:	00093783          	ld	a5,0(s2)
ffffffffc020382e:	b5f1                	j	ffffffffc02036fa <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0203830:	f2878793          	addi	a5,a5,-216
ffffffffc0203834:	bfb9                	j	ffffffffc0203792 <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc0203836:	00002617          	auipc	a2,0x2
ffffffffc020383a:	ea260613          	addi	a2,a2,-350 # ffffffffc02056d8 <default_pmm_manager+0x9c0>
ffffffffc020383e:	1b900593          	li	a1,441
ffffffffc0203842:	00002517          	auipc	a0,0x2
ffffffffc0203846:	e6650513          	addi	a0,a0,-410 # ffffffffc02056a8 <default_pmm_manager+0x990>
ffffffffc020384a:	c11fc0ef          	jal	ra,ffffffffc020045a <__panic>
        panic("create init_main failed.\n");
ffffffffc020384e:	00002617          	auipc	a2,0x2
ffffffffc0203852:	ed260613          	addi	a2,a2,-302 # ffffffffc0205720 <default_pmm_manager+0xa08>
ffffffffc0203856:	1d600593          	li	a1,470
ffffffffc020385a:	00002517          	auipc	a0,0x2
ffffffffc020385e:	e4e50513          	addi	a0,a0,-434 # ffffffffc02056a8 <default_pmm_manager+0x990>
ffffffffc0203862:	bf9fc0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203866:	00002697          	auipc	a3,0x2
ffffffffc020386a:	f0a68693          	addi	a3,a3,-246 # ffffffffc0205770 <default_pmm_manager+0xa58>
ffffffffc020386e:	00001617          	auipc	a2,0x1
ffffffffc0203872:	0fa60613          	addi	a2,a2,250 # ffffffffc0204968 <commands+0x818>
ffffffffc0203876:	1dd00593          	li	a1,477
ffffffffc020387a:	00002517          	auipc	a0,0x2
ffffffffc020387e:	e2e50513          	addi	a0,a0,-466 # ffffffffc02056a8 <default_pmm_manager+0x990>
ffffffffc0203882:	bd9fc0ef          	jal	ra,ffffffffc020045a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203886:	00002697          	auipc	a3,0x2
ffffffffc020388a:	ec268693          	addi	a3,a3,-318 # ffffffffc0205748 <default_pmm_manager+0xa30>
ffffffffc020388e:	00001617          	auipc	a2,0x1
ffffffffc0203892:	0da60613          	addi	a2,a2,218 # ffffffffc0204968 <commands+0x818>
ffffffffc0203896:	1dc00593          	li	a1,476
ffffffffc020389a:	00002517          	auipc	a0,0x2
ffffffffc020389e:	e0e50513          	addi	a0,a0,-498 # ffffffffc02056a8 <default_pmm_manager+0x990>
ffffffffc02038a2:	bb9fc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc02038a6 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc02038a6:	1141                	addi	sp,sp,-16
ffffffffc02038a8:	e022                	sd	s0,0(sp)
ffffffffc02038aa:	e406                	sd	ra,8(sp)
ffffffffc02038ac:	0000a417          	auipc	s0,0xa
ffffffffc02038b0:	c2440413          	addi	s0,s0,-988 # ffffffffc020d4d0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc02038b4:	6018                	ld	a4,0(s0)
ffffffffc02038b6:	4f1c                	lw	a5,24(a4)
ffffffffc02038b8:	2781                	sext.w	a5,a5
ffffffffc02038ba:	dff5                	beqz	a5,ffffffffc02038b6 <cpu_idle+0x10>
        {
            schedule();
ffffffffc02038bc:	0a2000ef          	jal	ra,ffffffffc020395e <schedule>
ffffffffc02038c0:	bfd5                	j	ffffffffc02038b4 <cpu_idle+0xe>

ffffffffc02038c2 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02038c2:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02038c6:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02038ca:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02038cc:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02038ce:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02038d2:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02038d6:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02038da:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02038de:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02038e2:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02038e6:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02038ea:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02038ee:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02038f2:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02038f6:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02038fa:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02038fe:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0203900:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203902:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203906:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020390a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020390e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203912:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203916:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020391a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020391e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203922:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203926:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020392a:	8082                	ret

ffffffffc020392c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020392c:	411c                	lw	a5,0(a0)
ffffffffc020392e:	4705                	li	a4,1
ffffffffc0203930:	37f9                	addiw	a5,a5,-2
ffffffffc0203932:	00f77563          	bgeu	a4,a5,ffffffffc020393c <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0203936:	4789                	li	a5,2
ffffffffc0203938:	c11c                	sw	a5,0(a0)
ffffffffc020393a:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc020393c:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020393e:	00002697          	auipc	a3,0x2
ffffffffc0203942:	e5a68693          	addi	a3,a3,-422 # ffffffffc0205798 <default_pmm_manager+0xa80>
ffffffffc0203946:	00001617          	auipc	a2,0x1
ffffffffc020394a:	02260613          	addi	a2,a2,34 # ffffffffc0204968 <commands+0x818>
ffffffffc020394e:	45a5                	li	a1,9
ffffffffc0203950:	00002517          	auipc	a0,0x2
ffffffffc0203954:	e8850513          	addi	a0,a0,-376 # ffffffffc02057d8 <default_pmm_manager+0xac0>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0203958:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020395a:	b01fc0ef          	jal	ra,ffffffffc020045a <__panic>

ffffffffc020395e <schedule>:
}

void
schedule(void) {
ffffffffc020395e:	1141                	addi	sp,sp,-16
ffffffffc0203960:	e406                	sd	ra,8(sp)
ffffffffc0203962:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203964:	100027f3          	csrr	a5,sstatus
ffffffffc0203968:	8b89                	andi	a5,a5,2
ffffffffc020396a:	4401                	li	s0,0
ffffffffc020396c:	efbd                	bnez	a5,ffffffffc02039ea <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020396e:	0000a897          	auipc	a7,0xa
ffffffffc0203972:	b628b883          	ld	a7,-1182(a7) # ffffffffc020d4d0 <current>
ffffffffc0203976:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020397a:	0000a517          	auipc	a0,0xa
ffffffffc020397e:	b5e53503          	ld	a0,-1186(a0) # ffffffffc020d4d8 <idleproc>
ffffffffc0203982:	04a88e63          	beq	a7,a0,ffffffffc02039de <schedule+0x80>
ffffffffc0203986:	0c888693          	addi	a3,a7,200
ffffffffc020398a:	0000a617          	auipc	a2,0xa
ffffffffc020398e:	ace60613          	addi	a2,a2,-1330 # ffffffffc020d458 <proc_list>
        le = last;
ffffffffc0203992:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0203994:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0203996:	4809                	li	a6,2
ffffffffc0203998:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020399a:	00c78863          	beq	a5,a2,ffffffffc02039aa <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020399e:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02039a2:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039a6:	03070163          	beq	a4,a6,ffffffffc02039c8 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02039aa:	fef697e3          	bne	a3,a5,ffffffffc0203998 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02039ae:	ed89                	bnez	a1,ffffffffc02039c8 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02039b0:	451c                	lw	a5,8(a0)
ffffffffc02039b2:	2785                	addiw	a5,a5,1
ffffffffc02039b4:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02039b6:	00a88463          	beq	a7,a0,ffffffffc02039be <schedule+0x60>
            proc_run(next);
ffffffffc02039ba:	945ff0ef          	jal	ra,ffffffffc02032fe <proc_run>
    if (flag) {
ffffffffc02039be:	e819                	bnez	s0,ffffffffc02039d4 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02039c0:	60a2                	ld	ra,8(sp)
ffffffffc02039c2:	6402                	ld	s0,0(sp)
ffffffffc02039c4:	0141                	addi	sp,sp,16
ffffffffc02039c6:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02039c8:	4198                	lw	a4,0(a1)
ffffffffc02039ca:	4789                	li	a5,2
ffffffffc02039cc:	fef712e3          	bne	a4,a5,ffffffffc02039b0 <schedule+0x52>
ffffffffc02039d0:	852e                	mv	a0,a1
ffffffffc02039d2:	bff9                	j	ffffffffc02039b0 <schedule+0x52>
}
ffffffffc02039d4:	6402                	ld	s0,0(sp)
ffffffffc02039d6:	60a2                	ld	ra,8(sp)
ffffffffc02039d8:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02039da:	f51fc06f          	j	ffffffffc020092a <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02039de:	0000a617          	auipc	a2,0xa
ffffffffc02039e2:	a7a60613          	addi	a2,a2,-1414 # ffffffffc020d458 <proc_list>
ffffffffc02039e6:	86b2                	mv	a3,a2
ffffffffc02039e8:	b76d                	j	ffffffffc0203992 <schedule+0x34>
        intr_disable();
ffffffffc02039ea:	f47fc0ef          	jal	ra,ffffffffc0200930 <intr_disable>
        return 1;
ffffffffc02039ee:	4405                	li	s0,1
ffffffffc02039f0:	bfbd                	j	ffffffffc020396e <schedule+0x10>

ffffffffc02039f2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02039f2:	9e3707b7          	lui	a5,0x9e370
ffffffffc02039f6:	2785                	addiw	a5,a5,1
ffffffffc02039f8:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02039fc:	02000793          	li	a5,32
ffffffffc0203a00:	9f8d                	subw	a5,a5,a1
}
ffffffffc0203a02:	00f5553b          	srlw	a0,a0,a5
ffffffffc0203a06:	8082                	ret

ffffffffc0203a08 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203a08:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203a0c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203a0e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203a12:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203a14:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203a18:	f022                	sd	s0,32(sp)
ffffffffc0203a1a:	ec26                	sd	s1,24(sp)
ffffffffc0203a1c:	e84a                	sd	s2,16(sp)
ffffffffc0203a1e:	f406                	sd	ra,40(sp)
ffffffffc0203a20:	e44e                	sd	s3,8(sp)
ffffffffc0203a22:	84aa                	mv	s1,a0
ffffffffc0203a24:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203a26:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203a2a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203a2c:	03067e63          	bgeu	a2,a6,ffffffffc0203a68 <printnum+0x60>
ffffffffc0203a30:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203a32:	00805763          	blez	s0,ffffffffc0203a40 <printnum+0x38>
ffffffffc0203a36:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203a38:	85ca                	mv	a1,s2
ffffffffc0203a3a:	854e                	mv	a0,s3
ffffffffc0203a3c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203a3e:	fc65                	bnez	s0,ffffffffc0203a36 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203a40:	1a02                	slli	s4,s4,0x20
ffffffffc0203a42:	00002797          	auipc	a5,0x2
ffffffffc0203a46:	dae78793          	addi	a5,a5,-594 # ffffffffc02057f0 <default_pmm_manager+0xad8>
ffffffffc0203a4a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203a4e:	9a3e                	add	s4,s4,a5
}
ffffffffc0203a50:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203a52:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203a56:	70a2                	ld	ra,40(sp)
ffffffffc0203a58:	69a2                	ld	s3,8(sp)
ffffffffc0203a5a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203a5c:	85ca                	mv	a1,s2
ffffffffc0203a5e:	87a6                	mv	a5,s1
}
ffffffffc0203a60:	6942                	ld	s2,16(sp)
ffffffffc0203a62:	64e2                	ld	s1,24(sp)
ffffffffc0203a64:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203a66:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203a68:	03065633          	divu	a2,a2,a6
ffffffffc0203a6c:	8722                	mv	a4,s0
ffffffffc0203a6e:	f9bff0ef          	jal	ra,ffffffffc0203a08 <printnum>
ffffffffc0203a72:	b7f9                	j	ffffffffc0203a40 <printnum+0x38>

ffffffffc0203a74 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203a74:	7119                	addi	sp,sp,-128
ffffffffc0203a76:	f4a6                	sd	s1,104(sp)
ffffffffc0203a78:	f0ca                	sd	s2,96(sp)
ffffffffc0203a7a:	ecce                	sd	s3,88(sp)
ffffffffc0203a7c:	e8d2                	sd	s4,80(sp)
ffffffffc0203a7e:	e4d6                	sd	s5,72(sp)
ffffffffc0203a80:	e0da                	sd	s6,64(sp)
ffffffffc0203a82:	fc5e                	sd	s7,56(sp)
ffffffffc0203a84:	f06a                	sd	s10,32(sp)
ffffffffc0203a86:	fc86                	sd	ra,120(sp)
ffffffffc0203a88:	f8a2                	sd	s0,112(sp)
ffffffffc0203a8a:	f862                	sd	s8,48(sp)
ffffffffc0203a8c:	f466                	sd	s9,40(sp)
ffffffffc0203a8e:	ec6e                	sd	s11,24(sp)
ffffffffc0203a90:	892a                	mv	s2,a0
ffffffffc0203a92:	84ae                	mv	s1,a1
ffffffffc0203a94:	8d32                	mv	s10,a2
ffffffffc0203a96:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203a98:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203a9c:	5b7d                	li	s6,-1
ffffffffc0203a9e:	00002a97          	auipc	s5,0x2
ffffffffc0203aa2:	d7ea8a93          	addi	s5,s5,-642 # ffffffffc020581c <default_pmm_manager+0xb04>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203aa6:	00002b97          	auipc	s7,0x2
ffffffffc0203aaa:	f52b8b93          	addi	s7,s7,-174 # ffffffffc02059f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203aae:	000d4503          	lbu	a0,0(s10)
ffffffffc0203ab2:	001d0413          	addi	s0,s10,1
ffffffffc0203ab6:	01350a63          	beq	a0,s3,ffffffffc0203aca <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203aba:	c121                	beqz	a0,ffffffffc0203afa <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203abc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203abe:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203ac0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ac2:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203ac6:	ff351ae3          	bne	a0,s3,ffffffffc0203aba <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203aca:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203ace:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203ad2:	4c81                	li	s9,0
ffffffffc0203ad4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203ad6:	5c7d                	li	s8,-1
ffffffffc0203ad8:	5dfd                	li	s11,-1
ffffffffc0203ada:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ade:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ae0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203ae4:	0ff5f593          	zext.b	a1,a1
ffffffffc0203ae8:	00140d13          	addi	s10,s0,1
ffffffffc0203aec:	04b56263          	bltu	a0,a1,ffffffffc0203b30 <vprintfmt+0xbc>
ffffffffc0203af0:	058a                	slli	a1,a1,0x2
ffffffffc0203af2:	95d6                	add	a1,a1,s5
ffffffffc0203af4:	4194                	lw	a3,0(a1)
ffffffffc0203af6:	96d6                	add	a3,a3,s5
ffffffffc0203af8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203afa:	70e6                	ld	ra,120(sp)
ffffffffc0203afc:	7446                	ld	s0,112(sp)
ffffffffc0203afe:	74a6                	ld	s1,104(sp)
ffffffffc0203b00:	7906                	ld	s2,96(sp)
ffffffffc0203b02:	69e6                	ld	s3,88(sp)
ffffffffc0203b04:	6a46                	ld	s4,80(sp)
ffffffffc0203b06:	6aa6                	ld	s5,72(sp)
ffffffffc0203b08:	6b06                	ld	s6,64(sp)
ffffffffc0203b0a:	7be2                	ld	s7,56(sp)
ffffffffc0203b0c:	7c42                	ld	s8,48(sp)
ffffffffc0203b0e:	7ca2                	ld	s9,40(sp)
ffffffffc0203b10:	7d02                	ld	s10,32(sp)
ffffffffc0203b12:	6de2                	ld	s11,24(sp)
ffffffffc0203b14:	6109                	addi	sp,sp,128
ffffffffc0203b16:	8082                	ret
            padc = '0';
ffffffffc0203b18:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203b1a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203b1e:	846a                	mv	s0,s10
ffffffffc0203b20:	00140d13          	addi	s10,s0,1
ffffffffc0203b24:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203b28:	0ff5f593          	zext.b	a1,a1
ffffffffc0203b2c:	fcb572e3          	bgeu	a0,a1,ffffffffc0203af0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203b30:	85a6                	mv	a1,s1
ffffffffc0203b32:	02500513          	li	a0,37
ffffffffc0203b36:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203b38:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203b3c:	8d22                	mv	s10,s0
ffffffffc0203b3e:	f73788e3          	beq	a5,s3,ffffffffc0203aae <vprintfmt+0x3a>
ffffffffc0203b42:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203b46:	1d7d                	addi	s10,s10,-1
ffffffffc0203b48:	ff379de3          	bne	a5,s3,ffffffffc0203b42 <vprintfmt+0xce>
ffffffffc0203b4c:	b78d                	j	ffffffffc0203aae <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203b4e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203b52:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203b56:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203b58:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203b5c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203b60:	02d86463          	bltu	a6,a3,ffffffffc0203b88 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203b64:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203b68:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203b6c:	0186873b          	addw	a4,a3,s8
ffffffffc0203b70:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203b74:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203b76:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203b7a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203b7c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203b80:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203b84:	fed870e3          	bgeu	a6,a3,ffffffffc0203b64 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0203b88:	f40ddce3          	bgez	s11,ffffffffc0203ae0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0203b8c:	8de2                	mv	s11,s8
ffffffffc0203b8e:	5c7d                	li	s8,-1
ffffffffc0203b90:	bf81                	j	ffffffffc0203ae0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0203b92:	fffdc693          	not	a3,s11
ffffffffc0203b96:	96fd                	srai	a3,a3,0x3f
ffffffffc0203b98:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203b9c:	00144603          	lbu	a2,1(s0)
ffffffffc0203ba0:	2d81                	sext.w	s11,s11
ffffffffc0203ba2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ba4:	bf35                	j	ffffffffc0203ae0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0203ba6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203baa:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203bae:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bb0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0203bb2:	bfd9                	j	ffffffffc0203b88 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0203bb4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203bb6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203bba:	01174463          	blt	a4,a7,ffffffffc0203bc2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0203bbe:	1a088e63          	beqz	a7,ffffffffc0203d7a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0203bc2:	000a3603          	ld	a2,0(s4)
ffffffffc0203bc6:	46c1                	li	a3,16
ffffffffc0203bc8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203bca:	2781                	sext.w	a5,a5
ffffffffc0203bcc:	876e                	mv	a4,s11
ffffffffc0203bce:	85a6                	mv	a1,s1
ffffffffc0203bd0:	854a                	mv	a0,s2
ffffffffc0203bd2:	e37ff0ef          	jal	ra,ffffffffc0203a08 <printnum>
            break;
ffffffffc0203bd6:	bde1                	j	ffffffffc0203aae <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0203bd8:	000a2503          	lw	a0,0(s4)
ffffffffc0203bdc:	85a6                	mv	a1,s1
ffffffffc0203bde:	0a21                	addi	s4,s4,8
ffffffffc0203be0:	9902                	jalr	s2
            break;
ffffffffc0203be2:	b5f1                	j	ffffffffc0203aae <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203be4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203be6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203bea:	01174463          	blt	a4,a7,ffffffffc0203bf2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0203bee:	18088163          	beqz	a7,ffffffffc0203d70 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0203bf2:	000a3603          	ld	a2,0(s4)
ffffffffc0203bf6:	46a9                	li	a3,10
ffffffffc0203bf8:	8a2e                	mv	s4,a1
ffffffffc0203bfa:	bfc1                	j	ffffffffc0203bca <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bfc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203c00:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c02:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203c04:	bdf1                	j	ffffffffc0203ae0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0203c06:	85a6                	mv	a1,s1
ffffffffc0203c08:	02500513          	li	a0,37
ffffffffc0203c0c:	9902                	jalr	s2
            break;
ffffffffc0203c0e:	b545                	j	ffffffffc0203aae <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c10:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0203c14:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c16:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203c18:	b5e1                	j	ffffffffc0203ae0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0203c1a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203c1c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203c20:	01174463          	blt	a4,a7,ffffffffc0203c28 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0203c24:	14088163          	beqz	a7,ffffffffc0203d66 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0203c28:	000a3603          	ld	a2,0(s4)
ffffffffc0203c2c:	46a1                	li	a3,8
ffffffffc0203c2e:	8a2e                	mv	s4,a1
ffffffffc0203c30:	bf69                	j	ffffffffc0203bca <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0203c32:	03000513          	li	a0,48
ffffffffc0203c36:	85a6                	mv	a1,s1
ffffffffc0203c38:	e03e                	sd	a5,0(sp)
ffffffffc0203c3a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203c3c:	85a6                	mv	a1,s1
ffffffffc0203c3e:	07800513          	li	a0,120
ffffffffc0203c42:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203c44:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203c46:	6782                	ld	a5,0(sp)
ffffffffc0203c48:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203c4a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0203c4e:	bfb5                	j	ffffffffc0203bca <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203c50:	000a3403          	ld	s0,0(s4)
ffffffffc0203c54:	008a0713          	addi	a4,s4,8
ffffffffc0203c58:	e03a                	sd	a4,0(sp)
ffffffffc0203c5a:	14040263          	beqz	s0,ffffffffc0203d9e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0203c5e:	0fb05763          	blez	s11,ffffffffc0203d4c <vprintfmt+0x2d8>
ffffffffc0203c62:	02d00693          	li	a3,45
ffffffffc0203c66:	0cd79163          	bne	a5,a3,ffffffffc0203d28 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203c6a:	00044783          	lbu	a5,0(s0)
ffffffffc0203c6e:	0007851b          	sext.w	a0,a5
ffffffffc0203c72:	cf85                	beqz	a5,ffffffffc0203caa <vprintfmt+0x236>
ffffffffc0203c74:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203c78:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203c7c:	000c4563          	bltz	s8,ffffffffc0203c86 <vprintfmt+0x212>
ffffffffc0203c80:	3c7d                	addiw	s8,s8,-1
ffffffffc0203c82:	036c0263          	beq	s8,s6,ffffffffc0203ca6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0203c86:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203c88:	0e0c8e63          	beqz	s9,ffffffffc0203d84 <vprintfmt+0x310>
ffffffffc0203c8c:	3781                	addiw	a5,a5,-32
ffffffffc0203c8e:	0ef47b63          	bgeu	s0,a5,ffffffffc0203d84 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0203c92:	03f00513          	li	a0,63
ffffffffc0203c96:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203c98:	000a4783          	lbu	a5,0(s4)
ffffffffc0203c9c:	3dfd                	addiw	s11,s11,-1
ffffffffc0203c9e:	0a05                	addi	s4,s4,1
ffffffffc0203ca0:	0007851b          	sext.w	a0,a5
ffffffffc0203ca4:	ffe1                	bnez	a5,ffffffffc0203c7c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0203ca6:	01b05963          	blez	s11,ffffffffc0203cb8 <vprintfmt+0x244>
ffffffffc0203caa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203cac:	85a6                	mv	a1,s1
ffffffffc0203cae:	02000513          	li	a0,32
ffffffffc0203cb2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203cb4:	fe0d9be3          	bnez	s11,ffffffffc0203caa <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203cb8:	6a02                	ld	s4,0(sp)
ffffffffc0203cba:	bbd5                	j	ffffffffc0203aae <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203cbc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203cbe:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0203cc2:	01174463          	blt	a4,a7,ffffffffc0203cca <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0203cc6:	08088d63          	beqz	a7,ffffffffc0203d60 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0203cca:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203cce:	0a044d63          	bltz	s0,ffffffffc0203d88 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0203cd2:	8622                	mv	a2,s0
ffffffffc0203cd4:	8a66                	mv	s4,s9
ffffffffc0203cd6:	46a9                	li	a3,10
ffffffffc0203cd8:	bdcd                	j	ffffffffc0203bca <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0203cda:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203cde:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203ce0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203ce2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203ce6:	8fb5                	xor	a5,a5,a3
ffffffffc0203ce8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203cec:	02d74163          	blt	a4,a3,ffffffffc0203d0e <vprintfmt+0x29a>
ffffffffc0203cf0:	00369793          	slli	a5,a3,0x3
ffffffffc0203cf4:	97de                	add	a5,a5,s7
ffffffffc0203cf6:	639c                	ld	a5,0(a5)
ffffffffc0203cf8:	cb99                	beqz	a5,ffffffffc0203d0e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203cfa:	86be                	mv	a3,a5
ffffffffc0203cfc:	00000617          	auipc	a2,0x0
ffffffffc0203d00:	21460613          	addi	a2,a2,532 # ffffffffc0203f10 <etext+0x2a>
ffffffffc0203d04:	85a6                	mv	a1,s1
ffffffffc0203d06:	854a                	mv	a0,s2
ffffffffc0203d08:	0ce000ef          	jal	ra,ffffffffc0203dd6 <printfmt>
ffffffffc0203d0c:	b34d                	j	ffffffffc0203aae <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203d0e:	00002617          	auipc	a2,0x2
ffffffffc0203d12:	b0260613          	addi	a2,a2,-1278 # ffffffffc0205810 <default_pmm_manager+0xaf8>
ffffffffc0203d16:	85a6                	mv	a1,s1
ffffffffc0203d18:	854a                	mv	a0,s2
ffffffffc0203d1a:	0bc000ef          	jal	ra,ffffffffc0203dd6 <printfmt>
ffffffffc0203d1e:	bb41                	j	ffffffffc0203aae <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203d20:	00002417          	auipc	s0,0x2
ffffffffc0203d24:	ae840413          	addi	s0,s0,-1304 # ffffffffc0205808 <default_pmm_manager+0xaf0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203d28:	85e2                	mv	a1,s8
ffffffffc0203d2a:	8522                	mv	a0,s0
ffffffffc0203d2c:	e43e                	sd	a5,8(sp)
ffffffffc0203d2e:	0e2000ef          	jal	ra,ffffffffc0203e10 <strnlen>
ffffffffc0203d32:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203d36:	01b05b63          	blez	s11,ffffffffc0203d4c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0203d3a:	67a2                	ld	a5,8(sp)
ffffffffc0203d3c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203d40:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203d42:	85a6                	mv	a1,s1
ffffffffc0203d44:	8552                	mv	a0,s4
ffffffffc0203d46:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203d48:	fe0d9ce3          	bnez	s11,ffffffffc0203d40 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d4c:	00044783          	lbu	a5,0(s0)
ffffffffc0203d50:	00140a13          	addi	s4,s0,1
ffffffffc0203d54:	0007851b          	sext.w	a0,a5
ffffffffc0203d58:	d3a5                	beqz	a5,ffffffffc0203cb8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d5a:	05e00413          	li	s0,94
ffffffffc0203d5e:	bf39                	j	ffffffffc0203c7c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0203d60:	000a2403          	lw	s0,0(s4)
ffffffffc0203d64:	b7ad                	j	ffffffffc0203cce <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0203d66:	000a6603          	lwu	a2,0(s4)
ffffffffc0203d6a:	46a1                	li	a3,8
ffffffffc0203d6c:	8a2e                	mv	s4,a1
ffffffffc0203d6e:	bdb1                	j	ffffffffc0203bca <vprintfmt+0x156>
ffffffffc0203d70:	000a6603          	lwu	a2,0(s4)
ffffffffc0203d74:	46a9                	li	a3,10
ffffffffc0203d76:	8a2e                	mv	s4,a1
ffffffffc0203d78:	bd89                	j	ffffffffc0203bca <vprintfmt+0x156>
ffffffffc0203d7a:	000a6603          	lwu	a2,0(s4)
ffffffffc0203d7e:	46c1                	li	a3,16
ffffffffc0203d80:	8a2e                	mv	s4,a1
ffffffffc0203d82:	b5a1                	j	ffffffffc0203bca <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0203d84:	9902                	jalr	s2
ffffffffc0203d86:	bf09                	j	ffffffffc0203c98 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0203d88:	85a6                	mv	a1,s1
ffffffffc0203d8a:	02d00513          	li	a0,45
ffffffffc0203d8e:	e03e                	sd	a5,0(sp)
ffffffffc0203d90:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203d92:	6782                	ld	a5,0(sp)
ffffffffc0203d94:	8a66                	mv	s4,s9
ffffffffc0203d96:	40800633          	neg	a2,s0
ffffffffc0203d9a:	46a9                	li	a3,10
ffffffffc0203d9c:	b53d                	j	ffffffffc0203bca <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0203d9e:	03b05163          	blez	s11,ffffffffc0203dc0 <vprintfmt+0x34c>
ffffffffc0203da2:	02d00693          	li	a3,45
ffffffffc0203da6:	f6d79de3          	bne	a5,a3,ffffffffc0203d20 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0203daa:	00002417          	auipc	s0,0x2
ffffffffc0203dae:	a5e40413          	addi	s0,s0,-1442 # ffffffffc0205808 <default_pmm_manager+0xaf0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203db2:	02800793          	li	a5,40
ffffffffc0203db6:	02800513          	li	a0,40
ffffffffc0203dba:	00140a13          	addi	s4,s0,1
ffffffffc0203dbe:	bd6d                	j	ffffffffc0203c78 <vprintfmt+0x204>
ffffffffc0203dc0:	00002a17          	auipc	s4,0x2
ffffffffc0203dc4:	a49a0a13          	addi	s4,s4,-1463 # ffffffffc0205809 <default_pmm_manager+0xaf1>
ffffffffc0203dc8:	02800513          	li	a0,40
ffffffffc0203dcc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203dd0:	05e00413          	li	s0,94
ffffffffc0203dd4:	b565                	j	ffffffffc0203c7c <vprintfmt+0x208>

ffffffffc0203dd6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203dd6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203dd8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ddc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203dde:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203de0:	ec06                	sd	ra,24(sp)
ffffffffc0203de2:	f83a                	sd	a4,48(sp)
ffffffffc0203de4:	fc3e                	sd	a5,56(sp)
ffffffffc0203de6:	e0c2                	sd	a6,64(sp)
ffffffffc0203de8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203dea:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203dec:	c89ff0ef          	jal	ra,ffffffffc0203a74 <vprintfmt>
}
ffffffffc0203df0:	60e2                	ld	ra,24(sp)
ffffffffc0203df2:	6161                	addi	sp,sp,80
ffffffffc0203df4:	8082                	ret

ffffffffc0203df6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203df6:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203dfa:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203dfc:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203dfe:	cb81                	beqz	a5,ffffffffc0203e0e <strlen+0x18>
        cnt ++;
ffffffffc0203e00:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203e02:	00a707b3          	add	a5,a4,a0
ffffffffc0203e06:	0007c783          	lbu	a5,0(a5)
ffffffffc0203e0a:	fbfd                	bnez	a5,ffffffffc0203e00 <strlen+0xa>
ffffffffc0203e0c:	8082                	ret
    }
    return cnt;
}
ffffffffc0203e0e:	8082                	ret

ffffffffc0203e10 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203e10:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203e12:	e589                	bnez	a1,ffffffffc0203e1c <strnlen+0xc>
ffffffffc0203e14:	a811                	j	ffffffffc0203e28 <strnlen+0x18>
        cnt ++;
ffffffffc0203e16:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203e18:	00f58863          	beq	a1,a5,ffffffffc0203e28 <strnlen+0x18>
ffffffffc0203e1c:	00f50733          	add	a4,a0,a5
ffffffffc0203e20:	00074703          	lbu	a4,0(a4)
ffffffffc0203e24:	fb6d                	bnez	a4,ffffffffc0203e16 <strnlen+0x6>
ffffffffc0203e26:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203e28:	852e                	mv	a0,a1
ffffffffc0203e2a:	8082                	ret

ffffffffc0203e2c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203e2c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203e2e:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e32:	0785                	addi	a5,a5,1
ffffffffc0203e34:	0585                	addi	a1,a1,1
ffffffffc0203e36:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203e3a:	fb75                	bnez	a4,ffffffffc0203e2e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203e3c:	8082                	ret

ffffffffc0203e3e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e3e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e42:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e46:	cb89                	beqz	a5,ffffffffc0203e58 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203e48:	0505                	addi	a0,a0,1
ffffffffc0203e4a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e4c:	fee789e3          	beq	a5,a4,ffffffffc0203e3e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e50:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203e54:	9d19                	subw	a0,a0,a4
ffffffffc0203e56:	8082                	ret
ffffffffc0203e58:	4501                	li	a0,0
ffffffffc0203e5a:	bfed                	j	ffffffffc0203e54 <strcmp+0x16>

ffffffffc0203e5c <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203e5c:	c20d                	beqz	a2,ffffffffc0203e7e <strncmp+0x22>
ffffffffc0203e5e:	962e                	add	a2,a2,a1
ffffffffc0203e60:	a031                	j	ffffffffc0203e6c <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0203e62:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203e64:	00e79a63          	bne	a5,a4,ffffffffc0203e78 <strncmp+0x1c>
ffffffffc0203e68:	00b60b63          	beq	a2,a1,ffffffffc0203e7e <strncmp+0x22>
ffffffffc0203e6c:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0203e70:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203e72:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e76:	f7f5                	bnez	a5,ffffffffc0203e62 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e78:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0203e7c:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e7e:	4501                	li	a0,0
ffffffffc0203e80:	8082                	ret

ffffffffc0203e82 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203e82:	00054783          	lbu	a5,0(a0)
ffffffffc0203e86:	c799                	beqz	a5,ffffffffc0203e94 <strchr+0x12>
        if (*s == c) {
ffffffffc0203e88:	00f58763          	beq	a1,a5,ffffffffc0203e96 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203e8c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203e90:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203e92:	fbfd                	bnez	a5,ffffffffc0203e88 <strchr+0x6>
    }
    return NULL;
ffffffffc0203e94:	4501                	li	a0,0
}
ffffffffc0203e96:	8082                	ret

ffffffffc0203e98 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203e98:	ca01                	beqz	a2,ffffffffc0203ea8 <memset+0x10>
ffffffffc0203e9a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203e9c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203e9e:	0785                	addi	a5,a5,1
ffffffffc0203ea0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203ea4:	fec79de3          	bne	a5,a2,ffffffffc0203e9e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203ea8:	8082                	ret

ffffffffc0203eaa <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203eaa:	ca19                	beqz	a2,ffffffffc0203ec0 <memcpy+0x16>
ffffffffc0203eac:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203eae:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203eb0:	0005c703          	lbu	a4,0(a1)
ffffffffc0203eb4:	0585                	addi	a1,a1,1
ffffffffc0203eb6:	0785                	addi	a5,a5,1
ffffffffc0203eb8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203ebc:	fec59ae3          	bne	a1,a2,ffffffffc0203eb0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203ec0:	8082                	ret

ffffffffc0203ec2 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0203ec2:	c205                	beqz	a2,ffffffffc0203ee2 <memcmp+0x20>
ffffffffc0203ec4:	962e                	add	a2,a2,a1
ffffffffc0203ec6:	a019                	j	ffffffffc0203ecc <memcmp+0xa>
ffffffffc0203ec8:	00c58d63          	beq	a1,a2,ffffffffc0203ee2 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0203ecc:	00054783          	lbu	a5,0(a0)
ffffffffc0203ed0:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0203ed4:	0505                	addi	a0,a0,1
ffffffffc0203ed6:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0203ed8:	fee788e3          	beq	a5,a4,ffffffffc0203ec8 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203edc:	40e7853b          	subw	a0,a5,a4
ffffffffc0203ee0:	8082                	ret
    }
    return 0;
ffffffffc0203ee2:	4501                	li	a0,0
}
ffffffffc0203ee4:	8082                	ret
