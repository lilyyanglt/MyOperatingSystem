kernel.o : kernel.c
	gcc -ffreestanding -c ./kernel/kernel.c -o kernel.o