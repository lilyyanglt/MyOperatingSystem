; our boot sector
; this code attempts to print hi lily using the BIOS 
; routine of accessing the display when BIOS printed something to the screen

bits 16
;[org 0x7c00]          ; the org directive means origin and it sets

mov ah, 0x0e            ; according to wikipedia, to use teletype mode
                        ; you set ah to 0x0e, and al to an ASCII code of the character
; First attempt
mov al, [the_secret]
int 0x10                ; Does this print an X? no this doesn't because by default it's offset from the 
                        ; top of the memory or bottom...anyways, it's somewhere at the beginner of memory.

; Third attempt
mov bx, 0x7c0           ; this works because the_secret is now offset from 0x07c0
mov ds, bx              ; this prints X because by default it's offset from data segment based on ds register value
mov al, [the_secret]
int 0x10                

mov al, [es:the_secret] ; tell the CPU to use the es (not ds) segment
int 0x10                ; this does not print X because es is not a data segment so you will print out garbage value

; Fourth attempt
mov bx, 0x7c0
mov es, bx
mov al, [es:the_secret]
int 0x10                ; Does this print an X? yes it does, because
                        ; we are saying that we want the_secret to offset from es
                        ; and es has been set to a segment we specify
                        ; although visually i still don't know how this works

jmp $                   ; jumps to current address

; this label represents us putting a byte of data in memory
the_secret:
  db "X"

times 510-($-$$) db 0

dw 0xaa55              

