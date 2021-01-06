*! SIA_COVG_04_00GC version 1.01 - Biostat Global Consulting - 2019-01-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original
* 2019-01-09	1.01	MK Trimner		Added global PRIOR_SIA_DOSE_MAX to Control Program
*										to indicate how many prior doses should be shown
*										in output, so need to check for appropriate values and
*										set default value of PLURAL if missing
*******************************************************************************

program define SIA_COVG_04_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	foreach g in PRIOR_SIA_DOSE_MAX {
		vcqi_log_global `g'
	}
	
	local exitflag 0
	
	* Set global to upper case
	vcqi_global PRIOR_SIA_DOSE_MAX `=upper("$PRIOR_SIA_DOSE_MAX")'
	
	* If Global is not populated, set to default
	if "$PRIOR_SIA_DOSE_MAX"=="" vcqi_global PRIOR_SIA_DOSE_MAX PLURAL

	* Confirm that global takes on acceptable values
	if !inlist("$PRIOR_SIA_DOSE_MAX","SINGLE","PLURAL") {
		di as error "SIA_COVG_04: Global macro PRIOR_SIA_DOSE_MAX must be either SINGLE or PLURAL. The current value is $PRIOR_SIA_DOSE_MAX."
		vcqi_log_comment $VCP 1 Error "Global macro PRIOR_SIA_DOSE_MAX must be either SINGLE or PLURAL. The current value is $PRIOR_SIA_DOSE_MAX."
		local exitflag 1
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


	

	
