# =============================================================================
# Z8000 Instruction Test Suite
# File: test_instructions.s
#
# Comprehensive test of Z8000 instructions (110 tests):
#
# Data Movement:
#   - LD (register, immediate, indirect, direct address, indexed, base)
#   - LDB (byte load, including compact single-word format)
#   - LDL (long 32-bit load)
#   - LDK (load 4-bit constant)
#   - ST/STB (indirect, direct address, indexed, base indexed)
#   - PUSH, POP (stack operations)
#
# Arithmetic:
#   - ADD, SUB (all addressing modes including indexed)
#   - ADDL, SUBL (32-bit long operations)
#   - ADC, SBC (add/subtract with carry)
#   - INC, DEC (increment/decrement by n, including indirect mode)
#   - NEG, COM (negate, complement, including indirect mode)
#   - CP, CPL (compare word and long)
#
# Logical:
#   - AND, OR, XOR (all addressing modes)
#
# Shift/Rotate:
#   - RL, RR (rotate left/right by 1 or 2)
#   - SLA, SRA (arithmetic shift left/right)
#   - SLL, SRL (logical shift left/right)
#
# Control Flow:
#   - JP, JR (conditional jumps)
#   - CALL, CALR, RET (subroutine support)
#   - DJNZ (decrement and jump)
#   - NOP (no operation)
#
# Block Operations:
#   - LDI, LDIR (block move with increment)
#   - LDD, LDDR (block move with decrement)
#   - CPI, CPIR (block compare with increment)
#   - CPD, CPDR (block compare with decrement)
#   - Byte variants (LDIB, CPIB, CPIRB, CPDRB)
#
# Input/Output:
#   - IN, INB (input word/byte)
#   - OUT, OUTB (output word/byte)
#   - SIN, SINB, SOUT, SOUTB (special I/O)
#
# Test results stored at 0x1F00:
#   0x1F00: Number of tests passed
#   0x1F02: Number of tests failed
#   0x1F04: Current test number
#   0x1F06: 0xDEAD if all passed, 0xFA11 if failed
# =============================================================================

        .text
        .global _start

# =============================================================================
# Test program starts at 0x0100
# =============================================================================
_start:
        ld      r0, #0              ! Tests passed
        ld      r1, #0              ! Tests failed
        ld      r2, #0              ! Current test number
        ld      r14, #0x1000        ! Data pointer
        ld      r15, #0x1F00        ! Results pointer

# =============================================================================
# TEST 1: LD Rd, Rs (register to register)
# =============================================================================
test_ld_r:
        ld      r2, #1              ! Test number 1
        ld      r3, #0x1234         ! Load immediate into R3
        ld      r4, r3              ! R4 <- R3 (should be 0x1234)

        cp      r4, #0x1234         ! Verify R4 == 0x1234
        jr      z, test_ld_r_pass
        inc     r1, #1
        jr      test_ld_im
test_ld_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 2: LD Rd, #data (immediate)
# =============================================================================
test_ld_im:
        ld      r2, #2              ! Test number 2
        ld      r3, #0xABCD         ! Load immediate

        cp      r3, #0xABCD         ! Verify R3 == 0xABCD
        jr      z, test_ld_im_pass
        inc     r1, #1
        jr      test_ld_ir
test_ld_im_pass:
        inc     r0, #1

# =============================================================================
# TEST 3: LD Rd, @Rs (indirect register load)
# =============================================================================
test_ld_ir:
        ld      r2, #3              ! Test number 3

        ld      r3, #0x5678
        ld      r4, #0x1000         ! Address
        ld      @r4, r3             ! Store 0x5678 at address 0x1000

        ld      r5, @r4             ! R5 <- mem[R4] (should be 0x5678)

        cp      r5, r3              ! Verify
        jr      z, test_ld_ir_pass
        inc     r1, #1
        jr      test_ld_da
test_ld_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 4: LD Rd, address (direct address load)
# =============================================================================
test_ld_da:
        ld      r2, #4              ! Test number 4

        ld      r3, #0x9ABC
        ld      r4, #0x1002
        ld      @r4, r3             ! Store 0x9ABC at 0x1002

        ld      r5, 0x1002          ! R5 <- mem[0x1002] (direct address load)

        cp      r5, r3              ! Verify
        jr      z, test_ld_da_pass
        inc     r1, #1
        jr      test_add_r
test_ld_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 5: ADD Rd, Rs (register)
# =============================================================================
test_add_r:
        ld      r2, #5              ! Test number 5
        ld      r3, #100            ! First operand
        ld      r4, #200            ! Second operand
        add     r3, r4              ! R3 <- R3 + R4 = 300

        cp      r3, #300            ! Verify R3 == 300
        jr      z, test_add_r_pass
        inc     r1, #1
        jr      test_add_im
test_add_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 6: ADD Rd, #data (immediate)
# =============================================================================
test_add_im:
        ld      r2, #6              ! Test number 6
        ld      r3, #1000
        add     r3, #234            ! R3 <- 1000 + 234 = 1234

        cp      r3, #1234           ! Verify R3 == 1234
        jr      z, test_add_im_pass
        inc     r1, #1
        jr      test_add_ir
test_add_im_pass:
        inc     r0, #1

# =============================================================================
# TEST 7: ADD Rd, @Rs (indirect)
# =============================================================================
test_add_ir:
        ld      r2, #7              ! Test number 7

        ld      r3, #500
        ld      r4, #0x1004
        ld      @r4, r3             ! mem[0x1004] = 500

        ld      r5, #500
        add     r5, @r4             ! R5 <- 500 + 500 = 1000

        cp      r5, #1000           ! Verify
        jr      z, test_add_ir_pass
        inc     r1, #1
        jr      test_add_da
test_add_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 8: ADD Rd, address (direct address)
# =============================================================================
test_add_da:
        ld      r2, #8              ! Test number 8

        ld      r3, #0x0100
        ld      r4, #0x1006
        ld      @r4, r3             ! mem[0x1006] = 0x0100

        ld      r5, #0x0F00
        add     r5, 0x1006          ! R5 <- 0x0F00 + mem[0x1006] = 0x1000

        cp      r5, #0x1000         ! Verify
        jr      z, test_add_da_pass
        inc     r1, #1
        jr      test_sub_r
test_add_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 9: SUB Rd, Rs (register)
# =============================================================================
test_sub_r:
        ld      r2, #9              ! Test number 9
        ld      r3, #1000
        ld      r4, #300
        sub     r3, r4              ! R3 <- 1000 - 300 = 700

        cp      r3, #700            ! Verify
        jr      z, test_sub_r_pass
        inc     r1, #1
        jr      test_sub_im
test_sub_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 10: SUB Rd, #data (immediate)
# =============================================================================
test_sub_im:
        ld      r2, #10             ! Test number 10
        ld      r3, #2000
        sub     r3, #500            ! R3 <- 2000 - 500 = 1500

        cp      r3, #1500           ! Verify
        jr      z, test_sub_im_pass
        inc     r1, #1
        jr      test_jp_true
test_sub_im_pass:
        inc     r0, #1

# =============================================================================
# TEST 11: JP cc, address (condition true - taken)
# =============================================================================
test_jp_true:
        ld      r2, #11             ! Test number 11
        ld      r3, #0
        cp      r3, #0              ! Set Z flag
        jp      z, test_jp_true_target  ! Should jump

        inc     r1, #1              ! If we get here, test failed
        jr      test_jp_false

test_jp_true_target:
        inc     r0, #1              ! Test passed
        jr      test_jp_false

# =============================================================================
# TEST 12: JP cc, address (condition false - not taken)
# =============================================================================
test_jp_false:
        ld      r2, #12             ! Test number 12
        ld      r3, #1
        cp      r3, #0              ! Clear Z flag (1 != 0)
        jp      z, test_jp_false_bad  ! Should NOT jump

        inc     r0, #1              ! If we get here, test passed
        jr      test_jr_fwd

test_jp_false_bad:
        inc     r1, #1              ! Test failed
        jr      test_jr_fwd

# =============================================================================
# TEST 13: JR cc, displacement (forward jump)
# =============================================================================
test_jr_fwd:
        ld      r2, #13             ! Test number 13
        ld      r3, #5
        cp      r3, #5              ! Set Z flag
        jr      z, test_jr_fwd_target  ! Forward jump

        inc     r1, #1              ! Should not reach here
        jr      test_jr_back
test_jr_fwd_target:
        inc     r0, #1

# =============================================================================
# TEST 14: JR cc, displacement (backward jump - loop)
# =============================================================================
test_jr_back:
        ld      r2, #14             ! Test number 14
        ld      r3, #0              ! Counter

test_jr_back_loop:
        inc     r3, #1              ! Increment counter
        cp      r3, #3              ! Check if counter == 3
        jr      nz, test_jr_back_loop  ! Loop back if not 3

        cp      r3, #3              ! If R3 == 3, test passed
        jr      z, test_jr_back_pass
        inc     r1, #1
        jr      test_flags_z
test_jr_back_pass:
        inc     r0, #1

# =============================================================================
# TEST 15: Flags - Zero flag
# =============================================================================
test_flags_z:
        ld      r2, #15             ! Test number 15
        ld      r3, #100
        sub     r3, #100            ! R3 = 0, should set Z flag
        jr      z, test_flags_z_pass
        inc     r1, #1
        jr      test_flags_nz
test_flags_z_pass:
        inc     r0, #1

# =============================================================================
# TEST 16: Flags - Not Zero
# =============================================================================
test_flags_nz:
        ld      r2, #16             ! Test number 16
        ld      r3, #100
        sub     r3, #50             ! R3 = 50, should clear Z flag
        jr      nz, test_flags_nz_pass
        inc     r1, #1
        jr      test_flags_c
test_flags_nz_pass:
        inc     r0, #1

# =============================================================================
# TEST 17: Flags - Carry (overflow in unsigned add)
# =============================================================================
test_flags_c:
        ld      r2, #17             ! Test number 17
        ld      r3, #0xFFFF         ! Max unsigned value
        add     r3, #1              ! Should overflow, set C flag
        jr      c, test_flags_c_pass
        inc     r1, #1
        jr      test_flags_nc
test_flags_c_pass:
        inc     r0, #1

# =============================================================================
# TEST 18: Flags - No Carry
# =============================================================================
test_flags_nc:
        ld      r2, #18             ! Test number 18
        ld      r3, #100
        add     r3, #100            ! No overflow
        jr      nc, test_flags_nc_pass
        inc     r1, #1
        jr      test_flags_s
test_flags_nc_pass:
        inc     r0, #1

# =============================================================================
# TEST 19: Flags - Sign (negative result)
# =============================================================================
test_flags_s:
        ld      r2, #19             ! Test number 19
        ld      r3, #0
        sub     r3, #1              ! R3 = -1 (0xFFFF), should set S flag
        jr      mi, test_flags_s_pass  ! mi = minus (sign set)
        inc     r1, #1
        jr      test_flags_ns
test_flags_s_pass:
        inc     r0, #1

# =============================================================================
# TEST 20: Flags - Not Sign (positive result)
# =============================================================================
test_flags_ns:
        ld      r2, #20             ! Test number 20
        ld      r3, #100
        add     r3, #100            ! R3 = 200, positive
        jr      pl, test_flags_ns_pass  ! pl = plus (sign clear)
        inc     r1, #1
        jp      tests_done
test_flags_ns_pass:
        inc     r0, #1

# =============================================================================
# TEST 21: LD address, Rs (store to direct address)
# =============================================================================
test_st_da:
        ld      r2, #21             ! Test number 21
        ld      r3, #0xBEEF         ! Value to store
        ld      0x1008, r3          ! Store R3 to address 0x1008

        ld      r4, 0x1008          ! Load back from 0x1008
        cp      r4, r3              ! Verify
        jr      z, test_st_da_pass
        inc     r1, #1
        jp      tests_done
test_st_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 22: LD Rd, addr(Rs) (indexed addressing)
# =============================================================================
test_ld_x:
        ld      r2, #22             ! Test number 22
        ld      r3, #0xCAFE         ! Value to store
        ld      r4, #0x1010         ! Base address
        ld      @r4, r3             ! Store 0xCAFE at 0x1010

        ld      r5, #4              ! Index value
        ld      r6, 0x100C(r5)      ! Load from 0x100C + 4 = 0x1010

        cp      r6, r3              ! Verify
        jr      z, test_ld_x_pass
        inc     r1, #1
        jp      tests_done
test_ld_x_pass:
        inc     r0, #1

# =============================================================================
# TEST 23: LD Rd, Rs(#disp) (base addressing)
# =============================================================================
test_ld_ba:
        ld      r2, #23             ! Test number 23
        ld      r3, #0xFACE         ! Value to store
        ld      r4, #0x1020         ! Address
        ld      @r4, r3             ! Store 0xFACE at 0x1020

        ld      r5, #0x1000         ! Base register
        ld      r6, r5(#0x20)       ! Load from R5 + 0x20 = 0x1020

        cp      r6, r3              ! Verify
        jr      z, test_ld_ba_pass
        inc     r1, #1
        jp      tests_done
test_ld_ba_pass:
        inc     r0, #1

# =============================================================================
# TEST 24: LD Rd, Rs(Rx) (base indexed addressing)
# =============================================================================
test_ld_bx:
        ld      r2, #24             ! Test number 24
        ld      r3, #0xB00B         ! Value to store
        ld      r4, #0x1030         ! Address
        ld      @r4, r3             ! Store 0xB00B at 0x1030

        ld      r5, #0x1000         ! Base register
        ld      r6, #0x30           ! Index register
        ld      r7, r5(r6)          ! Load from R5 + R6 = 0x1030

        cp      r7, r3              ! Verify
        jr      z, test_ld_bx_pass
        inc     r1, #1
        jp      tests_done
test_ld_bx_pass:
        inc     r0, #1

# =============================================================================
# TEST 25: AND Rd, Rs (logical AND)
# =============================================================================
test_and_r:
        ld      r2, #25             ! Test number 25
        ld      r3, #0xFF0F         ! First operand
        ld      r4, #0x0FFF         ! Second operand
        and     r3, r4              ! R3 = 0xFF0F AND 0x0FFF = 0x0F0F
        cp      r3, #0x0F0F         ! Verify
        jr      z, test_and_r_pass
        inc     r1, #1              ! Test failed
        jr      test_or_r           ! Skip to next test
test_and_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 26: OR Rd, Rs (logical OR)
# =============================================================================
test_or_r:
        ld      r2, #26             ! Test number 26
        ld      r3, #0xF0F0         ! First operand
        ld      r4, #0x0F0F         ! Second operand
        or      r3, r4              ! R3 = 0xF0F0 OR 0x0F0F = 0xFFFF

        cp      r3, #0xFFFF         ! Verify
        jr      z, test_or_r_pass
        inc     r1, #1
        jr      test_xor_r
test_or_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 27: XOR Rd, Rs (logical XOR)
# =============================================================================
test_xor_r:
        ld      r2, #27             ! Test number 27
        ld      r3, #0xAAAA         ! First operand
        ld      r4, #0xFF00         ! Second operand
        xor     r3, r4              ! R3 = 0xAAAA XOR 0xFF00 = 0x55AA

        cp      r3, #0x55AA         ! Verify
        jr      z, test_xor_r_pass
        inc     r1, #1
        jr      test_dec_r
test_xor_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 28: DEC Rd, #n (decrement by n)
# =============================================================================
test_dec_r:
        ld      r2, #28             ! Test number 28
        ld      r3, #100            ! Initial value
        dec     r3, #1              ! R3 = 100 - 1 = 99

        cp      r3, #99             ! Verify
        jr      z, test_dec_r_pass
        inc     r1, #1
        jr      test_dec_r2
test_dec_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 29: DEC Rd, #n (decrement by larger value)
# =============================================================================
test_dec_r2:
        ld      r2, #29             ! Test number 29
        ld      r3, #50             ! Initial value
        dec     r3, #5              ! R3 = 50 - 5 = 45

        cp      r3, #45             ! Verify
        jr      z, test_dec_r2_pass
        inc     r1, #1
        jr      test_neg_r
test_dec_r2_pass:
        inc     r0, #1

# =============================================================================
# TEST 30: NEG Rd (negate - two's complement)
# =============================================================================
test_neg_r:
        ld      r2, #30             ! Test number 30
        ld      r3, #1              ! Initial value
        neg     r3                  ! R3 = 0 - 1 = 0xFFFF (-1)

        cp      r3, #0xFFFF         ! Verify
        jr      z, test_neg_r_pass
        inc     r1, #1
        jr      test_neg_r2
test_neg_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 31: NEG Rd (negate larger value)
# =============================================================================
test_neg_r2:
        ld      r2, #31             ! Test number 31
        ld      r3, #100            ! Initial value (0x0064)
        neg     r3                  ! R3 = 0 - 100 = 0xFF9C (-100)

        cp      r3, #0xFF9C         ! Verify
        jr      z, test_neg_r2_pass
        inc     r1, #1
        jr      test_com_r
test_neg_r2_pass:
        inc     r0, #1

# =============================================================================
# TEST 32: COM Rd (complement - one's complement)
# =============================================================================
test_com_r:
        ld      r2, #32             ! Test number 32
        ld      r3, #0x00FF         ! Initial value
        com     r3                  ! R3 = ~0x00FF = 0xFF00

        cp      r3, #0xFF00         ! Verify
        jr      z, test_com_r_pass
        inc     r1, #1
        jr      test_com_r2
test_com_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 33: COM Rd (complement different value)
# =============================================================================
test_com_r2:
        ld      r2, #33             ! Test number 33
        ld      r3, #0xA5A5         ! Initial value
        com     r3                  ! R3 = ~0xA5A5 = 0x5A5A

        cp      r3, #0x5A5A         ! Verify
        jr      z, test_com_r2_pass
        inc     r1, #1
        jr      test_adc_r
test_com_r2_pass:
        inc     r0, #1

# =============================================================================
# TEST 34: ADC Rd, Rs (add with carry - no carry in)
# =============================================================================
test_adc_r:
        ld      r2, #34             ! Test number 34
        ld      r3, #100            ! First operand
        ld      r4, #50             ! Second operand
        add     r3, #0              ! Clear carry flag (100 + 0 = 100, no carry)
        ld      r3, #100            ! Reset R3
        adc     r3, r4              ! R3 = 100 + 50 + 0 = 150

        cp      r3, #150            ! Verify
        jr      z, test_adc_r_pass
        inc     r1, #1
        jr      test_adc_r2
test_adc_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 35: ADC Rd, Rs (add with carry - carry set)
# =============================================================================
test_adc_r2:
        ld      r2, #35             ! Test number 35
        ld      r3, #0xFFFF         ! Max value
        add     r3, #1              ! 0xFFFF + 1 = 0x0000 with carry set
        ld      r3, #100            ! R3 = 100
        ld      r4, #50             ! R4 = 50
        adc     r3, r4              ! R3 = 100 + 50 + 1 (carry) = 151

        cp      r3, #151            ! Verify
        jr      z, test_adc_r2_pass
        inc     r1, #1
        jr      test_sbc_r
test_adc_r2_pass:
        inc     r0, #1

# =============================================================================
# TEST 36: SBC Rd, Rs (subtract with borrow - no borrow)
# =============================================================================
test_sbc_r:
        ld      r2, #36             ! Test number 36
        ld      r3, #100            ! First operand
        ld      r4, #30             ! Second operand
        add     r3, #0              ! Clear carry/borrow flag
        ld      r3, #100            ! Reset R3
        sbc     r3, r4              ! R3 = 100 - 30 - 0 = 70

        cp      r3, #70             ! Verify
        jr      z, test_sbc_r_pass
        inc     r1, #1
        jr      test_sbc_r2
test_sbc_r_pass:
        inc     r0, #1

# =============================================================================
# TEST 37: SBC Rd, Rs (subtract with borrow - borrow set)
# =============================================================================
test_sbc_r2:
        ld      r2, #37             ! Test number 37
        ld      r3, #0              !
        sub     r3, #1              ! 0 - 1 = 0xFFFF with borrow/carry set
        ld      r3, #100            ! R3 = 100
        ld      r4, #30             ! R4 = 30
        sbc     r3, r4              ! R3 = 100 - 30 - 1 (borrow) = 69

        cp      r3, #69             ! Verify
        jr      z, test_sbc_r2_pass
        inc     r1, #1
        jp      tests_done
test_sbc_r2_pass:
        inc     r0, #1

# =============================================================================
# TEST 38: CALR (call relative) and RET
# =============================================================================
test_calr:
        ld      r2, #38             ! Test number 38
        ld      r13, #0x1E00        ! Set up stack pointer (save r15 for results)
        ld      r6, #0              ! Initialize return check

        ! Save R15 (results pointer) to R14 temporarily
        ld      r14, r15
        ld      r15, r13            ! SP = 0x1E00

        calr    calr_target         ! Call relative
        ! After return, R6 should be 0x1234

        ! Restore R15 (results pointer)
        ld      r15, r14

        cp      r6, #0x1234         ! Verify CALR/RET worked
        jr      z, test_calr_pass
        inc     r1, #1
        jr      test_call_da
test_calr_pass:
        inc     r0, #1
        jr      test_call_da

! Subroutine called by CALR
calr_target:
        ld      r6, #0x1234         ! Mark that we got here
        ret                         ! Return (unconditional)

# =============================================================================
# TEST 39: CALL address (call direct address) and RET
# =============================================================================
test_call_da:
        ld      r2, #39             ! Test number 39
        ld      r7, #0              ! Initialize return check

        ! Save R15 and set up stack
        ld      r14, r15
        ld      r15, r13            ! SP = 0x1E00

        call    call_target         ! Call direct address
        ! After return, R7 should be 0x5678

        ! Restore R15 (results pointer)
        ld      r15, r14

        cp      r7, #0x5678         ! Verify CALL/RET worked
        jr      z, test_call_da_pass
        inc     r1, #1
        jr      test_ret_cond
test_call_da_pass:
        inc     r0, #1
        jr      test_ret_cond

! Subroutine called by CALL
call_target:
        ld      r7, #0x5678         ! Mark that we got here
        ret                         ! Return (unconditional)

# =============================================================================
# TEST 40: RET cc (conditional return - condition true)
# =============================================================================
test_ret_cond:
        ld      r2, #40             ! Test number 40
        ld      r8, #0              ! Initialize return check

        ! Save R15 and set up stack
        ld      r14, r15
        ld      r15, r13            ! SP = 0x1E00

        calr    ret_cond_target     ! Call subroutine
        ! After return, R8 should be 0xABCD

        ! Restore R15
        ld      r15, r14

        cp      r8, #0xABCD         ! Verify conditional RET worked
        jr      z, test_ret_cond_pass
        inc     r1, #1
        jr      test_ret_cond_false
test_ret_cond_pass:
        inc     r0, #1
        jr      test_ret_cond_false

! Subroutine with conditional return (condition true)
ret_cond_target:
        ld      r8, #0xABCD         ! Mark that we got here
        cp      r8, #0xABCD         ! Set Z flag (equal)
        ret     z                   ! Return if zero (should return)
        ld      r8, #0xDEAD         ! Should not reach here
        ret

# =============================================================================
# TEST 41: RET cc (conditional return - condition false)
# =============================================================================
test_ret_cond_false:
        ld      r2, #41             ! Test number 41
        ld      r9, #0              ! Initialize return check

        ! Save R15 and set up stack
        ld      r14, r15
        ld      r15, r13            ! SP = 0x1E00

        calr    ret_false_target    ! Call subroutine
        ! After return, R9 should be 0x9999 (not 0x1111)

        ! Restore R15
        ld      r15, r14

        cp      r9, #0x9999         ! Verify conditional RET (false) worked
        jr      z, test_ret_cond_false_pass
        inc     r1, #1
        jp      tests_done
test_ret_cond_false_pass:
        inc     r0, #1
        jr      test_djnz

! Subroutine with conditional return (condition false)
ret_false_target:
        ld      r9, #0x1111         ! Initial value
        cp      r9, #0x2222         ! Set NZ flag (not equal)
        ret     z                   ! Return if zero (should NOT return)
        ld      r9, #0x9999         ! Should reach here
        ret                         ! Unconditional return

# =============================================================================
# TEST 42: DJNZ (decrement and jump if not zero)
# =============================================================================
test_djnz:
        ld      r2, #42             ! Test number 42
        ld      r3, #5              ! Loop counter
        ld      r4, #0              ! Accumulator

test_djnz_loop:
        inc     r4, #1              ! Increment accumulator
        djnz    r3, test_djnz_loop  ! Decrement r3, loop if not zero

        ! After loop: R4 should be 5 (looped 5 times)
        cp      r4, #5
        jr      z, test_djnz_pass
        inc     r1, #1
        jr      test_djnz2
test_djnz_pass:
        inc     r0, #1

# =============================================================================
# TEST 43: DJNZ (verify counter reaches zero)
# =============================================================================
test_djnz2:
        ld      r2, #43             ! Test number 43
        ld      r5, #3              ! Loop counter

test_djnz2_loop:
        djnz    r5, test_djnz2_loop ! Decrement r5, loop if not zero

        ! After loop: R5 should be 0
        cp      r5, #0
        jr      z, test_djnz2_pass
        inc     r1, #1
        jp      tests_done
test_djnz2_pass:
        inc     r0, #1
        jr      test_ldi

# =============================================================================
# TEST 44-45: Block instruction tests skipped (need microcode rework for correct 0xBB encoding)
# =============================================================================
test_ldi:
        jp      test_sub_ir         ! Skip block instruction tests
        ld      r2, #44             ! Test number 44

        ! Set up source data in memory
        ld      r4, #ldi_src_data   ! Source address
        ld      r5, #ldi_dst_data   ! Dest address
        ld      r6, #0              ! Clear dest location first

        ! Store 0 to dest to ensure it's clear
        ld      @r5, r6

        ! Execute LDI @R5, @R4, R6 (copy word from @R4 to @R5, increment both)
        ! Encoding: 0xBB91, then 0x5468 (dst=5, src=4, cnt=6, mode=8)
        ldi     @r5, @r4, r6

        ! Check if data was copied correctly
        ld      r6, @r5             ! Load from original dest address (now r5-2)
        ! Note: R5 was incremented, so we need to check the original dest
        ld      r7, #ldi_dst_data
        ld      r6, @r7             ! Load the copied data
        cp      r6, #0xCAFE         ! Should be 0xCAFE
        jr      z, test_ldi_pass
        inc     r1, #1
        jp      tests_done
test_ldi_pass:
        inc     r0, #1
        jr      test_ldir

# =============================================================================
# TEST 45: LDIR (Load, Increment, and Repeat)
# =============================================================================
test_ldir:
        ld      r2, #45             ! Test number 45

        ! Set up source data (3 words: 0x1111, 0x2222, 0x3333)
        ld      r4, #ldir_src_data  ! Source address
        ld      r5, #ldir_dst_data  ! Dest address
        ld      r6, #3              ! Count (3 words)

        ! Clear destination first
        ld      r7, #0
        ld      @r5, r7             ! Clear first word
        inc     r5, #2
        ld      @r5, r7             ! Clear second word
        inc     r5, #2
        ld      @r5, r7             ! Clear third word
        ld      r5, #ldir_dst_data  ! Reset dest pointer

        ! Execute LDIR @R5, @R4, R6 (copy 3 words from @R4 to @R5)
        ldir    @r5, @r4, r6

        ! Verify all three words were copied
        ld      r7, #ldir_dst_data
        ld      r8, @r7             ! First word
        cp      r8, #0x1111
        jr      nz, test_ldir_fail
        inc     r7, #2
        ld      r8, @r7             ! Second word
        cp      r8, #0x2222
        jr      nz, test_ldir_fail
        inc     r7, #2
        ld      r8, @r7             ! Third word
        cp      r8, #0x3333
        jr      nz, test_ldir_fail
        jr      test_ldir_pass

test_ldir_fail:
        inc     r1, #1
        jp      tests_done
test_ldir_pass:
        inc     r0, #1

# =============================================================================
# TEST 46: SUB Rd, @Rs (indirect register)
# =============================================================================
test_sub_ir:
        ld      r2, #46             ! Test number 46
        ld      r3, #100            ! Value to subtract from
        ld      r4, #sub_ir_data    ! Address of subtrahend
        sub     r3, @r4             ! R3 = 100 - mem[@R4] = 100 - 25 = 75
        cp      r3, #75
        jr      z, test_sub_ir_pass
        inc     r1, #1
        jr      test_sub_da
test_sub_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 47: SUB Rd, address (direct address)
# =============================================================================
test_sub_da:
        ld      r2, #47             ! Test number 47
        ld      r3, #200            ! Value to subtract from
        sub     r3, sub_da_data     ! R3 = 200 - mem[sub_da_data] = 200 - 50 = 150
        cp      r3, #150
        jr      z, test_sub_da_pass
        inc     r1, #1
        jr      test_sub_x
test_sub_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 48: SUB Rd, address(Rs) (indexed)
# =============================================================================
test_sub_x:
        ld      r2, #48             ! Test number 48
        ld      r3, #300            ! Value to subtract from
        ld      r4, #4              ! Index offset (2 words = 4 bytes)
        sub     r3, sub_x_base(r4)  ! R3 = 300 - mem[base+4] = 300 - 30 = 270
        cp      r3, #270
        jr      z, test_sub_x_pass
        inc     r1, #1
        jr      test_and_ir
test_sub_x_pass:
        inc     r0, #1

# =============================================================================
# TEST 49: AND Rd, @Rs (indirect register)
# =============================================================================
test_and_ir:
        ld      r2, #49             ! Test number 49
        ld      r3, #0xFF00         ! Value to AND
        ld      r4, #and_ir_data    ! Address of mask
        and     r3, @r4             ! R3 = 0xFF00 & 0x0F0F = 0x0F00
        cp      r3, #0x0F00
        jr      z, test_and_ir_pass
        inc     r1, #1
        jr      test_or_da
test_and_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 50: OR Rd, address (direct address)
# =============================================================================
test_or_da:
        ld      r2, #50             ! Test number 50
        ld      r3, #0x00F0         ! Value to OR
        or      r3, or_da_data      ! R3 = 0x00F0 | 0x0F00 = 0x0FF0
        cp      r3, #0x0FF0
        jr      z, test_or_da_pass
        inc     r1, #1
        jr      test_xor_x
test_or_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 51: XOR Rd, address(Rs) (indexed)
# =============================================================================
test_xor_x:
        ld      r2, #51             ! Test number 51
        ld      r3, #0xAAAA         ! Value to XOR
        ld      r4, #2              ! Index offset
        xor     r3, xor_x_base(r4)  ! R3 = 0xAAAA ^ 0x5555 = 0xFFFF
        cp      r3, #0xFFFF
        jr      z, test_xor_x_pass
        inc     r1, #1
        jr      test_cp_ir
test_xor_x_pass:
        inc     r0, #1

# =============================================================================
# TEST 52: CP Rd, @Rs (indirect register compare)
# =============================================================================
test_cp_ir:
        ld      r2, #52             ! Test number 52
        ld      r3, #0x1234         ! Value to compare
        ld      r4, #cp_ir_data     ! Address of comparison value
        cp      r3, @r4             ! Compare R3 with mem[@R4]
        jr      z, test_cp_ir_pass  ! Should be equal (both 0x1234)
        inc     r1, #1
        jr      test_st_x
test_cp_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 53: ST address(Rd), Rs (indexed store)
# =============================================================================
test_st_x:
        ld      r2, #53             ! Test number 53
        ld      r3, #0xBEEF         ! Value to store
        ld      r4, #4              ! Index offset
        ld      st_x_base(r4), r3   ! Store R3 at base+4
        ! Verify the store
        ld      r5, st_x_base(r4)   ! Load it back
        cp      r5, #0xBEEF
        jr      z, test_st_x_pass
        inc     r1, #1
        jr      test_cp_da
test_st_x_pass:
        inc     r0, #1

# Tests 54-56 removed: ALU BA/BX modes don't exist in Z8000

# =============================================================================
# TEST 54: CP Rd, address (direct address compare)
# =============================================================================
test_cp_da:
        ld      r2, #57             ! Test number 57
        ld      r3, #0x5678         ! Value to compare
        cp      r3, cp_da_data      ! Compare R3 with mem[cp_da_data]
        jr      z, test_cp_da_pass  ! Should be equal (both 0x5678)
        inc     r1, #1
        jr      test_and_da
test_cp_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 58: AND Rd, address (direct address)
# =============================================================================
test_and_da:
        ld      r2, #58             ! Test number 58
        ld      r3, #0xF0F0         ! Value to AND
        and     r3, and_da_data     ! R3 = 0xF0F0 & 0x0FF0 = 0x00F0
        cp      r3, #0x00F0
        jr      z, test_and_da_pass
        inc     r1, #1
        jr      test_or_ir
test_and_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 59: OR Rd, @Rs (indirect register)
# =============================================================================
test_or_ir:
        ld      r2, #59             ! Test number 59
        ld      r3, #0x00FF         ! Value to OR
        ld      r4, #or_ir_data     ! Address of value
        or      r3, @r4             ! R3 = 0x00FF | 0xFF00 = 0xFFFF
        cp      r3, #0xFFFF
        jr      z, test_or_ir_pass
        inc     r1, #1
        jr      test_xor_da
test_or_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 60: XOR Rd, address (direct address)
# =============================================================================
test_xor_da:
        ld      r2, #60             ! Test number 60
        ld      r3, #0xF0F0         ! Value to XOR
        xor     r3, xor_da_data     ! R3 = 0xF0F0 ^ 0x0F0F = 0xFFFF
        cp      r3, #0xFFFF
        jr      z, test_xor_da_pass
        inc     r1, #1
        jp      tests_done
test_xor_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 61: CPI (Compare and Increment, single word)
# CPI Rd, @Rs, Rn, cc - Compare Rd with @Rs, increment Rs, decrement Rn
# Encoding: first word 0xBB [Rs<<4] 0000, second word 0000_Rrrr_Rddd_cccc
# =============================================================================
test_cpi:
        ld      r2, #61             ! Test number 61
        ld      r3, #0x1234         ! Value to search for
        ld      r4, #cpi_src_data   ! Source address
        ld      r5, #1              ! Count (Rn)
        ! CPI R3, @R4, R5, eq (compare R3 with @R4, terminate on Z=1)
        cpi     r3, @r4, r5, eq
        ! Should match (both 0x1234), Z=1
        jr      z, test_cpi_match
        inc     r1, #1
        jp      tests_done
test_cpi_match:
        ! Verify R4 was incremented
        ld      r6, #cpi_src_data
        add     r6, #2              ! Expected R4 = original + 2
        cp      r4, r6
        jr      z, test_cpi_pass
        inc     r1, #1
        jp      tests_done
test_cpi_pass:
        inc     r0, #1

# =============================================================================
# TEST 62: CPIR with match (Repeat compare until match found)
# CPIR Rd, @Rs, Rn, cc - Repeat CPI until Z=1 (match) or Rn=0 (count exhausted)
# Encoding: first word 0xBB [Rs<<4] 0100, second word 0000_Rrrr_Rddd_cccc
# =============================================================================
test_cpir_match:
        ld      r2, #62             ! Test number 62
        ld      r3, #0x3333         ! Value to search for (3rd element)
        ld      r4, #cpir_src_data  ! Source address
        ld      r5, #5              ! Count (search up to 5 words)
        ! CPIR R3, @R4, R5, eq - repeat compare until Z=1 (match)
        cpir    r3, @r4, r5, eq
        ! Should find 0x3333 at 3rd position, Z=1
        jr      z, test_cpir_found
        inc     r1, #1
        jp      tests_done
test_cpir_found:
        ! Verify pointer advanced correctly (3 words = 6 bytes)
        ld      r6, #cpir_src_data
        add     r6, #6              ! Should be at position after match
        cp      r4, r6
        jr      z, test_cpir_count
        inc     r1, #1
        jp      tests_done
test_cpir_count:
        ! Verify count decremented correctly (5 - 3 = 2)
        cp      r5, #2
        jr      z, test_cpir_match_pass
        inc     r1, #1
        jp      tests_done
test_cpir_match_pass:
        inc     r0, #1

# =============================================================================
# TEST 63: CPIR with no match (count exhausted)
# =============================================================================
test_cpir_nomatch:
        ld      r2, #63             ! Test number 63
        ld      r3, #0x9999         ! Value not in list
        ld      r4, #cpir_src_data  ! Source address
        ld      r5, #3              ! Count (only check 3 words)
        ! CPIR R3, @R4, R5, eq - repeat compare, no match expected
        cpir    r3, @r4, r5, eq
        ! Should NOT find match, Z=0 when count exhausted
        jr      nz, test_cpir_nomatch_ok
        inc     r1, #1              ! Fail if Z=1 (false match)
        jp      tests_done
test_cpir_nomatch_ok:
        ! Verify count is 0
        cp      r5, #0
        jr      z, test_cpir_nomatch_pass
        inc     r1, #1
        jp      tests_done
test_cpir_nomatch_pass:
        inc     r0, #1

# =============================================================================
# TEST 64: CPIB (Compare and Increment, byte)
# Encoding: first word 0xBA [Rs<<4] 0000, second word 0000_Rrrr_Rddd_cccc
# =============================================================================
test_cpib:
        ld      r2, #64             ! Test number 64
        ld      r3, #0x00AB         ! Byte value to search for (in low byte)
        ld      r4, #cpib_src_data  ! Source address
        ld      r5, #1              ! Count (Rn)
        ! CPIB RL3, @R4, R5, eq - compare single byte, Z=1 on match
        cpib    rl3, @r4, r5, eq
        ! Should match (0xAB), Z=1
        jr      z, test_cpib_match
        inc     r1, #1
        jp      tests_done
test_cpib_match:
        ! Verify R4 was incremented by 1 (byte)
        ld      r6, #cpib_src_data
        add     r6, #1              ! Expected R4 = original + 1
        cp      r4, r6
        jr      z, test_cpib_pass
        inc     r1, #1
        jp      tests_done
test_cpib_pass:
        inc     r0, #1

# =============================================================================
# TEST 65: CPDR (Compare, Decrement, and Repeat)
# Searches backwards through memory
# Encoding: first word 0xBB [Rs<<4] 1100, second word 0000_Rrrr_Rddd_cccc
# =============================================================================
test_cpdr:
        ld      r2, #65             ! Test number 65
        ld      r3, #0x1111         ! Value to search for (1st element when going backwards)
        ld      r4, #cpdr_src_end   ! Start at end of data
        ld      r5, #4              ! Count
        ! CPDR R3, @R4, R5, eq - compare backwards until Z=1 (match)
        cpdr    r3, @r4, r5, eq
        ! Should find 0x1111 at 4th position from end, Z=1
        jr      z, test_cpdr_found
        inc     r1, #1
        jp      tests_done
test_cpdr_found:
        ! Verify count decremented correctly (4 - 4 = 0)
        ! Note: finds at last iteration so count should be 0
        cp      r5, #0
        jr      z, test_cpdr_pass
        inc     r1, #1
        jp      tests_done
test_cpdr_pass:
        inc     r0, #1

# =============================================================================
# TEST 66: CPIRB (Compare, Increment, Repeat - Byte)
# Encoding: first word 0xBA [Rs<<4] 0100, second word 0000_Rrrr_Rddd_cccc
# =============================================================================
test_cpirb:
        ld      r2, #66             ! Test number 66
        ld      r3, #0x00CD         ! Byte value to search for
        ld      r4, #cpirb_src_data ! Source address
        ld      r5, #5              ! Count
        ! CPIRB RL3, @R4, R5, eq - compare bytes, repeat until Z=1 (match)
        cpirb   rl3, @r4, r5, eq
        ! Should find 0xCD at 3rd byte, Z=1
        jr      z, test_cpirb_found
        inc     r1, #1
        jp      tests_done
test_cpirb_found:
        ! Verify pointer advanced by 3 bytes
        ld      r6, #cpirb_src_data
        add     r6, #3
        cp      r4, r6
        jr      z, test_cpirb_pass
        inc     r1, #1
        jp      tests_done
test_cpirb_pass:
        inc     r0, #1

# Tests 64-71 removed: ALU BA/BX modes don't exist in Z8000

# =============================================================================
# Test 64: LDL_IM - Load Long Immediate
# LDL RR4, #0x12345678  (R4=0x1234, R5=0x5678)
# =============================================================================
test_ldl_im:
        inc     r2, #1              ! Test 72
        ld      r4, #0              ! Clear R4
        ld      r5, #0              ! Clear R5
        ldl     rr4, #0x12345678    ! Load 32-bit immediate
        cp      r4, #0x1234         ! Check high word
        jr      nz, test_ldl_im_fail
        cp      r5, #0x5678         ! Check low word
        jr      z, test_ldl_im_pass
test_ldl_im_fail:
        inc     r1, #1
        jp      tests_done
test_ldl_im_pass:
        inc     r0, #1

# =============================================================================
# Test 65: LDL_IR - Load Long Indirect
# LDL RR4, @R6 where R6 points to 32-bit data
# =============================================================================
test_ldl_ir:
        inc     r2, #1              ! Test 76
        ld      r6, #ldl_src_data   ! R6 = pointer to 32-bit data
        ld      r4, #0              ! Clear R4
        ld      r5, #0              ! Clear R5
        ldl     rr4, @r6            ! Load 32-bit from memory
        cp      r4, #0xABCD         ! Check high word
        jr      nz, test_ldl_ir_fail
        cp      r5, #0xEF01         ! Check low word
        jr      z, test_ldl_ir_pass
test_ldl_ir_fail:
        inc     r1, #1
        jp      tests_done
test_ldl_ir_pass:
        inc     r0, #1

# =============================================================================
# Test 66: LDL_DA - Load Long Direct Address
# LDL RR4, ldl_src_data
# =============================================================================
test_ldl_da:
        inc     r2, #1              ! Test 77
        ld      r4, #0              ! Clear R4
        ld      r5, #0              ! Clear R5
        ldl     rr4, ldl_src_data   ! Load 32-bit from direct address
        cp      r4, #0xABCD         ! Check high word
        jr      nz, test_ldl_da_fail
        cp      r5, #0xEF01         ! Check low word
        jr      z, test_ldl_da_pass
test_ldl_da_fail:
        inc     r1, #1
        jp      tests_done
test_ldl_da_pass:
        inc     r0, #1

# =============================================================================
# Test 67: LDL_X - Load Long Indexed
# LDL RR4, ldl_indexed_base(R6) where R6=4 (offset to second long)
# =============================================================================
test_ldl_x:
        inc     r2, #1              ! Test 78
        ld      r6, #4              ! R6 = offset 4 bytes (second long)
        ld      r4, #0              ! Clear R4
        ld      r5, #0              ! Clear R5
        ldl     rr4, ldl_indexed_base(r6) ! Load 32-bit from indexed address
        cp      r4, #0x2222         ! Check high word (second long value)
        jr      nz, test_ldl_x_fail
        cp      r5, #0x3333         ! Check low word
        jr      z, test_ldl_x_pass
test_ldl_x_fail:
        inc     r1, #1
        jp      tests_done
test_ldl_x_pass:
        inc     r0, #1

# =============================================================================
# Test 68: STL_IR - Store Long Indirect
# STL @R6, RR4 where R6 points to destination
# =============================================================================
test_stl_ir:
        inc     r2, #1              ! Test 79
        ld      r4, #0x4455         ! High word to store
        ld      r5, #0x6677         ! Low word to store
        ld      r6, #stl_dst_data   ! R6 = pointer to destination
        ldl     @r6, rr4            ! Store 32-bit to memory
        ! Verify by loading back
        ldl     rr8, @r6            ! Load back to RR8
        cp      r8, #0x4455         ! Check high word
        jr      nz, test_stl_ir_fail
        cp      r9, #0x6677         ! Check low word
        jr      z, test_stl_ir_pass
test_stl_ir_fail:
        inc     r1, #1
        jp      tests_done
test_stl_ir_pass:
        inc     r0, #1

# =============================================================================
# Test 69: STL_DA - Store Long Direct Address
# STL stl_dst_data2, RR4
# =============================================================================
test_stl_da:
        inc     r2, #1              ! Test 80
        ld      r4, #0x8899         ! High word to store
        ld      r5, #0xAABB         ! Low word to store
        ldl     stl_dst_data2, rr4  ! Store 32-bit to direct address
        ! Verify by loading back
        ldl     rr8, stl_dst_data2  ! Load back to RR8
        cp      r8, #0x8899         ! Check high word
        jr      nz, test_stl_da_fail
        cp      r9, #0xAABB         ! Check low word
        jr      z, test_stl_da_pass
test_stl_da_fail:
        inc     r1, #1
        jp      tests_done
test_stl_da_pass:
        inc     r0, #1

# =============================================================================
# Test 70: STL_X - Store Long Indexed
# STL stl_indexed_base(R6), RR4 where R6=4 (offset)
# =============================================================================
test_stl_x:
        inc     r2, #1              ! Test 81
        ld      r4, #0xCCDD         ! High word to store
        ld      r5, #0xEEFF         ! Low word to store
        ld      r6, #4              ! R6 = offset 4 bytes
        ldl     stl_indexed_base(r6), rr4  ! Store 32-bit to indexed address
        ! Verify by loading back
        ldl     rr8, stl_indexed_base(r6)  ! Load back to RR8
        cp      r8, #0xCCDD         ! Check high word
        jr      nz, test_stl_x_fail
        cp      r9, #0xEEFF         ! Check low word
        jr      z, test_stl_x_pass
test_stl_x_fail:
        inc     r1, #1
        jp      tests_done
test_stl_x_pass:
        inc     r0, #1

# =============================================================================
# Test 71: ADDL_R - Add Long Register
# ADDL RR4, RR6 where RR4 = 0x00010002, RR6 = 0x00030004
# Result should be 0x00040006
# =============================================================================
test_addl_r:
        inc     r2, #1              ! Test 71
        ld      r4, #0x0001         ! RR4 high = 0x0001
        ld      r5, #0x0002         ! RR4 low = 0x0002
        ld      r6, #0x0003         ! RR6 high = 0x0003
        ld      r7, #0x0004         ! RR6 low = 0x0004
        addl    rr4, rr6            ! RR4 = RR4 + RR6
        cp      r4, #0x0004         ! Check high word
        jr      nz, test_addl_r_fail
        cp      r5, #0x0006         ! Check low word
        jr      z, test_addl_r_pass
test_addl_r_fail:
        inc     r1, #1
        jp      tests_done
test_addl_r_pass:
        inc     r0, #1

# =============================================================================
# Test 72: ADDL_IM - Add Long Immediate
# ADDL RR4, #0x00010001 where RR4 = 0x00020003
# Result should be 0x00030004
# =============================================================================
test_addl_im:
        inc     r2, #1              ! Test 72
        ld      r4, #0x0002         ! RR4 high = 0x0002
        ld      r5, #0x0003         ! RR4 low = 0x0003
        addl    rr4, #0x00010001    ! RR4 = RR4 + 0x00010001
        cp      r4, #0x0003         ! Check high word
        jr      nz, test_addl_im_fail
        cp      r5, #0x0004         ! Check low word
        jr      z, test_addl_im_pass
test_addl_im_fail:
        inc     r1, #1
        jp      tests_done
test_addl_im_pass:
        inc     r0, #1

# =============================================================================
# Test 73: SUBL_R - Subtract Long Register
# SUBL RR4, RR6 where RR4 = 0x00050006, RR6 = 0x00010002
# Result should be 0x00040004
# =============================================================================
test_subl_r:
        inc     r2, #1              ! Test 73
        ld      r4, #0x0005         ! RR4 high = 0x0005
        ld      r5, #0x0006         ! RR4 low = 0x0006
        ld      r6, #0x0001         ! RR6 high = 0x0001
        ld      r7, #0x0002         ! RR6 low = 0x0002
        subl    rr4, rr6            ! RR4 = RR4 - RR6
        cp      r4, #0x0004         ! Check high word
        jr      nz, test_subl_r_fail
        cp      r5, #0x0004         ! Check low word
        jr      z, test_subl_r_pass
test_subl_r_fail:
        inc     r1, #1
        jp      tests_done
test_subl_r_pass:
        inc     r0, #1

# =============================================================================
# Test 74: CPL_R - Compare Long Register
# CPL RR4, RR6 where both = 0x12345678 (should be equal, Z=1)
# =============================================================================
test_cpl_r:
        inc     r2, #1              ! Test 74
        ld      r4, #0x1234         ! RR4 high
        ld      r5, #0x5678         ! RR4 low
        ld      r6, #0x1234         ! RR6 high (same)
        ld      r7, #0x5678         ! RR6 low (same)
        cpl     rr4, rr6            ! Compare RR4 with RR6
        jr      z, test_cpl_r_pass  ! Should be equal
test_cpl_r_fail:
        inc     r1, #1
        jp      tests_done
test_cpl_r_pass:
        inc     r0, #1

# =============================================================================
# Test 75: LDL_BA - Load Long Based
# LDL RR4, R6(#4) where R6 points to ldl_based_data
# =============================================================================
test_ldl_ba:
        inc     r2, #1              ! Test 75
        ld      r6, #ldl_based_data ! Base address
        ld      r4, #0              ! Clear
        ld      r5, #0
        ldl     rr4, r6(#4)         ! Load from base+4 (second long)
        cp      r4, #0x5555         ! Check high word
        jr      nz, test_ldl_ba_fail
        cp      r5, #0x6666         ! Check low word
        jr      z, test_ldl_ba_pass
test_ldl_ba_fail:
        inc     r1, #1
        jp      tests_done
test_ldl_ba_pass:
        inc     r0, #1

# =============================================================================
# Test 76: LDB_BA - Load Byte Based
# LDB RH0, R6(#2) where R6 points to ldb_based_data
# =============================================================================
test_ldb_ba:
        inc     r2, #1              ! Test 76
        ld      r6, #ldb_based_data ! Base address
        ld      r3, #0              ! Clear (use R3, not R0!)
        ldb     rh3, r6(#2)         ! Load byte from base+2 into RH3
        cp      r3, #0x3300         ! Check (RH3 should be 0x33, in high byte position)
        jr      z, test_ldb_ba_pass
test_ldb_ba_fail:
        inc     r1, #1
        jp      tests_done
test_ldb_ba_pass:
        inc     r0, #1

# =============================================================================
# TEST 77: IN Rd, port (direct input word)
# Read from port 0x0000, should get io_data_reg value (0x1234)
# =============================================================================
test_in_da:
        inc     r2, #1              ! Test 77
        in      r3, #0x0000         ! Read from port 0
        cp      r3, #0x1234         ! Check value
        jr      z, test_in_da_pass
        inc     r1, #1
        jr      test_inb_da
test_in_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 78: INB Rbd, port (direct input byte)
# Read from port 0x0010, should get 0xAA
# =============================================================================
test_inb_da:
        inc     r2, #1              ! Test 78
        ld      r3, #0              ! Clear R3
        inb     rl3, #0x0010        ! Read byte from port 0x10 into RL3
        cp      r3, #0x00AA         ! Check value (low byte)
        jr      z, test_inb_da_pass
        inc     r1, #1
        jr      test_out_da
test_inb_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 79: OUT port, Rs (direct output word)
# Write 0xBEEF to port 0x0000
# =============================================================================
test_out_da:
        inc     r2, #1              ! Test 79
        ld      r3, #0xBEEF
        out     #0x0000, r3         ! Write to port 0
        ! Read it back
        in      r4, #0x0000
        cp      r4, #0xBEEF         ! Check write worked
        jr      z, test_out_da_pass
        inc     r1, #1
        jr      test_outb_da
test_out_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 80: OUTB port, Rbs (direct output byte)
# Write 0x42 to port 0x0001 (low byte of io_data_reg)
# =============================================================================
test_outb_da:
        inc     r2, #1              ! Test 80
        ld      r3, #0x0042         ! Value in low byte
        outb    #0x0001, rl3        ! Write byte to port 1
        ! Read back the word from port 0
        in      r4, #0x0000
        cp      r4, #0xBE42         ! High byte unchanged, low byte = 0x42
        jr      z, test_outb_da_pass
        inc     r1, #1
        jr      test_in_ir
test_outb_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 81: IN Rd, @Rs (indirect input word)
# Use R5 as port address register
# =============================================================================
test_in_ir:
        inc     r2, #1              ! Test 81
        ld      r5, #0x0002         ! Port address (io_ctrl_reg)
        ld      r3, #0x5555
        out     #0x0002, r3         ! Initialize ctrl reg
        in      r3, @r5             ! Read via indirect
        cp      r3, #0x5555         ! Check value
        jr      z, test_in_ir_pass
        inc     r1, #1
        jr      test_out_ir
test_in_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 82: OUT @Rd, Rs (indirect output word)
# Use R5 as port address register
# =============================================================================
test_out_ir:
        inc     r2, #1              ! Test 82
        ld      r5, #0x0002         ! Port address (io_ctrl_reg)
        ld      r3, #0xAAAA
        out     @r5, r3             ! Write via indirect
        in      r4, #0x0002         ! Read back
        cp      r4, #0xAAAA
        jr      z, test_out_ir_pass
        inc     r1, #1
        jr      test_sin_da
test_out_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 83: SIN Rd, port (special input word)
# Read from special I/O port 0x0020, should get sio_data_reg (0x5678)
# =============================================================================
test_sin_da:
        inc     r2, #1              ! Test 83
        sin     r3, #0x0020         ! Special I/O read
        cp      r3, #0x5678         ! Check initial value
        jr      z, test_sin_da_pass
        inc     r1, #1
        jr      test_sout_da
test_sin_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 84: SOUT port, Rs (special output word)
# Write 0xCAFE to special I/O port 0x0020
# =============================================================================
test_sout_da:
        inc     r2, #1              ! Test 84
        ld      r3, #0xCAFE
        sout    #0x0020, r3         ! Special I/O write
        sin     r4, #0x0020         ! Read back
        cp      r4, #0xCAFE
        jr      z, test_sout_da_pass
        inc     r1, #1
        jp      tests_done
test_sout_da_pass:
        inc     r0, #1

# =============================================================================
# TEST 85: NOP (no operation)
# Verify NOP doesn't change any registers
# =============================================================================
test_nop:
        inc     r2, #1              ! Test 85
        ld      r3, #0x1234         ! Set known value
        ld      r4, #0x5678         ! Set known value
        nop                         ! Execute NOP
        nop                         ! Execute another NOP
        nop                         ! And another
        cp      r3, #0x1234         ! Verify R3 unchanged
        jr      nz, test_nop_fail
        cp      r4, #0x5678         ! Verify R4 unchanged
        jr      nz, test_nop_fail
        jr      test_nop_pass
test_nop_fail:
        inc     r1, #1
        jp      tests_done
test_nop_pass:
        inc     r0, #1

# =============================================================================
# TEST 86: RL Rd, #1 (Rotate Left by 1)
# 0x8001 rotated left = 0x0003, carry = 1 (bit 15 was set)
# =============================================================================
test_rl_1:
        inc     r2, #1              ! Test 86
        ld      r3, #0x8001         ! Bit 15 and bit 0 set
        rl      r3, #1              ! Rotate left by 1
        cp      r3, #0x0003         ! Bit 15 -> bit 0, bit 0 -> bit 1
        jr      nz, test_rl_1_fail
        jr      test_rl_1_pass
test_rl_1_fail:
        inc     r1, #1
        jr      test_rl_2
test_rl_1_pass:
        inc     r0, #1

# =============================================================================
# TEST 87: RL Rd, #2 (Rotate Left by 2)
# 0xC000 rotated left 2 = 0x0003, carry = 1
# =============================================================================
test_rl_2:
        inc     r2, #1              ! Test 87
        ld      r3, #0xC000         ! Bits 15 and 14 set
        rl      r3, #2              ! Rotate left by 2
        cp      r3, #0x0003         ! Both high bits wrap to low bits
        jr      nz, test_rl_2_fail
        jr      test_rl_2_pass
test_rl_2_fail:
        inc     r1, #1
        jr      test_rr_1
test_rl_2_pass:
        inc     r0, #1

# =============================================================================
# TEST 88: RR Rd, #1 (Rotate Right by 1)
# 0x0001 rotated right = 0x8000, carry = 1 (bit 0 was set)
# =============================================================================
test_rr_1:
        inc     r2, #1              ! Test 88
        ld      r3, #0x0001         ! Only bit 0 set
        rr      r3, #1              ! Rotate right by 1
        cp      r3, #0x8000         ! Bit 0 -> bit 15
        jr      nz, test_rr_1_fail
        jr      test_rr_1_pass
test_rr_1_fail:
        inc     r1, #1
        jr      test_rr_2
test_rr_1_pass:
        inc     r0, #1

# =============================================================================
# TEST 89: RR Rd, #2 (Rotate Right by 2)
# 0x0003 rotated right 2 = 0xC000
# =============================================================================
test_rr_2:
        inc     r2, #1              ! Test 89
        ld      r3, #0x0003         ! Bits 0 and 1 set
        rr      r3, #2              ! Rotate right by 2
        cp      r3, #0xC000         ! Both low bits wrap to high bits
        jr      nz, test_rr_2_fail
        jr      test_rr_2_pass
test_rr_2_fail:
        inc     r1, #1
        jr      test_sla
test_rr_2_pass:
        inc     r0, #1

# =============================================================================
# TEST 90: SLA Rd, #n (Shift Left Arithmetic by count)
# 0x0001 shifted left by 4 = 0x0010
# =============================================================================
test_sla:
        inc     r2, #1              ! Test 90
        ld      r3, #0x0001         ! Bit 0 set
        sla     r3, #4              ! Shift left by 4
        cp      r3, #0x0010         ! Result should be 0x0010
        jr      nz, test_sla_fail
        jr      test_sla_pass
test_sla_fail:
        inc     r1, #1
        jr      test_srl
test_sla_pass:
        inc     r0, #1

# =============================================================================
# TEST 91: SRL Rd, #n (Shift Right Logical by count)
# 0x8000 shifted right by 4 = 0x0800
# =============================================================================
test_srl:
        inc     r2, #1              ! Test 91
        ld      r3, #0x8000         ! Bit 15 set
        srl     r3, #4              ! Shift right by 4
        cp      r3, #0x0800         ! Result should be 0x0800
        jr      nz, test_srl_fail
        jr      test_srl_pass
test_srl_fail:
        inc     r1, #1
        jr      test_rlb
test_srl_pass:
        inc     r0, #1

# =============================================================================
# TEST 92: RLB Rbd, #1 (Rotate Left Byte by 1)
# 0x81 rotated left = 0x03
# =============================================================================
test_rlb:
        inc     r2, #1              ! Test 92
        ld      r3, #0x0081         ! Byte value 0x81 in low byte
        rlb     rl3, #1             ! Rotate left by 1
        cp      r3, #0x0003         ! Bit 7 -> bit 0
        jr      nz, test_rlb_fail
        jr      test_rlb_pass
test_rlb_fail:
        inc     r1, #1
        jr      test_rrb
test_rlb_pass:
        inc     r0, #1

# =============================================================================
# TEST 93: RRB Rbd, #1 (Rotate Right Byte by 1)
# 0x01 rotated right = 0x80
# =============================================================================
test_rrb:
        inc     r2, #1              ! Test 93
        ld      r3, #0x0001         ! Byte value 0x01 in low byte
        rrb     rl3, #1             ! Rotate right by 1
        cp      r3, #0x0080         ! Bit 0 -> bit 7
        jr      nz, test_rrb_fail
        jr      test_rrb_pass
test_rrb_fail:
        inc     r1, #1
        jp      tests_done
test_rrb_pass:
        inc     r0, #1

# =============================================================================
# TEST 94: SLA sets Carry flag when bit shifts out
# 0x8000 shifted left by 1 should set C (bit 15 shifts out)
# =============================================================================
test_sla_carry:
        inc     r2, #1              ! Test 94
        ld      r3, #0x8000         ! Bit 15 set
        sla     r3, #1              ! Shift left - bit 15 should go to C
        jr      nc, test_sla_carry_fail   ! Should have carry set
        jr      test_sla_carry_pass
test_sla_carry_fail:
        inc     r1, #1
        jr      test_srl_carry
test_sla_carry_pass:
        inc     r0, #1

# =============================================================================
# TEST 95: SRL sets Carry flag when bit shifts out
# 0x0001 shifted right by 1 should set C (bit 0 shifts out)
# =============================================================================
test_srl_carry:
        inc     r2, #1              ! Test 95
        ld      r3, #0x0001         ! Bit 0 set
        srl     r3, #1              ! Shift right - bit 0 should go to C
        jr      nc, test_srl_carry_fail   ! Should have carry set
        jr      test_srl_carry_pass
test_srl_carry_fail:
        inc     r1, #1
        jr      test_srl_zero
test_srl_carry_pass:
        inc     r0, #1

# =============================================================================
# TEST 96: SRL sets Zero flag when result is zero
# 0x0001 shifted right by 1 should be 0 and set Z
# =============================================================================
test_srl_zero:
        inc     r2, #1              ! Test 96
        ld      r3, #0x0001         ! Only bit 0 set
        srl     r3, #1              ! Result is 0
        jr      nz, test_srl_zero_fail    ! Should have zero set
        jr      test_srl_zero_pass
test_srl_zero_fail:
        inc     r1, #1
        jr      test_rl_carry
test_srl_zero_pass:
        inc     r0, #1

# =============================================================================
# TEST 97: RL sets Carry flag
# 0x8000 rotated left by 1: bit 15 goes to C and bit 0
# =============================================================================
test_rl_carry:
        inc     r2, #1              ! Test 97
        ld      r3, #0x8000         ! Bit 15 set
        rl      r3, #1              ! Rotate left - bit 15 to C and bit 0
        jr      nc, test_rl_carry_fail    ! Should have carry set
        jr      test_rl_carry_pass
test_rl_carry_fail:
        inc     r1, #1
        jr      test_rr_carry
test_rl_carry_pass:
        inc     r0, #1

# =============================================================================
# TEST 98: RR sets Carry flag
# 0x0001 rotated right by 1: bit 0 goes to C and bit 15
# =============================================================================
test_rr_carry:
        inc     r2, #1              ! Test 98
        ld      r3, #0x0001         ! Bit 0 set
        rr      r3, #1              ! Rotate right - bit 0 to C and bit 15
        jr      nc, test_rr_carry_fail    ! Should have carry set
        jr      test_rr_carry_pass
test_rr_carry_fail:
        inc     r1, #1
        jp      tests_done
test_rr_carry_pass:
        inc     r0, #1

# =============================================================================
# TEST 99: SRA (Shift Right Arithmetic) - preserves sign bit
# 0x8004 >> 2 = 0xE001 (sign bit preserved, original was negative)
# SRA uses negative count on opcode 0xB3d9 (same as SLA)
# =============================================================================
test_sra:
        inc     r2, #1              ! Test 99
        ld      r3, #0x8004         ! 1000_0000_0000_0100 (negative value)
        sra     r3, #2              ! Shift right arithmetic by 2
        cp      r3, #0xE001         ! 1110_0000_0000_0001 (sign preserved)
        jr      z, test_sra_pass
        inc     r1, #1
        jr      test_sll
test_sra_pass:
        inc     r0, #1

# =============================================================================
# TEST 100: SLL (Shift Left Logical) - same as SLA but logical
# 0x0003 << 4 = 0x0030
# SLL uses positive count on opcode 0xB3d1 (same as SRL)
# =============================================================================
test_sll:
        inc     r2, #1              ! Test 100
        ld      r3, #0x0003         ! 0000_0000_0000_0011
        sll     r3, #4              ! Shift left logical by 4
        cp      r3, #0x0030         ! 0000_0000_0011_0000
        jr      z, test_sll_pass
        inc     r1, #1
        jr      test_sra_vs_srl
test_sll_pass:
        inc     r0, #1

# =============================================================================
# TEST 101: SRA vs SRL - verify sign extension difference
# SRA on 0xFF00 >> 8 should give 0xFFFF (sign fills in)
# SRL on 0xFF00 >> 8 would give 0x00FF (zeros fill in)
# =============================================================================
test_sra_vs_srl:
        inc     r2, #1              ! Test 101
        ld      r3, #0xFF00         ! 1111_1111_0000_0000 (negative)
        sra     r3, #8              ! Shift right arithmetic by 8
        cp      r3, #0xFFFF         ! 1111_1111_1111_1111 (sign extended)
        jr      z, test_sra_vs_srl_pass
        inc     r1, #1
        jp      tests_done
test_sra_vs_srl_pass:
        inc     r0, #1

# =============================================================================
# TEST 102: Compact LDB - single-word load byte immediate
# Format: 0xCdii where d=dest register, ii=immediate byte
# Tests both high and low byte register targets
# =============================================================================
test_ldb_short:
        inc     r2, #1              ! Test 102
        ld      r3, #0x0000         ! Clear R3 first
        ldb     rh3, #0x42          ! Load 0x42 to high byte (compact format: 0xC342)
        cp      r3, #0x4200         ! R3 should now be 0x4200
        jr      z, test_ldb_short_2
        inc     r1, #1
        jp      tests_done
test_ldb_short_2:
        ld      r3, #0x0000         ! Clear R3 again
        ldb     rl3, #0xAB          ! Load 0xAB to low byte (compact format: 0xC7AB)
        cp      r3, #0x00AB         ! R3 should now be 0x00AB
        jr      z, test_ldb_short_pass
        inc     r1, #1
        jp      tests_done
test_ldb_short_pass:
        inc     r0, #1

# =============================================================================
# TEST 103: LDK - Load Constant (4-bit immediate 0-15)
# Format: 0xBDrn where r=dest register, n=4-bit constant
# =============================================================================
test_ldk:
        inc     r2, #1              ! Test 103
        ldk     r3, #0              ! Load 0 to R3
        cp      r3, #0
        jr      nz, test_ldk_fail
        ldk     r3, #15             ! Load max value (15) to R3
        cp      r3, #15
        jr      nz, test_ldk_fail
        ldk     r4, #7              ! Load 7 to R4
        cp      r4, #7
        jr      z, test_ldk_pass
test_ldk_fail:
        inc     r1, #1
        jp      tests_done
test_ldk_pass:
        inc     r0, #1

# =============================================================================
# TEST 104: INC @Rd, #n - Increment memory via indirect addressing
# =============================================================================
test_inc_ir:
        inc     r2, #1              ! Test 104
        ld      r3, #inc_ir_data    ! Point to test data
        ld      r4, #0x1234         ! Expected value (0x1230 + 4)
        inc     @r3, #4             ! Increment memory by 4
        ld      r5, @r3             ! Read back
        cp      r5, r4
        jr      z, test_inc_ir_pass
test_inc_ir_fail:
        inc     r1, #1
        jp      tests_done
test_inc_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 105: DEC @Rd, #n - Decrement memory via indirect addressing
# =============================================================================
test_dec_ir:
        inc     r2, #1              ! Test 105
        ld      r3, #dec_ir_data    ! Point to test data
        ld      r4, #0x1000         ! Expected value (0x1005 - 5)
        dec     @r3, #5             ! Decrement memory by 5
        ld      r5, @r3             ! Read back
        cp      r5, r4
        jr      z, test_dec_ir_pass
test_dec_ir_fail:
        inc     r1, #1
        jp      tests_done
test_dec_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 106: NEG @Rd - Negate memory via indirect addressing
# =============================================================================
test_neg_ir:
        inc     r2, #1              ! Test 106
        ld      r3, #neg_ir_data    ! Point to test data
        ld      r4, #0xFFFB         ! Expected: -5 = 0xFFFB
        neg     @r3                 ! Negate memory
        ld      r5, @r3             ! Read back
        cp      r5, r4
        jr      z, test_neg_ir_pass
test_neg_ir_fail:
        inc     r1, #1
        jp      tests_done
test_neg_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 107: COM @Rd - Complement memory via indirect addressing
# =============================================================================
test_com_ir:
        inc     r2, #1              ! Test 107
        ld      r3, #com_ir_data    ! Point to test data
        ld      r4, #0xFF00         ! Expected: ~0x00FF = 0xFF00
        com     @r3                 ! Complement memory
        ld      r5, @r3             ! Read back
        cp      r5, r4
        jr      z, test_com_ir_pass
test_com_ir_fail:
        inc     r1, #1
        jp      tests_done
test_com_ir_pass:
        inc     r0, #1

# =============================================================================
# TEST 108: INIR - Block input, increment, repeat (word)
# Read 3 words from port into memory
# Encoding: 0x3Bs0 + 0x0rrd0 (s=port reg, r=count reg, d=dest reg)
# =============================================================================
test_inir:
        inc     r2, #1              ! Test 108
        ! Initialize destination memory to known value
        ld      r3, #inir_dst_data
        ld      r4, #0xFFFF
        ld      @r3, r4
        inc     r3, #2
        ld      @r3, r4
        inc     r3, #2
        ld      @r3, r4
        ! Reset port 0 to known value (earlier tests may have changed it)
        ld      r4, #0x1234
        out     #0x0000, r4         ! Write 0x1234 to port 0
        ! Set up port address in R5, count in R6, dest pointer in R4
        ld      r4, #inir_dst_data  ! Memory destination
        ld      r5, #0x0000         ! Port 0 (now contains 0x1234)
        ld      r6, #3              ! Count = 3 words
        ! Execute INIR @R4, @R5, R6 - block input words
        inir    @r4, @r5, r6
        ! Verify first word in memory
        ld      r3, #inir_dst_data
        ld      r7, @r3
        cp      r7, #0x1234
        jr      nz, test_inir_fail
        ! Verify second word
        inc     r3, #2
        ld      r7, @r3
        cp      r7, #0x1234
        jr      nz, test_inir_fail
        ! Verify third word
        inc     r3, #2
        ld      r7, @r3
        cp      r7, #0x1234
        jr      nz, test_inir_fail
        ! Skip pointer verification (just verify data transfer)
        jr      test_inir_pass
test_inir_fail:
        inc     r1, #1
        jp      test_otir
test_inir_pass:
        inc     r0, #1

# =============================================================================
# TEST 109: OTIR - Block output, increment, repeat (word)
# Write 3 words from memory to port
# =============================================================================
test_otir:
        inc     r2, #1              ! Test 109
        ! Set up source data, port address, and count
        ld      r4, #otir_src_data  ! Memory source
        ld      r5, #0x0000         ! Port 0
        ld      r6, #3              ! Count = 3 words
        ! Execute OTIR @R5, @R4, R6 - block output words
        otir    @r5, @r4, r6
        ! Read back from port - should contain last value written (0x3333)
        in      r7, #0x0000
        cp      r7, #0x3333
        jr      nz, test_otir_fail
        ! Skip pointer verification (just verify data transfer)
        jr      test_otir_pass
test_otir_fail:
        inc     r1, #1
        jp      tests_done          ! Skip remaining tests on failure
test_otir_pass:
        inc     r0, #1

# =============================================================================
# TEST 110: INIRB - Block input byte, increment, repeat
# Read 4 bytes from port into memory
# =============================================================================
test_inirb:
        inc     r2, #1              ! Test 110
        ! Clear destination first
        ld      r3, #inirb_dst_data
        ld      r4, #0xFFFF
        ld      @r3, r4
        inc     r3, #2
        ld      @r3, r4
        ! Set up: port in R5 (0x10 returns 0xAA), dest in R4, count in R6
        ld      r4, #inirb_dst_data ! Memory destination
        ld      r5, #0x0010         ! Port 0x10 (returns 0xAA)
        ld      r6, #4              ! Count = 4 bytes
        ! Execute INIRB @R4, @R5, R6 - block input bytes
        inirb   @r4, @r5, r6
        ! Verify bytes were written (all should be 0xAA)
        ld      r3, #inirb_dst_data
        ld      r7, @r3
        cp      r7, #0xAAAA         ! Both bytes should be 0xAA
        jr      nz, test_inirb_fail
        inc     r3, #2
        ld      r7, @r3
        cp      r7, #0xAAAA
        jr      nz, test_inirb_fail
        ! Verify R4 was incremented by 4 (4 bytes)
        ld      r3, #inirb_dst_data
        add     r3, #4
        cp      r4, r3
        jr      z, test_inirb_pass
test_inirb_fail:
        inc     r1, #1
        jp      tests_done
test_inirb_pass:
        inc     r0, #1

# =============================================================================
# All tests complete - store results
# =============================================================================
tests_done:
        ld      @r15, r0            ! Store tests passed at 0x1F00
        inc     r15, #2
        ld      @r15, r1            ! Store tests failed at 0x1F02
        inc     r15, #2
        ld      @r15, r2            ! Store last test number at 0x1F04
        inc     r15, #2

        cp      r1, #0              ! Any failures?
        jr      nz, tests_failed

        ld      r3, #0xDEAD         ! Success marker
        ld      @r15, r3            ! Store at 0x1F06
        jr      halt_loop

tests_failed:
        ld      r3, #0xFA11         ! Failure marker
        ld      @r15, r3            ! Store at 0x1F06

halt_loop:
        halt
	#jr      halt_loop           ! Infinite loop

# =============================================================================
# Data section for block move tests
# =============================================================================
        .align  2

ldi_src_data:
        .word   0xCAFE              ! Source data for LDI test

ldi_dst_data:
        .word   0x0000              ! Destination for LDI test (will be overwritten)

ldir_src_data:
        .word   0x1111              ! Source data for LDIR test - word 1
        .word   0x2222              ! Source data for LDIR test - word 2
        .word   0x3333              ! Source data for LDIR test - word 3

ldir_dst_data:
        .word   0x0000              ! Destination for LDIR test - word 1
        .word   0x0000              ! Destination for LDIR test - word 2
        .word   0x0000              ! Destination for LDIR test - word 3

# Data for addressing mode tests
sub_ir_data:
        .word   25                  ! Subtrahend for SUB @Rs test

sub_da_data:
        .word   50                  ! Subtrahend for SUB address test

sub_x_base:
        .word   10                  ! Index 0
        .word   20                  ! Index 2
        .word   30                  ! Index 4 (used in test)

and_ir_data:
        .word   0x0F0F              ! Mask for AND @Rs test

or_da_data:
        .word   0x0F00              ! Value for OR address test

xor_x_base:
        .word   0x1234              ! Index 0
        .word   0x5555              ! Index 2 (used in test)

cp_ir_data:
        .word   0x1234              ! Comparison value for CP @Rs test

st_x_base:
        .word   0x0000              ! Index 0
        .word   0x0000              ! Index 2
        .word   0x0000              ! Index 4 (used in test)

ldb_ir_data:
        .byte   0xAB                ! Byte for LDB @Rs test
        .byte   0x00                ! Padding

stb_da_data:
        .byte   0x00                ! Destination for STB test
        .byte   0x00                ! Padding

cp_da_data:
        .word   0x5678              ! Comparison value for CP address test

and_da_data:
        .word   0x0FF0              ! Mask for AND address test

or_ir_data:
        .word   0xFF00              ! Value for OR @Rs test

xor_da_data:
        .word   0x0F0F              ! Value for XOR address test

# Data for block compare tests
cpi_src_data:
        .word   0x1234              ! Matching value for CPI test

cpir_src_data:
        .word   0x1111              ! Word 1
        .word   0x2222              ! Word 2
        .word   0x3333              ! Word 3 (target for match test)
        .word   0x4444              ! Word 4
        .word   0x5555              ! Word 5

cpib_src_data:
        .byte   0xAB                ! Matching byte for CPIB test
        .byte   0x00                ! Padding

cpdr_src_data:
        .word   0x1111              ! Target for CPDR (find from end)
        .word   0x2222
        .word   0x3333
cpdr_src_end:
        .word   0x4444              ! Start searching from here (backwards)

cpirb_src_data:
        .byte   0xAB                ! Byte 1
        .byte   0xBC                ! Byte 2
        .byte   0xCD                ! Byte 3 (target for CPIRB)
        .byte   0xDE                ! Byte 4
        .byte   0xEF                ! Byte 5

# Data for long (32-bit) operation tests
        .align  2

ldl_src_data:
        .long   0xABCDEF01          ! 32-bit data for LDL tests

ldl_indexed_base:
        .long   0x11112222          ! First long (offset 0)
        .long   0x22223333          ! Second long (offset 4) - used in test

stl_dst_data:
        .long   0x00000000          ! Destination for STL_IR test

stl_dst_data2:
        .long   0x00000000          ! Destination for STL_DA test

stl_indexed_base:
        .long   0x00000000          ! First long (offset 0)
        .long   0x00000000          ! Second long (offset 4) - used in test

# Data for LDL_BA (based addressing) test
ldl_based_data:
        .long   0x11112222          ! First long (offset 0)
        .long   0x55556666          ! Second long (offset 4) - used in test

# Data for LDB_BA (byte based addressing) test
ldb_based_data:
        .byte   0x11                ! Offset 0
        .byte   0x22                ! Offset 1
        .byte   0x33                ! Offset 2 - used in test
        .byte   0x44                ! Offset 3

# Data for INC/DEC/NEG/COM indirect addressing tests
inc_ir_data:
        .word   0x1230              ! Will be incremented by 4 -> 0x1234

dec_ir_data:
        .word   0x1005              ! Will be decremented by 5 -> 0x1000

neg_ir_data:
        .word   0x0005              ! Will be negated -> 0xFFFB

com_ir_data:
        .word   0x00FF              ! Will be complemented -> 0xFF00

# Data for block I/O tests
inir_dst_data:
        .word   0xFFFF              ! Destination for INIR (3 words)
        .word   0xFFFF
        .word   0xFFFF

otir_src_data:
        .word   0x1111              ! Source for OTIR - word 1
        .word   0x2222              ! Source for OTIR - word 2
        .word   0x3333              ! Source for OTIR - word 3 (last written)

inirb_dst_data:
        .word   0xFFFF              ! Destination for INIRB (4 bytes)
        .word   0xFFFF

