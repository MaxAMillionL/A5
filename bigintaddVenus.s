/*--------------------------------------------------------------------*/
/* bigintadd.c                                                        */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include "bigint.h"
#include "bigintprivate.h"
#include <string.h>
#include <assert.h>

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

/* Return the larger of lLength1 and lLength2. */
/* STACK_SIZE = 8 + 8 + 8 (longs) + 8 (return addr) = 32 */
static long BigInt_larger(long lLength1, long lLength2)
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

/*--------------------------------------------------------------------*/

/* Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
   distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
   overflow occurred, and 1 (TRUE) otherwise. */

   /* STACK_SIZE = 8 + 8 + 8 (pointers) + 8 + 8 + 8 + 8 (longs) + 8 
   (return addr) = 64*/
int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
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
   
   //ulCarry = 0;
        mov     x0, 0
        str     x0, [sp, ULCARRY]


   //lIndex = 0;
         mov     x0, 0
        str     x0, [sp, LINDEX]
 loop:

   //if(lIndex >= lSumLength) goto endloop;!!!!!!
       ldr     x0, [sp, LINDEX]
       ldr     x1, [sp, ISUMLENGTH]
       cmp     x0,  x1
       bge     endloop




      //ulSum = ulCarry;
       ldr     x0, [sp, ULCARRY]
        str    x0, [sp, ULSUM]
        

     // ulCarry = 0;
      mov     x0, 0
      str     x0, [sp, ULCARRY ]

      ////ulSum += oAddend1->aulDigits[lIndex];



      if (ulSum >= oAddend1->aulDigits[lIndex])goto nooverflow1;
      /* Check for overflow. */

       //  ulCarry = 1;
      mov     x0, 1
      str     x0, [sp, ULCARRY ]

   nooverflow1:


      ulSum += oAddend2->aulDigits[lIndex];

      if (ulSum >= oAddend2->aulDigits[lIndex]) goto nooverflow2;



      /* Check for overflow. */
      //  ulCarry = 1;
      mov     x0, 1
      str     x0, [sp, ULCARRY ]

   nooverflow2:

      oSum->aulDigits[lIndex] = ulSum;


     // lIndex++;
        adr     x0, lIndex
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

   goto loop;
   
   endloop:

   /* Check for a carry out of the last "column" of the addition. */


  // if (ulCarry != 1) goto nocarryout;

        adr     x0, ulCarry
        ldr     w0, [x0]
        cmp     w0, 1
        bne     nocarryout


   
   //  if (lSumLength != MAX_DIGITS) goto notmaxdigit;

        ldr     x0, [sp, LSUMLENGTH]
       cmp     x0,  MAX_DIGITS
       bne     notmaxdigit

         return FALSE;
      oSum->aulDigits[lSumLength] = 1;

    //  lSumLength++;
        ldr     x0, [sp, LSUMLENGTH]
        add     x1, x1, 1
        str     x1, x0

      notmaxdigit:
   
nocarryout:
   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;
}
