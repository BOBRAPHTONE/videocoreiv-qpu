.set vw_layout, function vw_layout(row_step, element_stride, offset) { return (offset | 0xa00 | row_step << 12 | element_stride << 20); } vw_layout
.set vw_setup0, function vw_setup0(x, y) { return (2<<30|y<<23|x<<16); } vw_setup0
.set vw_setup1, function vw_setup1(x, y) { return (3<<30|x<<16|y); } vw_setup1

.global entry
.global exit

entry:

	mov r1, unif
	mov rb3, r1
        xor r0, r0, r0
loop:
	add r0, r0, r1
	sub.setf r1, r1, 1
	brr.allnz -, loop
	nop
	nop
	nop

	# Configure access to vpm
	ldi vw_setup, vw_layout(1, 1)

	# Write into VPM (auto-incrementing)
	mov vpm, elem_num
	mov vpm, r0

	# VPM DMA Store (VDW) basic setup
	ldi vw_setup, vw_setup0(2, 16)

	# VPM DMA Store stride setup
	ldi vw_setup, vw_setup1(0, 0)

	# Trigger transfer to destination in memory (address is from uniforms)
	nop; mov vw_addr, unif

	# Wait for vpm transfer to finish
	mov.never -, vw_wait

exit:
	# Signal done
	mov irq, 1
	nop; nop; thrend
	nop
	nop
