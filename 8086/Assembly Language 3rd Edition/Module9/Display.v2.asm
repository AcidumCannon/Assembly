; Lab 9, display 'welcome to asm!' in three lines in the middle of the screen
; first line will be green characters but black background
; second line will be red characters but green background
; third line will be blue characters but white background
assume cs:code, ds:data

data segment
    db 'welcome to masm!'
    db 16 dup (02h) ; green/black
    db 16 dup (24h) ; red/green
    db 16 dup (71h) ; blue/white
data ends

code segment
start:  mov ax, data
        mov ds, ax ; ds points to source

        mov ax, 0b800h ; 80 (column) x 25 (row) display buffer memory address
        mov es, ax ; es points to destination

        mov bx, 6e0h ; start from 11th row
        mov bp, 16 ; bp points to style
        
        mov cx, 3
line:   push cx
        
        sub si, si
        mov di, 3eh ; starts from 31th column
        
        mov cx, 16
col:    mov al, ds:[si] ; copy character
        mov es:[bx+di], al ; low byte ascii
        mov al, ds:[bp+si] ; copy appearance
        mov es:[bx+di+1], al ; high byte appearance
        inc si
        add di, 2
        loop col

        add bx, 160
        add bp, 16
        pop cx
        loop line

        mov ax, 4c00h
        int 21h
code ends

end start
