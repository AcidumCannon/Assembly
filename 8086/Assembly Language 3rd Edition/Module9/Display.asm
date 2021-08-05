; Lab 9, display 'welcome to asm!' in three lines in the middle of the screen
; first line will be green characters but black background
; second line will be red characters but green background
; third line will be blue characters but white background

assume ds:data, cs:code, ss:stack

data segment
    db 'welcome to masm!'
    db 02h, 24h, 71h ; green/black, red/green, blue/white
data ends

stack segment
    db 16 dup (0)
stack ends

code segment
start:  mov ax, data
        mov ds, ax

        mov ax, stack
        mov ss, ax
        mov sp, 16

        mov ax, 0b800h ; 80 (column) x 25 (row) display buffer memory address
        mov es, ax

        mov bp, 0780h ; starts from 12th row
        mov di, 3
        mov cx, 3
line:   sub di, cx ; di changes from 0 to 2
        push cx

        sub bx, bx
        sub si, si
        mov cx, 16
col:    ; copy character
        mov al, [0 + bx]
        mov es:[bp + 40h + si], al ; starts from 33th column, low byte ascii
        ; set appearance
        mov al, [16 + di]
        mov es:[bp + 41h + si], al ; starts from 33th column, high byte appearance
        inc bx
        add si, 2
        loop col

        add bp, 00a0h ; 1 styled character = 1 byte ascii + 1 byte appearance = 2 byte, thus 80 characters = 80 x 2 = 160 bytes = 00a0h(hex)
        mov di, 3
        pop cx
        loop line

        mov ax, 4c00h
        int 21h
code ends

end start
