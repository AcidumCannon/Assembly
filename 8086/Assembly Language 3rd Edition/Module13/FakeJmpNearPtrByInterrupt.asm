; check point 13.1 (2)
; use interrupt 7ch to mimic jmp near ptr s, use bx to store offset
assume cs:code

data segment
    db 'conversation', 0
data ends

code segment
start:
    mov ax, cs
    mov ds, ax
    mov si, offset handler ; ds:si = cs:(offset handler)
    sub ax, ax
    mov es, ax
    mov di, 200h ; es:di = 0:200h
    cld ; copy direction forward
    mov cx, offset handlerend-offset handler ; handler length
    rep movsb ; copy
    mov word ptr es:[7ch*4], 200h
    mov word ptr es:[7ch*4+2], 0 ; set interrupt vector
    mov ax, data
    mov ds, ax
    mov si, 0
    mov ax, 0b800h
    mov es, ax
    mov di, 12*160
s:
    cmp byte ptr [si], 0
    je ok
    mov al, [si]
    mov es:[di], al
    inc si
    add di, 2
    mov bx, offset s-offset ok
    int 7ch
ok:
    mov ax, 4c00h
    int 21h

handler:
    push bp
    mov bp, sp
    add [bp+2], bx ; (offset ok) + bx = (offset ok) + (offset s - offset ok) = (offset s)
    pop bp
    iret
handlerend:
    nop
code ends
end start
