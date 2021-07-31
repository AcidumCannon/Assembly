; Copy instructions from line 5 to line 14 to memory location 0:200
assume cs:code

code segment
        mov ax, cs
        mov ds, ax ; source, (ds)=(cs)
        mov ax, 0020h
        mov es, ax ; destination, (es)=(0020h)
        mov bx, 0  ; reset accumulator
        mov cx, 0017h ; instruction length
      s:mov al, [bx]
        mov es:[bx], al
        inc bx
        loop s
        mov ax, 4c00h
        int 21h
code ends

end
