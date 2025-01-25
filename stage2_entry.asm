[bits 32]

global _start
extern main

_start:
    ; Настройка стека
    mov esp, 0x7c00

    ;mov al, 'X'
    ;mov ah, 0x0f
    ;mov [0xb8002], ax

    mov bl, 0b1111 ; Белый цвет
    mov ecx, 0d8   ; Начальное положение 50, 50
    mov edx, 0d32
    call set_pixel

    mov ecx, 0d8   ; Начальное положение 50, 50
    mov edx, 0d64
    call set_pixel
    mov ecx, 0d8   ; Начальное положение 50, 50
    mov edx, 0d128
    call set_pixel

    mov ecx, 0d16   ; Начальное положение 50, 50
    mov edx, 0d32
    call set_pixel

    mov ecx, 0d32   ; Начальное положение 50, 50
    mov edx, 0d32
    call set_pixel

;.test:
;    cmp ecx, 100
;    ja .test_end
;
;    mov eax, ecx
;    and eax, 0xFFF8
;    mov edi, eax
;    add edi, 8
;    .fill_byte:
;        call set_pixel
;        inc eax
;        cmp eax, edi
;        jb .fill_byte
;    add ecx, 8
;    jmp .test
;.test_end:

    ; Переход к основному циклу в С
    ;call main

    jmp $

; Функция установки пикселя
; ecx - координата X
; edx - координата Y
; bl - цвет (4 бита)
set_pixel:
    push eax
    push ebx
    push ecx
    push edx
    push edi

    ; Вычисление смещения
    mov eax, edx        ; EAX = Y
    mov edi, 80         ; 640 пикселей = 80 байт на строку
    mul edi             ; EAX = Y * 80

    mov edi, ecx        ; EDI = X
    shr edi, 3          ; EDI >> 3 ( X / 8 )
    add edi, eax        ; EDI = Y*80 + X/8
    add edi, 0xA0000    ; Плоский адрес видеопамяти

    ; Вычисление бита (каждый байт хранит строку из 8 бит пикселей)
    mov eax, ecx      ; EAX = X
    and eax, 7        ; EAX = X % 8 (0-7)
    mov cl, 7
    sub cl, al        ; CL = 7 - (X % 8)

    ; Запись в плоскости
    mov dx, 0x03C4  ; Порт Sequencer
    mov al, 0x02    ; Регистр Map Mask
    out dx, al
    inc dx          ; Порт 0х03С5

    mov bh, 0x01    ; Начинаем с Plane 0 (бит 0)
.plane_loop:
    ; Проверяем, нужно ли устанавливать бит в текущей плоскости
    test bl, bh
    jz .next_plane

    mov al, bh  ; Активируем текущую плоскость
    out dx, al

    ; Вычисляем битовую маску в регистре AL
    mov al, 1               ; AL = 0b00000001
    shl al, cl              ; Сдвигаем влево на CL бит
    mov [edi], al           ; Записываем результат в видеопамять

.next_plane:
    shl bh, 1   ; Переходим к следующей плоскости
    cmp bh, 0x10    ; Проверяем, вышли ли за 4 плоскости
    jb .plane_loop

    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


