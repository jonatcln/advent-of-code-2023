# Solver for AoC 2023 day 1 part 2

        .section .rodata

msg_result:
        .string "Solution: %d\n"

digit_1: .string "one"
digit_2: .string "two"
digit_3: .string "three"
digit_4: .string "four"
digit_5: .string "five"
digit_6: .string "six"
digit_7: .string "seven"
digit_8: .string "eight"
digit_9: .string "nine"

digits: # struct { char* digit_addr; int* digit_len; }
        .word   digit_1, 3
        .word   digit_2, 3
        .word   digit_3, 5
        .word   digit_4, 4
        .word   digit_5, 4
        .word   digit_6, 3
        .word   digit_7, 5
        .word   digit_8, 5
        .word   digit_9, 4


        .text

################################################################################
# int main(int argc, char **argv)
################################################################################
        .globl  main
        .type   main, @function
main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s2, 8(sp)
        sw      s1, 4(sp)
        sw      s0, 0(sp)

        ## content_buffer = setup(argc, argv)
        call    setup
        ## if (content_buffer == NULL) goto failed
        beqz    a0, main.failed

        mv      s0, a0  # s0 := content_buffer

        ## char *current = &content_buffer[0]
        mv      s1, s0  # s1 := current

        ## int sum = 0
        li      s2, 0  # s2 := sum

main.seek_digit_left:
        ## d = parse_digit(current++)
        mv      a0, s1
        addi    s1, s1, 1
        call    parse_digit  # a0 := d
        ## if (d < 0) goto seek_digit_left
        bltz    a0, main.seek_digit_left
        # Leftmost digit found
        ## sum += d * 10
        li      t0, 10
        mul     t0, a0, t0
        add     s2, s2, t0

        # Seek newline or NULL
        li t1, '\n'
1:      ## while (true) {
        ##   c = *current++
        lbu     t0, 0(s1)  # t0 := c
        addi    s1, s1, 1
        ##   if (c == '\0' || c == '\n') break
        beqz    t0, main.seek_digit_right
        bne     t0, t1, 1b
        ## }
        ## --current
2:      addi    s1, s1, -1
main.seek_digit_right:
        ## d = parse_digit(--current)
        addi    s1, s1, -1
        mv      a0, s1
        call    parse_digit  # a0 := d
        ## if (d < 0) goto seek_digit_right
        bltz    a0, main.seek_digit_right
        # Found rightmost digit
        ## sum += d
        add     s2, s2, a0

        # Seek newline or NULL
        li      t1, '\n'
1:      ## while(true) {
        ##   c = *(++current)
        add     s1, s1, 1
        lbu     t0, 0(s1)  # t0 := c
        ##   if (c == '\0') goto done
        beqz    t0, main.done
        ##   if (c == '\n') break
        bne     t0, t1, 1b
        ## }

        # Continue with next line
        ## if (*(++current) != '\0') goto seek_digit_left
        add     s1, s1, 1
        lbu     t0, 0(s1)
        bnez    t0, main.seek_digit_left

main.done:
        ## printf(msg_result, sum)
        la      a0, msg_result
        mv      a1, s2
        call    printf

        ## free(content_buffer)
        mv      a0, s0
        call    free

        ## return 0
        li      a0, 0
        j       main.return

main.failed:
        # No need to free content_buffer since it wasn't allocated

        ## return -1
        li      a0, -1

main.return:
        lw      s0, 0(sp)
        lw      s1, 4(sp)
        lw      s2, 8(sp)
        lw      ra, 12(sp)
        addi    sp, sp, 16
        ret


################################################################################
# int parse_digit(char *p)
#
# Performs the following in order:
#   1. If *p is an ASCII decimal digit, returns the corresponding integer value.
#   2. If *p, *(p+1), *(p+2), ... is a spelled-out decimal digit (e.g. "two"),
#      then return the corresponding integer value.
#
# Returns -1 if the character is not a decimal digit.
################################################################################
        .type   parse_digit, @function
parse_digit:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s2, 8(sp)
        sw      s1, 4(sp)
        sw      s0, 0(sp)

        # Check if it's a single decimal digit
        ## if (*p - '0' < 10u) { return *p - '0' }
        lbu     t0, 0(a0)
        addi    t0, t0, -'0'
        sltiu   t1, t0, 10
        beqz    t1, 1f
        mv      a0, t0
        j       parse_digit.return

1:      # Check it it's a spelled-out digit

        mv      s0, a0      # s0 := p
        la      s1, digits  # s1 := struct{char*; int;}* d = digits
        li      s2, 1       # s2 := int i = 1

parse_digit.loop:
        ## while (true) {
        ##   if (strcmp(p, *d.digit_addr, d.digit_len) == 0) goto found
        mv      a0, s0
        lw      a1, 0(s1)
        lw      a2, 4(s1)
        call    strncmp
        beqz    a0, parse_digit.found

        ##   d++
        addi    s1, s1, 8
        ##   i++
        addi    s2, s2, 1
        ##   if (i >= 10) break
        slti    t0, s2, 10
        bnez    t0, parse_digit.loop
        ## }

        ## return -1
        li      a0, -1
        j       parse_digit.return

parse_digit.found:
        ## return i
        mv      a0, s2

parse_digit.return:
        lw      s0, 0(sp)
        lw      s2, 8(sp)
        lw      s1, 4(sp)
        lw      ra, 12(sp)
        addi    sp, sp, 16
        ret
