/*===========================================================================

  main/main.c 

  Copyright (c)2023 Kevin Boone, GPL v3.0

============================================================================*/
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#ifdef HAVE_READLINE
#include <readline/readline.h>
#include <readline/history.h>
#endif
#include <main/defs.h>
#include <config.h>

/*============================================================================
  readline_with_prompt 
============================================================================*/
static char *readline_with_prompt (const char *prompt)
  {
#ifdef HAVE_READLINE
  return readline (prompt);
#else
  printf (prompt);
  fflush (stdout);
  return readline_no_prompt ();
#endif
  }

/*============================================================================
  readline_no_prompt 
============================================================================*/
static char *readline_no_prompt (void)
  {
  char s[80];
  if (fgets (s, sizeof (s) - 2, stdin) == NULL)
      return NULL;
  char *buff = malloc (1);
  buff[0] = 0;
  BOOL done = FALSE;
  do
      {
      buff = realloc (buff, strlen(s) + 2);
      strcat (buff, s);

      if (buff[strlen(buff)- 1] == '\n')
        {
        buff[strlen(buff) - 1] = 0;
        done = TRUE;
        }

      if (!done)
        if (fgets (s, sizeof (s) - 2, stdin) == NULL)
          done = TRUE;
      } while (!done);
  return buff;
  }

/*===========================================================================
  my_readline 
============================================================================*/
char *my_readline (const char *prompt)
  {
  if (isatty (0))
    return readline_with_prompt (prompt);
  else
    return readline_no_prompt ();
  }

/*===========================================================================
  my_add_history
============================================================================*/
void my_add_history (const char *input)
  {
  add_history (input);
  }

/*===========================================================================
  my_read_history
============================================================================*/
void my_read_history (void)
  {
  char *s;
  asprintf (&s, "%s/%s", getenv("HOME"), HISTORY_FILE);
  read_history (s);
  free (s);
  }

/*===========================================================================
  my_write_history
============================================================================*/
void my_write_history (void)
  {
  char *s;
  asprintf (&s, "%s/%s", getenv("HOME"), HISTORY_FILE);
  write_history (s);
  free (s);
  }


