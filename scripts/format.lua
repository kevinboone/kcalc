------------------------------------------------------------------------------
--- format.lua
--- Functions for formatting and displaying data, including complex numbers,
--- tables, etc. 
---
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

_private_fmt_short = 0;
_private_fmt_long = 1;
_private_fmt_shortE = 2;
_private_fmt_longE = 3;
_private_fmt_shortG = 4;
_private_fmt_longG = 5;
_private_fmt_shortEng = 6;
_private_fmt_longEng = 7;
_private_fmt_bank = 8;
_private_fmt_hex = 9;
_private_fmt_rat = 10;
_private_fmt = _private_fmt_longG;

-----------------------------------------------------------------------------
--- kcalc_outstring
-----------------------------------------------------------------------------
function kcalc_outstring (x)
  print(x)
end

-----------------------------------------------------------------------------
--- kcalc_format_complex 
-----------------------------------------------------------------------------
function kcalc_format_complex (x, strict)
  local re = x.r
  local im = x.i
  if (im == nil) then im = 0 end
  if (re == nil) then re = 0 end
  if (re == -0) then re = 0 end --- don't know why this seems to happen
  if (im == 0) then
   return kcalc_format_number (re) 
  elseif (re == 0) then
    --- Imaginary part, but no real part
    if (im == 1) then
      return "i";
    elseif (im == -1) then
      return "-i"
    else
     if (strict) then
       return kcalc_format_number (im) .. "*i" 
     else
       return kcalc_format_number (im) .. "i" 
     end
    end 
  else
    --- Imaginary part and real part
    if (im == 1) then
     return kcalc_format_number (re) .. "+i"
    elseif (im == -1) then
     return kcalc_format_number (re) .. "-i"
    else
      if (im > 0) then
        if (strict) then
          return kcalc_format_number (re) .. "+" .. kcalc_format_number(im) .. "*i"
        else
          return kcalc_format_number (re) .. "+" .. kcalc_format_number(im) .. "i"
        end
      else
        if (strict) then
          return kcalc_format_number (re) .. "-" .. kcalc_format_number(-im) .. "*i"
        else
          return kcalc_format_number (re) .. "-" .. kcalc_format_number(-im) .. "i"
        end
      end
    end
  end
end

-----------------------------------------------------------------------------
--- kcalc_format_table
-----------------------------------------------------------------------------
function kcalc_format_table (x)
  local res = "{"
  for i=1,#x do
    res = res .. _kcalc_format (x[i])
    if not (i == #x) then
      res = res .. ","
    end
  end
  res = res .. "}"
  return res
end

-----------------------------------------------------------------------------
--- _kcalc_format_string 
-- Unless screen width is -1 (probably output is not to a tty), break up
-- strings by words.
-----------------------------------------------------------------------------
function _kcalc_format_string (s)
  if (_screen_width <= 0) then return s; end

  local result = "";
  local len = 0;
  for w in string.gmatch (s, "%S+%s*") do

    len = len + #w

    if (len > _screen_width) then
      result = result .. "\n"
      result = result .. w
      len = #w
    else
      if (string.find (w, "\n") ~= nil) then
	result = result .. w 
	len = 0 
      else 
	result = result .. w
      end
    end
  end
  return result
end

-----------------------------------------------------------------------------
--- kcalc_format -- formatter entry point
-----------------------------------------------------------------------------
function kcalc_format (x)
  if (_kcalc_strict) then
    kcalc_outstring (_kcalc_format (x, true))
  else
    kcalc_outstring (_kcalc_format (x))
  end
end

function _kcalc_format (x,strict)
  if (type (x) == "number") then
    return kcalc_format_number (x, strict)
  elseif (type (x) == "complex") then
    return kcalc_format_complex (x, strict)
  elseif (type (x) == "table") then
    return kcalc_format_table (x, strict)
  else
    if (not strict) then
      return _kcalc_format_string (tostring (x));
    else
      return "\"" .. tostring (x) .. "\"";
    end
  end
end

-----------------------------------------------------------------------------
--- dec2eng 
-----------------------------------------------------------------------------
function dec2eng (x,...)

  local z = {...};
  local sigfigs=15;
  if (#z >= 1) then
     sigfigs = tonumber (z[1]);
  end

  if (x == 0) then
     return "0.0";
  end

  local res = "";

  if (x < 0) then
    res = "-";
    x = -x;
  end

  local expof10 = floor (log10(x));
  if (expof10 > 0) then
    expof10 = (floor (expof10/3)) * 3; 
  else
    expof10 = (floor ((-expof10 + 3)/3)) * -3; 
  end

  x = x * 10^(-expof10);

  if (x >= 1000) then
    x = x / 1000
    expof10 = expof10 + 3
  elseif (x >= 100) then
    sigfigs = sigfigs - 2;
  elseif (x >= 10) then
    sigfigs = sigfigs - 1;
  end

  local fmtstring = "%." .. (sigfigs - 1) .. "f"
  if (expof10 == 0) then
    res = res .. string.format (fmtstring, x) 
  else
    res = res .. string.format (fmtstring, x) .. "E" .. expof10;
  end
  return res;
    
end

-----------------------------------------------------------------------------
--- dec2hex 
-----------------------------------------------------------------------------
function dec2hex (x)
   if (x < 0) then
     error ("Only positive whole numbers can be displayed in hex");
   end
   local xwhole = trunc (x);
   local xfrac = x - xwhole; 
   if (not (xfrac == 0)) then
     error ("Only positive whole numbers can be displayed in hex");
   end
   return string.format ("0x%x", xwhole, xfrac); 
end

-----------------------------------------------------------------------------
--- dec2rat
-----------------------------------------------------------------------------
function dec2rat (_x, improper, _error, _max_iters)

  x = tonumber(_x)
  if x == nil then
    error ("Argument " .. tostring(_x) .. 
      " cannot be converted to a real number in dec2rat")
  end

  local res = ""
  local neg = false
  local orig_x = x

  if (x < 0) then
    x = -x
    neg = true
  end

  local rat_max_iters = 10000
  if not (_max_iters == nil) then
    rat_max_iters = tonumber(_max_iters)
  end

  local eps = 0.00001
  if not (_error == nil) then
    eps = tonumber(_error)
  end

  local iters = 0
  local num = 1
  local denom = 1

  whole = floor (x)
  frac = x - whole

  if (frac == 0) then return tostring (_x) end

  if (improper) then
    local test_value = num/denom

    while ((abs (x - test_value) > eps) and (iters < rat_max_iters)) do
      if test_value < frac then
        num = num + 1
     else
        denom = denom + 1
        num = floor (round (x * denom))
      end

      test_value = num / denom
      iters = iters + 1
    end 
    if (iters < rat_max_iters) then  
      res = "" .. num .. "/" .. denom
      if (neg) then
        return "-(" .. res .. ")";
      else
        return res;
      end
    else
      error ("Argument " .. tostring(_x) .. 
        " could not be converted to a rational fraction in dec2rat")
    end
  else 
    local test_value = num/denom

    while ((abs (frac - test_value) > eps) and (iters < rat_max_iters)) do
      if test_value < frac then
        num = num + 1
     else
        denom = denom + 1
        num = floor (round (frac * denom))
      end

      test_value = num / denom
      iters = iters + 1
    end 

    if (iters < rat_max_iters) then  
      if whole == 0 then
        res = "" .. num .. "/" .. denom
      else
        res = "" .. whole .. "+" .. num .. "/" .. denom
      end 
      if (neg) then
        return "-(" .. res .. ")";
      else
        return res;
      end
    else
      error ("Argument " .. tostring(_x) .. 
        " could not be converted to a rational fraction in dec2rat")
    end
  end
end

-----------------------------------------------------------------------------
--- kcalc_format_number 
-----------------------------------------------------------------------------
function kcalc_format_number (x)
    if (_private_fmt == _private_fmt_short) then
      return (string.format ("%-.5f", x));
    elseif (_private_fmt == _private_fmt_long) then
      return (string.format ("%-.15f", x));
    elseif (_private_fmt == _private_fmt_shortE) then
      return (string.format ("%-.5G", x));
    elseif (_private_fmt == _private_fmt_longE) then
      return (string.format ("%-.15G", x));
    elseif (_private_fmt == _private_fmt_shortG) then
      return (string.format ("%-.5G", x));
    elseif (_private_fmt == _private_fmt_longG) then
      return (string.format ("%-.15G", x));
    elseif (_private_fmt == _private_fmt_bank) then
      return (string.format ("%.2f", x));
    elseif (_private_fmt == _private_fmt_hex) then
      return (dec2hex (x));
    elseif (_private_fmt == _private_fmt_longEng) then
      return (dec2eng (x, 15));
    elseif (_private_fmt == _private_fmt_shortEng) then
      return (dec2eng (x, 5));
    elseif (_private_fmt == _private_fmt_rat) then
      return (dec2rat (x));
    else
      return (string.format ("%-.15G", x));
    end
end

-----------------------------------------------------------------------------
--- format 
-----------------------------------------------------------------------------
function format (fmt)
  if (fmt == "short") then 
    _private_fmt = _private_fmt_short
  elseif (fmt == "long") then 
    _private_fmt = _private_fmt_long
  elseif (fmt == "shortE") then 
    _private_fmt = _private_fmt_shortE
  elseif (fmt == "longE") then 
    _private_fmt = _private_fmt_longE
  elseif (fmt == "shortG") then 
    _private_fmt = _private_fmt_shortG
  elseif (fmt == "longG") then 
    _private_fmt = _private_fmt_longG
  elseif (fmt == "shortEng") then 
    _private_fmt = _private_fmt_shortEng
  elseif (fmt == "longEng") then 
    _private_fmt = _private_fmt_longEng
  elseif (fmt == "bank") then 
    _private_fmt = _private_fmt_bank
  elseif (fmt == "hex") then 
    _private_fmt = _private_fmt_hex
  elseif (fmt == "rat") then 
    _private_fmt = _private_fmt_rat
  else
    error ("Unrecognized format: " .. fmt);
  end
end

-----------------------------------------------------------------------------
--- help_functions_format 
-----------------------------------------------------------------------------

kcalc_help['functions'] = kcalc_help['functions'] ..
  "Formatting functions:\n"..
  "dec2eng, dec2hex, dec2rat, format\n"..
  "\n"

kcalc_help["dec2eng"] = 
  "dec2eng(x,sf) -- Convert x to engineering notation\n\n"..
  "In engineering notiation, the exponent is always a multiple of three.\n"..
  "sf (optional) is the number of significant figures, which must be at \n"..
  "least four.\n"

kcalc_help["dec2hex"] = "dec2hex(x) -- Convert x to a hexadecimal string"

kcalc_help["dec2rat"] = 
  "dec2rat(x,improp,error,iterations) -- Convert x to a rational fraction\n\n"..
  "If improp == true, then the number may be displayed as an improper\n"..
  "fraction if x > 1.\n"..
  "Error is the error to attempt to achieve, typically < 1E-4.\n"..
  "Iterations is the maximum number of iterations the algorithm will use.\n"..
  "All arguments apart from x are optional.\n"

kcalc_help["format"] = 
  "format(fmt) -- Set number display format to the specified string\n\n"..
  "Allowable values of fmt are as follows:\n"..
  "  'short'             5 decimal places, no scientic notation\n"..
  "  'long'              15 decimal places, no scientic notation\n"..
  "  'shortE'            5 sig. figs, scientic notation\n"..
  "  'shortEng'          5 sig. figs, enginering notation\n"..
  "  'longE'             15 sig. figs, scientic notation\n"..
  "  'longEng'           15 sig. figs, engineering notation\n"..
  "  'shortG'            5 sig. figs, most compact of short and shortG\n"..
  "  'longG' (default)   15 sig. figs, most compact of long and longG\n"..
  "  'bank'              2 decimal places\n"..
  "  'hex'               hexadecimal\n"

