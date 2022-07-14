[bits 16]

;Address to copy the MBR to
LOAD_ADDRESS equ 0x1000

;Start of the stack
STACK_START equ 0x2000

;the size of the second stage (in sectors)
SECOND_STAGE_SIZE equ 1

[org LOAD_ADDRESS]

;--------------------------------------------
;Text sections
;--------------------------------------------
;infinite loop
_start:
    cli ;disable interrupts
    xor ax, ax ;reset all segment registers to 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    ;copy MBR to a new location
    .COPY_MBR:
        mov cx, 0x100
        mov si, 0x7c00
        mov di, LOAD_ADDRESS
        rep movsw
    ;jump to the new location
    jmp 0:AfterLoad

AfterLoad:
    ;Setup stack
    mov sp, STACK_START
    mov bp, sp

    ;save the drive number
    mov byte [drive_number], dl

    ;print hello message
    mov si, HELLO_MSG
    call print_string_16bit

    .pci_check:
        ;check for PCI instalation
        xor di, di
        mov ax, 0xb101
        int 0x1a 
        
        ;check if installed
        cmp ah, 0
        je .cpuid_check

        ;if not, print an error message and exit
        mov si, PCI_ERROR_MSG
        call print_string_16bit

        jmp .exit
    .cpuid_check:
       pushfd   ;save flags
       pushfd   ;store flags
       xor dword[esp], 0x00200000
       popfd    ;change eflags
       pushfd   ;check if changes happened

       pop eax
       xor eax, [esp]
       popfd
       and eax, 0x00200000

       cmp eax, 0
       jne .check_msr

       mov si, CPUID_ERROR_MSG
       call print_string_16bit

       jmp .enable_A20
    .check_msr:
        mov eax, 0x1
        cpuid
        test edx, 0x20
        jne .enable_A20

        mov si, MSR_ERROR_MSG
        call print_string_16bit
        jmp .exit
    .enable_A20:
        call enable_A20_16bit
        cmp ax, 1
        je .load_second_stage

        mov si, A20_ERROR_MSG
        call print_string_16bit
        jmp .exit
    .load_second_stage:
        xor ax, ax
        mov es, ax                              ;es:bx buffer 

        mov ax, (0x0200 + SECOND_STAGE_SIZE)    ;ah = 02(read), al = number of sectors to read
        mov cx, 0x2                             ;ch = cylindar number, cl = sector number
        mov dh, 0                               ;head number
        mov dl, byte [drive_number]             ;drive_number
        mov bx, second_stage                    ;es:bx, buffer
        int 0x13
    

        jnc second_stage                        ;carry is set on error

        mov si, SECOND_STAGE_ERROR
        call print_string_16bit

.exit:
    ;infinite loop
    jmp $

;--------------------------------------------
;Include section
;--------------------------------------------
%include "src/asm/print_16bit.asm"
%include "src/asm/A20.asm"

;--------------------------------------------
;Variable section
;--------------------------------------------
drive_number db 0

;--------------------------------------------
;Data section
;--------------------------------------------
HELLO_MSG db "Start", 0xa, 0xd, 0
PCI_ERROR_MSG db "PCI not found", 0xa, 0xd, 0
CPUID_ERROR_MSG db "CPUID not found", 0xa, 0xd, 0
MSR_ERROR_MSG db "MSR not found", 0xa, 0xd, 0
A20_ERROR_MSG db "cant enable A20", 0xa, 0xd, 0
SECOND_STAGE_ERROR db "Failed second stage", 0xa, 0xd, 0
;padding till end of sector
times 510-($-$$) db 0
;magic number
dw 0xaa55

;second_stage_is_to_be_loaded_here
second_stage: