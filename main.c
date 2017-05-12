#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <unistd.h>
#include <stdlib.h>
#ifdef HAVE_READLINE
#include <readline/readline.h>
#include <readline/history.h>
#endif
#include "klib_error.h" 
#include "klib_string.h" 
#include "klib_defs.h" 
#include "klib_getopt.h" 
#include "klib_getoptspec.h" 
#include "klib_path.h" 
#include "lua.h" 
#include "lauxlib.h" 
#include "lualib.h" 

#define PROMPT1 "expr> "
#define PROMPT2_EXPR "expr... "
#define PROMPT2_STMT "statment... "
#define STMT_CHAR '!'
#define QUIT_COMMAND "quit"
#define MAX_HISTORY 100

#ifdef HAVE_READLINE
typedef char* (*matches_fn) (const char *text, int state);
char **completion_matches (const char *text, matches_fn fn); 
static char **rl_function_list = NULL;
static int rl_function_list_size = 0;
#endif

/*============================================================================
  _readline_no_prompt 
============================================================================*/
char *_readline_no_prompt (void)
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

/*============================================================================
  _readline_with_prompt 
============================================================================*/
char *_readline_with_prompt (const char *prompt)
  {
#ifdef HAVE_READLINE
  return readline (prompt);
#else
  printf (prompt);
  return _readline_no_prompt ();
#endif
  }


/*============================================================================
  _readline 
  Use GNU readline if the input is a terminal, otherwise revert
  to fgets(). On EOF or error, returns NULL.
  Caller must free the string if it is non-NULL.
============================================================================*/
char *_readline (const char *prompt)
  {
  if (isatty (0))
    return _readline_with_prompt (prompt);
  else
    return _readline_no_prompt ();
  }


/*============================================================================
  transform_input
============================================================================*/
char *transform_input (const char *input)
  {
  if (strcmp (input, "help") == 0) return strdup ("help()");
  return strdup (input);
  }

/*============================================================================
  eval
  Evaluate the input as an expression or a lua statement. If it is an
  expression, print the result
============================================================================*/
void eval (const char *_input, lua_State *L, const char *source, 
    klib_Error **error)
  {
  if (_input == NULL) return;
  if (strlen (_input) == 0) return;

  char *input = transform_input (_input);

  BOOL report;
  char *s; 
  if (input[0] == STMT_CHAR)
    {
    report = FALSE;
    s = strdup (input+1);
    }
  else
    {
    s = malloc (strlen (input) + 20);
    sprintf (s, "last=%s", input);
    report = TRUE;
    }

  if (luaL_loadbuffer (L, s, strlen(s), source))
    {
    *error = klib_error_new (-1, lua_tostring(L, -1));
    lua_pop (L, -1);
    }
  else
    {
    if (lua_pcall (L, 0, 0, 0))
      {
      *error = klib_error_new (-1, lua_tostring(L, -1));
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
          *error = klib_error_new (-1, lua_tostring(L, -1));
          lua_pop (L, -1);
          }
        lua_pop (L, -1); // Do we need this? Function returns void
        }
      }
    }
  free (s);
  free (input);
  }


/*============================================================================
  require 
============================================================================*/
void require (lua_State *L, const char *name, klib_Error **error)
  {
  char s[1024];
  snprintf (s, sizeof (s), "require \"%s\"", name);
  if (luaL_loadbuffer (L, s, strlen(s), "line"))
    {
    *error = klib_error_new (-1, lua_tostring(L, -1));
    lua_pop (L, -1);
    }
  else
    {
    if (lua_pcall (L, 0, 0, 0))
      {
      *error = klib_error_new (-1, lua_tostring(L, -1));
      lua_pop (L, -1);
      }
    }
  }

/*============================================================================
  dofile 
============================================================================*/
void dofile (const char *file, lua_State *L, klib_Error **error)
  {
  char s[1024];
  snprintf (s, sizeof (s), "dofile \"%s\"", file);
  if (luaL_loadbuffer (L, s, strlen(s), file))
    {
    *error = klib_error_new (-1, lua_tostring(L, -1));
    lua_pop (L, -1);
    }
  else
    {
    if (lua_pcall (L, 0, 0, 0))
      {
      *error = klib_error_new (-1, lua_tostring(L, -1));
      lua_pop (L, -1);
      }
    }
  }

/*============================================================================
  init 
============================================================================*/
void init (lua_State *L, klib_Error **error)
  {
  require (L, "kcalc", error);
  }


/*========================================================================
  show_short_usage 
=========================================================================*/
void show_short_usage (FILE *f, const char *argv0)
  {
  fprintf (f, "Usage: %s [-ivh] [-s {file}] [expression]\n", argv0);
  fprintf (f, "'%s --longhelp' for more details.\n", argv0); 
  }


/*========================================================================
  show_long_usage 
=========================================================================*/
void show_long_usage (FILE *f, const char *argv0)
  {
  fprintf (f, "Usage: %s [options...] [expression]\n", argv0);
  fprintf (f, "  -i,--help                 interactive mode\n");
  fprintf (f, "  -h,--help                 brief usage\n");
  fprintf (f, "  --longhelp                detailed usage\n");
  fprintf (f, "  -v,--version              show version and configuration\n");
  }


/*============================================================================
  get_script_dir 
============================================================================*/
klib_Path *get_script_dir (void)
  {
  klib_Path *argv0 = klib_path_get_full_argv0();      
  klib_Path *script_dir = klib_path_get_dir(argv0);      
  klib_path_free (argv0);
  klib_path_append (script_dir, "scripts"); 
  return script_dir;
  }


/*============================================================================
  get_user_script_dir 
============================================================================*/
klib_Path *get_user_script_dir (void)
  {
  klib_Path *user_script_dir = klib_path_get_home_dir();

#ifdef WIN32
  klib_path_append (user_script_dir, "kcalc");
#else
  klib_path_append (user_script_dir, ".kcalc");
#endif
  
  return user_script_dir;
  }


/*========================================================================
  show_version
=========================================================================*/
void show_version (FILE *f, const char *argv0)
  {
  fprintf (f, APPNAME " version " VERSION "\n");
  fprintf (f, "\n");
  fprintf (f, 
    "Math implementation and shell copyright (c)2004-2013 Kevin Boone\n");
  fprintf (f, "Lua interpreter copyright (c)1994-2012 Lua.org, PUC-Rio\n");
  fprintf (f, "\n");
  klib_Path *script_dir = get_script_dir ();
  klib_Path *user_script_dir = get_user_script_dir ();
  fprintf (f, "System script directory: %s\n", klib_path_cstr(script_dir));
  fprintf (f, "User script directory:   %s\n", klib_path_cstr(user_script_dir));
  klib_path_free (script_dir);
  klib_path_free (user_script_dir);
  fprintf (f, "\n");
  }


/*============================================================================
  read_kcalc_history 
============================================================================*/
void read_kcalc_history (void)
  {
#ifdef HAVE_READLINE
  char filename[256];
  snprintf (filename, sizeof (filename) - 1, "%s/.kcalc_history", 
    getenv("HOME"));
  read_history (filename);
#endif
  }


/*============================================================================
  write_kcalc_history 
============================================================================*/
void write_kcalc_history (void)
  {
#ifdef HAVE_READLINE
  char filename[256];
  snprintf (filename, sizeof (filename) - 1, "%s/.kcalc_history", 
    getenv("HOME"));
  write_history (filename);
  history_truncate_file (filename, MAX_HISTORY);
#endif
  }



/*============================================================================
  init_rl_function_list 
  Used for readline completion
============================================================================*/
void init_rl_function_list (lua_State *L)
  {
#ifdef HAVE_READLINE
  rl_function_list_size = 0; 
  rl_function_list = malloc (0);
  lua_getglobal (L, "kcalc_help");
  lua_pushnil (L);
  while (lua_next (L, -2))
    {
    rl_function_list = realloc (rl_function_list, (rl_function_list_size + 2) * sizeof (char *));
    const char *s = lua_tostring (L, -2); 
    rl_function_list[rl_function_list_size] = strdup (s);
    rl_function_list_size++;
    lua_pop (L, 1);
    }
  lua_pop (L, 1); 

  rl_function_list = realloc 
    (rl_function_list, (rl_function_list_size + 2) * sizeof (char *));
  rl_function_list[rl_function_list_size] = strdup ("last");
  rl_function_list_size++;
  rl_function_list = realloc 
    (rl_function_list, (rl_function_list_size + 2) * sizeof (char *));
  rl_function_list[rl_function_list_size] = strdup ("quit");
  rl_function_list_size++;
#endif
  }

/*============================================================================
  kcalc_completion 
============================================================================*/
#ifdef HAVE_READLINE
static char* kcalc_generator (const char *text, int state)
  {
  static int list_index = 0, len = 0;
  if (state == 0)
    {
    list_index = 0;
    len = strlen (text);
    }

  int i;
  for (i = list_index; i < rl_function_list_size; i++)
    {
    if (strncmp (text, rl_function_list[i], len) == 0)
      {
      list_index = i + 1;
      return strdup (rl_function_list[i]); 
      }
    }

  return NULL;
  }


static char **kcalc_completion (const char *text, int start, int len)
  {
  char **matches = NULL;
  //if (start == 0)
    matches = completion_matches (text, kcalc_generator); 
  return matches;
  }
#endif


/*============================================================================
  main 
============================================================================*/

// EOF indicators used to detect when more input is required,
//  by looking at the parser error messages
#define EOFMARK "<eof>"
#define EOFMARKLEN (sizeof(EOFMARK))

int main (int argc, char **argv)
  {
  klib_GetOpt *getopt = klib_getopt_new ();
  klib_getopt_add_spec (getopt, "help", "help", 'h', KLIB_GETOPT_NOARG);
  klib_getopt_add_spec (getopt, "interactive", "interactive", 'i', 
    KLIB_GETOPT_NOARG);
  klib_getopt_add_spec (getopt, "longhelp", "longhelp", 0, KLIB_GETOPT_NOARG);
  klib_getopt_add_spec (getopt, "version", "version", 'v', KLIB_GETOPT_NOARG);
  klib_getopt_add_spec (getopt, "script", "script", 's', KLIB_GETOPT_COMPARG);

  klib_Error *error = NULL;

  klib_getopt_parse (getopt, argc, (const char **)argv, &error);

  if (!error)
    {
    BOOL interactive = FALSE;
    BOOL stopping_option = FALSE;
    if (klib_getopt_arg_set (getopt, "interactive"))
      {
      interactive = TRUE;
      }
    if (klib_getopt_arg_set (getopt, "help"))
      {
      show_short_usage (stdout, argv[0]);
      stopping_option = TRUE;
      }
    else if (klib_getopt_arg_set (getopt, "longhelp"))
      {
      show_long_usage (stdout, argv[0]);
      stopping_option = TRUE;
      }
    else if (klib_getopt_arg_set (getopt, "version"))
      {
      show_version (stdout, argv[0]);
      stopping_option = TRUE;
      }
    if (!stopping_option || interactive)
      { 
      klib_Path *script_dir = get_script_dir (); 
      klib_Path *user_script_dir = get_user_script_dir (); 

      klib_String *lua_path = klib_string_new_empty ();
#ifdef WIN32
      klib_string_printf (lua_path, "LUA_PATH=%s\\?.lua;%s\\?.lua", 
          klib_path_cstr (script_dir), klib_path_cstr (user_script_dir));
#else
      klib_string_printf (lua_path, "LUA_PATH=%s/?.lua;%s/?.lua", 
          klib_path_cstr (script_dir), klib_path_cstr (user_script_dir));
#endif
      putenv ((char *)klib_string_cstr (lua_path));

      lua_State *L = luaL_newstate();
      luaL_openlibs (L);

      klib_Error *error = NULL;
      init(L, &error);
      if (error)
        {
        fprintf (stderr, "%s\n", klib_error_cstr (error));
        klib_error_free (error);
        }
      else
        { 
        BOOL command_line = FALSE;
        int i, newargc = klib_getopt_argc(getopt);
        if (newargc > 0)
          {
          klib_String *s = klib_string_new_empty();
          for (i = 0; i < newargc; i++)
            {
            klib_string_append (s, klib_getopt_argv(getopt, i));
            klib_string_append (s, "");
            }
          klib_Error *error = NULL;
          eval (klib_string_cstr (s), L, "=cmdline", &error);
          if (error)
            {
            fprintf (stderr, "%s\n", klib_error_cstr (error));
            klib_error_free (error);
            }
          klib_string_free (s);
          command_line = TRUE;
          }

        BOOL script = FALSE;

        if (klib_getopt_arg_set (getopt, "script"))
         {
         const char *scriptfile = klib_getopt_get_arg (getopt, "script");
         klib_Error *error = NULL;
         dofile (scriptfile, L, &error);
         if (error)
            {
            fprintf (stderr, "%s\n", klib_error_cstr (error));
            klib_error_free (error);
            }
         script = TRUE;
         }
        
        if ((!command_line && !script) || interactive)
          {
          read_kcalc_history();

#ifdef HAVE_READLINE
          rl_attempted_completion_function = kcalc_completion;
          init_rl_function_list (L);
          //rl_basic_word_break_characters = " \t\n\"\\'`@$><=;|&{(+-/*";
          //rl_completer_word_break_characters = rl_basic_word_break_characters; 
          rl_completer_word_break_characters = " \t\n\"\\'`@$><=;|&{(+-/*";
#endif
          BOOL quit = FALSE;
          while (!quit)
            {
            klib_String *input_buffer = klib_string_new_empty ();
            BOOL complete = FALSE;
            BOOL eof = FALSE;
            char *input = _readline (PROMPT1);
            if (input)
              {
              do
                {
                if (input)
                  {
                  klib_string_append (input_buffer, input);
              
                  char *line_to_parse;
                   if (klib_string_cstr(input_buffer)[0] == STMT_CHAR)
                    line_to_parse = 
                      strdup (klib_string_cstr (input_buffer) + 1);
                   else
                    {
                   line_to_parse = malloc (klib_string_length (input_buffer) + 
                     20);
                   sprintf (line_to_parse, "return %s", 
                     klib_string_cstr (input_buffer)); 
                   } 

                  int status = luaL_loadbuffer 
                   (L, line_to_parse, strlen (line_to_parse), "=stdin"); 
                  free (line_to_parse);
 
                  if (status == LUA_ERRSYNTAX)
                    {
                    size_t lmsg = 0;
                    const char *msg = lua_tolstring (L, -1, &lmsg);
                    if (lmsg >= EOFMARKLEN && strcmp 
                       (msg + lmsg - EOFMARKLEN + 1, EOFMARK) == 0)
                      {
                      // Input is syntax error, but potentially incomplete
                      //  and could be completed
                      lua_pop (L, 1);
                      } 
                    else
                      {
                      complete = TRUE;
                      }
                    }
                  else if (status == LUA_OK)
                    {
                    // (presumably) no error message to pop from stack
                    complete = TRUE;
                    }
                  else
                    {
                    // It's not clear, but I'm guessing that in error conditions
                    //  other than syntax, there's still a message to pop from
                    //  the stack
                    lua_pop (L, 1);
                    complete = TRUE;
                    }

                  if (!complete)
                    {
                    klib_string_append (input_buffer, "\n");
                    if (klib_string_cstr(input_buffer)[0] == '!')
                      input = _readline (PROMPT2_STMT);
                    else
                      input = _readline (PROMPT2_EXPR);
                    }
                  }
                } while (input && !complete);
              free (input);
              }
            else
              {
              // EOF with nothing entered
              eof = TRUE;
              }
     
            if (eof)
              {
              quit = TRUE;
              }
            else if (strcmp (klib_string_cstr (input_buffer),
                QUIT_COMMAND) == 0)
              {
              quit = TRUE;
              }
            else
              {
              klib_Error *error = NULL;
              eval (klib_string_cstr (input_buffer), L, "=stdin", &error);
              if (error)
                {
                fprintf (stderr, "%s\n", klib_error_cstr (error));
                klib_error_free (error);
                }
#ifdef HAVE_READLINE
              if (klib_string_length (input_buffer) > 0)
                add_history (klib_string_cstr (input_buffer));
#endif
              }
  
            klib_string_free (input_buffer);
            }
          lua_close (L);
          write_kcalc_history();
          }
        }
      klib_path_free (script_dir);
      klib_path_free (user_script_dir);
      klib_string_free (lua_path);
      }
    }
  else
    {
    // Error parsing command line
    fprintf (stderr, "%s\n", klib_error_cstr (error));
    klib_error_free (error);
    }
  if (getopt) 
    klib_getopt_free (getopt);
  return 0; 
  }





