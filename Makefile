C_SOURCES=$(wildcard kernel/*.c drivers/*.c)
HEADERS=$(wildcard kernel/*.h drivers/*.h)

# TODO: Make sources dep on all header files

# creates a list of object files to build
# it replaces the '.c' extension of filenames in C_SOURCES with '.o'
OBJ=${C_SOURCES:.c=.o}

# default target build
all: os-image

run: all
	bochs -f bochsrc -q

os-image : boot/boot_sect.bin kernel.elf
	cat $^ > $@

kernel.elf : kernel/kernel_entry.o ${OBJ}
	ld -Ttext 0x1000 -melf_i386 $^ -o $@

# Generic rule for compiling C code to an object file
# For simplicity, we C files depend on all header files
%.o : %.c ${HEADERS}
	gcc -m32 -ffreestanding -c $< -o $@

# Assemble kernel entry
%.o : %.asm
	nasm -f elf $< -o $@

# building our boot sector
%.bin : %.asm
	nasm -f bin $< -I '../../16bit/' -o $@

clean:
	rm -rf *.elf *.bin *.dis *.o os-image
	rm -rf kernel/*.o boot/*.bin drivers/*.o