; source: Nick Blundell's book
; testing out the printing string function using pm
; but this doesn't work yet because of the fact that
; we haven't switched to 32 bit protected mode yet


[org 0x7c00]

mov bx, HELLO_MESSAGE
call print_string_pm

jmp $

%include "./boot/printing_string_pm.asm"

; global variables
HELLO_MESSAGE: 
    db "hello my friend", 0

; first boot sector padding
times 510-($-$$) db 0
dw 0xaa55 