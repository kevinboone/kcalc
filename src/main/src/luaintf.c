/*===========================================================================

  main/luaintf.c 

  Copyright (c)2023 Kevin Boone, GPL v3.0

============================================================================*/
#define _GNU_SOURCE
#include <stdio.h>
#ifdef HAVE_READLINE
#include <readline/readline.h>
#endif
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>
#include <fcntl.h>
#include <main/defs.h>
#include <config.h>
#include <lua.h> 
#include <lualib.h> 
#include <lauxlib.h> 
#include <main/luaintf.h> 

#ifdef HAVE_READLINE
static char **rl_function_list = NULL;
static int rl_function_list_size = 0;
typedef char* (*matches_fn) (const char *text, int state);
char **completion_matches (const char *text, matches_fn fn);  
#endif

/*===========================================================================
  luaintf_require
============================================================================*/
void luaintf_require (lua_State *L, const char *name, char **error)
  {
  char *s;
  asprintf (&s, "require \"%s\"", name);
  if (luaL_loadbuffer (L, s, strlen(s), "line"))
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
    }
  free (s);
  }

/*===========================================================================
  luaintf_get_user_script_dir
============================================================================*/
char *luaintf_get_user_script_dir (void)
  {
  char *s;
  asprintf (&s, "%s/.%s", getenv("HOME"), NAME); 
  return s;
  }

/*===========================================================================
  luaintf_get_system_script_dir
============================================================================*/
char *luaintf_get_system_script_dir (void)
  {
  return strdup (SHAREDIR);
  }

/*===========================================================================
  luaintf_init_env
============================================================================*/
void luaintf_init_env (void)
  {
  char *script_dir = luaintf_get_system_script_dir(); 
  char *user_script_dir = luaintf_get_user_script_dir();
  char *lua_path;
  asprintf (&lua_path, "%s/?.lua;%s/?.lua",
    script_dir, user_script_dir); 
  setenv ("LUA_PATH", lua_path, TRUE);
  free (lua_path);
  free (script_dir);
  free (user_script_dir);
  }

/*===========================================================================
  luaintf_load_scripts
============================================================================*/
void luaintf_load_scripts (lua_State *L, char **error)
  {
  luaintf_require (L, "kcalc", error);
  }

/*===========================================================================
  l_refresh
============================================================================*/
static int l_refresh (lua_State *L)
  {
  luaintf_refresh_readline (L);
  luaintf_refresh_module_list (L);
  return 0;
  }

/*===========================================================================
  l_import
============================================================================*/
static int l_import (lua_State *L)
  {
  const char *s = lua_tostring (L, 1); 
  char *error = NULL;
  luaintf_require (L, s, &error);
  if (error)
    {
    fprintf (stderr, "%s\n", error);
    free (error);
    }
  else
    l_refresh (L); 
  return 0;
  }

/*===========================================================================
  luaintf_init_functions
============================================================================*/
void luaintf_init_functions (lua_State *L)
  {
  lua_pushcfunction (L, l_refresh);
  lua_setglobal(L, "refresh");
  lua_pushcfunction (L, l_import);
  lua_setglobal(L, "import");
  }

/*===========================================================================
  luaintf_set_screen_width
============================================================================*/
void luaintf_set_screen_width (lua_State *L, int width)
  {
  char *s;
  asprintf (&s, "_screen_width=%d", width);
  if (luaL_loadbuffer (L, s, strlen(s), "init"))
    {
    lua_pop (L, -1); 
    }
  else
    {
    if (lua_pcall (L, 0, 0, 0))
      {     
      lua_pop (L, -1); 
      }
    }
  free (s);
  }

/*===========================================================================
  luaintf_generator
============================================================================*/
#ifdef HAVE_READLINE
static char *luaintf_generator (const char *text, int state)
  {
  static int list_index = 0, len = 0;
  if (state == 0)
    {
    list_index = 0;
    len = strlen (text);
    }

  for (int i = list_index; i < rl_function_list_size; i++)
    {
    if (strncmp (text, rl_function_list[i], len) == 0)
      {
      list_index = i + 1;
      return strdup (rl_function_list[i]);
      }
    }

  return NULL;
  }
#endif

/*===========================================================================
  luaintf_completion
============================================================================*/
#ifdef HAVE_READLINE
static char **luaintf_completion (const char *text, int start, int len)
  {
  (void)start; (void)len;
  return completion_matches (text, luaintf_generator);
  }
#endif

/*===========================================================================
  luaintf_init_readline
============================================================================*/
void luaintf_init_readline (lua_State *L)
  {
#ifdef HAVE_READLINE
  rl_function_list_size = 0;
  rl_function_list = malloc (0);

  lua_getglobal (L, "kcalc_help");
  lua_pushnil (L);
  while (lua_next (L, -2))
    {
    rl_function_list = realloc (rl_function_list, 
       (rl_function_list_size + 2) * sizeof (char *));
    const char *s = lua_tostring (L, -2);
    rl_function_list [rl_function_list_size] = strdup (s);
    rl_function_list_size++;
    lua_pop (L, 1);
    }
  lua_pop (L, 0);
  rl_attempted_completion_function = luaintf_completion;
  rl_completer_word_break_characters = " \t\n\"\\'`@$><=;|&{(+-/*";
#endif
  }

/*===========================================================================
  luaintf_free_readline
============================================================================*/
void luaintf_free_readline (void)
  {
#ifdef HAVE_READLINE
  for (int i = 0; i < rl_function_list_size; i++)
    {
    free (rl_function_list[i]);
    }
  free (rl_function_list);
#endif
  }

/*===========================================================================
  luaintf_refresh_readline
============================================================================*/
void luaintf_refresh_readline (lua_State *L)
  {
  luaintf_free_readline();
  luaintf_init_readline (L);
  }

/*===========================================================================
  luaintf_get_module_list_from_dir
============================================================================*/
char *luaintf_get_module_list_from_dir (const char *dir)
  {
  char *result = malloc (1);
  result[0] = 0;
  DIR *d = opendir (dir);
  if (d)
    {
    struct dirent *de = readdir (d);
    while (de)
      {
      if (strstr (de->d_name, ".lua"))
        {
        char *path;
        asprintf (&path, "%s/%s", dir, de->d_name);
        int f = open (path, O_RDONLY);
        if (f >= 0)
          {
          char line[256];
          int n = read (f, line, sizeof (line));
          line[sizeof(line) - 1] = 0; 
          char *p = strchr (line, '\n');
          if (p) *p = 0;
          p = strstr (line, "module: ");
          if (p)
            {
            char *modtext = p + 8; 
            int newlen = strlen (result) + strlen (modtext) + 4;
            result = realloc (result, newlen);
            strcat (result, modtext);
            strcat (result, "\\n");
            }
          close (f);
          }
        free (path);
        }
      de = readdir (d);
      }
    closedir (d);
    } 
  return result; 
  }

/*===========================================================================
  luaintf_refresh_module_list
============================================================================*/
void luaintf_refresh_module_list (lua_State *L)
  {
  char *system_script_dir = luaintf_get_system_script_dir();
  char *user_script_dir = luaintf_get_user_script_dir();
  char *list1 = luaintf_get_module_list_from_dir (system_script_dir);
  char *list2 = luaintf_get_module_list_from_dir (user_script_dir);
  int newlen = strlen (list1) + strlen (list2) + 3;
  list1 = realloc (list1, newlen);
  strcat (list1, list2);

  char *s;
  asprintf (&s, 
     "kcalc_help['modules']=\"%sUse !import(name) to load a module\"", 
     list1);
  if (luaL_loadbuffer (L, s, strlen(s), "init"))
    {
    lua_pop (L, -1); 
    }
  else
    {
    if (lua_pcall (L, 0, 0, 0))
      {     
      lua_pop (L, -1); 
      }
    }
  free (s);

  free (list1); 
  free (list2); 
  free (system_script_dir); 
  free (user_script_dir); 
  }

