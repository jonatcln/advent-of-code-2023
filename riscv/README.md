# RISC-V

Currently assumes the rv32im architecture.

## Requirements

The required tools are listed at the top of the [Makefile](Makefile).

- To build, it requires a compiler toolchain (including binutils) that can
  cross-compile to rv32im. The toolchain should come with standard system
  startup files and libraries (for riscv32).
- To run, it requires the QEMU User Emulator for riscv32 (qemu-riscv32).
- To debug, either a gdb version included with the cross-compilation toolchain,
  or a multiarch build of gdb with riscv32 support is required.

## Building, running, debugging

Run `make list` to see the available build, run, and debug commands.
