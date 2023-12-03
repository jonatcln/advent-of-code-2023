#include "stdio.h"

        .section .rodata

msg_err_missing_filename_arg:
        .string "Error: missing filename argument\n"
fopen_mode_r:
        .string "r"
msg_open_failed:
        .string "Opening input failed\n"
msg_read_failed:
        .string "Reading input failed\n"


        .text

################################################################################
# char *setup(int argc, char **argv)
#
# Processes the arguments, reads the input file in a content buffer, and returns
# the address of this buffer.
# On failure, NULL is returned.
################################################################################
        .globl  setup
        .type   setup, @function
setup:
        addi    sp, sp, -16
        sw      ra, 12(sp)

        ## if (argc < 2) {
        sltiu   t0, a0, 2
        beqz    t0, 1f
        ##   fprintf(stderr, msg_err_missing_filename_arg)
        lw      a0, stderr
        la      a1, msg_err_missing_filename_arg
        call    fprintf
        ##   return NULL
        li      a0, 0
        j       setup.return
        ## }
1:
        ## content_buffer = read_input(argv[1])
        lw      a0, 4(a1)
        call    read_input
        ## return content_buffer
setup.return:
        lw      ra, 12(sp)
        addi    sp, sp, 16
        ret


################################################################################
# char *read_input(char *filename)
#
# Read the input file in a content buffer and append a NULL byte.
#
# On success, the address of the malloc'ed content buffer is returned.
# On error, an error message is printed to stderr and NULL is returned.
################################################################################
        .type   read_input, @function
read_input:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s2, 8(sp)
        sw      s1, 4(sp)
        sw      s0, 0(sp)

        ## fp = fopen(filename, "r")
        # a0 is already correct
        la      a1, fopen_mode_r
        call    fopen
        ## if (fp == NULL) { goto open_failed }
        beqz    a0, read_input.open_failed
        mv      s0, a0  # s0 := fp

        ## fseek(fp, 0, SEEK_END)
        # a0 is already correct
        li      a1, 0
        li      a2, SEEK_END
        call    fseek

        ## fsize = ftell(fp)
        mv      a0, s0
        call    ftell
        addi    s1, a0, 1  # s1 := fsize + 1

        ## fseek(fp, 0, SEEK_SET)
        mv      a0, s0
        li      a1, 0
        li      a2, SEEK_SET
        call    fseek

        ## content_buf = malloc(fsize + 1)
        mv      a0, s1
        call    malloc
        mv      s2, a0  # s2 := content_buf

        ## fread(content_buf, 1, fsize, fp)
        # a0 is already correct
        li      a1, 1
        addi    a2, s1, -1
        mv      a3, s0
        call    fread

        ## fclose(fp)
        mv      a0, s0
        call    fclose

        ## content_buf[fsize] = '\0'
        add     t0, s2, s1
        sb      zero, -1(t0)

        ## return content_buf
        mv      a0, s2
        j       read_input.return

read_input.open_failed:
        ## fprintf(stderr, msg_open_failed)
        lw      a0, stderr
        la      a1, msg_open_failed
        call    fprintf

        ## return NULL
        li      a0, 0
        j       read_input.return

read_input.read_failed:
        ## fprintf(stderr, msg_read_failed)
        lw      a0, stderr
        la      a1, msg_read_failed
        call    fprintf

        ## return NULL
        li      a0, 0

read_input.return:
        lw      s0, 0(sp)
        lw      s1, 4(sp)
        lw      s2, 8(sp)
        lw      ra, 12(sp)
        addi    sp, sp, 16
        ret
