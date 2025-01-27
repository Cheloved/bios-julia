[bits 32]

global _start
extern main

_start:
    ; Настройка стека
    mov esp, 0x7c00

    ; Проверка адреса фреймбуфера
    mov edi, [framebuffer]

    ; Установка цвета
    mov eax, 0x00ff0000
    mov [edi], eax

    ; Расчет общего кол-ва пикселей
    movzx ecx, word [screen_width]
    movzx ebx, word [screen_height]
    imul ecx, ebx

    ; Заливка фреймбуфера
    cld
    rep stosd

    ; Переход в С
    call main

    jmp $

framebuffer     equ 0x85FC
screen_width    equ 0x85FA
screen_height   equ 0x85F9
bpp             equ 0x85F8
