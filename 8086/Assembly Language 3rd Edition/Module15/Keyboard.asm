; Lab 15, modified interrupt 9 handler

assume cs:code, ss:stack

stack segment
    db 16 dup (0)
stack ends

code segment
start:
    mov ax, stack
    mov ss, ax
    mov sp, 16
    mov ax, cs
    mov ds, ax
    mov si, offset int9 ; ds:si = cs:(offset int 9)
    sub ax, ax
    mov es, ax
    mov di, 204h ; es:di = 0:204h, where handler will be copied to
    mov cx, offset int9end-offset int9 ; handler length
    cld ; forward copy
    rep movsb
    push es:[9*4]
    pop es:[200h]
    push es:[9*4+2]
    pop es:[202h] ; store original interrupt 9 vector
    cli ; ignore maskable interrupts to prevent they are being handled before new handler is set
    mov word ptr es:[9*4], 204h ; new handler ip
    ; you DO NOT want interrupt 9 being handled here because vector is not configured yet
    mov word ptr es:[9*4+2], 0 ; new handler cs
    sti ; respond to maskable interrupts
    mov ax, 4c00h
    int 21h
int9:
    push ax
    push es
    push bx
    push cx

    in al, 60h ; read keyboard scan code

    pushf
    call dword ptr cs:[200h] ; int 9 mimic

    cmp al, 1eh+80h ; is key A released?
    jne int9ret

    mov ax, 0b800h
    mov es, ax
    sub bx, bx
    mov cx, 2000
s:
    mov byte ptr es:[bx], 'A'
    add bx, 2
    loop s
int9ret:
    pop cx
    pop bx
    pop es
    pop ax
    iret
int9end:
    nop

code ends
end start
