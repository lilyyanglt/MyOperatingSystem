; routine for switching to protected mode
[bits 16]

switch_to_pm:

    cli                     ; call cli to halt interrupt

    lgdt [gdt_descriptor]   ; load our global descriptor table, which defines
                            ; the protected mode segments (e.g. for code and data)

    ; set cr0 first bit to be 1 
    ; which indicates that we are going into 32 bit mode

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; making a far jump to force CPU to flush its cache 
    ; of pre-fetched and real-mode decoded instructions, which can 
    ; cause problems
    jmp CODE_SEG:init_pm

[bits 32]

init_pm:

    ; now that we are in protected mode
    ; we are going to reset all our segment registers
    ; to the DATA_SEG location

    mov eax, DATA_SEG        ; QUESTION: why not using EAX? since we are in 32 bit mode?
    mov ds, eax              ; I tried changing this to eax as you can see now
    mov ss, eax              ; it works either way so it's okay
    mov es, eax
    mov fs, eax
    mov gs, eax

    ; update our stack position so it is right
    ; at the top of the free space

    mov ebp, 0x90000
    mov esp, ebp

    ; once that's all set up
    ; we can call our function to prove that we are 
    ; in 32 bit protected mode
    call BEGIN_PM