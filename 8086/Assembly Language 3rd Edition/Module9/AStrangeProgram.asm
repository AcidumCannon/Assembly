; Lab 8 from the text book, will the program exit normally? Yes!
assume cs:codesg

codesg segment                  ; offset(dec) comment
        mov ax, 4c00h           ; 0
        int 21h                 ; 3
start:  mov ax, 0               ; 5
    s:  nop                     ; 6 EB after instruction copy, the instruction is: EB F6, equivalent to (ip) = (ip) - 10 = 10 - 10 = 0
        nop                     ; 7 F6

        mov di, offset s        ; 10 <- where 10 comes from
        mov si, offset s2       ; 13
        mov ax, cs:[si]         ; 16 instruction copy
        mov cs:[di], ax         ; 19 instruction copy

    s0: jmp short s             ; 22

    s1: mov ax, 0               ; 24
        int 21h                 ; 27
        mov ax, 0               ; 29

    s2: jmp short s1            ; 32 EB F6, equivalent to (ip) = (ip) - 10 = 24 - 34 = -10 = F6 (2's complement)
        nop                     ; 34

codesg ends
end start
