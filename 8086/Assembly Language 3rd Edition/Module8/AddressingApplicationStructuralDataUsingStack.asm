assume cs:code, ds:data, es:table, ss:stack

data segment
    ;0
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'
    ;84
    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
    ;168
    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800
data ends

table segment
    db 21 dup ('year summ ne ?? ')
table ends

stack segment
    db 16 dup (0)
stack ends

code segment
start:
    mov ax, data
    mov ds, ax

    mov ax, table
    mov es, ax

    mov ax, stack
    mov ss, ax
    mov sp, 16

    sub bx, bx
    sub bp, bp
    sub di, di
    mov cx, 21
s0:
    push cx
    sub si, si
    mov cx, 2
s1:
    ;       si  si
    ;       |   |
    ;       v   v
    ; bp-> '1 9 7 5'
    ; bp-> '1 9 7 6'
    ;      ...
    mov ax, ds:[0+bp+si]
    mov es:[bx+0+si], ax
    mov ax, ds:[84+bp+si]
    mov es:[bx+5+si], ax
    push ax
    add si, 2
    loop s1

    mov ax, ds:[168+di]
    mov es:[bx+0ah], ax

    pop dx
    pop ax
    div word ptr es:[bx+0ah] ; DO NOT forget to explicitly point out the unit size
    mov es:[bx+0dh], ax

    add bx, 10h
    add bp, 4
    add di, 2
    pop cx
    loop s0

    mov ax, 4c00h
    int 21h
code ends
end start
