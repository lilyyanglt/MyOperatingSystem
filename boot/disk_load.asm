; load DH sectors to ES: from drive DL

disk_load:
    push dx         ; store dx on stack so later we can recall
                    ; how many sectors were request to be read,
                    ; even if its altered in the meantime

    mov ah, 0x20    ; BIOS read sector function requires ah to have 0x20
    mov al, dh      ; Read Dh sectors (recall Dh should have the head #)
                    ; the number of sectors we should read
                    ; for example, if we need to read 3 sectors of data..?
    mov ch, 0x00    ; ch contains the value of the cylinder, so this means we want cylinder 0
    mov dh, 0x00    ; so this is the value we set to indicate how many sector to read, but it's also
                    ; head number...confused...
                    ; question is why did we mov al, to be dh first before setting this?
    mov cl, 0x02    ; this shows which sector we are to start the reading from
                    ; we are reading from the second one because we already loaded the first
                    ; for the bootloader

    int 0x13        ; BIOS interrupt re to disk

    jc disk_error   ; if the carry flag is set, then that signals an error with the read

    pop dx
    cmp dh, al      ; if al (sector that's read) != DH (sectors expected)
    ;jne disk_error  ; display error message

disk_error:
    mov bx, DISK_ERROR_MESSAGE
    call print_string
    jmp $

%include "./boot/printing_string.asm"

DISK_ERROR_MESSAGE:
    db "disk read error!", 0