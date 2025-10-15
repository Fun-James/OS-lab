
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00005297          	auipc	t0,0x5
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0205000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00005297          	auipc	t0,0x5
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0205008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02042b7          	lui	t0,0xc0204
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
ffffffffc020003c:	c0204137          	lui	sp,0xc0204

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	ffc50513          	addi	a0,a0,-4 # ffffffffc0201048 <etext>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	00650513          	addi	a0,a0,6 # ffffffffc0201068 <etext+0x20>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	fda58593          	addi	a1,a1,-38 # ffffffffc0201048 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	01250513          	addi	a0,a0,18 # ffffffffc0201088 <etext+0x40>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00005597          	auipc	a1,0x5
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0205018 <free_area>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	01e50513          	addi	a0,a0,30 # ffffffffc02010a8 <etext+0x60>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00005597          	auipc	a1,0x5
ffffffffc020009a:	13a58593          	addi	a1,a1,314 # ffffffffc02051d0 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	02a50513          	addi	a0,a0,42 # ffffffffc02010c8 <etext+0x80>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00005597          	auipc	a1,0x5
ffffffffc02000ae:	52558593          	addi	a1,a1,1317 # ffffffffc02055cf <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00001517          	auipc	a0,0x1
ffffffffc02000d0:	01c50513          	addi	a0,a0,28 # ffffffffc02010e8 <etext+0xa0>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00005517          	auipc	a0,0x5
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0205018 <free_area>
ffffffffc02000e0:	00005617          	auipc	a2,0x5
ffffffffc02000e4:	0f060613          	addi	a2,a2,240 # ffffffffc02051d0 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	747000ef          	jal	ra,ffffffffc0201036 <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	01c50513          	addi	a0,a0,28 # ffffffffc0201118 <etext+0xd0>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	0d1000ef          	jal	ra,ffffffffc02009dc <pmm_init>

    /* do nothing */
    while (1)
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    (*cnt) ++;
ffffffffc020011e:	401c                	lw	a5,0(s0)
}
ffffffffc0200120:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
}
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200140:	2e1000ef          	jal	ra,ffffffffc0200c20 <vprintfmt>
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200172:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200174:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	2ab000ef          	jal	ra,ffffffffc0200c20 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c2:	00005317          	auipc	t1,0x5
ffffffffc02001c6:	fbe30313          	addi	t1,t1,-66 # ffffffffc0205180 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
    is_panic = 1;
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
    va_start(ap, fmt);
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	f4650513          	addi	a0,a0,-186 # ffffffffc0201138 <etext+0xf0>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00001517          	auipc	a0,0x1
ffffffffc020020c:	f0850513          	addi	a0,a0,-248 # ffffffffc0201110 <etext+0xc8>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	5870006f          	j	ffffffffc0200fa2 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00001517          	auipc	a0,0x1
ffffffffc0200226:	f3650513          	addi	a0,a0,-202 # ffffffffc0201158 <etext+0x110>
void dtb_init(void) {
ffffffffc020022a:	fc86                	sd	ra,120(sp)
ffffffffc020022c:	f8a2                	sd	s0,112(sp)
ffffffffc020022e:	e8d2                	sd	s4,80(sp)
ffffffffc0200230:	f4a6                	sd	s1,104(sp)
ffffffffc0200232:	f0ca                	sd	s2,96(sp)
ffffffffc0200234:	ecce                	sd	s3,88(sp)
ffffffffc0200236:	e4d6                	sd	s5,72(sp)
ffffffffc0200238:	e0da                	sd	s6,64(sp)
ffffffffc020023a:	fc5e                	sd	s7,56(sp)
ffffffffc020023c:	f862                	sd	s8,48(sp)
ffffffffc020023e:	f466                	sd	s9,40(sp)
ffffffffc0200240:	f06a                	sd	s10,32(sp)
ffffffffc0200242:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200248:	00005597          	auipc	a1,0x5
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0205000 <boot_hartid>
ffffffffc0200250:	00001517          	auipc	a0,0x1
ffffffffc0200254:	f1850513          	addi	a0,a0,-232 # ffffffffc0201168 <etext+0x120>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00005417          	auipc	s0,0x5
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0205008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	f1250513          	addi	a0,a0,-238 # ffffffffc0201178 <etext+0x130>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00001517          	auipc	a0,0x1
ffffffffc020027a:	f1a50513          	addi	a0,a0,-230 # ffffffffc0201190 <etext+0x148>
    if (boot_dtb == 0) {
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020028a:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200290:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a6:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002bc:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfedad1d>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02002ca:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f4:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200302:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020031c:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200320:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200326:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200328:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020032e:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200330:	00001917          	auipc	s2,0x1
ffffffffc0200334:	eb090913          	addi	s2,s2,-336 # ffffffffc02011e0 <etext+0x198>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00001497          	auipc	s1,0x1
ffffffffc0200342:	e9a48493          	addi	s1,s1,-358 # ffffffffc02011d8 <etext+0x190>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200392:	00001517          	auipc	a0,0x1
ffffffffc0200396:	ec650513          	addi	a0,a0,-314 # ffffffffc0201258 <etext+0x210>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	ef250513          	addi	a0,a0,-270 # ffffffffc0201290 <etext+0x248>
}
ffffffffc02003a6:	7446                	ld	s0,112(sp)
ffffffffc02003a8:	70e6                	ld	ra,120(sp)
ffffffffc02003aa:	74a6                	ld	s1,104(sp)
ffffffffc02003ac:	7906                	ld	s2,96(sp)
ffffffffc02003ae:	69e6                	ld	s3,88(sp)
ffffffffc02003b0:	6a46                	ld	s4,80(sp)
ffffffffc02003b2:	6aa6                	ld	s5,72(sp)
ffffffffc02003b4:	6b06                	ld	s6,64(sp)
ffffffffc02003b6:	7be2                	ld	s7,56(sp)
ffffffffc02003b8:	7c42                	ld	s8,48(sp)
ffffffffc02003ba:	7ca2                	ld	s9,40(sp)
ffffffffc02003bc:	7d02                	ld	s10,32(sp)
ffffffffc02003be:	6de2                	ld	s11,24(sp)
ffffffffc02003c0:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
}
ffffffffc02003c4:	7446                	ld	s0,112(sp)
ffffffffc02003c6:	70e6                	ld	ra,120(sp)
ffffffffc02003c8:	74a6                	ld	s1,104(sp)
ffffffffc02003ca:	7906                	ld	s2,96(sp)
ffffffffc02003cc:	69e6                	ld	s3,88(sp)
ffffffffc02003ce:	6a46                	ld	s4,80(sp)
ffffffffc02003d0:	6aa6                	ld	s5,72(sp)
ffffffffc02003d2:	6b06                	ld	s6,64(sp)
ffffffffc02003d4:	7be2                	ld	s7,56(sp)
ffffffffc02003d6:	7c42                	ld	s8,48(sp)
ffffffffc02003d8:	7ca2                	ld	s9,40(sp)
ffffffffc02003da:	7d02                	ld	s10,32(sp)
ffffffffc02003dc:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	dd250513          	addi	a0,a0,-558 # ffffffffc02011b0 <etext+0x168>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	3d1000ef          	jal	ra,ffffffffc0200fbc <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	417000ef          	jal	ra,ffffffffc0201010 <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200400:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020042e:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047a:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	363000ef          	jal	ra,ffffffffc0200ff2 <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	d4450513          	addi	a0,a0,-700 # ffffffffc02011e8 <etext+0x1a0>
           fdt32_to_cpu(x >> 32);
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e8:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052e:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200532:	011b78b3          	and	a7,s6,a7
ffffffffc0200536:	005eeeb3          	or	t4,t4,t0
ffffffffc020053a:	00c6e733          	or	a4,a3,a2
ffffffffc020053e:	006c6c33          	or	s8,s8,t1
ffffffffc0200542:	010b76b3          	and	a3,s6,a6
ffffffffc0200546:	00bb7b33          	and	s6,s6,a1
ffffffffc020054a:	01d7e7b3          	or	a5,a5,t4
ffffffffc020054e:	016c6b33          	or	s6,s8,s6
ffffffffc0200552:	01146433          	or	s0,s0,a7
ffffffffc0200556:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020055c:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020055e:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200560:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00001517          	auipc	a0,0x1
ffffffffc0200576:	c9650513          	addi	a0,a0,-874 # ffffffffc0201208 <etext+0x1c0>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	c9c50513          	addi	a0,a0,-868 # ffffffffc0201220 <etext+0x1d8>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	caa50513          	addi	a0,a0,-854 # ffffffffc0201240 <etext+0x1f8>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	cee50513          	addi	a0,a0,-786 # ffffffffc0201290 <etext+0x248>
        memory_base = mem_base;
ffffffffc02005aa:	00005797          	auipc	a5,0x5
ffffffffc02005ae:	bc87bf23          	sd	s0,-1058(a5) # ffffffffc0205188 <memory_base>
        memory_size = mem_size;
ffffffffc02005b2:	00005797          	auipc	a5,0x5
ffffffffc02005b6:	bd67bf23          	sd	s6,-1058(a5) # ffffffffc0205190 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005bc:	00005517          	auipc	a0,0x5
ffffffffc02005c0:	bcc53503          	ld	a0,-1076(a0) # ffffffffc0205188 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005c6:	00005517          	auipc	a0,0x5
ffffffffc02005ca:	bca53503          	ld	a0,-1078(a0) # ffffffffc0205190 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <buddy_init>:
    return order;
}

// 初始化伙伴系统
static void buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc02005d0:	00005797          	auipc	a5,0x5
ffffffffc02005d4:	a4878793          	addi	a5,a5,-1464 # ffffffffc0205018 <free_area>
ffffffffc02005d8:	00005717          	auipc	a4,0x5
ffffffffc02005dc:	ba870713          	addi	a4,a4,-1112 # ffffffffc0205180 <is_panic>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02005e0:	e79c                	sd	a5,8(a5)
ffffffffc02005e2:	e39c                	sd	a5,0(a5)
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
ffffffffc02005e4:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc02005e8:	07e1                	addi	a5,a5,24
ffffffffc02005ea:	fee79be3          	bne	a5,a4,ffffffffc02005e0 <buddy_init+0x10>
    }
    nr_free = 0;
ffffffffc02005ee:	00005797          	auipc	a5,0x5
ffffffffc02005f2:	ba07b523          	sd	zero,-1110(a5) # ffffffffc0205198 <nr_free>
}
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <buddy_alloc_pages>:
    }
}

// 分配页面
static struct Page *buddy_alloc_pages(size_t n) {
    if (n == 0) return NULL;
ffffffffc02005f8:	cd61                	beqz	a0,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
    if (n > nr_free) return NULL;
ffffffffc02005fa:	00005f17          	auipc	t5,0x5
ffffffffc02005fe:	b9ef0f13          	addi	t5,t5,-1122 # ffffffffc0205198 <nr_free>
ffffffffc0200602:	000f3e83          	ld	t4,0(t5)
ffffffffc0200606:	0caee563          	bltu	t4,a0,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
    while ((1 << order) < n) {
ffffffffc020060a:	4785                	li	a5,1
ffffffffc020060c:	0cf50463          	beq	a0,a5,ffffffffc02006d4 <buddy_alloc_pages+0xdc>
    uint32_t order = 0;
ffffffffc0200610:	4601                	li	a2,0
        order++;
ffffffffc0200612:	2605                	addiw	a2,a2,1
    while ((1 << order) < n) {
ffffffffc0200614:	00c79e3b          	sllw	t3,a5,a2
ffffffffc0200618:	feae6de3          	bltu	t3,a0,ffffffffc0200612 <buddy_alloc_pages+0x1a>
    // 计算所需最小阶数
    uint32_t order = get_order(n);
    uint32_t current_order;

    // 从所需阶数开始，向上查找可用的更大块
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc020061c:	47b9                	li	a5,14
ffffffffc020061e:	0ac7ee63          	bltu	a5,a2,ffffffffc02006da <buddy_alloc_pages+0xe2>
    uint32_t order = 0;
ffffffffc0200622:	87b2                	mv	a5,a2
ffffffffc0200624:	00005697          	auipc	a3,0x5
ffffffffc0200628:	9f468693          	addi	a3,a3,-1548 # ffffffffc0205018 <free_area>
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc020062c:	453d                	li	a0,15
ffffffffc020062e:	a021                	j	ffffffffc0200636 <buddy_alloc_pages+0x3e>
ffffffffc0200630:	2785                	addiw	a5,a5,1
ffffffffc0200632:	08a78f63          	beq	a5,a0,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200636:	02079593          	slli	a1,a5,0x20
ffffffffc020063a:	9181                	srli	a1,a1,0x20
ffffffffc020063c:	00159713          	slli	a4,a1,0x1
ffffffffc0200640:	972e                	add	a4,a4,a1
ffffffffc0200642:	070e                	slli	a4,a4,0x3
ffffffffc0200644:	9736                	add	a4,a4,a3
ffffffffc0200646:	00873803          	ld	a6,8(a4)
        if (!list_empty(&(free_area[current_order].free_list))) {
ffffffffc020064a:	fee803e3          	beq	a6,a4,ffffffffc0200630 <buddy_alloc_pages+0x38>
    __list_del(listelm->prev, listelm->next);
ffffffffc020064e:	00083303          	ld	t1,0(a6)
ffffffffc0200652:	00883883          	ld	a7,8(a6)

    // 从找到的空闲链表中取出一个块
    list_entry_t *le = list_next(&(free_area[current_order].free_list));
    struct Page *page = le2page(le, page_link);
    list_del(le);
    free_area[current_order].nr_free--;
ffffffffc0200656:	4b0c                	lw	a1,16(a4)
    struct Page *page = le2page(le, page_link);
ffffffffc0200658:	fe880513          	addi	a0,a6,-24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020065c:	01133423          	sd	a7,8(t1)
    next->prev = prev;
ffffffffc0200660:	0068b023          	sd	t1,0(a7)
    free_area[current_order].nr_free--;
ffffffffc0200664:	35fd                	addiw	a1,a1,-1
ffffffffc0200666:	cb0c                	sw	a1,16(a4)

    // 如果找到的块比需要的大，则进行切分
    while (current_order > order) {
ffffffffc0200668:	04f67863          	bgeu	a2,a5,ffffffffc02006b8 <buddy_alloc_pages+0xc0>
ffffffffc020066c:	37fd                	addiw	a5,a5,-1
ffffffffc020066e:	02079593          	slli	a1,a5,0x20
ffffffffc0200672:	9181                	srli	a1,a1,0x20
ffffffffc0200674:	00159713          	slli	a4,a1,0x1
ffffffffc0200678:	972e                	add	a4,a4,a1
ffffffffc020067a:	070e                	slli	a4,a4,0x3
ffffffffc020067c:	96ba                	add	a3,a3,a4
        current_order--;
        // 切分后的另一半（伙伴）
        struct Page *buddy = page + (1 << current_order);
ffffffffc020067e:	4f85                	li	t6,1
ffffffffc0200680:	a011                	j	ffffffffc0200684 <buddy_alloc_pages+0x8c>
ffffffffc0200682:	37fd                	addiw	a5,a5,-1
ffffffffc0200684:	00ff95bb          	sllw	a1,t6,a5
ffffffffc0200688:	00259713          	slli	a4,a1,0x2
ffffffffc020068c:	972e                	add	a4,a4,a1
ffffffffc020068e:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm, listelm->next);
ffffffffc0200690:	0086b883          	ld	a7,8(a3)
ffffffffc0200694:	972a                	add	a4,a4,a0
        buddy->property = current_order; // 记录伙伴的阶数
ffffffffc0200696:	cb1c                	sw	a5,16(a4)
        list_add(&(free_area[current_order].free_list), &(buddy->page_link));
        free_area[current_order].nr_free++;
ffffffffc0200698:	4a8c                	lw	a1,16(a3)
        list_add(&(free_area[current_order].free_list), &(buddy->page_link));
ffffffffc020069a:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc020069e:	0068b023          	sd	t1,0(a7)
ffffffffc02006a2:	0066b423          	sd	t1,8(a3)
    elm->prev = prev;
ffffffffc02006a6:	ef14                	sd	a3,24(a4)
    elm->next = next;
ffffffffc02006a8:	03173023          	sd	a7,32(a4)
        free_area[current_order].nr_free++;
ffffffffc02006ac:	0015871b          	addiw	a4,a1,1
ffffffffc02006b0:	ca98                	sw	a4,16(a3)
    while (current_order > order) {
ffffffffc02006b2:	16a1                	addi	a3,a3,-24
ffffffffc02006b4:	fcf617e3          	bne	a2,a5,ffffffffc0200682 <buddy_alloc_pages+0x8a>
    }

    // 标记分配出去的块为非空闲，并记录其阶数
    ClearPageProperty(page); 
ffffffffc02006b8:	ff083783          	ld	a5,-16(a6)
    page->property = order;
    nr_free -= (1 << order);
ffffffffc02006bc:	41ce8e33          	sub	t3,t4,t3
    page->property = order;
ffffffffc02006c0:	fec82c23          	sw	a2,-8(a6)
    ClearPageProperty(page); 
ffffffffc02006c4:	9bf5                	andi	a5,a5,-3
ffffffffc02006c6:	fef83823          	sd	a5,-16(a6)
    nr_free -= (1 << order);
ffffffffc02006ca:	01cf3023          	sd	t3,0(t5)
    
    return page;
ffffffffc02006ce:	8082                	ret
    if (n == 0) return NULL;
ffffffffc02006d0:	4501                	li	a0,0
}
ffffffffc02006d2:	8082                	ret
    while ((1 << order) < n) {
ffffffffc02006d4:	4e05                	li	t3,1
    uint32_t order = 0;
ffffffffc02006d6:	4601                	li	a2,0
ffffffffc02006d8:	b7a9                	j	ffffffffc0200622 <buddy_alloc_pages+0x2a>
    if (current_order == MAX_ORDER) { // 没找到
ffffffffc02006da:	47bd                	li	a5,15
ffffffffc02006dc:	fef60ae3          	beq	a2,a5,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
    return listelm->next;
ffffffffc02006e0:	02061713          	slli	a4,a2,0x20
ffffffffc02006e4:	9301                	srli	a4,a4,0x20
ffffffffc02006e6:	00171793          	slli	a5,a4,0x1
ffffffffc02006ea:	97ba                	add	a5,a5,a4
ffffffffc02006ec:	00379713          	slli	a4,a5,0x3
ffffffffc02006f0:	00005797          	auipc	a5,0x5
ffffffffc02006f4:	92878793          	addi	a5,a5,-1752 # ffffffffc0205018 <free_area>
ffffffffc02006f8:	97ba                	add	a5,a5,a4
ffffffffc02006fa:	0087b803          	ld	a6,8(a5)
    free_area[current_order].nr_free--;
ffffffffc02006fe:	4b98                	lw	a4,16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200700:	00083583          	ld	a1,0(a6)
ffffffffc0200704:	00883683          	ld	a3,8(a6)
ffffffffc0200708:	377d                	addiw	a4,a4,-1
    struct Page *page = le2page(le, page_link);
ffffffffc020070a:	fe880513          	addi	a0,a6,-24
    prev->next = next;
ffffffffc020070e:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc0200710:	e28c                	sd	a1,0(a3)
    free_area[current_order].nr_free--;
ffffffffc0200712:	cb98                	sw	a4,16(a5)
    while (current_order > order) {
ffffffffc0200714:	b755                	j	ffffffffc02006b8 <buddy_alloc_pages+0xc0>

ffffffffc0200716 <buddy_nr_free_pages>:
    nr_free += (1 << order);
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	a8253503          	ld	a0,-1406(a0) # ffffffffc0205198 <nr_free>
ffffffffc020071e:	8082                	ret

ffffffffc0200720 <buddy_check>:

// 检查函数，用于测试
static void buddy_check(void) {
    // 省略具体检查代码，可根据需要添加
}
ffffffffc0200720:	8082                	ret

ffffffffc0200722 <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200722:	1141                	addi	sp,sp,-16
ffffffffc0200724:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200726:	18058163          	beqz	a1,ffffffffc02008a8 <buddy_free_pages+0x186>
    while ((1 << order) < n) {
ffffffffc020072a:	4705                	li	a4,1
    uint32_t order = 0;
ffffffffc020072c:	4681                	li	a3,0
    while ((1 << order) < n) {
ffffffffc020072e:	4785                	li	a5,1
ffffffffc0200730:	12e58d63          	beq	a1,a4,ffffffffc020086a <buddy_free_pages+0x148>
        order++;
ffffffffc0200734:	2685                	addiw	a3,a3,1
    while ((1 << order) < n) {
ffffffffc0200736:	00d7983b          	sllw	a6,a5,a3
ffffffffc020073a:	feb86de3          	bltu	a6,a1,ffffffffc0200734 <buddy_free_pages+0x12>
    for (; p != base + (1 << order); p++) {
ffffffffc020073e:	00281793          	slli	a5,a6,0x2
ffffffffc0200742:	97c2                	add	a5,a5,a6
ffffffffc0200744:	078e                	slli	a5,a5,0x3
ffffffffc0200746:	00f50633          	add	a2,a0,a5
ffffffffc020074a:	c38d                	beqz	a5,ffffffffc020076c <buddy_free_pages+0x4a>
    struct Page *p = base;
ffffffffc020074c:	87aa                	mv	a5,a0
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020074e:	6798                	ld	a4,8(a5)
ffffffffc0200750:	8b0d                	andi	a4,a4,3
ffffffffc0200752:	10071f63          	bnez	a4,ffffffffc0200870 <buddy_free_pages+0x14e>
        p->flags = 0;
ffffffffc0200756:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020075a:	0007a023          	sw	zero,0(a5)
    for (; p != base + (1 << order); p++) {
ffffffffc020075e:	02878793          	addi	a5,a5,40
ffffffffc0200762:	fec796e3          	bne	a5,a2,ffffffffc020074e <buddy_free_pages+0x2c>
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200766:	4805                	li	a6,1
ffffffffc0200768:	00d8183b          	sllw	a6,a6,a3
    while (order < MAX_ORDER -1) {
ffffffffc020076c:	47b5                	li	a5,13
ffffffffc020076e:	00005297          	auipc	t0,0x5
ffffffffc0200772:	8aa28293          	addi	t0,t0,-1878 # ffffffffc0205018 <free_area>
ffffffffc0200776:	0ad7e163          	bltu	a5,a3,ffffffffc0200818 <buddy_free_pages+0xf6>
ffffffffc020077a:	02069793          	slli	a5,a3,0x20
ffffffffc020077e:	9381                	srli	a5,a5,0x20
ffffffffc0200780:	00179613          	slli	a2,a5,0x1
ffffffffc0200784:	963e                	add	a2,a2,a5
ffffffffc0200786:	00005297          	auipc	t0,0x5
ffffffffc020078a:	89228293          	addi	t0,t0,-1902 # ffffffffc0205018 <free_area>
ffffffffc020078e:	060e                	slli	a2,a2,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200790:	00005317          	auipc	t1,0x5
ffffffffc0200794:	a1833303          	ld	t1,-1512(t1) # ffffffffc02051a8 <pages>
ffffffffc0200798:	00001897          	auipc	a7,0x1
ffffffffc020079c:	f688b883          	ld	a7,-152(a7) # ffffffffc0201700 <nbase>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02007a0:	00005f17          	auipc	t5,0x5
ffffffffc02007a4:	a00f3f03          	ld	t5,-1536(t5) # ffffffffc02051a0 <npage>
ffffffffc02007a8:	9616                	add	a2,a2,t0
ffffffffc02007aa:	00001e97          	auipc	t4,0x1
ffffffffc02007ae:	f4eebe83          	ld	t4,-178(t4) # ffffffffc02016f8 <error_string+0x38>
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc02007b2:	4e05                	li	t3,1
    while (order < MAX_ORDER -1) {
ffffffffc02007b4:	4fb9                	li	t6,14
ffffffffc02007b6:	a805                	j	ffffffffc02007e6 <buddy_free_pages+0xc4>
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc02007b8:	4b8c                	lw	a1,16(a5)
ffffffffc02007ba:	04d59f63          	bne	a1,a3,ffffffffc0200818 <buddy_free_pages+0xf6>
    __list_del(listelm->prev, listelm->next);
ffffffffc02007be:	0187b383          	ld	t2,24(a5)
ffffffffc02007c2:	0207b803          	ld	a6,32(a5)
        free_area[order].nr_free--;
ffffffffc02007c6:	4a0c                	lw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc02007c8:	9b75                	andi	a4,a4,-3
    prev->next = next;
ffffffffc02007ca:	0103b423          	sd	a6,8(t2)
    next->prev = prev;
ffffffffc02007ce:	00783023          	sd	t2,0(a6)
        free_area[order].nr_free--;
ffffffffc02007d2:	35fd                	addiw	a1,a1,-1
ffffffffc02007d4:	ca0c                	sw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc02007d6:	e798                	sd	a4,8(a5)
        if (buddy < base) {
ffffffffc02007d8:	00a7f363          	bgeu	a5,a0,ffffffffc02007de <buddy_free_pages+0xbc>
ffffffffc02007dc:	853e                	mv	a0,a5
        order++; // 阶数加一，继续向上尝试合并
ffffffffc02007de:	2685                	addiw	a3,a3,1
    while (order < MAX_ORDER -1) {
ffffffffc02007e0:	0661                	addi	a2,a2,24
ffffffffc02007e2:	09f68263          	beq	a3,t6,ffffffffc0200866 <buddy_free_pages+0x144>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02007e6:	406507b3          	sub	a5,a0,t1
ffffffffc02007ea:	878d                	srai	a5,a5,0x3
ffffffffc02007ec:	03d787b3          	mul	a5,a5,t4
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc02007f0:	00de183b          	sllw	a6,t3,a3
ffffffffc02007f4:	97c6                	add	a5,a5,a7
ffffffffc02007f6:	0107c7b3          	xor	a5,a5,a6
        struct Page *buddy = pa2page(buddy_idx * PGSIZE);
ffffffffc02007fa:	07b2                	slli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02007fc:	83b1                	srli	a5,a5,0xc
ffffffffc02007fe:	09e7f963          	bgeu	a5,t5,ffffffffc0200890 <buddy_free_pages+0x16e>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200802:	411787b3          	sub	a5,a5,a7
ffffffffc0200806:	00279713          	slli	a4,a5,0x2
ffffffffc020080a:	97ba                	add	a5,a5,a4
ffffffffc020080c:	078e                	slli	a5,a5,0x3
ffffffffc020080e:	979a                	add	a5,a5,t1
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc0200810:	6798                	ld	a4,8(a5)
ffffffffc0200812:	00277593          	andi	a1,a4,2
ffffffffc0200816:	f1cd                	bnez	a1,ffffffffc02007b8 <buddy_free_pages+0x96>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200818:	02069713          	slli	a4,a3,0x20
ffffffffc020081c:	9301                	srli	a4,a4,0x20
ffffffffc020081e:	00171793          	slli	a5,a4,0x1
ffffffffc0200822:	97ba                	add	a5,a5,a4
ffffffffc0200824:	078e                	slli	a5,a5,0x3
    SetPageProperty(base);
ffffffffc0200826:	6518                	ld	a4,8(a0)
ffffffffc0200828:	92be                	add	t0,t0,a5
ffffffffc020082a:	0082b583          	ld	a1,8(t0)
ffffffffc020082e:	00276793          	ori	a5,a4,2
    nr_free += (1 << order);
ffffffffc0200832:	00005617          	auipc	a2,0x5
ffffffffc0200836:	96660613          	addi	a2,a2,-1690 # ffffffffc0205198 <nr_free>
    free_area[order].nr_free++;
ffffffffc020083a:	0102a703          	lw	a4,16(t0)
    base->property = order;
ffffffffc020083e:	c914                	sw	a3,16(a0)
    SetPageProperty(base);
ffffffffc0200840:	e51c                	sd	a5,8(a0)
    list_add(&(free_area[order].free_list), &(base->page_link));
ffffffffc0200842:	01850693          	addi	a3,a0,24
    nr_free += (1 << order);
ffffffffc0200846:	621c                	ld	a5,0(a2)
    prev->next = next->prev = elm;
ffffffffc0200848:	e194                	sd	a3,0(a1)
ffffffffc020084a:	00d2b423          	sd	a3,8(t0)
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200850:	f10c                	sd	a1,32(a0)
    elm->prev = prev;
ffffffffc0200852:	00553c23          	sd	t0,24(a0)
    free_area[order].nr_free++;
ffffffffc0200856:	2705                	addiw	a4,a4,1
    nr_free += (1 << order);
ffffffffc0200858:	983e                	add	a6,a6,a5
    free_area[order].nr_free++;
ffffffffc020085a:	00e2a823          	sw	a4,16(t0)
    nr_free += (1 << order);
ffffffffc020085e:	01063023          	sd	a6,0(a2)
}
ffffffffc0200862:	0141                	addi	sp,sp,16
ffffffffc0200864:	8082                	ret
ffffffffc0200866:	6811                	lui	a6,0x4
ffffffffc0200868:	bf45                	j	ffffffffc0200818 <buddy_free_pages+0xf6>
    for (; p != base + (1 << order); p++) {
ffffffffc020086a:	02850613          	addi	a2,a0,40
ffffffffc020086e:	bdf9                	j	ffffffffc020074c <buddy_free_pages+0x2a>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200870:	00001697          	auipc	a3,0x1
ffffffffc0200874:	a7068693          	addi	a3,a3,-1424 # ffffffffc02012e0 <etext+0x298>
ffffffffc0200878:	00001617          	auipc	a2,0x1
ffffffffc020087c:	a3860613          	addi	a2,a2,-1480 # ffffffffc02012b0 <etext+0x268>
ffffffffc0200880:	08800593          	li	a1,136
ffffffffc0200884:	00001517          	auipc	a0,0x1
ffffffffc0200888:	a4450513          	addi	a0,a0,-1468 # ffffffffc02012c8 <etext+0x280>
ffffffffc020088c:	937ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200890:	00001617          	auipc	a2,0x1
ffffffffc0200894:	a7860613          	addi	a2,a2,-1416 # ffffffffc0201308 <etext+0x2c0>
ffffffffc0200898:	06a00593          	li	a1,106
ffffffffc020089c:	00001517          	auipc	a0,0x1
ffffffffc02008a0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201328 <etext+0x2e0>
ffffffffc02008a4:	91fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02008a8:	00001697          	auipc	a3,0x1
ffffffffc02008ac:	a0068693          	addi	a3,a3,-1536 # ffffffffc02012a8 <etext+0x260>
ffffffffc02008b0:	00001617          	auipc	a2,0x1
ffffffffc02008b4:	a0060613          	addi	a2,a2,-1536 # ffffffffc02012b0 <etext+0x268>
ffffffffc02008b8:	08200593          	li	a1,130
ffffffffc02008bc:	00001517          	auipc	a0,0x1
ffffffffc02008c0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02012c8 <etext+0x280>
ffffffffc02008c4:	8ffff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008c8 <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc02008c8:	1141                	addi	sp,sp,-16
ffffffffc02008ca:	e406                	sd	ra,8(sp)
ffffffffc02008cc:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc02008ce:	c5fd                	beqz	a1,ffffffffc02009bc <buddy_init_memmap+0xf4>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc02008d0:	00259693          	slli	a3,a1,0x2
ffffffffc02008d4:	96ae                	add	a3,a3,a1
ffffffffc02008d6:	068e                	slli	a3,a3,0x3
ffffffffc02008d8:	96aa                	add	a3,a3,a0
ffffffffc02008da:	87aa                	mv	a5,a0
ffffffffc02008dc:	00d57f63          	bgeu	a0,a3,ffffffffc02008fa <buddy_init_memmap+0x32>
        assert(PageReserved(p));
ffffffffc02008e0:	6798                	ld	a4,8(a5)
ffffffffc02008e2:	8b05                	andi	a4,a4,1
ffffffffc02008e4:	cf45                	beqz	a4,ffffffffc020099c <buddy_init_memmap+0xd4>
        p->flags = 0;
ffffffffc02008e6:	0007b423          	sd	zero,8(a5)
        p->property = 0; 
ffffffffc02008ea:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008ee:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc02008f2:	02878793          	addi	a5,a5,40
ffffffffc02008f6:	fed7e5e3          	bltu	a5,a3,ffffffffc02008e0 <buddy_init_memmap+0x18>
ffffffffc02008fa:	00005417          	auipc	s0,0x5
ffffffffc02008fe:	89e40413          	addi	s0,s0,-1890 # ffffffffc0205198 <nr_free>
ffffffffc0200902:	00043283          	ld	t0,0(s0)
ffffffffc0200906:	00004397          	auipc	t2,0x4
ffffffffc020090a:	71238393          	addi	t2,t2,1810 # ffffffffc0205018 <free_area>
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc020090e:	4605                	li	a2,1
ffffffffc0200910:	4839                	li	a6,14
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200912:	4781                	li	a5,0
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc0200914:	0017871b          	addiw	a4,a5,1
ffffffffc0200918:	00e6173b          	sllw	a4,a2,a4
ffffffffc020091c:	0007869b          	sext.w	a3,a5
ffffffffc0200920:	06e5e263          	bltu	a1,a4,ffffffffc0200984 <buddy_init_memmap+0xbc>
ffffffffc0200924:	0785                	addi	a5,a5,1
ffffffffc0200926:	ff0797e3          	bne	a5,a6,ffffffffc0200914 <buddy_init_memmap+0x4c>
ffffffffc020092a:	000a0f37          	lui	t5,0xa0
ffffffffc020092e:	6e91                	lui	t4,0x4
ffffffffc0200930:	46b9                	li	a3,14
ffffffffc0200932:	15000893          	li	a7,336
ffffffffc0200936:	00179713          	slli	a4,a5,0x1
    __list_add(elm, listelm, listelm->next);
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	078e                	slli	a5,a5,0x3
ffffffffc020093e:	979e                	add	a5,a5,t2
ffffffffc0200940:	0087bf83          	ld	t6,8(a5)
        free_area[order].nr_free++;
ffffffffc0200944:	0107ae03          	lw	t3,16(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200948:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020094c:	00efb023          	sd	a4,0(t6)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200950:	00853303          	ld	t1,8(a0)
ffffffffc0200954:	e798                	sd	a4,8(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200956:	01138733          	add	a4,t2,a7
    elm->prev = prev;
ffffffffc020095a:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc020095c:	03f53023          	sd	t6,32(a0)
        free_area[order].nr_free++;
ffffffffc0200960:	001e071b          	addiw	a4,t3,1
ffffffffc0200964:	cb98                	sw	a4,16(a5)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200966:	00236793          	ori	a5,t1,2
        p->property = order;
ffffffffc020096a:	c914                	sw	a3,16(a0)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc020096c:	e51c                	sd	a5,8(a0)
        total_pages -= (1 << order);
ffffffffc020096e:	41d585b3          	sub	a1,a1,t4
        nr_free += (1 << order);
ffffffffc0200972:	92f6                	add	t0,t0,t4
        p += (1 << order);
ffffffffc0200974:	957a                	add	a0,a0,t5
    while (total_pages > 0) {
ffffffffc0200976:	fdd1                	bnez	a1,ffffffffc0200912 <buddy_init_memmap+0x4a>
}
ffffffffc0200978:	60a2                	ld	ra,8(sp)
ffffffffc020097a:	00543023          	sd	t0,0(s0)
ffffffffc020097e:	6402                	ld	s0,0(sp)
ffffffffc0200980:	0141                	addi	sp,sp,16
ffffffffc0200982:	8082                	ret
        nr_free += (1 << order);
ffffffffc0200984:	00d61ebb          	sllw	t4,a2,a3
ffffffffc0200988:	00179713          	slli	a4,a5,0x1
        p += (1 << order);
ffffffffc020098c:	002e9f13          	slli	t5,t4,0x2
ffffffffc0200990:	00f708b3          	add	a7,a4,a5
ffffffffc0200994:	9f76                	add	t5,t5,t4
ffffffffc0200996:	088e                	slli	a7,a7,0x3
ffffffffc0200998:	0f0e                	slli	t5,t5,0x3
ffffffffc020099a:	b745                	j	ffffffffc020093a <buddy_init_memmap+0x72>
        assert(PageReserved(p));
ffffffffc020099c:	00001697          	auipc	a3,0x1
ffffffffc02009a0:	99c68693          	addi	a3,a3,-1636 # ffffffffc0201338 <etext+0x2f0>
ffffffffc02009a4:	00001617          	auipc	a2,0x1
ffffffffc02009a8:	90c60613          	addi	a2,a2,-1780 # ffffffffc02012b0 <etext+0x268>
ffffffffc02009ac:	02d00593          	li	a1,45
ffffffffc02009b0:	00001517          	auipc	a0,0x1
ffffffffc02009b4:	91850513          	addi	a0,a0,-1768 # ffffffffc02012c8 <etext+0x280>
ffffffffc02009b8:	80bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02009bc:	00001697          	auipc	a3,0x1
ffffffffc02009c0:	8ec68693          	addi	a3,a3,-1812 # ffffffffc02012a8 <etext+0x260>
ffffffffc02009c4:	00001617          	auipc	a2,0x1
ffffffffc02009c8:	8ec60613          	addi	a2,a2,-1812 # ffffffffc02012b0 <etext+0x268>
ffffffffc02009cc:	02900593          	li	a1,41
ffffffffc02009d0:	00001517          	auipc	a0,0x1
ffffffffc02009d4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02012c8 <etext+0x280>
ffffffffc02009d8:	feaff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02009dc <pmm_init>:
static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    // pmm_manager = &default_pmm_manager; // <--- 2. 注释或删除此行
    pmm_manager = &buddy_pmm_manager;   // <--- 3. 添加此行，切换到伙伴系统
ffffffffc02009dc:	00001797          	auipc	a5,0x1
ffffffffc02009e0:	98478793          	addi	a5,a5,-1660 # ffffffffc0201360 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02009e4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02009e6:	7179                	addi	sp,sp,-48
ffffffffc02009e8:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02009ea:	00001517          	auipc	a0,0x1
ffffffffc02009ee:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0201398 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;   // <--- 3. 添加此行，切换到伙伴系统
ffffffffc02009f2:	00004417          	auipc	s0,0x4
ffffffffc02009f6:	7be40413          	addi	s0,s0,1982 # ffffffffc02051b0 <pmm_manager>
void pmm_init(void) {
ffffffffc02009fa:	f406                	sd	ra,40(sp)
ffffffffc02009fc:	ec26                	sd	s1,24(sp)
ffffffffc02009fe:	e44e                	sd	s3,8(sp)
ffffffffc0200a00:	e84a                	sd	s2,16(sp)
ffffffffc0200a02:	e052                	sd	s4,0(sp)
    pmm_manager = &buddy_pmm_manager;   // <--- 3. 添加此行，切换到伙伴系统
ffffffffc0200a04:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200a06:	f46ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200a0a:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200a0c:	00004497          	auipc	s1,0x4
ffffffffc0200a10:	7bc48493          	addi	s1,s1,1980 # ffffffffc02051c8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200a14:	679c                	ld	a5,8(a5)
ffffffffc0200a16:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200a18:	57f5                	li	a5,-3
ffffffffc0200a1a:	07fa                	slli	a5,a5,0x1e
ffffffffc0200a1c:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200a1e:	b9fff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc0200a22:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200a24:	ba3ff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200a28:	14050d63          	beqz	a0,ffffffffc0200b82 <pmm_init+0x1a6>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200a2c:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200a2e:	00001517          	auipc	a0,0x1
ffffffffc0200a32:	9b250513          	addi	a0,a0,-1614 # ffffffffc02013e0 <buddy_pmm_manager+0x80>
ffffffffc0200a36:	f16ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200a3a:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200a3e:	864e                	mv	a2,s3
ffffffffc0200a40:	fffa0693          	addi	a3,s4,-1
ffffffffc0200a44:	85ca                	mv	a1,s2
ffffffffc0200a46:	00001517          	auipc	a0,0x1
ffffffffc0200a4a:	9b250513          	addi	a0,a0,-1614 # ffffffffc02013f8 <buddy_pmm_manager+0x98>
ffffffffc0200a4e:	efeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200a52:	c80007b7          	lui	a5,0xc8000
ffffffffc0200a56:	8652                	mv	a2,s4
ffffffffc0200a58:	0d47e463          	bltu	a5,s4,ffffffffc0200b20 <pmm_init+0x144>
ffffffffc0200a5c:	00005797          	auipc	a5,0x5
ffffffffc0200a60:	77378793          	addi	a5,a5,1907 # ffffffffc02061cf <end+0xfff>
ffffffffc0200a64:	757d                	lui	a0,0xfffff
ffffffffc0200a66:	8d7d                	and	a0,a0,a5
ffffffffc0200a68:	8231                	srli	a2,a2,0xc
ffffffffc0200a6a:	00004797          	auipc	a5,0x4
ffffffffc0200a6e:	72c7bb23          	sd	a2,1846(a5) # ffffffffc02051a0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200a72:	00004797          	auipc	a5,0x4
ffffffffc0200a76:	72a7bb23          	sd	a0,1846(a5) # ffffffffc02051a8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200a7a:	000807b7          	lui	a5,0x80
ffffffffc0200a7e:	002005b7          	lui	a1,0x200
ffffffffc0200a82:	02f60563          	beq	a2,a5,ffffffffc0200aac <pmm_init+0xd0>
ffffffffc0200a86:	00261593          	slli	a1,a2,0x2
ffffffffc0200a8a:	00c586b3          	add	a3,a1,a2
ffffffffc0200a8e:	fec007b7          	lui	a5,0xfec00
ffffffffc0200a92:	97aa                	add	a5,a5,a0
ffffffffc0200a94:	068e                	slli	a3,a3,0x3
ffffffffc0200a96:	96be                	add	a3,a3,a5
ffffffffc0200a98:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc0200a9a:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200a9c:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9fae58>
        SetPageReserved(pages + i);
ffffffffc0200aa0:	00176713          	ori	a4,a4,1
ffffffffc0200aa4:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200aa8:	fef699e3          	bne	a3,a5,ffffffffc0200a9a <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200aac:	95b2                	add	a1,a1,a2
ffffffffc0200aae:	fec006b7          	lui	a3,0xfec00
ffffffffc0200ab2:	96aa                	add	a3,a3,a0
ffffffffc0200ab4:	058e                	slli	a1,a1,0x3
ffffffffc0200ab6:	96ae                	add	a3,a3,a1
ffffffffc0200ab8:	c02007b7          	lui	a5,0xc0200
ffffffffc0200abc:	0af6e763          	bltu	a3,a5,ffffffffc0200b6a <pmm_init+0x18e>
ffffffffc0200ac0:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0200ac2:	77fd                	lui	a5,0xfffff
ffffffffc0200ac4:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ac8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200aca:	04b6ee63          	bltu	a3,a1,ffffffffc0200b26 <pmm_init+0x14a>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ace:	601c                	ld	a5,0(s0)
ffffffffc0200ad0:	7b9c                	ld	a5,48(a5)
ffffffffc0200ad2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200ad4:	00001517          	auipc	a0,0x1
ffffffffc0200ad8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0201450 <buddy_pmm_manager+0xf0>
ffffffffc0200adc:	e70ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200ae0:	00003597          	auipc	a1,0x3
ffffffffc0200ae4:	52058593          	addi	a1,a1,1312 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc0200ae8:	00004797          	auipc	a5,0x4
ffffffffc0200aec:	6cb7bc23          	sd	a1,1752(a5) # ffffffffc02051c0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200af0:	c02007b7          	lui	a5,0xc0200
ffffffffc0200af4:	0af5e363          	bltu	a1,a5,ffffffffc0200b9a <pmm_init+0x1be>
ffffffffc0200af8:	6090                	ld	a2,0(s1)
}
ffffffffc0200afa:	7402                	ld	s0,32(sp)
ffffffffc0200afc:	70a2                	ld	ra,40(sp)
ffffffffc0200afe:	64e2                	ld	s1,24(sp)
ffffffffc0200b00:	6942                	ld	s2,16(sp)
ffffffffc0200b02:	69a2                	ld	s3,8(sp)
ffffffffc0200b04:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200b06:	40c58633          	sub	a2,a1,a2
ffffffffc0200b0a:	00004797          	auipc	a5,0x4
ffffffffc0200b0e:	6ac7b723          	sd	a2,1710(a5) # ffffffffc02051b8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200b12:	00001517          	auipc	a0,0x1
ffffffffc0200b16:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201470 <buddy_pmm_manager+0x110>
}
ffffffffc0200b1a:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200b1c:	e30ff06f          	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200b20:	c8000637          	lui	a2,0xc8000
ffffffffc0200b24:	bf25                	j	ffffffffc0200a5c <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200b26:	6705                	lui	a4,0x1
ffffffffc0200b28:	177d                	addi	a4,a4,-1
ffffffffc0200b2a:	96ba                	add	a3,a3,a4
ffffffffc0200b2c:	8efd                	and	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0200b2e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200b32:	02c7f063          	bgeu	a5,a2,ffffffffc0200b52 <pmm_init+0x176>
    pmm_manager->init_memmap(base, n);
ffffffffc0200b36:	6010                	ld	a2,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0200b38:	fff80737          	lui	a4,0xfff80
ffffffffc0200b3c:	973e                	add	a4,a4,a5
ffffffffc0200b3e:	00271793          	slli	a5,a4,0x2
ffffffffc0200b42:	97ba                	add	a5,a5,a4
ffffffffc0200b44:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200b46:	8d95                	sub	a1,a1,a3
ffffffffc0200b48:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200b4a:	81b1                	srli	a1,a1,0xc
ffffffffc0200b4c:	953e                	add	a0,a0,a5
ffffffffc0200b4e:	9702                	jalr	a4
}
ffffffffc0200b50:	bfbd                	j	ffffffffc0200ace <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0200b52:	00000617          	auipc	a2,0x0
ffffffffc0200b56:	7b660613          	addi	a2,a2,1974 # ffffffffc0201308 <etext+0x2c0>
ffffffffc0200b5a:	06a00593          	li	a1,106
ffffffffc0200b5e:	00000517          	auipc	a0,0x0
ffffffffc0200b62:	7ca50513          	addi	a0,a0,1994 # ffffffffc0201328 <etext+0x2e0>
ffffffffc0200b66:	e5cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200b6a:	00001617          	auipc	a2,0x1
ffffffffc0200b6e:	8be60613          	addi	a2,a2,-1858 # ffffffffc0201428 <buddy_pmm_manager+0xc8>
ffffffffc0200b72:	06100593          	li	a1,97
ffffffffc0200b76:	00001517          	auipc	a0,0x1
ffffffffc0200b7a:	85a50513          	addi	a0,a0,-1958 # ffffffffc02013d0 <buddy_pmm_manager+0x70>
ffffffffc0200b7e:	e44ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0200b82:	00001617          	auipc	a2,0x1
ffffffffc0200b86:	82e60613          	addi	a2,a2,-2002 # ffffffffc02013b0 <buddy_pmm_manager+0x50>
ffffffffc0200b8a:	04900593          	li	a1,73
ffffffffc0200b8e:	00001517          	auipc	a0,0x1
ffffffffc0200b92:	84250513          	addi	a0,a0,-1982 # ffffffffc02013d0 <buddy_pmm_manager+0x70>
ffffffffc0200b96:	e2cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200b9a:	86ae                	mv	a3,a1
ffffffffc0200b9c:	00001617          	auipc	a2,0x1
ffffffffc0200ba0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0201428 <buddy_pmm_manager+0xc8>
ffffffffc0200ba4:	07c00593          	li	a1,124
ffffffffc0200ba8:	00001517          	auipc	a0,0x1
ffffffffc0200bac:	82850513          	addi	a0,a0,-2008 # ffffffffc02013d0 <buddy_pmm_manager+0x70>
ffffffffc0200bb0:	e12ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200bb4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200bb4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200bb8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200bba:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200bbe:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200bc0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200bc4:	f022                	sd	s0,32(sp)
ffffffffc0200bc6:	ec26                	sd	s1,24(sp)
ffffffffc0200bc8:	e84a                	sd	s2,16(sp)
ffffffffc0200bca:	f406                	sd	ra,40(sp)
ffffffffc0200bcc:	e44e                	sd	s3,8(sp)
ffffffffc0200bce:	84aa                	mv	s1,a0
ffffffffc0200bd0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200bd2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200bd6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200bd8:	03067e63          	bgeu	a2,a6,ffffffffc0200c14 <printnum+0x60>
ffffffffc0200bdc:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200bde:	00805763          	blez	s0,ffffffffc0200bec <printnum+0x38>
ffffffffc0200be2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200be4:	85ca                	mv	a1,s2
ffffffffc0200be6:	854e                	mv	a0,s3
ffffffffc0200be8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200bea:	fc65                	bnez	s0,ffffffffc0200be2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200bec:	1a02                	slli	s4,s4,0x20
ffffffffc0200bee:	00001797          	auipc	a5,0x1
ffffffffc0200bf2:	8c278793          	addi	a5,a5,-1854 # ffffffffc02014b0 <buddy_pmm_manager+0x150>
ffffffffc0200bf6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200bfa:	9a3e                	add	s4,s4,a5
}
ffffffffc0200bfc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200bfe:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200c02:	70a2                	ld	ra,40(sp)
ffffffffc0200c04:	69a2                	ld	s3,8(sp)
ffffffffc0200c06:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200c08:	85ca                	mv	a1,s2
ffffffffc0200c0a:	87a6                	mv	a5,s1
}
ffffffffc0200c0c:	6942                	ld	s2,16(sp)
ffffffffc0200c0e:	64e2                	ld	s1,24(sp)
ffffffffc0200c10:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200c12:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200c14:	03065633          	divu	a2,a2,a6
ffffffffc0200c18:	8722                	mv	a4,s0
ffffffffc0200c1a:	f9bff0ef          	jal	ra,ffffffffc0200bb4 <printnum>
ffffffffc0200c1e:	b7f9                	j	ffffffffc0200bec <printnum+0x38>

ffffffffc0200c20 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200c20:	7119                	addi	sp,sp,-128
ffffffffc0200c22:	f4a6                	sd	s1,104(sp)
ffffffffc0200c24:	f0ca                	sd	s2,96(sp)
ffffffffc0200c26:	ecce                	sd	s3,88(sp)
ffffffffc0200c28:	e8d2                	sd	s4,80(sp)
ffffffffc0200c2a:	e4d6                	sd	s5,72(sp)
ffffffffc0200c2c:	e0da                	sd	s6,64(sp)
ffffffffc0200c2e:	fc5e                	sd	s7,56(sp)
ffffffffc0200c30:	f06a                	sd	s10,32(sp)
ffffffffc0200c32:	fc86                	sd	ra,120(sp)
ffffffffc0200c34:	f8a2                	sd	s0,112(sp)
ffffffffc0200c36:	f862                	sd	s8,48(sp)
ffffffffc0200c38:	f466                	sd	s9,40(sp)
ffffffffc0200c3a:	ec6e                	sd	s11,24(sp)
ffffffffc0200c3c:	892a                	mv	s2,a0
ffffffffc0200c3e:	84ae                	mv	s1,a1
ffffffffc0200c40:	8d32                	mv	s10,a2
ffffffffc0200c42:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200c44:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200c48:	5b7d                	li	s6,-1
ffffffffc0200c4a:	00001a97          	auipc	s5,0x1
ffffffffc0200c4e:	89aa8a93          	addi	s5,s5,-1894 # ffffffffc02014e4 <buddy_pmm_manager+0x184>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200c52:	00001b97          	auipc	s7,0x1
ffffffffc0200c56:	a6eb8b93          	addi	s7,s7,-1426 # ffffffffc02016c0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200c5a:	000d4503          	lbu	a0,0(s10)
ffffffffc0200c5e:	001d0413          	addi	s0,s10,1
ffffffffc0200c62:	01350a63          	beq	a0,s3,ffffffffc0200c76 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0200c66:	c121                	beqz	a0,ffffffffc0200ca6 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0200c68:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200c6a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200c6c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200c6e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200c72:	ff351ae3          	bne	a0,s3,ffffffffc0200c66 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200c76:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200c7a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200c7e:	4c81                	li	s9,0
ffffffffc0200c80:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0200c82:	5c7d                	li	s8,-1
ffffffffc0200c84:	5dfd                	li	s11,-1
ffffffffc0200c86:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0200c8a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200c8c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200c90:	0ff5f593          	zext.b	a1,a1
ffffffffc0200c94:	00140d13          	addi	s10,s0,1
ffffffffc0200c98:	04b56263          	bltu	a0,a1,ffffffffc0200cdc <vprintfmt+0xbc>
ffffffffc0200c9c:	058a                	slli	a1,a1,0x2
ffffffffc0200c9e:	95d6                	add	a1,a1,s5
ffffffffc0200ca0:	4194                	lw	a3,0(a1)
ffffffffc0200ca2:	96d6                	add	a3,a3,s5
ffffffffc0200ca4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200ca6:	70e6                	ld	ra,120(sp)
ffffffffc0200ca8:	7446                	ld	s0,112(sp)
ffffffffc0200caa:	74a6                	ld	s1,104(sp)
ffffffffc0200cac:	7906                	ld	s2,96(sp)
ffffffffc0200cae:	69e6                	ld	s3,88(sp)
ffffffffc0200cb0:	6a46                	ld	s4,80(sp)
ffffffffc0200cb2:	6aa6                	ld	s5,72(sp)
ffffffffc0200cb4:	6b06                	ld	s6,64(sp)
ffffffffc0200cb6:	7be2                	ld	s7,56(sp)
ffffffffc0200cb8:	7c42                	ld	s8,48(sp)
ffffffffc0200cba:	7ca2                	ld	s9,40(sp)
ffffffffc0200cbc:	7d02                	ld	s10,32(sp)
ffffffffc0200cbe:	6de2                	ld	s11,24(sp)
ffffffffc0200cc0:	6109                	addi	sp,sp,128
ffffffffc0200cc2:	8082                	ret
            padc = '0';
ffffffffc0200cc4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0200cc6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200cca:	846a                	mv	s0,s10
ffffffffc0200ccc:	00140d13          	addi	s10,s0,1
ffffffffc0200cd0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200cd4:	0ff5f593          	zext.b	a1,a1
ffffffffc0200cd8:	fcb572e3          	bgeu	a0,a1,ffffffffc0200c9c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0200cdc:	85a6                	mv	a1,s1
ffffffffc0200cde:	02500513          	li	a0,37
ffffffffc0200ce2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0200ce4:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200ce8:	8d22                	mv	s10,s0
ffffffffc0200cea:	f73788e3          	beq	a5,s3,ffffffffc0200c5a <vprintfmt+0x3a>
ffffffffc0200cee:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200cf2:	1d7d                	addi	s10,s10,-1
ffffffffc0200cf4:	ff379de3          	bne	a5,s3,ffffffffc0200cee <vprintfmt+0xce>
ffffffffc0200cf8:	b78d                	j	ffffffffc0200c5a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0200cfa:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0200cfe:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200d02:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0200d04:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0200d08:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200d0c:	02d86463          	bltu	a6,a3,ffffffffc0200d34 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0200d10:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0200d14:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200d18:	0186873b          	addw	a4,a3,s8
ffffffffc0200d1c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200d20:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0200d22:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0200d26:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0200d28:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0200d2c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200d30:	fed870e3          	bgeu	a6,a3,ffffffffc0200d10 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0200d34:	f40ddce3          	bgez	s11,ffffffffc0200c8c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0200d38:	8de2                	mv	s11,s8
ffffffffc0200d3a:	5c7d                	li	s8,-1
ffffffffc0200d3c:	bf81                	j	ffffffffc0200c8c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0200d3e:	fffdc693          	not	a3,s11
ffffffffc0200d42:	96fd                	srai	a3,a3,0x3f
ffffffffc0200d44:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200d48:	00144603          	lbu	a2,1(s0)
ffffffffc0200d4c:	2d81                	sext.w	s11,s11
ffffffffc0200d4e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200d50:	bf35                	j	ffffffffc0200c8c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0200d52:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200d56:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0200d5a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200d5c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0200d5e:	bfd9                	j	ffffffffc0200d34 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0200d60:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200d62:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200d66:	01174463          	blt	a4,a7,ffffffffc0200d6e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0200d6a:	1a088e63          	beqz	a7,ffffffffc0200f26 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0200d6e:	000a3603          	ld	a2,0(s4)
ffffffffc0200d72:	46c1                	li	a3,16
ffffffffc0200d74:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0200d76:	2781                	sext.w	a5,a5
ffffffffc0200d78:	876e                	mv	a4,s11
ffffffffc0200d7a:	85a6                	mv	a1,s1
ffffffffc0200d7c:	854a                	mv	a0,s2
ffffffffc0200d7e:	e37ff0ef          	jal	ra,ffffffffc0200bb4 <printnum>
            break;
ffffffffc0200d82:	bde1                	j	ffffffffc0200c5a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0200d84:	000a2503          	lw	a0,0(s4)
ffffffffc0200d88:	85a6                	mv	a1,s1
ffffffffc0200d8a:	0a21                	addi	s4,s4,8
ffffffffc0200d8c:	9902                	jalr	s2
            break;
ffffffffc0200d8e:	b5f1                	j	ffffffffc0200c5a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200d90:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200d92:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200d96:	01174463          	blt	a4,a7,ffffffffc0200d9e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0200d9a:	18088163          	beqz	a7,ffffffffc0200f1c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0200d9e:	000a3603          	ld	a2,0(s4)
ffffffffc0200da2:	46a9                	li	a3,10
ffffffffc0200da4:	8a2e                	mv	s4,a1
ffffffffc0200da6:	bfc1                	j	ffffffffc0200d76 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200da8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0200dac:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200dae:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200db0:	bdf1                	j	ffffffffc0200c8c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0200db2:	85a6                	mv	a1,s1
ffffffffc0200db4:	02500513          	li	a0,37
ffffffffc0200db8:	9902                	jalr	s2
            break;
ffffffffc0200dba:	b545                	j	ffffffffc0200c5a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200dbc:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0200dc0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200dc2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200dc4:	b5e1                	j	ffffffffc0200c8c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0200dc6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200dc8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200dcc:	01174463          	blt	a4,a7,ffffffffc0200dd4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0200dd0:	14088163          	beqz	a7,ffffffffc0200f12 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0200dd4:	000a3603          	ld	a2,0(s4)
ffffffffc0200dd8:	46a1                	li	a3,8
ffffffffc0200dda:	8a2e                	mv	s4,a1
ffffffffc0200ddc:	bf69                	j	ffffffffc0200d76 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0200dde:	03000513          	li	a0,48
ffffffffc0200de2:	85a6                	mv	a1,s1
ffffffffc0200de4:	e03e                	sd	a5,0(sp)
ffffffffc0200de6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0200de8:	85a6                	mv	a1,s1
ffffffffc0200dea:	07800513          	li	a0,120
ffffffffc0200dee:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200df0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0200df2:	6782                	ld	a5,0(sp)
ffffffffc0200df4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200df6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0200dfa:	bfb5                	j	ffffffffc0200d76 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0200dfc:	000a3403          	ld	s0,0(s4)
ffffffffc0200e00:	008a0713          	addi	a4,s4,8
ffffffffc0200e04:	e03a                	sd	a4,0(sp)
ffffffffc0200e06:	14040263          	beqz	s0,ffffffffc0200f4a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0200e0a:	0fb05763          	blez	s11,ffffffffc0200ef8 <vprintfmt+0x2d8>
ffffffffc0200e0e:	02d00693          	li	a3,45
ffffffffc0200e12:	0cd79163          	bne	a5,a3,ffffffffc0200ed4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200e16:	00044783          	lbu	a5,0(s0)
ffffffffc0200e1a:	0007851b          	sext.w	a0,a5
ffffffffc0200e1e:	cf85                	beqz	a5,ffffffffc0200e56 <vprintfmt+0x236>
ffffffffc0200e20:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200e24:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200e28:	000c4563          	bltz	s8,ffffffffc0200e32 <vprintfmt+0x212>
ffffffffc0200e2c:	3c7d                	addiw	s8,s8,-1
ffffffffc0200e2e:	036c0263          	beq	s8,s6,ffffffffc0200e52 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0200e32:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200e34:	0e0c8e63          	beqz	s9,ffffffffc0200f30 <vprintfmt+0x310>
ffffffffc0200e38:	3781                	addiw	a5,a5,-32
ffffffffc0200e3a:	0ef47b63          	bgeu	s0,a5,ffffffffc0200f30 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0200e3e:	03f00513          	li	a0,63
ffffffffc0200e42:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200e44:	000a4783          	lbu	a5,0(s4)
ffffffffc0200e48:	3dfd                	addiw	s11,s11,-1
ffffffffc0200e4a:	0a05                	addi	s4,s4,1
ffffffffc0200e4c:	0007851b          	sext.w	a0,a5
ffffffffc0200e50:	ffe1                	bnez	a5,ffffffffc0200e28 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0200e52:	01b05963          	blez	s11,ffffffffc0200e64 <vprintfmt+0x244>
ffffffffc0200e56:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0200e58:	85a6                	mv	a1,s1
ffffffffc0200e5a:	02000513          	li	a0,32
ffffffffc0200e5e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0200e60:	fe0d9be3          	bnez	s11,ffffffffc0200e56 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0200e64:	6a02                	ld	s4,0(sp)
ffffffffc0200e66:	bbd5                	j	ffffffffc0200c5a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200e68:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200e6a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0200e6e:	01174463          	blt	a4,a7,ffffffffc0200e76 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0200e72:	08088d63          	beqz	a7,ffffffffc0200f0c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0200e76:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0200e7a:	0a044d63          	bltz	s0,ffffffffc0200f34 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0200e7e:	8622                	mv	a2,s0
ffffffffc0200e80:	8a66                	mv	s4,s9
ffffffffc0200e82:	46a9                	li	a3,10
ffffffffc0200e84:	bdcd                	j	ffffffffc0200d76 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0200e86:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200e8a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0200e8c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0200e8e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0200e92:	8fb5                	xor	a5,a5,a3
ffffffffc0200e94:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200e98:	02d74163          	blt	a4,a3,ffffffffc0200eba <vprintfmt+0x29a>
ffffffffc0200e9c:	00369793          	slli	a5,a3,0x3
ffffffffc0200ea0:	97de                	add	a5,a5,s7
ffffffffc0200ea2:	639c                	ld	a5,0(a5)
ffffffffc0200ea4:	cb99                	beqz	a5,ffffffffc0200eba <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0200ea6:	86be                	mv	a3,a5
ffffffffc0200ea8:	00000617          	auipc	a2,0x0
ffffffffc0200eac:	63860613          	addi	a2,a2,1592 # ffffffffc02014e0 <buddy_pmm_manager+0x180>
ffffffffc0200eb0:	85a6                	mv	a1,s1
ffffffffc0200eb2:	854a                	mv	a0,s2
ffffffffc0200eb4:	0ce000ef          	jal	ra,ffffffffc0200f82 <printfmt>
ffffffffc0200eb8:	b34d                	j	ffffffffc0200c5a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0200eba:	00000617          	auipc	a2,0x0
ffffffffc0200ebe:	61660613          	addi	a2,a2,1558 # ffffffffc02014d0 <buddy_pmm_manager+0x170>
ffffffffc0200ec2:	85a6                	mv	a1,s1
ffffffffc0200ec4:	854a                	mv	a0,s2
ffffffffc0200ec6:	0bc000ef          	jal	ra,ffffffffc0200f82 <printfmt>
ffffffffc0200eca:	bb41                	j	ffffffffc0200c5a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0200ecc:	00000417          	auipc	s0,0x0
ffffffffc0200ed0:	5fc40413          	addi	s0,s0,1532 # ffffffffc02014c8 <buddy_pmm_manager+0x168>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0200ed4:	85e2                	mv	a1,s8
ffffffffc0200ed6:	8522                	mv	a0,s0
ffffffffc0200ed8:	e43e                	sd	a5,8(sp)
ffffffffc0200eda:	0fc000ef          	jal	ra,ffffffffc0200fd6 <strnlen>
ffffffffc0200ede:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0200ee2:	01b05b63          	blez	s11,ffffffffc0200ef8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0200ee6:	67a2                	ld	a5,8(sp)
ffffffffc0200ee8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0200eec:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0200eee:	85a6                	mv	a1,s1
ffffffffc0200ef0:	8552                	mv	a0,s4
ffffffffc0200ef2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0200ef4:	fe0d9ce3          	bnez	s11,ffffffffc0200eec <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200ef8:	00044783          	lbu	a5,0(s0)
ffffffffc0200efc:	00140a13          	addi	s4,s0,1
ffffffffc0200f00:	0007851b          	sext.w	a0,a5
ffffffffc0200f04:	d3a5                	beqz	a5,ffffffffc0200e64 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200f06:	05e00413          	li	s0,94
ffffffffc0200f0a:	bf39                	j	ffffffffc0200e28 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0200f0c:	000a2403          	lw	s0,0(s4)
ffffffffc0200f10:	b7ad                	j	ffffffffc0200e7a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0200f12:	000a6603          	lwu	a2,0(s4)
ffffffffc0200f16:	46a1                	li	a3,8
ffffffffc0200f18:	8a2e                	mv	s4,a1
ffffffffc0200f1a:	bdb1                	j	ffffffffc0200d76 <vprintfmt+0x156>
ffffffffc0200f1c:	000a6603          	lwu	a2,0(s4)
ffffffffc0200f20:	46a9                	li	a3,10
ffffffffc0200f22:	8a2e                	mv	s4,a1
ffffffffc0200f24:	bd89                	j	ffffffffc0200d76 <vprintfmt+0x156>
ffffffffc0200f26:	000a6603          	lwu	a2,0(s4)
ffffffffc0200f2a:	46c1                	li	a3,16
ffffffffc0200f2c:	8a2e                	mv	s4,a1
ffffffffc0200f2e:	b5a1                	j	ffffffffc0200d76 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0200f30:	9902                	jalr	s2
ffffffffc0200f32:	bf09                	j	ffffffffc0200e44 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0200f34:	85a6                	mv	a1,s1
ffffffffc0200f36:	02d00513          	li	a0,45
ffffffffc0200f3a:	e03e                	sd	a5,0(sp)
ffffffffc0200f3c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0200f3e:	6782                	ld	a5,0(sp)
ffffffffc0200f40:	8a66                	mv	s4,s9
ffffffffc0200f42:	40800633          	neg	a2,s0
ffffffffc0200f46:	46a9                	li	a3,10
ffffffffc0200f48:	b53d                	j	ffffffffc0200d76 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0200f4a:	03b05163          	blez	s11,ffffffffc0200f6c <vprintfmt+0x34c>
ffffffffc0200f4e:	02d00693          	li	a3,45
ffffffffc0200f52:	f6d79de3          	bne	a5,a3,ffffffffc0200ecc <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0200f56:	00000417          	auipc	s0,0x0
ffffffffc0200f5a:	57240413          	addi	s0,s0,1394 # ffffffffc02014c8 <buddy_pmm_manager+0x168>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200f5e:	02800793          	li	a5,40
ffffffffc0200f62:	02800513          	li	a0,40
ffffffffc0200f66:	00140a13          	addi	s4,s0,1
ffffffffc0200f6a:	bd6d                	j	ffffffffc0200e24 <vprintfmt+0x204>
ffffffffc0200f6c:	00000a17          	auipc	s4,0x0
ffffffffc0200f70:	55da0a13          	addi	s4,s4,1373 # ffffffffc02014c9 <buddy_pmm_manager+0x169>
ffffffffc0200f74:	02800513          	li	a0,40
ffffffffc0200f78:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200f7c:	05e00413          	li	s0,94
ffffffffc0200f80:	b565                	j	ffffffffc0200e28 <vprintfmt+0x208>

ffffffffc0200f82 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0200f82:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0200f84:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0200f88:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0200f8a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0200f8c:	ec06                	sd	ra,24(sp)
ffffffffc0200f8e:	f83a                	sd	a4,48(sp)
ffffffffc0200f90:	fc3e                	sd	a5,56(sp)
ffffffffc0200f92:	e0c2                	sd	a6,64(sp)
ffffffffc0200f94:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200f96:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0200f98:	c89ff0ef          	jal	ra,ffffffffc0200c20 <vprintfmt>
}
ffffffffc0200f9c:	60e2                	ld	ra,24(sp)
ffffffffc0200f9e:	6161                	addi	sp,sp,80
ffffffffc0200fa0:	8082                	ret

ffffffffc0200fa2 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0200fa2:	4781                	li	a5,0
ffffffffc0200fa4:	00004717          	auipc	a4,0x4
ffffffffc0200fa8:	06c73703          	ld	a4,108(a4) # ffffffffc0205010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0200fac:	88ba                	mv	a7,a4
ffffffffc0200fae:	852a                	mv	a0,a0
ffffffffc0200fb0:	85be                	mv	a1,a5
ffffffffc0200fb2:	863e                	mv	a2,a5
ffffffffc0200fb4:	00000073          	ecall
ffffffffc0200fb8:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0200fba:	8082                	ret

ffffffffc0200fbc <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0200fbc:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0200fc0:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0200fc2:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0200fc4:	cb81                	beqz	a5,ffffffffc0200fd4 <strlen+0x18>
        cnt ++;
ffffffffc0200fc6:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0200fc8:	00a707b3          	add	a5,a4,a0
ffffffffc0200fcc:	0007c783          	lbu	a5,0(a5)
ffffffffc0200fd0:	fbfd                	bnez	a5,ffffffffc0200fc6 <strlen+0xa>
ffffffffc0200fd2:	8082                	ret
    }
    return cnt;
}
ffffffffc0200fd4:	8082                	ret

ffffffffc0200fd6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0200fd6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200fd8:	e589                	bnez	a1,ffffffffc0200fe2 <strnlen+0xc>
ffffffffc0200fda:	a811                	j	ffffffffc0200fee <strnlen+0x18>
        cnt ++;
ffffffffc0200fdc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200fde:	00f58863          	beq	a1,a5,ffffffffc0200fee <strnlen+0x18>
ffffffffc0200fe2:	00f50733          	add	a4,a0,a5
ffffffffc0200fe6:	00074703          	lbu	a4,0(a4)
ffffffffc0200fea:	fb6d                	bnez	a4,ffffffffc0200fdc <strnlen+0x6>
ffffffffc0200fec:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0200fee:	852e                	mv	a0,a1
ffffffffc0200ff0:	8082                	ret

ffffffffc0200ff2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200ff2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200ff6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200ffa:	cb89                	beqz	a5,ffffffffc020100c <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0200ffc:	0505                	addi	a0,a0,1
ffffffffc0200ffe:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201000:	fee789e3          	beq	a5,a4,ffffffffc0200ff2 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201004:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201008:	9d19                	subw	a0,a0,a4
ffffffffc020100a:	8082                	ret
ffffffffc020100c:	4501                	li	a0,0
ffffffffc020100e:	bfed                	j	ffffffffc0201008 <strcmp+0x16>

ffffffffc0201010 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201010:	c20d                	beqz	a2,ffffffffc0201032 <strncmp+0x22>
ffffffffc0201012:	962e                	add	a2,a2,a1
ffffffffc0201014:	a031                	j	ffffffffc0201020 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201016:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201018:	00e79a63          	bne	a5,a4,ffffffffc020102c <strncmp+0x1c>
ffffffffc020101c:	00b60b63          	beq	a2,a1,ffffffffc0201032 <strncmp+0x22>
ffffffffc0201020:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201024:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201026:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020102a:	f7f5                	bnez	a5,ffffffffc0201016 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020102c:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201030:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201032:	4501                	li	a0,0
ffffffffc0201034:	8082                	ret

ffffffffc0201036 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201036:	ca01                	beqz	a2,ffffffffc0201046 <memset+0x10>
ffffffffc0201038:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020103a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020103c:	0785                	addi	a5,a5,1
ffffffffc020103e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201042:	fec79de3          	bne	a5,a2,ffffffffc020103c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201046:	8082                	ret
