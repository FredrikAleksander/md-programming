	.global __main
	.global __end
__main:
	ori.w #0x0000, %d0
	andi.w #0xDEAD, %d0
	jmp __main
__end:
