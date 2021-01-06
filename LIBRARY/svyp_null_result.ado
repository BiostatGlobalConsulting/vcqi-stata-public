*! svyp_null_result version 1.01 - Biostat Global Consulting - 2018-07-05
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed

* 2016-10-23	1.00	Dale Rhoda		First version
* 2018-07-05	1.01	?				? Different date in top line than 2016-10-23
*-------------------------------------------------------------------------------

program define svyp_null_result, rclass	
	version 14.1
	
	* This is a simple program that returns null results if a user
	* calls the svypd program on a subpopulation of size 0 
	* or a population of non-zero size, but for whom the response 
	* is missing for every respondent.
	
	return scalar 	clusters 	= 0
	return scalar 	Nwtd 		= 0
	return scalar 	N 			= 0
	return local 	method 		= ""
	return scalar 	deff 		= .
	return scalar 	df 			= 0
	return local 	cilevellist = "`cilevellist'"
	return scalar 	ub_2alpha  	= .
	return scalar 	lb_2alpha  	= .
	return scalar 	ub_alpha 	= .
	return scalar 	lb_alpha 	= .
	return scalar 	stderr 		= .
	return scalar 	svyp 		= .
	
	matrix ci_list = [95, ., .] \ [90, ., .]
	matrix colnames ci_list = level  lcb_2sided  ucb_2sided
	return matrix 	ci_list 	= ci_list
	
end
