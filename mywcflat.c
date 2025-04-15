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


/* this is theflattened c im just using the top code as reference */





int main(void){

loop1:
if ((iChar = getchar()) == EOF) goto endloop1;
   lCharCount++;
   /* if a space is detected we either evaluate if we shoudl chnage the inword boolean to false after we increase the word count or if we are in a word set the boolean to true. */ 
   if (!(isspace(iChar))) goto else1;

      /* if the inword boolean was previously set to true as in we were ina  word then increase teh word count and then set inwrod to false since we detected a space as the car */
      if (!iInWord) goto endinWord;
         lWordCount++;
         iInWord = FALSE;     
      endinWord:
   goto endelse1;

   else1:
      /* if the inword boolean was previously set to FALSE and a new charcter that isnta spcae or a newline is detected then we are in a new word so set the inword boolean to true. */
      if (iInWord) goto endnotinWord;
            iInWord = TRUE;  
      endnotinWord:
   endelse1:
   /* increase the newline count if the new line charcter is detected */

   if (!(iChar == '\n')) goto newlineEnd;
      lLineCount++;
   newlineEnd:

   goto loop1;

endloop1:
/* this is for the last word if you dont add a space after 
the last word */
if (!iInWord) goto wordEnd;
   lWordCount++;
wordEnd:


printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
return 0;
}