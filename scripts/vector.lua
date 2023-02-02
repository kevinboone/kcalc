--- vector.lua: module: vector: operations on vectors 
------------------------------------------------------------------------------
--- This file is part of kcalc v9.0, Copyright (c)2012 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

function dot_product(x, y)
  if (type (x) ~= 'table' or type (y) ~= 'table') then
    error "dot_product: arguments must be vectors (arrays)";
  end

  if (#x ~= #y) then
    error "dot_product: vectors must have the same number of dimensions";
  end

  local result = 0

  for i = 1,#x do
    result = result + x[i]*y[i]
  end

  return result
end

function cross_product(x, y)
  if (type (x) ~= 'table' or type (y) ~= 'table') then
    error "cross_product: arguments must be vectors (arrays)";
  end

  if (#x ~= 3 or #y ~= 3) then
    error "cross_product: vectors must be three-dimensional";
  end

  return {x[2]*y[3] - x[3]*y[2], x[3]*y[1]-x[1]*y[3], x[1]*y[2] - x[2]*y[1]} 
end

function vector_modulus (v)
  if (type (v) ~= 'table') then
    error "vector_modulus: argument must be a vector (array)";
  end
  local result = 0;
  for i = 1,#v do
    result = result + (v[i] * v[i]);
  end
  return sqrt(result);
end

function scale_vector (a, v)
  if (type (v) ~= 'table') then
    error "scale vector: second argument must be a vector";
  end

  result = {};
  for i = 1,#v do
    result[#result + 1] = v[i] * a 
  end

  return result;
end

function add_vectors (x, y)
  if (type (x) ~= 'table' or type (y) ~= 'table') then
    error "add_vectors: arguments must be vectors (arrays)";
  end

  if (#x ~= #y) then
    error "add_vectors: vectors must have the same number of dimensions";
  end

  result = {};
  for i = 1,#x do
    result[#result + 1] = x[i] + y[i]; 
  end

  return result 
end


--- mod() overwrites the version in basic.lua to include vector modulus
function mod (x)
  if (type (x) == 'table') then
    return vector_modulus (x);
  else
    return abs (x); 
  end
end

kcalc_help["mod"]="mod(x) -- Modulus of complex x; absolute value of real x; modulus (length) of vector x"
kcalc_help["add_vectors"]="add_vectors(x,y) -- add the corresponding elements in x and y"
kcalc_help["dot_product"]="dot_produt(x,y) -- dot (scalar) product of vectors x and y"
kcalc_help["cross_product"]="cross_produt(x,y) -- cross (vector) product of vectors x and y"
kcalc_help["scale_vector"]="scale_vector(a,v) -- scale vector v by real or complex a"

kcalc_help['functions'] = kcalc_help['functions'] ..
  "Vector functions:\n"..
  "add_vectors, cross_product, dot_product, scale_vector\n"..
  "\n"


