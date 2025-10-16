
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0206137          	lui	sp,0xc0206
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
ffffffffc020004a:	1141                	addi	sp,sp,-16
ffffffffc020004c:	00002517          	auipc	a0,0x2
ffffffffc0200050:	37450513          	addi	a0,a0,884 # ffffffffc02023c0 <etext+0x4>
ffffffffc0200054:	e406                	sd	ra,8(sp)
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	37e50513          	addi	a0,a0,894 # ffffffffc02023e0 <etext+0x24>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	34e58593          	addi	a1,a1,846 # ffffffffc02023bc <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	38a50513          	addi	a0,a0,906 # ffffffffc0202400 <etext+0x44>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200082:	00007597          	auipc	a1,0x7
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0207018 <free_area>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	39650513          	addi	a0,a0,918 # ffffffffc0202420 <etext+0x64>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200096:	00007597          	auipc	a1,0x7
ffffffffc020009a:	47a58593          	addi	a1,a1,1146 # ffffffffc0207510 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	3a250513          	addi	a0,a0,930 # ffffffffc0202440 <etext+0x84>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02000aa:	00008597          	auipc	a1,0x8
ffffffffc02000ae:	86558593          	addi	a1,a1,-1947 # ffffffffc020790f <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	39450513          	addi	a0,a0,916 # ffffffffc0202460 <etext+0xa4>
ffffffffc02000d4:	0141                	addi	sp,sp,16
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:
ffffffffc02000d8:	00007517          	auipc	a0,0x7
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0207018 <free_area>
ffffffffc02000e0:	00007617          	auipc	a2,0x7
ffffffffc02000e4:	43060613          	addi	a2,a2,1072 # ffffffffc0207510 <end>
ffffffffc02000e8:	1141                	addi	sp,sp,-16
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
ffffffffc02000ee:	e406                	sd	ra,8(sp)
ffffffffc02000f0:	2ba020ef          	jal	ra,ffffffffc02023aa <memset>
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	39450513          	addi	a0,a0,916 # ffffffffc0202490 <etext+0xd4>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>
ffffffffc020010c:	69b000ef          	jal	ra,ffffffffc0200fa6 <pmm_init>
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc020011e:	401c                	lw	a5,0(s0)
ffffffffc0200120:	60a2                	ld	ra,8(sp)
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
ffffffffc020013c:	ec06                	sd	ra,24(sp)
ffffffffc020013e:	c602                	sw	zero,12(sp)
ffffffffc0200140:	60f010ef          	jal	ra,ffffffffc0201f4e <vprintfmt>
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
ffffffffc020014c:	711d                	addi	sp,sp,-96
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
ffffffffc0200172:	e41a                	sd	t1,8(sp)
ffffffffc0200174:	c202                	sw	zero,4(sp)
ffffffffc0200176:	5d9010ef          	jal	ra,ffffffffc0201f4e <vprintfmt>
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
ffffffffc02001c2:	00007317          	auipc	t1,0x7
ffffffffc02001c6:	2fe30313          	addi	t1,t1,766 # ffffffffc02074c0 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	2be50513          	addi	a0,a0,702 # ffffffffc02024b0 <etext+0xf4>
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
ffffffffc0200208:	00003517          	auipc	a0,0x3
ffffffffc020020c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0202e00 <etext+0xa44>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	0fa0206f          	j	ffffffffc0202316 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:
ffffffffc0200220:	7119                	addi	sp,sp,-128
ffffffffc0200222:	00002517          	auipc	a0,0x2
ffffffffc0200226:	2ae50513          	addi	a0,a0,686 # ffffffffc02024d0 <etext+0x114>
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
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200248:	00007597          	auipc	a1,0x7
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc0200250:	00002517          	auipc	a0,0x2
ffffffffc0200254:	29050513          	addi	a0,a0,656 # ffffffffc02024e0 <etext+0x124>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020025c:	00007417          	auipc	s0,0x7
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0207008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00002517          	auipc	a0,0x2
ffffffffc020026a:	28a50513          	addi	a0,a0,650 # ffffffffc02024f0 <etext+0x134>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	29250513          	addi	a0,a0,658 # ffffffffc0202508 <etext+0x14c>
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
ffffffffc020028a:	431c                	lw	a5,0(a4)
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
ffffffffc0200290:	6b41                	lui	s6,0x10
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002a6:	8df1                	and	a1,a1,a2
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
ffffffffc02002bc:	2581                	sext.w	a1,a1
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed89dd>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
ffffffffc02002ca:	4c81                	li	s9,0
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002f4:	8d71                	and	a0,a0,a2
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
ffffffffc0200302:	8e6d                	and	a2,a2,a1
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
ffffffffc020031c:	1402                	slli	s0,s0,0x20
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
ffffffffc0200320:	9001                	srli	s0,s0,0x20
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200326:	943a                	add	s0,s0,a4
ffffffffc0200328:	9a3a                	add	s4,s4,a4
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
ffffffffc020032e:	4b8d                	li	s7,3
ffffffffc0200330:	00002917          	auipc	s2,0x2
ffffffffc0200334:	22890913          	addi	s2,s2,552 # ffffffffc0202558 <etext+0x19c>
ffffffffc0200338:	49bd                	li	s3,15
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
ffffffffc020033e:	00002497          	auipc	s1,0x2
ffffffffc0200342:	21248493          	addi	s1,s1,530 # ffffffffc0202550 <etext+0x194>
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
ffffffffc0200392:	00002517          	auipc	a0,0x2
ffffffffc0200396:	23e50513          	addi	a0,a0,574 # ffffffffc02025d0 <etext+0x214>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	26a50513          	addi	a0,a0,618 # ffffffffc0202608 <etext+0x24c>
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
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
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
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	14a50513          	addi	a0,a0,330 # ffffffffc0202528 <etext+0x16c>
ffffffffc02003e6:	6109                	addi	sp,sp,128
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	745010ef          	jal	ra,ffffffffc0202330 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
ffffffffc02003f8:	2a01                	sext.w	s4,s4
ffffffffc02003fa:	78b010ef          	jal	ra,ffffffffc0202384 <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
ffffffffc0200400:	4c85                	li	s9,1
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
ffffffffc020042e:	01877733          	and	a4,a4,s8
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
ffffffffc020047a:	01857533          	and	a0,a0,s8
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	6d7010ef          	jal	ra,ffffffffc0202366 <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
ffffffffc02004a4:	00002517          	auipc	a0,0x2
ffffffffc02004a8:	0bc50513          	addi	a0,a0,188 # ffffffffc0202560 <etext+0x1a4>
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
ffffffffc02004e8:	01837333          	and	t1,t1,s8
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
ffffffffc020052a:	01877c33          	and	s8,a4,s8
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
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
ffffffffc020055c:	1782                	slli	a5,a5,0x20
ffffffffc020055e:	9301                	srli	a4,a4,0x20
ffffffffc0200560:	1402                	slli	s0,s0,0x20
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00002517          	auipc	a0,0x2
ffffffffc0200576:	00e50513          	addi	a0,a0,14 # ffffffffc0202580 <etext+0x1c4>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00002517          	auipc	a0,0x2
ffffffffc0200588:	01450513          	addi	a0,a0,20 # ffffffffc0202598 <etext+0x1dc>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00002517          	auipc	a0,0x2
ffffffffc020059a:	02250513          	addi	a0,a0,34 # ffffffffc02025b8 <etext+0x1fc>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02005a2:	00002517          	auipc	a0,0x2
ffffffffc02005a6:	06650513          	addi	a0,a0,102 # ffffffffc0202608 <etext+0x24c>
ffffffffc02005aa:	00007797          	auipc	a5,0x7
ffffffffc02005ae:	f087bf23          	sd	s0,-226(a5) # ffffffffc02074c8 <memory_base>
ffffffffc02005b2:	00007797          	auipc	a5,0x7
ffffffffc02005b6:	f167bf23          	sd	s6,-226(a5) # ffffffffc02074d0 <memory_size>
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:
ffffffffc02005bc:	00007517          	auipc	a0,0x7
ffffffffc02005c0:	f0c53503          	ld	a0,-244(a0) # ffffffffc02074c8 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:
ffffffffc02005c6:	00007517          	auipc	a0,0x7
ffffffffc02005ca:	f0a53503          	ld	a0,-246(a0) # ffffffffc02074d0 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <buddy_init>:
    return order;
}

// 初始化伙伴系统
static void buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc02005d0:	00007797          	auipc	a5,0x7
ffffffffc02005d4:	a4878793          	addi	a5,a5,-1464 # ffffffffc0207018 <free_area>
ffffffffc02005d8:	00007717          	auipc	a4,0x7
ffffffffc02005dc:	ba870713          	addi	a4,a4,-1112 # ffffffffc0207180 <kmem_caches>
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
ffffffffc02005ee:	00007797          	auipc	a5,0x7
ffffffffc02005f2:	ee07b523          	sd	zero,-278(a5) # ffffffffc02074d8 <nr_free>
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
ffffffffc02005fa:	00007f17          	auipc	t5,0x7
ffffffffc02005fe:	edef0f13          	addi	t5,t5,-290 # ffffffffc02074d8 <nr_free>
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
ffffffffc0200624:	00007697          	auipc	a3,0x7
ffffffffc0200628:	9f468693          	addi	a3,a3,-1548 # ffffffffc0207018 <free_area>
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
ffffffffc02006f0:	00007797          	auipc	a5,0x7
ffffffffc02006f4:	92878793          	addi	a5,a5,-1752 # ffffffffc0207018 <free_area>
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
    free_area[order].nr_free++;
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200716:	00007517          	auipc	a0,0x7
ffffffffc020071a:	dc253503          	ld	a0,-574(a0) # ffffffffc02074d8 <nr_free>
ffffffffc020071e:	8082                	ret

ffffffffc0200720 <show_buddy_info>:
        }
    }
    return -1;
}

static void show_buddy_info(const char *label) {
ffffffffc0200720:	7179                	addi	sp,sp,-48
ffffffffc0200722:	85aa                	mv	a1,a0
    cprintf("   --- %s ---\n", label);
ffffffffc0200724:	00002517          	auipc	a0,0x2
ffffffffc0200728:	efc50513          	addi	a0,a0,-260 # ffffffffc0202620 <etext+0x264>
static void show_buddy_info(const char *label) {
ffffffffc020072c:	f022                	sd	s0,32(sp)
ffffffffc020072e:	ec26                	sd	s1,24(sp)
ffffffffc0200730:	e84a                	sd	s2,16(sp)
ffffffffc0200732:	e44e                	sd	s3,8(sp)
ffffffffc0200734:	e052                	sd	s4,0(sp)
ffffffffc0200736:	f406                	sd	ra,40(sp)
ffffffffc0200738:	00007497          	auipc	s1,0x7
ffffffffc020073c:	8f048493          	addi	s1,s1,-1808 # ffffffffc0207028 <free_area+0x10>
    cprintf("   --- %s ---\n", label);
ffffffffc0200740:	a0dff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200744:	4401                	li	s0,0
        if (free_area[i].nr_free > 0) {
            cprintf("     阶数 %2d (大小 %4d): %d 个空闲块\n", i, 1 << i, free_area[i].nr_free);
ffffffffc0200746:	4a05                	li	s4,1
ffffffffc0200748:	00002997          	auipc	s3,0x2
ffffffffc020074c:	ee898993          	addi	s3,s3,-280 # ffffffffc0202630 <etext+0x274>
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200750:	493d                	li	s2,15
ffffffffc0200752:	a021                	j	ffffffffc020075a <show_buddy_info+0x3a>
ffffffffc0200754:	2405                	addiw	s0,s0,1
ffffffffc0200756:	01240e63          	beq	s0,s2,ffffffffc0200772 <show_buddy_info+0x52>
        if (free_area[i].nr_free > 0) {
ffffffffc020075a:	4094                	lw	a3,0(s1)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc020075c:	04e1                	addi	s1,s1,24
        if (free_area[i].nr_free > 0) {
ffffffffc020075e:	dafd                	beqz	a3,ffffffffc0200754 <show_buddy_info+0x34>
            cprintf("     阶数 %2d (大小 %4d): %d 个空闲块\n", i, 1 << i, free_area[i].nr_free);
ffffffffc0200760:	008a163b          	sllw	a2,s4,s0
ffffffffc0200764:	85a2                	mv	a1,s0
ffffffffc0200766:	854e                	mv	a0,s3
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200768:	2405                	addiw	s0,s0,1
            cprintf("     阶数 %2d (大小 %4d): %d 个空闲块\n", i, 1 << i, free_area[i].nr_free);
ffffffffc020076a:	9e3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc020076e:	ff2416e3          	bne	s0,s2,ffffffffc020075a <show_buddy_info+0x3a>
        }
    }
    cprintf("   --------------------------------\n");
}
ffffffffc0200772:	7402                	ld	s0,32(sp)
ffffffffc0200774:	70a2                	ld	ra,40(sp)
ffffffffc0200776:	64e2                	ld	s1,24(sp)
ffffffffc0200778:	6942                	ld	s2,16(sp)
ffffffffc020077a:	69a2                	ld	s3,8(sp)
ffffffffc020077c:	6a02                	ld	s4,0(sp)
    cprintf("   --------------------------------\n");
ffffffffc020077e:	00002517          	auipc	a0,0x2
ffffffffc0200782:	ee250513          	addi	a0,a0,-286 # ffffffffc0202660 <etext+0x2a4>
}
ffffffffc0200786:	6145                	addi	sp,sp,48
    cprintf("   --------------------------------\n");
ffffffffc0200788:	b2d1                	j	ffffffffc020014c <cprintf>

ffffffffc020078a <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc020078a:	1141                	addi	sp,sp,-16
ffffffffc020078c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020078e:	16058063          	beqz	a1,ffffffffc02008ee <buddy_free_pages+0x164>
    uint32_t order = base->property;
ffffffffc0200792:	4914                	lw	a3,16(a0)
    nr_free += (1 << order);
ffffffffc0200794:	00007597          	auipc	a1,0x7
ffffffffc0200798:	d4458593          	addi	a1,a1,-700 # ffffffffc02074d8 <nr_free>
ffffffffc020079c:	4785                	li	a5,1
ffffffffc020079e:	00d797bb          	sllw	a5,a5,a3
ffffffffc02007a2:	6198                	ld	a4,0(a1)
    for (; p != base + (1 << order); p++) {
ffffffffc02007a4:	00279613          	slli	a2,a5,0x2
ffffffffc02007a8:	963e                	add	a2,a2,a5
ffffffffc02007aa:	060e                	slli	a2,a2,0x3
    nr_free += (1 << order);
ffffffffc02007ac:	97ba                	add	a5,a5,a4
ffffffffc02007ae:	e19c                	sd	a5,0(a1)
    for (; p != base + (1 << order); p++) {
ffffffffc02007b0:	962a                	add	a2,a2,a0
ffffffffc02007b2:	00c50e63          	beq	a0,a2,ffffffffc02007ce <buddy_free_pages+0x44>
ffffffffc02007b6:	87aa                	mv	a5,a0
        assert(!PageReserved(p));
ffffffffc02007b8:	6798                	ld	a4,8(a5)
ffffffffc02007ba:	8b05                	andi	a4,a4,1
ffffffffc02007bc:	ef6d                	bnez	a4,ffffffffc02008b6 <buddy_free_pages+0x12c>
        p->flags = 0;
ffffffffc02007be:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02007c2:	0007a023          	sw	zero,0(a5)
    for (; p != base + (1 << order); p++) {
ffffffffc02007c6:	02878793          	addi	a5,a5,40
ffffffffc02007ca:	fef617e3          	bne	a2,a5,ffffffffc02007b8 <buddy_free_pages+0x2e>
    while (order < MAX_ORDER - 1) {
ffffffffc02007ce:	47b5                	li	a5,13
ffffffffc02007d0:	00007f97          	auipc	t6,0x7
ffffffffc02007d4:	848f8f93          	addi	t6,t6,-1976 # ffffffffc0207018 <free_area>
ffffffffc02007d8:	0ad7e063          	bltu	a5,a3,ffffffffc0200878 <buddy_free_pages+0xee>
ffffffffc02007dc:	02069793          	slli	a5,a3,0x20
ffffffffc02007e0:	9381                	srli	a5,a5,0x20
ffffffffc02007e2:	00179613          	slli	a2,a5,0x1
ffffffffc02007e6:	963e                	add	a2,a2,a5
ffffffffc02007e8:	00007f97          	auipc	t6,0x7
ffffffffc02007ec:	830f8f93          	addi	t6,t6,-2000 # ffffffffc0207018 <free_area>
ffffffffc02007f0:	060e                	slli	a2,a2,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02007f2:	00007897          	auipc	a7,0x7
ffffffffc02007f6:	cf68b883          	ld	a7,-778(a7) # ffffffffc02074e8 <pages>
ffffffffc02007fa:	00003817          	auipc	a6,0x3
ffffffffc02007fe:	13683803          	ld	a6,310(a6) # ffffffffc0203930 <nbase>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200802:	00007e97          	auipc	t4,0x7
ffffffffc0200806:	cdeebe83          	ld	t4,-802(t4) # ffffffffc02074e0 <npage>
ffffffffc020080a:	967e                	add	a2,a2,t6
ffffffffc020080c:	00003e17          	auipc	t3,0x3
ffffffffc0200810:	11ce3e03          	ld	t3,284(t3) # ffffffffc0203928 <error_string+0x38>
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200814:	4305                	li	t1,1
    while (order < MAX_ORDER - 1) {
ffffffffc0200816:	4f39                	li	t5,14
ffffffffc0200818:	a805                	j	ffffffffc0200848 <buddy_free_pages+0xbe>
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc020081a:	4b8c                	lw	a1,16(a5)
ffffffffc020081c:	04d59e63          	bne	a1,a3,ffffffffc0200878 <buddy_free_pages+0xee>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200820:	0187b383          	ld	t2,24(a5)
ffffffffc0200824:	0207b283          	ld	t0,32(a5)
        free_area[order].nr_free--;
ffffffffc0200828:	4a0c                	lw	a1,16(a2)
        ClearPageProperty(buddy); // 伙伴不再是空闲块头
ffffffffc020082a:	9b75                	andi	a4,a4,-3
    prev->next = next;
ffffffffc020082c:	0053b423          	sd	t0,8(t2)
    next->prev = prev;
ffffffffc0200830:	0072b023          	sd	t2,0(t0)
        free_area[order].nr_free--;
ffffffffc0200834:	35fd                	addiw	a1,a1,-1
ffffffffc0200836:	ca0c                	sw	a1,16(a2)
        ClearPageProperty(buddy); // 伙伴不再是空闲块头
ffffffffc0200838:	e798                	sd	a4,8(a5)
        if (buddy < base) {
ffffffffc020083a:	00a7f363          	bgeu	a5,a0,ffffffffc0200840 <buddy_free_pages+0xb6>
ffffffffc020083e:	853e                	mv	a0,a5
        order++;
ffffffffc0200840:	2685                	addiw	a3,a3,1
    while (order < MAX_ORDER - 1) {
ffffffffc0200842:	0661                	addi	a2,a2,24
ffffffffc0200844:	03e68a63          	beq	a3,t5,ffffffffc0200878 <buddy_free_pages+0xee>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200848:	41150733          	sub	a4,a0,a7
ffffffffc020084c:	870d                	srai	a4,a4,0x3
ffffffffc020084e:	03c70733          	mul	a4,a4,t3
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200852:	00d317bb          	sllw	a5,t1,a3
ffffffffc0200856:	9742                	add	a4,a4,a6
ffffffffc0200858:	8fb9                	xor	a5,a5,a4
        struct Page *buddy = pa2page(buddy_idx * PGSIZE);
ffffffffc020085a:	07b2                	slli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020085c:	83b1                	srli	a5,a5,0xc
ffffffffc020085e:	07d7fc63          	bgeu	a5,t4,ffffffffc02008d6 <buddy_free_pages+0x14c>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200862:	410787b3          	sub	a5,a5,a6
ffffffffc0200866:	00279713          	slli	a4,a5,0x2
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	078e                	slli	a5,a5,0x3
ffffffffc020086e:	97c6                	add	a5,a5,a7
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc0200870:	6798                	ld	a4,8(a5)
ffffffffc0200872:	00277593          	andi	a1,a4,2
ffffffffc0200876:	f1d5                	bnez	a1,ffffffffc020081a <buddy_free_pages+0x90>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200878:	02069713          	slli	a4,a3,0x20
ffffffffc020087c:	9301                	srli	a4,a4,0x20
ffffffffc020087e:	00171793          	slli	a5,a4,0x1
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	078e                	slli	a5,a5,0x3
    SetPageProperty(base); // 标记它是一个新的空闲块头
ffffffffc0200886:	6518                	ld	a4,8(a0)
ffffffffc0200888:	9fbe                	add	t6,t6,a5
ffffffffc020088a:	008fb603          	ld	a2,8(t6)
ffffffffc020088e:	00276793          	ori	a5,a4,2
ffffffffc0200892:	e51c                	sd	a5,8(a0)
    base->property = order;
ffffffffc0200894:	c914                	sw	a3,16(a0)
    free_area[order].nr_free++;
ffffffffc0200896:	010fa783          	lw	a5,16(t6)
    list_add(&(free_area[order].free_list), &(base->page_link));
ffffffffc020089a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020089e:	e218                	sd	a4,0(a2)
ffffffffc02008a0:	00efb423          	sd	a4,8(t6)
}
ffffffffc02008a4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02008a6:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc02008a8:	01f53c23          	sd	t6,24(a0)
    free_area[order].nr_free++;
ffffffffc02008ac:	2785                	addiw	a5,a5,1
ffffffffc02008ae:	00ffa823          	sw	a5,16(t6)
}
ffffffffc02008b2:	0141                	addi	sp,sp,16
ffffffffc02008b4:	8082                	ret
        assert(!PageReserved(p));
ffffffffc02008b6:	00002697          	auipc	a3,0x2
ffffffffc02008ba:	e0a68693          	addi	a3,a3,-502 # ffffffffc02026c0 <etext+0x304>
ffffffffc02008be:	00002617          	auipc	a2,0x2
ffffffffc02008c2:	dd260613          	addi	a2,a2,-558 # ffffffffc0202690 <etext+0x2d4>
ffffffffc02008c6:	08500593          	li	a1,133
ffffffffc02008ca:	00002517          	auipc	a0,0x2
ffffffffc02008ce:	dde50513          	addi	a0,a0,-546 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc02008d2:	8f1ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02008d6:	00002617          	auipc	a2,0x2
ffffffffc02008da:	e0260613          	addi	a2,a2,-510 # ffffffffc02026d8 <etext+0x31c>
ffffffffc02008de:	06a00593          	li	a1,106
ffffffffc02008e2:	00002517          	auipc	a0,0x2
ffffffffc02008e6:	e1650513          	addi	a0,a0,-490 # ffffffffc02026f8 <etext+0x33c>
ffffffffc02008ea:	8d9ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02008ee:	00002697          	auipc	a3,0x2
ffffffffc02008f2:	d9a68693          	addi	a3,a3,-614 # ffffffffc0202688 <etext+0x2cc>
ffffffffc02008f6:	00002617          	auipc	a2,0x2
ffffffffc02008fa:	d9a60613          	addi	a2,a2,-614 # ffffffffc0202690 <etext+0x2d4>
ffffffffc02008fe:	07900593          	li	a1,121
ffffffffc0200902:	00002517          	auipc	a0,0x2
ffffffffc0200906:	da650513          	addi	a0,a0,-602 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc020090a:	8b9ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020090e <buddy_check>:

static void buddy_check(void) {
ffffffffc020090e:	7115                	addi	sp,sp,-224
ffffffffc0200910:	e1ca                	sd	s2,192(sp)
    cprintf("=== 开始伙伴系统测试 ===\n");
ffffffffc0200912:	00002517          	auipc	a0,0x2
ffffffffc0200916:	df650513          	addi	a0,a0,-522 # ffffffffc0202708 <etext+0x34c>
    return nr_free;
ffffffffc020091a:	00007917          	auipc	s2,0x7
ffffffffc020091e:	bbe90913          	addi	s2,s2,-1090 # ffffffffc02074d8 <nr_free>
static void buddy_check(void) {
ffffffffc0200922:	ed86                	sd	ra,216(sp)
ffffffffc0200924:	e9a2                	sd	s0,208(sp)
ffffffffc0200926:	fd4e                	sd	s3,184(sp)
ffffffffc0200928:	e5a6                	sd	s1,200(sp)
ffffffffc020092a:	f952                	sd	s4,176(sp)
ffffffffc020092c:	f556                	sd	s5,168(sp)
    cprintf("=== 开始伙伴系统测试 ===\n");
ffffffffc020092e:	81fff0ef          	jal	ra,ffffffffc020014c <cprintf>
    return nr_free;
ffffffffc0200932:	00093983          	ld	s3,0(s2)
    size_t initial_free = buddy_nr_free_pages();
    cprintf("初始空闲页数: %d\n\n", initial_free);
ffffffffc0200936:	00002517          	auipc	a0,0x2
ffffffffc020093a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0202730 <etext+0x374>
ffffffffc020093e:	85ce                	mv	a1,s3
ffffffffc0200940:	80dff0ef          	jal	ra,ffffffffc020014c <cprintf>

    
    // 1. 测试简单请求和释放操作
    
    cprintf("1. 简单的分配和释放操作\n");
ffffffffc0200944:	00002517          	auipc	a0,0x2
ffffffffc0200948:	e0c50513          	addi	a0,a0,-500 # ffffffffc0202750 <etext+0x394>
ffffffffc020094c:	801ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc0200950:	00002517          	auipc	a0,0x2
ffffffffc0200954:	e2850513          	addi	a0,a0,-472 # ffffffffc0202778 <etext+0x3bc>
ffffffffc0200958:	dc9ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    struct Page *p1 = alloc_pages(16);
ffffffffc020095c:	4541                	li	a0,16
ffffffffc020095e:	630000ef          	jal	ra,ffffffffc0200f8e <alloc_pages>
ffffffffc0200962:	842a                	mv	s0,a0
    show_buddy_info("分配 16 页后");
ffffffffc0200964:	00002517          	auipc	a0,0x2
ffffffffc0200968:	e2450513          	addi	a0,a0,-476 # ffffffffc0202788 <etext+0x3cc>
ffffffffc020096c:	db5ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(p1 != NULL);
ffffffffc0200970:	34040563          	beqz	s0,ffffffffc0200cba <buddy_check+0x3ac>
    assert(buddy_nr_free_pages() == initial_free - 16);
ffffffffc0200974:	00093783          	ld	a5,0(s2)
ffffffffc0200978:	ff098713          	addi	a4,s3,-16
ffffffffc020097c:	4cf71f63          	bne	a4,a5,ffffffffc0200e5a <buddy_check+0x54c>
    cprintf("   - 已分配 16 页。通过。\n");
ffffffffc0200980:	00002517          	auipc	a0,0x2
ffffffffc0200984:	e6050513          	addi	a0,a0,-416 # ffffffffc02027e0 <etext+0x424>
ffffffffc0200988:	fc4ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    free_pages(p1, 16);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	45c1                	li	a1,16
ffffffffc0200990:	60a000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    show_buddy_info("释放 16 页后");
ffffffffc0200994:	00002517          	auipc	a0,0x2
ffffffffc0200998:	e7450513          	addi	a0,a0,-396 # ffffffffc0202808 <etext+0x44c>
ffffffffc020099c:	d85ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc02009a0:	00093403          	ld	s0,0(s2)
ffffffffc02009a4:	49341b63          	bne	s0,s3,ffffffffc0200e3a <buddy_check+0x52c>
    cprintf("   - 已释放 16 页。通过。\n");
ffffffffc02009a8:	00002517          	auipc	a0,0x2
ffffffffc02009ac:	ea050513          	addi	a0,a0,-352 # ffffffffc0202848 <etext+0x48c>
ffffffffc02009b0:	f9cff0ef          	jal	ra,ffffffffc020014c <cprintf>


    
    // 2. 测试复杂请求和释放操作 (碎片化与合并)
    
    cprintf("2. 复杂的分配和释放操作\n");
ffffffffc02009b4:	00002517          	auipc	a0,0x2
ffffffffc02009b8:	ebc50513          	addi	a0,a0,-324 # ffffffffc0202870 <etext+0x4b4>
ffffffffc02009bc:	f90ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc02009c0:	00002517          	auipc	a0,0x2
ffffffffc02009c4:	db850513          	addi	a0,a0,-584 # ffffffffc0202778 <etext+0x3bc>
ffffffffc02009c8:	d59ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    struct Page *p2 = alloc_pages(3);  // 消耗4页
ffffffffc02009cc:	450d                	li	a0,3
ffffffffc02009ce:	5c0000ef          	jal	ra,ffffffffc0200f8e <alloc_pages>
ffffffffc02009d2:	84aa                	mv	s1,a0
    show_buddy_info("分配 3 页后");
ffffffffc02009d4:	00002517          	auipc	a0,0x2
ffffffffc02009d8:	ec450513          	addi	a0,a0,-316 # ffffffffc0202898 <etext+0x4dc>
ffffffffc02009dc:	d45ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    struct Page *p3 = alloc_pages(10); // 消耗16页
ffffffffc02009e0:	4529                	li	a0,10
ffffffffc02009e2:	5ac000ef          	jal	ra,ffffffffc0200f8e <alloc_pages>
ffffffffc02009e6:	8a2a                	mv	s4,a0
    show_buddy_info("分配 10 页后");
ffffffffc02009e8:	00002517          	auipc	a0,0x2
ffffffffc02009ec:	ec050513          	addi	a0,a0,-320 # ffffffffc02028a8 <etext+0x4ec>
ffffffffc02009f0:	d31ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(p2 != NULL && p3 != NULL);
ffffffffc02009f4:	42048363          	beqz	s1,ffffffffc0200e1a <buddy_check+0x50c>
ffffffffc02009f8:	420a0163          	beqz	s4,ffffffffc0200e1a <buddy_check+0x50c>
    assert(buddy_nr_free_pages() == initial_free - 4 - 16);
ffffffffc02009fc:	00093783          	ld	a5,0(s2)
ffffffffc0200a00:	fec40713          	addi	a4,s0,-20
ffffffffc0200a04:	3ef71b63          	bne	a4,a5,ffffffffc0200dfa <buddy_check+0x4ec>
    cprintf("   - 已分配 3 页块 (实际消耗 4 页) 和 10 页块 (实际消耗 16 页)。通过。\n");
ffffffffc0200a08:	00002517          	auipc	a0,0x2
ffffffffc0200a0c:	f0850513          	addi	a0,a0,-248 # ffffffffc0202910 <etext+0x554>
ffffffffc0200a10:	f3cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 逆序释放,测试合并逻辑
    free_pages(p3, 10);
ffffffffc0200a14:	45a9                	li	a1,10
ffffffffc0200a16:	8552                	mv	a0,s4
ffffffffc0200a18:	582000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    show_buddy_info("释放 10 页后");
ffffffffc0200a1c:	00002517          	auipc	a0,0x2
ffffffffc0200a20:	f5450513          	addi	a0,a0,-172 # ffffffffc0202970 <etext+0x5b4>
ffffffffc0200a24:	cfdff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free - 4);
ffffffffc0200a28:	00093783          	ld	a5,0(s2)
ffffffffc0200a2c:	ffc40713          	addi	a4,s0,-4
ffffffffc0200a30:	3af71563          	bne	a4,a5,ffffffffc0200dda <buddy_check+0x4cc>
    cprintf("   - 已释放 10 页块。通过。\n");
ffffffffc0200a34:	00002517          	auipc	a0,0x2
ffffffffc0200a38:	f8450513          	addi	a0,a0,-124 # ffffffffc02029b8 <etext+0x5fc>
ffffffffc0200a3c:	f10ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    free_pages(p2, 3);
ffffffffc0200a40:	458d                	li	a1,3
ffffffffc0200a42:	8526                	mv	a0,s1
ffffffffc0200a44:	556000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    show_buddy_info("释放 3 页后");
ffffffffc0200a48:	00002517          	auipc	a0,0x2
ffffffffc0200a4c:	f9850513          	addi	a0,a0,-104 # ffffffffc02029e0 <etext+0x624>
ffffffffc0200a50:	cd1ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200a54:	00093783          	ld	a5,0(s2)
ffffffffc0200a58:	36879163          	bne	a5,s0,ffffffffc0200dba <buddy_check+0x4ac>
    cprintf("   - 已释放 3 页块。通过。\n");
ffffffffc0200a5c:	00002517          	auipc	a0,0x2
ffffffffc0200a60:	f9450513          	addi	a0,a0,-108 # ffffffffc02029f0 <etext+0x634>
ffffffffc0200a64:	ee8ff0ef          	jal	ra,ffffffffc020014c <cprintf>


    
    // 3. 测试请求和释放最小单元操作 (可视化分割与合并)

    cprintf("3. 最小单元操作 \n");
ffffffffc0200a68:	00002517          	auipc	a0,0x2
ffffffffc0200a6c:	fb050513          	addi	a0,a0,-80 # ffffffffc0202a18 <etext+0x65c>
ffffffffc0200a70:	edcff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc0200a74:	00002517          	auipc	a0,0x2
ffffffffc0200a78:	d0450513          	addi	a0,a0,-764 # ffffffffc0202778 <etext+0x3bc>
ffffffffc0200a7c:	ca5ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>

    // 分配一个最小单元
    struct Page *p_min1 = alloc_pages(1);
ffffffffc0200a80:	4505                	li	a0,1
ffffffffc0200a82:	50c000ef          	jal	ra,ffffffffc0200f8e <alloc_pages>
ffffffffc0200a86:	84aa                	mv	s1,a0
    struct Page *p_min2 = alloc_pages(1);
ffffffffc0200a88:	4505                	li	a0,1
ffffffffc0200a8a:	504000ef          	jal	ra,ffffffffc0200f8e <alloc_pages>
ffffffffc0200a8e:	842a                	mv	s0,a0
    assert(p_min1 != NULL && p_min2 != NULL);
ffffffffc0200a90:	30048563          	beqz	s1,ffffffffc0200d9a <buddy_check+0x48c>
ffffffffc0200a94:	30050363          	beqz	a0,ffffffffc0200d9a <buddy_check+0x48c>
    cprintf("   - 已分配两次 1 页。通过。\n");
ffffffffc0200a98:	00002517          	auipc	a0,0x2
ffffffffc0200a9c:	fc050513          	addi	a0,a0,-64 # ffffffffc0202a58 <etext+0x69c>
ffffffffc0200aa0:	eacff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("分配两次 1 页后");
ffffffffc0200aa4:	00002517          	auipc	a0,0x2
ffffffffc0200aa8:	fdc50513          	addi	a0,a0,-36 # ffffffffc0202a80 <etext+0x6c4>
ffffffffc0200aac:	c75ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>

    // 释放这个最小单元
    free_pages(p_min1, 1);
ffffffffc0200ab0:	4585                	li	a1,1
ffffffffc0200ab2:	8526                	mv	a0,s1
ffffffffc0200ab4:	4e6000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    free_pages(p_min2, 1);
ffffffffc0200ab8:	4585                	li	a1,1
ffffffffc0200aba:	8522                	mv	a0,s0
ffffffffc0200abc:	4de000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    cprintf("   - 已释放两次 1 页。通过。\n");
ffffffffc0200ac0:	00002517          	auipc	a0,0x2
ffffffffc0200ac4:	fd850513          	addi	a0,a0,-40 # ffffffffc0202a98 <etext+0x6dc>
ffffffffc0200ac8:	e84ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("释放两次 1 页后");
ffffffffc0200acc:	00002517          	auipc	a0,0x2
ffffffffc0200ad0:	ff450513          	addi	a0,a0,-12 # ffffffffc0202ac0 <etext+0x704>
ffffffffc0200ad4:	c4dff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    
    // 检查内存是否完全恢复
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200ad8:	00093783          	ld	a5,0(s2)
ffffffffc0200adc:	29379f63          	bne	a5,s3,ffffffffc0200d7a <buddy_check+0x46c>
    cprintf("   - 测试通过: 最小单元操作正确。\n\n");
ffffffffc0200ae0:	00002517          	auipc	a0,0x2
ffffffffc0200ae4:	ff850513          	addi	a0,a0,-8 # ffffffffc0202ad8 <etext+0x71c>
ffffffffc0200ae8:	e64ff0ef          	jal	ra,ffffffffc020014c <cprintf>


    
    // 4. 测试请求和释放最大单元操作
    
    cprintf("4. 最大单元操作\n");
ffffffffc0200aec:	00002517          	auipc	a0,0x2
ffffffffc0200af0:	02450513          	addi	a0,a0,36 # ffffffffc0202b10 <etext+0x754>
ffffffffc0200af4:	e58ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200af8:	00006417          	auipc	s0,0x6
ffffffffc0200afc:	67040413          	addi	s0,s0,1648 # ffffffffc0207168 <free_area+0x150>
ffffffffc0200b00:	44b9                	li	s1,14
    cprintf("4. 最大单元操作\n");
ffffffffc0200b02:	87a2                	mv	a5,s0
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200b04:	56fd                	li	a3,-1
        if (!list_empty(&(free_area[i].free_list))) {
ffffffffc0200b06:	6798                	ld	a4,8(a5)
ffffffffc0200b08:	16f71563          	bne	a4,a5,ffffffffc0200c72 <buddy_check+0x364>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200b0c:	34fd                	addiw	s1,s1,-1
ffffffffc0200b0e:	17a1                	addi	a5,a5,-24
ffffffffc0200b10:	fed49be3          	bne	s1,a3,ffffffffc0200b06 <buddy_check+0x1f8>
ffffffffc0200b14:	4a81                	li	s5,0
    int max_order = find_max_order();
    show_buddy_info("初始状态");
ffffffffc0200b16:	00002517          	auipc	a0,0x2
ffffffffc0200b1a:	c6250513          	addi	a0,a0,-926 # ffffffffc0202778 <etext+0x3bc>
ffffffffc0200b1e:	c03ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    int max_block_size = (1 << max_order);
    // 分配这个最大的块
    struct Page *p_max = alloc_pages(max_block_size);
ffffffffc0200b22:	8556                	mv	a0,s5
ffffffffc0200b24:	46a000ef          	jal	ra,ffffffffc0200f8e <alloc_pages>
ffffffffc0200b28:	8a2a                	mv	s4,a0
    show_buddy_info("分配最大块后");
ffffffffc0200b2a:	00002517          	auipc	a0,0x2
ffffffffc0200b2e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0202b28 <etext+0x76c>
ffffffffc0200b32:	befff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(p_max != NULL);
ffffffffc0200b36:	220a0263          	beqz	s4,ffffffffc0200d5a <buddy_check+0x44c>
    cprintf("   - 已分配最大块。通过。\n");
ffffffffc0200b3a:	00002517          	auipc	a0,0x2
ffffffffc0200b3e:	01650513          	addi	a0,a0,22 # ffffffffc0202b50 <etext+0x794>
ffffffffc0200b42:	e0aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(buddy_nr_free_pages() == initial_free - max_block_size);
ffffffffc0200b46:	00093783          	ld	a5,0(s2)
ffffffffc0200b4a:	41598733          	sub	a4,s3,s5
ffffffffc0200b4e:	1ef71663          	bne	a4,a5,ffffffffc0200d3a <buddy_check+0x42c>

    // 释放这个最大的块
    free_pages(p_max, max_block_size);
ffffffffc0200b52:	85d6                	mv	a1,s5
ffffffffc0200b54:	8552                	mv	a0,s4
ffffffffc0200b56:	444000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    show_buddy_info("释放最大块后");
ffffffffc0200b5a:	00002517          	auipc	a0,0x2
ffffffffc0200b5e:	05650513          	addi	a0,a0,86 # ffffffffc0202bb0 <etext+0x7f4>
ffffffffc0200b62:	bbfff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200b66:	00093783          	ld	a5,0(s2)
ffffffffc0200b6a:	1af99863          	bne	s3,a5,ffffffffc0200d1a <buddy_check+0x40c>
    cprintf("   - 已释放最大块。通过。\n");
ffffffffc0200b6e:	00002517          	auipc	a0,0x2
ffffffffc0200b72:	05a50513          	addi	a0,a0,90 # ffffffffc0202bc8 <etext+0x80c>
ffffffffc0200b76:	dd6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200b7a:	47b9                	li	a5,14
ffffffffc0200b7c:	56fd                	li	a3,-1
        if (!list_empty(&(free_area[i].free_list))) {
ffffffffc0200b7e:	6418                	ld	a4,8(s0)
ffffffffc0200b80:	00871663          	bne	a4,s0,ffffffffc0200b8c <buddy_check+0x27e>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200b84:	37fd                	addiw	a5,a5,-1
ffffffffc0200b86:	1421                	addi	s0,s0,-24
ffffffffc0200b88:	fed79be3          	bne	a5,a3,ffffffffc0200b7e <buddy_check+0x270>
    
    // 再次查找最大块,阶数应该和之前一样
    assert(find_max_order() == max_order);
ffffffffc0200b8c:	16f49763          	bne	s1,a5,ffffffffc0200cfa <buddy_check+0x3ec>
    cprintf("   - 验证通过: 最大块再次可用。\n");
ffffffffc0200b90:	00002517          	auipc	a0,0x2
ffffffffc0200b94:	08050513          	addi	a0,a0,128 # ffffffffc0202c10 <etext+0x854>
ffffffffc0200b98:	db4ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    cprintf("5. “穿插打孔”碎片化与合并\n");
ffffffffc0200b9c:	00002517          	auipc	a0,0x2
ffffffffc0200ba0:	0a450513          	addi	a0,a0,164 # ffffffffc0202c40 <etext+0x884>
ffffffffc0200ba4:	da8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc0200ba8:	00002517          	auipc	a0,0x2
ffffffffc0200bac:	bd050513          	addi	a0,a0,-1072 # ffffffffc0202778 <etext+0x3bc>
ffffffffc0200bb0:	b71ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    const int ALLOC_COUNT = 20;
    const int ALLOC_SIZE = 4;
    struct Page *allocated[ALLOC_COUNT];

    for (int i = 0; i < ALLOC_COUNT; i++) {
ffffffffc0200bb4:	1104                	addi	s1,sp,160
    show_buddy_info("初始状态");
ffffffffc0200bb6:	840a                	mv	s0,sp
        allocated[i] = alloc_pages(ALLOC_SIZE);
ffffffffc0200bb8:	4511                	li	a0,4
ffffffffc0200bba:	3d4000ef          	jal	ra,ffffffffc0200f8e <alloc_pages>
ffffffffc0200bbe:	e008                	sd	a0,0(s0)
        assert(allocated[i] != NULL);
ffffffffc0200bc0:	cd4d                	beqz	a0,ffffffffc0200c7a <buddy_check+0x36c>
    for (int i = 0; i < ALLOC_COUNT; i++) {
ffffffffc0200bc2:	0421                	addi	s0,s0,8
ffffffffc0200bc4:	fe941ae3          	bne	s0,s1,ffffffffc0200bb8 <buddy_check+0x2aa>
    }
    show_buddy_info("分配 20 个 4 页块后");
ffffffffc0200bc8:	00002517          	auipc	a0,0x2
ffffffffc0200bcc:	0c050513          	addi	a0,a0,192 # ffffffffc0202c88 <etext+0x8cc>
ffffffffc0200bd0:	b51ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    cprintf("   - 连续分配了 %d 个 %d 页大小的块. OK.\n", ALLOC_COUNT, ALLOC_SIZE);
ffffffffc0200bd4:	4611                	li	a2,4
ffffffffc0200bd6:	45d1                	li	a1,20
ffffffffc0200bd8:	00002517          	auipc	a0,0x2
ffffffffc0200bdc:	0d050513          	addi	a0,a0,208 # ffffffffc0202ca8 <etext+0x8ec>
ffffffffc0200be0:	d6cff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200be4:	840a                	mv	s0,sp
    // 释放偶数块，制造孔洞
    for (int i = 0; i < ALLOC_COUNT; i += 2) {
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200be6:	6008                	ld	a0,0(s0)
ffffffffc0200be8:	4591                	li	a1,4
    for (int i = 0; i < ALLOC_COUNT; i += 2) {
ffffffffc0200bea:	0441                	addi	s0,s0,16
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200bec:	3ae000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    for (int i = 0; i < ALLOC_COUNT; i += 2) {
ffffffffc0200bf0:	fe941be3          	bne	s0,s1,ffffffffc0200be6 <buddy_check+0x2d8>
    }
    show_buddy_info("释放所有偶数块后");
ffffffffc0200bf4:	00002517          	auipc	a0,0x2
ffffffffc0200bf8:	0ec50513          	addi	a0,a0,236 # ffffffffc0202ce0 <etext+0x924>
ffffffffc0200bfc:	b25ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    cprintf("   - 释放了所有偶数块，制造碎片. OK.\n");
ffffffffc0200c00:	00002517          	auipc	a0,0x2
ffffffffc0200c04:	10050513          	addi	a0,a0,256 # ffffffffc0202d00 <etext+0x944>
ffffffffc0200c08:	d44ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(buddy_nr_free_pages() == initial_free - (ALLOC_COUNT / 2) * ALLOC_SIZE);
ffffffffc0200c0c:	00093703          	ld	a4,0(s2)
ffffffffc0200c10:	fd898793          	addi	a5,s3,-40
ffffffffc0200c14:	0020                	addi	s0,sp,8
ffffffffc0200c16:	1124                	addi	s1,sp,168
ffffffffc0200c18:	08e79163          	bne	a5,a4,ffffffffc0200c9a <buddy_check+0x38c>

    // 释放奇数块，触发合并
    for (int i = 1; i < ALLOC_COUNT; i += 2) {
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200c1c:	6008                	ld	a0,0(s0)
ffffffffc0200c1e:	4591                	li	a1,4
    for (int i = 1; i < ALLOC_COUNT; i += 2) {
ffffffffc0200c20:	0441                	addi	s0,s0,16
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200c22:	378000ef          	jal	ra,ffffffffc0200f9a <free_pages>
    for (int i = 1; i < ALLOC_COUNT; i += 2) {
ffffffffc0200c26:	fe941be3          	bne	s0,s1,ffffffffc0200c1c <buddy_check+0x30e>
    }
    show_buddy_info("释放所有奇数块后");
ffffffffc0200c2a:	00002517          	auipc	a0,0x2
ffffffffc0200c2e:	15650513          	addi	a0,a0,342 # ffffffffc0202d80 <etext+0x9c4>
ffffffffc0200c32:	aefff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    cprintf("   - 释放了所有奇数块，触发合并. OK.\n");
ffffffffc0200c36:	00002517          	auipc	a0,0x2
ffffffffc0200c3a:	16a50513          	addi	a0,a0,362 # ffffffffc0202da0 <etext+0x9e4>
ffffffffc0200c3e:	d0eff0ef          	jal	ra,ffffffffc020014c <cprintf>

    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200c42:	00093783          	ld	a5,0(s2)
ffffffffc0200c46:	08f99a63          	bne	s3,a5,ffffffffc0200cda <buddy_check+0x3cc>
    cprintf("   - PASS: 碎片化合并测试正确.\n\n");
ffffffffc0200c4a:	00002517          	auipc	a0,0x2
ffffffffc0200c4e:	18e50513          	addi	a0,a0,398 # ffffffffc0202dd8 <etext+0xa1c>
ffffffffc0200c52:	cfaff0ef          	jal	ra,ffffffffc020014c <cprintf>

    cprintf("=== 伙伴系统测试完成 ===\n");
}
ffffffffc0200c56:	644e                	ld	s0,208(sp)
ffffffffc0200c58:	60ee                	ld	ra,216(sp)
ffffffffc0200c5a:	64ae                	ld	s1,200(sp)
ffffffffc0200c5c:	690e                	ld	s2,192(sp)
ffffffffc0200c5e:	79ea                	ld	s3,184(sp)
ffffffffc0200c60:	7a4a                	ld	s4,176(sp)
ffffffffc0200c62:	7aaa                	ld	s5,168(sp)
    cprintf("=== 伙伴系统测试完成 ===\n");
ffffffffc0200c64:	00002517          	auipc	a0,0x2
ffffffffc0200c68:	1a450513          	addi	a0,a0,420 # ffffffffc0202e08 <etext+0xa4c>
}
ffffffffc0200c6c:	612d                	addi	sp,sp,224
    cprintf("=== 伙伴系统测试完成 ===\n");
ffffffffc0200c6e:	cdeff06f          	j	ffffffffc020014c <cprintf>
    int max_block_size = (1 << max_order);
ffffffffc0200c72:	4a85                	li	s5,1
    struct Page *p_max = alloc_pages(max_block_size);
ffffffffc0200c74:	009a9abb          	sllw	s5,s5,s1
ffffffffc0200c78:	bd79                	j	ffffffffc0200b16 <buddy_check+0x208>
        assert(allocated[i] != NULL);
ffffffffc0200c7a:	00002697          	auipc	a3,0x2
ffffffffc0200c7e:	ff668693          	addi	a3,a3,-10 # ffffffffc0202c70 <etext+0x8b4>
ffffffffc0200c82:	00002617          	auipc	a2,0x2
ffffffffc0200c86:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200c8a:	12c00593          	li	a1,300
ffffffffc0200c8e:	00002517          	auipc	a0,0x2
ffffffffc0200c92:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200c96:	d2cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - (ALLOC_COUNT / 2) * ALLOC_SIZE);
ffffffffc0200c9a:	00002697          	auipc	a3,0x2
ffffffffc0200c9e:	09e68693          	addi	a3,a3,158 # ffffffffc0202d38 <etext+0x97c>
ffffffffc0200ca2:	00002617          	auipc	a2,0x2
ffffffffc0200ca6:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200caa:	13600593          	li	a1,310
ffffffffc0200cae:	00002517          	auipc	a0,0x2
ffffffffc0200cb2:	9fa50513          	addi	a0,a0,-1542 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200cb6:	d0cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL);
ffffffffc0200cba:	00002697          	auipc	a3,0x2
ffffffffc0200cbe:	ae668693          	addi	a3,a3,-1306 # ffffffffc02027a0 <etext+0x3e4>
ffffffffc0200cc2:	00002617          	auipc	a2,0x2
ffffffffc0200cc6:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200cca:	0d100593          	li	a1,209
ffffffffc0200cce:	00002517          	auipc	a0,0x2
ffffffffc0200cd2:	9da50513          	addi	a0,a0,-1574 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200cd6:	cecff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200cda:	00002697          	auipc	a3,0x2
ffffffffc0200cde:	b4668693          	addi	a3,a3,-1210 # ffffffffc0202820 <etext+0x464>
ffffffffc0200ce2:	00002617          	auipc	a2,0x2
ffffffffc0200ce6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200cea:	13f00593          	li	a1,319
ffffffffc0200cee:	00002517          	auipc	a0,0x2
ffffffffc0200cf2:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200cf6:	cccff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(find_max_order() == max_order);
ffffffffc0200cfa:	00002697          	auipc	a3,0x2
ffffffffc0200cfe:	ef668693          	addi	a3,a3,-266 # ffffffffc0202bf0 <etext+0x834>
ffffffffc0200d02:	00002617          	auipc	a2,0x2
ffffffffc0200d06:	98e60613          	addi	a2,a2,-1650 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200d0a:	12100593          	li	a1,289
ffffffffc0200d0e:	00002517          	auipc	a0,0x2
ffffffffc0200d12:	99a50513          	addi	a0,a0,-1638 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200d16:	cacff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200d1a:	00002697          	auipc	a3,0x2
ffffffffc0200d1e:	b0668693          	addi	a3,a3,-1274 # ffffffffc0202820 <etext+0x464>
ffffffffc0200d22:	00002617          	auipc	a2,0x2
ffffffffc0200d26:	96e60613          	addi	a2,a2,-1682 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200d2a:	11d00593          	li	a1,285
ffffffffc0200d2e:	00002517          	auipc	a0,0x2
ffffffffc0200d32:	97a50513          	addi	a0,a0,-1670 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200d36:	c8cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - max_block_size);
ffffffffc0200d3a:	00002697          	auipc	a3,0x2
ffffffffc0200d3e:	e3e68693          	addi	a3,a3,-450 # ffffffffc0202b78 <etext+0x7bc>
ffffffffc0200d42:	00002617          	auipc	a2,0x2
ffffffffc0200d46:	94e60613          	addi	a2,a2,-1714 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200d4a:	11800593          	li	a1,280
ffffffffc0200d4e:	00002517          	auipc	a0,0x2
ffffffffc0200d52:	95a50513          	addi	a0,a0,-1702 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200d56:	c6cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_max != NULL);
ffffffffc0200d5a:	00002697          	auipc	a3,0x2
ffffffffc0200d5e:	de668693          	addi	a3,a3,-538 # ffffffffc0202b40 <etext+0x784>
ffffffffc0200d62:	00002617          	auipc	a2,0x2
ffffffffc0200d66:	92e60613          	addi	a2,a2,-1746 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200d6a:	11600593          	li	a1,278
ffffffffc0200d6e:	00002517          	auipc	a0,0x2
ffffffffc0200d72:	93a50513          	addi	a0,a0,-1734 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200d76:	c4cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200d7a:	00002697          	auipc	a3,0x2
ffffffffc0200d7e:	aa668693          	addi	a3,a3,-1370 # ffffffffc0202820 <etext+0x464>
ffffffffc0200d82:	00002617          	auipc	a2,0x2
ffffffffc0200d86:	90e60613          	addi	a2,a2,-1778 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200d8a:	10800593          	li	a1,264
ffffffffc0200d8e:	00002517          	auipc	a0,0x2
ffffffffc0200d92:	91a50513          	addi	a0,a0,-1766 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200d96:	c2cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_min1 != NULL && p_min2 != NULL);
ffffffffc0200d9a:	00002697          	auipc	a3,0x2
ffffffffc0200d9e:	c9668693          	addi	a3,a3,-874 # ffffffffc0202a30 <etext+0x674>
ffffffffc0200da2:	00002617          	auipc	a2,0x2
ffffffffc0200da6:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200daa:	0fd00593          	li	a1,253
ffffffffc0200dae:	00002517          	auipc	a0,0x2
ffffffffc0200db2:	8fa50513          	addi	a0,a0,-1798 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200db6:	c0cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200dba:	00002697          	auipc	a3,0x2
ffffffffc0200dbe:	a6668693          	addi	a3,a3,-1434 # ffffffffc0202820 <etext+0x464>
ffffffffc0200dc2:	00002617          	auipc	a2,0x2
ffffffffc0200dc6:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200dca:	0f000593          	li	a1,240
ffffffffc0200dce:	00002517          	auipc	a0,0x2
ffffffffc0200dd2:	8da50513          	addi	a0,a0,-1830 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200dd6:	becff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - 4);
ffffffffc0200dda:	00002697          	auipc	a3,0x2
ffffffffc0200dde:	bae68693          	addi	a3,a3,-1106 # ffffffffc0202988 <etext+0x5cc>
ffffffffc0200de2:	00002617          	auipc	a2,0x2
ffffffffc0200de6:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200dea:	0eb00593          	li	a1,235
ffffffffc0200dee:	00002517          	auipc	a0,0x2
ffffffffc0200df2:	8ba50513          	addi	a0,a0,-1862 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200df6:	bccff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - 4 - 16);
ffffffffc0200dfa:	00002697          	auipc	a3,0x2
ffffffffc0200dfe:	ae668693          	addi	a3,a3,-1306 # ffffffffc02028e0 <etext+0x524>
ffffffffc0200e02:	00002617          	auipc	a2,0x2
ffffffffc0200e06:	88e60613          	addi	a2,a2,-1906 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200e0a:	0e500593          	li	a1,229
ffffffffc0200e0e:	00002517          	auipc	a0,0x2
ffffffffc0200e12:	89a50513          	addi	a0,a0,-1894 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200e16:	bacff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p2 != NULL && p3 != NULL);
ffffffffc0200e1a:	00002697          	auipc	a3,0x2
ffffffffc0200e1e:	aa668693          	addi	a3,a3,-1370 # ffffffffc02028c0 <etext+0x504>
ffffffffc0200e22:	00002617          	auipc	a2,0x2
ffffffffc0200e26:	86e60613          	addi	a2,a2,-1938 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200e2a:	0e400593          	li	a1,228
ffffffffc0200e2e:	00002517          	auipc	a0,0x2
ffffffffc0200e32:	87a50513          	addi	a0,a0,-1926 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200e36:	b8cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200e3a:	00002697          	auipc	a3,0x2
ffffffffc0200e3e:	9e668693          	addi	a3,a3,-1562 # ffffffffc0202820 <etext+0x464>
ffffffffc0200e42:	00002617          	auipc	a2,0x2
ffffffffc0200e46:	84e60613          	addi	a2,a2,-1970 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200e4a:	0d700593          	li	a1,215
ffffffffc0200e4e:	00002517          	auipc	a0,0x2
ffffffffc0200e52:	85a50513          	addi	a0,a0,-1958 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200e56:	b6cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - 16);
ffffffffc0200e5a:	00002697          	auipc	a3,0x2
ffffffffc0200e5e:	95668693          	addi	a3,a3,-1706 # ffffffffc02027b0 <etext+0x3f4>
ffffffffc0200e62:	00002617          	auipc	a2,0x2
ffffffffc0200e66:	82e60613          	addi	a2,a2,-2002 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200e6a:	0d200593          	li	a1,210
ffffffffc0200e6e:	00002517          	auipc	a0,0x2
ffffffffc0200e72:	83a50513          	addi	a0,a0,-1990 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200e76:	b4cff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200e7a <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200e7a:	1141                	addi	sp,sp,-16
ffffffffc0200e7c:	e406                	sd	ra,8(sp)
ffffffffc0200e7e:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200e80:	c5fd                	beqz	a1,ffffffffc0200f6e <buddy_init_memmap+0xf4>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200e82:	00259693          	slli	a3,a1,0x2
ffffffffc0200e86:	96ae                	add	a3,a3,a1
ffffffffc0200e88:	068e                	slli	a3,a3,0x3
ffffffffc0200e8a:	96aa                	add	a3,a3,a0
ffffffffc0200e8c:	87aa                	mv	a5,a0
ffffffffc0200e8e:	00d57f63          	bgeu	a0,a3,ffffffffc0200eac <buddy_init_memmap+0x32>
        assert(PageReserved(p));
ffffffffc0200e92:	6798                	ld	a4,8(a5)
ffffffffc0200e94:	8b05                	andi	a4,a4,1
ffffffffc0200e96:	cf45                	beqz	a4,ffffffffc0200f4e <buddy_init_memmap+0xd4>
        p->flags = 0;
ffffffffc0200e98:	0007b423          	sd	zero,8(a5)
        p->property = 0; 
ffffffffc0200e9c:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200ea0:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200ea4:	02878793          	addi	a5,a5,40
ffffffffc0200ea8:	fed7e5e3          	bltu	a5,a3,ffffffffc0200e92 <buddy_init_memmap+0x18>
ffffffffc0200eac:	00006417          	auipc	s0,0x6
ffffffffc0200eb0:	62c40413          	addi	s0,s0,1580 # ffffffffc02074d8 <nr_free>
ffffffffc0200eb4:	00043283          	ld	t0,0(s0)
ffffffffc0200eb8:	00006397          	auipc	t2,0x6
ffffffffc0200ebc:	16038393          	addi	t2,t2,352 # ffffffffc0207018 <free_area>
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc0200ec0:	4605                	li	a2,1
ffffffffc0200ec2:	4839                	li	a6,14
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200ec4:	4781                	li	a5,0
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc0200ec6:	0017871b          	addiw	a4,a5,1
ffffffffc0200eca:	00e6173b          	sllw	a4,a2,a4
ffffffffc0200ece:	0007869b          	sext.w	a3,a5
ffffffffc0200ed2:	06e5e263          	bltu	a1,a4,ffffffffc0200f36 <buddy_init_memmap+0xbc>
ffffffffc0200ed6:	0785                	addi	a5,a5,1
ffffffffc0200ed8:	ff0797e3          	bne	a5,a6,ffffffffc0200ec6 <buddy_init_memmap+0x4c>
ffffffffc0200edc:	000a0f37          	lui	t5,0xa0
ffffffffc0200ee0:	6e91                	lui	t4,0x4
ffffffffc0200ee2:	46b9                	li	a3,14
ffffffffc0200ee4:	15000893          	li	a7,336
ffffffffc0200ee8:	00179713          	slli	a4,a5,0x1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200eec:	97ba                	add	a5,a5,a4
ffffffffc0200eee:	078e                	slli	a5,a5,0x3
ffffffffc0200ef0:	979e                	add	a5,a5,t2
ffffffffc0200ef2:	0087bf83          	ld	t6,8(a5)
        free_area[order].nr_free++;
ffffffffc0200ef6:	0107ae03          	lw	t3,16(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200efa:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0200efe:	00efb023          	sd	a4,0(t6)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200f02:	00853303          	ld	t1,8(a0)
ffffffffc0200f06:	e798                	sd	a4,8(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200f08:	01138733          	add	a4,t2,a7
    elm->prev = prev;
ffffffffc0200f0c:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0200f0e:	03f53023          	sd	t6,32(a0)
        free_area[order].nr_free++;
ffffffffc0200f12:	001e071b          	addiw	a4,t3,1
ffffffffc0200f16:	cb98                	sw	a4,16(a5)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200f18:	00236793          	ori	a5,t1,2
        p->property = order;
ffffffffc0200f1c:	c914                	sw	a3,16(a0)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200f1e:	e51c                	sd	a5,8(a0)
        total_pages -= (1 << order);
ffffffffc0200f20:	41d585b3          	sub	a1,a1,t4
        nr_free += (1 << order);
ffffffffc0200f24:	92f6                	add	t0,t0,t4
        p += (1 << order);
ffffffffc0200f26:	957a                	add	a0,a0,t5
    while (total_pages > 0) {
ffffffffc0200f28:	fdd1                	bnez	a1,ffffffffc0200ec4 <buddy_init_memmap+0x4a>
}
ffffffffc0200f2a:	60a2                	ld	ra,8(sp)
ffffffffc0200f2c:	00543023          	sd	t0,0(s0)
ffffffffc0200f30:	6402                	ld	s0,0(sp)
ffffffffc0200f32:	0141                	addi	sp,sp,16
ffffffffc0200f34:	8082                	ret
        nr_free += (1 << order);
ffffffffc0200f36:	00d61ebb          	sllw	t4,a2,a3
ffffffffc0200f3a:	00179713          	slli	a4,a5,0x1
        p += (1 << order);
ffffffffc0200f3e:	002e9f13          	slli	t5,t4,0x2
ffffffffc0200f42:	00f708b3          	add	a7,a4,a5
ffffffffc0200f46:	9f76                	add	t5,t5,t4
ffffffffc0200f48:	088e                	slli	a7,a7,0x3
ffffffffc0200f4a:	0f0e                	slli	t5,t5,0x3
ffffffffc0200f4c:	b745                	j	ffffffffc0200eec <buddy_init_memmap+0x72>
        assert(PageReserved(p));
ffffffffc0200f4e:	00002697          	auipc	a3,0x2
ffffffffc0200f52:	ee268693          	addi	a3,a3,-286 # ffffffffc0202e30 <etext+0xa74>
ffffffffc0200f56:	00001617          	auipc	a2,0x1
ffffffffc0200f5a:	73a60613          	addi	a2,a2,1850 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200f5e:	02b00593          	li	a1,43
ffffffffc0200f62:	00001517          	auipc	a0,0x1
ffffffffc0200f66:	74650513          	addi	a0,a0,1862 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200f6a:	a58ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200f6e:	00001697          	auipc	a3,0x1
ffffffffc0200f72:	71a68693          	addi	a3,a3,1818 # ffffffffc0202688 <etext+0x2cc>
ffffffffc0200f76:	00001617          	auipc	a2,0x1
ffffffffc0200f7a:	71a60613          	addi	a2,a2,1818 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0200f7e:	02700593          	li	a1,39
ffffffffc0200f82:	00001517          	auipc	a0,0x1
ffffffffc0200f86:	72650513          	addi	a0,a0,1830 # ffffffffc02026a8 <etext+0x2ec>
ffffffffc0200f8a:	a38ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200f8e <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0200f8e:	00006797          	auipc	a5,0x6
ffffffffc0200f92:	5627b783          	ld	a5,1378(a5) # ffffffffc02074f0 <pmm_manager>
ffffffffc0200f96:	6f9c                	ld	a5,24(a5)
ffffffffc0200f98:	8782                	jr	a5

ffffffffc0200f9a <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0200f9a:	00006797          	auipc	a5,0x6
ffffffffc0200f9e:	5567b783          	ld	a5,1366(a5) # ffffffffc02074f0 <pmm_manager>
ffffffffc0200fa2:	739c                	ld	a5,32(a5)
ffffffffc0200fa4:	8782                	jr	a5

ffffffffc0200fa6 <pmm_init>:
    pmm_manager = &slub_pmm_manager;  // 使用SLUB分配器
ffffffffc0200fa6:	00002797          	auipc	a5,0x2
ffffffffc0200faa:	70278793          	addi	a5,a5,1794 # ffffffffc02036a8 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fae:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200fb0:	7179                	addi	sp,sp,-48
ffffffffc0200fb2:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fb4:	00002517          	auipc	a0,0x2
ffffffffc0200fb8:	edc50513          	addi	a0,a0,-292 # ffffffffc0202e90 <buddy_pmm_manager+0x38>
    pmm_manager = &slub_pmm_manager;  // 使用SLUB分配器
ffffffffc0200fbc:	00006417          	auipc	s0,0x6
ffffffffc0200fc0:	53440413          	addi	s0,s0,1332 # ffffffffc02074f0 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fc4:	f406                	sd	ra,40(sp)
ffffffffc0200fc6:	ec26                	sd	s1,24(sp)
ffffffffc0200fc8:	e44e                	sd	s3,8(sp)
ffffffffc0200fca:	e84a                	sd	s2,16(sp)
ffffffffc0200fcc:	e052                	sd	s4,0(sp)
    pmm_manager = &slub_pmm_manager;  // 使用SLUB分配器
ffffffffc0200fce:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fd0:	97cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200fd4:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fd6:	00006497          	auipc	s1,0x6
ffffffffc0200fda:	53248493          	addi	s1,s1,1330 # ffffffffc0207508 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200fde:	679c                	ld	a5,8(a5)
ffffffffc0200fe0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fe2:	57f5                	li	a5,-3
ffffffffc0200fe4:	07fa                	slli	a5,a5,0x1e
ffffffffc0200fe6:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200fe8:	dd4ff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc0200fec:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200fee:	dd8ff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200ff2:	14050d63          	beqz	a0,ffffffffc020114c <pmm_init+0x1a6>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200ff6:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200ff8:	00002517          	auipc	a0,0x2
ffffffffc0200ffc:	ee050513          	addi	a0,a0,-288 # ffffffffc0202ed8 <buddy_pmm_manager+0x80>
ffffffffc0201000:	94cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0201004:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201008:	864e                	mv	a2,s3
ffffffffc020100a:	fffa0693          	addi	a3,s4,-1
ffffffffc020100e:	85ca                	mv	a1,s2
ffffffffc0201010:	00002517          	auipc	a0,0x2
ffffffffc0201014:	ee050513          	addi	a0,a0,-288 # ffffffffc0202ef0 <buddy_pmm_manager+0x98>
ffffffffc0201018:	934ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020101c:	c80007b7          	lui	a5,0xc8000
ffffffffc0201020:	8652                	mv	a2,s4
ffffffffc0201022:	0d47e463          	bltu	a5,s4,ffffffffc02010ea <pmm_init+0x144>
ffffffffc0201026:	00007797          	auipc	a5,0x7
ffffffffc020102a:	4e978793          	addi	a5,a5,1257 # ffffffffc020850f <end+0xfff>
ffffffffc020102e:	757d                	lui	a0,0xfffff
ffffffffc0201030:	8d7d                	and	a0,a0,a5
ffffffffc0201032:	8231                	srli	a2,a2,0xc
ffffffffc0201034:	00006797          	auipc	a5,0x6
ffffffffc0201038:	4ac7b623          	sd	a2,1196(a5) # ffffffffc02074e0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020103c:	00006797          	auipc	a5,0x6
ffffffffc0201040:	4aa7b623          	sd	a0,1196(a5) # ffffffffc02074e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201044:	000807b7          	lui	a5,0x80
ffffffffc0201048:	002005b7          	lui	a1,0x200
ffffffffc020104c:	02f60563          	beq	a2,a5,ffffffffc0201076 <pmm_init+0xd0>
ffffffffc0201050:	00261593          	slli	a1,a2,0x2
ffffffffc0201054:	00c586b3          	add	a3,a1,a2
ffffffffc0201058:	fec007b7          	lui	a5,0xfec00
ffffffffc020105c:	97aa                	add	a5,a5,a0
ffffffffc020105e:	068e                	slli	a3,a3,0x3
ffffffffc0201060:	96be                	add	a3,a3,a5
ffffffffc0201062:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc0201064:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201066:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f8b18>
        SetPageReserved(pages + i);
ffffffffc020106a:	00176713          	ori	a4,a4,1
ffffffffc020106e:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201072:	fef699e3          	bne	a3,a5,ffffffffc0201064 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201076:	95b2                	add	a1,a1,a2
ffffffffc0201078:	fec006b7          	lui	a3,0xfec00
ffffffffc020107c:	96aa                	add	a3,a3,a0
ffffffffc020107e:	058e                	slli	a1,a1,0x3
ffffffffc0201080:	96ae                	add	a3,a3,a1
ffffffffc0201082:	c02007b7          	lui	a5,0xc0200
ffffffffc0201086:	0af6e763          	bltu	a3,a5,ffffffffc0201134 <pmm_init+0x18e>
ffffffffc020108a:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020108c:	77fd                	lui	a5,0xfffff
ffffffffc020108e:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201092:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201094:	04b6ee63          	bltu	a3,a1,ffffffffc02010f0 <pmm_init+0x14a>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201098:	601c                	ld	a5,0(s0)
ffffffffc020109a:	7b9c                	ld	a5,48(a5)
ffffffffc020109c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020109e:	00002517          	auipc	a0,0x2
ffffffffc02010a2:	eaa50513          	addi	a0,a0,-342 # ffffffffc0202f48 <buddy_pmm_manager+0xf0>
ffffffffc02010a6:	8a6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02010aa:	00005597          	auipc	a1,0x5
ffffffffc02010ae:	f5658593          	addi	a1,a1,-170 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc02010b2:	00006797          	auipc	a5,0x6
ffffffffc02010b6:	44b7b723          	sd	a1,1102(a5) # ffffffffc0207500 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010ba:	c02007b7          	lui	a5,0xc0200
ffffffffc02010be:	0af5e363          	bltu	a1,a5,ffffffffc0201164 <pmm_init+0x1be>
ffffffffc02010c2:	6090                	ld	a2,0(s1)
}
ffffffffc02010c4:	7402                	ld	s0,32(sp)
ffffffffc02010c6:	70a2                	ld	ra,40(sp)
ffffffffc02010c8:	64e2                	ld	s1,24(sp)
ffffffffc02010ca:	6942                	ld	s2,16(sp)
ffffffffc02010cc:	69a2                	ld	s3,8(sp)
ffffffffc02010ce:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02010d0:	40c58633          	sub	a2,a1,a2
ffffffffc02010d4:	00006797          	auipc	a5,0x6
ffffffffc02010d8:	42c7b223          	sd	a2,1060(a5) # ffffffffc02074f8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010dc:	00002517          	auipc	a0,0x2
ffffffffc02010e0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0202f68 <buddy_pmm_manager+0x110>
}
ffffffffc02010e4:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010e6:	866ff06f          	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02010ea:	c8000637          	lui	a2,0xc8000
ffffffffc02010ee:	bf25                	j	ffffffffc0201026 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010f0:	6705                	lui	a4,0x1
ffffffffc02010f2:	177d                	addi	a4,a4,-1
ffffffffc02010f4:	96ba                	add	a3,a3,a4
ffffffffc02010f6:	8efd                	and	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02010f8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010fc:	02c7f063          	bgeu	a5,a2,ffffffffc020111c <pmm_init+0x176>
    pmm_manager->init_memmap(base, n);
ffffffffc0201100:	6010                	ld	a2,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0201102:	fff80737          	lui	a4,0xfff80
ffffffffc0201106:	973e                	add	a4,a4,a5
ffffffffc0201108:	00271793          	slli	a5,a4,0x2
ffffffffc020110c:	97ba                	add	a5,a5,a4
ffffffffc020110e:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201110:	8d95                	sub	a1,a1,a3
ffffffffc0201112:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201114:	81b1                	srli	a1,a1,0xc
ffffffffc0201116:	953e                	add	a0,a0,a5
ffffffffc0201118:	9702                	jalr	a4
}
ffffffffc020111a:	bfbd                	j	ffffffffc0201098 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc020111c:	00001617          	auipc	a2,0x1
ffffffffc0201120:	5bc60613          	addi	a2,a2,1468 # ffffffffc02026d8 <etext+0x31c>
ffffffffc0201124:	06a00593          	li	a1,106
ffffffffc0201128:	00001517          	auipc	a0,0x1
ffffffffc020112c:	5d050513          	addi	a0,a0,1488 # ffffffffc02026f8 <etext+0x33c>
ffffffffc0201130:	892ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201134:	00002617          	auipc	a2,0x2
ffffffffc0201138:	dec60613          	addi	a2,a2,-532 # ffffffffc0202f20 <buddy_pmm_manager+0xc8>
ffffffffc020113c:	06300593          	li	a1,99
ffffffffc0201140:	00002517          	auipc	a0,0x2
ffffffffc0201144:	d8850513          	addi	a0,a0,-632 # ffffffffc0202ec8 <buddy_pmm_manager+0x70>
ffffffffc0201148:	87aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc020114c:	00002617          	auipc	a2,0x2
ffffffffc0201150:	d5c60613          	addi	a2,a2,-676 # ffffffffc0202ea8 <buddy_pmm_manager+0x50>
ffffffffc0201154:	04b00593          	li	a1,75
ffffffffc0201158:	00002517          	auipc	a0,0x2
ffffffffc020115c:	d7050513          	addi	a0,a0,-656 # ffffffffc0202ec8 <buddy_pmm_manager+0x70>
ffffffffc0201160:	862ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201164:	86ae                	mv	a3,a1
ffffffffc0201166:	00002617          	auipc	a2,0x2
ffffffffc020116a:	dba60613          	addi	a2,a2,-582 # ffffffffc0202f20 <buddy_pmm_manager+0xc8>
ffffffffc020116e:	07e00593          	li	a1,126
ffffffffc0201172:	00002517          	auipc	a0,0x2
ffffffffc0201176:	d5650513          	addi	a0,a0,-682 # ffffffffc0202ec8 <buddy_pmm_manager+0x70>
ffffffffc020117a:	848ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020117e <slub_init_memmap>:
                kmem_caches[i].num);
    }
}

void slub_init_memmap(struct Page *base, size_t n) {
    base_pmm->init_memmap(base, n);
ffffffffc020117e:	00002797          	auipc	a5,0x2
ffffffffc0201182:	cea7b783          	ld	a5,-790(a5) # ffffffffc0202e68 <buddy_pmm_manager+0x10>
ffffffffc0201186:	8782                	jr	a5

ffffffffc0201188 <slub_alloc_pages>:
}

struct Page *slub_alloc_pages(size_t n) {
    return base_pmm->alloc_pages(n);
ffffffffc0201188:	00002797          	auipc	a5,0x2
ffffffffc020118c:	ce87b783          	ld	a5,-792(a5) # ffffffffc0202e70 <buddy_pmm_manager+0x18>
ffffffffc0201190:	8782                	jr	a5

ffffffffc0201192 <slub_free_pages>:
}

void slub_free_pages(struct Page *base, size_t n) {
    base_pmm->free_pages(base, n);
ffffffffc0201192:	00002797          	auipc	a5,0x2
ffffffffc0201196:	ce67b783          	ld	a5,-794(a5) # ffffffffc0202e78 <buddy_pmm_manager+0x20>
ffffffffc020119a:	8782                	jr	a5

ffffffffc020119c <slub_nr_free_pages>:
}

size_t slub_nr_free_pages(void) {
    return base_pmm->nr_free_pages();
ffffffffc020119c:	00002797          	auipc	a5,0x2
ffffffffc02011a0:	ce47b783          	ld	a5,-796(a5) # ffffffffc0202e80 <buddy_pmm_manager+0x28>
ffffffffc02011a4:	8782                	jr	a5

ffffffffc02011a6 <slub_init>:
void slub_init(void) {
ffffffffc02011a6:	7139                	addi	sp,sp,-64
ffffffffc02011a8:	f822                	sd	s0,48(sp)
ffffffffc02011aa:	f426                	sd	s1,40(sp)
ffffffffc02011ac:	f04a                	sd	s2,32(sp)
ffffffffc02011ae:	ec4e                	sd	s3,24(sp)
ffffffffc02011b0:	e852                	sd	s4,16(sp)
ffffffffc02011b2:	e456                	sd	s5,8(sp)
ffffffffc02011b4:	e05a                	sd	s6,0(sp)
ffffffffc02011b6:	fc06                	sd	ra,56(sp)
    base_pmm->init();
ffffffffc02011b8:	00002797          	auipc	a5,0x2
ffffffffc02011bc:	ca87b783          	ld	a5,-856(a5) # ffffffffc0202e60 <buddy_pmm_manager+0x8>
ffffffffc02011c0:	9782                	jalr	a5
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc02011c2:	6a05                	lui	s4,0x1
ffffffffc02011c4:	00006417          	auipc	s0,0x6
ffffffffc02011c8:	fcc40413          	addi	s0,s0,-52 # ffffffffc0207190 <kmem_caches+0x10>
ffffffffc02011cc:	00006917          	auipc	s2,0x6
ffffffffc02011d0:	1f490913          	addi	s2,s2,500 # ffffffffc02073c0 <names.0>
ffffffffc02011d4:	00002997          	auipc	s3,0x2
ffffffffc02011d8:	49498993          	addi	s3,s3,1172 # ffffffffc0203668 <cache_sizes>
ffffffffc02011dc:	00006497          	auipc	s1,0x6
ffffffffc02011e0:	fa448493          	addi	s1,s1,-92 # ffffffffc0207180 <kmem_caches>
ffffffffc02011e4:	00006b17          	auipc	s6,0x6
ffffffffc02011e8:	1ecb0b13          	addi	s6,s6,492 # ffffffffc02073d0 <names.0+0x10>
    base_pmm->init();
ffffffffc02011ec:	46c1                	li	a3,16
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc02011ee:	fd8a0a13          	addi	s4,s4,-40 # fd8 <kern_entry-0xffffffffc01ff028>
        snprintf(names[i], 32, "kmem_cache_%lu", cache_sizes[i]);
ffffffffc02011f2:	00002a97          	auipc	s5,0x2
ffffffffc02011f6:	db6a8a93          	addi	s5,s5,-586 # ffffffffc0202fa8 <buddy_pmm_manager+0x150>
ffffffffc02011fa:	a019                	j	ffffffffc0201200 <slub_init+0x5a>
        kmem_caches[i].objsize = cache_sizes[i];
ffffffffc02011fc:	0009b683          	ld	a3,0(s3)
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc0201200:	02da5833          	divu	a6,s4,a3
ffffffffc0201204:	01040713          	addi	a4,s0,16
ffffffffc0201208:	02040793          	addi	a5,s0,32
        kmem_caches[i].objsize = cache_sizes[i];
ffffffffc020120c:	fed43823          	sd	a3,-16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201210:	ec18                	sd	a4,24(s0)
ffffffffc0201212:	e818                	sd	a4,16(s0)
ffffffffc0201214:	f41c                	sd	a5,40(s0)
ffffffffc0201216:	f01c                	sd	a5,32(s0)
ffffffffc0201218:	e400                	sd	s0,8(s0)
ffffffffc020121a:	e000                	sd	s0,0(s0)
        snprintf(names[i], 32, "kmem_cache_%lu", cache_sizes[i]);
ffffffffc020121c:	854a                	mv	a0,s2
ffffffffc020121e:	8656                	mv	a2,s5
ffffffffc0201220:	02000593          	li	a1,32
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201224:	04840413          	addi	s0,s0,72
ffffffffc0201228:	09a1                	addi	s3,s3,8
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc020122a:	fb043823          	sd	a6,-80(s0)
        snprintf(names[i], 32, "kmem_cache_%lu", cache_sizes[i]);
ffffffffc020122e:	0a2010ef          	jal	ra,ffffffffc02022d0 <snprintf>
        kmem_caches[i].name = names[i];
ffffffffc0201232:	ff243423          	sd	s2,-24(s0)
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201236:	02090913          	addi	s2,s2,32
ffffffffc020123a:	fd6411e3          	bne	s0,s6,ffffffffc02011fc <slub_init+0x56>
    cprintf("SLUB allocator initialized\n");
ffffffffc020123e:	00002517          	auipc	a0,0x2
ffffffffc0201242:	d7a50513          	addi	a0,a0,-646 # ffffffffc0202fb8 <buddy_pmm_manager+0x160>
ffffffffc0201246:	f07fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Cache configurations:\n");
ffffffffc020124a:	00002517          	auipc	a0,0x2
ffffffffc020124e:	d8e50513          	addi	a0,a0,-626 # ffffffffc0202fd8 <buddy_pmm_manager+0x180>
ffffffffc0201252:	efbfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201256:	00006917          	auipc	s2,0x6
ffffffffc020125a:	16a90913          	addi	s2,s2,362 # ffffffffc02073c0 <names.0>
        cprintf("  %s: objsize=%lu, num_per_slab=%lu\n", 
ffffffffc020125e:	00002417          	auipc	s0,0x2
ffffffffc0201262:	d9240413          	addi	s0,s0,-622 # ffffffffc0202ff0 <buddy_pmm_manager+0x198>
ffffffffc0201266:	6494                	ld	a3,8(s1)
ffffffffc0201268:	6090                	ld	a2,0(s1)
ffffffffc020126a:	60ac                	ld	a1,64(s1)
ffffffffc020126c:	8522                	mv	a0,s0
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020126e:	04848493          	addi	s1,s1,72
        cprintf("  %s: objsize=%lu, num_per_slab=%lu\n", 
ffffffffc0201272:	edbfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201276:	ff2498e3          	bne	s1,s2,ffffffffc0201266 <slub_init+0xc0>
}
ffffffffc020127a:	70e2                	ld	ra,56(sp)
ffffffffc020127c:	7442                	ld	s0,48(sp)
ffffffffc020127e:	74a2                	ld	s1,40(sp)
ffffffffc0201280:	7902                	ld	s2,32(sp)
ffffffffc0201282:	69e2                	ld	s3,24(sp)
ffffffffc0201284:	6a42                	ld	s4,16(sp)
ffffffffc0201286:	6aa2                	ld	s5,8(sp)
ffffffffc0201288:	6b02                	ld	s6,0(sp)
ffffffffc020128a:	6121                	addi	sp,sp,64
ffffffffc020128c:	8082                	ret

ffffffffc020128e <slub_alloc.part.0>:

#define LARGE_BLOCK_MAGIC 0x4C524745  // "LRGE"
#define LARGE_BLOCK_HEADER_SIZE SLUB_ALIGN_SIZE(sizeof(struct large_block_header))

/* 分配任意大小的内存(类似kmalloc) */
void *slub_alloc(size_t size) {
ffffffffc020128e:	1141                	addi	sp,sp,-16
ffffffffc0201290:	e022                	sd	s0,0(sp)
    
    if (size > SLUB_MAX_SIZE) {
        // 大于最大对象大小,直接分配页
        // 需要额外空间存储头部信息
        size_t total_size = size + LARGE_BLOCK_HEADER_SIZE;
        size_t n = ROUNDUP(total_size, PGSIZE) / PGSIZE;
ffffffffc0201292:	6405                	lui	s0,0x1
ffffffffc0201294:	043d                	addi	s0,s0,15
ffffffffc0201296:	942a                	add	s0,s0,a0
ffffffffc0201298:	8031                	srli	s0,s0,0xc
void *slub_alloc(size_t size) {
ffffffffc020129a:	e406                	sd	ra,8(sp)
    return base_pmm->alloc_pages(n);
ffffffffc020129c:	8522                	mv	a0,s0
ffffffffc020129e:	00002797          	auipc	a5,0x2
ffffffffc02012a2:	bd27b783          	ld	a5,-1070(a5) # ffffffffc0202e70 <buddy_pmm_manager+0x18>
ffffffffc02012a6:	9782                	jalr	a5
        struct Page *page = slub_alloc_pages(n);
        if (page == NULL) {
ffffffffc02012a8:	c921                	beqz	a0,ffffffffc02012f8 <slub_alloc.part.0+0x6a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012aa:	00006697          	auipc	a3,0x6
ffffffffc02012ae:	23e6b683          	ld	a3,574(a3) # ffffffffc02074e8 <pages>
ffffffffc02012b2:	8d15                	sub	a0,a0,a3
ffffffffc02012b4:	850d                	srai	a0,a0,0x3
ffffffffc02012b6:	00002697          	auipc	a3,0x2
ffffffffc02012ba:	6726b683          	ld	a3,1650(a3) # ffffffffc0203928 <error_string+0x38>
ffffffffc02012be:	02d50533          	mul	a0,a0,a3
ffffffffc02012c2:	00002697          	auipc	a3,0x2
ffffffffc02012c6:	66e6b683          	ld	a3,1646(a3) # ffffffffc0203930 <nbase>
            return NULL;
        }
        
        // 在页的开头写入头部信息
        void *kva = page2kva(page);
ffffffffc02012ca:	00006717          	auipc	a4,0x6
ffffffffc02012ce:	21673703          	ld	a4,534(a4) # ffffffffc02074e0 <npage>
ffffffffc02012d2:	9536                	add	a0,a0,a3
ffffffffc02012d4:	00c51793          	slli	a5,a0,0xc
ffffffffc02012d8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02012da:	0532                	slli	a0,a0,0xc
ffffffffc02012dc:	02e7f263          	bgeu	a5,a4,ffffffffc0201300 <slub_alloc.part.0+0x72>
ffffffffc02012e0:	00006697          	auipc	a3,0x6
ffffffffc02012e4:	2286b683          	ld	a3,552(a3) # ffffffffc0207508 <va_pa_offset>
        struct large_block_header *header = (struct large_block_header *)kva;
        header->num_pages = n;
        header->magic = LARGE_BLOCK_MAGIC;
ffffffffc02012e8:	4c5247b7          	lui	a5,0x4c524
        void *kva = page2kva(page);
ffffffffc02012ec:	9536                	add	a0,a0,a3
        header->magic = LARGE_BLOCK_MAGIC;
ffffffffc02012ee:	74578793          	addi	a5,a5,1861 # 4c524745 <kern_entry-0xffffffff73cdb8bb>
        header->num_pages = n;
ffffffffc02012f2:	e100                	sd	s0,0(a0)
        header->magic = LARGE_BLOCK_MAGIC;
ffffffffc02012f4:	c51c                	sw	a5,8(a0)
        
        // 返回头部之后的地址
        return (void *)((uintptr_t)kva + LARGE_BLOCK_HEADER_SIZE);
ffffffffc02012f6:	0541                	addi	a0,a0,16
    if (cache == NULL) {
        return NULL;
    }
    
    return kmem_cache_alloc(cache);
}
ffffffffc02012f8:	60a2                	ld	ra,8(sp)
ffffffffc02012fa:	6402                	ld	s0,0(sp)
ffffffffc02012fc:	0141                	addi	sp,sp,16
ffffffffc02012fe:	8082                	ret
        void *kva = page2kva(page);
ffffffffc0201300:	86aa                	mv	a3,a0
ffffffffc0201302:	00002617          	auipc	a2,0x2
ffffffffc0201306:	d1660613          	addi	a2,a2,-746 # ffffffffc0203018 <buddy_pmm_manager+0x1c0>
ffffffffc020130a:	10f00593          	li	a1,271
ffffffffc020130e:	00002517          	auipc	a0,0x2
ffffffffc0201312:	d3250513          	addi	a0,a0,-718 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201316:	eadfe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020131a <kmem_cache_alloc>:
void *kmem_cache_alloc(struct kmem_cache *cache) {
ffffffffc020131a:	7179                	addi	sp,sp,-48
ffffffffc020131c:	e84a                	sd	s2,16(sp)
    return list->next == list;
ffffffffc020131e:	02853903          	ld	s2,40(a0)
ffffffffc0201322:	f022                	sd	s0,32(sp)
ffffffffc0201324:	f406                	sd	ra,40(sp)
ffffffffc0201326:	ec26                	sd	s1,24(sp)
ffffffffc0201328:	e44e                	sd	s3,8(sp)
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc020132a:	02050793          	addi	a5,a0,32
void *kmem_cache_alloc(struct kmem_cache *cache) {
ffffffffc020132e:	842a                	mv	s0,a0
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc0201330:	06f90a63          	beq	s2,a5,ffffffffc02013a4 <kmem_cache_alloc+0x8a>
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0201334:	6110                	ld	a2,0(a0)
ffffffffc0201336:	01c92483          	lw	s1,28(s2)
    slab->inuse++;
ffffffffc020133a:	01892703          	lw	a4,24(s2)
    if (slab->inuse == cache->num) {
ffffffffc020133e:	6508                	ld	a0,8(a0)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0201340:	02c484b3          	mul	s1,s1,a2
    slab->inuse++;
ffffffffc0201344:	2705                	addiw	a4,a4,1
    if (slab->inuse == cache->num) {
ffffffffc0201346:	883a                	mv	a6,a4
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0201348:	01093583          	ld	a1,16(s2)
        slab->free = -1; // 没有更多空闲对象
ffffffffc020134c:	56fd                	li	a3,-1
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc020134e:	94ae                	add	s1,s1,a1
    if (node->next != NULL) {
ffffffffc0201350:	609c                	ld	a5,0(s1)
ffffffffc0201352:	c791                	beqz	a5,ffffffffc020135e <kmem_cache_alloc+0x44>
        slab->free = (next_addr - base_addr) / cache->objsize;
ffffffffc0201354:	8f8d                	sub	a5,a5,a1
ffffffffc0201356:	02c7d7b3          	divu	a5,a5,a2
ffffffffc020135a:	0007869b          	sext.w	a3,a5
ffffffffc020135e:	00d92e23          	sw	a3,28(s2)
    slab->inuse++;
ffffffffc0201362:	00e92c23          	sw	a4,24(s2)
    if (slab->inuse == cache->num) {
ffffffffc0201366:	02a81363          	bne	a6,a0,ffffffffc020138c <kmem_cache_alloc+0x72>
    __list_del(listelm->prev, listelm->next);
ffffffffc020136a:	00093683          	ld	a3,0(s2)
ffffffffc020136e:	00893703          	ld	a4,8(s2)
        list_add(&cache->slabs_full, &slab->slab_link);
ffffffffc0201372:	01040593          	addi	a1,s0,16 # 1010 <kern_entry-0xffffffffc01feff0>
    prev->next = next;
ffffffffc0201376:	e698                	sd	a4,8(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201378:	6c1c                	ld	a5,24(s0)
    next->prev = prev;
ffffffffc020137a:	e314                	sd	a3,0(a4)
    prev->next = next->prev = elm;
ffffffffc020137c:	0127b023          	sd	s2,0(a5)
ffffffffc0201380:	01243c23          	sd	s2,24(s0)
    elm->next = next;
ffffffffc0201384:	00f93423          	sd	a5,8(s2)
    elm->prev = prev;
ffffffffc0201388:	00b93023          	sd	a1,0(s2)
    memset(objp, 0, cache->objsize);
ffffffffc020138c:	4581                	li	a1,0
ffffffffc020138e:	8526                	mv	a0,s1
ffffffffc0201390:	01a010ef          	jal	ra,ffffffffc02023aa <memset>
}
ffffffffc0201394:	70a2                	ld	ra,40(sp)
ffffffffc0201396:	7402                	ld	s0,32(sp)
ffffffffc0201398:	6942                	ld	s2,16(sp)
ffffffffc020139a:	69a2                	ld	s3,8(sp)
ffffffffc020139c:	8526                	mv	a0,s1
ffffffffc020139e:	64e2                	ld	s1,24(sp)
ffffffffc02013a0:	6145                	addi	sp,sp,48
ffffffffc02013a2:	8082                	ret
    return list->next == list;
ffffffffc02013a4:	03853983          	ld	s3,56(a0)
    else if (!list_empty(&cache->slabs_free)) {
ffffffffc02013a8:	03050793          	addi	a5,a0,48
ffffffffc02013ac:	02f98d63          	beq	s3,a5,ffffffffc02013e6 <kmem_cache_alloc+0xcc>
    __list_del(listelm->prev, listelm->next);
ffffffffc02013b0:	0009b583          	ld	a1,0(s3)
ffffffffc02013b4:	0089b683          	ld	a3,8(s3)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc02013b8:	6110                	ld	a2,0(a0)
    slab->inuse++;
ffffffffc02013ba:	0189a703          	lw	a4,24(s3)
    prev->next = next;
ffffffffc02013be:	e594                	sd	a3,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02013c0:	751c                	ld	a5,40(a0)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc02013c2:	01c9a483          	lw	s1,28(s3)
    next->prev = prev;
ffffffffc02013c6:	e28c                	sd	a1,0(a3)
    prev->next = next->prev = elm;
ffffffffc02013c8:	0137b023          	sd	s3,0(a5)
ffffffffc02013cc:	03353423          	sd	s3,40(a0)
    slab->inuse++;
ffffffffc02013d0:	2705                	addiw	a4,a4,1
    if (slab->inuse == cache->num) {
ffffffffc02013d2:	6508                	ld	a0,8(a0)
    elm->prev = prev;
ffffffffc02013d4:	0129b023          	sd	s2,0(s3)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc02013d8:	02c484b3          	mul	s1,s1,a2
    elm->next = next;
ffffffffc02013dc:	00f9b423          	sd	a5,8(s3)
    if (slab->inuse == cache->num) {
ffffffffc02013e0:	883a                	mv	a6,a4
}
ffffffffc02013e2:	894e                	mv	s2,s3
ffffffffc02013e4:	b795                	j	ffffffffc0201348 <kmem_cache_alloc+0x2e>
    return base_pmm->alloc_pages(n);
ffffffffc02013e6:	4505                	li	a0,1
ffffffffc02013e8:	00002797          	auipc	a5,0x2
ffffffffc02013ec:	a887b783          	ld	a5,-1400(a5) # ffffffffc0202e70 <buddy_pmm_manager+0x18>
ffffffffc02013f0:	9782                	jalr	a5
ffffffffc02013f2:	84aa                	mv	s1,a0
    if (page == NULL) {
ffffffffc02013f4:	d145                	beqz	a0,ffffffffc0201394 <kmem_cache_alloc+0x7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02013f6:	00006697          	auipc	a3,0x6
ffffffffc02013fa:	0f26b683          	ld	a3,242(a3) # ffffffffc02074e8 <pages>
ffffffffc02013fe:	40d506b3          	sub	a3,a0,a3
ffffffffc0201402:	00002797          	auipc	a5,0x2
ffffffffc0201406:	5267b783          	ld	a5,1318(a5) # ffffffffc0203928 <error_string+0x38>
ffffffffc020140a:	868d                	srai	a3,a3,0x3
ffffffffc020140c:	02f686b3          	mul	a3,a3,a5
ffffffffc0201410:	00002797          	auipc	a5,0x2
ffffffffc0201414:	5207b783          	ld	a5,1312(a5) # ffffffffc0203930 <nbase>
    void *kva = page2kva(page);
ffffffffc0201418:	00006717          	auipc	a4,0x6
ffffffffc020141c:	0c873703          	ld	a4,200(a4) # ffffffffc02074e0 <npage>
ffffffffc0201420:	96be                	add	a3,a3,a5
ffffffffc0201422:	00c69793          	slli	a5,a3,0xc
ffffffffc0201426:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201428:	06b2                	slli	a3,a3,0xc
ffffffffc020142a:	06e7f363          	bgeu	a5,a4,ffffffffc0201490 <kmem_cache_alloc+0x176>
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc020142e:	6408                	ld	a0,8(s0)
    void *kva = page2kva(page);
ffffffffc0201430:	00006797          	auipc	a5,0x6
ffffffffc0201434:	0d87b783          	ld	a5,216(a5) # ffffffffc0207508 <va_pa_offset>
ffffffffc0201438:	96be                	add	a3,a3,a5
    slab->s_mem = (void *)((uintptr_t)kva + SLUB_ALIGN_SIZE(sizeof(struct slab)));
ffffffffc020143a:	02868893          	addi	a7,a3,40
ffffffffc020143e:	0116b823          	sd	a7,16(a3)
    slab->inuse = 0;
ffffffffc0201442:	0006bc23          	sd	zero,24(a3)
    slab->cache = cache;
ffffffffc0201446:	f280                	sd	s0,32(a3)
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc0201448:	fff50813          	addi	a6,a0,-1
        node->next = (struct freelist_node *)((uintptr_t)objp + cache->objsize);
ffffffffc020144c:	6010                	ld	a2,0(s0)
    slab->s_mem = (void *)((uintptr_t)kva + SLUB_ALIGN_SIZE(sizeof(struct slab)));
ffffffffc020144e:	87c6                	mv	a5,a7
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc0201450:	00080c63          	beqz	a6,ffffffffc0201468 <kmem_cache_alloc+0x14e>
ffffffffc0201454:	4701                	li	a4,0
        node->next = (struct freelist_node *)((uintptr_t)objp + cache->objsize);
ffffffffc0201456:	85be                	mv	a1,a5
ffffffffc0201458:	97b2                	add	a5,a5,a2
ffffffffc020145a:	e19c                	sd	a5,0(a1)
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc020145c:	0705                	addi	a4,a4,1
ffffffffc020145e:	ff071ce3          	bne	a4,a6,ffffffffc0201456 <kmem_cache_alloc+0x13c>
        node->next = (struct freelist_node *)((uintptr_t)objp + cache->objsize);
ffffffffc0201462:	02c707b3          	mul	a5,a4,a2
ffffffffc0201466:	97c6                	add	a5,a5,a7
    __list_add(elm, listelm, listelm->next);
ffffffffc0201468:	7c18                	ld	a4,56(s0)
    last_node->next = NULL;
ffffffffc020146a:	0007b023          	sd	zero,0(a5)
    prev->next = next->prev = elm;
ffffffffc020146e:	fc14                	sd	a3,56(s0)
    elm->next = next;
ffffffffc0201470:	e698                	sd	a4,8(a3)
    prev->next = next;
ffffffffc0201472:	00e9b423          	sd	a4,8(s3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201476:	741c                	ld	a5,40(s0)
    next->prev = prev;
ffffffffc0201478:	01373023          	sd	s3,0(a4)
}
ffffffffc020147c:	4805                	li	a6,1
    prev->next = next->prev = elm;
ffffffffc020147e:	e394                	sd	a3,0(a5)
ffffffffc0201480:	f414                	sd	a3,40(s0)
    elm->prev = prev;
ffffffffc0201482:	0126b023          	sd	s2,0(a3)
    elm->next = next;
ffffffffc0201486:	e69c                	sd	a5,8(a3)
}
ffffffffc0201488:	8936                	mv	s2,a3
ffffffffc020148a:	4705                	li	a4,1
ffffffffc020148c:	4481                	li	s1,0
ffffffffc020148e:	bd6d                	j	ffffffffc0201348 <kmem_cache_alloc+0x2e>
    void *kva = page2kva(page);
ffffffffc0201490:	00002617          	auipc	a2,0x2
ffffffffc0201494:	b8860613          	addi	a2,a2,-1144 # ffffffffc0203018 <buddy_pmm_manager+0x1c0>
ffffffffc0201498:	05800593          	li	a1,88
ffffffffc020149c:	00002517          	auipc	a0,0x2
ffffffffc02014a0:	ba450513          	addi	a0,a0,-1116 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc02014a4:	d1ffe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02014a8 <kmem_cache_free>:
void kmem_cache_free(struct kmem_cache *cache, void *objp) {
ffffffffc02014a8:	872e                	mv	a4,a1
    if (objp == NULL) {
ffffffffc02014aa:	cdb9                	beqz	a1,ffffffffc0201508 <kmem_cache_free+0x60>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc02014ac:	77fd                	lui	a5,0xfffff
ffffffffc02014ae:	8fed                	and	a5,a5,a1
    if (slab->cache != cache) {
ffffffffc02014b0:	7394                	ld	a3,32(a5)
ffffffffc02014b2:	04a69c63          	bne	a3,a0,ffffffffc020150a <kmem_cache_free+0x62>
    uintptr_t offset = (uintptr_t)objp - (uintptr_t)slab->s_mem;
ffffffffc02014b6:	0107b803          	ld	a6,16(a5) # fffffffffffff010 <end+0x3fdf7b00>
    int obj_index = offset / cache->objsize;
ffffffffc02014ba:	00053883          	ld	a7,0(a0)
    if (slab->free >= 0) {
ffffffffc02014be:	4fd0                	lw	a2,28(a5)
    uintptr_t offset = (uintptr_t)objp - (uintptr_t)slab->s_mem;
ffffffffc02014c0:	410586b3          	sub	a3,a1,a6
    int obj_index = offset / cache->objsize;
ffffffffc02014c4:	0316d6b3          	divu	a3,a3,a7
        node->next = NULL;
ffffffffc02014c8:	4581                	li	a1,0
    int obj_index = offset / cache->objsize;
ffffffffc02014ca:	2681                	sext.w	a3,a3
    if (slab->free >= 0) {
ffffffffc02014cc:	00064663          	bltz	a2,ffffffffc02014d8 <kmem_cache_free+0x30>
        void *next_free = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc02014d0:	03160633          	mul	a2,a2,a7
ffffffffc02014d4:	010605b3          	add	a1,a2,a6
    int was_full = (slab->inuse == cache->num);
ffffffffc02014d8:	4f90                	lw	a2,24(a5)
ffffffffc02014da:	e30c                	sd	a1,0(a4)
ffffffffc02014dc:	650c                	ld	a1,8(a0)
    slab->inuse--;
ffffffffc02014de:	fff6071b          	addiw	a4,a2,-1
    slab->free = obj_index;
ffffffffc02014e2:	cfd4                	sw	a3,28(a5)
    slab->inuse--;
ffffffffc02014e4:	cf98                	sw	a4,24(a5)
ffffffffc02014e6:	0007069b          	sext.w	a3,a4
    if (slab->inuse == 0) {
ffffffffc02014ea:	ee89                	bnez	a3,ffffffffc0201504 <kmem_cache_free+0x5c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02014ec:	6390                	ld	a2,0(a5)
ffffffffc02014ee:	6794                	ld	a3,8(a5)
        list_add(&cache->slabs_free, &slab->slab_link);
ffffffffc02014f0:	03050593          	addi	a1,a0,48
    prev->next = next;
ffffffffc02014f4:	e614                	sd	a3,8(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014f6:	7d18                	ld	a4,56(a0)
    next->prev = prev;
ffffffffc02014f8:	e290                	sd	a2,0(a3)
    prev->next = next->prev = elm;
ffffffffc02014fa:	e31c                	sd	a5,0(a4)
ffffffffc02014fc:	fd1c                	sd	a5,56(a0)
    elm->next = next;
ffffffffc02014fe:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0201500:	e38c                	sd	a1,0(a5)
}
ffffffffc0201502:	8082                	ret
    } else if (was_full) {
ffffffffc0201504:	00b60a63          	beq	a2,a1,ffffffffc0201518 <kmem_cache_free+0x70>
}
ffffffffc0201508:	8082                	ret
        cprintf("Error: object %p does not belong to cache %s\n", objp, cache->name);
ffffffffc020150a:	6130                	ld	a2,64(a0)
ffffffffc020150c:	00002517          	auipc	a0,0x2
ffffffffc0201510:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0203058 <buddy_pmm_manager+0x200>
ffffffffc0201514:	c39fe06f          	j	ffffffffc020014c <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201518:	6390                	ld	a2,0(a5)
ffffffffc020151a:	6794                	ld	a3,8(a5)
        list_add(&cache->slabs_partial, &slab->slab_link);
ffffffffc020151c:	02050593          	addi	a1,a0,32
    prev->next = next;
ffffffffc0201520:	e614                	sd	a3,8(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201522:	7518                	ld	a4,40(a0)
    next->prev = prev;
ffffffffc0201524:	e290                	sd	a2,0(a3)
    prev->next = next->prev = elm;
ffffffffc0201526:	e31c                	sd	a5,0(a4)
ffffffffc0201528:	f51c                	sd	a5,40(a0)
    elm->next = next;
ffffffffc020152a:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc020152c:	e38c                	sd	a1,0(a5)
}
ffffffffc020152e:	8082                	ret

ffffffffc0201530 <slub_alloc>:
    if (size == 0) {
ffffffffc0201530:	c521                	beqz	a0,ffffffffc0201578 <slub_alloc+0x48>
    if (size > SLUB_MAX_SIZE) {
ffffffffc0201532:	6705                	lui	a4,0x1
ffffffffc0201534:	80070713          	addi	a4,a4,-2048 # 800 <kern_entry-0xffffffffc01ff800>
ffffffffc0201538:	00a77363          	bgeu	a4,a0,ffffffffc020153e <slub_alloc+0xe>
ffffffffc020153c:	bb89                	j	ffffffffc020128e <slub_alloc.part.0>
    size = SLUB_ALIGN_SIZE(size);
ffffffffc020153e:	00750793          	addi	a5,a0,7
ffffffffc0201542:	9be1                	andi	a5,a5,-8
ffffffffc0201544:	46c1                	li	a3,16
ffffffffc0201546:	00002717          	auipc	a4,0x2
ffffffffc020154a:	12270713          	addi	a4,a4,290 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020154e:	4501                	li	a0,0
ffffffffc0201550:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201552:	00f6f963          	bgeu	a3,a5,ffffffffc0201564 <slub_alloc+0x34>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201556:	2505                	addiw	a0,a0,1
ffffffffc0201558:	0721                	addi	a4,a4,8
ffffffffc020155a:	00c50f63          	beq	a0,a2,ffffffffc0201578 <slub_alloc+0x48>
        if (cache_sizes[i] >= size) {
ffffffffc020155e:	6314                	ld	a3,0(a4)
ffffffffc0201560:	fef6ebe3          	bltu	a3,a5,ffffffffc0201556 <slub_alloc+0x26>
            return &kmem_caches[i];
ffffffffc0201564:	00351793          	slli	a5,a0,0x3
ffffffffc0201568:	953e                	add	a0,a0,a5
ffffffffc020156a:	050e                	slli	a0,a0,0x3
    return kmem_cache_alloc(cache);
ffffffffc020156c:	00006797          	auipc	a5,0x6
ffffffffc0201570:	c1478793          	addi	a5,a5,-1004 # ffffffffc0207180 <kmem_caches>
ffffffffc0201574:	953e                	add	a0,a0,a5
ffffffffc0201576:	b355                	j	ffffffffc020131a <kmem_cache_alloc>
}
ffffffffc0201578:	4501                	li	a0,0
ffffffffc020157a:	8082                	ret

ffffffffc020157c <slub_free>:

/* 释放由slub_alloc分配的内存(类似kfree) */
void slub_free(void *objp) {
    if (objp == NULL) {
ffffffffc020157c:	cd49                	beqz	a0,ffffffffc0201616 <slub_free+0x9a>
    }
    
    // 检查是否是大内存分配（通过检查头部魔数）
    // 大内存分配的地址会在页对齐地址之后偏移LARGE_BLOCK_HEADER_SIZE
    uintptr_t addr = (uintptr_t)objp;
    uintptr_t page_addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020157e:	76fd                	lui	a3,0xfffff
ffffffffc0201580:	8ee9                	and	a3,a3,a0
    uintptr_t offset = addr - page_addr;
    
    // 如果偏移正好是LARGE_BLOCK_HEADER_SIZE，可能是大内存分配
    if (offset == LARGE_BLOCK_HEADER_SIZE) {
ffffffffc0201582:	ff050793          	addi	a5,a0,-16
ffffffffc0201586:	85aa                	mv	a1,a0
ffffffffc0201588:	02d78663          	beq	a5,a3,ffffffffc02015b4 <slub_free+0x38>
    
    // 否则，尝试作为SLUB对象释放
    struct slab *slab = (struct slab *)page_addr;
    
    // 检查是否是有效的slab
    if (slab->cache != NULL && 
ffffffffc020158c:	7288                	ld	a0,32(a3)
ffffffffc020158e:	cd09                	beqz	a0,ffffffffc02015a8 <slub_free+0x2c>
ffffffffc0201590:	00006797          	auipc	a5,0x6
ffffffffc0201594:	bf078793          	addi	a5,a5,-1040 # ffffffffc0207180 <kmem_caches>
ffffffffc0201598:	00f56863          	bltu	a0,a5,ffffffffc02015a8 <slub_free+0x2c>
        slab->cache >= &kmem_caches[0] && 
ffffffffc020159c:	00006797          	auipc	a5,0x6
ffffffffc02015a0:	e2478793          	addi	a5,a5,-476 # ffffffffc02073c0 <names.0>
ffffffffc02015a4:	06f56863          	bltu	a0,a5,ffffffffc0201614 <slub_free+0x98>
        slab->cache < &kmem_caches[SLUB_CACHE_NUM]) {
        kmem_cache_free(slab->cache, objp);
    } else {
        cprintf("Warning: slub_free called on unknown allocation at %p\n", objp);
ffffffffc02015a8:	00002517          	auipc	a0,0x2
ffffffffc02015ac:	ae050513          	addi	a0,a0,-1312 # ffffffffc0203088 <buddy_pmm_manager+0x230>
ffffffffc02015b0:	b9dfe06f          	j	ffffffffc020014c <cprintf>
        if (header->magic == LARGE_BLOCK_MAGIC) {
ffffffffc02015b4:	4698                	lw	a4,8(a3)
ffffffffc02015b6:	4c5247b7          	lui	a5,0x4c524
ffffffffc02015ba:	74578793          	addi	a5,a5,1861 # 4c524745 <kern_entry-0xffffffff73cdb8bb>
ffffffffc02015be:	fcf717e3          	bne	a4,a5,ffffffffc020158c <slub_free+0x10>
void slub_free(void *objp) {
ffffffffc02015c2:	1141                	addi	sp,sp,-16
ffffffffc02015c4:	e406                	sd	ra,8(sp)
            struct Page *page = kva2page((void *)page_addr);
ffffffffc02015c6:	c02007b7          	lui	a5,0xc0200
ffffffffc02015ca:	04f6e763          	bltu	a3,a5,ffffffffc0201618 <slub_free+0x9c>
ffffffffc02015ce:	00006517          	auipc	a0,0x6
ffffffffc02015d2:	f3a53503          	ld	a0,-198(a0) # ffffffffc0207508 <va_pa_offset>
ffffffffc02015d6:	40a68533          	sub	a0,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc02015da:	8131                	srli	a0,a0,0xc
ffffffffc02015dc:	00006797          	auipc	a5,0x6
ffffffffc02015e0:	f047b783          	ld	a5,-252(a5) # ffffffffc02074e0 <npage>
ffffffffc02015e4:	04f57663          	bgeu	a0,a5,ffffffffc0201630 <slub_free+0xb4>
    return &pages[PPN(pa) - nbase];
ffffffffc02015e8:	00002797          	auipc	a5,0x2
ffffffffc02015ec:	3487b783          	ld	a5,840(a5) # ffffffffc0203930 <nbase>
ffffffffc02015f0:	8d1d                	sub	a0,a0,a5
ffffffffc02015f2:	00251793          	slli	a5,a0,0x2
    }
}
ffffffffc02015f6:	60a2                	ld	ra,8(sp)
ffffffffc02015f8:	953e                	add	a0,a0,a5
    base_pmm->free_pages(base, n);
ffffffffc02015fa:	628c                	ld	a1,0(a3)
ffffffffc02015fc:	00006797          	auipc	a5,0x6
ffffffffc0201600:	eec7b783          	ld	a5,-276(a5) # ffffffffc02074e8 <pages>
ffffffffc0201604:	050e                	slli	a0,a0,0x3
ffffffffc0201606:	953e                	add	a0,a0,a5
ffffffffc0201608:	00002797          	auipc	a5,0x2
ffffffffc020160c:	8707b783          	ld	a5,-1936(a5) # ffffffffc0202e78 <buddy_pmm_manager+0x20>
}
ffffffffc0201610:	0141                	addi	sp,sp,16
    base_pmm->free_pages(base, n);
ffffffffc0201612:	8782                	jr	a5
        kmem_cache_free(slab->cache, objp);
ffffffffc0201614:	bd51                	j	ffffffffc02014a8 <kmem_cache_free>
ffffffffc0201616:	8082                	ret
            struct Page *page = kva2page((void *)page_addr);
ffffffffc0201618:	00002617          	auipc	a2,0x2
ffffffffc020161c:	90860613          	addi	a2,a2,-1784 # ffffffffc0202f20 <buddy_pmm_manager+0xc8>
ffffffffc0201620:	13100593          	li	a1,305
ffffffffc0201624:	00002517          	auipc	a0,0x2
ffffffffc0201628:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc020162c:	b97fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201630:	00001617          	auipc	a2,0x1
ffffffffc0201634:	0a860613          	addi	a2,a2,168 # ffffffffc02026d8 <etext+0x31c>
ffffffffc0201638:	06a00593          	li	a1,106
ffffffffc020163c:	00001517          	auipc	a0,0x1
ffffffffc0201640:	0bc50513          	addi	a0,a0,188 # ffffffffc02026f8 <etext+0x33c>
ffffffffc0201644:	b7ffe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201648 <slub_check>:

/* ========== 测试函数 ========== */

void slub_check(void) {
ffffffffc0201648:	7171                	addi	sp,sp,-176
    cprintf("=== SLUB allocator check begin ===\n");
ffffffffc020164a:	00002517          	auipc	a0,0x2
ffffffffc020164e:	a7650513          	addi	a0,a0,-1418 # ffffffffc02030c0 <buddy_pmm_manager+0x268>
void slub_check(void) {
ffffffffc0201652:	f506                	sd	ra,168(sp)
ffffffffc0201654:	f122                	sd	s0,160(sp)
ffffffffc0201656:	ed26                	sd	s1,152(sp)
ffffffffc0201658:	e54e                	sd	s3,136(sp)
ffffffffc020165a:	e94a                	sd	s2,144(sp)
ffffffffc020165c:	e152                	sd	s4,128(sp)
ffffffffc020165e:	fcd6                	sd	s5,120(sp)
ffffffffc0201660:	f8da                	sd	s6,112(sp)
ffffffffc0201662:	f4de                	sd	s7,104(sp)
ffffffffc0201664:	f0e2                	sd	s8,96(sp)
ffffffffc0201666:	ece6                	sd	s9,88(sp)
ffffffffc0201668:	e8ea                	sd	s10,80(sp)
    cprintf("=== SLUB allocator check begin ===\n");
ffffffffc020166a:	ae3fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试1: 基本的分配和释放
    cprintf("Test 1: Basic allocation and free\n");
ffffffffc020166e:	00002517          	auipc	a0,0x2
ffffffffc0201672:	a7a50513          	addi	a0,a0,-1414 # ffffffffc02030e8 <buddy_pmm_manager+0x290>
ffffffffc0201676:	ad7fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return kmem_cache_alloc(cache);
ffffffffc020167a:	00006517          	auipc	a0,0x6
ffffffffc020167e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02071c8 <kmem_caches+0x48>
ffffffffc0201682:	c99ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201686:	89aa                	mv	s3,a0
ffffffffc0201688:	00006517          	auipc	a0,0x6
ffffffffc020168c:	b4050513          	addi	a0,a0,-1216 # ffffffffc02071c8 <kmem_caches+0x48>
ffffffffc0201690:	c8bff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201694:	00002497          	auipc	s1,0x2
ffffffffc0201698:	fd448493          	addi	s1,s1,-44 # ffffffffc0203668 <cache_sizes>
ffffffffc020169c:	842a                	mv	s0,a0
ffffffffc020169e:	8726                	mv	a4,s1
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02016a0:	4781                	li	a5,0
ffffffffc02016a2:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc02016a4:	03f00593          	li	a1,63
ffffffffc02016a8:	a029                	j	ffffffffc02016b2 <slub_check+0x6a>
ffffffffc02016aa:	6714                	ld	a3,8(a4)
ffffffffc02016ac:	0721                	addi	a4,a4,8
ffffffffc02016ae:	02d5e563          	bltu	a1,a3,ffffffffc02016d8 <slub_check+0x90>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02016b2:	2785                	addiw	a5,a5,1
ffffffffc02016b4:	fec79be3          	bne	a5,a2,ffffffffc02016aa <slub_check+0x62>
    void *p1 = slub_alloc(32);
    void *p2 = slub_alloc(32);
    void *p3 = slub_alloc(64);
    assert(p1 != NULL && p2 != NULL && p3 != NULL);
ffffffffc02016b8:	00002697          	auipc	a3,0x2
ffffffffc02016bc:	a5868693          	addi	a3,a3,-1448 # ffffffffc0203110 <buddy_pmm_manager+0x2b8>
ffffffffc02016c0:	00001617          	auipc	a2,0x1
ffffffffc02016c4:	fd060613          	addi	a2,a2,-48 # ffffffffc0202690 <etext+0x2d4>
ffffffffc02016c8:	14e00593          	li	a1,334
ffffffffc02016cc:	00002517          	auipc	a0,0x2
ffffffffc02016d0:	97450513          	addi	a0,a0,-1676 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc02016d4:	aeffe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc02016d8:	00379513          	slli	a0,a5,0x3
ffffffffc02016dc:	97aa                	add	a5,a5,a0
ffffffffc02016de:	00379513          	slli	a0,a5,0x3
ffffffffc02016e2:	00006917          	auipc	s2,0x6
ffffffffc02016e6:	a9e90913          	addi	s2,s2,-1378 # ffffffffc0207180 <kmem_caches>
    return kmem_cache_alloc(cache);
ffffffffc02016ea:	954a                	add	a0,a0,s2
ffffffffc02016ec:	c2fff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc02016f0:	8a2a                	mv	s4,a0
    assert(p1 != NULL && p2 != NULL && p3 != NULL);
ffffffffc02016f2:	fc0983e3          	beqz	s3,ffffffffc02016b8 <slub_check+0x70>
ffffffffc02016f6:	d069                	beqz	s0,ffffffffc02016b8 <slub_check+0x70>
ffffffffc02016f8:	d161                	beqz	a0,ffffffffc02016b8 <slub_check+0x70>
    assert(p1 != p2);
ffffffffc02016fa:	73340463          	beq	s0,s3,ffffffffc0201e22 <slub_check+0x7da>
    cprintf("  Allocated: p1=%p, p2=%p, p3=%p\n", p1, p2, p3);
ffffffffc02016fe:	86aa                	mv	a3,a0
ffffffffc0201700:	8622                	mv	a2,s0
ffffffffc0201702:	85ce                	mv	a1,s3
ffffffffc0201704:	00002517          	auipc	a0,0x2
ffffffffc0201708:	a4450513          	addi	a0,a0,-1468 # ffffffffc0203148 <buddy_pmm_manager+0x2f0>
ffffffffc020170c:	a41fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    slub_free(p1);
ffffffffc0201710:	854e                	mv	a0,s3
ffffffffc0201712:	e6bff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p2);
ffffffffc0201716:	8522                	mv	a0,s0
ffffffffc0201718:	e65ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p3);
ffffffffc020171c:	8552                	mv	a0,s4
ffffffffc020171e:	e5fff0ef          	jal	ra,ffffffffc020157c <slub_free>
    cprintf("  Test 1 passed!\n");
ffffffffc0201722:	00002517          	auipc	a0,0x2
ffffffffc0201726:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0203170 <buddy_pmm_manager+0x318>
ffffffffc020172a:	a23fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试2: 重复分配释放
    cprintf("Test 2: Repeated allocation and free\n");
ffffffffc020172e:	00002517          	auipc	a0,0x2
ffffffffc0201732:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0203188 <buddy_pmm_manager+0x330>
ffffffffc0201736:	8a8a                	mv	s5,sp
ffffffffc0201738:	a15fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    void *ptrs[10];
    for (int i = 0; i < 10; i++) {
ffffffffc020173c:	05010a13          	addi	s4,sp,80
    cprintf("Test 2: Repeated allocation and free\n");
ffffffffc0201740:	8b56                	mv	s6,s5
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201742:	4421                	li	s0,8
        if (cache_sizes[i] >= size) {
ffffffffc0201744:	07f00993          	li	s3,127
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201748:	87a6                	mv	a5,s1
ffffffffc020174a:	4501                	li	a0,0
ffffffffc020174c:	a029                	j	ffffffffc0201756 <slub_check+0x10e>
        if (cache_sizes[i] >= size) {
ffffffffc020174e:	6798                	ld	a4,8(a5)
ffffffffc0201750:	07a1                	addi	a5,a5,8
ffffffffc0201752:	02e9e563          	bltu	s3,a4,ffffffffc020177c <slub_check+0x134>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201756:	2505                	addiw	a0,a0,1
ffffffffc0201758:	fe851be3          	bne	a0,s0,ffffffffc020174e <slub_check+0x106>
        ptrs[i] = slub_alloc(128);
        assert(ptrs[i] != NULL);
ffffffffc020175c:	00002697          	auipc	a3,0x2
ffffffffc0201760:	a5468693          	addi	a3,a3,-1452 # ffffffffc02031b0 <buddy_pmm_manager+0x358>
ffffffffc0201764:	00001617          	auipc	a2,0x1
ffffffffc0201768:	f2c60613          	addi	a2,a2,-212 # ffffffffc0202690 <etext+0x2d4>
ffffffffc020176c:	15c00593          	li	a1,348
ffffffffc0201770:	00002517          	auipc	a0,0x2
ffffffffc0201774:	8d050513          	addi	a0,a0,-1840 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201778:	a4bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc020177c:	00351793          	slli	a5,a0,0x3
ffffffffc0201780:	953e                	add	a0,a0,a5
ffffffffc0201782:	050e                	slli	a0,a0,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201784:	954a                	add	a0,a0,s2
ffffffffc0201786:	b95ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
        ptrs[i] = slub_alloc(128);
ffffffffc020178a:	00ab3023          	sd	a0,0(s6)
        assert(ptrs[i] != NULL);
ffffffffc020178e:	d579                	beqz	a0,ffffffffc020175c <slub_check+0x114>
    for (int i = 0; i < 10; i++) {
ffffffffc0201790:	0b21                	addi	s6,s6,8
ffffffffc0201792:	fb6a1be3          	bne	s4,s6,ffffffffc0201748 <slub_check+0x100>
    }
    for (int i = 0; i < 10; i++) {
        slub_free(ptrs[i]);
ffffffffc0201796:	000ab503          	ld	a0,0(s5)
    for (int i = 0; i < 10; i++) {
ffffffffc020179a:	0aa1                	addi	s5,s5,8
        slub_free(ptrs[i]);
ffffffffc020179c:	de1ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    for (int i = 0; i < 10; i++) {
ffffffffc02017a0:	ff5a1be3          	bne	s4,s5,ffffffffc0201796 <slub_check+0x14e>
    }
    cprintf("  Test 2 passed!\n");
ffffffffc02017a4:	00002517          	auipc	a0,0x2
ffffffffc02017a8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02031c0 <buddy_pmm_manager+0x368>
ffffffffc02017ac:	9a1fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试3: 不同大小的分配
    cprintf("Test 3: Different sizes\n");
ffffffffc02017b0:	00002517          	auipc	a0,0x2
ffffffffc02017b4:	a2850513          	addi	a0,a0,-1496 # ffffffffc02031d8 <buddy_pmm_manager+0x380>
ffffffffc02017b8:	995fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return kmem_cache_alloc(cache);
ffffffffc02017bc:	00006517          	auipc	a0,0x6
ffffffffc02017c0:	9c450513          	addi	a0,a0,-1596 # ffffffffc0207180 <kmem_caches>
ffffffffc02017c4:	b57ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc02017c8:	89aa                	mv	s3,a0
ffffffffc02017ca:	00006517          	auipc	a0,0x6
ffffffffc02017ce:	9fe50513          	addi	a0,a0,-1538 # ffffffffc02071c8 <kmem_caches+0x48>
ffffffffc02017d2:	b49ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc02017d6:	842a                	mv	s0,a0
ffffffffc02017d8:	00002717          	auipc	a4,0x2
ffffffffc02017dc:	e9070713          	addi	a4,a4,-368 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02017e0:	4781                	li	a5,0
ffffffffc02017e2:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc02017e4:	03f00593          	li	a1,63
ffffffffc02017e8:	a029                	j	ffffffffc02017f2 <slub_check+0x1aa>
ffffffffc02017ea:	6714                	ld	a3,8(a4)
ffffffffc02017ec:	0721                	addi	a4,a4,8
ffffffffc02017ee:	2cd5ee63          	bltu	a1,a3,ffffffffc0201aca <slub_check+0x482>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02017f2:	2785                	addiw	a5,a5,1
ffffffffc02017f4:	fec79be3          	bne	a5,a2,ffffffffc02017ea <slub_check+0x1a2>
        return NULL;
ffffffffc02017f8:	4a01                	li	s4,0
ffffffffc02017fa:	00002717          	auipc	a4,0x2
ffffffffc02017fe:	e6e70713          	addi	a4,a4,-402 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201802:	4781                	li	a5,0
ffffffffc0201804:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201806:	07f00593          	li	a1,127
ffffffffc020180a:	a029                	j	ffffffffc0201814 <slub_check+0x1cc>
ffffffffc020180c:	6714                	ld	a3,8(a4)
ffffffffc020180e:	0721                	addi	a4,a4,8
ffffffffc0201810:	2cd5e763          	bltu	a1,a3,ffffffffc0201ade <slub_check+0x496>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201814:	2785                	addiw	a5,a5,1
ffffffffc0201816:	fec79be3          	bne	a5,a2,ffffffffc020180c <slub_check+0x1c4>
        return NULL;
ffffffffc020181a:	4a81                	li	s5,0
ffffffffc020181c:	00002717          	auipc	a4,0x2
ffffffffc0201820:	e4c70713          	addi	a4,a4,-436 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201824:	4781                	li	a5,0
ffffffffc0201826:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201828:	0ff00593          	li	a1,255
ffffffffc020182c:	a029                	j	ffffffffc0201836 <slub_check+0x1ee>
ffffffffc020182e:	6714                	ld	a3,8(a4)
ffffffffc0201830:	0721                	addi	a4,a4,8
ffffffffc0201832:	2cd5e063          	bltu	a1,a3,ffffffffc0201af2 <slub_check+0x4aa>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201836:	2785                	addiw	a5,a5,1
ffffffffc0201838:	fec79be3          	bne	a5,a2,ffffffffc020182e <slub_check+0x1e6>
        return NULL;
ffffffffc020183c:	4b01                	li	s6,0
ffffffffc020183e:	00002717          	auipc	a4,0x2
ffffffffc0201842:	e2a70713          	addi	a4,a4,-470 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201846:	4781                	li	a5,0
ffffffffc0201848:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc020184a:	1ff00593          	li	a1,511
ffffffffc020184e:	a029                	j	ffffffffc0201858 <slub_check+0x210>
ffffffffc0201850:	6714                	ld	a3,8(a4)
ffffffffc0201852:	0721                	addi	a4,a4,8
ffffffffc0201854:	2ad5e963          	bltu	a1,a3,ffffffffc0201b06 <slub_check+0x4be>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201858:	2785                	addiw	a5,a5,1
ffffffffc020185a:	fec79be3          	bne	a5,a2,ffffffffc0201850 <slub_check+0x208>
        return NULL;
ffffffffc020185e:	4b81                	li	s7,0
ffffffffc0201860:	00002717          	auipc	a4,0x2
ffffffffc0201864:	e0870713          	addi	a4,a4,-504 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201868:	4781                	li	a5,0
ffffffffc020186a:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc020186c:	3ff00593          	li	a1,1023
ffffffffc0201870:	a029                	j	ffffffffc020187a <slub_check+0x232>
ffffffffc0201872:	6714                	ld	a3,8(a4)
ffffffffc0201874:	0721                	addi	a4,a4,8
ffffffffc0201876:	22d5e663          	bltu	a1,a3,ffffffffc0201aa2 <slub_check+0x45a>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020187a:	2785                	addiw	a5,a5,1
ffffffffc020187c:	fec79be3          	bne	a5,a2,ffffffffc0201872 <slub_check+0x22a>
        return NULL;
ffffffffc0201880:	4c81                	li	s9,0
ffffffffc0201882:	00002717          	auipc	a4,0x2
ffffffffc0201886:	de670713          	addi	a4,a4,-538 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020188a:	4781                	li	a5,0
ffffffffc020188c:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc020188e:	7ff00593          	li	a1,2047
ffffffffc0201892:	a029                	j	ffffffffc020189c <slub_check+0x254>
ffffffffc0201894:	6714                	ld	a3,8(a4)
ffffffffc0201896:	0721                	addi	a4,a4,8
ffffffffc0201898:	20d5ef63          	bltu	a1,a3,ffffffffc0201ab6 <slub_check+0x46e>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020189c:	2785                	addiw	a5,a5,1
ffffffffc020189e:	fec79be3          	bne	a5,a2,ffffffffc0201894 <slub_check+0x24c>
        return NULL;
ffffffffc02018a2:	4c01                	li	s8,0
    void *p256 = slub_alloc(256);
    void *p512 = slub_alloc(512);
    void *p1024 = slub_alloc(1024);
    void *p2048 = slub_alloc(2048);
    
    assert(p16 != NULL && p32 != NULL && p64 != NULL && p128 != NULL);
ffffffffc02018a4:	54098f63          	beqz	s3,ffffffffc0201e02 <slub_check+0x7ba>
ffffffffc02018a8:	54040d63          	beqz	s0,ffffffffc0201e02 <slub_check+0x7ba>
ffffffffc02018ac:	540a0b63          	beqz	s4,ffffffffc0201e02 <slub_check+0x7ba>
ffffffffc02018b0:	540a8963          	beqz	s5,ffffffffc0201e02 <slub_check+0x7ba>
    assert(p256 != NULL && p512 != NULL && p1024 != NULL && p2048 != NULL);
ffffffffc02018b4:	5e0b0763          	beqz	s6,ffffffffc0201ea2 <slub_check+0x85a>
ffffffffc02018b8:	5e0b8563          	beqz	s7,ffffffffc0201ea2 <slub_check+0x85a>
ffffffffc02018bc:	5e0c8363          	beqz	s9,ffffffffc0201ea2 <slub_check+0x85a>
ffffffffc02018c0:	5e0c0163          	beqz	s8,ffffffffc0201ea2 <slub_check+0x85a>
    
    cprintf("  Allocated sizes: 16=%p, 32=%p, 64=%p, 128=%p\n", p16, p32, p64, p128);
ffffffffc02018c4:	86d2                	mv	a3,s4
ffffffffc02018c6:	8756                	mv	a4,s5
ffffffffc02018c8:	8622                	mv	a2,s0
ffffffffc02018ca:	85ce                	mv	a1,s3
ffffffffc02018cc:	00002517          	auipc	a0,0x2
ffffffffc02018d0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0203278 <buddy_pmm_manager+0x420>
ffffffffc02018d4:	879fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("                   256=%p, 512=%p, 1024=%p, 2048=%p\n", p256, p512, p1024, p2048);
ffffffffc02018d8:	86e6                	mv	a3,s9
ffffffffc02018da:	865e                	mv	a2,s7
ffffffffc02018dc:	8762                	mv	a4,s8
ffffffffc02018de:	85da                	mv	a1,s6
ffffffffc02018e0:	00002517          	auipc	a0,0x2
ffffffffc02018e4:	9c850513          	addi	a0,a0,-1592 # ffffffffc02032a8 <buddy_pmm_manager+0x450>
ffffffffc02018e8:	865fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    slub_free(p16);
ffffffffc02018ec:	854e                	mv	a0,s3
ffffffffc02018ee:	c8fff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p32);
ffffffffc02018f2:	8522                	mv	a0,s0
ffffffffc02018f4:	c89ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p64);
ffffffffc02018f8:	8552                	mv	a0,s4
ffffffffc02018fa:	c83ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p128);
ffffffffc02018fe:	8556                	mv	a0,s5
ffffffffc0201900:	c7dff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p256);
ffffffffc0201904:	855a                	mv	a0,s6
ffffffffc0201906:	c77ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p512);
ffffffffc020190a:	855e                	mv	a0,s7
ffffffffc020190c:	c71ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p1024);
ffffffffc0201910:	8566                	mv	a0,s9
ffffffffc0201912:	c6bff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p2048);
ffffffffc0201916:	8562                	mv	a0,s8
ffffffffc0201918:	c65ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    cprintf("  Test 3 passed!\n");
ffffffffc020191c:	00002517          	auipc	a0,0x2
ffffffffc0201920:	9c450513          	addi	a0,a0,-1596 # ffffffffc02032e0 <buddy_pmm_manager+0x488>
ffffffffc0201924:	829fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试4: 填充slab(触发slab扩展)
    cprintf("Test 4: Fill slab (trigger slab growth)\n");
ffffffffc0201928:	00002517          	auipc	a0,0x2
ffffffffc020192c:	9d050513          	addi	a0,a0,-1584 # ffffffffc02032f8 <buddy_pmm_manager+0x4a0>
ffffffffc0201930:	81dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201934:	4a01                	li	s4,0
    cprintf("Test 4: Fill slab (trigger slab growth)\n");
ffffffffc0201936:	00002797          	auipc	a5,0x2
ffffffffc020193a:	d3278793          	addi	a5,a5,-718 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020193e:	46a1                	li	a3,8
        if (cache_sizes[i] >= size) {
ffffffffc0201940:	03f00613          	li	a2,63
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201944:	2a05                	addiw	s4,s4,1
ffffffffc0201946:	56da0e63          	beq	s4,a3,ffffffffc0201ec2 <slub_check+0x87a>
        if (cache_sizes[i] >= size) {
ffffffffc020194a:	6798                	ld	a4,8(a5)
ffffffffc020194c:	07a1                	addi	a5,a5,8
ffffffffc020194e:	fee67be3          	bgeu	a2,a4,ffffffffc0201944 <slub_check+0x2fc>
            return &kmem_caches[i];
ffffffffc0201952:	003a1b93          	slli	s7,s4,0x3
ffffffffc0201956:	014b8ab3          	add	s5,s7,s4
ffffffffc020195a:	0a8e                	slli	s5,s5,0x3
ffffffffc020195c:	01590433          	add	s0,s2,s5
    struct kmem_cache *cache = get_kmem_cache(64);
    int num_objs = cache->num * 3; // 分配3个slab的对象
ffffffffc0201960:	641c                	ld	a5,8(s0)
ffffffffc0201962:	00179b1b          	slliw	s6,a5,0x1
ffffffffc0201966:	00fb0cbb          	addw	s9,s6,a5
    void **objs = (void **)slub_alloc(num_objs * sizeof(void *));
ffffffffc020196a:	003c9513          	slli	a0,s9,0x3
ffffffffc020196e:	bc3ff0ef          	jal	ra,ffffffffc0201530 <slub_alloc>
    int num_objs = cache->num * 3; // 分配3个slab的对象
ffffffffc0201972:	8b66                	mv	s6,s9
    void **objs = (void **)slub_alloc(num_objs * sizeof(void *));
ffffffffc0201974:	8c2a                	mv	s8,a0
    
    for (int i = 0; i < num_objs; i++) {
ffffffffc0201976:	03905663          	blez	s9,ffffffffc02019a2 <slub_check+0x35a>
ffffffffc020197a:	fffc899b          	addiw	s3,s9,-1
ffffffffc020197e:	02099793          	slli	a5,s3,0x20
ffffffffc0201982:	01d7d993          	srli	s3,a5,0x1d
ffffffffc0201986:	00850793          	addi	a5,a0,8
ffffffffc020198a:	8d2a                	mv	s10,a0
ffffffffc020198c:	99be                	add	s3,s3,a5
        objs[i] = kmem_cache_alloc(cache);
ffffffffc020198e:	8522                	mv	a0,s0
ffffffffc0201990:	98bff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201994:	00ad3023          	sd	a0,0(s10)
        assert(objs[i] != NULL);
ffffffffc0201998:	40050563          	beqz	a0,ffffffffc0201da2 <slub_check+0x75a>
    for (int i = 0; i < num_objs; i++) {
ffffffffc020199c:	0d21                	addi	s10,s10,8
ffffffffc020199e:	ff3d18e3          	bne	s10,s3,ffffffffc020198e <slub_check+0x346>
    }
    cprintf("  Allocated %d objects from cache_%lu\n", num_objs, cache->objsize);
ffffffffc02019a2:	014b87b3          	add	a5,s7,s4
ffffffffc02019a6:	078e                	slli	a5,a5,0x3
ffffffffc02019a8:	97ca                	add	a5,a5,s2
ffffffffc02019aa:	6390                	ld	a2,0(a5)
ffffffffc02019ac:	85e6                	mv	a1,s9
ffffffffc02019ae:	00002517          	auipc	a0,0x2
ffffffffc02019b2:	97a50513          	addi	a0,a0,-1670 # ffffffffc0203328 <buddy_pmm_manager+0x4d0>
ffffffffc02019b6:	f96fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return listelm->next;
ffffffffc02019ba:	6c1c                	ld	a5,24(s0)
    
    // 检查链表状态
    int full_count = 0, partial_count = 0, free_count = 0;
    list_entry_t *le;
    
    for (le = list_next(&cache->slabs_full); le != &cache->slabs_full; le = list_next(le)) {
ffffffffc02019bc:	010a8713          	addi	a4,s5,16
ffffffffc02019c0:	974a                	add	a4,a4,s2
    int full_count = 0, partial_count = 0, free_count = 0;
ffffffffc02019c2:	4581                	li	a1,0
    for (le = list_next(&cache->slabs_full); le != &cache->slabs_full; le = list_next(le)) {
ffffffffc02019c4:	00e78663          	beq	a5,a4,ffffffffc02019d0 <slub_check+0x388>
ffffffffc02019c8:	679c                	ld	a5,8(a5)
        full_count++;
ffffffffc02019ca:	2585                	addiw	a1,a1,1
    for (le = list_next(&cache->slabs_full); le != &cache->slabs_full; le = list_next(le)) {
ffffffffc02019cc:	fee79ee3          	bne	a5,a4,ffffffffc02019c8 <slub_check+0x380>
ffffffffc02019d0:	741c                	ld	a5,40(s0)
    }
    for (le = list_next(&cache->slabs_partial); le != &cache->slabs_partial; le = list_next(le)) {
ffffffffc02019d2:	020a8713          	addi	a4,s5,32
ffffffffc02019d6:	974a                	add	a4,a4,s2
    int full_count = 0, partial_count = 0, free_count = 0;
ffffffffc02019d8:	4601                	li	a2,0
    for (le = list_next(&cache->slabs_partial); le != &cache->slabs_partial; le = list_next(le)) {
ffffffffc02019da:	00e78663          	beq	a5,a4,ffffffffc02019e6 <slub_check+0x39e>
ffffffffc02019de:	679c                	ld	a5,8(a5)
        partial_count++;
ffffffffc02019e0:	2605                	addiw	a2,a2,1
    for (le = list_next(&cache->slabs_partial); le != &cache->slabs_partial; le = list_next(le)) {
ffffffffc02019e2:	fee79ee3          	bne	a5,a4,ffffffffc02019de <slub_check+0x396>
ffffffffc02019e6:	7c1c                	ld	a5,56(s0)
    }
    for (le = list_next(&cache->slabs_free); le != &cache->slabs_free; le = list_next(le)) {
ffffffffc02019e8:	030a8713          	addi	a4,s5,48
ffffffffc02019ec:	974a                	add	a4,a4,s2
    int full_count = 0, partial_count = 0, free_count = 0;
ffffffffc02019ee:	4681                	li	a3,0
    for (le = list_next(&cache->slabs_free); le != &cache->slabs_free; le = list_next(le)) {
ffffffffc02019f0:	00e78663          	beq	a5,a4,ffffffffc02019fc <slub_check+0x3b4>
ffffffffc02019f4:	679c                	ld	a5,8(a5)
        free_count++;
ffffffffc02019f6:	2685                	addiw	a3,a3,1
    for (le = list_next(&cache->slabs_free); le != &cache->slabs_free; le = list_next(le)) {
ffffffffc02019f8:	fee79ee3          	bne	a5,a4,ffffffffc02019f4 <slub_check+0x3ac>
    }
    
    cprintf("  Slab lists: full=%d, partial=%d, free=%d\n", full_count, partial_count, free_count);
ffffffffc02019fc:	00002517          	auipc	a0,0x2
ffffffffc0201a00:	96450513          	addi	a0,a0,-1692 # ffffffffc0203360 <buddy_pmm_manager+0x508>
ffffffffc0201a04:	f48fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 释放所有对象
    for (int i = 0; i < num_objs; i++) {
ffffffffc0201a08:	03905463          	blez	s9,ffffffffc0201a30 <slub_check+0x3e8>
ffffffffc0201a0c:	fffb079b          	addiw	a5,s6,-1
ffffffffc0201a10:	02079713          	slli	a4,a5,0x20
ffffffffc0201a14:	01d75793          	srli	a5,a4,0x1d
ffffffffc0201a18:	008c0a13          	addi	s4,s8,8 # ff0008 <kern_entry-0xffffffffbf20fff8>
ffffffffc0201a1c:	89e2                	mv	s3,s8
ffffffffc0201a1e:	9a3e                	add	s4,s4,a5
        kmem_cache_free(cache, objs[i]);
ffffffffc0201a20:	0009b583          	ld	a1,0(s3)
ffffffffc0201a24:	8522                	mv	a0,s0
    for (int i = 0; i < num_objs; i++) {
ffffffffc0201a26:	09a1                	addi	s3,s3,8
        kmem_cache_free(cache, objs[i]);
ffffffffc0201a28:	a81ff0ef          	jal	ra,ffffffffc02014a8 <kmem_cache_free>
    for (int i = 0; i < num_objs; i++) {
ffffffffc0201a2c:	ff499ae3          	bne	s3,s4,ffffffffc0201a20 <slub_check+0x3d8>
    }
    slub_free(objs);
ffffffffc0201a30:	8562                	mv	a0,s8
ffffffffc0201a32:	b4bff0ef          	jal	ra,ffffffffc020157c <slub_free>
    cprintf("  Test 4 passed!\n");
ffffffffc0201a36:	00002517          	auipc	a0,0x2
ffffffffc0201a3a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0203390 <buddy_pmm_manager+0x538>
ffffffffc0201a3e:	f0efe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试5: 边界情况
    cprintf("Test 5: Edge cases\n");
ffffffffc0201a42:	00002517          	auipc	a0,0x2
ffffffffc0201a46:	96650513          	addi	a0,a0,-1690 # ffffffffc02033a8 <buddy_pmm_manager+0x550>
ffffffffc0201a4a:	f02fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return kmem_cache_alloc(cache);
ffffffffc0201a4e:	00005517          	auipc	a0,0x5
ffffffffc0201a52:	73250513          	addi	a0,a0,1842 # ffffffffc0207180 <kmem_caches>
ffffffffc0201a56:	8c5ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
    void *p_zero = slub_alloc(0);
    assert(p_zero == NULL);
    slub_free(NULL); // 不应崩溃
    
    void *p_small = slub_alloc(1); // 最小分配
    assert(p_small != NULL);
ffffffffc0201a5a:	36050463          	beqz	a0,ffffffffc0201dc2 <slub_check+0x77a>
    slub_free(p_small);
ffffffffc0201a5e:	b1fff0ef          	jal	ra,ffffffffc020157c <slub_free>
ffffffffc0201a62:	00002717          	auipc	a4,0x2
ffffffffc0201a66:	c0670713          	addi	a4,a4,-1018 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201a6a:	4781                	li	a5,0
ffffffffc0201a6c:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201a6e:	7ff00593          	li	a1,2047
ffffffffc0201a72:	a029                	j	ffffffffc0201a7c <slub_check+0x434>
ffffffffc0201a74:	6714                	ld	a3,8(a4)
ffffffffc0201a76:	0721                	addi	a4,a4,8
ffffffffc0201a78:	0ad5e163          	bltu	a1,a3,ffffffffc0201b1a <slub_check+0x4d2>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201a7c:	2785                	addiw	a5,a5,1
ffffffffc0201a7e:	fec79be3          	bne	a5,a2,ffffffffc0201a74 <slub_check+0x42c>
    
    void *p_max = slub_alloc(SLUB_MAX_SIZE); // 最大对象
    assert(p_max != NULL);
ffffffffc0201a82:	00001697          	auipc	a3,0x1
ffffffffc0201a86:	0be68693          	addi	a3,a3,190 # ffffffffc0202b40 <etext+0x784>
ffffffffc0201a8a:	00001617          	auipc	a2,0x1
ffffffffc0201a8e:	c0660613          	addi	a2,a2,-1018 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201a92:	1ac00593          	li	a1,428
ffffffffc0201a96:	00001517          	auipc	a0,0x1
ffffffffc0201a9a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201a9e:	f24fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc0201aa2:	00379513          	slli	a0,a5,0x3
ffffffffc0201aa6:	97aa                	add	a5,a5,a0
ffffffffc0201aa8:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201aac:	954a                	add	a0,a0,s2
ffffffffc0201aae:	86dff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201ab2:	8caa                	mv	s9,a0
ffffffffc0201ab4:	b3f9                	j	ffffffffc0201882 <slub_check+0x23a>
            return &kmem_caches[i];
ffffffffc0201ab6:	00379513          	slli	a0,a5,0x3
ffffffffc0201aba:	97aa                	add	a5,a5,a0
ffffffffc0201abc:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201ac0:	954a                	add	a0,a0,s2
ffffffffc0201ac2:	859ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201ac6:	8c2a                	mv	s8,a0
ffffffffc0201ac8:	bbf1                	j	ffffffffc02018a4 <slub_check+0x25c>
            return &kmem_caches[i];
ffffffffc0201aca:	00379513          	slli	a0,a5,0x3
ffffffffc0201ace:	97aa                	add	a5,a5,a0
ffffffffc0201ad0:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201ad4:	954a                	add	a0,a0,s2
ffffffffc0201ad6:	845ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201ada:	8a2a                	mv	s4,a0
ffffffffc0201adc:	bb39                	j	ffffffffc02017fa <slub_check+0x1b2>
            return &kmem_caches[i];
ffffffffc0201ade:	00379513          	slli	a0,a5,0x3
ffffffffc0201ae2:	97aa                	add	a5,a5,a0
ffffffffc0201ae4:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201ae8:	954a                	add	a0,a0,s2
ffffffffc0201aea:	831ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201aee:	8aaa                	mv	s5,a0
ffffffffc0201af0:	b335                	j	ffffffffc020181c <slub_check+0x1d4>
            return &kmem_caches[i];
ffffffffc0201af2:	00379513          	slli	a0,a5,0x3
ffffffffc0201af6:	97aa                	add	a5,a5,a0
ffffffffc0201af8:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201afc:	954a                	add	a0,a0,s2
ffffffffc0201afe:	81dff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201b02:	8b2a                	mv	s6,a0
ffffffffc0201b04:	bb2d                	j	ffffffffc020183e <slub_check+0x1f6>
            return &kmem_caches[i];
ffffffffc0201b06:	00379513          	slli	a0,a5,0x3
ffffffffc0201b0a:	97aa                	add	a5,a5,a0
ffffffffc0201b0c:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201b10:	954a                	add	a0,a0,s2
ffffffffc0201b12:	809ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201b16:	8baa                	mv	s7,a0
ffffffffc0201b18:	b3a1                	j	ffffffffc0201860 <slub_check+0x218>
            return &kmem_caches[i];
ffffffffc0201b1a:	00379513          	slli	a0,a5,0x3
ffffffffc0201b1e:	97aa                	add	a5,a5,a0
ffffffffc0201b20:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201b24:	954a                	add	a0,a0,s2
ffffffffc0201b26:	ff4ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
    assert(p_max != NULL);
ffffffffc0201b2a:	dd21                	beqz	a0,ffffffffc0201a82 <slub_check+0x43a>
    slub_free(p_max);
ffffffffc0201b2c:	a51ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    cprintf("  Test 5 passed!\n");
ffffffffc0201b30:	00002517          	auipc	a0,0x2
ffffffffc0201b34:	8a050513          	addi	a0,a0,-1888 # ffffffffc02033d0 <buddy_pmm_manager+0x578>
ffffffffc0201b38:	e14fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试6: 内存写入测试
    cprintf("Test 6: Memory write test\n");
ffffffffc0201b3c:	00002517          	auipc	a0,0x2
ffffffffc0201b40:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02033e8 <buddy_pmm_manager+0x590>
ffffffffc0201b44:	e08fe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0201b48:	00002717          	auipc	a4,0x2
ffffffffc0201b4c:	b2070713          	addi	a4,a4,-1248 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201b50:	4781                	li	a5,0
ffffffffc0201b52:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201b54:	02700593          	li	a1,39
ffffffffc0201b58:	a029                	j	ffffffffc0201b62 <slub_check+0x51a>
ffffffffc0201b5a:	6714                	ld	a3,8(a4)
ffffffffc0201b5c:	0721                	addi	a4,a4,8
ffffffffc0201b5e:	02d5e563          	bltu	a1,a3,ffffffffc0201b88 <slub_check+0x540>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201b62:	2785                	addiw	a5,a5,1
ffffffffc0201b64:	fec79be3          	bne	a5,a2,ffffffffc0201b5a <slub_check+0x512>
    int *pi = (int *)slub_alloc(sizeof(int) * 10);
    assert(pi != NULL);
ffffffffc0201b68:	00002697          	auipc	a3,0x2
ffffffffc0201b6c:	8a068693          	addi	a3,a3,-1888 # ffffffffc0203408 <buddy_pmm_manager+0x5b0>
ffffffffc0201b70:	00001617          	auipc	a2,0x1
ffffffffc0201b74:	b2060613          	addi	a2,a2,-1248 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201b78:	1b300593          	li	a1,435
ffffffffc0201b7c:	00001517          	auipc	a0,0x1
ffffffffc0201b80:	4c450513          	addi	a0,a0,1220 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201b84:	e3efe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc0201b88:	00379513          	slli	a0,a5,0x3
ffffffffc0201b8c:	97aa                	add	a5,a5,a0
ffffffffc0201b8e:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201b92:	954a                	add	a0,a0,s2
ffffffffc0201b94:	f86ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
    assert(pi != NULL);
ffffffffc0201b98:	d961                	beqz	a0,ffffffffc0201b68 <slub_check+0x520>
ffffffffc0201b9a:	86aa                	mv	a3,a0
ffffffffc0201b9c:	872a                	mv	a4,a0
    for (int i = 0; i < 10; i++) {
ffffffffc0201b9e:	4781                	li	a5,0
ffffffffc0201ba0:	45a9                	li	a1,10
        pi[i] = i * i;
ffffffffc0201ba2:	02f7863b          	mulw	a2,a5,a5
    for (int i = 0; i < 10; i++) {
ffffffffc0201ba6:	2785                	addiw	a5,a5,1
ffffffffc0201ba8:	0711                	addi	a4,a4,4
        pi[i] = i * i;
ffffffffc0201baa:	fec72e23          	sw	a2,-4(a4)
    for (int i = 0; i < 10; i++) {
ffffffffc0201bae:	feb79ae3          	bne	a5,a1,ffffffffc0201ba2 <slub_check+0x55a>
    }
    for (int i = 0; i < 10; i++) {
ffffffffc0201bb2:	4781                	li	a5,0
ffffffffc0201bb4:	45a9                	li	a1,10
        assert(pi[i] == i * i);
ffffffffc0201bb6:	02f7873b          	mulw	a4,a5,a5
ffffffffc0201bba:	4290                	lw	a2,0(a3)
ffffffffc0201bbc:	1ce61363          	bne	a2,a4,ffffffffc0201d82 <slub_check+0x73a>
    for (int i = 0; i < 10; i++) {
ffffffffc0201bc0:	2785                	addiw	a5,a5,1
ffffffffc0201bc2:	0691                	addi	a3,a3,4
ffffffffc0201bc4:	feb799e3          	bne	a5,a1,ffffffffc0201bb6 <slub_check+0x56e>
    }
    slub_free(pi);
ffffffffc0201bc8:	9b5ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    cprintf("  Test 6 passed!\n");
ffffffffc0201bcc:	00002517          	auipc	a0,0x2
ffffffffc0201bd0:	85c50513          	addi	a0,a0,-1956 # ffffffffc0203428 <buddy_pmm_manager+0x5d0>
ffffffffc0201bd4:	d78fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试7: 大内存分配回退到伙伴系统
    cprintf("Test 7: Large allocation fallback to buddy system\n");
ffffffffc0201bd8:	00002517          	auipc	a0,0x2
ffffffffc0201bdc:	86850513          	addi	a0,a0,-1944 # ffffffffc0203440 <buddy_pmm_manager+0x5e8>
ffffffffc0201be0:	d6cfe0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0201be4:	00002717          	auipc	a4,0x2
ffffffffc0201be8:	a8470713          	addi	a4,a4,-1404 # ffffffffc0203668 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201bec:	4781                	li	a5,0
ffffffffc0201bee:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201bf0:	7ff00593          	li	a1,2047
ffffffffc0201bf4:	a029                	j	ffffffffc0201bfe <slub_check+0x5b6>
ffffffffc0201bf6:	6714                	ld	a3,8(a4)
ffffffffc0201bf8:	0721                	addi	a4,a4,8
ffffffffc0201bfa:	02d5ea63          	bltu	a1,a3,ffffffffc0201c2e <slub_check+0x5e6>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201bfe:	2785                	addiw	a5,a5,1
ffffffffc0201c00:	fec79be3          	bne	a5,a2,ffffffffc0201bf6 <slub_check+0x5ae>
    if (size > SLUB_MAX_SIZE) {
ffffffffc0201c04:	6505                	lui	a0,0x1
ffffffffc0201c06:	80150513          	addi	a0,a0,-2047 # 801 <kern_entry-0xffffffffc01ff7ff>
ffffffffc0201c0a:	e84ff0ef          	jal	ra,ffffffffc020128e <slub_alloc.part.0>
    
    // 测试边界值: SLUB_MAX_SIZE vs SLUB_MAX_SIZE+1
    void *p_max_slub = slub_alloc(SLUB_MAX_SIZE);
    void *p_min_buddy = slub_alloc(SLUB_MAX_SIZE + 1);
    assert(p_max_slub != NULL && p_min_buddy != NULL);
ffffffffc0201c0e:	00002697          	auipc	a3,0x2
ffffffffc0201c12:	86a68693          	addi	a3,a3,-1942 # ffffffffc0203478 <buddy_pmm_manager+0x620>
ffffffffc0201c16:	00001617          	auipc	a2,0x1
ffffffffc0201c1a:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201c1e:	1c300593          	li	a1,451
ffffffffc0201c22:	00001517          	auipc	a0,0x1
ffffffffc0201c26:	41e50513          	addi	a0,a0,1054 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201c2a:	d98fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc0201c2e:	00379513          	slli	a0,a5,0x3
ffffffffc0201c32:	97aa                	add	a5,a5,a0
ffffffffc0201c34:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201c38:	954a                	add	a0,a0,s2
ffffffffc0201c3a:	ee0ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201c3e:	6a85                	lui	s5,0x1
ffffffffc0201c40:	8a2a                	mv	s4,a0
ffffffffc0201c42:	801a8513          	addi	a0,s5,-2047 # 801 <kern_entry-0xffffffffc01ff7ff>
    if (size > SLUB_MAX_SIZE) {
ffffffffc0201c46:	e48ff0ef          	jal	ra,ffffffffc020128e <slub_alloc.part.0>
ffffffffc0201c4a:	89aa                	mv	s3,a0
    assert(p_max_slub != NULL && p_min_buddy != NULL);
ffffffffc0201c4c:	fc0a01e3          	beqz	s4,ffffffffc0201c0e <slub_check+0x5c6>
ffffffffc0201c50:	dd5d                	beqz	a0,ffffffffc0201c0e <slub_check+0x5c6>
    
    // 验证地址特征
    uintptr_t offset_slub = (uintptr_t)p_max_slub - ROUNDDOWN((uintptr_t)p_max_slub, PGSIZE);
    uintptr_t offset_buddy = (uintptr_t)p_min_buddy - ROUNDDOWN((uintptr_t)p_min_buddy, PGSIZE);
ffffffffc0201c52:	fffa8613          	addi	a2,s5,-1
ffffffffc0201c56:	00c57433          	and	s0,a0,a2
    cprintf("  SLUB_MAX_SIZE: addr=%p, offset=%lu (SLUB)\n", p_max_slub, offset_slub);
ffffffffc0201c5a:	85d2                	mv	a1,s4
ffffffffc0201c5c:	00ca7633          	and	a2,s4,a2
ffffffffc0201c60:	00002517          	auipc	a0,0x2
ffffffffc0201c64:	84850513          	addi	a0,a0,-1976 # ffffffffc02034a8 <buddy_pmm_manager+0x650>
ffffffffc0201c68:	ce4fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  SLUB_MAX_SIZE+1: addr=%p, offset=%lu (Buddy)\n", p_min_buddy, offset_buddy);
ffffffffc0201c6c:	8622                	mv	a2,s0
ffffffffc0201c6e:	85ce                	mv	a1,s3
ffffffffc0201c70:	00002517          	auipc	a0,0x2
ffffffffc0201c74:	86850513          	addi	a0,a0,-1944 # ffffffffc02034d8 <buddy_pmm_manager+0x680>
ffffffffc0201c78:	cd4fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(offset_buddy == LARGE_BLOCK_HEADER_SIZE);
ffffffffc0201c7c:	47c1                	li	a5,16
ffffffffc0201c7e:	1cf41263          	bne	s0,a5,ffffffffc0201e42 <slub_check+0x7fa>
    if (size > SLUB_MAX_SIZE) {
ffffffffc0201c82:	6511                	lui	a0,0x4
ffffffffc0201c84:	e0aff0ef          	jal	ra,ffffffffc020128e <slub_alloc.part.0>
ffffffffc0201c88:	842a                	mv	s0,a0
    
    // 测试多页分配和内存读写
    void *p_large = slub_alloc(PGSIZE * 4);
    assert(p_large != NULL);
ffffffffc0201c8a:	14050c63          	beqz	a0,ffffffffc0201de2 <slub_check+0x79a>
    cprintf("  Allocated 4 pages at %p\n", p_large);
ffffffffc0201c8e:	85aa                	mv	a1,a0
ffffffffc0201c90:	00002517          	auipc	a0,0x2
ffffffffc0201c94:	8b050513          	addi	a0,a0,-1872 # ffffffffc0203540 <buddy_pmm_manager+0x6e8>
ffffffffc0201c98:	cb4fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 写入测试
    memset(p_large, 0xAA, PGSIZE);
ffffffffc0201c9c:	6605                	lui	a2,0x1
ffffffffc0201c9e:	0aa00593          	li	a1,170
ffffffffc0201ca2:	8522                	mv	a0,s0
ffffffffc0201ca4:	706000ef          	jal	ra,ffffffffc02023aa <memset>
    assert(((char *)p_large)[0] == (char)0xAA);
ffffffffc0201ca8:	00044703          	lbu	a4,0(s0)
ffffffffc0201cac:	0aa00793          	li	a5,170
ffffffffc0201cb0:	1af71963          	bne	a4,a5,ffffffffc0201e62 <slub_check+0x81a>
    assert(((char *)p_large)[PGSIZE - 1] == (char)0xAA);
ffffffffc0201cb4:	9aa2                	add	s5,s5,s0
ffffffffc0201cb6:	fffac583          	lbu	a1,-1(s5)
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201cba:	4781                	li	a5,0
ffffffffc0201cbc:	46a1                	li	a3,8
        if (cache_sizes[i] >= size) {
ffffffffc0201cbe:	03f00613          	li	a2,63
    assert(((char *)p_large)[PGSIZE - 1] == (char)0xAA);
ffffffffc0201cc2:	00e58763          	beq	a1,a4,ffffffffc0201cd0 <slub_check+0x688>
ffffffffc0201cc6:	aa75                	j	ffffffffc0201e82 <slub_check+0x83a>
        if (cache_sizes[i] >= size) {
ffffffffc0201cc8:	6498                	ld	a4,8(s1)
ffffffffc0201cca:	04a1                	addi	s1,s1,8
ffffffffc0201ccc:	02e66563          	bltu	a2,a4,ffffffffc0201cf6 <slub_check+0x6ae>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201cd0:	2785                	addiw	a5,a5,1
ffffffffc0201cd2:	fed79be3          	bne	a5,a3,ffffffffc0201cc8 <slub_check+0x680>
    
    // 混合分配测试
    void *p_small_mix = slub_alloc(64);
    assert(p_small_mix != NULL);
ffffffffc0201cd6:	00002697          	auipc	a3,0x2
ffffffffc0201cda:	8e268693          	addi	a3,a3,-1822 # ffffffffc02035b8 <buddy_pmm_manager+0x760>
ffffffffc0201cde:	00001617          	auipc	a2,0x1
ffffffffc0201ce2:	9b260613          	addi	a2,a2,-1614 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201ce6:	1d800593          	li	a1,472
ffffffffc0201cea:	00001517          	auipc	a0,0x1
ffffffffc0201cee:	35650513          	addi	a0,a0,854 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201cf2:	cd0fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc0201cf6:	00379513          	slli	a0,a5,0x3
ffffffffc0201cfa:	97aa                	add	a5,a5,a0
ffffffffc0201cfc:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201d00:	954a                	add	a0,a0,s2
ffffffffc0201d02:	e18ff0ef          	jal	ra,ffffffffc020131a <kmem_cache_alloc>
ffffffffc0201d06:	84aa                	mv	s1,a0
    assert(p_small_mix != NULL);
ffffffffc0201d08:	d579                	beqz	a0,ffffffffc0201cd6 <slub_check+0x68e>
    cprintf("  Mixed allocation: small=%p, large=%p\n", p_small_mix, p_large);
ffffffffc0201d0a:	8622                	mv	a2,s0
ffffffffc0201d0c:	85aa                	mv	a1,a0
ffffffffc0201d0e:	00002517          	auipc	a0,0x2
ffffffffc0201d12:	8c250513          	addi	a0,a0,-1854 # ffffffffc02035d0 <buddy_pmm_manager+0x778>
ffffffffc0201d16:	c36fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return base_pmm->nr_free_pages();
ffffffffc0201d1a:	00001a97          	auipc	s5,0x1
ffffffffc0201d1e:	166aba83          	ld	s5,358(s5) # ffffffffc0202e80 <buddy_pmm_manager+0x28>
ffffffffc0201d22:	9a82                	jalr	s5
ffffffffc0201d24:	892a                	mv	s2,a0
    
    // 释放测试
    size_t free_before = slub_nr_free_pages();
    slub_free(p_max_slub);
ffffffffc0201d26:	8552                	mv	a0,s4
ffffffffc0201d28:	855ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p_min_buddy);
ffffffffc0201d2c:	854e                	mv	a0,s3
ffffffffc0201d2e:	84fff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p_large);
ffffffffc0201d32:	8522                	mv	a0,s0
ffffffffc0201d34:	849ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    slub_free(p_small_mix);
ffffffffc0201d38:	8526                	mv	a0,s1
ffffffffc0201d3a:	843ff0ef          	jal	ra,ffffffffc020157c <slub_free>
    return base_pmm->nr_free_pages();
ffffffffc0201d3e:	9a82                	jalr	s5
    size_t free_after = slub_nr_free_pages();
    cprintf("  Pages recovered: %lu\n", free_after - free_before);
ffffffffc0201d40:	412505b3          	sub	a1,a0,s2
ffffffffc0201d44:	00002517          	auipc	a0,0x2
ffffffffc0201d48:	8b450513          	addi	a0,a0,-1868 # ffffffffc02035f8 <buddy_pmm_manager+0x7a0>
ffffffffc0201d4c:	c00fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    cprintf("  Test 7 passed!\n");
ffffffffc0201d50:	00002517          	auipc	a0,0x2
ffffffffc0201d54:	8c050513          	addi	a0,a0,-1856 # ffffffffc0203610 <buddy_pmm_manager+0x7b8>
ffffffffc0201d58:	bf4fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    cprintf("=== SLUB allocator check passed! ===\n");
}
ffffffffc0201d5c:	740a                	ld	s0,160(sp)
ffffffffc0201d5e:	70aa                	ld	ra,168(sp)
ffffffffc0201d60:	64ea                	ld	s1,152(sp)
ffffffffc0201d62:	694a                	ld	s2,144(sp)
ffffffffc0201d64:	69aa                	ld	s3,136(sp)
ffffffffc0201d66:	6a0a                	ld	s4,128(sp)
ffffffffc0201d68:	7ae6                	ld	s5,120(sp)
ffffffffc0201d6a:	7b46                	ld	s6,112(sp)
ffffffffc0201d6c:	7ba6                	ld	s7,104(sp)
ffffffffc0201d6e:	7c06                	ld	s8,96(sp)
ffffffffc0201d70:	6ce6                	ld	s9,88(sp)
ffffffffc0201d72:	6d46                	ld	s10,80(sp)
    cprintf("=== SLUB allocator check passed! ===\n");
ffffffffc0201d74:	00002517          	auipc	a0,0x2
ffffffffc0201d78:	8b450513          	addi	a0,a0,-1868 # ffffffffc0203628 <buddy_pmm_manager+0x7d0>
}
ffffffffc0201d7c:	614d                	addi	sp,sp,176
    cprintf("=== SLUB allocator check passed! ===\n");
ffffffffc0201d7e:	bcefe06f          	j	ffffffffc020014c <cprintf>
        assert(pi[i] == i * i);
ffffffffc0201d82:	00001697          	auipc	a3,0x1
ffffffffc0201d86:	69668693          	addi	a3,a3,1686 # ffffffffc0203418 <buddy_pmm_manager+0x5c0>
ffffffffc0201d8a:	00001617          	auipc	a2,0x1
ffffffffc0201d8e:	90660613          	addi	a2,a2,-1786 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201d92:	1b800593          	li	a1,440
ffffffffc0201d96:	00001517          	auipc	a0,0x1
ffffffffc0201d9a:	2aa50513          	addi	a0,a0,682 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201d9e:	c24fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(objs[i] != NULL);
ffffffffc0201da2:	00001697          	auipc	a3,0x1
ffffffffc0201da6:	5ae68693          	addi	a3,a3,1454 # ffffffffc0203350 <buddy_pmm_manager+0x4f8>
ffffffffc0201daa:	00001617          	auipc	a2,0x1
ffffffffc0201dae:	8e660613          	addi	a2,a2,-1818 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201db2:	18600593          	li	a1,390
ffffffffc0201db6:	00001517          	auipc	a0,0x1
ffffffffc0201dba:	28a50513          	addi	a0,a0,650 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201dbe:	c04fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_small != NULL);
ffffffffc0201dc2:	00001697          	auipc	a3,0x1
ffffffffc0201dc6:	5fe68693          	addi	a3,a3,1534 # ffffffffc02033c0 <buddy_pmm_manager+0x568>
ffffffffc0201dca:	00001617          	auipc	a2,0x1
ffffffffc0201dce:	8c660613          	addi	a2,a2,-1850 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201dd2:	1a800593          	li	a1,424
ffffffffc0201dd6:	00001517          	auipc	a0,0x1
ffffffffc0201dda:	26a50513          	addi	a0,a0,618 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201dde:	be4fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_large != NULL);
ffffffffc0201de2:	00001697          	auipc	a3,0x1
ffffffffc0201de6:	74e68693          	addi	a3,a3,1870 # ffffffffc0203530 <buddy_pmm_manager+0x6d8>
ffffffffc0201dea:	00001617          	auipc	a2,0x1
ffffffffc0201dee:	8a660613          	addi	a2,a2,-1882 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201df2:	1ce00593          	li	a1,462
ffffffffc0201df6:	00001517          	auipc	a0,0x1
ffffffffc0201dfa:	24a50513          	addi	a0,a0,586 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201dfe:	bc4fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p16 != NULL && p32 != NULL && p64 != NULL && p128 != NULL);
ffffffffc0201e02:	00001697          	auipc	a3,0x1
ffffffffc0201e06:	3f668693          	addi	a3,a3,1014 # ffffffffc02031f8 <buddy_pmm_manager+0x3a0>
ffffffffc0201e0a:	00001617          	auipc	a2,0x1
ffffffffc0201e0e:	88660613          	addi	a2,a2,-1914 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201e12:	16e00593          	li	a1,366
ffffffffc0201e16:	00001517          	auipc	a0,0x1
ffffffffc0201e1a:	22a50513          	addi	a0,a0,554 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201e1e:	ba4fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != p2);
ffffffffc0201e22:	00001697          	auipc	a3,0x1
ffffffffc0201e26:	31668693          	addi	a3,a3,790 # ffffffffc0203138 <buddy_pmm_manager+0x2e0>
ffffffffc0201e2a:	00001617          	auipc	a2,0x1
ffffffffc0201e2e:	86660613          	addi	a2,a2,-1946 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201e32:	14f00593          	li	a1,335
ffffffffc0201e36:	00001517          	auipc	a0,0x1
ffffffffc0201e3a:	20a50513          	addi	a0,a0,522 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201e3e:	b84fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(offset_buddy == LARGE_BLOCK_HEADER_SIZE);
ffffffffc0201e42:	00001697          	auipc	a3,0x1
ffffffffc0201e46:	6c668693          	addi	a3,a3,1734 # ffffffffc0203508 <buddy_pmm_manager+0x6b0>
ffffffffc0201e4a:	00001617          	auipc	a2,0x1
ffffffffc0201e4e:	84660613          	addi	a2,a2,-1978 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201e52:	1ca00593          	li	a1,458
ffffffffc0201e56:	00001517          	auipc	a0,0x1
ffffffffc0201e5a:	1ea50513          	addi	a0,a0,490 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201e5e:	b64fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(((char *)p_large)[0] == (char)0xAA);
ffffffffc0201e62:	00001697          	auipc	a3,0x1
ffffffffc0201e66:	6fe68693          	addi	a3,a3,1790 # ffffffffc0203560 <buddy_pmm_manager+0x708>
ffffffffc0201e6a:	00001617          	auipc	a2,0x1
ffffffffc0201e6e:	82660613          	addi	a2,a2,-2010 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201e72:	1d300593          	li	a1,467
ffffffffc0201e76:	00001517          	auipc	a0,0x1
ffffffffc0201e7a:	1ca50513          	addi	a0,a0,458 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201e7e:	b44fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(((char *)p_large)[PGSIZE - 1] == (char)0xAA);
ffffffffc0201e82:	00001697          	auipc	a3,0x1
ffffffffc0201e86:	70668693          	addi	a3,a3,1798 # ffffffffc0203588 <buddy_pmm_manager+0x730>
ffffffffc0201e8a:	00001617          	auipc	a2,0x1
ffffffffc0201e8e:	80660613          	addi	a2,a2,-2042 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201e92:	1d400593          	li	a1,468
ffffffffc0201e96:	00001517          	auipc	a0,0x1
ffffffffc0201e9a:	1aa50513          	addi	a0,a0,426 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201e9e:	b24fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p256 != NULL && p512 != NULL && p1024 != NULL && p2048 != NULL);
ffffffffc0201ea2:	00001697          	auipc	a3,0x1
ffffffffc0201ea6:	39668693          	addi	a3,a3,918 # ffffffffc0203238 <buddy_pmm_manager+0x3e0>
ffffffffc0201eaa:	00000617          	auipc	a2,0x0
ffffffffc0201eae:	7e660613          	addi	a2,a2,2022 # ffffffffc0202690 <etext+0x2d4>
ffffffffc0201eb2:	16f00593          	li	a1,367
ffffffffc0201eb6:	00001517          	auipc	a0,0x1
ffffffffc0201eba:	18a50513          	addi	a0,a0,394 # ffffffffc0203040 <buddy_pmm_manager+0x1e8>
ffffffffc0201ebe:	b04fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    int num_objs = cache->num * 3; // 分配3个slab的对象
ffffffffc0201ec2:	00803783          	ld	a5,8(zero) # 8 <kern_entry-0xffffffffc01ffff8>
ffffffffc0201ec6:	9002                	ebreak

ffffffffc0201ec8 <printnum>:
ffffffffc0201ec8:	02069813          	slli	a6,a3,0x20
ffffffffc0201ecc:	7179                	addi	sp,sp,-48
ffffffffc0201ece:	02085813          	srli	a6,a6,0x20
ffffffffc0201ed2:	e052                	sd	s4,0(sp)
ffffffffc0201ed4:	03067a33          	remu	s4,a2,a6
ffffffffc0201ed8:	f022                	sd	s0,32(sp)
ffffffffc0201eda:	ec26                	sd	s1,24(sp)
ffffffffc0201edc:	e84a                	sd	s2,16(sp)
ffffffffc0201ede:	f406                	sd	ra,40(sp)
ffffffffc0201ee0:	e44e                	sd	s3,8(sp)
ffffffffc0201ee2:	84aa                	mv	s1,a0
ffffffffc0201ee4:	892e                	mv	s2,a1
ffffffffc0201ee6:	fff7041b          	addiw	s0,a4,-1
ffffffffc0201eea:	2a01                	sext.w	s4,s4
ffffffffc0201eec:	03067e63          	bgeu	a2,a6,ffffffffc0201f28 <printnum+0x60>
ffffffffc0201ef0:	89be                	mv	s3,a5
ffffffffc0201ef2:	00805763          	blez	s0,ffffffffc0201f00 <printnum+0x38>
ffffffffc0201ef6:	347d                	addiw	s0,s0,-1
ffffffffc0201ef8:	85ca                	mv	a1,s2
ffffffffc0201efa:	854e                	mv	a0,s3
ffffffffc0201efc:	9482                	jalr	s1
ffffffffc0201efe:	fc65                	bnez	s0,ffffffffc0201ef6 <printnum+0x2e>
ffffffffc0201f00:	1a02                	slli	s4,s4,0x20
ffffffffc0201f02:	00001797          	auipc	a5,0x1
ffffffffc0201f06:	7de78793          	addi	a5,a5,2014 # ffffffffc02036e0 <slub_pmm_manager+0x38>
ffffffffc0201f0a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201f0e:	9a3e                	add	s4,s4,a5
ffffffffc0201f10:	7402                	ld	s0,32(sp)
ffffffffc0201f12:	000a4503          	lbu	a0,0(s4)
ffffffffc0201f16:	70a2                	ld	ra,40(sp)
ffffffffc0201f18:	69a2                	ld	s3,8(sp)
ffffffffc0201f1a:	6a02                	ld	s4,0(sp)
ffffffffc0201f1c:	85ca                	mv	a1,s2
ffffffffc0201f1e:	87a6                	mv	a5,s1
ffffffffc0201f20:	6942                	ld	s2,16(sp)
ffffffffc0201f22:	64e2                	ld	s1,24(sp)
ffffffffc0201f24:	6145                	addi	sp,sp,48
ffffffffc0201f26:	8782                	jr	a5
ffffffffc0201f28:	03065633          	divu	a2,a2,a6
ffffffffc0201f2c:	8722                	mv	a4,s0
ffffffffc0201f2e:	f9bff0ef          	jal	ra,ffffffffc0201ec8 <printnum>
ffffffffc0201f32:	b7f9                	j	ffffffffc0201f00 <printnum+0x38>

ffffffffc0201f34 <sprintputch>:
ffffffffc0201f34:	499c                	lw	a5,16(a1)
ffffffffc0201f36:	6198                	ld	a4,0(a1)
ffffffffc0201f38:	6594                	ld	a3,8(a1)
ffffffffc0201f3a:	2785                	addiw	a5,a5,1
ffffffffc0201f3c:	c99c                	sw	a5,16(a1)
ffffffffc0201f3e:	00d77763          	bgeu	a4,a3,ffffffffc0201f4c <sprintputch+0x18>
ffffffffc0201f42:	00170793          	addi	a5,a4,1
ffffffffc0201f46:	e19c                	sd	a5,0(a1)
ffffffffc0201f48:	00a70023          	sb	a0,0(a4)
ffffffffc0201f4c:	8082                	ret

ffffffffc0201f4e <vprintfmt>:
ffffffffc0201f4e:	7119                	addi	sp,sp,-128
ffffffffc0201f50:	f4a6                	sd	s1,104(sp)
ffffffffc0201f52:	f0ca                	sd	s2,96(sp)
ffffffffc0201f54:	ecce                	sd	s3,88(sp)
ffffffffc0201f56:	e8d2                	sd	s4,80(sp)
ffffffffc0201f58:	e4d6                	sd	s5,72(sp)
ffffffffc0201f5a:	e0da                	sd	s6,64(sp)
ffffffffc0201f5c:	fc5e                	sd	s7,56(sp)
ffffffffc0201f5e:	f06a                	sd	s10,32(sp)
ffffffffc0201f60:	fc86                	sd	ra,120(sp)
ffffffffc0201f62:	f8a2                	sd	s0,112(sp)
ffffffffc0201f64:	f862                	sd	s8,48(sp)
ffffffffc0201f66:	f466                	sd	s9,40(sp)
ffffffffc0201f68:	ec6e                	sd	s11,24(sp)
ffffffffc0201f6a:	892a                	mv	s2,a0
ffffffffc0201f6c:	84ae                	mv	s1,a1
ffffffffc0201f6e:	8d32                	mv	s10,a2
ffffffffc0201f70:	8a36                	mv	s4,a3
ffffffffc0201f72:	02500993          	li	s3,37
ffffffffc0201f76:	5b7d                	li	s6,-1
ffffffffc0201f78:	00001a97          	auipc	s5,0x1
ffffffffc0201f7c:	79ca8a93          	addi	s5,s5,1948 # ffffffffc0203714 <slub_pmm_manager+0x6c>
ffffffffc0201f80:	00002b97          	auipc	s7,0x2
ffffffffc0201f84:	970b8b93          	addi	s7,s7,-1680 # ffffffffc02038f0 <error_string>
ffffffffc0201f88:	000d4503          	lbu	a0,0(s10)
ffffffffc0201f8c:	001d0413          	addi	s0,s10,1
ffffffffc0201f90:	01350a63          	beq	a0,s3,ffffffffc0201fa4 <vprintfmt+0x56>
ffffffffc0201f94:	c121                	beqz	a0,ffffffffc0201fd4 <vprintfmt+0x86>
ffffffffc0201f96:	85a6                	mv	a1,s1
ffffffffc0201f98:	0405                	addi	s0,s0,1
ffffffffc0201f9a:	9902                	jalr	s2
ffffffffc0201f9c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201fa0:	ff351ae3          	bne	a0,s3,ffffffffc0201f94 <vprintfmt+0x46>
ffffffffc0201fa4:	00044603          	lbu	a2,0(s0)
ffffffffc0201fa8:	02000793          	li	a5,32
ffffffffc0201fac:	4c81                	li	s9,0
ffffffffc0201fae:	4881                	li	a7,0
ffffffffc0201fb0:	5c7d                	li	s8,-1
ffffffffc0201fb2:	5dfd                	li	s11,-1
ffffffffc0201fb4:	05500513          	li	a0,85
ffffffffc0201fb8:	4825                	li	a6,9
ffffffffc0201fba:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201fbe:	0ff5f593          	zext.b	a1,a1
ffffffffc0201fc2:	00140d13          	addi	s10,s0,1
ffffffffc0201fc6:	04b56263          	bltu	a0,a1,ffffffffc020200a <vprintfmt+0xbc>
ffffffffc0201fca:	058a                	slli	a1,a1,0x2
ffffffffc0201fcc:	95d6                	add	a1,a1,s5
ffffffffc0201fce:	4194                	lw	a3,0(a1)
ffffffffc0201fd0:	96d6                	add	a3,a3,s5
ffffffffc0201fd2:	8682                	jr	a3
ffffffffc0201fd4:	70e6                	ld	ra,120(sp)
ffffffffc0201fd6:	7446                	ld	s0,112(sp)
ffffffffc0201fd8:	74a6                	ld	s1,104(sp)
ffffffffc0201fda:	7906                	ld	s2,96(sp)
ffffffffc0201fdc:	69e6                	ld	s3,88(sp)
ffffffffc0201fde:	6a46                	ld	s4,80(sp)
ffffffffc0201fe0:	6aa6                	ld	s5,72(sp)
ffffffffc0201fe2:	6b06                	ld	s6,64(sp)
ffffffffc0201fe4:	7be2                	ld	s7,56(sp)
ffffffffc0201fe6:	7c42                	ld	s8,48(sp)
ffffffffc0201fe8:	7ca2                	ld	s9,40(sp)
ffffffffc0201fea:	7d02                	ld	s10,32(sp)
ffffffffc0201fec:	6de2                	ld	s11,24(sp)
ffffffffc0201fee:	6109                	addi	sp,sp,128
ffffffffc0201ff0:	8082                	ret
ffffffffc0201ff2:	87b2                	mv	a5,a2
ffffffffc0201ff4:	00144603          	lbu	a2,1(s0)
ffffffffc0201ff8:	846a                	mv	s0,s10
ffffffffc0201ffa:	00140d13          	addi	s10,s0,1
ffffffffc0201ffe:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0202002:	0ff5f593          	zext.b	a1,a1
ffffffffc0202006:	fcb572e3          	bgeu	a0,a1,ffffffffc0201fca <vprintfmt+0x7c>
ffffffffc020200a:	85a6                	mv	a1,s1
ffffffffc020200c:	02500513          	li	a0,37
ffffffffc0202010:	9902                	jalr	s2
ffffffffc0202012:	fff44783          	lbu	a5,-1(s0)
ffffffffc0202016:	8d22                	mv	s10,s0
ffffffffc0202018:	f73788e3          	beq	a5,s3,ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc020201c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0202020:	1d7d                	addi	s10,s10,-1
ffffffffc0202022:	ff379de3          	bne	a5,s3,ffffffffc020201c <vprintfmt+0xce>
ffffffffc0202026:	b78d                	j	ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc0202028:	fd060c1b          	addiw	s8,a2,-48
ffffffffc020202c:	00144603          	lbu	a2,1(s0)
ffffffffc0202030:	846a                	mv	s0,s10
ffffffffc0202032:	fd06069b          	addiw	a3,a2,-48
ffffffffc0202036:	0006059b          	sext.w	a1,a2
ffffffffc020203a:	02d86463          	bltu	a6,a3,ffffffffc0202062 <vprintfmt+0x114>
ffffffffc020203e:	00144603          	lbu	a2,1(s0)
ffffffffc0202042:	002c169b          	slliw	a3,s8,0x2
ffffffffc0202046:	0186873b          	addw	a4,a3,s8
ffffffffc020204a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020204e:	9f2d                	addw	a4,a4,a1
ffffffffc0202050:	fd06069b          	addiw	a3,a2,-48
ffffffffc0202054:	0405                	addi	s0,s0,1
ffffffffc0202056:	fd070c1b          	addiw	s8,a4,-48
ffffffffc020205a:	0006059b          	sext.w	a1,a2
ffffffffc020205e:	fed870e3          	bgeu	a6,a3,ffffffffc020203e <vprintfmt+0xf0>
ffffffffc0202062:	f40ddce3          	bgez	s11,ffffffffc0201fba <vprintfmt+0x6c>
ffffffffc0202066:	8de2                	mv	s11,s8
ffffffffc0202068:	5c7d                	li	s8,-1
ffffffffc020206a:	bf81                	j	ffffffffc0201fba <vprintfmt+0x6c>
ffffffffc020206c:	fffdc693          	not	a3,s11
ffffffffc0202070:	96fd                	srai	a3,a3,0x3f
ffffffffc0202072:	00ddfdb3          	and	s11,s11,a3
ffffffffc0202076:	00144603          	lbu	a2,1(s0)
ffffffffc020207a:	2d81                	sext.w	s11,s11
ffffffffc020207c:	846a                	mv	s0,s10
ffffffffc020207e:	bf35                	j	ffffffffc0201fba <vprintfmt+0x6c>
ffffffffc0202080:	000a2c03          	lw	s8,0(s4)
ffffffffc0202084:	00144603          	lbu	a2,1(s0)
ffffffffc0202088:	0a21                	addi	s4,s4,8
ffffffffc020208a:	846a                	mv	s0,s10
ffffffffc020208c:	bfd9                	j	ffffffffc0202062 <vprintfmt+0x114>
ffffffffc020208e:	4705                	li	a4,1
ffffffffc0202090:	008a0593          	addi	a1,s4,8
ffffffffc0202094:	01174463          	blt	a4,a7,ffffffffc020209c <vprintfmt+0x14e>
ffffffffc0202098:	1a088e63          	beqz	a7,ffffffffc0202254 <vprintfmt+0x306>
ffffffffc020209c:	000a3603          	ld	a2,0(s4)
ffffffffc02020a0:	46c1                	li	a3,16
ffffffffc02020a2:	8a2e                	mv	s4,a1
ffffffffc02020a4:	2781                	sext.w	a5,a5
ffffffffc02020a6:	876e                	mv	a4,s11
ffffffffc02020a8:	85a6                	mv	a1,s1
ffffffffc02020aa:	854a                	mv	a0,s2
ffffffffc02020ac:	e1dff0ef          	jal	ra,ffffffffc0201ec8 <printnum>
ffffffffc02020b0:	bde1                	j	ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc02020b2:	000a2503          	lw	a0,0(s4)
ffffffffc02020b6:	85a6                	mv	a1,s1
ffffffffc02020b8:	0a21                	addi	s4,s4,8
ffffffffc02020ba:	9902                	jalr	s2
ffffffffc02020bc:	b5f1                	j	ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc02020be:	4705                	li	a4,1
ffffffffc02020c0:	008a0593          	addi	a1,s4,8
ffffffffc02020c4:	01174463          	blt	a4,a7,ffffffffc02020cc <vprintfmt+0x17e>
ffffffffc02020c8:	18088163          	beqz	a7,ffffffffc020224a <vprintfmt+0x2fc>
ffffffffc02020cc:	000a3603          	ld	a2,0(s4)
ffffffffc02020d0:	46a9                	li	a3,10
ffffffffc02020d2:	8a2e                	mv	s4,a1
ffffffffc02020d4:	bfc1                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc02020d6:	00144603          	lbu	a2,1(s0)
ffffffffc02020da:	4c85                	li	s9,1
ffffffffc02020dc:	846a                	mv	s0,s10
ffffffffc02020de:	bdf1                	j	ffffffffc0201fba <vprintfmt+0x6c>
ffffffffc02020e0:	85a6                	mv	a1,s1
ffffffffc02020e2:	02500513          	li	a0,37
ffffffffc02020e6:	9902                	jalr	s2
ffffffffc02020e8:	b545                	j	ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc02020ea:	00144603          	lbu	a2,1(s0)
ffffffffc02020ee:	2885                	addiw	a7,a7,1
ffffffffc02020f0:	846a                	mv	s0,s10
ffffffffc02020f2:	b5e1                	j	ffffffffc0201fba <vprintfmt+0x6c>
ffffffffc02020f4:	4705                	li	a4,1
ffffffffc02020f6:	008a0593          	addi	a1,s4,8
ffffffffc02020fa:	01174463          	blt	a4,a7,ffffffffc0202102 <vprintfmt+0x1b4>
ffffffffc02020fe:	14088163          	beqz	a7,ffffffffc0202240 <vprintfmt+0x2f2>
ffffffffc0202102:	000a3603          	ld	a2,0(s4)
ffffffffc0202106:	46a1                	li	a3,8
ffffffffc0202108:	8a2e                	mv	s4,a1
ffffffffc020210a:	bf69                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc020210c:	03000513          	li	a0,48
ffffffffc0202110:	85a6                	mv	a1,s1
ffffffffc0202112:	e03e                	sd	a5,0(sp)
ffffffffc0202114:	9902                	jalr	s2
ffffffffc0202116:	85a6                	mv	a1,s1
ffffffffc0202118:	07800513          	li	a0,120
ffffffffc020211c:	9902                	jalr	s2
ffffffffc020211e:	0a21                	addi	s4,s4,8
ffffffffc0202120:	6782                	ld	a5,0(sp)
ffffffffc0202122:	46c1                	li	a3,16
ffffffffc0202124:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0202128:	bfb5                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc020212a:	000a3403          	ld	s0,0(s4)
ffffffffc020212e:	008a0713          	addi	a4,s4,8
ffffffffc0202132:	e03a                	sd	a4,0(sp)
ffffffffc0202134:	14040263          	beqz	s0,ffffffffc0202278 <vprintfmt+0x32a>
ffffffffc0202138:	0fb05763          	blez	s11,ffffffffc0202226 <vprintfmt+0x2d8>
ffffffffc020213c:	02d00693          	li	a3,45
ffffffffc0202140:	0cd79163          	bne	a5,a3,ffffffffc0202202 <vprintfmt+0x2b4>
ffffffffc0202144:	00044783          	lbu	a5,0(s0)
ffffffffc0202148:	0007851b          	sext.w	a0,a5
ffffffffc020214c:	cf85                	beqz	a5,ffffffffc0202184 <vprintfmt+0x236>
ffffffffc020214e:	00140a13          	addi	s4,s0,1
ffffffffc0202152:	05e00413          	li	s0,94
ffffffffc0202156:	000c4563          	bltz	s8,ffffffffc0202160 <vprintfmt+0x212>
ffffffffc020215a:	3c7d                	addiw	s8,s8,-1
ffffffffc020215c:	036c0263          	beq	s8,s6,ffffffffc0202180 <vprintfmt+0x232>
ffffffffc0202160:	85a6                	mv	a1,s1
ffffffffc0202162:	0e0c8e63          	beqz	s9,ffffffffc020225e <vprintfmt+0x310>
ffffffffc0202166:	3781                	addiw	a5,a5,-32
ffffffffc0202168:	0ef47b63          	bgeu	s0,a5,ffffffffc020225e <vprintfmt+0x310>
ffffffffc020216c:	03f00513          	li	a0,63
ffffffffc0202170:	9902                	jalr	s2
ffffffffc0202172:	000a4783          	lbu	a5,0(s4)
ffffffffc0202176:	3dfd                	addiw	s11,s11,-1
ffffffffc0202178:	0a05                	addi	s4,s4,1
ffffffffc020217a:	0007851b          	sext.w	a0,a5
ffffffffc020217e:	ffe1                	bnez	a5,ffffffffc0202156 <vprintfmt+0x208>
ffffffffc0202180:	01b05963          	blez	s11,ffffffffc0202192 <vprintfmt+0x244>
ffffffffc0202184:	3dfd                	addiw	s11,s11,-1
ffffffffc0202186:	85a6                	mv	a1,s1
ffffffffc0202188:	02000513          	li	a0,32
ffffffffc020218c:	9902                	jalr	s2
ffffffffc020218e:	fe0d9be3          	bnez	s11,ffffffffc0202184 <vprintfmt+0x236>
ffffffffc0202192:	6a02                	ld	s4,0(sp)
ffffffffc0202194:	bbd5                	j	ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc0202196:	4705                	li	a4,1
ffffffffc0202198:	008a0c93          	addi	s9,s4,8
ffffffffc020219c:	01174463          	blt	a4,a7,ffffffffc02021a4 <vprintfmt+0x256>
ffffffffc02021a0:	08088d63          	beqz	a7,ffffffffc020223a <vprintfmt+0x2ec>
ffffffffc02021a4:	000a3403          	ld	s0,0(s4)
ffffffffc02021a8:	0a044d63          	bltz	s0,ffffffffc0202262 <vprintfmt+0x314>
ffffffffc02021ac:	8622                	mv	a2,s0
ffffffffc02021ae:	8a66                	mv	s4,s9
ffffffffc02021b0:	46a9                	li	a3,10
ffffffffc02021b2:	bdcd                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc02021b4:	000a2783          	lw	a5,0(s4)
ffffffffc02021b8:	4719                	li	a4,6
ffffffffc02021ba:	0a21                	addi	s4,s4,8
ffffffffc02021bc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02021c0:	8fb5                	xor	a5,a5,a3
ffffffffc02021c2:	40d786bb          	subw	a3,a5,a3
ffffffffc02021c6:	02d74163          	blt	a4,a3,ffffffffc02021e8 <vprintfmt+0x29a>
ffffffffc02021ca:	00369793          	slli	a5,a3,0x3
ffffffffc02021ce:	97de                	add	a5,a5,s7
ffffffffc02021d0:	639c                	ld	a5,0(a5)
ffffffffc02021d2:	cb99                	beqz	a5,ffffffffc02021e8 <vprintfmt+0x29a>
ffffffffc02021d4:	86be                	mv	a3,a5
ffffffffc02021d6:	00001617          	auipc	a2,0x1
ffffffffc02021da:	53a60613          	addi	a2,a2,1338 # ffffffffc0203710 <slub_pmm_manager+0x68>
ffffffffc02021de:	85a6                	mv	a1,s1
ffffffffc02021e0:	854a                	mv	a0,s2
ffffffffc02021e2:	0ce000ef          	jal	ra,ffffffffc02022b0 <printfmt>
ffffffffc02021e6:	b34d                	j	ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc02021e8:	00001617          	auipc	a2,0x1
ffffffffc02021ec:	51860613          	addi	a2,a2,1304 # ffffffffc0203700 <slub_pmm_manager+0x58>
ffffffffc02021f0:	85a6                	mv	a1,s1
ffffffffc02021f2:	854a                	mv	a0,s2
ffffffffc02021f4:	0bc000ef          	jal	ra,ffffffffc02022b0 <printfmt>
ffffffffc02021f8:	bb41                	j	ffffffffc0201f88 <vprintfmt+0x3a>
ffffffffc02021fa:	00001417          	auipc	s0,0x1
ffffffffc02021fe:	4fe40413          	addi	s0,s0,1278 # ffffffffc02036f8 <slub_pmm_manager+0x50>
ffffffffc0202202:	85e2                	mv	a1,s8
ffffffffc0202204:	8522                	mv	a0,s0
ffffffffc0202206:	e43e                	sd	a5,8(sp)
ffffffffc0202208:	142000ef          	jal	ra,ffffffffc020234a <strnlen>
ffffffffc020220c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0202210:	01b05b63          	blez	s11,ffffffffc0202226 <vprintfmt+0x2d8>
ffffffffc0202214:	67a2                	ld	a5,8(sp)
ffffffffc0202216:	00078a1b          	sext.w	s4,a5
ffffffffc020221a:	3dfd                	addiw	s11,s11,-1
ffffffffc020221c:	85a6                	mv	a1,s1
ffffffffc020221e:	8552                	mv	a0,s4
ffffffffc0202220:	9902                	jalr	s2
ffffffffc0202222:	fe0d9ce3          	bnez	s11,ffffffffc020221a <vprintfmt+0x2cc>
ffffffffc0202226:	00044783          	lbu	a5,0(s0)
ffffffffc020222a:	00140a13          	addi	s4,s0,1
ffffffffc020222e:	0007851b          	sext.w	a0,a5
ffffffffc0202232:	d3a5                	beqz	a5,ffffffffc0202192 <vprintfmt+0x244>
ffffffffc0202234:	05e00413          	li	s0,94
ffffffffc0202238:	bf39                	j	ffffffffc0202156 <vprintfmt+0x208>
ffffffffc020223a:	000a2403          	lw	s0,0(s4)
ffffffffc020223e:	b7ad                	j	ffffffffc02021a8 <vprintfmt+0x25a>
ffffffffc0202240:	000a6603          	lwu	a2,0(s4)
ffffffffc0202244:	46a1                	li	a3,8
ffffffffc0202246:	8a2e                	mv	s4,a1
ffffffffc0202248:	bdb1                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc020224a:	000a6603          	lwu	a2,0(s4)
ffffffffc020224e:	46a9                	li	a3,10
ffffffffc0202250:	8a2e                	mv	s4,a1
ffffffffc0202252:	bd89                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc0202254:	000a6603          	lwu	a2,0(s4)
ffffffffc0202258:	46c1                	li	a3,16
ffffffffc020225a:	8a2e                	mv	s4,a1
ffffffffc020225c:	b5a1                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc020225e:	9902                	jalr	s2
ffffffffc0202260:	bf09                	j	ffffffffc0202172 <vprintfmt+0x224>
ffffffffc0202262:	85a6                	mv	a1,s1
ffffffffc0202264:	02d00513          	li	a0,45
ffffffffc0202268:	e03e                	sd	a5,0(sp)
ffffffffc020226a:	9902                	jalr	s2
ffffffffc020226c:	6782                	ld	a5,0(sp)
ffffffffc020226e:	8a66                	mv	s4,s9
ffffffffc0202270:	40800633          	neg	a2,s0
ffffffffc0202274:	46a9                	li	a3,10
ffffffffc0202276:	b53d                	j	ffffffffc02020a4 <vprintfmt+0x156>
ffffffffc0202278:	03b05163          	blez	s11,ffffffffc020229a <vprintfmt+0x34c>
ffffffffc020227c:	02d00693          	li	a3,45
ffffffffc0202280:	f6d79de3          	bne	a5,a3,ffffffffc02021fa <vprintfmt+0x2ac>
ffffffffc0202284:	00001417          	auipc	s0,0x1
ffffffffc0202288:	47440413          	addi	s0,s0,1140 # ffffffffc02036f8 <slub_pmm_manager+0x50>
ffffffffc020228c:	02800793          	li	a5,40
ffffffffc0202290:	02800513          	li	a0,40
ffffffffc0202294:	00140a13          	addi	s4,s0,1
ffffffffc0202298:	bd6d                	j	ffffffffc0202152 <vprintfmt+0x204>
ffffffffc020229a:	00001a17          	auipc	s4,0x1
ffffffffc020229e:	45fa0a13          	addi	s4,s4,1119 # ffffffffc02036f9 <slub_pmm_manager+0x51>
ffffffffc02022a2:	02800513          	li	a0,40
ffffffffc02022a6:	02800793          	li	a5,40
ffffffffc02022aa:	05e00413          	li	s0,94
ffffffffc02022ae:	b565                	j	ffffffffc0202156 <vprintfmt+0x208>

ffffffffc02022b0 <printfmt>:
ffffffffc02022b0:	715d                	addi	sp,sp,-80
ffffffffc02022b2:	02810313          	addi	t1,sp,40
ffffffffc02022b6:	f436                	sd	a3,40(sp)
ffffffffc02022b8:	869a                	mv	a3,t1
ffffffffc02022ba:	ec06                	sd	ra,24(sp)
ffffffffc02022bc:	f83a                	sd	a4,48(sp)
ffffffffc02022be:	fc3e                	sd	a5,56(sp)
ffffffffc02022c0:	e0c2                	sd	a6,64(sp)
ffffffffc02022c2:	e4c6                	sd	a7,72(sp)
ffffffffc02022c4:	e41a                	sd	t1,8(sp)
ffffffffc02022c6:	c89ff0ef          	jal	ra,ffffffffc0201f4e <vprintfmt>
ffffffffc02022ca:	60e2                	ld	ra,24(sp)
ffffffffc02022cc:	6161                	addi	sp,sp,80
ffffffffc02022ce:	8082                	ret

ffffffffc02022d0 <snprintf>:
ffffffffc02022d0:	711d                	addi	sp,sp,-96
ffffffffc02022d2:	15fd                	addi	a1,a1,-1
ffffffffc02022d4:	03810313          	addi	t1,sp,56
ffffffffc02022d8:	95aa                	add	a1,a1,a0
ffffffffc02022da:	f406                	sd	ra,40(sp)
ffffffffc02022dc:	fc36                	sd	a3,56(sp)
ffffffffc02022de:	e0ba                	sd	a4,64(sp)
ffffffffc02022e0:	e4be                	sd	a5,72(sp)
ffffffffc02022e2:	e8c2                	sd	a6,80(sp)
ffffffffc02022e4:	ecc6                	sd	a7,88(sp)
ffffffffc02022e6:	e01a                	sd	t1,0(sp)
ffffffffc02022e8:	e42a                	sd	a0,8(sp)
ffffffffc02022ea:	e82e                	sd	a1,16(sp)
ffffffffc02022ec:	cc02                	sw	zero,24(sp)
ffffffffc02022ee:	c115                	beqz	a0,ffffffffc0202312 <snprintf+0x42>
ffffffffc02022f0:	02a5e163          	bltu	a1,a0,ffffffffc0202312 <snprintf+0x42>
ffffffffc02022f4:	00000517          	auipc	a0,0x0
ffffffffc02022f8:	c4050513          	addi	a0,a0,-960 # ffffffffc0201f34 <sprintputch>
ffffffffc02022fc:	869a                	mv	a3,t1
ffffffffc02022fe:	002c                	addi	a1,sp,8
ffffffffc0202300:	c4fff0ef          	jal	ra,ffffffffc0201f4e <vprintfmt>
ffffffffc0202304:	67a2                	ld	a5,8(sp)
ffffffffc0202306:	00078023          	sb	zero,0(a5)
ffffffffc020230a:	4562                	lw	a0,24(sp)
ffffffffc020230c:	70a2                	ld	ra,40(sp)
ffffffffc020230e:	6125                	addi	sp,sp,96
ffffffffc0202310:	8082                	ret
ffffffffc0202312:	5575                	li	a0,-3
ffffffffc0202314:	bfe5                	j	ffffffffc020230c <snprintf+0x3c>

ffffffffc0202316 <sbi_console_putchar>:
ffffffffc0202316:	4781                	li	a5,0
ffffffffc0202318:	00005717          	auipc	a4,0x5
ffffffffc020231c:	cf873703          	ld	a4,-776(a4) # ffffffffc0207010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0202320:	88ba                	mv	a7,a4
ffffffffc0202322:	852a                	mv	a0,a0
ffffffffc0202324:	85be                	mv	a1,a5
ffffffffc0202326:	863e                	mv	a2,a5
ffffffffc0202328:	00000073          	ecall
ffffffffc020232c:	87aa                	mv	a5,a0
ffffffffc020232e:	8082                	ret

ffffffffc0202330 <strlen>:
ffffffffc0202330:	00054783          	lbu	a5,0(a0)
ffffffffc0202334:	872a                	mv	a4,a0
ffffffffc0202336:	4501                	li	a0,0
ffffffffc0202338:	cb81                	beqz	a5,ffffffffc0202348 <strlen+0x18>
ffffffffc020233a:	0505                	addi	a0,a0,1
ffffffffc020233c:	00a707b3          	add	a5,a4,a0
ffffffffc0202340:	0007c783          	lbu	a5,0(a5)
ffffffffc0202344:	fbfd                	bnez	a5,ffffffffc020233a <strlen+0xa>
ffffffffc0202346:	8082                	ret
ffffffffc0202348:	8082                	ret

ffffffffc020234a <strnlen>:
ffffffffc020234a:	4781                	li	a5,0
ffffffffc020234c:	e589                	bnez	a1,ffffffffc0202356 <strnlen+0xc>
ffffffffc020234e:	a811                	j	ffffffffc0202362 <strnlen+0x18>
ffffffffc0202350:	0785                	addi	a5,a5,1
ffffffffc0202352:	00f58863          	beq	a1,a5,ffffffffc0202362 <strnlen+0x18>
ffffffffc0202356:	00f50733          	add	a4,a0,a5
ffffffffc020235a:	00074703          	lbu	a4,0(a4)
ffffffffc020235e:	fb6d                	bnez	a4,ffffffffc0202350 <strnlen+0x6>
ffffffffc0202360:	85be                	mv	a1,a5
ffffffffc0202362:	852e                	mv	a0,a1
ffffffffc0202364:	8082                	ret

ffffffffc0202366 <strcmp>:
ffffffffc0202366:	00054783          	lbu	a5,0(a0)
ffffffffc020236a:	0005c703          	lbu	a4,0(a1)
ffffffffc020236e:	cb89                	beqz	a5,ffffffffc0202380 <strcmp+0x1a>
ffffffffc0202370:	0505                	addi	a0,a0,1
ffffffffc0202372:	0585                	addi	a1,a1,1
ffffffffc0202374:	fee789e3          	beq	a5,a4,ffffffffc0202366 <strcmp>
ffffffffc0202378:	0007851b          	sext.w	a0,a5
ffffffffc020237c:	9d19                	subw	a0,a0,a4
ffffffffc020237e:	8082                	ret
ffffffffc0202380:	4501                	li	a0,0
ffffffffc0202382:	bfed                	j	ffffffffc020237c <strcmp+0x16>

ffffffffc0202384 <strncmp>:
ffffffffc0202384:	c20d                	beqz	a2,ffffffffc02023a6 <strncmp+0x22>
ffffffffc0202386:	962e                	add	a2,a2,a1
ffffffffc0202388:	a031                	j	ffffffffc0202394 <strncmp+0x10>
ffffffffc020238a:	0505                	addi	a0,a0,1
ffffffffc020238c:	00e79a63          	bne	a5,a4,ffffffffc02023a0 <strncmp+0x1c>
ffffffffc0202390:	00b60b63          	beq	a2,a1,ffffffffc02023a6 <strncmp+0x22>
ffffffffc0202394:	00054783          	lbu	a5,0(a0)
ffffffffc0202398:	0585                	addi	a1,a1,1
ffffffffc020239a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020239e:	f7f5                	bnez	a5,ffffffffc020238a <strncmp+0x6>
ffffffffc02023a0:	40e7853b          	subw	a0,a5,a4
ffffffffc02023a4:	8082                	ret
ffffffffc02023a6:	4501                	li	a0,0
ffffffffc02023a8:	8082                	ret

ffffffffc02023aa <memset>:
ffffffffc02023aa:	ca01                	beqz	a2,ffffffffc02023ba <memset+0x10>
ffffffffc02023ac:	962a                	add	a2,a2,a0
ffffffffc02023ae:	87aa                	mv	a5,a0
ffffffffc02023b0:	0785                	addi	a5,a5,1
ffffffffc02023b2:	feb78fa3          	sb	a1,-1(a5)
ffffffffc02023b6:	fec79de3          	bne	a5,a2,ffffffffc02023b0 <memset+0x6>
ffffffffc02023ba:	8082                	ret
