/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
   while ((iChar = getchar()) != EOF)
   {
      lCharCount++;
    //
      if (isspace(iChar))
      {
        // 
         if (iInWord)
         {
            lWordCount++;
            iInWord = FALSE;
         }
      }
      else
      {
        /*inword tracks if we just in a word and the boolean is set to true if we*/
         if (! iInWord)
            iInWord = TRUE;
      }

      if (iChar == '\n')
         lLineCount++;
   }

   if (iInWord)
      lWordCount++;

   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}


/*this is theflattened c im just using the top code as reference*/


int main(void)
{
   while ((iChar = getchar()) != EOF)
   {
      lCharCount++;
/*if a space is detected we either evaluate if we shoudl chnage the inword boolean to false after we increase the word count or if we are in a word set the boolean to true. 

*/ 
      if (isspace(iChar))
      {
         if (iInWord)
         {
            lWordCount++;
            iInWord = FALSE;
         }
      }
      else
      {
         if (! iInWord)
            iInWord = TRUE;
      }
/*increase the newline count if the new line charcter is detected*/
newlineLoop:
      if (!(iChar == '\n')) goto newlineLoopEnd;
         lLineCount++;
         goto newlineLoop;
newlineLoopEnd:
   }
/*this is for the last word if you dont add a space after 
the last word */
wordLoop:
   if (!iInWord) goto wordLoopEnd;
      lWordCount++;
      goto wordLoop;
wordLoopEnd:

   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
