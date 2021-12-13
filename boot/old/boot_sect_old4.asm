; our boot sector
; this is for testing our print string function
; I had written the code myself for printing the string

bits 16
[org 0x7c00]          ; the org directive means origin and it sets the data segment to 
                      ; offset from where our bootloader code is at

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
