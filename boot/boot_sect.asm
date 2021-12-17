; source: Nick Blundell's book
; boot sector that boots the C kernel in 32 bit protected mode

[bits 16]
[org 0x7c00]

; constant for the memory offset to which we will load our kernel
KERNEL_OFFSET equ 0x1000

; BIOS stores our boot drive (recall in our _old8.asm file)
; in dl, so let's remember this for later
mov [BOOT_DRIVE], dl

; set up our stack
mov bp, 0x9000
mov sp, bp

; this announces that we are starting to boot from 
; 16-bit real mode
mov bx, MSG_REAL_MODE
call print_string

; load our kernel
call load_kernel

; note that there's not going to be return to this function
call switch_to_pm   

; since we won't be returning back from the 
; previous function, do we need this line of code?
jmp $

%include "./boot/printing_string.asm"
%include "./boot/printing_string_pm.asm"
%include "./boot/gdt.asm"
%include "./boot/switch_to_pm.asm"
%include "./boot/disk_load.asm"

[bits 16]

load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string

    ; set-up parameters for our disk_load routine
    ; recall we set the dh to say that we want to load the 
    ; first 15 sectors (exluding the boot sector because in our
    ; routine, we set cl to say 2 so we are reading starting from
    ; boot sector 2) from the boot disk to address KERNEL_OFFSET
    
    mov bx, KERNEL_OFFSET
    mov dh, 15
    mov dl, [BOOT_DRIVE]
    call disk_load           

    ret

[bits 32]

; switching to protected mode
BEGIN_PM:

    ; this part just announces we are in 
    ; 32 bit mode (pm mode)
    mov ebx, MSG_PROT_MODE
    call print_string_pm

    ; Now jump to the address of where our kernel is loaded
    call KERNEL_OFFSET

    jmp $

; ##################################
; Global variables
; ##################################

MSG_REAL_MODE:
    db "Started in 16-bit Real Mode", 0

MSG_PROT_MODE: 
    db "Successfully landed in 32-bit Protected Mode", 0

BOOT_DRIVE:
    db 0

MSG_LOAD_KERNEL:
    db "Loading kernel into memory", 0

; first boot sector padding
times 510-($-$$) db 0
dw 0xaa55 