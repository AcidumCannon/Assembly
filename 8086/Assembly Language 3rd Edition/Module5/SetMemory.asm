; Set memory location 0:200~0:23F to 0~3F accordingly
assume cs:code

code segment
        mov ax, 0020h
        mov ds, ax ; (ds)=0020h
        sub bx, bx ; (bx)=0
        mov cx, 64 ; 0~63 in total 64 numbers
      s:mov [bx], bl
        inc bl
        loop s

        mov ax, 4c00h
        int 21h
code ends

end
