TARGET = riscv64-unknown-linux-gnu
CC = $(TARGET)-gcc
AS = $(TARGET)-as
LD = $(TARGET)-ld
OBJCOPY = $(TARGET)-objcopy
OBJDUMP = $(TARGET)-objdump
GDB = gdb-multiarch

QEMU_USR = qemu-riscv32
QEMU_SYS = qemu-system-riscv32

PROGRAM_ARGS = input/day$(DAY).txt

BIN = day$(DAY)/part$(PART).bin

.PHONY : list
list :
	@echo '              list  : show this list'
	@echo '              clean : remove all generated files'
	@echo 'DAY=01 PART=1 build : build the solution for day 01 part 1'
	@echo 'DAY=01 PART=1 run   : build & run the solution for day 01 part 1'
	@echo 'DAY=01 PART=1 debug : launch qemu waiting for gdb on port 1234'
	@echo 'DAY=01 PART=1 gdb   : attach gdb to waiting qemu process'

.PHONY : build
build : $(BIN)

.PHONY : run
run : $(BIN)
	$(QEMU_USR) $< $(PROGRAM_ARGS)

.PHONY : debug
debug : $(BIN)
	$(QEMU_USR) -g 1234 $<

.PHONY : gdb
gdb : $(BIN)
	$(GDB) -q -ex 'target remote :1234' $<

.PHONY : clean
clean :
	find . \( -name '*.o' -or -name '*.d' -or -name '*.elf' \
	           -or -name '*.so' -or -name '*.bin' -or -name '*.img' \
	       \) -delete

%.bin : %.S common.S
	$(CC) -march=rv32im -mabi=ilp32 -static -g -I include/ -o $@ $^
