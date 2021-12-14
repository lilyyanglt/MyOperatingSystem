; entry to kernel
; to ensure we jump straight into the kernel's entry function 
; instead of to the first instruction of the kernel code
; which could be anything other than main sometimes
; we need the metadata for this file in the object file instead
; of a raw binary file

[bits 32]

; this directive will delcare that we will be referencing
; the external symbol 'main'
; so the linkker can substitute the final address
[extern main]

call main
jmp $