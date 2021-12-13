; our boot sector
; this code attempts to print hi lily using the BIOS 
; routine of accessing the display when BIOS printed something to the screen

bits 16

mov ah, 0x0e            ; according to wikipedia, to use teletype mode
                        ; you set ah to 0x0e, and al to an ASCII code of the character
mov al, 'H'
int 0x10
mov al, 'i'
int 0x10
mov al, 'l'
int 0x10
mov al, 'i'
int 0x10
mov al, 'l'
int 0x10
mov al, 'y'
int 0x10

jmp $                  ; jumps to current address

times 510-($-$$) db 0

dw 0xaa55
