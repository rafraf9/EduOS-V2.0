[bits 16]

;Address to copy the MBR to
LOAD_ADDRESS equ 0x1000

[org LOAD_ADDRESS + 512]

_start:
    mov si, WELCOME_MSG
    call print_string_16bit

    ;infinate loop
    jmp $


;--------------------------------------------
;Include section
;--------------------------------------------
%include "src/asm/print_16bit.asm"

;--------------------------------------------
;Data section
;--------------------------------------------
WELCOME_MSG db "Loaded second stage", 0xa, 0xd, 0x0

;Padding at the end
times 512-($-$$) db 0