--- stats.lua: module: stats: simple statistics functions 
------------------------------------------------------------------------------
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

function _mean (tab)
  if #tab == 0 then
    error ("Function mean(...) requires at least one argument");
  end
  local sum = 0;
  for i = 1,#tab do
    sum = sum + tab[i]
  end
  return sum / #tab;
end

function mean (...)
  local z = {...}
  if type(z[1]) == 'table' then
    return _mean (z[1])
  else
    return _mean (z)
  end
end

function _median (tab)
  if #tab == 0 then
    error ("Function median(...) requires at least one argument");
  end
  local n = #tab; 
  table.sort (tab);
  local m = 0;
  if (n % 2 == 0) then
    --- even
   m = tab[n / 2] + tab[n / 2 + 1]
   m = m / 2
  else
    --- odd 
   m = tab[(n + 1) / 2]
  end
  return m; 
end

function median (...)
  local z = {...}
  if type(z[1]) == 'table' then
    return _median (z[1])
  else
    return _median (z)
  end
end

function _max (tab)
    return math.max (unpack (tab))
end

function max (...)
  local z = {...}
  if type(z[1]) == 'table' then
    return _max (z[1])
  else
    return math.max (unpack (z))
  end
end

function _min (tab)
    return math.min (unpack (tab))
end

function min (...)
  local z = {...}
  if type(z[1]) == 'table' then
    return _min (z[1])
  else
    return math.min (unpack (z))
  end
end

function _mode (tab)
  local freq = {}
  local values = {}
  for i = 1,#tab do
    local hash = tostring(tab[i])
    if freq[hash] == nil then
      freq[hash] = 0
      values[hash] = tab[i]
    end
    freq[hash] = freq[hash] + 1;
  end
  local modal_value = -1
  local modal_hash = ""
  for i,v in pairs(freq) do
    if v > modal_value then 
      modal_value = v
      modal_hash = i
    end
  end 
  return values[modal_hash];
end

function mode (...)
  local z = {...}
  if type(z[1]) == 'table' then
    return _mode (z[1])
  else
    return _mode (z) 
  end
end

function _var (xx, flag)
  local sumsq = 0;
  local m = mean (xx);
  for i = 1,#xx do
    sumsq = sumsq + (xx[i] - m) * (xx[i] - m) 
  end
  if (flag == 1) then
    return sumsq / #xx;
  else
    return sumsq / (#xx - 1);
  end
end

function var (xx, flag)
  if not (type(xx) == 'table') then
   error ("First argument to var must be a table"); 
  else
    return _var (xx, flag) 
  end
end

function _std (xx, flag)
  return sqrt (var (xx, flag));
end

function std (xx, flag)
  if not (type(xx) == 'table') then
   error ("First argument to std must be a table"); 
  else
    return _std (xx, flag) 
  end
end

function cov (xx, yy)
  if not (type(xx) == 'table') then
    error ("First argument to cov must be a table"); 
  end
  if not (type(yy) == 'table') then
    error ("second argument to cov must be a table"); 
  end
  local N = #xx
  if (not (#yy == N)) then
    error ("x and y data sets are not of the same size"); 
  end
  local sxy = 0;
  local sx = 0;
  local sy = 0;
  for i = 1,N do
    sxy = sxy + (xx[i] * yy[i])
    sx = sx + xx[i];
    sy = sy + yy[i];
  end
  return (sxy - sx * sy / N) / (N - 1);
end

function linreg (xx, yy)
  if not (type(xx) == 'table') then
    error ("First argument to linreg must be a table"); 
  end
  if not (type(yy) == 'table') then
    error ("second argument to linreg must be a table"); 
  end
  local N = #xx
  if (not (#yy == N)) then
    error ("x and y data sets are not of the same size"); 
  end
  local xmean = mean (xx);
  local ymean = mean (yy);
  local b = cov (xx,yy) / (var (xx,0));
  local a = ymean - b * xmean;
  local r = sqrt (cov (xx,yy) * cov (xx,yy) / var(xx) /  var(yy));
  return {a, b, r}
end

kcalc_help['functions'] = kcalc_help['functions'] ..
  "Statistical functions:\n"..
  "cov, linreg, std, max, mean, median, min, mode, var\n"..
  "\n"


kcalc_help["cov"]=
  "cov({x1,x2,...),{y1,y2,...}) -- Covariance of two arrays\n\n"..
  "Covariance is the mean of the products of the deviations of the "..
  "x's and the corresponding y's from their respective means."

kcalc_help["linreg"]=
  "linreg({x1,x2,...),{y1,y2,...}) -- Linear regression\n\n"..
  "Determines the coefficients of the linear equation that represents the "..
  "best straight-line fit between the data points (x1,y1), (x2,y2)..."..
  "Values are determined by simple least-squares fitting. linreg() returns "..
  "an array with three values: the y-intercept, the slope of the fit line, "..
  "and the correlation coefficient. "..
  "\n"..
  "Example:\n"..
  "\n"..
  "expr> linreg ({1,2,3,4,5},{-3,-5,-7,-9,-11})\n"..
  "{-1,-2,1}\n"..
  "\n"..
  "The best fit line is represented by the equation y = (-1) + (-2)x "..
  "with a correlation coefficient of 1.0 (a perfect straight line). "

kcalc_help["max"]="max(x1,x2,...) -- Maximum of list of numbers\n\n"..
  "The x's can be a list of arguments, or a single table in x1. "..
  "If x1 is a table, then the other arguments are ignored."

kcalc_help["mean"]=
  "mean(x1,x2,...) -- Arithmetical mean of list of numbers\n\n"..
  "The x's can be a list of arguments, or a single table in x1."..
  "If x1 is a table, then the other arguments are ignored."

kcalc_help["median"]=
  "median(x1,x2,...) -- Median value of list of numbers\n\n"..
  "The x's can be a list of arguments, or a single table in x1. "..
  "If x1 is a table, then the other arguments are ignored."

kcalc_help["min"]="min(x1,x2,...) -- Minimum of list of numbers\n\n"..
  "The x's can be a list of arguments, or a single table in x1."..
  "If x1 is a table, then the other arguments are ignored."

kcalc_help["mode"]="mode(x1,x2,...) -- Modal value of list of numbers\n\n"..
  "The x's can be a list of arguments, or a single table in x1. "..
  "If x1 is a table, then the other arguments are ignored. "..
  "This function does not handle multi-modal or non-modal data: "..
  "exactly one mode is always returned, if there is any input at all. "..
  "The mode function is defined on any type of data, in any combination. "

kcalc_help["std"]=
"std({x1,x2,...}, flag) -- Standard deviation of list of numbers\n\n"..
"The standard devation is calculated using Bessel's correction (providing "..
"an unbiased estimator of the population standard deviation), unless ".. 
"flag==1, in which case the uncorrected second moment is returned."

kcalc_help["var"]="var({x1,x2,...}, flag) -- Variance of list of numbers\n\n"..
  "The variance is calculated using Bessel's correction (providing an "..
  "unbiased estimator of the population variance), unless flag==1, in "..
  "which case the uncorrected second moment is returned."



