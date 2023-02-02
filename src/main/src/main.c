/*===========================================================================

  main/main.c 

  Copyright (c)2023 Kevin Boone, GPL v3.0

============================================================================*/
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <main/defs.h>
#include <main/my_readline.h>
#include <main/luaintf.h>
#include <config.h>
#include <lua.h> 
#include <lualib.h> 
#include <lauxlib.h> 

#define EOFMARK "<eof>"
#define EOFMARKLEN (sizeof (EOFMARK))

/*===========================================================================
  strcmp_trimmed 
============================================================================*/
static int strcmp_trimmed (const char *s_var, const char *s_fixed) 
  {
  char *s_var_trimmed = strdup (s_var); 
  char *s = s_var_trimmed;
  char *d = s;
  do while(isspace(*s)) s++; while((*d++ = *s++)); 
  int ret = strcmp (s_fixed, s_var_trimmed);
  free (s_var_trimmed);
  return ret;
  }

/*===========================================================================
  transform_input 
============================================================================*/
static char *transform_input (const char *input) 
  {
  if (strcmp_trimmed (input, "help") == 0) return strdup ("help()");
  if (strcmp_trimmed (input, "refresh") == 0) return strdup ("refresh()");
  return strdup (input);
  }

/*===========================================================================
  eval_and_print 
============================================================================*/
static void eval_and_print (const char *input_buffer, lua_State *L, 
              const char *source, char **error)
  {
  if (!input_buffer) return;
  if (!input_buffer[0]) return;
  char *input = transform_input (input_buffer);
  BOOL report;
  char *s;
  if (input[0] == STMT_CHAR)
    {
    report = FALSE;
    s = strdup (input + 1);
    }
  else
    {
    asprintf (&s, "last=%s", input);
    report = TRUE;
    }

  if (luaL_loadbuffer (L, s, strlen (s), source))
    {
    *error = strdup (lua_tostring (L, -1));
    lua_pop (L, -1);
    }
  else
    {
    if (lua_pcall (L, 0, 0, 0))
      {
      *error = strdup (lua_tostring (L, -1));
      lua_pop (L, -1);
      }
    else
      {
      if (report)
        {
        lua_getglobal (L, "kcalc_format");
        lua_getglobal (L, "last");
        if (lua_pcall (L, 1, 0, 0))
          {
          *error = strdup (lua_tostring (L, -1));
          lua_pop (L, -1);
          }
        lua_pop (L, -1);
        }
      }
    }

  free (s);
  free (input);
  } 

/*===========================================================================
  eval_and_print 
============================================================================*/
static BOOL eval_and_print_show_error (const char *input_buffer, lua_State *L, 
              const char *source)
  {
  BOOL ret = TRUE;
  char *error = NULL;
  eval_and_print (input_buffer, L, source, &error);
  if (error)
    {
    fprintf (stderr, "%s\n", error);
    free (error);
    ret = FALSE;
    }
  return ret;
  }

/*===========================================================================
  repl 
============================================================================*/
void repl (lua_State *L)
  {
  luaintf_init_readline (L); 
  my_read_history ();
  BOOL quit = FALSE;
  while (!quit)
    {
    char *input_buffer = malloc (1);
    BOOL complete = FALSE;
    input_buffer[0] = 0;
    char *input = my_readline (PROMPT1);
    if (input)
      {
      do
        {
        if (input)
          {
          char *line_to_parse;
          int buff_len = strlen (input) + strlen (input_buffer) + 1;
          input_buffer = realloc (input_buffer, buff_len);          
          strcat (input_buffer, input);
          if (input_buffer[0] == STMT_CHAR)
            line_to_parse = strdup (input_buffer + 1);
          else 
            {
            asprintf (&line_to_parse, "return %s", input_buffer);
            }
          int status = luaL_loadbuffer (L, line_to_parse, 
                 strlen (line_to_parse), "=stdin");
          free (line_to_parse);
          if (status == LUA_ERRSYNTAX)
            {
            size_t lmsg = 0;
            const char *msg = lua_tolstring (L, -1, &lmsg);
            if (lmsg >= EOFMARKLEN && 
                 strcmp (msg + lmsg - EOFMARKLEN + 1, EOFMARK) == 0)
              {
              lua_pop (L, 1);
              }
            else
              {
              complete = TRUE;
              }
            }
          else if (status == LUA_OK)
            {
            complete = TRUE;
            }
          else
            {
            lua_pop (L, 1);
            complete = TRUE;
            }
          
          if (!complete)
            {
            int buff_len = strlen (input_buffer) + 2;
            input_buffer = realloc (input_buffer, buff_len);          
            strcat (input_buffer, "\n");
            free (input);
            if (input_buffer[0] == '!')
              input = my_readline (PROMPT2_STMT);
            else
              input = my_readline (PROMPT2_EXPR);
            }
          }
        } while (input && !complete);
      free (input);
      }
    else
      quit = TRUE;

    if (!quit)
       {
       if (strcmp_trimmed (input_buffer, QUIT_COMMAND) == 0)
         quit = TRUE;
       else
         {
         eval_and_print_show_error (input_buffer, L, "=stdin");
#ifdef HAVE_READLINE
        if (input_buffer[0])
           my_add_history (input_buffer);
#endif
         }   
       }
    free (input_buffer);
    }
  my_write_history ();
  luaintf_free_readline();
  }

/*=========================================================================
  show_usage 
=========================================================================*/
static void show_usage (const char *argv0)
  {
  printf ("Usage: %s [options] [expression]\n", argv0);
  printf ("   -i             force interactive mode\n");
  printf ("   -s {Lua file}  run a script\n");
  printf ("   -v             show version\n");
  printf ("   -w {cols}      set display width\n");
  }
  
/*=========================================================================
  show_version
=========================================================================*/
static void show_version (void)
  {
  printf ("%s version %s,\n", NAME, VERSION);
  char *system_script_dir = luaintf_get_system_script_dir();
  char *user_script_dir = luaintf_get_user_script_dir();
  printf ("System script directory: %s\n", system_script_dir);
  printf ("User script directory: %s\n", user_script_dir);
  free (system_script_dir);
  free (user_script_dir);
  printf ("copyright 2012-2023 Kevin Boone.\n");
  printf ("This is free software distributed under the\n");
  printf ("terms of the GNU Public Licence, v3.0.\n");
  }

/*===========================================================================
  do_file 
============================================================================*/
void do_file (lua_State *L, const char *filename, char **error)
  {
  char *s;
  asprintf (&s, "dofile \"%s\"", filename);
  if (luaL_loadbuffer (L, s, strlen(s), filename))
    {
    *error = strdup (lua_tostring(L, -1));
    lua_pop (L, -1);
    }
  else
    {
    if (lua_pcall (L, 0, 0, 0))
      {
      *error = strdup (lua_tostring(L, -1));
      lua_pop (L, -1);
      }
    }
  free (s);
  }
  
/*===========================================================================
  main
============================================================================*/
static BOOL do_file_show_error (lua_State *L, const char *filename)
  {
  BOOL ret = TRUE;
  char *error = NULL;
  do_file (L, filename, &error);
  if (error)
    {
    fprintf (stderr, "%s\n", error);
    free (error);
    ret = FALSE;
    }
  return ret;
  }
  
/*===========================================================================
  main
============================================================================*/
int main (int argc, char **argv)
  {
  int ret = 0;

  luaintf_init_env();
  lua_State *L = luaL_newstate();
  luaL_openlibs (L);
  luaintf_init_functions (L);

  char *error = NULL;
  luaintf_load_scripts (L, &error);
  if (error == NULL)
    {
    int opt;
    int set_width = 0;
    BOOL interactive = TRUE;
    BOOL usage = FALSE;
    BOOL version = FALSE;
    BOOL force_interactive = FALSE;

    while (((opt = getopt (argc, argv, "hivs:w:")) != -1) && (ret == 0))
      {
      switch (opt)
        {
        case 'v':
          version = TRUE;
          break;       
        case 'w':
          set_width = atoi (optarg);
          break;       
        case 'h':
          usage = TRUE;
          break;       
        case 'i':
          force_interactive = TRUE;
          break;       
        case 's':
          do_file_show_error (L, optarg);
          interactive = FALSE;
          break;       
        }
      }

    if (usage)
      {
      show_usage (argv[0]);
      ret = -1;
      }

    if (version)
      {
      show_version();
      ret = -1;
      }

    if (set_width <= 0)
      {
      if (isatty (1))
	{
	struct winsize w;
	if (ioctl (1, TIOCGWINSZ, &w) == 0)
	  {
	  luaintf_set_screen_width (L, w.ws_col); 
	  }
	else
	  luaintf_set_screen_width (L, 80); 
	}
      else
	luaintf_set_screen_width (L, -1); 
      }
    else
      luaintf_set_screen_width (L, set_width); 
 
    luaintf_refresh_module_list (L);

    if (ret == 0 && (optind < argc))
      {
      interactive = FALSE;
      char *buffer = malloc (1);
      buffer[0] = 0;
      for (int i = optind; i < argc; i++)
        {
        int newlen = strlen (buffer) + strlen (argv[i]) + 1;
        buffer = realloc (buffer, newlen); 
        strcat (buffer, argv[i]);
        }
      eval_and_print_show_error (buffer, L, "=stdin");
      free (buffer);
      }

    if (ret == 0 && (interactive || force_interactive))
      repl (L);

    if (usage || version) ret = 0;
    }
  else
    {
    fprintf (stderr, "%s: %s\n", argv[0], error);
    ret = EINVAL;
    }

  lua_close (L);

  return ret;
  }


