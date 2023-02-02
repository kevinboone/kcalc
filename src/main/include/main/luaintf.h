/*===========================================================================

  main/luainft.h

  Copyright (c)2023 Kevin Boone, GPL v3.0

============================================================================*/

#pragma once

#include <lua.h> 

extern void luaintf_init_env (void);
extern void luaintf_load_scripts (lua_State *L, char **error);
extern void luaintf_init_readline (lua_State *L);
extern void luaintf_free_readline (void);
extern void luaintf_refresh_readline (lua_State *L);
extern void luaintf_init_functions (lua_State *L);
extern void luaintf_refresh_readline (lua_State *L);
extern void luaintf_refresh_module_list (lua_State *L);
extern char *luaintf_get_user_script_dir (void);
extern char *luaintf_get_system_script_dir (void);
extern void luaintf_set_screen_width (lua_State *L, int width);


