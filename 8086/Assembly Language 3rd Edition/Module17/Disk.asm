; Lab 17, disk io

assume cs:code

code segment
int7ch:
    jmp begin
    table dw 200h+read, 200h+write ; label is essentially offsets, interrupt 7ch handler is installed to 0:200, +200h is required
begin:
    push si
    push cx
    cmp ah, 1
    ja retu
    mov si, ax
    mov cl, 8
    shr si, cl
    add si, si
    call word ptr table[200h+si] ; table is a label, need to adjust as well
retu:
    pop cx
    pop si
    iret
read:
    push bp
    mov bp, sp
    push ax
    push dx
    push cx
    mov ax, dx
    sub dx, dx
    mov cx, 1440
    div cx
    xchg ax, dx ; (dx) = head, (ax) = rem(lba/1440)
    mov cl, 18
    div cl
    xchg al, ah ; (al) = rem(rem(lba/1440)/18) = sector-1, (ah) = int(rem(lba/1440)/18) = cylinder
    inc al ; (al) + 1 = (sector-1) + 1 = sector
    mov cx, ax
    mov ax, [bp-2] ; untouched ax
    mov ah, 2 ; interrupt 13h, 2=read
    mov dh, dl
    sub dl, dl
    int 13h
    pop cx
    pop dx
    pop ax
    pop bp
    ret
write:
    push bp
    mov bp, sp
    push ax
    push dx
    push cx
    mov ax, dx
    sub dx, dx
    mov cx, 1440
    div cx
    xchg ax, dx
    mov cl, 18
    div cl
    xchg al, ah
    inc al
    mov cx, ax
    mov ax, [bp-2]
    mov ah, 3 ; the only difference between read and write, interrupt 13h, 3=write
    mov dh, dl
    sub dl, dl
    int 13h
    pop cx
    pop dx
    pop ax
    pop bp
    ret
int7chend:
    nop

install:
    mov ax, cs
    mov ds, ax
    mov si, offset int7ch ; (ds:si) = cs:(offset int7ch) 
    sub ax, ax
    mov es, ax
    mov di, 200h ; (es:di) = 0:200h
    mov cx, offset int7chend-int7ch
    cld ; forward copy
    rep movsb
    mov word ptr es:[7ch*4], 200h
    mov word ptr es:[7ch*4+2], 0
start:
    ; ah = {0=read, 1=write}
    ; al = number of sectors to read/write
    ; dx = lba of begin sector
    ; es:bx = src/dst
    sub ax, ax
    mov es, ax
    mov bx, 200h
    mov ax, 0108h ; write 8 sector
    mov dx, 0 ; dst = head 0, cylinder 0, sector 1
    int 7ch
    mov ax, 4c00h
    int 21h

code ends
end install
