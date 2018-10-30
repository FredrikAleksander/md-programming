	.global _binary_z80data_start
	.global _binary_z80data_end

_binary_z80data_start:
	.word 0xaf01, 0xd91f           | xor a; ld bc, 0x1fd9
	.word 0x1127, 0x0021           | ld de, 0x0027
	.word 0x2600, 0xf977           | ld hl, 0x0026; ld sp, hl; ld (hl), a
	.word 0xedb0, 0xdde1           | ldir; pop ix
	.word 0xfde1, 0xed47           | pop iy; ld i, a
	.word 0xed4f, 0xd1e1           | ld r, a; pop de; pop hl
	.word 0xf108, 0xd9c1           | pop af; ex af, af; exx; pop bc
	.word 0xd1e1, 0xf1f9           | pop de; pop hl; pop af; ld sp, hl
	.word 0xf3ed, 0x5636           | di; im 1; ld (hl), 0xe9
	.word 0xe9e9, 0x8104           | jp (hl); add a,c; inc b
	.word 0x8f01                   | adc a,a; ???
_binary_z80data_end:
