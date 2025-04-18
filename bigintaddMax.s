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

BigInt_larger:
        // save all local variables and parameters
        sub sp, sp, LARGER_STACK_BYTECOUNT
        str x30, [sp]             // store return pointer
        str x0,  [sp, LLENGTH1]   // store lLength1
        str x1,  [sp, LLENGTH2]   // store lLength2
        str x2,  [sp, LLARGER]    // store lLarger

        // if(lLength1 <= lLength2) goto len2large
        ldr     x0, [sp, LLENGTH1]
        ldr     x1, [sp, LLENGTH1]
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
        ldr x0, [sp, LLARGER]
        ldr x30 [sp]
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
         
        // parameters
        .equ    OADDEND1, 8
        .equ    OADDEND2, 16
        .equ    OSUM, 24

        // local variables
        .equ    ULCARRY, 32
        .equ    ULSUM, 40
        .equ    LINDEX, 48
        .equ    LSUMLENGTH 56
BigInt_add:
        // save all local variables and parameters
        sub sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]              // store return pointer
        str     x0, [sp, OADDEND1]     // store oAddend1
        str     x1, [sp, OADDEND2]     // store oAddend1
        str     x2, [sp, OSUM]         // store oSum
        str     x3, [sp, ULCARRY]        // store carry
        str     x4, [sp, ULSUM]        // store ulSum
        str     x5, [sp, LINDEX]       // store lIndex
        str     x6, [sp, LSUMLENGTH]   // store lSumLength

        // Determine the larger length
        // lSumLength = BigInt_larger
        // (oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [sp, OADDEND1]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, OADDEND2]
        ldr     x1, [sp, LLENGTH]
        bl      BigInt_larger
        str     x0, [sp, LSUMLENGTH]

        

   /* Clear oSum's array if necessary. */
   // if (oSum->lLength <= lSumLength) goto noClear;
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, LSUMLENGTH]
        ble     x0, x1
        str     x0, [sp, LSUMLENGTH]

   // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
   noClear:
   

















   
   /* Perform the addition. */
   ulCarry = 0;
   lIndex = 0;
   loop:
   if(lIndex >= lSumLength) goto endloop;
      ulSum = ulCarry;
      ulCarry = 0;

      ulSum += oAddend1->aulDigits[lIndex];

      if (ulSum >= oAddend1->aulDigits[lIndex])goto nooverflow1;
      /* Check for overflow. */
         ulCarry = 1;
      nooverflow1:
      ulSum += oAddend2->aulDigits[lIndex];

      if (ulSum >= oAddend2->aulDigits[lIndex]) goto nooverflow2; 
      /* Check for overflow. */
         ulCarry = 1;
      nooverflow2:

      oSum->aulDigits[lIndex] = ulSum;
      lIndex++;
     goto loop;
   
   endloop:

   /* Check for a carry out of the last "column" of the addition. */
   if (ulCarry != 1) goto nocarryout;
   
      if (lSumLength != MAX_DIGITS) goto notmaxdigit;
         return FALSE;
      oSum->aulDigits[lSumLength] = 1;
      lSumLength++;
      notmaxdigit:
   
nocarryout:
   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;
}
