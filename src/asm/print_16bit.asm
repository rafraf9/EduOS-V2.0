[bits 16]

;INPUT: si - null ending string to print
;prints a string to the screen
print_string_16bit:
    push ax
    push si
    mov ah, 0x0e    ;teletype code

    .print_char:
        mov al, byte [si]   ;get byte from string

        cmp al, 0           ;check if we reached the end of the string
        je .end_print   

        int 0x10            ;print the character

        inc si              ;next byte of string
        jmp .print_char     ;loop
    .end_print:

    pop si
    pop ax
    ret


