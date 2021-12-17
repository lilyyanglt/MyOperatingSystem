# Building a simple operating system

Personal project trying to build an operating system from the ground by following the [Nick Blundell's book](https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf) and also using resources from the Princeton course COS318. Although he hasn't completed the book, but it's a great resource to learn more about the system.

My goal is to learn enough from this book and then start building on top of it with other features.

# install Instructions and System Requirements

* development of this should be done inside a Virtual Machine, highly recommended.
* TODO: provide Vagrant file with provisioning instructions
* Development of this was done in a virtual machine using Ubuntu 20.04

1. In the root directory of this repo, run `make` - this builds all the necessary files for simulation to start
2. Then start simulation using bochs `make run`
3. Once completed, you can run `make clean` to clean up all the files

# Problems Encountered During Development and Troubleshooting Steps

## Problem 1

After combining kernel.bin and boot_sect.bin into an os-image binary, bochs cannot find a disk to boot with error *no bootable device*

See log error file: ./logs/bochsout-121521.txt

### Steps taken to troubleshoot:

1. Check the resulting os-image binary using `od -t x1 -A n os-image`

My first check was to make sure the binary file consists of the magic number of 0xaa55 in the last 2 bytes of the first sector because that's how the BIOS finds the boot loader from a drive. I do see it so I am not sure what's wrong. 

2. I then created a small assembly file and compile it into a binary file to make sure when I did `cat boot_sect.bin boot_sect2.bin > os-image` it didn't corrupt the file

The code inside boot_sect2.asm is as follows taking the tutorial from boot_sect_old8.asm where we added some additional 512 bytes to the end of the file, so I just created a separate file and included the following, and ran `nasm boot_sect2.asm -f bin -o boot_sect2.bin`

```
; this just simply creates 256 bytes of 0xdada which comes to a total of 512 bytes
times 256 dw 0xdada
```

When I did this, bochs booted os-image with no problems, so then that means the cat command didn't corrupt the file

3. I then read the [dev blog link](https://dev.to/nsadisha/build-your-own-operating-system-1setupbooting-2im3) to perhaps try creating an iso image from the binary file and using the bochsrc config then maybe I could see what's wrong. 

So I tried to learn how to create an iso image from a binary file, and found this from [stackoverflow](https://stackoverflow.com/questions/34268518/creating-a-bootable-iso-image-with-custom-bootloader)


so I followed it and created myos.iso image file, and then using the following bochsrc file and installed bochs-sdl: 

```
    megs:            32
    display_library: sdl2
    romimage:        file=/usr/share/bochs/BIOS-bochs-latest
    vgaromimage:     file=/usr/share/bochs/VGABIOS-lgpl-latest
    ata0-master:     type=cdrom, path=myos.iso, status=inserted
    boot:            cdrom
    log:             bochslog.txt
    clock:           sync=realtime, time0=local
    cpu:             count=1, ips=1000000

```

I first converted the simple boot_sect.bin to iso to test this process out, but then when I tried to do the same for os-image to convert it into iso file, I realized the size is huge - over 4MB! So the commands I did was:

```
# I think this is creating a floppy image that's of size (1024 * 5760 ~ 5MB)
dd if=/dev/zero of=floppy.img bs=1024 count=5760

# so this part I believe based on the explanation that I am copying the boot_sect.bin code to the first sector of the floppy.img
dd if=boot_sect.bin of=floppy.img seek=0 count=1 conv=notrunc

# so I then tried to copy the kernel.bin to the floppy disk
# so because the first sector is already with the boot_sect.bin, I copy the kernel
# starting sector 1 and because kernel is about 4MB = 4,000,000 / 512 is about 8184 sectors
dd if=kernel.bin of=floppy.img seek=1 count=8184 conv=notrunc

# then when I ran the genisoimage command
genisoimage -quiet -V 'MYOS' -input-charset iso8859-1 -o myos.iso -b floppy.img -hide floppy.img iso/

```

However, I got an error but I don't remember what the error said, but it had something to do with the fact that the floppy.img disk is not correct
Then I went online to check if there's a max size for a floppy disk, and I found that floppy disks can only be 1.44MB or 2.88MB, so essentially I can't copy that many bytes into the floppy disk image. However I didn't get an error from the `dd` commands so it must be me trying to create the iso from floppy is not correct. 

4. Then I looked into why was it that a simple .c file to produce the kernel.bin was so huge of 4MB

kernel.c file
```c

void main() {
    char * video_memory = (char*)0xb8000;
    *video_memory = 'X'
}
```
Then this file was compiled into an .o file usingn this command:

`gcc -ffreestanding -s -c kernel.c -o kernel.o` - which produced a kernel.o file of 1376 bytes

Then using this command to produce a .bin file for the kernel

`ld -o kernel.bin -Ttext 0x1000 kernel.o --oformat binary`

This is where the kernel.bin shows me it's 4MB in size...I don't quite understand what exactly linker does that made my binary file so huge **TBD**
Also, when I tried to disassemble the resulting kernel.bin using this command `ndisasm -b 64 kernel.bin > kernel.dis`

I got something really weird in the dis file:

```
00000000  F30F1EFA          rep hint_nop55 edx
00000004  55                push rbp
00000005  4889E5            mov rbp,rsp
00000008  48C745F800800B00  mov qword [rbp-0x8],0xb8000
00000010  488B45F8          mov rax,[rbp-0x8]
00000014  C60058            mov byte [rax],0x58
00000017  90                nop
00000018  5D                pop rbp
00000019  C3                ret
0000001A  0000              add [rax],al
0000001C  0000              add [rax],al
0000001E  0000              add [rax],al
00000020  0000              add [rax],al
00000022  0000              add [rax],al
00000024  0000              add [rax],al
00000026  0000              add [rax],al
... 
continue down to about line 209511 with add [rax],al line...

```
if I had used `ndisasm -b 32 kernel.bin > kernel.dis`, then the file would have this, and have exactly the same number of lines, which makes sense because this is using 32 bit registers and the previous uses 64 bit registers, but what's happening after `ret`? *Why is it resuling in so many add lines*:

```
00000000  F30F1EFA          rep hint_nop55 edx
00000004  55                push ebp
00000005  48                dec eax
00000006  89E5              mov ebp,esp
00000008  48                dec eax
00000009  C745F800800B00    mov dword [ebp-0x8],0xb8000
00000010  48                dec eax
00000011  8B45F8            mov eax,[ebp-0x8]
00000014  C60058            mov byte [eax],0x58
00000017  90                nop
00000018  5D                pop ebp
00000019  C3                ret
0000001A  0000              add [eax],al
0000001C  0000              add [eax],al
0000001E  0000              add [eax],al
00000020  0000              add [eax],al
00000022  0000              add [eax],al
00000024  0000              add [eax],al
00000026  0000              add [eax],al
00000028  0000              add [eax],al
0000002A  0000              add [eax],al
0000002C  0000              add [eax],al
0000002E  0000              add [eax],al
...
```

### Next steps

I don't want to spend any more time on this for now because my focus is to learn operating system concepts, but based on the troubleshooting so far, I need to better understand the following:

* How to create an image using genisoimage without using floppy disk? 
* Why was it that linker is doing that when I disassemble the resulting kernel.bin had a lot of `add` instructions which resulted in that heavy size file. 
* Learn more about gcc compiler and the linker as well as different architectures

### Temporary Solution (Dec 16, 2021)
* After some new discovery, I came across the .elf format that I can use the linker to create instead of creating a binary format. Up to this point, I still don't quite understand why binary format using the linker produced a 4MB file, but because I was able to combine the boot sector code with an elf format file to produce an os-image, the total size was only 13k bytes which is suitable to using a floppy disk. Here are my manual steps that I'll need to automate using a Makefile, but it works! Praise God!

1. Compile my c progams into elf32 format. 
`gcc -m32 -ffreestanding -c kernel.c -o kernel.o`

2. Compile the assembly code into elf32 format as well that we want to link together with the kernel code into one file 
`nasm -f elf kernel_entry.asm -o kernel_entry.o`

3. link the 2 output files and product an elf format instead of a binary

`ld -Ttext 0x1000 -melf_i386 kernel_entry.o kernel.o -o kernel.elf`

4. then combine our bootloader and kernel.elf together into an os-image

`cat boot_sect.bin kernel.elf > os-image`

You will notice that this os-image is very small in size. You can also do the same thing without the entry file to test things out first which I have done. 