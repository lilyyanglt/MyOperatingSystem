; our boot sector
; this code attempts to print hi lily using the BIOS 
; routine of accessing the display when BIOS printed something to the screen

bits 16
; [org 0x7c00]          ; the org directive means origin and it sets
                        ; the location counter to the value specified

mov ah, 0x0e            ; according to wikipedia, to use teletype mode
                        ; you set ah to 0x0e, and al to an ASCII code of the character
; First attempt
; mov al, the_secret
; int 0x10                ; Does this print an X?

; Second attempt
mov al, [the_secret]
int 0x10                ; Does this print an X? - this will only if we added [org 0x7c00]
                        ; at the top of the file because the offset is now starting at 7c00
                        ; so you don't need to do any math to get to the location of where
                        ; 'X' is located

; Third attempt
mov bx, the_secret      ; this works if we didn't have [org 0x7c00] at the top of the file
add bx, 0x7c00           
mov al, [bx]
int 0x10                

; Fourth attempt
mov al, [0x7c19]
int 0x10                ; Does this print an X?

jmp $                   ; jumps to current address

; this label represents us putting a byte of data in memory
the_secret:
  db "X"



times 510-($-$$) db 0

dw 0xaa55               ; the magic number is actually 0x55aa
                        ; except in the x86 architecture, it uses 
