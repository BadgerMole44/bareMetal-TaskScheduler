ENTRY(Reset_Handler)

MEMORY
{
    FLASH(rx):ORIGIN = 0x08000000,LENGTH = 1024K
    SRAM(rwx):ORIGIN = 0x20000000,LENGTH = 128K
}

SECTIONS
{
    .text   :
    {   
        *(.isr_vector)              /* * is wild card char. tells to merge .text sections of all input files */
        *(.text)
        *(.text.*)                  /* including nano c std lib adds extra sections. this consoladates them to one section*/
        *(.init)
        *(.fini)
        *(.rodata)                  /* including nano c std lib adds extra sections. this consoladates them to one section*/
        *(.rodata.*)
        . = ALIGN(4);               /* previous value of location counter is aligned with nex word boundary. */
        _end_of_text = .;           /* location counter stored in this symbol name (always tracks vma) */
    }> FLASH                        /* vma and lma are the same. Generate absolute addresses and load addresses in FLASH */

    _load_address_of_data = LOADADDR(.data);
    .data   :
    {
        _start_of_data = .;
        *(.data)
        *(.data.*)                  /* including nano c std lib adds extra sections. this consoladates them to one section*/
        . = ALIGN(4);
        _end_of_data = .;
    }> SRAM AT> FLASH                           /* absolute address in SRAM. load address in FLASH. */

    .bss    :
    {   
        _start_of_bss = .;
        __bss_start__ = _start_of_bss;          /* required for linking with nano c std lib*/
        *(.bss)
        *(.bss.*)                  /* including nano c std lib adds extra sections. this consoladates them to one section*/
        *(COMMON)                               /* anything from COMMON section goes to .bss section */
        . = ALIGN(4);
        _end_of_bss = .;
        __bss_end__ = _end_of_bss;              /* required for linking with nano c std lib*/
        . = ALIGN(4);
        end = .;                             /* required for linking with nano c std lib (start of heap for _sbrk in syscalls.c)*/
    }> SRAM
}