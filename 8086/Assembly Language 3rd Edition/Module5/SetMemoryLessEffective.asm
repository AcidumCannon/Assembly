; Set memory location 0:200~0:23F to 0~3F accordingly, but less effective
assume cs:code

code segment
        mov ax, 0
        mov ds, ax

        mov bx, 200h
        sub dl, dl
        
        mov cx, 64
      s:mov [bx], dl ; less effective
      ; the reason this is less effective is because we can start from 0200:0, then (bx)=(dl), we only need one register
        inc bx
        inc dl
        loop s

        mov ax, 4c00h
        int 21h
code ends

end
