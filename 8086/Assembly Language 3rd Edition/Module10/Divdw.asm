; Lab 10, subprogram divdw

; int(X/Y) = quotient of X/Y
; rem(X/Y) = remainder of X/Y
; eg. int(38/10) = 3, rem(38/10) = 8
; X/N = int(H/N)*65536 + (rem(H/N)*65536+L)/N [****]
; where int(H/N) is the high 16 bits, and the remainder is the high 16 bits of (rem(H/N)*65536+L)
; so after (rem(H/N)*65536+L)/N is made, you will essentially get low 16 bits of X/N and remainder
; assume after (rem(H/N)*65536+L)/N is made, (ax) = A, (bx) = B
; [****] is logically = int(H/N):(A:B)

; Proof of X/N = int(H/N)*65536 + (rem(H/N)*65536+L)/N gives as follows:
; since H = int(H/N)*N + rem(H/N)
; X/N = (H*65536 + L)/N
;     = ((int(H/N)*N + rem(H/N))*65536 + L)/N
;     = (int(H/N) + rem(H/N)/N)*65536 + L/N
;     = int(H/N)*65536 + rem(H/N)*65536/N + L/N
;     = int(H/N)*65536 + (rem(H/N)*65536 + L)/N
; H, L, N can be stored in the 16 bits register thus H, L, N <= 65535 [***]
; so H/N, L/N will not overflow
; and rem(H/N) will range from [0, N-1], thus rem(H/N) <= N-1
; rem(H/N)*65536+L  <= (N-1)*65536+L <= (N-1)*65536+65535 by [***] <= N*65536-65536+65535 <= N*65536-1
; so (rem(H/N)*65536+L)/N <= (N*65536-1)/N = 65536-(1/N) < 65536, since only integer can be picked,
; (rem(H/N)*65536+L)/N <= 65535 will not cause overflow

; p.s. treat X*65536+Y = X:Y (left-shift 4 times) similar like we did to cs:ip really helps me to understand how to use [****]

assume cs:code

code segment
; example: compute 000f4240 / 0a
example:
    mov ax, 4240h
    mov dx, 000fh
    mov cx, 0ah
    call divdw

    mov ax, 4c00h
    int 21h
; name: divdw
; func: doing division without overflow, dword dividend, word divisor, dword answer
; para: (ax) = dword low 16 bits,
;       (dx) = dword high 16 bits,
;       (cx) = divisor
; retu: (dx) = answer high 16 bits
;       (ax) = answer low 16 bits
;       (cx) = remainder
divdw:
    push bx
    push ax
    mov ax, dx
    sub dx, dx ; H/N
    div cx ; (ax) = int(H/N), (dx) = rem(H/N)
    mov bx, ax
    pop ax ; (dx):(ax) = rem(H/N) * 65536 + L
    div cx ; (ax) = int(rem(H/N) * 65536 + L), (dx) = rem(rem(H/N) * 65536 + L)
    mov cx, dx ; cx remainder
    mov dx, bx ; dx answer high 16 bits, ax already has the answer low 16 bits
    pop bx ; balance stack
    ret
code ends
end example
