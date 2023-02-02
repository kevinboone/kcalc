--- module: calculus: simple numerical calculus functions 
------------------------------------------------------------------------------
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

--- note: eval_for_x is a helper function imported from basic.lua 

--- integrate_simpson 
function integrate_simpson (fn,_x_min,_x_max,_steps)
  local x_min = _x_min
  local x_max = _x_max
  local x0 = x_min
  local x1 = x_max
  local t = 0
  local steps = tonumber (_steps)
  if (steps == nil) then steps = 20 end
  if (steps < 2) then 
    error ("steps argument must be greater than 1 in integrate_simpson()")
  end;
  local h = (x1 - x0) / steps
  local s = eval_for_x (fn, x1) + eval_for_x (fn, x0)

  local i = 1
  repeat
    s = s + 4 * eval_for_x (fn, x0 + i * h)
    i = i + 2
  until i > steps
  i = 2
  repeat
    s = s + 2 * eval_for_x (fn, x0 + i * h)
    i = i + 2
  until i > steps - 1

  return s * h / 3
end

--- integrate_trapezium
function integrate_trapezium (fn,_x_min,_x_max,_steps)
  local x_min = _x_min
  local x_max = _x_max
  local x0 = x_min
  local x1 = x_max
  local t = 0;
  local steps = tonumber (_steps); 
  if (steps == nil) then steps = 20 end
  if (steps < 2) then 
    error ("steps argument must be greater than 1 in integrate_trapezium()")
  end;
  local h = (x1 - x0) / steps
  local s = eval_for_x (fn, x1) + eval_for_x (fn, x0)

  local i = 1
  repeat
    s = s + 2 * eval_for_x (fn, x0 + i * h)
    i = i + 1
  until i > steps
  return s * h / 2
end

kcalc_help['functions'] = kcalc_help['functions'] ..
  "Calculus functions:\n"..
  "integrate_simpson, integrate_trapezium\n"..
  "\n"


kcalc_help["integrate_simpson"]=
  "integrate_simpson(fn,x0,x1,steps) -- Numerical definite integration\n\n"..
  "Integrate the function fn in the range x0..x1 with the specified number "..
  "of subdivision steps, using Simpson's method. fn may be the name of any "..
  "function that takes a single value and returns a single value. "..
  "Alternatively, for simplicity, fn may be a string containing an "..
  "expression in x. The steps argument is optional; if not given it "..
  "defaults to 20."..
  "\n"..
  "Example: integrate sin(x)/x for x in the range 1..2:\n"..
  "\n"..
  "expr> integrate_simpson (\"sin(x)/x\", 1, 2)\n"..
  "0.659329908514041\n"

kcalc_help["integrate_trapezium"]=
  "integrate_trapezium(fn,x0,x1,steps) -- Numerical definite integration\n\n"..
  "Integrate the function fn in the range x0..x1 with the specified number "..
  "of subdivision steps, using the trapezium method. fn may be the name of "..
  "any function that takes a single value and returns a single value. "..
  "Alternatively, for simplicity, fn may be a string containing an "..
  "expression in x. The steps argument is optional; if not given it "..
  "defaults to 20.\n"..
  "\n"..
  "Example: integrate sin(x)/x for x in the range 1..2:\n"..
  "\n"..
  "expr> integrate_trapezium (\"sin(x)/x\", 1, 2)\n"..
  "0.682034377191586\n"..
  "\n"..
  "The trapezium method is faster than Simpson's method (see "..
  "integrate_simpson()) for the same number of subdivisions, but less "..
  "accurate. Unless the function to be integrated is very slow to "..
  "evaluate, Simpson's method is probably to be preferred."


