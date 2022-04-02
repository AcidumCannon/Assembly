; course project 2
assume cs:code

code segment
program:
    jmp mainscreen
    str0 db '0) reset pc'
    str1 db '1) start system'
    str2 db '2) clock'
    str3 db '3) set clock'
    strlen dw str1-str0, str2-str1, str3-str2, strlen-str3
    stridx dw str0, str1, str2, str3
    year db 'ye/'
    month db 'mo/'
    day db 'da '
    hour db 'ho:'
    minute db 'mi:'
    second db 'se'
    timedate dw year, month, day, hour, minute, second
    timedateaddr db 9, 8, 7, 4, 2, 0 ; corresponding date and time address in CMOS RAM
    clockloopflag db 0 ; {0=exit loop, 1=enter loop}
    clockstrcolor db 07h ; clock display characters' default appearance={foreground=white, background=black}
    int9addr dw 0, 0 ; to save original interrupt vector 9
    setclockstr0 db 'Set date and time, Enter=confirm, Esc=cancel.'
    setclockstr1 db 'Format requirement: yymmddhhmmss.'
    setclockstrlen dw setclockstr1-setclockstr0, setclockstrlen-setclockstr1
    setclockstridx dw setclockstr0, setclockstr1
    clockstack db 16 dup (0) ; stack to store new date and time user input
    clockstacktop dw 0 ; stack top pointer
    mainscreenentry dw resetpc, startsystem, clockcall, setclockcall
    setclockstackentry dw setclockstackpush, setclockstackpop, setclockstackprint

clearscreen:
    push ax
    push bx
    push cx
    push dx
    mov ax, 0600h ; (ah)=06h init screen or rolling up, (al)=0 blank screen
    mov bh, 07h ; (bh)=07h default appearance
    sub cx, cx ; (ch)=upper-left row, (cl)=upper-left column
    mov dx, 184fh; (dh)=lower-right row, (dl)=lower-right column
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    ret

printmainscreen:
    push ax
    push bx
    push cx
    push dx
    push es
    push bp
    mov ax, cs
    mov es, ax
    mov ax, 1301h ; (ah)=13h print string, (al)=01h, cursor move, appearance=(bl)
    mov dx, 0a22h ; 10 row, 34 column
    sub bx, bx
printmainscreenloop:
    cmp bx, 8
    jae printmainscreenret
    mov bp, stridx[bx] ; (es:bp)=cs:(stridx[bx])=cs:strX, X={0, 1, 2, 3}
    mov cx, strlen[bx] ; length of cs:strX, X={0, 1, 2, 3}
    push bx
    mov bx, 0007h ; (bh)=0 first page, (bl)=07h default appearance
    int 10h
    pop bx
    add bx, 2
    inc dh
    jmp printmainscreenloop
printmainscreenret:
    pop bp
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

resetpc:
    mov ax, 0ffffh
    push ax ; system stack top = ffff, ...
    mov ax, 0
    push ax ; system stack top = 0, ffff, ...
    retf ; set (cs:ip) = ffff:0 where after power up the first instruction to be executed, which is a jump instruction to let the BIOS initialize

startsystem:
    call clearscreen
    mov ah, 2
    sub bh, bh
    sub dx, dx
    int 10h ; set cursor to row 0, column 0
    sub ax, ax
    mov es, ax
    mov bx, 7c00h ; (es:bx)=0:7c00h
    mov ax, 0201h ; read 1 sector
    mov cx, 0001h ; cylinder 0, sector 1
    mov dx, 0080h ; head 0, drive C
    int 13h ; copy drive C MBR to 0:7c00h, where system will execute instructions there
    sub ax, ax
    push ax ; system stack top = 0, ...
    mov ax, 7c00h
    push ax ; system stack top = 7c00, 0, ...
    retf ; set (cs:ip) = 0:7c00

mainscreen:
    call clearscreen
    call printmainscreen
mainscreenloop:
    sub ah, ah
    int 16h
    sub al, 30h ; convert ascii to hex,'0'~'9' -30h = 0~9
    sub bx, bx
    mov bl, al
    add bx, bx
    jmp word ptr mainscreenentry[bx]
    jmp mainscreenloop

setclockcall:
    call setclock
    jmp mainscreen

clockcall:
    call clock
    mov clockstrcolor, 07h ; restore clock display characters' appearance to default={foreground=white, background=black}
    jmp mainscreen

clock:
    call clearscreen
    mov clockloopflag, 1 ; enter loop flag
    push ax
    push es
    sub ax, ax
    mov es, ax
    mov ax, es:[9*4+2]
    mov int9addr[2], ax
    mov ax, es:[9*4]
    mov int9addr[0], ax ; store original interrupt 9 vector provided by BIOS
    cli ; do NOT respond to maskable interrupt (eg. keyboard)
    mov word ptr es:[9*4], offset clockint9
    ; since new interrupt 9 vector is not set yet, you will not want to respond maskable interrupt here (eg. keyboard inputs)
    mov word ptr es:[9*4+2], cs
    sti ; new interrupt 9 vector is set, we can respond to maskable interrupt now
    pop es
    pop ax
clockloop:
    call getclock
    call printclock
    cmp clockloopflag, 1
    jne clockret ; clockloopflag=0, exit loop
    jmp clockloop
clockret:
    push ax
    push es
    sub ax, ax
    mov es, ax
    cli
    mov ax, int9addr[0]
    mov word ptr es:[9*4], ax
    mov ax, int9addr[2]
    mov word ptr es:[9*4+2], ax ; restore original interrupt 9 vector provided by BIOS
    sti
    pop es
    pop ax
    ret

getclock:
    push bx
    push si
    push cx
    push ax
    lea bx, timedateaddr ; lea means load effective address, since timedateaddr is a data label, but we only want address not the content of address
    lea si, timedate
    mov cx, 6
getclockloop:
    push cx
    mov al, cs:[bx] ; set CMOS RAM unit that will be accessed
    out 70h, al ; select unit
    in al, 71h ; read from unit
    mov ah, al ; copy al to ah, suppose we have BCD(26) = 0010 0110, (ah) = 0010 0110, (al) = 0010 0110
    mov cl, 4
    shr ah, cl ; (ah) = 0000 0010, (al) = 0010 0110
    and al, 00001111b ; (ah) = 0000 0010, (al) = 0000 0110
    add ah, 30h ; (ah) = 32h = '2'
    add al, 30h ; (al) = 36h = '6'
    mov di, cs:[si]
    mov byte ptr cs:[di], ah ; since '26' is what we want to print, and lower address will be print first,
    mov byte ptr cs:[di+1], al ; (ah) should be first to print out, thus lower address
    inc bx
    add si, 2
    pop cx
    loop getclockloop
    pop ax
    pop cx
    pop si
    pop bx
    ret

printclock:
    push ax
    push bx
    push cx
    push dx
    push es
    push bp
    mov ax, cs
    mov es, ax
    lea bp, year
    mov ax, 1301h ; (ah)=13h print string, (al)=01h, cursor move, appearance=(bl)
    mov bl, clockstrcolor ; (bl)=appearance
    sub bh, bh ; (bh)=0 first page
    mov cx, timedate-year
    mov dx, 0a22h ; 10 row, 34 column
    int 10h
    pop bp
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

clockint9:
    push ax
    push es
    push bx
    push cx
    in al, 60h ; read ascii of key just pressed
    pushf
    call dword ptr int9addr ; mimic int 9
    cmp al, 01h ; Esc pressed
    je clockesc
    cmp al, 3bh ; F1 pressed
    je clockf1
    jmp clockint9ret
clockesc:
    mov clockloopflag, 0 ; Esc pressed, exit loop, clockloopflag=0
    jmp clockint9ret
clockf1:
    inc clockstrcolor ; F1 pressed, change appearance
    jmp clockint9ret    
clockint9ret:
    pop cx
    pop bx
    pop es
    pop ax
    iret

printsetclock:
    push ax
    push bx
    push cx
    push dx
    push es
    push bp
    mov ax, cs
    mov es, ax
    mov ax, 1301h ; (ah)=13h print string, (al)=01h, cursor move, appearance=(bl)
    mov dx, 0a14h ; 10 row, 20 column
    sub bx, bx
printsetclockloop:
    cmp bx, 4
    jae printsetclockret
    mov bp, setclockstridx[bx] ; (es:bp)=cs:(setclockstridx[bx])=cs:setclockstrX, X={0, 1}
    mov cx, setclockstrlen[bx] ; length of cs:setclockstrX, X={0, 1}
    push bx
    mov bx, 0007h ; (bh)=0 first page, (bl)=07h default appearance
    int 10h
    pop bx
    add bx, 2
    inc dh
    jmp printsetclockloop
printsetclockret:
    pop bp
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

setclock:
    call clearscreen
    call printsetclock
    push ax
    push dx
    mov dx, 0c28h ; 12 row, 40 column
    push bx
    mov ah, 02h ; set cursor
    mov bx, 0007h ; (bh)=0 first page
    int 10h
    pop bx
setclocknext:
    sub ah, ah ; (ah)=0
    int 16h ; read keyboard input buffer
    cmp al, '9'
    ja setclocknotdigit ; ascii input > 9, non digit
    cmp al, '0'
    jb setclocknotdigit ; ascii input < 0, non digit
    cmp clockstacktop, 12 ; clockstack is full
    jae setclocknext ; do not respond to ascii input 0~9, only respond to non digit(enter, esc, backspace)
    ; clockstack not full and input ascii is 0~9, execute the following
    sub ah, ah ; (ah)=0 setclockstack push
    call setclockstack
    mov ah, 2 ; (ah)=2 setclockstack print
    call setclockstack
    jmp setclocknext
setclocknotdigit:
    cmp ah, 0eh ; Backspace
    je setclockbackspace
    cmp ah, 1ch ; Enter
    je setclockenter
    cmp ah, 01h ; Esc
    je setclockesc
    jmp setclocknext
setclockbackspace:
    mov ah, 1 ; (ah)=1 setclockstack pop
    call setclockstack
    mov ah, 2 ; (ah)=2 setclockstack print
    call setclockstack
    jmp setclocknext
setclockenter:
    cmp clockstacktop, 12 ; clockstack is not full, do not respond to enter
    jb setclocknext
    push cx
    mov cl, 4
    sub bx, bx
setclockenterloop:
    cmp bx, 6
    jae setclockenterret
    push bx
    add bx, bx
    mov ax, word ptr clockstack[bx] ; clockstack ascii time, suppose we have ascii '26', then (ah) = 36h = '6', (al) = 32h = '2'
    pop bx
    xchg ah, al ; display order is big-endian, so exchange to be little-endian, (ah) = 32h = '2', (al) = 36h = '6'
    sub ah, 30h ; ascii to hex, (ah) = 02h
    sub al, 30h ; ascii to hex, (al) = 06h
    shl ah, cl ; left shift 4 times, (ah) = 20h
    add al, ah ; (al) = 26h
    mov ah, al ; (ah) = 26h
    mov al, timedateaddr[bx] ; set CMOS RAM unit that will be accessed
    out 70h, al ; select unit
    mov al, ah ; (al) = 26h, to be written
    out 71h, al ; write to unit
    inc bx
    jmp setclockenterloop
setclockenterret:
    mov clockstacktop, 0
    pop cx
    pop dx
    pop ax
    ret
setclockesc:
    mov clockstacktop, 0
    pop dx
    pop ax
    ret

; (ah) = {0=push, 1=pop, 2=print}
; for push and pop, (al)=character
; for print, (dh)=row, (dl)=column
setclockstack:
    push bx
    push ax
    push dx
    push cx
    push si
    cmp ah, 2
    ja setclockstackret
    sub bx, bx
    mov bl, ah
    add bx, bx
    jmp word ptr setclockstackentry[bx]
setclockstackpush:
    mov bx, clockstacktop
    mov clockstack[bx], al ; push character first
    inc clockstacktop ; stack top pointer increment
    jmp setclockstackret
setclockstackpop:
    cmp clockstacktop, 0
    je setclockstackret
    dec clockstacktop ; stack top pointer decrement
    mov bx, clockstacktop ; pop character
    mov al, clockstack[bx] ; (al) = character popped
    jmp setclockstackret
setclockstackprint:
    sub si, si
setclockstackprintloop:
    cmp si, clockstacktop
    jne setclockstackprintnonempty
    mov ah, 02h ; set cursor
    mov bx, 0007h
    int 10h
    mov ax, 0920h ; print trailing space
    mov cx, 1
    int 10h
    jmp setclockstackret
setclockstackprintnonempty:
    ; print a character in clock stack at cursor position and a following space
    mov ah, 02h ; set cursor at row and column passed in
    mov bx, 0007h
    int 10h
    mov ah, 09h ; print character at cursor position
    mov al, clockstack[si]
    mov cx, 1
    int 10h
    inc dl ; set cursor position to next column
    mov ah, 02h
    mov bx, 0007h ; set cursor
    int 10h
    mov ax, 0920h ; print space
    mov cx, 1
    int 10h
    inc si
    jmp setclockstackprintloop
setclockstackret:
    pop si
    pop cx
    pop dx
    pop ax
    pop bx
    ret

loader:
    ; load 8 sectors to memory, src sector is located at cylinder 0, head 0, sector 2
    mov ax, 3000h
    mov es, ax
    push ax
    sub bx, bx ; (es:bx) = 3000:0
    push bx
    mov ax, 0208h
    mov cx, 0002h
    sub dx, dx
    int 13h
    retf

install:
    ; copy loader and program to floopy disk
    ; since the program is beyond 512 bytes, and 1 sector = 512 bytes is not enough
    ; we need a loader < 512 bytes to be responsible for placing actual program and set (cs:ip) to the actual program
    ; in this instance (cs:ip) will be set to 3000:0
    mov ax, cs
    mov es, ax
    mov bx, offset loader ; (es:bx) = cs:(offset loader)
    mov ax, 0301h
    mov cx, 0001h
    sub dx, dx
    int 13h ; copy loader to MBR
    mov bx, offset program ; (es:bx) = cs:(offset program)
    mov ax, 0308h
    mov cx, 0002h
    int 13h ; copy program to the sectors following MBR
    mov ax, 4c00h
    int 21h

code ends
end install
