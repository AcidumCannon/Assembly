; Lab 10, subprogram show_str

; 80x25 color display mode information:
; 80 columns, 25 rows,
; a character is consists of 2 bytes, ascii and style,
; buffer address: B8000H~BFFFFH,
; 32KB buffer = 8 (pages for display) x ~4 (KB per page for display, 4000B is needed actually),
; monitor will display the first page by default, so (following are zero based),
; assume E = row x A0
; then B800:E = row address
; E + column x 2 = character ascii address
; E + column x 2 + 1 = character style

; 80x25 character style:
; 7    6    5    4    3    2    1    0
; BL   R    G    B    HI   R    G    B
; blink: 7
; background: 4, 5, 6
; highlight: 3
; foreground: 0, 1, 2

assume cs:code

data segment
    db 'Welcome to masm!', 0
data ends

code segment
; example: display string in data segment at the 8th row, 3rd column with green color
example:
    mov dh, 8
    mov dl, 3
    mov cl, 2
    mov ax, data
    mov ds, ax
    mov si, 0
    call show_str

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
    pop cx ; becareful, this is necessary when jcxz executed, we need to keep stack balanced by this or line 71
    pop es
    pop ax
    pop bx
    pop si
    pop cx
    pop dx
    ret

code ends
end example
