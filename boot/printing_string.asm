; our print string function

print_string:
    pusha
    
    mov ah, 0x0e        ; setting the a register first byte to be 0e
    mov dh, 0x0         ; setting the register first byte to be 00
    
    jmp check_cx
    
    check_cx:
    mov dl, [bx]        ; copy the value at address bx into the last 8 bits of dx register
    cmp dl, 0           ; compare only the dl because each character is only 8 bits (1 byte)
    jne print_char      ; because we ended our string bytes with a 0 byte to indicate end of string
                        ; if dl is not a zero byte, then jump to print out the character
                        ; essentially this loop will end until dl is 0, if we don't get there
                        ; it will continue to jump to print_char routing

    popa
    ret

    print_char:

        mov al, dl      ; this is part of the required step to print the character
        int 0x10
        add bx, 1       ; increment the bx value by 1 so we can move to the next character
        jmp check_cx    

