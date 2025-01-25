[bits 32]

global _start
extern main

section .text
_start:
    jmp 0x0000:start

start:
    ; Настройка сегментных регистров
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Настройка стека
    mov ss, ax
    mov sp, 0x7c00

    mov al, 'B'
    mov ah, 0x0f
    mov [0xb8002], ax

    ; Переход к основному циклу в С
    call main

    jmp $
