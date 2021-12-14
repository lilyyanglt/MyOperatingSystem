/**
* source: Nick Blundell's book
* 
* this is our kernel entry
* you will run 
* $ gcc -ffreestanding -c kernel.c -o kernel.o
* $ ld -o ../kernel.bin -Ttext 0x1000 kernel.o --oformat binary
* note that we are telling the linker that the origin of our 
* code once we load it into memory will
* be 0x1000
**/

#include <stdio.h>

void main() {
    char * video_memory = (char*) 0xb8000;

    *video_memory = 'X';
}