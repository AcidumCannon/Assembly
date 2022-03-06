; Lab 10, subprogram dtoc

assume cs:code

data segment
    db 10 dup (0)
data ends

code segment
; example: display string coverted from word data in data segment at the 8th row, 3rd column with green color
example:
    mov ax, 12666
    mov bx, data
    mov ds, bx
    mov si, 0
    call dtoc

    mov dh, 8
    mov dl, 3
    mov cl, 2
    call show_str

    mov ax, 4c00h
    int 21h

; name: dtoc
; func: convert word to decimal string ending with 0
; para: (ax) = word data,
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
    sub dx, dx
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
    pop cx ; becareful, this is necessary when jcxz executed, we need to keep stack balanced by this or line 92
    pop es
    pop ax
    pop bx
    pop si
    pop cx
    pop dx
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
end example
