*! SIA_COVG_03_00GC version 1.02 - Biostat Global Consulting 2017-02-04
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-17	1.01	Dale Rhoda		Remove quotes from MIN > MAX logic 
* 2017-02-04	1.02	Dale Rhoda		Edited error msgs
*******************************************************************************

program define SIA_COVG_03_00GC

	local oldvcp $VCP
	global VCP SIA_COVG_03_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"

	vcqi_log_global SIA_MAX_AGE
	vcqi_log_global SIA_MIN_AGE
	
	local exitflag 0
	
	if "$SIA_MAX_AGE" == "" {
		di as error "SIA_COVG_03: Global macro SIA_MAX_AGE required for this measure."
		vcqi_log_comment $VCP 1 Error "Global macro SIA_MAX_AGE required for this measure."
		local exitflag 1
	}
	
	if "$SIA_MIN_AGE" == "" {
		di as error "SIA_COVG_03: Global macro SIA_MIN_AGE required for this measure"
		vcqi_log_comment $VCP 1 Error "Global macro SIA_MIN_AGE required for this measure."
		local exitflag 1
	}
	
	if $SIA_MIN_AGE>=$SIA_MAX_AGE {
		di as error "SIA_COVG_03: Global macro SIA_MIN_AGE must be less than SIA_MAX_AGE."
		vcqi_log_comment $VCP 1 Error "Global macro SIA_MIN_AGE must be less than SIA_MAX_AGE."
		local exitflag 1
	}
	
	if `=strlen("$SIA_MAX_AGE")'< 3 {
		di as error "SIA_COVG_03: Global macro SIA_MAX_AGE is less than 3 characters, double check to make sure this value is filled in with days and not months or years. For the analysis to run properly this must be the max age in days."
		vcqi_log_comment $VCP 2 Warning "Global macro SIA_MAX_AGE is less than 3 characters, double check to make sure this value is filled in with days and not months or years. For the analysis to run properly this must be the max age in days."
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
