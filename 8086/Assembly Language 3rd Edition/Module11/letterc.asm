; Lab 11, subprogram letterc

; ascii, a=97, z=122

assume cs:code

data segment
    db "Beginner's All-purpose Symbolic Instruction Code.", 0
data ends

code segment
example:
    mov ax, data
    mov ds, ax
    sub si, si
    call letterc

    mov ax, 4c00h
    int 21h

; name: letterc
; func: convert lower case alphabets in the string ending with 0 to upper case
; para: ds:si points to the string address
; reru: not applicable
letterc:
    push si
start:
    cmp byte ptr [si], 0
    je ok
    cmp byte ptr [si], 97
    jb next
    cmp byte ptr [si], 122
    ja next
    and byte ptr [si], 11011111b
next:
    inc si
    jmp short start
ok:
    pop si
    ret

code ends
end example
