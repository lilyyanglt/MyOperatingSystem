; load DH sectors to ES: from drive DL
; in summary:
; to load disk into memory, we need to set the following values:
; ah = 0x02
; dh = head 0 (either 0 or 1)
; al = number of sectors to read
; ch = cylinder number
; cl = the sector # to start reading from
; then call 0x13 interrupt

disk_load:
    push dx         ; store dx on stack so later we can recall
                    ; how many sectors were request to be read,
                    ; even if its altered in the meantime

    mov ah, 0x02    ; BIOS read sector function requires ah to have 0x20
    mov al, dh      ; Read DH sectors - recall earlier we've set the value of dh to 5 meaning we want to read 5 sectors
                    
    mov ch, 0x00    ; ch contains the value of the cylinder, so this means we want cylinder 0
    mov dh, 0x00    ; now we have to set dh to either 0 (read) or 1 (write)
    mov cl, 0x02    ; this shows which sector we are to start the reading from
                    ; we are reading from the second one because we already loaded the first
                    ; for the bootloader

    int 0x13        ; BIOS interrupt re to disk

    jc disk_error   ; if the carry flag is set, then that signals an error with the read

    pop dx
    cmp dh, al      ; if al (sector that's read) != DH (sectors expected)
    jne disk_error  ; display error message
    ret

disk_error:
    mov bx, DISK_ERROR_MESSAGE
    call print_string
    jmp $

DISK_ERROR_MESSAGE:
    db "disk read error!", 0