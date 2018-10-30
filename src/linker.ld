MEMORY {
	HEADER (rx)  : ORIGIN = 0x00,     LENGTH = 0x200
	ROM (rx)     : ORIGIN = 0x200,    LENGTH = 0x3ffdff
	RAM (!rx)    : ORIGIN = 0xFF0000, LENGTH = 0xFFFF
}
SECTIONS {
	.header : {
		*(.header*);
	} > HEADER

	.text : {
		*(.text);
		*(.text*);
	} > ROM

	.rodata : {
		. = ALIGN(2);
		*(.rodata);
		*(.rodata*);
	} > ROM

	. = ALIGN(4);

	_sidata = .;

	.bss : {
		. = ALIGN(2);
		_sbss = .;
		*(.bss);
		*(.bss*)
		*(COMMON)
		. = ALIGN(2);
		_ebss = .;
		__bss_end__ = _ebss;
	} > RAM

	.data : AT ( _sidata ) {
		. = ALIGN(4);
		_sdata = .;
		*(.data)
		*(.data*)
		. = ALIGN(4);
		_edata = .;
	} > RAM

	. = ALIGN(2);

	_sheap = .;
	. = 0xFFFFFF;
	_eheap = .;

	.stabstr : {
		*(.stabstr);
		*(.stabstr*);
	}


	_vdp_ctrl  = 0xC00004;
	_vdp_data  = 0xC00000;
	
	_psg_ctrl  = 0xC00011;

	_z80_bus   = 0xA11100;
	_z80_reset = 0xA11200;
	_z80_ram   = 0xA00000;

	_version_reg    = 0xA10000;
	_version_regb_a = 0xA10001;
	_version_regb_b = 0xA10000;
	_tmss_reg       = 0xA14000;

	_pad_ctrl_a     = 0xA10009;
	_pad_ctrl_b     = 0xA1000B;
	_pad_ctrl_c     = 0xA1000D;
	_pad_data_a     = 0xA10003;
	_pad_data_b     = 0xA10005;
	_pad_data_c     = 0xA10007;

}
