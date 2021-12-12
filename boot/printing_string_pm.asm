; this is a print string routine in the protected mode (pm)
; the downside to this routine is that it always prints
; the string to the top left of the screen and with each
; character write, will replace the previous one, but
; for now, it achieves our purpose of replacing the BIOS routine


bits 32

; define constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

; prints a null-terminated string pointed to by EDx
print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY       ; Set EDX (note it's not EBX) to the start of vid memory

print_string_pm_loop:
    mov al, [ebx]               ; store the character at EBX in AL - recall that
                                ; our code using BIOS routine, bx holds the address
                                ; of where our character string starts, so
                                ; using ebx here as if we've switched to 32 bit mode
    mov ah, WHITE_ON_BLACK      ; store the attributes of our character

    cmp al, 0                   ; al will be 0 at the end of the string
    je print_string_pm_done 

    mov [edx], ax               ; put the value we set up with 1 byte of character and 1 
                                ; byte attribute into the slot for the video memory

    add ebx, 1                  ; increment ebx so we can read the next character stored there
    add edx, 2                  ; increment video memory address to 2 spots down because each 
                                ; character requiers 1 byte of char and 1 byte of attribute

    jmp print_string_pm_loop

print_string_pm_done:
    popa
    ret