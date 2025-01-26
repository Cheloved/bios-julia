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
    mov al, 0x4         ; Количество секторов для чтения
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

    mov si, before_stage2_msg
    call print_string

    jmp 0x7e00


disk_error:
    mov si, error_msg
    call print_string
    cli
    hlt

print_string:
    pusha
.loop:
    lodsb           ; Загрузка символа из SI в AL
    or al, al       ; Проверка на конец строки
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
disk_ok_msg db "Stage2 loaded from disk", 0xD, 0xA, 0
before_stage2_msg db "Entering stage 2", 0xD, 0xA, 0
error_msg db "Disk error on loading stage2!", 0xD, 0xA, 0

; Заполнение до 512 байт
times 510 - ($ - $$) db 0
dw 0xaa55
