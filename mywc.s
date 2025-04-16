//----------------------------------------------------------------------
// mywc.s
// Author: Maxwell Lloyd and Venus Dinari 
//----------------------------------------------------------------------

.section .rodata

dataStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------
        .section .bss

lLineCount:
        .skip   8
lWordCount:
        .skip   8
lCharCount:
        .skip   8
iChar:
        .skip   4
//----------------------------------------------------------------------

.section .data
iInWord:
        .word  0

//----------------------------------------------------------------------
        .section .text
//----------------------------------------------------------------------
// Write to stdout counts of how many lines, words, and characters
// are in stdin. A word is a sequence of non-whitespace characters.
// Whitespace is defined by the isspace() function. Return 0. 
//----------------------------------------------------------------------

        // Must be a multiple of 16 and we have teh return address of main whihc is 8 bytes but rounds up to 16 
        .equ    MAIN_STACK_BYTECOUNT, 16
        .equ    TRUE, 1
        .equ    FALSE, 0
        .equ    EOF, -1

        .global main

main:
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]
loop1:
        // if ((iChar = getchar()) == EOF) goto endloop1;
        bl      getchar
        cmp     w0, EOF
        beq     endloop1
        adr     x1, iChar
        str     x0, [x1]

        // lCharCount++;
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        
        // if (!(isspace(iChar))) goto else1;
        adr     x0, iChar
        ldr     x0, [x0]
        bl      isspace
        cmp     x0, FALSE
        beq     else1

        // if (!iInWord) goto endinWord;
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     endinWord

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // iInWord = FALSE;
        mov     x0, FALSE
        adr     x1, iInWord
        str     x0, [x1]

endinWord:
        // goto endelse1
        b       endelse1

else1:

        // if (iInWord) goto endnotinWord;
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, TRUE
        beq     endnotinWord

        // iInWord = TRUE;
        mov     x0, TRUE
        adr     x1, iInWord
        str     x0, [x1]

endnotinWord:

endelse1:

        // if (!(iChar == '\n')) goto newLineEnd;
        adr     x0, iChar
        ldr     x0, [x0]
        cmp     x0, '\n'
        bne     newLineEnd

        // lLineCount++;
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

newLineEnd:

        // goto loop1
        b       loop1

endloop1:

        // if (!iInWord) goto wordEnd;
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     wordEnd

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

wordEnd:

        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, dataStr
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf

        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
