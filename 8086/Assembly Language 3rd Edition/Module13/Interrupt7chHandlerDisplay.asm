; Lab 13, (1), install handler for interrupt 7ch, to display a string ending with 0
assume cs:code, ds:data

data segment
    db "welcome to masm! ", 0
data ends

code segment
start:
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

    mov dh, 10
    mov dl, 10
    mov cl, 2
    mov ax, data
    mov ds, ax
    mov si, 0
    int 7ch ; display green string at 10th row, 10th column
    mov ax, 4c00h
    int 21h

handler:
    push ax
    push es
    push di
handlerstart:
    mov ax, 0b800h
    mov es, ax
    mov al, 160
    mul dh ; row efficient address = (dh) * 160
    mov di, ax
    sub ax, ax
    mov al, dl
    add di, ax
    add di, ax ; efficient address = row efficient address + dl*2 = row efficient address + dl + dl
handlerloop:
    cmp byte ptr ds:[si], 0 ; is end?
    je handlerok ; end
    mov al, ds:[si]
    mov es:[di], al ; set ascii
    mov byte ptr es:[di+1], cl ; set color
    inc si
    add di, 2
    jmp short handlerloop
handlerok:
    pop di
    pop es
    pop ax
    iret
handlerend:
    nop
code ends
end start
