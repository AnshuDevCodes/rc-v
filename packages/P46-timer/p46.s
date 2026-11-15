# P46 program - see README.md for the task.
# Rules: start at the label p46_main and finish with ret; every label you
# create starts with p46_ ; save ra (and any s registers you use) on the stack.
# You may call the library routines in sw/lib/rcv_lib.s (rcv_puts, rcv_getc, ...).

        .text
p46_main:
        # Save return address and saved registers on the stack
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)

        # Load the MMIO base address for Slot 3 
        # (Note: Adjust the base address 0xFFFF00C0 if your course framework uses a different slot offset)
        li      s0, 0xFFFF00C0       

        # 1. Set the comparison target value (CMP) in the timer
        li      t0, 5                # Target count value to match
        sb      t0, 4(s0)            # Store to CMP register (offset +4)

        # 2. Enable the timer via the CTRL register (bit 0 = enable)
        li      t0, 1                
        sb      t0, 8(s0)            # Store to CTRL register (offset +8)

p46_poll_loop:
        # 3. Read the STATUS register (bit 0 = sticky match flag)
        lb      t1, 12(s0)           # Load from STATUS register (offset +12)
        andi    t1, t1, 1            # Isolate bit 0 (the match flag)
        beqz    t1, p46_poll_loop    # If match flag is 0, keep looping/waiting

        # Clean up stack and return when match is detected
        lw      s0, 8(sp)
        lw      ra, 12(sp)
        addi    sp, sp, 16
        ret

        .rodata
p46_msg:
        .asciz  "TODO\n"
        .align  2