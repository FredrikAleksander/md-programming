	.section .header

|==============================================================================
| M68000 interrupt vector table
|==============================================================================
InterruptVectors:
	.long StackTop
	.long EntryPoint
	.long Interrupt                | Bus error
	.long Interrupt                | Address error
	.long Interrupt                | Illegal instruction
	.long Interrupt                | Division by zero
	.long Interrupt                | CHK exception
	.long Interrupt                | TRAPV exception
	.long Interrupt                | Privilege violation
	.long Interrupt                | TRACE exception
	.long Interrupt                | Line-A emulator
	.long Interrupt                | Line-F emulator
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Spurious exception
	.long Interrupt                | IRQ level 1
	.long Interrupt                | IRQ level 2
	.long Interrupt                | IRQ level 3
	.long HBlankInterrupt          | IRQ level 4 (horizontal retrace interrupt)
	.long Interrupt                | IRQ level 5
	.long VBlankInterrupt          | IRQ level 6 (vertical retrace interrupt)
	.long Interrupt                | IRQ level 7
	.long Interrupt                | TRAP #00 exception
	.long Interrupt                | TRAP #01 exception
	.long Interrupt                | TRAP #02 exception
	.long Interrupt                | TRAP #03 exception
	.long Interrupt                | TRAP #04 exception
	.long Interrupt                | TRAP #05 exception
	.long Interrupt                | TRAP #06 exception
	.long Interrupt                | TRAP #07 exception
	.long Interrupt                | TRAP #08 exception
	.long Interrupt                | TRAP #09 exception
	.long Interrupt                | TRAP #10 exception
	.long Interrupt                | TRAP #11 exception
	.long Interrupt                | TRAP #12 exception
	.long Interrupt                | TRAP #13 exception
	.long Interrupt                | TRAP #14 exception
	.long Interrupt                | TRAP #15 exception
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)
	.long Interrupt                | Unused (reserved)

|==============================================================================
| Sega Megadrive ROM header
|==============================================================================
RomHeader:
	.ascii "SEGA MEGA DRIVE (C)"                                | Console name
	.ascii "FK   2018.OCT"                                      | Copyright
	.ascii "YOUR GAME HERE                                  "   | Domestic name
	.ascii "YOUR GAME HERE                                  "   | International name
	.ascii "GM XXXXXXXX-XX"                                     | Version number
	.word  0x0000                                               | Checksum
	.ascii "J               "                                   | I/O support
	.long  0x00000000                                           | Start address of ROM
	.long  __end                                                | End address of ROM
	.long  0x00FF0000                                           | Start address of RAM
	.long  0x00FFFFFF                                           | End address of RAM
	.long  0x00000000                                           | SRAM enabled
	.long  0x00000000                                           | Unused
	.long  0x00000000                                           | Start address of SRAM
	.long  0x00000000                                           | End address of SRAM
	.long  0x00000000                                           | Unused
	.long  0x00000000                                           | Unused
	.ascii "                                        "           | Notes (unused)
	.ascii "JUE             "                                   | Country codes

	.section .text
|==============================================================================
| Interrupt routines
|==============================================================================
Interrupt:
	stop #0x2700
	rte
HBlankInterrupt:
	addi.l #1, _hsync_counter
	rte
VBlankInterrupt:
	addi.l #1, _vsync_counter
	rte

|==============================================================================
| Boot/reset entry point
|==============================================================================
EntryPoint:
	move #0x2700, %sr              | Disable interrupts
	| Check reset button
	tst.w 0x00A10008
	bne Startup
	tst.w 0x00A1000C
	bne Startup
	
	| Write proper bits to TMSS security chip
	move.b _version_regb_a, %d0   | Move LSB of version register into D0
	andi.b #0x0F, %d0              | Compare hardware version
	bra Startup                    | If no TSS is present, skip next instr
	move.l #0x53454741, _tmss_reg   | Write "SEGA" to TMSS
Startup:
    | Fill RAM with zeroes
	clr.l  %d0
	movea.l %d0, %a0
	move.l #0x00003FFF, %d1
	1:
	move.l %d0, -(%a0)
	dbra %d1, 1b

	| Initialize .data section by copying LEN(=_edata-_sdata) bytes from _sidata to _sdata
	| .data section is aligned on 4 byte boundaries, so it is possible to use long moves
	move.l #_edata, %d1            | Set d1 to end of .data section
	move.l #_sdata, %d0            | Set d0 to start of .data section
	sub.l  %d0, %d1                | Subtract d0 from d1, making d1 equal the length of the .data section
	cmp.l  #0, %d1                 | Check if .data section length is zero
	beq 3f                         | If zero, skip section initialization
	lsr.l #2, %d1                  | Divide d1 by 4
	sub.l #1, %d1                  | Subtract 1 from d1
	movea.l %d0, %a1               | Set a1 register to _sdata
	movea.l #_sidata, %a0          | Set a0 register to _sidata
	2:                             | do {
	move.l (%a1)+, (%a0)+          |     *a1 = *a0; ++a1; ++a0;
	dbra %d1, 2b                   | } while(d1 > 0);

	| Setup Hardware
	3:
	jsr InitZ80
	jsr InitPSG
	jsr InitVDP
	jsr InitGamepads

	movea.l #_sheap, %a0           | Place address of empty RAM location to a0
	movem.l (%a0), %d0-%d7/%a1-%a6 | Clear all registers besides a0 and a7
	move.l #0x0, %a0               | Clear a0 register
	move   #0x2300, %sr            | Enable interrupts

                                   | System should now be in a good state
                                   | with RAM intialized to zero, all devices
                                   | are in good initial states, and all
                                   | registers are 0 except the SP.
	jmp __main


|==============================================================================
| Device initialization routines
|==============================================================================
InitZ80:                           | Initialize the Z80 coprocessor
	move.w #0x0100, _z80_bus       | Request Z80 bus access
	move.w #0x0100, _z80_reset     | Hold Z80 in reset state

	1:                             | Wait for Z80 bus access
	btst #0x0, _z80_bus            | ...
	bne 1b                         | ...

	move.l #_binary_z80data_end, %d0
	move.l #_binary_z80data_start, %d1
	sub.l  %d1, %d0                | Subtract start from end to get the length of data
	move.l %d1, %a0                | Move location of Z80 data to a0
	move.l #_z80_ram, %a1          | Move location of Z80 ram to a1

	2:                             | do {
	move.b (%a0)+, (%a1)+          |   *a1= *a0; *a1++; *a0++;
	dbra %d0, 2b                   | } while(--d0 != -1);

	move.w #0x0000, _z80_reset     | Relase Z80 reset state
	move.w #0x0000, _z80_bus       | Relinquish Z80 bus access

	rts
InitPSG:                           | Copy data from PSGData into PSG registers
	move.l #PSGData, %a0
	move.l #0x03, %d0
	1:
	move.b (%a0)+, _psg_ctrl
	dbra   %d0, 1b
	rts
InitVDP:                           | Initialize VDP registers from VDPRegisters
	move.l #VDPRegisters, %a0
	move.l #0x18, %d0
	move.l #0x8000, %d1
	1:
	move.b (%a0)+, %d1
	move.w %d1, _vdp_ctrl
	add.w  #0x0100, %d1
	dbra %d0, 1b
	rts
InitGamepads:                      | Initialize gamepads
	move.b #0x40, %d0
	move.b %d0, _pad_ctrl_a
	move.b %d0, _pad_ctrl_b
	move.b %d0, _pad_ctrl_c
	rts
PSGData:
	.word 0x9fbf, 0xdfff
VDPRegisters:
	.byte 0x14                     | 0: Horiz. interrupt on, display on
	.byte 0x74                     | 1: Vert. interrupt on, screen blank off, DMA on, V28 mode (40 cells vertically), Genesis mode on
	.byte 0x30                     | 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
	.byte 0x40                     | 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
	.byte 0x05                     | 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
	.byte 0x70                     | 5: Sprite table at 0xE000 (bits 0-6)
	.byte 0x00                     | 6: Unused
	.byte 0x00                     | 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
	.byte 0x00                     | 8: Unused
	.byte 0x00                     | 9: Unused
	.byte 0x00                     | 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
	.byte 0x00                     | 11: External interrupts off, V scroll fullscreen, H scroll fullscreen
	.byte 0x81                     | 12: Shadows and highlights off, interlace off, H40 mode (64 cells horizontally)
	.byte 0x34                     | 13: Horiz. scroll table at 0xD000 (bits 0-5)
	.byte 0x00                     | 14: Unused
	.byte 0x00                     | 15: Autoincrement off
	.byte 0x01                     | 16: Vert. scroll 32, Horiz. scroll 64
	.byte 0x00                     | 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
	.byte 0x00                     | 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
	.byte 0x00                     | 19: DMA length lo byte
	.byte 0x00                     | 20: DMA length hi byte
	.byte 0x00                     | 21: DMA source address lo byte
	.byte 0x00                     | 22: DMA source address mid byte
	.byte 0x00                     | 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)
.section .bss
StackBottom:
	.space 512
StackTop:

.section .data
_hsync_counter:
	.word 0x0000
_vsync_counter:
	.word 0x0000
