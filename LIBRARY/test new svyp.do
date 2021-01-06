*! test new svyp version 1.00 - Biostat Global Consulting - 2017-05-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-05-09	1.00	Dale Rhoda		Original version								
*******************************************************************************

set seed 199

clear
set more off
set obs 210
gen y = 0
gen id = mod(_n,7)+1
bysort id: gen clusterid = _n
sort clusterid id
gen rand = runiform()
sort rand
replace y = _n <= _N/2
tab y

svyset clusterid, || _n
svyset _n
*svyset _n
*replace y = 0
svyp_with_levellist y, method(wald) adjust truncate cilevellist(0.01 50 95 99.99)
return list
matrix list r(ci_alpha)
matrix list r(ci_list)

di .5-invnormal(.975)*sqrt(.25/209)
di .5+invnormal(.975)*sqrt(.25/209)

capture program drop svyp_with_levellist
capture program drop svyp_ci_calculator

svyp_ci_calculator , n(210) p(.5) stderr(`=sqrt(.25/210)') truncate method(wilson) dof(209)
return list

svyp_ci_calculator , n(210) p(.5) stderr(`=sqrt(.25/105)') truncate method(wilson)
return list

svyp_ci_calculator , n(99.5) p(.5) stderr(`=sqrt(.25/105)') truncate method(wilson)
return list


capture program drop svyp_with_levellist
capture program drop svyp_ci_calculator
capture program drop iwplot_svyp
capture program drop excel_wrapper_for_iwplot_svyp

svyp_ci_calculator , n(85) p(1) stderr(0) truncate method(wald) cilevellist(10 50 75 95 99.99)
return list
matrix list r(ci_list)
