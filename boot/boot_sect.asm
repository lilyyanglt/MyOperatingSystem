; source: Nick Blundell's book
; The following code demonstrates how to read some sectors
; from the boot disk using our disk_load.asm file

[org 0x7c00]

mov [BOOT_DRIVE], dl    ; BIOS stores our boot drive in DL, so it's best to remember this for later
                        ; so we remember it by putting the value inside the byte we reserved under
                        ; the BOOT_DRIVE label

mov bp, 0x8000          ; setting up our stack out of the way
mov sp, bp

mov bx, 0x9000          ; load 5 sectors to 0x0000(es):0x9000(bx) (so recall that the physical address is going to be 0x00000 + 0x9000 becomes)
                        ; 0x09000 which is where our es segment is started for the disk sectors to be loaded
                        ; if you don't include this, you won't be able to find where the disk sectors are loaded into
mov dh, 5               ; that the cpu calculates the absolute physical
mov dl, [BOOT_DRIVE]    ; address is 0x0000 * 16 + 0x9000 (which means 0x9000)
call disk_load          

mov dx, [0x9000 + 512]  ; also, print the first word from the 2nd loaded 
call print_hex          ; sector; should be 0xface

mov dx, [0x9000]        ; should be the second sector that's loaded 
call print_hex          ; which should have the value of 0xdada

jmp $

%include "./boot/disk_load.asm"
%include "./boot/printing_hex.asm"

; global variables
BOOT_DRIVE: db 0

; first boot sector padding
times 510-($-$$) db 0
dw 0xaa55 

; code for the second sector and third sector
times 256 dw 0xdada     ; filling up the second sector with 256 words (16 bite) with 0xdada
times 256 dw 0xface     ; filling up the third sector with 256 words with 0xface

