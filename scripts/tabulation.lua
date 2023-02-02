--- tabulation.lua: module: tabulation: functions for mapping and tabulating function values and results
------------------------------------------------------------------------------
---
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

function _map (fn, tab)
  local outtab = {}
  for i = 1,#tab do
    outtab[i] = eval_for_x (fn, tab[i]) 
  end
  return outtab 
end

function map (fn, ...)
  local z = {...}
  if type(z[1]) == 'table' then
    return _map (fn, z[1])
  else
    return _map (fn, z)
  end
end

--- tabulate_functions
function tabulate_functions (from, to, steps, func1, func2, func3)
  if (from == to) then error ("Start and end values are the same"); end
  local step = (to - from) / steps;
  local result = {}
  for x = from, to, step
  do
    if (func3) then
      local pair = {x, eval_for_x(func1,x), eval_for_x(func2,x), 
         eval_for_x(func3,x)}
      result[#result+1] = pair; 
    else 
      if (func2) then
        local pair = {x, eval_for_x (func1, x), eval_for_x (func2, x)}
        result[#result+1] = pair; 
      else 
        if (func1) then
          local pair = {x, eval_for_x (func1, x)}
          result[#result+1] = pair; 
        else
          error ("At least one function must be supplied")
        end
      end
    end
  end
  return result
end



kcalc_help["map"]="map(fn,x1,x2...) -- Apply function fn to values x1, x2..\n\n"..
  "The values can be arguments, or a table in x1. "..
  "If x1 is a table, the other arguments are ignored. "..
  "The map function returns its results in a table. "..
  "Example: to find the complex number with the smallest modulus:\n"..
  "min(map(mod,{1+i, 2-3*i, 2-i}))"

kcalc_help["tabulate_functions"]="tabulate_functions (start, end, steps, fn1, fn2...) -- Generate a table of values of one or more functions over a specified range.\n\n"..
  "The output is an two-dimensional array, in which each row represents a "..
  "value of the independent variable. The row array has an entry for this "..
  "variable, and one entry for each of the functions applied to the value.";

kcalc_help['functions'] = kcalc_help['functions'] ..
  "Tabulation and mapping functions:\n"..
  "map, tabulate_functions\n"..
  "\n"


