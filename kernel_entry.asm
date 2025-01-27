[bits 32]

global _start

extern fb
extern width
extern height
extern bpp

extern main

_start:
    ; Настройка стека
    mov esp, 0x7c00

    ; Получение и запись информации о VBE
    mov [fb],     eax
    mov [width],  bx
    mov [height], cx
    mov [bpp],    dl

    ; Проверка адреса фреймбуфера
    mov edi, [fb]

    ; Установка цвета
    mov eax, 0x0000ff00     ; Зеленый (ARGB)
    mov [edi], eax

    ; Расчет общего кол-ва пикселей
    movzx ecx, word [width]
    movzx ebx, word [height]
    imul ecx, ebx

    ; Заливка фреймбуфера
    cld
    rep stosd

    ; Переход в С
    call main

    jmp $

; framebuffer     equ 0x85FC
; screen_width    equ 0x85FA
; screen_height   equ 0x85F9
; bpp             equ 0x85F8
