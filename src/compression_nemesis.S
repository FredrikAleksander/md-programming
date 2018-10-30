.global nemesis_decompress
.global nemesis_decompress_ram

nemesis_decompress:
	movem.l %d0-%a1/%a3-%a5, -(%sp)
	lea nemesis_pcd_write_row_to_vdp.l, %a3
	lea _vdp_data.l, %a4
	bra nemesis_decompress_main
nemesis_decompress_ram:
	movem.l %d0-%a1/%a3-%a5, -(sp)
	lea nemesis_pcd_write_row_to_ram.l, %a3
nemesis_decompress_main:
	lea nemesis_code_table, %a1
	move.w (%a0)+, %d2
	lsl.w  #1, %d2
	bcc.s  1f
	adda.w #nem_pcd_write_row_to_vdp-nem_pcd_write_row_to_vdp, %a3
	1:
	lsl.w   #2, %d2
	movea.w %d2, %a5
	moveq   #8, %d3
	moveq   #0, %d2
	moveq   #0, %d4
	bsr.w   nemesis_build_code_table
	move.b  (%a0)+, %d5
	asl.w   #8, %d5
	move.b  (%a0)+, %d5
	move.w  #0x10, %d6
	bsr.s   nemesis_process_compressed_data
	movem.l (%sp)+, %d0-%a1/%a3-%a5
	rts

nemesis_process_compressed_data:
	move.w %d6, %d7
	subq.w #8, %d7
	move.w %d5, %d1
	lsr.w  %d7, %d1
	cmpi.b #0b11111100, %d1
	bcc.s  nemesis_pcd_inline_data
	andi.w #0xFF, %d1
	add.w  %d1, %d1
	move.b (%a1, %d1.w), %d0
	ext.w %d0
	sub.w %d0, %d6
	cmpi.w #9, %d6
	bcc.s 1f
	addq.w #8, %d6
	asl.w  #8, %d5
	move.b (%a0)+, %d5

	1:
	move.b 1(%a1, %d1.w), %d1
	move.w %d1, %d0
	andi.w #0xF, %d1
	andi.w #0xF0, %d0

nemesis_pcd_get_repeat_count:
	lsr.w #4, %d0

nemesis_pcd_write_pixel:
	lsl.l #4, %d4
	or.b  %d1, %d4
	subq.w #1, %d3
	bne.s nemesis_pcd_write_pixel_loop
	jmp (%a3)
nemesis_pcd_new_row:
	moveq #0, %d4
	moveq #0, %d3
nemesis_pcd_write_pixel_loop:
	dbf %d0, nemesis_pcd_write_pixel
	bra.s nemesis_process_compressed_data

nemesis_pcd_inline_data:
	subq.w #6, %d6
	cmpi.w #9, %d6
	bcc.s 1f
	addq.w #8, %d6
	asl.w #8,%d5
	move.b (%a0)+, %d5

	1:
	subq.w #7, %d6
	move.w %d5, %d1
	lsr.w  %d6, %d1
	move.w %d1, %d0
	andi.w #0xF, %d1
	andi.w #0x70, %d0
	cmpi.w #9, %d6
	bcc.s  nemesis_pcd_get_repeat_count
	addq.w #8, %d6
	asl.w  #8, %d5
	move.b (%a0)+, %d5
	bra.s  nemesis_pcd_get_repeat_count

nemesis_pcd_write_row_to_vdp:
	move.l %d4, (%a4)
	subq.w #1, %a5
	move.w %a5, %d4
	bne.s  nemesis_pcd_new_row
	rts

nemesis_pcd_write_row_to_vdp_xor:
	eor.l %d4, %d2
	move.l %d2, (%a4)
	subq.w #1, %a5
	move.w %a5, %d4
	bne.s nemesis_pcd_new_row
	rts

nemesis_pcd_write_row_to_ram:
	move.l %d4, (%a4)+
	subq.w #1, %a5
	move.w %a5, %d4
	bne.s  nemesis_pcd_new_row
	rts

nemesis_pcd_write_row_to_ram_xor:
	eor.l %d4, %d2
	move.l %d2, (%a4)+
	subq.w #1, %a5
	move.w %a5, %d4
	bne.s  nemesis_pcd_new_row
	rts

nemesis_build_code_table:
	move.b (%a0)+, %d0
nemesis_bct_check_end:
	cmpi.b #0xFF, %d0
	bne.s  nemesis_bct_new_pal_index
	rts
nemesis_bct_new_pal_index:
	move.w %d0, %d7
nemesis_bct_loop:
	move.b (%a0)+, %d0
	cmpi.b #0x80, %d0
	bcc.s nemesis_bct_check_end
	move.b %d0, %d1
	andi.w #0xF, %d7
	andi.w #0x70, %d1
	or.w   %d1, %d7
	andi.w #0xF, %d0
	move.b %d0, %d1
	lsl.w  #8, %d1
	or.w   %d1, %d7
	moveq  #8, %d1
	sub.w  %d0, %d1
	bne.s  nemesis_bct_short_code
	move.b (%a0)+, %d0
	add.w  %d0, %d0
	move.w %d7, (%a1, %d0.w)
	bra.s  nemesis_bct_loop


nemesis_bct_short_code:
	move.b (%a0)+, %d0
	lsl.w  %d1, %d0
	add.w  %d0, %d0
	moveq  #1, %d5
	lsl.w  %d1, %d5
	subq.w #1, %d5
nemesis_bct_short_code_loop:
	move.w %d7, (%a1, %d0.w)
	addq.w #2, %d0
	dbf    %d5, nemesis_bct_short_code_loop
	bra.s  nemesis_bct_loop

	.section .bss
nemesis_code_table:
	.space 0x200

