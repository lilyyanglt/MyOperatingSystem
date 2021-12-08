; our boot sector
; this code attempts to print hi lily using the BIOS 
; routine of accessing the display when BIOS printed something to the screen

bits 16
[org 0x7c00]          ; the org directive means origin and it sets

mov bx, HELLO_MESSAGE
call print_string

mov bx, GOODBYE_MESSAGE
call print_string

jmp $                   ; jumps to current address

%include "./boot/printing_string.asm"

; DATA
HELLO_MESSAGE:
    db "Hello world", 0

GOODBYE_MESSAGE:
    db "Goodbye", 0

times 510-($-$$) db 0

dw 0xaa55               ; the magic number is actually 0x55aa
                        ; except in the x86 architecture, it uses 
