/* printf() mimic that supports %c and %d, works with tc 2.0 */
#define Vram ((char far *)0xb8000000+160*10+7*2) /* video ram, row 10, column 7 */

void mprintf(char *format, ...);

main() {
    mprintf("%d: %che %cltimate %cnswer of %cife, the %cniverse, and %cverything.", 42, 'T', 'U', 'A', 'L', 'U', 'E');
}

void mprintf(char *format, ...) {
    char far *cursor = Vram;
    char *pformat = format;
    /* 
        why _BP+6? 
        _BP as stack top of parameters,
        _BP+0 is _BP that before mov bp, sp instruction was executed
        _BP+2 is efficient address of main()
        _BP+4 is parameter format
        _BP+6 is base address of values that will be inserted to the format string to replace corresponding specifiers
    */
    int *which = (int *)(_BP+6);
    int i;
    if (format == 0) { return; } /* NULL is given */
    while(*pformat != 0) {
        if (*pformat == '%') {
            if (*(pformat+1) == 0) {
                /* format string end with %, print % and return */
                *cursor = '%';
                return;
            } else if (*(pformat+1) == 'd') {
                /* print one integer */
                pformat++; /* do not print specifier d */
                i = *which;
                while(i) {
                    /*
                        get one least significant digit at a time,
                        and +0x30 to convert it to ascii,
                        then mimic PUSH instruction
                        eg. for integer 123
                        ------- <- stack top
                        | '1' |
                        -------
                        | '2' |
                        -------
                        | '3' |
                        -------
                    */
                    _SP -= 2;
                    *(int *)(_SP) = i%10+0x30;
                    i /= 10;
                }
                i = *which;
                while(i) {
                    /*
                        mimic POP instruction,
                        in order to get the correct print order
                    */
                    *cursor = *(int *)(_SP);
                    _SP += 2;
                    cursor += 2; /* cursor will move forward extra once */
                    i /= 10;
                }
                which++;
                cursor -= 2; /* cursor backward once */
            } else if (*(pformat+1) == 'c') {
                /* print one character */
                pformat++; /* do not print specifier c */
                *cursor = *which++;
            } else {
                /* unknown specifier, print as it is */
                *cursor = '%';
            }
        } else {
            /* print normal character */
            *cursor = *pformat;
            
        }
        cursor += 2; /* display cursor move forward once */
        pformat++; /* read next character */
    }
}
