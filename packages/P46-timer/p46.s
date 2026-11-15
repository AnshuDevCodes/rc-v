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
        li      s0, 0xFFFF00C0       # verify Slot 3 base

        # Initialize and configure timer registers using word stores
        sw      zero, 8(s0)          # CTRL = 0 (disable)
        sw      zero, 0(s0)          # COUNT = 0
        li      t0, 1
        sw      t0, 12(s0)           # clear STATUS
        li      t0, 5
        sw      t0, 4(s0)            # CMP = 5
        li      t0, 1
        sw      t0, 8(s0)            # CTRL = enable

p46_poll_loop:
        # Read the STATUS register and isolate the match flag
        lw      t1, 12(s0)
        andi    t1, t1, 1
        beqz    t1, p46_poll_loop

        sw      zero, 8(s0)          # Stop the timer

        # Clean up stack and return when match is detected
        lw      s0, 8(sp)
        lw      ra, 12(sp)
        addi    sp, sp, 16
        ret

        .rodata
p46_msg:
        .asciz  "TODO\n"
        .align  2
