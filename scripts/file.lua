--- file.lua: module: file: file read/write functions
------------------------------------------------------------------------------
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

--- get_values_from_line 
--- Splits a line at various separators, and constructs an array
--- with the Lua-language values of each token
function get_values_from_line (s) 
  local ret = nil
  local f,err = loadstring ("kcalc_temp={" .. s .. "}")
  if (f) then
    f();
    ret = kcalc_temp;
  else
    error (err)
  end
  return ret 
end



--- read_csv 
function read_csv (filename) 
  local n = 0
  local ret = {}
  local f,err = io.open (filename);
  if (f) then
    for line in f:lines() do
      n = n + 1
      local ary = get_values_from_line (line); 
      for i=1,#ary do
        local v = ary[i]
        if (type (v) == 'function') then
          error ("Invalid data item on line " .. n .. ": " 
            .. _kcalc_format (v));
        end
        ret[#ret+1] = v 
      end
    end
    io.close (f)
  else
    error ("read_csv() failed: " .. err);
  end
  return ret; 
end


--- write_csv 
function write_csv (filename,x) 
  if (type (x) == 'table') then
    local f,err = io.open (filename, "w");
    if (f) then
      local old_fmt = _private_fmt;
      _private_fmt = _private_fmt_longG;
      local res = ""
      for i=1,#x do
        res = res .. _kcalc_format (x[i],true)
        if not (i == #x) then
          res = res .. ","
        end
      end
      _private_fmt = old_fmt;
      f:write (res) 
      f:write ("\n") 
      io.close (f)
    else
      error ("write_csv() failed: " .. err);
    end
    return nil; 
  else
    error ("Argument to write_csv() must be an array");
  end
end


kcalc_help['functions'] = kcalc_help['functions'] ..
  "File-handling functions:\n"..
  "read_csv, write_csv, write_csv2\n"..
  "\n"

--- write_csv2
function write_csv2 (filename, x)
  if (type (x) == 'table') then
    local f, err = io.open (filename, "w");
    if (f) then
      local old_fmt = _private_fmt;
      _private_fmt = _private_fmt_longG;
      for i=1,#x do
        local elem = x[i];
        if (type (elem) == 'table') then
          for j=1,#elem do
            f:write (_kcalc_format (elem[j], true));
            if (j ~= #elem) then
              f:write (",");
            end
          end
        else
          f:write (_kcalc_format (x[i], true));
        end 
        f:write ("\n"); 
      end
     _private_fmt = _old_fmt;
    else
      error ("Could not open " .. filename .. "for wrting: " .. err);
    end
  else
    error ("Argument to write_csv2 must be an array");
   end
end

kcalc_help["read_csv"]=
  "read_csv(file) -- Reads comma-separated values from file into an array\n\n"..
  "read_csv() reads any number of values from a file into a flat array. ".. 
  "The layout of values within the file is ignored -- there can be one "..
  "entry per line (without or without commas at the end), or many entries "..
  "on the same line. Blank lines are ignored, as are multiple separators. "..
  "That is, '1,2' is the same as '1,,,2'. Entries must be valid KCalc "..
  "expressions so, for example, strings must be quoted, and complex "..
  "numbers must be given in the form 'a+b*i'. Entries can themselves be "..
  "arrays, with elements grouped using braces: {1,2,3}."

kcalc_help["write_csv"]=
  "write_csv(file, x) -- Writes comma-separated values from array x to file\n\n"..
  "write_csv() writes a file of comma-separated values from the array x, "..
  "in a form suitable to be read back using read_csv(). String values are "..
  "quoted, and sub-arrays enclosed in braces. Regardless of the current "..
  "formatting settings, numerical values are written out in 'longG' format, "..
  "to minimize the loss of precision when they are read back."

kcalc_help["write_csv2"]=
  "write_csv2(file, x) -- Writes array x to file, one line per item\n\n"..
  "If an element of x is itself an array, then its values are written on "..
  "the same line, separated by commas. This function is suited for writing "..
  "out two-dimensional data, where each element of the array x is itself "..
  "an array. Numeric values are written with full precision. " 

