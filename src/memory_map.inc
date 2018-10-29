	| Gamepad registers
	.set pad_ctrl_a,     0xA10009
	.set pad_ctrl_b,     0xA1000B
	.set pad_ctrl_c,     0xA1000D
	.set pad_data_a,     0xA10003
	.set pad_data_b,     0xA10005
	.set pad_data_c,     0xA10007

	| VDP registers
	.set vdp_ctrl,       0xC00004
	.set vdp_data,       0xC00000

	| PSG registers
	.set psg_ctrl,       0xC00011

	| Z80
	.set z80_bus_access, 0xA11100
	.set z80_reset,      0xA11200
	.set z80_ram_start,  0xA00000

	.set ram_start,      0x00F00000
	.set hsync_counter,  ram_start
	.set vsync_counter,  ram_start + 0x04
