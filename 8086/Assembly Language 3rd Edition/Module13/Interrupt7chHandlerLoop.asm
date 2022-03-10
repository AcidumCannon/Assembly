; Lab 13, (2), install handler for interrupt 7ch, to mimic loop
assume cs:code

code segment
    mov ax, cs
    mov ds, ax
    mov ax, offset handler
    mov si, ax ; ds:si = cs:(offset handler)
    sub ax, ax
    mov es, ax
    mov ax, 200h
    mov di, ax ; es:di = 0:200h
    cld ; set copy forward
    mov cx, offset handlerend-offset handler ; set copy length
    rep movsb ; copy

    mov word ptr es:[7ch*4], 200h
    mov word ptr es:[7ch*4+2], 0 ; set interrupt vector

    mov ax, 0b800h
    mov es, ax
    mov di, 160*12
    mov bx, offset s-offset se
    mov cx, 80
s:
    mov byte ptr es:[di], '!'
    add di, 2
    int 7ch
se:
    nop
    mov ax, 4c00h
    int 21h

handler:
    push bp
    mov bp, sp
    dec cx ; mimic loop first step: (cx)=(cx)-1
    jcxz handlerok ; (cx)=0, exit loop
    add [bp+2], bx ; (cx)!=0, loop, [bp+2] = offset se, (bx) = offset s-offset se, [bp+2]+(bx) = offset s
handlerok:
    pop bp
    iret
handlerend:
    nop
code ends
end
