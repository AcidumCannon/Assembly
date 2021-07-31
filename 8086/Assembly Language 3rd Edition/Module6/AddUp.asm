; Add data in segment a and segment b to segment c accordingly
assume cs:code

a segment
    db 1, 2, 3, 4, 5, 6, 7, 8
a ends

b segment
    db 1, 2, 3, 4, 5, 6, 7, 8
b ends

c segment
    db 0, 0, 0, 0, 0, 0, 0, 0
c ends

code segment
start:  mov ax, a
        mov ds, ax ; (ds) = a

        mov ax, c
        mov es, ax ; (es) = c

        sub bx, bx
        mov cx, 8
    s:  mov dl, [bx] ; (dl) = (ds * 16 + bx)
        push ds ; temporary store ds
        mov ax, b
        mov ds, ax
        add dl, [bx] ; add up
        mov es:[bx], dl
        pop ds ; restore ds
        inc bx
        loop s

        mov ax, 4c00h
        int 21h

code ends

end start
