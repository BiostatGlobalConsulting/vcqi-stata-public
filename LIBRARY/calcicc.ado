*! calcicc version 1.04 - Biostat Global Consulting - 2020-12-04
********************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
********************************************************************************
* 2020-05-26	1.0		Dale Rhoda		Original version
* 2020-05-28	1.01	Dale Rhoda		Handle missing outcomes (Thanks, Cait!)
* 2020-06-01	1.02	Dale Rhoda		count quietly	
* 2020-06-08    1.03	Dale Rhoda		Added if & screen output
* 2020-12-04	1.04	Dale Rhoda		Changed default to 1/(mwtd-1) if 
*                                       neither ms_between or ms_within is > 0
*                                       (meaning that p-hat is 0% or 100%)
*
*                                       So whenever coverage is identical in
*                                       all PSUs, the icc should be -1/(mwtd-1)
*
*                                       mwtd is sometimes called n0 in ICC 
*                                       literature
********************************************************************************
*
* Program to calculate ICC without truncating it at 0
*
* Argument 1 is the outcome
* Argument 2 is the name of the clusterid
*
* This program is used by VCQI and by the bootstrap command in iccloop
*

program calcicc , rclass

syntax varlist [if]

if "`if'" != "" {
	local if `if' & !missing(`1')
}
else {
	local if if !missing(`1')
}

qui loneway_plus `1' `2' `if'

scalar ms_between = r(ms_b)
scalar ms_within  = r(ms_w)

qui count `if'
local bigN = r(N)

preserve
	contract `2' `if'
	gen summand = _freq * _freq / `bigN'
	egen summit = total(summand)
	scalar mwtd = (`bigN' - summit) / `=_N -1'
restore	

if ms_between > 0 | ms_within > 0  scalar icc = (ms_between - ms_within) / (ms_between + (mwtd - 1) * ms_within)
else scalar icc = -1 / (mwtd-1)

return scalar anova_icc = icc
return scalar n0 = mwtd

di as text "ANOVA ICC = `=string(`=scalar(icc)',"%7.5f")'"

end
