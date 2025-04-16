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

//------------------------------------------------------------------------

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */
//--------------------------------------------------------------



        // Must be a multiple of 16 and we have teh return address of main whihc is 8 bytes but rounds up to 16 
        .equ    MAIN_STACK_BYTECOUNT, 16
         .equ    TRUE, 1
         .equ    FALSE, 0



        .global main

main:
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]
loop1:
        // if ((iChar = getchar()) == EOF) goto endloop1;
        bl      getchar
        cmp     x0, EOF
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
        adr     x0, iChar
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     else1


        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // scanf("%ld", &l1)
        adr     x0, scanfFormatStr
        adr     x1, l1
        bl      scanf

        // printf("Enter an integer: ")
        adr     x0, promptStr
        bl      printf

        // scanf("%ld", &l2)
        adr     x0, scanfFormatStr
        adr     x1, l2
        bl      scanf

        // gcd()
        bl      gcd

        // printf("The gcd is %ld\n", lGcd)
        adr     x0, printfFormatStr
        adr     x1, lGcd
        ldr     x1, [x1]
        bl      printf

        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)