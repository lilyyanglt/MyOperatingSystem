; GDT
; flags of the descriptors are more conveniently defined using literal
; binary numbers that are suffixed with b

gdt_start:

; ##########################################
; this is the mandatory gdt null descriptor
; dd means define double world (so double 
; word means 4 bytes)
; ##########################################

gdt_null:
    dd 0x0
    dd 0x0

; #########################################
; this is the code segment descriptor
; base = 0x0
; limit = 0xfffff (so in the code, we put the first 16 bits in the first line)
;         the rest of the 4 bits is inside the byte with the 2nd flags
; 1st flags: (present) 1 (privilege) 00 (descriptor type) 1             => 1001b
; type flags: (code) 1 (conforming) 0 (readable) 1 (accessed) 0         => 1010b
; 2nd flags: (gruanularity) 1 (32-bit default) 1 (64-bit seg) 0 (AVL)0  => 1100b
; #########################################

gdt_code: 
    dw 0xffff       ; Limit (bits 0 - 15)
    dw 0x0          ; Base (bits 0 - 15)
    db 0x0          ; Base (bits 16 - 23)
    db 10011010b    ; 1st flags, type flags
    db 11001111b    ; 2nd flags, Limit (bits 16 - 19)
    db 0x0          ; Base (bits 24 - 31)

; #########################################
; this is the data segment descriptor
; almost all the same except for the type flags
; type flags: (code) 0 (expand down) 0 (writable)1 (accessed)0 => 0010b
;
; #########################################

gdt_data:
    dw 0xffff       ; Limit (bits 0 - 15)
    dw 0x0          ; Base (bits 0 - 15)
    db 0x0          ; Base (bits 16 - 23)
    db 10010010b    ; 1st flags, type flags
    db 11001111b    ; 2nd flags, Limit (bits 16 - 19)
    db 0x0          ; Base (bits 24 - 31)

; ##########################################
; we need this label of gdt_end is so that
; the size of the GDT descriptor below can be calculated
; by the assembler
; ##########################################

gdt_end:

; ##########################################
; GDT descriptor
; ##########################################
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; size of our gdt, always one less than true size (2 bytes - 16 bits)
    dd gdt_start                ; start address of our gdt (4 bytes - 32 bits)


; ###########################################
; Defining some handy constants for the gdt segment
; descriptor offsets, which are what segment registers
; must contain when in protected mode. For example,
; when we set DS = 0x10 in PM, the CPU knows that
; we mean it to use the segment described at offset 0x10
; (ie. 16 bytes) in our GDT, which in our case is the data
; segment (0x0 -> NULL; 0x08 -> CODE; 0X10 -> DATA)
CODE_SEG equ gdt_code - gdt_start 
DATA_SEG equ gdt_data - gdt_start 