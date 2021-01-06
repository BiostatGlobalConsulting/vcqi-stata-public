*! DESC_03_00GC version 1.11 - Biostat Global Consulting - 2018-01-23
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
* 2018-01-10	1.07	Dale Rhoda		Make MISSING a synonym of RELABEL
* 2018-01-16	1.08	MK Trimner		Fixed RELABEL code
* 2018-01-16	1.08	MK Trimner		Added label option for N and NWTD
* 2018-01-16	1.09	Dale Rhoda		Make dataset name more generic *AND*
* 										backward compatible
* 2018-01-17	1.10	MK Trimner		Added code to check that all variables provided
*										in subtotal globals (LEVELS and LIST) were
*										included in the DESC_03_VARIABLES global
* 2018-01-17	1.10	MK Trimner		Changed the BEFORE and AFER check to look at the upper tense
*										Changed SUBTOTAL_ONLY and SUBTOTAL_LIST logic
*										so that SUBTOTAL_LIST globals are wiped out 
*										and put warning to log/screen if 
*										SUBTOTAL_ONLY is specified rather than exit vcqi
* 2018-01-23	1.11	MK Trimner		Removed code added for SUBTOTAL checks as already existed
*										Removed quotes around ${DESC_03_SUBTOTAL_LIST_`i'} in global check 
*										error message for word count
*******************************************************************************

program define DESC_03_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_03_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local exitflag 0
	
	if "$DESC_03_DATASET" == "" {
		di as error                   "You must specify DESC_03_DATASET."
		vcqi_log_comment $VCP 1 Error "You must specify DESC_03_DATASET."
		local exitflag 1
	}
	
	* Make this code backward compatible; in the old days the user simply 
	* specified RI, TT or SIA for the dataset string and this code assumed 
	* that the dataset was equal to that string plus _with_ids.dta.
	* Now the user is encouraged to specify the name of the dataset explicitly
	* but for backward compatibility, if they specify only RI, TT or SIA then
	* we check to see if the _with_ids.dta dataset exists.  If it does, we
	* concatenate the string _with_ids onto the dataset name global.  If it does
	* not exist, but there is a dataset named RI or TT or SIA then we do not
	* concatenate onto the global.
		
	* Strip off the .dta if the user provided it
	if lower(substr("$DESC_03_DATASET",-4,4)) == ".dta" global DESC_03_DATASET = subinstr("$DESC_03_DATASET",".dta","",.)
		
	if inlist("`=upper("$DESC_03_DATASET")'","RI","SIA", "TT") {
		capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}_with_ids.dta"
		* If the _with_ids dataset exists, update the global
		if _rc == 0 vcqi_global DESC_03_DATASET ${DESC_03_DATASET}_with_ids
		else {
			* Else check to see if there's a dataset present without _with_ids
			capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}.dta"
			if _rc != 0 {
				di as error ///
				"DESC_03_DATASET is ${DESC_03_DATASET} but there is no dataset named ${DESC_03_DATASET} or named ${DESC_03_DATASET}_with_ids in the VCQI output folder."
				vcqi_log_comment $VCP 1 Error ///
				"DESC_03_DATASET is ${DESC_03_DATASET} but there is no dataset named ${DESC_03_DATASET} or named ${DESC_03_DATASET}_with_ids in the VCQI output folder."
				local exitflag 1
			}
		}
	}	

	* Confirm dataset exists
	capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}.dta" 
	if _rc!=0 {
		di as error ///
		"${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}.dta does not exist."
		vcqi_log_comment $VCP 1 Error ///
		"${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}.dta does not exist."
		local exitflag 1
	}
	else qui use "${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}", clear
	
	* Confirm variables have been provided
	if "$DESC_03_VARIABLES"=="" {
			di as error ///
			"You must define global variable DESC_03_VARIABLES"
			vcqi_log_comment $VCP 1 Error ///
			"You must define global variable DESC_03_VARIABLES"
			local exitflag 1
	}
	
	* Confirm specified variables exist in global DESC_03_VARIABLES
	foreach g in $DESC_03_VARIABLES {
		capture confirm variable `g'
		if _rc!=0 {
			di as error ///
			"The variable `g' provided in global macro DESC_03_VARIABLES does not exist in dataset."
			vcqi_log_comment $VCP 1 Error ///
			"The variable `g' provided in global macro DESC_03_VARIABLES does not exist in dataset." 
			local exitflag 1
		}
	}
	
	* Confirm global variables DESC_03_SHORT_TITLE and DESC_03_SELECTED_VALUE are defined 
	foreach g in DESC_03_SHORT_TITLE DESC_03_SELECTED_VALUE {
		if "${`g'}"=="" {
			di as error                   "Global variable `g' must be defined."
			vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
			local exitflag 1
		}
	}
	
	qui compress
	
	* Confirm that all variables within DESC_03_VARIABLES are the same var type
	global VTYPE "`=substr("`:type `=word("$DESC_03_VARIABLES",1)''",1,3)'"
	foreach g in $DESC_03_VARIABLES {
		if "`=substr("`:type `g''",1,3)'"!="$VTYPE" {
			di as error ///
			"All variables specified in DESC_03_VARIABLES must have the same value type to be included in this measurement."
			vcqi_log_comment $VCP 1 Error ///
			"All variables specified in DESC_03_VARIABLES must have the same value type to be included in this measurement." 
			local exitflag 1
		}
	}

	* Set default N and NWTD labels if not specified
	if "$DESC_03_N_LABEL"=="" 		vcqi_global DESC_03_N_LABEL N
	if "$DESC_03_NWTD_LABEL"=="" 	vcqi_global DESC_03_NWTD_LABEL Weighted N
	
	* Confirm DESC_03_WEIGHTED is a valid dataset type and defined
	if !inlist("`=upper("$DESC_03_WEIGHTED")'","YES", "NO") {
		di as error ///
		"DESC_03_WEIGHTED must be YES or NO.  The current value is $DESC_03_WEIGHTED."
		vcqi_log_comment $VCP 1 Error ///
		"DESC_03_WEIGHTED must be YES or NO.  The current value is $DESC_03_WEIGHTED."
		local exitflag 1
	}
	
	* Confirm DESC_03_DENOMINATOR is a valid dataset type and defined
	* If DESC_03_WEIGHTED is YES DESC_03_DENOMINATOR must be ALL
	if "`=upper("$DESC_03_WEIGHTED")'"=="YES" & "`=upper("$DESC_03_DENOMINATOR")'"!="ALL" {
		di as error ///
		"DESC_03_DENOMINATOR must be ALL if DESC_03_WEIGHTED is YES.  The current value is $DESC_03_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error ///
		"DESC_03_DENOMINATOR must be ALL if DESC_03_WEIGHTED is YES.  The current value is $DESC_03_DENOMINATOR."
		local exitflag 1
	}

	* If DESC_03_WEIGHTED is NO DESC_03_DENOMINATOR can be ALL or RESPONDED
	if !inlist("`=upper("$DESC_03_DENOMINATOR")'","ALL", "RESPONDED") {
		di as error ///
		"DESC_03_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_03_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error ///
		"DESC_03_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_03_DENOMINATOR."
		local exitflag 1
	}
	
		
	* If the user has used the outdated global macro nomenclature with the word MISSING in the macro names, 
	* convert them to the new nomenclature with the word RELABEL
	if "$DESC_03_N_MISSING_LEVELS" != "" {
		global DESC_03_N_RELABEL_LEVELS $DESC_03_N_MISSING_LEVELS
		forvalues i = 1/$DESC_03_N_RELABEL_LEVELS {
			global DESC_03_RELABEL_LEVEL_`i' ${DESC_03_MISSING_LEVEL_`i'}
			global DESC_03_RELABEL_LABEL_`i' ${DESC_03_MISSING_LABEL_`i'}
		}
	}
	
	* Confirm global values are either missing or a number for Globals DESC_03_N_RELABEL_LEVELS and DESC_03_N_SUBTOTALS
	foreach g in DESC_03_N_RELABEL_LEVELS DESC_03_N_SUBTOTALS {
		if "${`g'}"==""{
			global `g' 0
		}
		capture confirm number ${`g'}
		if _rc!=0 {
			di as error ///
			"Global variable `g' must be a numeric value. The current value is ${`g'}"
			vcqi_log_comment $VCP 1 Error ///
			"Global variable `g' must be a numeric value. The current value is ${`g'}"
			local exitflag 1
		}
				
		if  ${`g'} < 0 {
			di as error ///
			"Global variable `g' must be a number >= zero. The current value is ${`g'}"
			vcqi_log_comment $VCP 1 Error ///
			"Global variable `g' must be a number >= zero. The current value is ${`g'}"	
			local exitflag 1
			
		}
	}
	
	* If DESC_03_N_RELABEL_LEVELS was blank and changed to 0 all other missing level globals will be ignored
	if $DESC_03_N_RELABEL_LEVELS==0 {
		if "$DESC_03_RELABEL_LEVEL_1" != "" {
			di as error ///
			"Warning: Global macro DESC_03_RELABEL_LEVEL_1 is defined but DESC_03_N_RELABEL_LEVELS is 0 or not defined so no levels will be re-labeled."
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_03_RELABEL_LEVEL_1 is defined but DESC_03_N_RELABEL_LEVELS is 0 or not defined so no levels will be re-labeled."
		}
	}
		
	
	* Confirm each missing level and label is populated for each N_MISSING LEVEL
	if $DESC_03_N_RELABEL_LEVELS!=0 {
		forvalues i = 1/$DESC_03_N_RELABEL_LEVELS {
			foreach g in DESC_03_RELABEL_LEVEL_`i' DESC_03_RELABEL_LABEL_`i' {
				if "${`g'}"=="" {
					di as error                   "Global variable `g' must be defined."
					vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
					local exitflag 1
				}
			}
		}
	}
	
	* If DESC_03_N_SUBTOTALS was blank and changed to 0 all other subtotal level globals be ignored
	if $DESC_03_N_SUBTOTALS==0 {
		if "$DESC_03_SUBTOTAL_LEVELS_1" != "" {
			di as error ///
			"Warning: Global macro DESC_03_SUBTOTAL_LEVELS_1 is defined but DESC_03_N_SUBTOTALS is undefined or zero, so no subtotals will be calculated."
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_03_SUBTOTAL_LEVELS_1 is defined but DESC_03_N_SUBTOTALS is undefined or zero, so no subtotals will be calculated."
		}
	}		
	
	* Confirm each subtotal level and label is populated for each N_SUBTOTALS
	if $DESC_03_N_SUBTOTALS!=0 {
		forvalues i = 1/$DESC_03_N_SUBTOTALS {
			foreach g in DESC_03_SUBTOTAL_LEVELS_`i' DESC_03_SUBTOTAL_LABEL_`i' {
				if "${`g'}"=="" {
					di as error                   "Global variable `g' must be defined."
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
					"Global DESC_03_SUBTOTAL_LIST_`i' is defined but does not have two words. (It is currently ${DESC_03_SUBTOTAL_LIST_`i'}.) The first word should be BEFORE or AFTER.  The second word should be the name of a variable from DESC_03_VARIABLES."
					vcqi_log_comment $VCP 1 Error ///
					"Global DESC_03_SUBTOTAL_LIST_`i' is defined but does not have two words. (It is currently ${DESC_03_SUBTOTAL_LIST_`i'}.) The first word should be BEFORE or AFTER.  The second word should be the name of a variable from DESC_03_VARIABLES."
					local exitflag 1
				}
				if !inlist("`=upper("`=word("${DESC_03_SUBTOTAL_LIST_`i'}",1)'")'","BEFORE","AFTER") {
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
				"If you specify to DESC_03_SHOW_SUBTOTALS_ONLY then you cannot also specify SUBTOTAL_LIST; DESC_03_SUBTOTAL_LIST_`i' will be ignored."
				vcqi_log_comment $VCP 2 Warning ///
				"If you specify to DESC_03_SHOW_SUBTOTALS_ONLY then you cannot also specify SUBTOTAL_LIST; DESC_03_SUBTOTAL_LIST_`i' will be ignored."
				
				* Clear out SUBTOTAL_LIST global
				vcqi_global DESC_03_SUBTOTAL_LIST_`i'
				
			}		
		}
	}			
			
	* Confirm all variables listed in the DESC_03_RELABEL_LEVELS and DESC_03_SUBTOTAL_LEVELS
	* Are included in the DESC_03_VARIABLES global variable
	
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
	
	
		if $DESC_03_N_RELABEL_LEVELS!=0 {
		forvalues i = 1/$DESC_03_N_RELABEL_LEVELS {
			foreach g in ${DESC_03_RELABEL_LEVEL_`i'} {
				local match 0
				foreach d in $DESC_03_VARIABLES {
					if "`g'" == "`d'" local match 1
				}
				if `match'==0 {
					di as error "Variable `g' in DESC_03_RELABEL_LEVEL_`i' is not inlcuded in DESC_03_VARIABLES"
					vcqi_log_comment $VCP 1 Error "Variable `g' in DESC_03_RELABEL_LEVEL_`i' is not inlcuded in DESC_03_VARIABLES"
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
