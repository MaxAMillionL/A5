//----------------------------------------------------------------------
// bigintadd.s
// Author: Maxwell Lloyd and Venus Dinari 
//----------------------------------------------------------------------

.section .rodata

//----------------------------------------------------------------------

.section .bss

//----------------------------------------------------------------------

.section .data

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
        LENGTH1 .req x19
        LENGTH2 .req x20

        // local variables
        LARGER  .req x21

larger:
{
   long lLarger;
   if(lLength1 <= lLength2) goto len2large;
      lLarger = lLength1;
      goto len1large;
   len2large:
      lLarger = lLength2;
   len1large:
   return lLarger;
}

//----------------------------------------------------------------------
// Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
// distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
// overflow occurred, and 1 (TRUE) otherwise.
// int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
//----------------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 64
         
        // parameters
        ADDEND1 .req x19
        ADDEND2 .req x20
        OSUM    .req x21

        // local variables
        CARRY   .req x22
        lSUM    .req x23
        INDEX   .req x24
        lSUMLENGTH .req x25
add:
{
   unsigned long ulCarry;
   unsigned long ulSum;
   long lIndex;
   long lSumLength;

   /* Determine the larger length. */
   lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);

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
