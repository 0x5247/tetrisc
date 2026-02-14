.align 0x2

.globl fmt_x
.globl print_reg
.globl place_cur

.include "src/constants.inc"

.section .text
fmt_x:
	la a2, xdigits

0:
	andi a3, a1, 0xf
	add a3, a2, a3
	lb a3, (a3)

	c.addi a0, -0x1
	sb a3, (a0)

	c.srli a1, 0x4
	bnez a1, 0b

	c.jr ra

print_reg:
	c.addi sp, -0x4
	sw ra, (sp)
	c.addi sp, -0x4
	sw a0, (sp)
	c.addi sp, -0x4
	sw a1, (sp)
	c.addi sp, -0x4
	sw a2, (sp)
	c.addi sp, -0x4
	sw a3, (sp)
	c.addi sp, -0x4
	sw a7, (sp)

	c.li a1, '\n'
	sb a1, -0x1(sp)

	li a1, '0'
	sb a1, -0x2(sp)
	sb a1, -0x3(sp)
	sb a1, -0x4(sp)
	sb a1, -0x5(sp)
	sb a1, -0x6(sp)
	sb a1, -0x7(sp)
	sb a1, -0x8(sp)
	sb a1, -0x9(sp)

	addi a0, sp, -0x1
	mv a1, t0
	jal fmt_x

	c.li a0, STDOUT
	addi a1, sp, -0x9
	li a2, 0x9
	li a7, SYS_WRITE
	ecall

	lw a7, (sp)
	c.addi sp, 0x4
	lw a3, (sp)
	c.addi sp, 0x4
	lw a2, (sp)
	c.addi sp, 0x4
	lw a1, (sp)
	c.addi sp, 0x4
	lw a0, (sp)
	c.addi sp, 0x4
	lw ra, (sp)
	c.addi sp, 0x4

	c.jr ra

place_cur:
	c.addi sp, -0x4
	sw a0, (sp)
	c.addi sp, -0x4
	sw a1, (sp)
	c.addi sp, -0x4
	sw a2, (sp)
	c.addi sp, -0x4
	sw a3, (sp)

	addi a3, sp, -0x8

	c.li a2, ESC
	sb a2, 0x0(a3)
	li a2, '['
	sb a2, 0x1(a3)
	li a2, ';'
	sb a2, 0x4(a3)
	li a2, 'H'
	sb a2, 0x7(a3)

	sh t0, 0x2(a3)
	sh a7, 0x5(a3)

	c.li a0, STDOUT
	mv a1, a3
	c.li a2, 0x8
	li a7, SYS_WRITE
	ecall

	lw a3, (sp)
	c.addi sp, 0x4
	lw a2, (sp)
	c.addi sp, 0x4
	lw a1, (sp)
	c.addi sp, 0x4
	lw a0, (sp)
	c.addi sp, 0x4

	c.jr ra

.section .rodata
xdigits: .ascii "0123456789ABCDEF"
