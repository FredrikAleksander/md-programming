	| Gamepad buttons
	.set pad_button_up         0x0
	.set pad_button_down       0x1
	.set pad_button_left       0x2
	.set pad_button_right      0x3
	.set pad_button_a          0xC
	.set pad_button_b          0x4
	.set pad_button_c          0x5
	.set pad_button_start      0xD

	| VDP Commands
	.set vdp_write_palettes    0xF0000000
	.set vdp_write_tiles       0x40000000
	.set vdp_write_plane_a     0x40000003
	.set vdp_write_sprit_table 0x60000003
	.set vdp_write_hscroll     0x50000003
	.set vdp_write_vscroll     0x40000010

	.set vdp_read_sprite_table 0x20000003
