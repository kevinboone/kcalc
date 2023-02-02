------------------------------------------------------------------------------
--- help.lua
--- Implements help and documentation functions
---
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

--- Global associative array for help topics
kcalc_help = {}
kcalc_help['functions'] = ""
kcalc_help['constants'] = ""
kcalc_help['operators'] = 
  "Operators in order of decreasing precedence\n" ..
  "or      logical OR\n"..
  "and     logical AND\n"..
  "<       less than\n"..
  ">       greater than\n"..
  "<=      less than or equal\n"..
  ">=      greater than or equal\n"..
  "~=      not equal\n"..
  "==      equal\n"..
  "..      concatenation\n"..
  "-       subtraction\n"..
  "+       addition\n"..
  "/       division\n"..
  "*       multiplication\n"..
  "%       remainder\n"..
  "not     logical negation\n"..
  "#       size (of a table)\n"..
  "-       unary minus\n"..
  "^       power\n"

kcalc_help['functions'] = kcalc_help['functions'] ..
  "Help functions:\n"..
  "help, apropos\n"..
  "\n"

kcalc_help["help"] = "help('topic') -- Get help on a topic";
kcalc_help["apropos"] = "apropos('keyword') -- List help topics matching keyword";

--------------------------------------------------------------------------
--- help 
--------------------------------------------------------------------------
function help(topic)
  if not (topic == nil) then
    local s = kcalc_help[topic]
    if not (s == nil) then
      return s
    else 
      return "No help available for topic '" .. topic .. "'"
    end
  end
    return "Enter help ('functions') for a list of built-in functions\n" ..
    "Enter help ('constants') for a list of built-in constants\n" ..
    "Enter help ('operators') for information about operators\n" ..
    "Enter help ('modules') for information about extension modules\n" ..
    "Enter help ('{function_name}') for information about a specific function\n"..
    "Enter apropos ('{keyword}') to search for entries matching a keyword\n"
end

--------------------------------------------------------------------------
--- kcalc_first_line 
--- Returns the first line of some text that contains \n separators
--------------------------------------------------------------------------
function kcalc_first_line (s)
  i1,i2 = string.find (s, "(.-\n)")
  if not (i1 == nil) then
    return string.sub (s, i1, i2 - 1)
  else 
    return s
  end
end

--------------------------------------------------------------------------
--- apropos 
--------------------------------------------------------------------------
function apropos (keyword)
  local res = ""
  if keyword == nil then
      return "apropos function requires a keyword argument"
  else
    local found = false;
      for func,text in pairs(kcalc_help) do
        if not (func == "functions" or 
              func == "operators" or func == "constants") then
          if string.match (string.upper(" " .. text), 
              "[^%w]" .. string.upper(keyword) .. "[^%w]") then
            res = res .. kcalc_first_line (text) .. "\n"
            found = true;
          end
        end
      end
    if found then
      return res
    else
      return "No help entries for keyword '" .. keyword .. "'"
    end
  end
end

