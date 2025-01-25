OUTPUT_FORMAT("binary")
OUTPUT_ARCH(i8086)
ENTRY(_start)
SECTIONS {
    . = 0x7e00;
    .text : { *(.text) }
    .data : { *(.data) }
    .rodata : { *(.rodata) }
    .bss : { *(.bss) }
    /DISCARD/ : { *(.note*) }
}
