; our boot sector
; this code attempts to print hi lily using the BIOS 
; routine of accessing the display when BIOS printed something to the screen

bits 16
; [org 0x7c00]          ; the org directive means origin and it sets
                        ; the location counter to the value specified
mov ah, 0x0e            ; if you don't do this, ax stores 0xaa55 

mov bp, 0x8000          ; Set the base of the stack a little above where BIOS
mov sp, bp              ; loads our boot sector - so it won’t overwrite us.

push "A"                ; Push some characters on the stack for later
push "B"                ; retreival. Note , these are pushed on as
push "C"                ; 16-bit values , so the most significant byte
                        ; will be added by our assembler as 0x00.

pop bx                  ; Note , we can only pop 16-bits , so pop to bx
mov al, bl              ; then copy bl (i.e. 8-bit char) to al
int 0x10                ; print(al)

pop bx                  ; Pop the next value
mov al, bl
int 0x10                ; print(al)

mov al, [0x7ffe]        ; To prove our stack grows downwards from bp ,
                        ; fetch the char at 0x8000 - 0x2 (i.e. 16-bits)
int 0x10                ; print(al)


jmp $                   ; jumps to current address


times 510-($-$$) db 0

dw 0xaa55               ; the magic number is actually 0x55aa
                        ; except in the x86 architecture, it uses 
