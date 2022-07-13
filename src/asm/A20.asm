;enables the A20 line
;ax = 1 on success, ax = 0 on failure
enable_A20_16bit:
    cli
    ;check if already enabled
    call check_A20
    cmp ax, 1
    je .exit

    ;try to enable the gate with BIOS
    mov ax, 0x2401
    int 15h

    ;check if was activated
    call check_A20
    cmp ax, 1
    je .exit

    ;try with the keyboard controller
    call A20_wait
    mov al, 0xad
    out 0x64, al

    call A20_wait
    mov al, 0xd0
    out 0x64, al

    call A20_wait2
    in al, 0x60
    push ax

    call A20_wait
    mov al, 0xd1
    out 0x64, al

    call A20_wait
    pop ax
    or al, 2
    out 0x60, al

    call A20_wait
    mov al, 0xae
    out 0x64, al

    call A20_wait

    ;check if was activated
    call check_A20
    cmp ax, 1
    je .exit

    ;try the Fast A20 gate
    in al, 0x92
    or al, 2
    out 0x92, al

    ;check if was activated
    call check_A20
    cmp ax, 1
    je .exit

    ;nothing worked so give up
    mov ax, 0

.exit:
    ret

A20_wait:
    in al, 0x64
    test al, 2
    jnz A20_wait
    ret

A20_wait2:
    in al, 0x64
    test al, 1
    jnz A20_wait2
    ret

;Checks if the A20 line is enabled
;ax = 1 if the line is enabled, otherwise ax = 0

check_A20:
    push ds
    push es
    push si
    push di

    cli

    xor ax, ax  ;es = 0
    mov es, ax

    not ax      ;ds = 0xFFFF
    mov ds, ax

    mov di, 0x500
    mov si, 0x510

    mov al, byte [es:di]
    push ax

    mov al, byte [ds:si]
    push ax

    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF

    cmp byte [es:di], 0xFF

    pop ax
    mov byte [ds:si], al

    pop ax
    mov byte [es:di], al

    mov ax, 0
    je .exit

    mov ax, 1
.exit:
    pop di
    pop si
    pop es
    pop ds
    ret