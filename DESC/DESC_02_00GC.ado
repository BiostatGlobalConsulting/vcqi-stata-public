*! DESC_02_00GC version 1.09 - Biostat Global Consulting - 2018-01-17
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
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2018-01-03	1.05	Dale Rhoda		Only allow SUBTOTALS for numeric vars
* 2018-01-10	1.06	Dale Rhoda		Make MISSING a synonym of RELABEL
* 2018-01-16	1.07	MK Trimner		Fixed RELABEL code
* 2018-01-16	1.07	MK Trimner		Added Label option for N and NWTD
* 2018-01-16	1.08	Dale Rhoda		Make dataset name more generic *AND*
* 										backward compatible
* 2018-01-17	1.09	MK Trimner		Added code to check that the subtotal 
*										globals ontain only valid values for 
*                                       the specified variable.
*										Added additional code to mirror that 
*										of DESC_03_00GC check program.
*										This includes reformatting the SUBTOTAL 
*										global checks to align with DESC_03.
*******************************************************************************

program define DESC_02_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_02_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local exitflag 0
	
	if "$DESC_02_DATASET" == "" {
		di as error                   "You must specify DESC_02_DATASET."
		vcqi_log_comment $VCP 1 Error "You must specify DESC_02_DATASET."
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
	if lower(substr("$DESC_02_DATASET",-4,4)) == ".dta" global DESC_02_DATASET = subinstr("$DESC_02_DATASET",".dta","",.)
		
	if inlist("`=upper("$DESC_02_DATASET")'","RI","SIA", "TT") {
		capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}_with_ids.dta"
		* If the _with_ids dataset exists, update the global
		if _rc == 0 vcqi_global DESC_02_DATASET ${DESC_02_DATASET}_with_ids
		else {
			* Else check to see if there's a dataset present without _with_ids
			capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}.dta"
			if _rc != 0 {
				di as error                   "DESC_02_DATASET is ${DESC_02_DATASET} but there is no dataset named ${DESC_02_DATASET} or named ${DESC_02_DATASET}_with_ids in the VCQI output folder."
				vcqi_log_comment $VCP 1 Error "DESC_02_DATASET is ${DESC_02_DATASET} but there is no dataset named ${DESC_02_DATASET} or named ${DESC_02_DATASET}_with_ids in the VCQI output folder."
				local exitflag 1
			}
		}
	}
	
	* Confirm dataset exists
	capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}.dta" 
	if _rc!=0 {
		di as error ///
		"${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}.dta does not exist."
		vcqi_log_comment $VCP 1 Error ///
		"${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}.dta does not exist."
		local exitflag 1
	}
	else qui use "${VCQI_OUTPUT_FOLDER}/${DESC_02_DATASET}", clear
	
	* Confirm variables have been provided
	if "$DESC_02_VARIABLES"=="" {
			di as error                   "You must define global variable DESC_02_VARIABLES"
			vcqi_log_comment $VCP 1 Error "You must define global variable DESC_02_VARIABLES"
			local exitflag 1
	}
	
	* Confirm specified variables exist in global DESC_02_VARIABLES
	foreach g in $DESC_02_VARIABLES {
		capture confirm variable `g'
		if _rc!=0 {
			di as error                   "The variable `g' provided in global macro DESC_02_VARIABLES does not exist in dataset."
			vcqi_log_comment $VCP 1 Error "The variable `g' provided in global macro DESC_02_VARIABLES does not exist in dataset." 
			local exitflag 1
		}
		
	}
	
	* Confirm DESC_02_WEIGHTED is valid & defined
	if !inlist("`=upper("$DESC_02_WEIGHTED")'","YES", "NO") {
		di as error                   "DESC_02_WEIGHTED must be YES or NO.  The current value is $DESC_02_WEIGHTED."
		vcqi_log_comment $VCP 1 Error "DESC_02_WEIGHTED must be YES or NO.  The current value is $DESC_02_WEIGHTED."
		local exitflag 1
	}
	
	* Set default N and NWTD labels if not specified
	if "$DESC_02_N_LABEL"=="" 		vcqi_global DESC_02_N_LABEL N
	if "$DESC_02_NWTD_LABEL"=="" 	vcqi_global DESC_02_NWTD_LABEL Weighted N
	
	* Confirm DESC_02_DENOMINATOR is valid and defined
	* If DESC_02_WEIGHTED is YES DESC_02_DENOMINATOR must be ALL
	if "`=upper("$DESC_02_WEIGHTED")'"=="YES" & "`=upper("$DESC_02_DENOMINATOR")'"!="ALL" {
		di as error                   "DESC_02_DENOMINATOR must be ALL if DESC_02_WEIGHTED is YES.  The current value is $DESC_02_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error "DESC_02_DENOMINATOR must be ALL if DESC_02_WEIGHTED is YES.  The current value is $DESC_02_DENOMINATOR."
		local exitflag 1
	}

	* If DESC_02_WEIGHTED is NO DESC_02_DENOMINATOR can be ALL or RESPONDED
	if !inlist("`=upper("$DESC_02_DENOMINATOR")'","ALL", "RESPONDED") {
		di as error                   "DESC_02_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_02_DENOMINATOR."
		vcqi_log_comment $VCP 1 Error "DESC_02_DENOMINATOR must be ALL or RESPONDED.  The current value is $DESC_02_DENOMINATOR."
		local exitflag 1
	}
	
	* Gently remind the user that missing values are not tabulated when the denominator is RESPONDED
	if "`=upper("$DESC_02_DENOMINATOR")'" == "RESPONDED" ///
		vcqi_log_comment $VCP 3 Comment "DESC_02 denominator is RESPONDED so missing values will not be tabulated."
		
	* If the user has used the outdated global macro nomenclature with the word MISSING in the macro names, 
	* convert them to the new nomenclature with the word RELABEL
	if "$DESC_02_N_MISSING_LEVELS" != "" {
		global DESC_02_N_RELABEL_LEVELS $DESC_02_N_MISSING_LEVELS
		forvalues i = 1/$DESC_02_N_RELABEL_LEVELS {
			global DESC_02_RELABEL_LEVEL_`i' ${DESC_02_MISSING_LEVEL_`i'}
			global DESC_02_RELABEL_LABEL_`i' ${DESC_02_MISSING_LABEL_`i'}
		}
	}

	* Confirm global values are either missing or a number for Globals DESC_02_N_RELABEL_LEVELS and DESC_02_N_SUBTOTALS
	foreach g in DESC_02_N_RELABEL_LEVELS DESC_02_N_SUBTOTALS {
		if `"${`g'}"'==""{
			global `g' 0
		}
		capture confirm number ${`g'}
		if _rc!=0 {
			di as error                   "Global variable `g' must be a numeric value. The current value is ${`g'}"
			vcqi_log_comment $VCP 1 Error "Global variable `g' must be a numeric value. The current value is ${`g'}"
			local exitflag 1
		}
				
		if  ${`g'} < 0 {
			di as error                   "Global variable `g' must be a number >= zero. The current value is ${`g'}"
			vcqi_log_comment $VCP 1 Error "Global variable `g' must be a number >= zero. The current value is ${`g'}"	
			local exitflag 1
			
		}
	}
	
	* If DESC_02_N_RELABEL_LEVELS was blank and changed to 0 all other missing level globals will be ignored
	if $DESC_02_N_RELABEL_LEVELS==0 {
		if "$DESC_02_RELABEL_LEVEL_1" != "" {
			di as error ///
			"Warning: Global macro DESC_02_RELABEL_LEVEL_1 is defined, but DESC_02_N_RELABEL_LEVELS is 0 or not defined, so no levels will be re-labeled"
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_02_RELABEL_LEVEL_1 is defined, but DESC_02_N_RELABEL_LEVELS is 0 or not defined, so no levels will be re-labeled"
		}
	}
		
	
	* Confirm each missing level and label is populated for each N_MISSING LEVEL
	if $DESC_02_N_RELABEL_LEVELS!=0 {
		forvalues i = 1/$DESC_02_N_RELABEL_LEVELS {
			foreach g in DESC_02_RELABEL_LEVEL_`i' DESC_02_RELABEL_LABEL_`i' {
				if "${`g'}"=="" {
					di as error                   "Global variable `g' must be defined."
					vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
					local exitflag 1
				}
			}
		}
	}
	
	* If DESC_02_N_SUBTOTALS was blank and changed to 0 all other subtotal level globals be ignored
	if $DESC_02_N_SUBTOTALS==0 {
		if "$DESC_02_SUBTOTAL_LEVELS_1" != "" {
			di as error ///
			"Warning: Global macro DESC_02_SUBTOTAL_LEVELS_1 is defined, but DESC_02_N_SUBTOTALS is 0 or not defined, so no subtotals will be calculated."
			vcqi_log_comment $VCP 2 Warning ///
			"Warning: Global macro DESC_02_SUBTOTAL_LEVELS_1 is defined, but DESC_02_N_SUBTOTALS is 0 or not defined, so no subtotals will be calculated."
		}
	}
		
	
	* Confirm each subtotal level and label is populated for each N_MISSING LEVEL
	if $DESC_02_N_SUBTOTALS!=0 {
		forvalues i = 1/$DESC_02_N_SUBTOTALS {
			foreach g in DESC_02_SUBTOTAL_LEVELS_`i' DESC_02_SUBTOTAL_LABEL_`i' {
				if `"${`g'}"'=="" {
					di as error                   "Global variable `g' must be defined."
					vcqi_log_comment $VCP 1 Error "Global variable `g' must be defined."
					local exitflag 1
				}
			}
			
			* Adding code to mirror DESC_03_00GC program code -MKT 2018-01-17
			* If SUBTOTAL_LIST is defined, then confirm that
			* a) it holds only two words
			* b) the first word is either BEFORE or AFTER
			* c) the second word is a level from DESC_02_VARIABLES
			
			if "${DESC_02_SUBTOTAL_LIST_`i'}" != "" {
				if wordcount("${DESC_02_SUBTOTAL_LIST_`i'}") != 2 {
					di as error ///
					"Global DESC_02_SUBTOTAL_LIST_`i' is defined but does not have two words. (It is currently "${DESC_02_SUBTOTAL_LIST_`i'}".) The first word should be BEFORE or AFTER.  The second word should be the name of a level of the DESC_02_VARIABLES."
					vcqi_log_comment $VCP 1 Error ///
					"Global DESC_02_SUBTOTAL_LIST_`i' is defined but does not have two words. (It is currently "${DESC_02_SUBTOTAL_LIST_`i'}".) The first word should be BEFORE or AFTER.  The second word should be the name of a level of the DESC_02_VARIABLES."
					local exitflag 1
				}
				if !inlist("`=upper("`=word("${DESC_02_SUBTOTAL_LIST_`i'}",1)'")'","BEFORE","AFTER") {
					di as error ///
					"The first word of global DESC_02_SUBTOTAL_LIST_`i' should be BEFORE or AFTER.  It is currently `=word("${DESC_02_SUBTOTAL_LIST_`i'}",1)'."
					vcqi_log_comment $VCP 1 Error ///
					"The first word of global DESC_02_SUBTOTAL_LIST_`i' should be BEFORE or AFTER.  It is currently `=word("${DESC_02_SUBTOTAL_LIST_`i'}",1)'."
					local exitflag 1
				}
			}
				
			* Foreach value provided in SUBTOTAL_LIST confirm it is an appropriate value
			* for the variable provided
			foreach v in $DESC_02_VARIABLES {
				
				* Confirm that each variable is numeric if SUBTOTALS are specified
				if substr("`: type `v''",1,3) == "str" {
					di as error                   "DESC_02 can only compute subtotals for numeric variables; `v' is a string variable."
					vcqi_log_comment $VCP 1 Error "DESC_02 can only compute subtotals for numeric variables; `v' is a string variable."
					local exitflag 1		
				}
							
				else {
					capture local labname : value label `v'
					
					if "`labname'" != "" {
						noi fetch_label_values `labname'
						local llist `r(vlist)'
						local ullist  : list uniq llist
						local llist   : list sort ullist
						if substr("`llist'",1,2) == ". " local llist `=substr("`llist'",3,.)' .
						
						* Add the missing option if ALL was selected as denominator
						if "`=upper("$DESC_02_DENOMINATOR")'"=="ALL" local llist `llist' .
												
						* Complete the same check for the values provided in DESC_02_SUBTOTAL_LEVELS
						foreach g in ${DESC_02_SUBTOTAL_LEVELS_`i'} {
							local listmatch 0
							if `g'!=. {
								capture confirm number `g' 
								if _rc!=0 {	
									di as error                   "Global Variable DESC_02_SUBTOTAL_LEVELS_`i' must be all numeric values. It currently contains the value of `g'"
									vcqi_log_comment $VCP 1 Error "Global Variable DESC_02_SUBTOTAL_LEVELS_`i' must be all numeric values. It currently contains the value of `g'"
									local exitflag 1
									continue
								}
							}
							foreach p in `llist' {
								if `g'==`p' local listmatch 1
							}
						
							if `listmatch' == 0 {
								di as error ///
								"The values of global DESC_02_SUBTOTAL_LEVELS_`i' should be one of the values associated with variable `v' listed in DESC_02_VARIABLES(`llist').  It currently contains the value of `g'."
								vcqi_log_comment $VCP 1 Error ///
								"The values of global DESC_02_SUBTOTAL_LEVELS_`i' should be one of the values associated with variable `v' listed in DESC_02_VARIABLES(`llist').  It currently contains the value of `g'."
								local exitflag 1
							}
						}		
						* Complete the same check for values in DESC_02_SUBTOTAL_LIST if specified
						* Create a local to find the number to be used as before or after
						if "$DESC_02_SUBTOTAL_LIST" !="" {
							if strpos("`=upper("${DESC_02_SUBTOTAL_LIST_`i'}")'","AFTER")> 0 local l `=subinstr("`=upper("${DESC_02_SUBTOTAL_LIST_`i'}")'","AFTER ","",.)'
							if strpos("`=upper("${DESC_02_SUBTOTAL_LIST_`i'}")'","BEFORE")> 0 local l `=subinstr("`=upper("${DESC_02_SUBTOTAL_LIST_`i'}")'","BEFORE ","",.)'
							local listmatch 0
							foreach p in `llist' {
								if `l'==`p' local listmatch 1
							}
							if `listmatch'==0 {
								noi di as error "Global variable DESC_02_SUBTOTAL_LIST_`i'" ///
								" must contain a valid variable value number from variable `v': `llist'." ///
								" The current value is: ${DESC_02_SUBTOTAL_LIST_`i'}."
								
								vcqi_log_comment $VCP 1 Error "Global variable DESC_02_SUBTOTAL_LIST_`i'" ///
								" must contain a valid variable value number from variable `v': `llist'." ///
								" The current value is: ${DESC_02_SUBTOTAL_LIST_`i'}." 
								
								local exitflag 1
							}
						}
					}
				}
			}
		}
	
	
		* Confirm that if "${DESC_02_SHOW_SUBTOTALS_ONLY"}" then the user has not also specified 
		* any SUBTOTAL_LEVEL globals
		
		if "${DESC_02_SHOW_SUBTOTALS_ONLY}" != "" {
			forvalues i = 1/$DESC_02_N_SUBTOTALS {
				if "${DESC_02_SUBTOTAL_LIST_`i'}" != "" {
					di as error ///
					"If you specify to DESC_02_SHOW_SUBTOTALS_ONLY then you cannot also specify SUBTOTAL_LIST; DESC_02_SUBTOTAL_LIST_`i' will be ignored."
					vcqi_log_comment $VCP 2 Warning ///
					"If you specify to DESC_02_SHOW_SUBTOTALS_ONLY then you cannot also specify SUBTOTAL_LIST; DESC_02_SUBTOTAL_LIST_`i' will be ignored."
					
					* Clear out SUBTOTAL_LIST global
					vcqi_global DESC_02_SUBTOTAL_LIST_`i'
					
				}		
			}
		}	
	}		

			
	/* Confirm the values provided in globals DESC_02_SUBTOTAL_LEVELS_# and 
	* DESC_02_SUBTOTAL_LIST_# are appropriate value
	* for the variable provided
	if "$DESC_02_N_SUBTOTALS"!="" {
		foreach v in $DESC_02_VARIABLES {
			capture local labname : value label `v'
			
			if "`labname'" != "" {
				noi fetch_label_values `labname'
				local llist `llist' `r(vlist)'
				local ullist  : list uniq llist
				local llist   : list sort ullist
			
						
				* Create new local and remove spaces and add , for inlist purposes
				local p `=subinstr("`llist'"," ",",",.)'
				
				* Add the missing option if ALL was selected as denominator
				if "`=upper("$DESC_02_DENOMINATOR")'"=="ALL" local p `p',.
				
				forvalue i = 1/$DESC_02_N_SUBTOTALS {					
					foreach g in ${DESC_02_SUBTOTAL_LEVELS_`i'} {
						if !inlist(`g',`p') {
							local exitflag 1
							noi di as error "Global variable DESC_02_SUBTOTAL_LEVELS_`i' must " ///
							"contain a valid variable value number from variable `v': `llist'." ///
							" The current value is: ${DESC_02_SUBTOTAL_LEVELS_`i'}."
							
							vcqi_log_comment $VCP 1 Error "Global variable DESC_02_SUBTOTAL_LEVELS_`i' must " ///
							"contain a valid variable value number from variable `v': `llist'." ///
							" The current value is:${DESC_02_SUBTOTAL_LEVELS_`i'}."
						}
					}
					
					* If the DESC_02_SHOW_SUBTOTALS_ONLY is not set to yes
					* Complete the below check
					if "`=upper("$DESC_02_SHOW_SUBTOTALS_ONLY")'"!="YES" {
						* Create a local to find the number to be used as before or after
						if strpos("${DESC_02_SUBTOTAL_LIST_`i'}","after")> 0 local l `=subinstr("${DESC_02_SUBTOTAL_LIST_`i'}","after ","",.)'
						if strpos("${DESC_02_SUBTOTAL_LIST_`i'}","before")> 0 local l `=subinstr("${DESC_02_SUBTOTAL_LIST_`i'}","before ","",.)'
					
						if !inlist(`l',`p') {
							local exitflag 1
							
							noi di as error "Global variable DESC_02_SUBTOTAL_LIST_`i'" ///
							" must contain a valid variable value number from variable `v': `llist'." ///
							" The current value is: ${DESC_02_SUBTOTAL_LIST_`i'}."
							
							vcqi_log_comment $VCP 1 Error "Global variable DESC_02_SUBTOTAL_LIST_`i'" ///
							" must contain a valid variable value number from variable `v': `llist'." ///
							" The current value is: ${DESC_02_SUBTOTAL_LIST_`i'}." 
						}
					}
					
				}
			}
		}
	}*/			
			
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
		
	
	
	



