; Lab 16, direct address table

assume cs:code, ds:data

data segment
    table dw clearscreen, setforeground, setbackground, roll
data ends

code segment
start:
    ; ah = subprogram index, al = color and will only works with subprogram index 1, 2
    mov ax, 0000h ; clearscreen
    ; mov ax, 0101h ; setforeground, blue
    ; mov ax, 0207h ; setbackground, white
    ; mov ax, 0300h ; roll
    call entry
    mov ax, 4c00h
    int 21h

entry:
    push bx
    push ds
    mov bx, data
    mov ds, bx
    cmp ah, 3 ; subprogram index = {0, 1, 2, 3}
    ja entryend ; or program will end
    sub bx, bx
    mov bl, ah
    add bx, bx ; calculate the subprogram offset = (subprogram index) * 2 since offset is a word
    call word ptr table[bx] ; call subprogram
entryend:
    pop ds
    pop bx
    ret

clearscreen:
    push bx
    push cx
    push es
    mov bx, 0b800h
    mov es, bx
    sub bx, bx
    mov cx, 2000 ; 80x25=2000 characters
clearloop:
    mov byte ptr es:[bx], ' '
    add bx, 2
    loop clearloop
    pop es
    pop cx
    pop bx
    ret

setforeground:
    push bx
    push es
    push cx
    mov bx, 0b800h
    mov es, bx
    mov bx, 1
    mov cx, 2000
setfloop:
    and byte ptr es:[bx], 11111000b ; index 0(Blue), 1(Green), 2(Red) will control foreground
    or es:[bx], al ; set foreground
    add bx, 2
    loop setfloop
    pop cx
    pop es
    pop bx
    ret

setbackground:
    push bx
    push es
    push cx
    mov cl, 4
    shl al, cl ; adjust al so that bits that control background can be aligned to the byte that controls the appearance of character
    mov bx, 0b800h
    mov es, bx
    mov bx, 1
    mov cx, 2000
setbloop:
    and byte ptr es:[bx], 10001111b ; index 4(Blue), 5(Green), 6(Red) will control background
    or es:[bx], al ; set background
    add bx, 2
    loop setbloop
    pop cx
    pop es
    pop bx
    ret

; roll:
;     push bx
;     push es
;     push cx
;     mov bx, 0b800h
;     mov es, bx
;     mov bx, 160
;     mov cx, 24
; rollloop:
;     push cx
;     mov cx, 160
; copyline:
;     push ax
;     mov al, es:[bx]
;     mov es:[bx-160], al
;     pop ax
;     inc bx
;     loop copyline
;     pop cx
;     loop rollloop
;     mov cx, 80
; lastline:
;     mov byte ptr es:[bx], ' '
;     add bx, 2
;     loop lastline
;     pop cx
;     pop es
;     pop bx
;     ret
roll:
    push cx
    push ds
    push si
    push es
    push di
    mov cx, 0b800h
    mov ds, cx
    mov si, 160
    mov es, cx
    mov di, 0
    cld ; forward copy
    mov cx, 24
rollloop:
    push cx
    mov cx, 160
    rep movsb ; similar to copyline above
    pop cx
    loop rollloop
    mov cx, 80
lastline:
    mov byte ptr [si], ' ' ; not necessary to set si as 0 and using address 24*160 + si, since the time out of rollloop, si will already points to the last line
    add si, 2
    loop lastline
    pop di
    pop es
    pop si
    pop ds
    pop cx
    ret

code ends
end start
