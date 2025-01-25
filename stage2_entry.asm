[bits 32]

global _start
extern main

_start:
    mov al, 'X'
    mov ah, 0x0f
    mov [0xb8002], ax

    ; Переход к основному циклу в С
    call main

    jmp $
