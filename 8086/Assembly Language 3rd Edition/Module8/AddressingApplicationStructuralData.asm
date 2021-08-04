; My solution for Lab 7 in the textbook
assume cs:code, ds:data, es:table, ss:stack

data segment
    ; from 1975 to 1995, in total 21 years, string
    ; ds:[0] ~ ds:[83]
    db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982', '1983'
    db '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992'
    db '1993', '1994', '1995'
    ; total income in 21 years, double word
    ; ds:[84] ~ ds:[167]
    dd 16, 22, 382, 1356, 2390, 8000, 16000, 24486, 50065, 97479, 140417, 197514
    dd 345980, 590827, 803530, 1183000, 1843000, 2759000, 3753000, 4649000, 5937000
    ; number of the employees in the company in 21 years, word
    ; ds:[168] ~ ds:[209]
    dw 3, 7, 9, 13, 28, 38, 130, 220, 476, 778, 1001, 1442, 2258, 2793, 4037, 5635, 8226
    dw 11542, 14430, 15257, 17800
data ends

table segment
    db 21 dup ('year summ ne ?? ')
table ends

stack segment
    db 16 dup (0)
stack ends

code segment
start:  mov ax, data
        mov ds, ax

        mov ax, table
        mov es, ax 

        mov ax, stack
        mov ss, ax
        mov sp, 16

        sub bp, bp
        sub bx, bx
        sub si, si

        mov cx, 21
all:    push cx ; temporarily store outer loop counter
        
        ; handle year and income
        push si ; temporarily store (si)
        sub si, si
        mov cx, 2
yrin:   mov ax, [0 + bx + si] ; equivalent instruction: mov ax, 0[bx][si], meaning: select first logic row of data segment (year string), treat each year string as a row, and a word as an element
        mov es:[bp + 0 + si], ax ; equivalent instruction: mov es:[bp].0[si], ax, meaning: for bp logic row in table segment, treat first logic data member as an array, and a word as an element
        mov ax, [84 + bx + si] ; equivalent instruction: mov ax, 84[bx][si], meaning: select second logic row of data segment (income dword), treat each income dword as a row, and a word as an element
        mov es:[bp + 5 + si], ax ; equivalent instruction: mov es:[bp].5[si], ax, meaning: for bp logic row in table segment, treat second logic data member as an array, and a word as an element
        add si, 2
        loop yrin
        pop si ; restore (si)
        
        ; handle number of employees
        mov ax, [168 + si] ; equivalent instruction: mov ax, 168[si], meaning: selection third row of data segment (number of employees, word) treat each number of employees word as an element
        mov es:[bp + 0ah], ax ; equivalent instruction: es:[bp].0ah, meaning: for bp logic row in table segment, treat third logic data member as an element
        
        ; handle income per employee
        mov ax, es:[bp + 5 + 0] ; dividend 32 bit
        mov dx, es:[bp + 5 + 2] ; move dividend low word to ax, and high word to dx
        div word ptr [168 + si] ; divisor 16 bit
        mov es:[bp + 0dh], ax ; ax is the quotient, dx is the remainder

        add bx, 4
        add bp, 16
        add si, 2
        pop cx ; restore outer loop counter
        loop all

        mov ax, 4c00h
        int 21h
code ends

end start
