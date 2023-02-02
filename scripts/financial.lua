--- financial.lua: module: financial: simple financial functions
------------------------------------------------------------------------------
--- This file is part of kcalc v9.0, Copyright (c)2012 Kevin Boone, 
--- distributed according to the terms of the GPL v3.0
------------------------------------------------------------------------------


--- compound_interest 
function compound_interest (C, r, t, n)
  if (n == nil) then n = 1; end
  return C * (1 + r / n)^(n * t)
end

--- loan_balance 
function loan_balance (C, r, t, P, n)
  if (n == nil) then n = 1; end
  return C * (1 + r / n)^(n * t) - 
    P * (((1+r/n)^(n*t) - 1)/((1+r/n) - 1)) 
end

--- loan_repayment
function loan_repayment (C, r, t, n)
  if (n == nil) then n = 1; end
  -- standard formula fails if r == 0
  if (r == 0) then return C / n / t end;
  local i = r / n;
  local mpay  = C * i / (1 - exp (-(n * t * log (1 + i))))
  return mpay
end

kcalc_help['functions'] = kcalc_help['functions'] ..
  "Financial functions:\n"..
  "compound_interest, loan_balance, loan_repayment\n"..
  "\n"


kcalc_help["compound_interest"]=
  "compound_interest(C,r,t,n) -- Compound interest on a sum of money\n\n"..
  "Calculates the total value of a sum of money C invested for t terms "..
  "at a fractional termly interest rate of r, with interest compounded "..
  "n times per term. The argument n is optional, and defaults to 1.\n\n"..
  "Example: Determine the value after ten years of an investment of "..
  "£10,000, compounded monthly, at an annual interest rate of 6%:\n"..
  "expr> !format ('bank')\n"..
  "expr> compound_interest (10000, .06, 10, 12)\n"..
  "18193.97"

kcalc_help["loan_balance"]=
  "loan_balance(C,r,t,P,n) -- Balance outstanding on a loan of money\n\n"..
  "Calculates the amount outstanding on a loan of amount C, after t terms "..
  "at a fractional termly interest rate of r per term, compounded n times "..
  "per term, allowing for repayments n times per term, each of amount P. "..
  "The argument n is optional and defalts to 1.\n"..
  "\n"..
  "Example: Determine the amount remaining on a loan of £10,000, after "..
  "five years at an interest rate of 6% per year, when repaying £100 "..
  "per month:\n"..
  "expr> !format ('bank')\n"..
  "expr> loan_balance (10000,.06,5,100,12)\n"..
  "6511.50\n"..
  "\n"..
  "Note that this function is only valid for situations where the "..
  "repayment interval is the same as the compounding interval."

kcalc_help["loan_repayment"]=
  "loan_repayment(C,r,t,n) -- Repayment amount on a loan of money\n\n"..
  "Calculates the regular payments needed to clear a loan of amount C, "..
  "with a fractional termly interest rate of r per term, over t terms, "..
  "with repayments n times per term, and interest compounded at the same "..
  "intervals as repayments. "..
  "\n"..
  "Example: Determine the monthly repayment needed to clear a loan of "..
  "£140,000, at an annual interest rate of 6%, over 25 years:"..
  "\n"..
  "expr> !format ('bank')\n"..
  "expr> loan_repayment (140000,.06,25,12)\n"..
  "902.02"




