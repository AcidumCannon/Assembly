; Lab 14, access CMOS RAM, display current date and time
; date and time in CMOS RAM are represented by BCD (Binary-Coded Decimal)
; use 4 bits to represent decimals
; 0     1       2       3       4       5       6       7       8       9
; 0000  0001    0010    0011    0100    0101    0110    0111    1000    1001
; for example 26 in BCD = 0010 0110

assume cs:code

code segment
year:
    db '??/'
month:
    db '??/'
day:
    db '?? '
hour:
    db '??:'
minute:
    db '??:'
second:
    db '??', '$'
which:
    dw offset year, offset month, offset day, offset hour, offset minute, offset second
addr:
    db 9, 8, 7, 4, 2, 0
start:
    mov ax, cs
    mov ds, ax
    mov bx, offset addr
    mov si, offset which
    mov cx, 6
s:
    push cx
    mov al, [bx] ; set CMOS RAM unit that will be accessed
    out 70h, al ; select unit
    in al, 71h ; read from unit
    mov ah, al ; copy al to ah, suppose we have BCD(26) = 0010 0110, (ah) = 0010 0110, (al) = 0010 0110
    mov cl, 4
    shr ah, cl ; (ah) = 0000 0010, (al) = 0010 0110
    and al, 00001111b ; (ah) = 0000 0010, (al) = 0000 0110
    add ah, 30h ; (ah) = 32h = '2'
    add al, 30h ; (al) = 36h = '6'
    mov di, [si]
    ; normal memory layout (hex):
    ; [di]  [di+1]  which in decimal is [di]  [di+1]
    ;  A      1                          10     16
    ; expected memory layout (ascii)
    ; [di]  [di+1]
    ;  '2'    '6'
    mov byte ptr [di], ah ; since '26' is what we want to print, and lower address will be print first,
    mov byte ptr [di+1], al ; (ah) should be first to print out, thus lower address
    inc bx
    add si, 2
    pop cx
    loop s

    
    mov ah, 2 ; BIOS set cursor subprogram in interrupt 10h handler
    mov bh, 0 ; set page 0
    mov dh, 11 ; set row 11
    mov dl, 31 ; set column 31
    int 10h ; BIOS interrupt

    sub dx, dx ; ds:dx points to string 
    mov ah, 9 ; DOS print string at cursor subprogram in interrupt 21h handler
    int 21h ; DOS interrupt

    mov ax, 4c00h
    int 21h
code ends
end start
