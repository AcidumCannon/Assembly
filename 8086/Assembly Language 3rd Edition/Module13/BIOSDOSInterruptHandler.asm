; Lab 13, (3), using BIOS and DOS interrupt handler
assume cs:code

code segment
s1:
    db 'Good, better, best,', '$'
s2:
    db 'Never let it rest,', '$'
s3:
    db 'Till good is better,', '$'
s4:
    db 'And better, best.', '$'
s:
    dw offset s1, offset s2, offset s3, offset s4
row:
    db 2, 4, 6, 8
start:
    mov ax, cs
    mov ds, ax
    mov bx, offset s ; bx points to string address
    mov si, offset row ; si points to row
    mov cx, 4
ok:
    mov bh, 0 ; set cursor to page 0
    mov dh, [si] ; set row
    mov dl, 0 ; set column
    mov ah, 2 ; set BIOS cursor locating subprogram
    int 10h ; BIOS interrupt

    mov dx, [bx] ; set string to print
    mov ah, 9 ; set DOS print string subprogram
    int 21h ; DOS interrupt

    add bx, 2
    inc si
    loop ok
    mov ax, 4c00h
    int 21h
code ends
end start
