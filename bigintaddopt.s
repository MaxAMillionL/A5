//----------------------------------------------------------------------
// bigintadd.s
// Author: Maxwell Lloyd and Venus Dinari 
//----------------------------------------------------------------------
        
.section .text

//----------------------------------------------------------------------
// Deals with very large numbers not able to be handles by c normally.
// Made with the purpose to translate flat c for a fibinacci sequence.
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Return the larger of lLength1 and lLength2.
// static long BigInt_larger(long lLength1, long lLength2)
//----------------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32

        // parameters
        LLENGTH1 .req x19
        LLENGTH2 .req x20

        // local variables
        LLARGER  .req x21

        .global BigInt_larger

BigInt_larger:

        // save all local variables and parameters
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]          // store return pointer
        str     x19, [sp, 8]       // store lLength1
        str     x20, [sp, 16]      // store lLength2
        str     x21, [sp, 24]      // store lLarger
        mov     LLENGTH1, x0       
        mov     LLENGTH2, x1

        // if(lLength1 <= lLength2) goto len2large
        cmp     LLENGTH1, LLENGTH2
        ble     len2large

        // lLarger = lLength1;
        mov     LLARGER, LLENGTH1

        // goto len1large;
        b       len1large
        
len2large:

        // lLarger = lLength2;
        mov LLARGER, LLENGTH2

len1large:

        // return lLarger;
        ldr x30, [sp]
        ldr x19, [sp, 8]
        ldr x20, [sp, 16]
        ldr x21, [sp, 24]
        add sp, sp, LARGER_STACK_BYTECOUNT
        ret

        .size   BigInt_larger, (. - BigInt_larger)


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
        .equ    MAX_DIGITS, 32768
         
        // parameters
        OADDEND1 .req x19
        OADDEND2 .req x20
        OSUM     .req x21

        // local variables
        ULCARRY   .req x22
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
        bl      larger
        mov     LSUMLENGTH, x0

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
        mul     x2, MAX_DIGITS, SIZE_OF_LONG
        bl      memset

noClear:

        // ulCarry = 0;
        mov     ULCARRY, 0

        // lIndex = 0;
        mov     LINDEX, 0

 loop:

        // if(lIndex >= lSumLength) goto endloop;
        cmp     LINDEX, LSUMLENGTH
        bge     endloop

        // ulSum = ulCarry;
        mov     ULSUM, ULCARRY
        
        // ulCarry = 0;
        mov     ULCARRY, 0

        // ulSum += oAddend1->aulDigits[lIndex];
        mov     x0, OADDEND1
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        add     ULSUM, ULSUM, x0


        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto nooverflow1;
        mov     x0, OADDEND1
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        mov     x1, ULSUM
        cmp     x1, x0
        bhs     nooverflow1

        // ulCarry = 1;
        mov     ULSUM, 1

nooverflow1:

        // ulSum += oAddend2->aulDigits[lIndex];
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        add     ULSUM, ULSUM, x0

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto nooverflow2;
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        mov     x1, ULSUM
        cmp     x1, x0
        bhs     nooverflow2

        //  ulCarry = 1;
        mov     ULCARRY, 1

nooverflow2:

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

        // goto loop;
        b       loop
   
endloop:

        // if (ulCarry != 1) goto nocarryout;
        cmp     ULCARRY, 1
        bne     nocarryout
   
        // if (lSumLength != MAX_DIGITS) goto notmaxdigit;
        cmp     LSUMLENGTH,  MAX_DIGITS
        bne     notmaxdigit

        // return FALSE;
        ldr     x0, FALSE
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
        mov     x0, LSUMLENGTH
        add     x1, x1, 1
        str     x1, x0
   
nocarryout:

        // oSum->lLength = lSumLength;
        mov    x0, OSUM
        add    x0, x0, LLENGTH
        mov    x1, LSUMLENGTH
        str    x1, [x0]

        // return TRUE;
        ldr     x0, FALSE
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