_start:
	lui	x2,0x10
	jal	x1,run

run:
	addi	x2,x2,-16 # fff0 <__global_pointer$+0xcf94>
	sw	x1,12(x2)
	sw	x8,8(x2)
	addi	x8,x2,16
#   print_pointer_address((void *)0);
	addi	x10,x0,0
	auipc	x1,0x0
	jalr	x1,16(x1) # 2c <print_pointer_address>
#   while (1) {
loop:
	addi	x0,x0,0
	jal	x0,loop

# void print_pointer_address(void *ptr) {
	addi	x2,x2,-64
	sw	x1,60(x2)
	sw	x8,56(x2)
	addi	x8,x2,64
	sw	x10,-52(x8)
#   const unsigned address = (unsigned)ptr;
	lw	x15,-52(x8)
	sw	x15,-24(x8)
#   *leds = (char)address;
	lui	x15,0x3
	lw	x15,-1056(x15) # 2be0 <leds>
	lw	x14,-24(x8)
	andi	x14,x14,255
	sb	x14,0(x15)
	jalr	x0,0(x1)

.org 0x2be0
.word 0xffffffff
