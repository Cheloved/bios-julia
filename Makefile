# Конфигурация
CC := gcc
ASM := nasm
LD = ld
QEMU := qemu-system-x86_64

# Флаги
ASMFLAGS := -f bin
CFLAGS := -O0 -nostdlib -ffreestanding -fno-pie -fno-pic \
		  -mno-red-zone -m16 -march=i386 -mtune=i386
LDFLAGS := -m elf_i386 -T linker.ld -nostdlib --oformat binary

# Исходные файлы
BOOT_SRC := boot.asm
STAGE2_ENTRY := stage2_entry.asm
STAGE2_SRCS := stage2.c $(wildcard *.c)
STAGE2_OBJS := stage2_entry.o $(STAGE2_SRCS:.c=.o)

# Цели по умолчанию
all: disk.img

# Сборка загрузчика
boot.bin: $(BOOT_SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

# Cборка stage2_entry
stage2_entry.o: $(STAGE2_ENTRY)
	$(ASM) -f elf32 $< -o $@

# Компиляция С-файлов
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Линковка stage2
stage2.bin: $(STAGE2_OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

# Создание образа диска
disk.img: boot.bin stage2.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=boot.bin of=$@ conv=notrunc
	dd if=stage2.bin of=$@ bs=512 seek=1 conv=notrunc

# Запуск в QEMU
run: disk.img
	# $(QEMU) -nographic -drive format=raw,file=$<
	# $(QEMU) -display curses -serial stdio -drive format=raw,file=$<
	$(QEMU) -display none -vnc :0 -drive format=raw,file=$<

gccs:
	$(CC) $(CFLAGS) -s -c screen.c -o screen.s

# Очистка
clean:
	rm -f *.o *.bin *.img *.s

kill:
	pkill qemu-system-x86_64

.PHONY: all run clean
