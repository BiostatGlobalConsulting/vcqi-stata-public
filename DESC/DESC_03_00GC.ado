*! DESC_03_00GC version 1.06 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Changed 1 to 2 for warning 
*										Changed the wording on a comment
* 2016-01-18	1.02	Dale Rhoda		Changes related to vcqi_global
* 2016-03-08	1.03	Dale Rhoda		Removed warning about DESC_03_TO_TITLE
* 2016-10-19	1.04	Dale Rhoda		Improved logic for warnings on 
*										MISSING_LEVELS and SUBTOTALS
* 2017-03-26	1.05	Dale Rhoda		Allow user to :
*										a) put sub-total BEFORE a variable or response
*										b) put sub-total AFTER  a variable or response
*										c) show sub-totals only
* 2017-08-26	1.06	Mary Prier		Added version 14.1 line
*******************************************************************************

program define DESC_03_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_03_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local exitflag 0
	
	*Confirm DESC_03_DATASET is a valid dataset type and defined
		if !inlist("`=upper("$DESC_03_DATASET")'","RI","SIA", "TT") {
		di as error "DESC_03_DATASET must be RI, SIA or TT.  The current value is $DESC_03_DATASET."
		vcqi_log_comment $VCP 1 Error "DESC_03_DATASET must be RI, SIA or TT.  The current value is $DESC_03_DATASET."
		local exitflag 1
	}

	*Confirm dataset exists
	capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}_with_ids.dta" 
		if _rc!=0 {
			di as error ///
			"${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}_with_ids.dta does not exist. Run establish_unique_${DESC_03_DATASET}_ids"
			vcqi_log_comment $VCP 1 Error "Dataset does not exist to run this measurement"
			local exitflag 1
		}

		if _rc==0 {
		qui use "${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}_with_ids.dta", clear
		}
		
	
	*Confirm variables have been provided
	if "$DESC_03_VARIABLES"=="" {
			di as error "You must define global variable DESC_03_VARIABLES"
			vcqi_log_comment $VCP 1 Error "You must define global variable DESC_03_VARIABLES"
			local exitflag 1
	}
	
	*Confirm specified variables exist in global DESC_03_VARIABLES
	foreach g in $DESC_03_VARIABLES {
		capture confirm variable `g'
		if _rc!=0 {
			di as error "The variable `g' provided in global macro DESC_03_VARIABLES does not exist in dataset."
			vcqi_log_comment $VCP 1 Error "The variable `g' provided in global macro DESC_03_VARIABLES does not exist in dataset." 
			local exitflag 1
		}
	}
	
	*Confirm global variables DESC_03_SHORT_TITLE and DESC_03_SELECTED_VALUE are defined 
	foreach g in DESC_03_SHORT_TITLE DESC_03_SELECTED_VALUE {
		if "${`g'}"=="" {
			di as error "Global variable `g' must be defined."
			vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
			local exitflag 1
		}
	}
	
	*qui compress  
	qui compress
	
	*Confirm that all variables within DESC_03_VARIABLES are the same var type
	global VTYPE "`=substr("`:type `=word("$DESC_03_VARIABLES",1)''",1,3)'"
	foreach g in $DESC_03_VARIABLES {
		if "`=substr("`:type `g''",1,3)'"!="$VTYPE" {
			di as error "All variables specified in DESC_03_VARIABLES must have the same value type to be included in this measurement."
			vcqi_log_comment $VCP 1 Error "All variables specified in DESC_03_VARIABLES must have the same value type to be included in this measurement." 
			local exitflag 1
		}
	}

	*Confirm DESC_03_WEIGHTED is a valid dataset type and defined
	if !inlist("`=upper("$DESC_03_WEIGHTED")'","YES", "NO") {
		di as error "DESC_03_WEIGHTED must be YES or NO.  The current value is $DESC_03_WEIGHTED."
		vcqi_log_comment $VCP 1 Error "DESC_03_WEIGHTED must be YES or NO.  The current value is $DESC_03_WEIGHTED."
		local exitflag 1
	}
	
	*Confirm DESC_03_DENOMINATOR is a valid dataset type and defined
	*If DESC_03_WEIGHTED is YES DESC_03_DENOMINATOR must be ALL
	if "`=upper("$DESC_03_WEIGHTED")'"=="YES" & "`=upper("$DESC_03_DENOMINATOR")'"!="ALL" {
		di as error "DESC_03_DENOMINATOR must be ALL if DESC_03_WEIGHTED is YES.  The current value is $DESC_03_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error "DESC_03_DENOMINATOR must be ALL if DESC_03_WEIGHTED is YES.  The current value is $DESC_03_DENOMINATOR."
		local exitflag 1
	}

	*If DESC_03_WEIGHTED is NO DESC_03_DENOMINATOR can be ALL or RESPONDED
	if !inlist("`=upper("$DESC_03_DENOMINATOR")'","ALL", "RESPONDED") {
		di as error "DESC_03_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_03_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error "DESC_03_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_03_DENOMINATOR."
		local exitflag 1
	}
	
	
	*Confirm global values are either missing or a number for Globals DESC_03_N_MISSING_LEVELS and DESC_03_N_SUBTOTALS
	foreach g in DESC_03_N_MISSING_LEVELS DESC_03_N_SUBTOTALS {
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
	
	*If DESC_03_N_MISSING_LEVELS was blank and changed to 0 all other missing level globals will be ignored
	if $DESC_03_N_MISSING_LEVELS==0 {
		if "$DESC_03_MISSING_LEVEL_1" != "" {
			di as error ///
			"Warning: Global macro DESC_03_MISSING_LEVEL_1 is defined but DESC_03_N_MISSING_LEVELS is 0 or not defined so no levels will be re-labeled."
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_03_MISSING_LEVEL_1 is defined but DESC_03_N_MISSING_LEVELS is 0 or not defined so no levels will be re-labeled."
		}
	}
		
	
	*Confirm each missing level and label is populated for each N_MISSING LEVEL
	if $DESC_03_N_MISSING_LEVELS!=0 {
		forvalues i = 1/$DESC_03_N_MISSING_LEVELS {
			foreach g in DESC_03_MISSING_LEVEL_`i' DESC_03_MISSING_LABEL_`i' {
				if "${`g'}"=="" {
					di as error "Global variable `g' must be defined."
					vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
					local exitflag 1
				}
			}
		}
	}
	
	*If DESC_03_N_SUBTOTALS was blank and changed to 0 all other subtotal level globals be ignored
	if $DESC_03_N_SUBTOTALS==0 {
		if "$DESC_03_SUBTOTAL_LEVELS_1" != "" {
			di as error ///
			"Warning: Global macro DESC_03_SUBTOTAL_LEVELS_1 is defined but DESC_03_N_SUBTOTALS is undefined or zero, so no subtotals will be calculated."
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_03_SUBTOTAL_LEVELS_1 is defined but DESC_03_N_SUBTOTALS is undefined or zero, so no subtotals will be calculated."
		}
	}		
	
	*Confirm each subtotal level and label is populated for each N_SUBTOTALS
	if $DESC_03_N_SUBTOTALS!=0 {
		forvalues i = 1/$DESC_03_N_SUBTOTALS {
			foreach g in DESC_03_SUBTOTAL_LEVELS_`i' DESC_03_SUBTOTAL_LABEL_`i' {
				if "${`g'}"=="" {
					di as error "Global variable `g' must be defined."
					vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
					local exitflag 1
				}
			}
			
			* If SUBTOTAL_LIST is defined, then confirm that
			* a) it holds only two words
			* b) the first word is either BEFORE or AFTER
			* c) the second word is a variable from DESC_03_VARIABLES
			
			if "${DESC_03_SUBTOTAL_LIST_`i'}" != "" {
				if wordcount("${DESC_03_SUBTOTAL_LIST_`i'}") != 2 {
					di as error ///
					"Global DESC_03_SUBTOTAL_LIST_`i' is defined but does not have two words. (It is currently "${DESC_03_SUBTOTAL_LIST_`i'}".) The first word should be BEFORE or AFTER.  The second word should be the name of a variable from DESC_03_VARIABLES."
					vcqi_log_comment $VCP 1 Error ///
					"Global DESC_03_SUBTOTAL_LIST_`i' is defined but does not have two words. (It is currently "${DESC_03_SUBTOTAL_LIST_`i'}".) The first word should be BEFORE or AFTER.  The second word should be the name of a variable from DESC_03_VARIABLES."
					local exitflag 1
				}
				if !inlist("`=word("${DESC_03_SUBTOTAL_LIST_`i'}",1)'","BEFORE","AFTER") {
					di as error ///
					"The first word of global DESC_03_SUBTOTAL_LIST_`i' should be BEFORE or AFTER.  It is currently `=word("${DESC_03_SUBTOTAL_LIST_`i'}",1)'."
					vcqi_log_comment $VCP 1 Error ///
					"The first word of global DESC_03_SUBTOTAL_LIST_`i' should be BEFORE or AFTER.  It is currently `=word("${DESC_03_SUBTOTAL_LIST_`i'}",1)'."
					local exitflag 1
				}
				local listmatch 0
				foreach g in $DESC_03_VARIABLES {
					if "`g'" == "`=word("${DESC_03_SUBTOTAL_LIST_`i'}",2)'" local listmatch 1
				}
				if `listmatch' == 0 {
					di as error ///
					"The second word of global DESC_03_SUBTOTAL_LIST_`i' should be one of the variables listed in DESC_03_VARIABLES.  It is currently `=word("${DESC_03_SUBTOTAL_LIST_`i'}",2)'."
					vcqi_log_comment $VCP 1 Error ///
					"The second word of global DESC_03_SUBTOTAL_LIST_`i' should be one of the variables listed in DESC_03_VARIABLES.  It is currently `=word("${DESC_03_SUBTOTAL_LIST_`i'}",2)'."
					local exitflag 1
				}				
			}
		}
	}
	
	* Confirm that if "${DESC_03_SHOW_SUBTOTALS_ONLY"}" then the user has not also specified 
	* any SUBTOTAL_LEVEL globals
	
	if "${DESC_03_SHOW_SUBTOTALS_ONLY"}" != "" {
		forvalues i = 1/$DESC_03_N_SUBTOTALS {
			if "${DESC_03_SUBTOTAL_LIST_`i'}" != "" {
				di as error ///
				"If you specify to DESC_03_SHOW_SUBTOTALS_ONLY then you cannot also specify SUBTOTAL_LIST; you have specified DESC_03_SUBTOTAL_LIST_`i'."
				vcqi_log_comment $VCP 1 Error ///
				"If you specify to DESC_03_SHOW_SUBTOTALS_ONLY then you cannot also specify SUBTOTAL_LIST; you have specified DESC_03_SUBTOTAL_LIST_`i'."
				local exitflag 1
			}		
		}
	}			
			
	*Confirm all variables listed in the DESC_03_MISSING_LEVELS and DESC_03_SUBTOTAL_LEVELS
	*Are included in the DESC_03_VARIABLES global variable
	
	if $DESC_03_N_SUBTOTALS!=0 {
		forvalues i = 1/$DESC_03_N_SUBTOTALS {
			foreach g in ${DESC_03_SUBTOTAL_LEVELS_`i'} {
				local match 0
				foreach d in $DESC_03_VARIABLES {
				
					if "`g'" == "`d'" local match 1
				}
				if `match'==0 {
					di as error "Variable `g' in DESC_03_SUBTOTAL_LEVELS_`i' is not inlcuded in DESC_03_VARIABLES"
					vcqi_log_comment $VCP 1 Error "Variable `g' in DESC_03_SUBTOTAL_LEVELS_`i' is not inlcuded in DESC_03_VARIABLES"
					local exitflag 1
				}
			}	
		}
	}
	
	
		if $DESC_03_N_MISSING_LEVELS!=0 {
		forvalues i = 1/$DESC_03_N_MISSING_LEVELS {
			foreach g in ${DESC_03_MISSING_LEVEL_`i'} {
				local match 0
				foreach d in $DESC_03_VARIABLES {
					if "`g'" == "`d'" local match 1
				}
				if `match'==0 {
					di as error "Variable `g' in DESC_03_MISSING_LEVEL_`i' is not inlcuded in DESC_03_VARIABLES"
					vcqi_log_comment $VCP 1 Error "Variable `g' in DESC_03_MISSING_LEVEL_`i' is not inlcuded in DESC_03_VARIABLES"
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
