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

        // parameters stack offsets
        .equ    LLENGTH1, 8
        .equ    LLENGTH2, 16

        // local variables stack offsets
        .equ    LLARGER, 24
        .global BigInt_larger

BigInt_larger:
        // save parameters
        sub sp, sp, LARGER_STACK_BYTECOUNT
        str x30, [sp]             // store return pointer
        str x0,  [sp, LLENGTH1]   // store lLength1
        str x1,  [sp, LLENGTH2]   // store lLength2

        // if(lLength1 <= lLength2) goto len2large
        ldr     x0, [sp, LLENGTH1]
        ldr     x1, [sp, LLENGTH2]
        cmp     x0, x1
        ble     len2large

        // lLarger = lLength1;
        ldr     x0, [sp, LLENGTH1]
        str     x0, [sp, LLARGER] 

        // goto len1large;
        b       len1large;
        
len2large:

        // lLarger = lLength2;
        ldr     x0, [sp, LLENGTH2]
        str     x0, [sp, LLARGER] 

len1large:

        // return lLarger;
        ldr     x0, [sp, LLARGER]
        ldr     x30, [sp]
        add     sp, sp, LARGER_STACK_BYTECOUNT
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

        // constants
        .equ    TRUE, 1
        .equ    FALSE, 0
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8
        .equ    SIZE_OF_LONG, 8
        .equ    MAX_DIGITS, 32768
        
         
        // parameters
        .equ    OADDEND1, 8
        .equ    OADDEND2, 16
        .equ    OSUM, 24

        // local variables
        .equ    ULCARRY, 32
        .equ    ULSUM, 40
        .equ    LINDEX, 48
        .equ    LSUMLENGTH, 56
        .global BigInt_add

BigInt_add:
        // save parameters
        sub sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]              // store return pointer
        str     x0, [sp, OADDEND1]     // store oAddend1
        str     x1, [sp, OADDEND2]     // store oAddend2
        str     x2, [sp, OSUM]         // store oSum

        // Determine the larger length
        // lSumLength = BigInt_larger
        // (oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [sp, OADDEND1]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, OADDEND2]
        ldr     x1, [x1, LLENGTH]
        bl      BigInt_larger
        str     x0, [sp, LSUMLENGTH]

        // if (oSum->lLength <= lSumLength) goto noClear;
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        ble     noClear

        // memset(oSum->aulDigits, 0, 
        // MAX_DIGITS * sizeof(unsigned long));
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        mov     x1, 0
        mov     x3, SIZE_OF_LONG
        mov     x4, MAX_DIGITS
        mul     x2, x4, x3
        bl      memset

noClear:

        // ulCarry = 0;
        mov     x0, 0
        str     x0, [sp, ULCARRY]

        // lIndex = 0;
        mov     x0, 0
        str     x0, [sp, LINDEX]

loop:

        // if(lIndex >= lSumLength) goto endloop;
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0,  x1
        bge     endloop

        //ulSum = ulCarry;
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]
        
        // ulCarry = 0;
        mov     x0, 0
        str     x0, [sp, ULCARRY]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, OADDEND1]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        add     x2, x0, x1
        str     x2, [sp, ULSUM]

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto nooverflow1;
        ldr     x0, [sp, OADDEND1]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        cmp     x1, x0
        bhs     nooverflow1

        // ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]

nooverflow1:

        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, OADDEND2]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        add     x2, x0, x1
        str     x2, [sp, ULSUM]

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto nooverflow2;
        ldr     x0, [sp, OADDEND2]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        cmp     x1, x0 
        bhs     nooverflow2

        //  ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]

nooverflow2:

        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        lsl     x1, x1, 3
        add     x0, x0, x1
        ldr     x2, [sp, ULSUM]
        str     x2, [x0]
        
        // lIndex++;
        ldr     x0, [sp, LINDEX]
        add     x0, x0, 1
        str     x0, [sp, LINDEX]

        // goto loop;
        b       loop
   
endloop:

        // if (ulCarry != 1) goto nocarryout;
        ldr     x0, [sp, ULCARRY]
        cmp     x0, 1
        bne     nocarryout
   
        // if (lSumLength != MAX_DIGITS) goto notmaxdigit;
        ldr     x0, [sp, LSUMLENGTH]
        cmp     x0,  MAX_DIGITS
        bne     notmaxdigit

        // return FALSE;
        mov     x0, FALSE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

notmaxdigit:

        // oSum->aulDigits[lSumLength] = 1;
        ldr    x0, [sp, OSUM]
        add    x0, x0, AULDIGITS
        ldr    x1, [sp, LSUMLENGTH]
        lsl    x1, x1, 3
        add    x0, x0, x1
        mov    x2, 1
        str    x2, [x0]

        // lSumLength++;
        ldr     x0, [sp, LSUMLENGTH]
        add     x0, x0, 1
        str     x0, [sp, LSUMLENGTH]
   
nocarryout:

        // oSum->lLength = lSumLength;
        ldr    x0, [sp, OSUM]
        add    x0, x0, LLENGTH
        ldr    x1, [sp, LSUMLENGTH]
        str    x1, [x0]
      
        // return TRUE;
        mov     x0, TRUE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
        
        .size   BigInt_add, (. - BigInt_add)
