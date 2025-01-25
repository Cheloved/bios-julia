[bits 32]

global _start
extern main

_start:
    ; Настройка стека
    mov esp, 0x7c00

    mov al, 'X'
    mov ah, 0x0f
    mov [0xb8002], ax

    ; Переход к основному циклу в С
    call main

    jmp $
