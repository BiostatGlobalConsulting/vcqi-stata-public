*! DESC_02_00GC version 1.03 - Biostat Global Consulting 2016-10-19
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-10	1.02	Dale Rhoda		Changed no missing and no subtotals
*                                       from warning to comment
* 2016-10-19	1.03	Dale Rhoda		Improved logic for warnings on 
*										MISSING_LEVELS and SUBTOTALS
*******************************************************************************

program define DESC_02_00GC

	local oldvcp $VCP
	global VCP DESC_02_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local exitflag 0
	
	*Confirm DESC_02_DATASET is a valid dataset type and defined
		if !inlist("`=upper("$DESC_02_DATASET")'","RI","SIA", "TT") {
		di as error "DESC_02_DATASET must be RI, SIA or TT.  The current value is $DESC_02_DATASET."
		vcqi_log_comment $VCP 1 Error "DESC_02_DATASET must be RI, SIA or TT.  The current value is $DESC_02_DATASET."
		local exitflag 1
	}

	*Confirm dataset exists
	capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}_with_ids.dta" 
		if _rc!=0 {
			di as error ///
			"${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}_with_ids.dta does not exist. Run establish_unique_${DESC_02_DATASET}_ids"
			vcqi_log_comment $VCP 1 Error "Dataset does not exist to run this measurement"
			local exitflag 1
		}

		if _rc==0 {
		qui use "${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}_with_ids.dta", clear
		}
		
	
	*Confirm variables have been provided
	if "$DESC_02_VARIABLES"=="" {
			di as error "You must define global variable DESC_02_VARIABLES"
			vcqi_log_comment $VCP 1 Error "You must define global variable DESC_02_VARIABLES"
			local exitflag 1
	}
	
	*Confirm specified variables exist in global DESC_02_VARIABLES
	foreach g in $DESC_02_VARIABLES {
		capture confirm variable `g'
		if _rc!=0 {
			di as error "The variable `g' provided in global macro DESC_02_VARIABLES does not exist in dataset."
			vcqi_log_comment $VCP 1 Error "The variable `g' provided in global macro DESC_02_VARIABLES does not exist in dataset." 
			local exitflag 1
		}
	}
	
	*Confirm DESC_02_WEIGHTED is valid & defined
	if !inlist("`=upper("$DESC_02_WEIGHTED")'","YES", "NO") {
		di as error "DESC_02_WEIGHTED must be YES or NO.  The current value is $DESC_02_WEIGHTED."
		vcqi_log_comment $VCP 1 Error "DESC_02_WEIGHTED must be YES or NO.  The current value is $DESC_02_WEIGHTED."
		local exitflag 1
	}
	
	*Confirm DESC_02_DENOMINATOR is valid and defined
	*If DESC_02_WEIGHTED is YES DESC_02_DENOMINATOR must be ALL
	if "`=upper("$DESC_02_WEIGHTED")'"=="YES" & "`=upper("$DESC_02_DENOMINATOR")'"!="ALL" {
		di as error "DESC_02_DENOMINATOR must be ALL if DESC_02_WEIGHTED is YES.  The current value is $DESC_02_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error "DESC_02_DENOMINATOR must be ALL if DESC_02_WEIGHTED is YES.  The current value is $DESC_02_DENOMINATOR."
		local exitflag 1
	}

	*If DESC_02_WEIGHTED is NO DESC_02_DENOMINATOR can be ALL or RESPONDED
	if !inlist("`=upper("$DESC_02_DENOMINATOR")'","ALL", "RESPONDED") {
		di as error "DESC_02_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_02_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error "DESC_02_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_02_DENOMINATOR."
		local exitflag 1
	}
	
	* Gently remind the user that missing values are not tabulated when the denominator is RESPONDED
	if "`=upper("$DESC_02_DENOMINATOR")'" == "RESPONDED" ///
		vcqi_log_comment $VCP 3 Comment "DESC_02 denominator is RESPONDED so missing values will not be tabulated."

	*Confirm global values are either missing or a number for Globals DESC_02_N_MISSING_LEVELS and DESC_02_N_SUBTOTALS
	foreach g in DESC_02_N_MISSING_LEVELS DESC_02_N_SUBTOTALS {
		if "${`g'}"==""{
			global `g' 0
		}
		capture confirm number ${`g'}
		if _rc!=0 {
			di as error "Global variable `g' must be a numeric value. The current value is ${`g'}"
			vcqi_log_comment $VCP 1 Error "Global variable `g' must be a numeric value. The current value is ${`g'}"
			local exitflag 1
		}
				
		if  ${`g'} < 0 {
			di as error "Global variable `g' must be a number >= zero. The current value is ${`g'}"
			vcqi_log_comment $VCP 1 Error "Global variable `g' must be a number >= zero. The current value is ${`g'}"	
			local exitflag 1
			
		}
	}
	
	*If DESC_02_N_MISSING_LEVELS was blank and changed to 0 all other missing level globals will be ignored
	if $DESC_02_N_MISSING_LEVELS==0 {
		if "$DESC_02_MISSING_LEVEL_1" != "" {
			di as error ///
			"Warning: Global macro DESC_02_MISSING_LEVEL_1 is defined, but DESC_02_N_MISSING_LEVELS is 0 or not defined, so no levels will be re-labeled"
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_02_MISSING_LEVEL_1 is defined, but DESC_02_N_MISSING_LEVELS is 0 or not defined, so no levels will be re-labeled"
		}
	}
		
	
	*Confirm each missing level and label is populated for each N_MISSING LEVEL
	if $DESC_02_N_MISSING_LEVELS!=0 {
		forvalues i = 1/$DESC_02_N_MISSING_LEVELS {
			foreach g in DESC_02_MISSING_LEVEL_`i' DESC_02_MISSING_LABEL_`i' {
				if "${`g'}"=="" {
					di as error "Global variable `g' must be defined."
					vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
					local exitflag 1
				}
			}
		}
	}
	
	*If DESC_02_N_SUBTOTALS was blank and changed to 0 all other subtotal level globals be ignored
	if $DESC_02_N_SUBTOTALS==0 {
		if "$DESC_02_SUBTOTAL_LEVELS_1" != "" {
			di as error ///
			"Warning: Global macro DESC_02_SUBTOTAL_LEVELS_1 is defined, but DESC_02_N_SUBTOTALS is 0 or not defined, so no subtotals will be calculated."
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_02_SUBTOTAL_LEVELS_1 is defined, but DESC_02_N_SUBTOTALS is 0 or not defined, so no subtotals will be calculated."
		}
	}
		
	
	*Confirm each missing level and label is populated for each N_MISSING LEVEL
	if $DESC_02_N_SUBTOTALS!=0 {
		forvalues i = 1/$DESC_02_N_SUBTOTALS {
			foreach g in DESC_02_SUBTOTAL_LEVELS_`i' DESC_02_SUBTOTAL_LABEL_`i' {
				if "${`g'}"=="" {
					di as error "Global variable `g' must be defined."
					vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
					local exitflag 1
				}
			}
		}
	}

	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		di `exitflag'
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
		
	
	
	



