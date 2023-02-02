--- module: solve: simple equation-solving functions 
------------------------------------------------------------------------------
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

--- note: eval_for_x is a helper function imported from basic.lua 

--- solve_secant
function solve_secant (fn,_x_min,_x_max,_eps,_iters)
  local x_min = _x_min
  local x_max = _x_max
  local x0 = x_min;
  local x1 = x_max;
  local x2;
  local eps = tonumber (_eps); 
  local iters = tonumber (_iters);
  if (eps == nil) then eps = 1e-5; end;
  if (iters == nil) then iters = 20; end;
  local n = 0;
  repeat 
    local y1 = eval_for_x (fn, x1)
    local y0 = eval_for_x (fn, x0)
    x2 = x1 - y1 * ((x1 - x0) / (y1 - y0));
    local y2 = eval_for_x (fn, x2)
    x0 = x1;
    x1 = x2;
    n = n + 1;
  until (abs(y2) < eps) or (n > iters); 
  if (n > iters) then
    error ("solve_secant() did not converge after " .. iters .. " iterations") 
  end
  return x2; 
end

--- solve_bisection
function solve_bisection (fn,_x_min,_x_max,_eps,_iters)
  local x_min = _x_min
  local x_max = _x_max
  local a = x_min;
  local b = x_max;
  local c;
  local eps = tonumber (_eps); 
  local iters = tonumber (_iters);
  if (eps == nil) then eps = 1e-5; end;
  if (iters == nil) then iters = 20; end;
  local n = 0;
  repeat 
    c = (a + b) / 2;
    local fa = eval_for_x (fn, a);
    local fc = eval_for_x (fn, c);
    if (sign(fc) == sign (fa)) then 
      a = c
    else
      b = c 
    end
    n = n + 1;
  until (abs(fc) < eps) or (n > iters); 
  if (n > iters) then
    error ("solve_bisection() did not converge after " .. iters .. " iterations") 
  end
  return c; 
end


--- quadratic
function quadratic (a,b,c)
  p = sqrt (b^2 - 4 * a * c) 
  return {-b / (2 * a) - p / (2 * a), -b / (2 * a) + p / (2 * a)}
end


kcalc_help['functions'] = kcalc_help['functions'] ..
  "Solving/root-finding functions:\n"..
  "quadratic,solve_bisection,solve_secant\n"..
  "\n"


kcalc_help["quadratic"]=
  "quadratic(a,b,c) -- Roots of a quadratic equation\n\n"..
  "quadratic(a,b,c) returns a two-element array containing the roots of the\n"..
  "equation \"a*x^2 + b*x + c = 0\". Any of a, b, or c may be complex, as\n"..
  "may the either of the return values.\n"


kcalc_help["solve_secant"]=
  "solve_secant(fn,x0,x1,eps,iters) -- Solve fn(x)=0\n\n"..
  "Attempts to solve the equation fn(x)=0 using the secant method.\n"..
  "\n"..
  "The starting values x0 and x1 must be given, but eps -- the tolerance --\n"..
  "and iters -- the number of iterations -- can be omitted, These default\n"..
  "to 0.00001 and 20 respectively.\n"..
  "\n"..
  "The starting values need not enclose the root, but the method is most\n"..
  "effective when the starting values are close to the root. solve_secant()\n"..
  "can be used to solve for complex as well as real roots.\n"..
  "\n"..
  "The function argument fn can be any function which takes a single value\n"..
  "and returns a single value, defined in the Lua language. Alternatively,\n"..
  "an expression containg the term x can be supplied in the form of a\n"..
  "string.\n"..
  "\n"..
  "Example: Solve X^2 - 5*x + 6 = 0, starting with values 4 and 5:\n"..
  "\n"..
  "expr> solve_secant (\"x^2 - 5*x + 6\", 4, 5)\n"..
  "3.00000476301613\n"..
  "\n"..
  "Example: Solve x^2 + 4 = 0, starting with values 0 and i:\n"..
  "\n"..
  "expr> !function f(x) return x*x + 4 end\n"..
  "expr> solve_secant (f, 0, i, 1e-16)\n"..
  "2i\n"..
  "\n"..
  "Note that, in general, complex starting points must be given when\n"..
  "trying to solve for a complex root.\n"

kcalc_help["solve_bisection"]=
  "solve_bisection(fn,x0,x1,eps,iters) -- Solve fn(x)=0\n\n"..
  "Attempts to solve the equation fn(x)=0 using the bisection method.\n"..
  "\n"..
  "The starting values x0 and x1 must be given, but eps -- the tolerance --\n"..
  "and iters -- the number of iterations -- can be omitted, These default\n"..
  "to 0.00001 and 20 respectively.\n"..
  "\n"..
  "The starting values must bracket the root, that is, the value of fn(x)\n"..
  "must been of different sign at each of the starting values.\n"..
  "\n"..
  "The function argument fn can be any function which takes a single value\n"..
  "and returns a single value, defined in the Lua language. Alternatively,\n"..
  "an expression containg the term x can be supplied in the form of a\n"..
  "string.\n"..
  "\n"..
  "Example: Solve X^2 - 5*x + 6 = 0, starting with values 4 and 5:\n"..
  "\n"..
  "expr> solve_bisection (\"x^2 - 5*x + 6\", 2, 4)\n"..
  "3\n"..
  "\n"..
  "The bisection method (as implemented here) is only appropriate for\n"..
  "real-valued functions.\n"

