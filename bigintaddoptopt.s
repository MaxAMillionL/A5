//----------------------------------------------------------------------
// bigintaddopt.s
// Author: Maxwell Lloyd and Venus Dinari 
//----------------------------------------------------------------------
        
.section .text

//----------------------------------------------------------------------
// Deals with very large numbers not able to be handles by c normally.
// Made with the purpose to optimize flat c for a fibinacci sequence.
//----------------------------------------------------------------------


//----------------------------------------------------------------------
// Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
// distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
// overflow occurred, and 1 (TRUE) otherwise.
// int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
//----------------------------------------------------------------------

        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 64
        .equ    TRUE, 1
        .equ    FALSE, 0
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8
        .equ    SIZE_OF_LONG, 8
        .equ    MAX_DIGITS, 32768
         
        // parameters
        OADDEND1 .req x19
        OADDEND2 .req x20
        OSUM     .req x21

        // local variables
        ULSUM   .req x23
        LINDEX  .req x24
        LSUMLENGTH .req x25

        .global BigInt_add

BigInt_add:

        // save all local variables and parameters
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]       // store return pointer
        str     x19, [sp, 8]    // store oAddend1
        str     x20, [sp, 16]   // store oAddend1
        str     x21, [sp, 24]   // store oSum
        str     x22, [sp, 32]   // store carry
        str     x23, [sp, 40]   // store ulSum
        str     x24, [sp, 48]   // store lIndex
        str     x25, [sp, 56]   // store lSumLength
        mov     OADDEND1, x0    
        mov     OADDEND2, x1
        mov     OSUM, x2

        // Determine the larger length
        // lSumLength = BigInt_larger
        // (oAddend1->lLength, oAddend2->lLength);
        mov     x0, OADDEND1
        mov     x1, OADDEND2
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [x1, LLENGTH]
        cmp     x0, x1
        bgt     l1
        mov     LSUMLENGTH, x1
        b       fin
l1:
        mov     LSUMLENGTH, x0
fin:

        // if (oSum->lLength <= lSumLength) goto noClear;
        mov     x0, OSUM
        ldr     x0, [x0, LLENGTH]
        mov     x1, LSUMLENGTH
        cmp     x0, x1
        ble     noClear

        // memset(oSum->aulDigits, 0, 
        // MAX_DIGITS * sizeof(unsigned long));
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     x1, 0
        mov     x3, SIZE_OF_LONG
        mov     x4, MAX_DIGITS
        mul     x2, x4, x3
        bl      memset

noClear:
        // lIndex = 0;
        mov     LINDEX, 0

        // if(lIndex >= lSumLength) goto endloop;
        cmp     LINDEX, LSUMLENGTH
        bge     endloop

loop:

        // ulSum = c flag;
        bcs     carry
        mov     ULSUM, 0
        b       nocarry
carry:
        mov     ULSUM, 1
nocarry:

        // ulSum += oAddend1->aulDigits[lIndex];
        mov     x0, OADDEND1
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        adcs    ULSUM, ULSUM, x0

        // ulSum += oAddend2->aulDigits[lIndex];
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        adcs    ULSUM, ULSUM, x0

        // oSum->aulDigits[lIndex] = ulSum;
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        lsl     x1, x1, 3
        add     x0, x0, x1
        mov     x2, ULSUM
        str     x2, [x0]

        // lIndex++;
        add     LINDEX, LINDEX, 1

        // if(lIndex < lSumLength) goto loop;
        cmp     LINDEX, LSUMLENGTH
        blt     loop
   
endloop:

        // if (c flag != 1) goto nocarryout;
        bcc     nocarryout
   
        // if (lSumLength != MAX_DIGITS) goto notmaxdigit;
        cmp     LSUMLENGTH,  MAX_DIGITS
        bne     notmaxdigit

        // return FALSE;
        mov     x0, FALSE
        ldr     x30, [sp]
        ldr     x19, [sp, 8]    // store oAddend1
        ldr     x20, [sp, 16]   // store oAddend1
        ldr     x21, [sp, 24]   // store oSum
        ldr     x22, [sp, 32]   // store carry
        ldr     x23, [sp, 40]   // store ulSum
        ldr     x24, [sp, 48]   // store lIndex
        ldr     x25, [sp, 56]   // store lSumLength
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

notmaxdigit:

        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     x1, LSUMLENGTH
        lsl     x1, x1, 3
        add     x0, x0, x1
        mov     x2, 1
        str     x2, [x0]

        // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, 1

nocarryout:

        // oSum->lLength = lSumLength;
        mov    x0, OSUM
        add    x0, x0, LLENGTH
        mov    x1, LSUMLENGTH
        str    x1, [x0]

        // return TRUE;
        mov     x0, TRUE
        ldr     x30, [sp]
        ldr     x19, [sp, 8]    // store oAddend1
        ldr     x20, [sp, 16]   // store oAddend1
        ldr     x21, [sp, 24]   // store oSum
        ldr     x22, [sp, 32]   // store carry
        ldr     x23, [sp, 40]   // store ulSum
        ldr     x24, [sp, 48]   // store lIndex
        ldr     x25, [sp, 56]   // store lSumLength
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
