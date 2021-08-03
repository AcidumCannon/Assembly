; Capitalize front four characters for each english word in data segment
assume cs:codesg, ss:stacksg, ds:datasg

stacksg segment
    dw 0, 0, 0, 0, 0, 0, 0, 0 ; use stack to temporarily store register content
stacksg ends

datasg segment
    db '1. display      ' ; each of them is 16 bytes
    db '2. brows        '
    db '3. replace      '
    db '4. modify       '
datasg ends

codesg segment
start:  mov ax, stacksg
        mov ss, ax
        mov sp, 16 ; initialize stack
        mov ax, datasg
        mov ds, ax
        mov cx, 4 ; outer loop, for 4 rows
        sub bx, bx ; use (bx) to represent row address, initialize (bx)
row:    push cx ; store outer loop counter
        sub si, si ; use (si) to represent col address, initialize (si)
        mov cx, 4 ; inner loop, for 4 columns
col:    mov al, [bx + si + 3] ;| set the 5th (0 based) bit to 0 (rest are 1s) and apply AND bitwisely will set whatever a~z to A~Z correspondingly
        and al, 11011111B ;| <- that is what we do here
        mov [bx + si + 3], al ;| set the 5th (0 based) bit to 1 (rest are 0s) and apply OR bitwisely will set whatever A~Z to a~z correspondingly
        inc si
        loop col
        add bx, 16
        pop cx ; restore outer loop counter
        loop row
        mov ax, 4c00h
        int 21h
codesg ends

end start
