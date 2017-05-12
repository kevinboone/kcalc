------------------------------------------------------------------------------
--- kcalc.lua
--- This is the main initialization script for kcalc. All scripts referenced
--- Must be in the main script directory or the user script directory
---
--- This file is part of kcalc v8.0, Copyright (c)2012 Kevin Boone, 
--- distributed according to the terms of the GPL v2.0
------------------------------------------------------------------------------

require "help"
require "complex"
require "basic"
require "stats"
require "format"
require "solve"
require "file"
require "calculus"
require "financial"
--- Note that it is not an error for kcalcrc to be absent
pcall (require, "kcalcrc")

