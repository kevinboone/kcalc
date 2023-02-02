------------------------------------------------------------------------------
--- kcalc.lua
--- This is the main initialization script for kcalc. All scripts referenced
--- Must be in the main script directory or the user script directory
---
--- This file is part of kcalc v9.0, Copyright (c)2023 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------

--- Note that the relative ordering of these first four modules
--  is significant
require "help"
require "complex"
require "basic"
require "format"
--require "stats"
--require "solve"
--require "file"
--require "calculus"
--require "financial"
--- Note that it is not an error for kcalcrc to be absent
pcall (require, "kcalcrc")

