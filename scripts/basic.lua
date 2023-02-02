------------------------------------------------------------------------------
--- basic.lua
--- Basic functions, including simplifying wrappers for functions in the
--- Lua math library and in complex.lua 
---
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

pi = math.pi
i = math.i
huge = math.huge;
e = math.exp(1);

function arg(x)
  if (getmetatable(x)==complex) then
    return complex.arg(x)
  else
    return complex.arg(x + math.i * 0)
  end
end

function abs(x)
  return math.abs(x)
end

function acos(x)
  return math.acos(x)
end

function acosd(x)
  return 360 / 2 / math.pi * math.acos(x)
end

function acosh(x)
  return math.acosh(x)
end

function asin(x)
  return math.asin(x)
end

function asind(x)
  return 360 / 2 / math.pi * math.asin(x)
end

function asinh(x)
  return math.asinh(x)
end


function atan(x)
  return math.atan(x)
end

function atand(x)
  return 360 / 2 / math.pi * math.atan(x)
end

function atanh(x)
  return math.atanh(x)
end

function atan2(x,y)
  return math.atan2(x,y)
end

function atan2d(x,y)
  return 360 / 2 / math.pi * math.atan2(x,y)
end

function ceil(x)
  return math.ceil(x)
end

function cos(x)
  return math.cos(x)
end

function cosd(x)
  return math.cos(x / 360 * 2 * math.pi)
end

function cosh(x)
  return math.cosh(x)
end

function deg(x)
  return math.deg(x)
end

function exp(x)
  return math.exp(x)
end

function fact(x)
   local errval = "Factorial is only defined on non-negative whole numbers"
   if (not (type(x) == 'number')) then
     error (errval)
   end
   if (x < 0) then
     error (errval)
   end
   local xwhole = trunc (x);
   local xfrac = x - xwhole; 
   if (not (xfrac == 0)) then
     error (errval)
   end
   if (x == 0) then return 1 end;
   local t = 1;
   for i = 1,x do
     t = t * i;
   end
   return t;
end

function floor(x)
  return math.floor(x)
end

function fmod(x,y)
  return math.fmod(x,y)
end

function frexp(x)
  return math.frexp(x)
end

function gcd (u,v)
   local errval = "gcd is only defined on real numbers"
   if (not (type(u) == 'number')) then
     error (errval)
   end
   if (not (type(v) == 'number')) then
     error (errval)
   end
  local t;
  while not (v == 0) do
    t = u
    u = v
    v = t % v
  end
  return abs(u)
end

function im(x)
  if (getmetatable(x)==complex) then
    return x.i; 
  else
    return 0; 
  end
end

function ldexp(m,e)
  return math.ldexp(m,e)
end

function list_vars()
  local t = ""
  for k,v in pairs(_G) do
    if (not string.match (k, "^_")) then
      local tp = type(v)
      if (tp == 'number' or tp == 'complex' or tp == 'string'
            or tp == 'table') then
        if k == 'bit32' or k == 'table' or k == 'package' 
              or k == 'math' or k == 'io' or k == 'coroutine'
              or k == 'string' or k == 'os' or k == 'debug' 
              or k == 'complex' or k == 'kcalc_help' then
        else
          t = t .. k .. ": " .. type (v) .. "\n" 
        end
      end
    end
  end
  return t;
end

function log (...)
  local z = {...}
  return math.log (unpack (z))
end

function logN (x, N)
  return log (x) / log (N)
end

function log10 (x)
  return logN (x, 10)
end

function mod (x)
  return abs (x) -- this also handles complex
end

function pow (x,y)
  return math.pow (x,y)
end

function rad (x)
  return math.rad(x)
end

function random (...)
  local z = {...}
  return math.random (unpack (z))
end

function randomseed (x)
  return math.randomseed (x)
end

function real (x)
  if (getmetatable(x)==complex) then
    return x.r; 
  else
    return x; 
  end
end

function round (x)
  if (x >= 0) then 
    return math.floor (x + .5);
  end
  return math.ceil (x - .5);
end

function sign(x)
  if (x == 0) then return 0
  elseif (x < 0) then return -1
  else return 1
  end
end

function sin(x)
  return math.sin(x)
end

function sind(x)
  return math.sin(x / 360 * 2 * math.pi)
end

function sqrt (x)
  return math.sqrt (x)
end

function tan (x)
  return math.tan (x)
end

function tand(x)
  return math.tan(x / 360 * 2 * math.pi)
end

function tanh (x)
  return math.tanh (x)
end

function trunc (x)
  if (x >= 0) then return math.floor (x); end; 
  return math.ceil (x);
end


--- eval_for_x is a helper function for those functions which take either a 
--- function or a string containing x's as arguments
--- To handle the string we need a _global_ variable, as loadstring always
--- operates in a global context. To avoid side-effects, we have to
--- save any global variable already defined with the name 'x'
--- This function is not intended for use in user scripts
function eval_for_x (fn, _x)
  --- save old global x
  local old_x = x
  x = _x;
  local y = 0;
  if type(fn) == 'function' then
    y = fn(x)
  elseif type(fn) == 'string' then
    f,err = loadstring ("return " .. fn);
    if (f == nil) then 
      error ("string cannot be compiled to a function: " .. err)
    end
    y = f();
  else
    error "The fn argument must be a function"
  end
  --- restore old global x
  x = old_x
  return y;
end


function eval (s)
  local y = 0;
  if type(s) == 'function' then
    y = s() 
  elseif type(s) == 'string' then
    f,err = loadstring ("return " .. s);
    if (f == nil) then 
      error ("string cannot be compiled to a function: " .. err)
    end
    y = f()
  elseif type(s) == 'number' then
    y = s
  elseif type(s) == 'table' then 
    y = s
  elseif type(s) == 'complex' then
    y = s
  else
    error "Argument must be an expression"
  end
  return y
end



kcalc_help['functions'] = kcalc_help['functions'] ..
  "Basic functions:\n"..
  "abs, acos, acosd, acosh, asin, asinh, atan, atand, atanh, atan2, ceil, "..
  "cos, cosd, cosh, deg, eval, exp, fact, floor, fmod, gcd, im, list_vars, "..
  "log, logN, log10, mod, rad, random, randomseed, round, real, sign, sin, "..
  "sind, sinh, sqrt, tan, tand, trunc\n"..
  "\n"

kcalc_help['functions'] = kcalc_help['functions'] ..
  "System management:\n"..
  "import, list_vars, refresh\n"..
  "\n"

kcalc_help["arg"] = "arg(x) -- Argument of complex number x";
kcalc_help["abs"]="abs(x) -- Modulus of complex x; absolute value of real x"
kcalc_help["acos"]="acos(x) -- Inverse cosine in radians of x"
kcalc_help["acosd"]="acosd(x) -- Inverse cosine in degrees of x"
kcalc_help["acosh"]="acosh(x) -- Inverse hyperbolic cosine of x"
kcalc_help["asin"]="asin(x) -- Inverse sine in radians of x"
kcalc_help["asind"]="asind(x) -- Inverse sine in degrees of x"
kcalc_help["asinh"]="asinh(x) -- Inverse hyperbolic sine of x"
kcalc_help["atan"]="atan(x) -- Inverse tangent in radians of x"
kcalc_help["atand"]="atand(x) -- Inverse tangent in degrees of x"
kcalc_help["atanh"]="atanh(x) -- Inverse hyperbolic tangent of x"
kcalc_help["atan2"]="atan2(x,y) -- Angle whose tangent is x/y"
kcalc_help["ceil"]="ceil(x) -- Nearest whole number greater than x"
kcalc_help["cos"]="cos(x) -- Cosine of x in radians"
kcalc_help["cosd"]="cosd(x) -- Cosine of x in degrees"
kcalc_help["cosh"]="cosh(x) -- Hyperbolic cosine of x"
kcalc_help["deg"]="deg(x) -- Convert x in radians to degrees"
kcalc_help["exp"]="exp(x) -- e^x; natural antilogarithm"
kcalc_help["eval"]="eval(x) -- Evaluate x as an expression"
kcalc_help["fact"]="fact(x) -- Factorial of x"
kcalc_help["floor"]="floor(x) -- Nearest whole number below x"
kcalc_help["fmod"]="fmod(x,y) -- Remainer when dividing x by y"
kcalc_help["gcd"]="gcd(x,y) -- Greatest common divisor of x and y"
kcalc_help["im"]="im(x) -- Imaginary part of complex x"
kcalc_help["import"]="import(name) -- Load module with name"
kcalc_help["list_vars"]="list_vars() -- List defined (global) variables"
kcalc_help["log"]="log(x) -- Natural logarithm of x"
kcalc_help["log10"]="log10(x) -- Logarithm of x to base 10"
kcalc_help["logN"]="logN(x, N) -- Logarithm of x to base N"
kcalc_help["mod"]="mod(x) -- Modulus of complex x; absolute value of real x"
kcalc_help["rad"]="rad(x) -- Convert x in degrees to radians"
kcalc_help["real"]="real(x) -- Real part of complex x"
kcalc_help["random"]="random() -- Pseudo-random number between 0 and 1\n"..
  "random(x) -- Pseudo-random whole number between 0 and x\n"..
  "random(x,y) -- Pseudo-random whole number between x and y"
kcalc_help["randomseed"] = "randomseed(x) -- Sets the random-number seed to x"
kcalc_help["refresh"]="Refresh the internal state, after changes to files"
kcalc_help["round"]="round(x) -- Round x to nearest whole number, half away from zero"
kcalc_help["real"]="real(x) -- Real part of complex x"
kcalc_help["sign"]="sign(x) -- Returns 1.0 if x is +ve; -1.0 if -ve; 0 if zero"
kcalc_help["sin"]="sin(x) -- Sine of x in radians"
kcalc_help["sind"]="sind(x) -- Sine of x in degrees"
kcalc_help["sinh"]="sinh(x) -- Hyperbolic sin of x"
kcalc_help["sqrt"]="sqrt(x) -- Square root of x"
kcalc_help["tan"]="tan(x) -- Tangent of x in radians"
kcalc_help["tand"]="tand(x) -- Tangent of x in degrees"
kcalc_help["tanh"]="tanh(x) -- Hyperbolic tangent of x"
kcalc_help["trunc"]="trunc(x) -- truncate x to whole number closest to zero"

kcalc_help["constants"] = kcalc_help["constants"] ..
  "Basic constants\n"..
   "i                 Square root of -1\n"..
   "e                 Base of natural logarithms\n"..
   "pi                Pi\n"..
   "huge              The largest number representable; 1/0\n"..
   "\n"

kcalc_help["i"]="i -- Imaginary suffix; square root of -1"
kcalc_help["e"]="e -- Base of natural logarithms"
kcalc_help["pi"]="pi -- Constant pi"
kcalc_help["huge"]="huge -- result of arithmetic operations that overflow"



