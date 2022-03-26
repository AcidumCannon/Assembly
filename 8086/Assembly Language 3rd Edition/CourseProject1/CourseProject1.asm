; course project 1
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

temp segment
    db 16 dup (0)
temp ends

table segment
    db 21 dup ('year', 0, 'summ ne ?? ')
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

    mov cx, 21
    sub dx, dx
    mov dh, 0
    mov ax, table
    mov ds, ax
    sub si, si
s2:
    push cx
    mov dl, 0 ; set column 0
    mov cl, 8 ; set color white
    call show_str ; show year
    
    push ds
    push si
    push dx
    mov ax, [si+5] ; set summ low 16 bits
    mov dx, [si+7] ; set summ high 16 bits
    push ax
    mov ax, temp
    mov ds, ax
    pop ax
    sub si, si ; set ds:si points to temp segment to store converted string ending with 0
    call dtoc ; convert
    pop dx
    mov dl, 20 ; set column 20, color is still white
    call show_str ; show summ
    pop si
    pop ds

    push ds
    push si
    push dx
    mov ax, [si+10] ; set ne low 16 bits
    sub dx, dx ; set ne high 16 bits
    push ax
    mov ax, temp
    mov ds, ax
    pop ax
    sub si, si ; set ds:si points to temp segment to store converted string ending with 0
    call dtoc ; convert
    pop dx
    mov dl, 40 ; set column 40, color is still white
    call show_str ; show ne
    pop si
    pop ds

    push ds
    push si
    push dx
    mov ax, [si+13] ; set avg low 16 bits
    sub dx, dx ; set avg high 16 bits
    push ax
    mov ax, temp
    mov ds, ax
    pop ax
    sub si, si ; set ds:si points to temp segment to store converted string ending with 0
    call dtoc ; convert
    pop dx
    mov dl, 60 ; set column 60, color is still white
    call show_str ; show avg
    pop si
    pop ds
    
    inc dh
    add si, 16
    pop cx
    loop s2
    
    mov ax, 4c00h
    int 21h

; name: show_str
; func: show an string ended with 0 at the designated position with designated color
; para: (dh) = row, 0~24,
;       (dl) = column, 0~79,
;       (cl) = color, red=1, green=2, blue=3,
;       ds:si points to the string address
; reru: not applicable
show_str:
    push dx
    push cx
    push si
    push bx
    push ax
    push es
change:
    push cx ; we need to keep (cl) since we will use it later
    sub cx, cx
    mov cl, [si]
    jcxz ok
    mov al, dh
    mov ah, 0a0h
    mul ah ; E = row x A0
    mov bx, ax
    sub ax, ax
    mov al, dl
    add bx, ax
    add bx, ax ; E + column x 2 = E + column + column = character ascii address
    mov ax, 0b800h
    mov es, ax
    mov es:[bx], cl
    pop cx
    mov es:[bx+1], cl ; E + column x 2 + 1 = E + column + column + 1 = character style
    inc si
    inc dl
    jmp short change
ok: 
    pop cx ; becareful, this is necessary when jcxz executed, we need to keep stack balanced by this or line 161
    pop es
    pop ax
    pop bx
    pop si
    pop cx
    pop dx
    ret

; name: dtoc
; func: convert dword to decimal string ending with 0
; para: (ax) = dword low 16 bits,
;       (dx) = dword high 16 bits,
;       ds:si points to the string address
; reru: not applicable
dtoc:
    push ax
    push dx
    push cx
    push bx
    push si
    sub bx, bx ; use bx to count how many characters pushed to the stack
convert:
    mov cx, 10
    call divdw
    add cx, 30h ; digit + 30h is the corresponding ascii
    push cx
    inc bx
    mov cx, ax
    jcxz convertok ; quotient is zero, means we finally got the last digit
    jmp short convert
convertok:
    mov cx, bx
copy:
    pop ax ; since we pushed every digit to stack in the reversed order (least significant to most significant), pop will restore
    mov [si], al
    inc si
    loop copy
    mov [si], 0 ; now add trailing zero to suggest the end of string
    pop si
    pop bx
    pop cx
    pop dx
    pop ax
    ret

; name: divdw
; func: doing division without overflow, dword dividend, word divisor, dword answer
; para: (ax) = dword low 16 bits,
;       (dx) = dword high 16 bits,
;       (cx) = divisor
; retu: (dx) = answer high 16 bits
;       (ax) = answer low 16 bits
;       (cx) = remainder
divdw:
    push bx
    push ax
    mov ax, dx
    sub dx, dx ; H/N
    div cx ; (ax) = int(H/N), (dx) = rem(H/N)
    mov bx, ax
    pop ax ; (dx):(ax) = rem(H/N) * 65536 + L
    div cx ; (ax) = int(rem(H/N) * 65536 + L), (dx) = rem(rem(H/N) * 65536 + L)
    mov cx, dx ; cx remainder
    mov dx, bx ; dx answer high 16 bits, ax already has the answer low 16 bits
    pop bx ; balance stack
    ret

code ends
end start
