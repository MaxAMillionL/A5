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
        str x19, [sp, LLENGTH1]   // store lLength1
        str x20, [sp, LLENGTH2]   // store lLength2
        str x21, [sp, LLARGER]    // store lLarger

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
         
        // parameters
        OADDEND1 .req x19
        OADDEND2 .req x20
        OSUM     .req x21

        // local variables
        CARRY   .req x22
        ULSUM   .req x23
        LINDEX  .req x24
        LSUMLENGTH .req x25
BigInt_add:
        // save all local variables and parameters
        sub sp, sp, ADD_STACK_BYTECOUNT
        str x30, [sp]       // store return pointer
        str x19, [sp, 8]    // store oAddend1
        str x20, [sp, 16]   // store oAddend1
        str x21, [sp, 24]   // store oSum
        str x22, [sp, 32]   // store carry
        str x23, [sp, 40]   // store ulSum
        str x24, [sp, 48]   // store lIndex
        str x25, [sp, 56]   // store lSumLength
        mov OADDEND1, x0    
        mov OADDEND2, x1
        mov OSUM, x2

        // Determine the larger length
        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        mov x0, OADDEND1
        mov x1, OADDEND2
        bl  larger
        mov LSUMLENGTH, x0

   /* Clear oSum's array if necessary. */
   if (oSum->lLength <= lSumLength) goto noClear;
      memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
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
