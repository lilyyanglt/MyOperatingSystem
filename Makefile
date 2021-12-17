os-image : boot_sect.bin kernel.elf
	cat boot_sect.bin kernel.elf > os-image

kernel.elf : kernel_entry.o kernel.o
	ld -Ttext 0x1000 -melf_i386 kernel_entry.o kernel.o -o kernel.elf

kernel.o : kernel.c
	gcc -m32 -ffreestanding -c ./kernel/kernel.c -o kernel.o

kernel_entry.o : kernel_entry.asm
	nasm -f elf ./kernel/kernel_entry.asm -o kernel_entry.o

boot_sect.bin : boot_sect.asm
	nasm -f bin ./boot/boot_sect.asm -o boot_sect.bin

clean:
	rm *.bin *.o