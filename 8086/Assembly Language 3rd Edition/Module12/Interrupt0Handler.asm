; lab12, interrupt 0 handler
assume cs:code

code segment
    ; install interrupt handler
    sub ax, ax
    mov es, ax
    mov di, 200 ; set es:di = 0:200
    mov ax, cs
    mov ds, ax
    mov si, offset int0 ; set ds:si = cs:offset int0
    mov cx, offset int0end-offset int0 ; interrupt handler length = offset int0end-offset int0
    cld ; set copy direction forward
    rep movsb ; copy interrupt handler
    ; set interrupt vector = 0:200
    mov word ptr es:[0*4], 200
    mov word ptr es:[0*4+2], 0
    ; example, 16 bits dividend, 8 bit divisor, 8 bit result
    mov ax, 1000
    mov dh, 1
    div dh ; 1000/1=1000>255, al cannot store a number greater than 255, thus overflow, trigger interrupt 0

    mov ax, 4c00h
    int 21h

; interrupt 0 handler
int0:
    jmp short int0start
    ; cannot using data segment as usual since after interrupt installer executed,
    ; allocated memeory will be given back to OS
    db 'divide error!'
    push ds
    push si
    push ax
    push es
    push di
    push cx
int0start:
    mov ax, cs
    mov ds, ax
    mov si, 202 ; jmp short int0start length is 2, so the string address will be 200+2=202, ds:si = 0:202
    mov ax, 0b800h
    mov es, ax
    mov di, 12*160+32*2 ; es:di = b800:(12*160+32*2), row 13, column 33
    mov cx, 13
int0loop:
    mov al, ds:[si]
    mov es:[di], al
    mov byte ptr es:[di+1], 4 ; set color to red
    inc si
    add di, 2
    loop int0loop

    pop cx
    pop di
    pop es
    pop ax
    pop si
    pop ds
    mov ax, 4c00h
    int 21h
int0end:
    nop
code ends
end
