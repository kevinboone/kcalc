/*===========================================================================

  main/my_readline.h

  Copyright (c)2023 Kevin Boone, GPL v3.0

============================================================================*/

#pragma once

#include <lua.h>

extern char *my_readline (const char *prompt);
extern void my_add_history (const char *input);
extern void my_read_history (void);
extern void my_write_history (void);
