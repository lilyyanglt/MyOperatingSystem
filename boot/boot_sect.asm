; source: Nick Blundell's book
; putting everything we learn together
; we are going to switch to 32 bit mode
; also we will use the video memory to print
; some character onto the screen
; so this is a boot sector that will enter 32-bit 
; protected mode

[bits 16]
[org 0x7c00]

; set up our stack
mov bp, 0x9000
mov sp, bp

mov bx, MSG_REAL_MODE
call print_string

call switch_to_pm   ; note that there's not going to be return to this function

jmp $

%include "./boot/printing_string.asm"
%include "./boot/printing_string_pm.asm"
%include "./boot/gdt.asm"
%include "./boot/switch_to_pm.asm"

[bits 32]

BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm

    jmp $

; Global variables
MSG_REAL_MODE:
    db "Started in 16-bit Real Mode", 0

MSG_PROT_MODE: 
    db "Successfully landed in 32-bit Protected Mode", 0

; first boot sector padding
times 510-($-$$) db 0
dw 0xaa55 