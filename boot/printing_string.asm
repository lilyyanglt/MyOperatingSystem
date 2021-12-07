; our print string function

print_string:
    pusha
    
    mov ah, 0x0e
    
    jmp check_cx
    
    check_cx:
    mov cx, [bx]
    cmp cx, 0
    jne print_char

    popa
    ret

    print_char:
         ; need to figure out

        mov al, cl 
        int 0x10
        add bx, 1
        jmp check_cx

