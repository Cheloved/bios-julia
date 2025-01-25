[bits 16]
[org 0x7c00]

start:
    ; Настройка сегментных регистров
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Настройка стека
    mov ss, ax
    mov sp, 0x7c00

    ; Установка текстового режима 80х25
    mov ax, 0x0003
    int 0x10

    ; Начальный текст
    mov si, init_msg
    call print_string

	; Чтение второго этапа с диска
    cli
    mov ah, 0x02        ; Функция чтения секторов
    mov al, 0x10        ; Количество секторов для чтения
    mov ch, 0           ; Цилиндр
    mov dh, 0           ; Головка
    mov cl, 2           ; Сектор (MBR - 1, второй этап с 2)
    mov bx, 0x7e00      ; Адрес, куда грузить второй этап
    int 0x13
    sti

    jc disk_error       ; Проверка ошибки (CF=1 при ошибке)
    ; При отсутствии ошибки, вывести соотв. сообщение
    mov si, disk_ok_msg
    call print_string

    ; Активация линии А20
    mov ax, 0x2401
    int 0x15

    ; Загрузка GDT
    cli
    lgdt [gdt_descriptor]

    ; Включение защищенного режима
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Переход в 32-битный режим и обновление CS
    jmp CODE_SEG:protected_mode

disk_error:
    mov si, error_msg
    call print_string
    hlt

print_string:
    pusha
.loop:
    lodsb       ; Загрузка символа из SI в AL
    or al, al   ; Проверка на конец строки
    jz .done

    mov ah, 0x0e    ; Функция вывода символа
    mov bh, 0       ; Номер страницы
    int 0x10

    jmp .loop
.done:
    popa
    ret

; Данные
init_msg db "MBR Bootloader loaded", 0xD, 0xA, 0
disk_ok_msg db "Disk loaded", 0xD, 0xA, 0
a20_ok_msg db "A20 enabled", 0xD, 0xA, 0
gdt_ok_msg db "GDT loaded", 0xD, 0xA, 0
before_protected_msg db "Entering protected mode", 0xD, 0xA, 0
error_msg db "Disk error!", 0

; Определение GDT
gdt_start:
    dd 0x0
    dd 0x0
gdt_code:
    dw 0xffff       ; Лимит (0-15)
    dw 0x0          ; База (0-15)
    db 0x0          ; База (16-23)
    db 10011010     ; Present = 1 для используемых сегментов
                    ; Privilege = 00 - "ring"
                    ; Type = 1 - code/data
                    ; Type flags:
                    ;   1 - code
                    ;   0 - conforming
                    ;   1 - readable
                    ;   0 - accessed (managed by CPU)
    db 11001111     ; Granularity 1 - limit += 0x1000
                    ; 1 - 32bits
                    ; 00 - для AVL(не используется)
                    ; 1111 - лимит (16-23)
    db 0            ; База (24-31)
gdt_data:
    dw 0xffff       ; Лимит (0-15)
    dw 0x0          ; База (0-15)
    db 0x0          ; База (16-23)
    db 10010010     ; Present = 1 для используемых сегментов
                    ; Privilege = 00 - "ring"
                    ; Type = 1 - code/data
                    ; Type flags:
                    ;   0 - data
                    ;   0 - conforming
                    ;   1 - readable
                    ;   0 - accessed (managed by CPU)
    db 11001111     ; Granularity 1 - limit += 0x1000
                    ; 1 - 32bits
                    ; 00 - для AVL(не используется)
                    ; 1111 - лимит (16-23)
    db 0            ; База (24-31)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Размер
    dd gdt_start                ; Начало

CODE_SEG equ gdt_code - gdt_start   ; Offset код-дескриптора относительно начала
DATA_SEG equ gdt_data - gdt_start

[bits 32]
protected_mode:
    ; Обновление сегментных регистров
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Настройка 32-битного стека
    mov esp, 0x7c00

    mov al, 'A'
    mov ah, 0x0f
    mov [0xb8000], ax

    jmp $

    ; Переход ко второму этапу
    ;jmp 0x7e00


; Заполнение до 512 байт
times 510 - ($ - $$) db 0
dw 0xaa55
