*! check_analysis_metadata version 1.04 - Biostat Global Consulting - 2017-01-30
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-03-07	1.0		Dale Rhoda		Pulled out from RI, TT, SIA code	
* 2016-09-19	1.01	Dale Rhoda		Require level 4 stratifier if user
*										requests level 4 table output		
* 2016-10-26	1.02	Dale Rhoda		Allow Jeffreys intervals, too	
* 2017-01-16	1.03	Dale Rhoda		Make LEVEL4 error messages more 
*										informative		
* 2017-01-30	1.04	Dale Rhoda		Add checking for VCQI_LEVEL4_SET_VARLIST
*										and VCQI_LEVEL4_SET_LAYOUT
* 2017-06-08	1.05	Dale Rhoda		Add SIA and TT datasets to list of those
*										searched for variables in level 4 
*										SET_VARLIST
*******************************************************************************

program define check_analysis_metadata

	local oldvcp $VCP
	global VCP check_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local exitflag 0	
		
		* Check globals that should be populated with strings
		
		foreach g in VCQI_DATA_FOLDER VCQI_OUTPUT_FOLDER VCQI_ANALYSIS_NAME {

			if "$`g'" == "" {
				di as error "Please set `g'."
				local exitflag 1
			}	
		}
		
		* Check for existence of datasets listing strata names and orders
		
		* Confirm contents of level 1 name file, if level 1 output is requested
		
		if "$SHOW_LEVEL1_ALONE" == "1" | "$SHOW_LEVELS_1_4_TOGETHER" == "1" {
			vcqi_log_global LEVEL1_NAME_DATASET
			capture confirm file "${LEVEL1_NAME_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1
				di as error "LEVEL1_NAME_DATASET does not exist"
				vcqi_log_comment $VCP 1 Error  "LEVEL1_NAME_DATASET does not exist"
			}
			else {
				use "${LEVEL1_NAME_DATASET}", clear
				capture confirm variable level1id level1name
				if _rc != 0 {
					local exitflag 1
					di as error "LEVEL1_NAME_DATASET should contain variables level1id and level1name."
					vcqi_log_comment $VCP 1 Error "LEVEL1_NAME_DATASET should contain variables level1id and level1name."
				}
			}
		}
		
		* Confirm contents of level 2 files, if level 2 output is requested 
		
		if "$SHOW_LEVEL2_ALONE" == "1" | "$SHOW_LEVELS_2_3_TOGETHER" == "1" | ///
		   "$SHOW_LEVELS_2_4_TOGETHER" == "1" | "$SHOW_LEVELS_2_3_4_TOGETHER" == "1" {
		
			vcqi_log_global LEVEL2_NAME_DATASET
			capture confirm file "${LEVEL2_NAME_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1
				di as error "LEVEL2_NAME_DATASET does not exist."
				vcqi_log_comment $VCP 1 Error "LEVEL2_NAME_DATASET does not exist."
			}
			else {
				use "${LEVEL2_NAME_DATASET}", clear
				capture confirm variable level2id level2name
				if _rc != 0 {
					local exitflag 1
					di as error "LEVEL2_NAME_DATASET should contain variables level2id and level2name."
					vcqi_log_comment $VCP 1 Error "LEVEL2_NAME_DATASET should contain variables level2id and level2name."
				}
			}
			
			vcqi_log_global LEVEL2_ORDER_DATASET
			capture confirm file "${LEVEL2_ORDER_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1
				di as error "LEVEL2_ORDER_DATASET does not exist."
				vcqi_log_comment $VCP 1 Error "LEVEL2_ORDER_DATASET does not exist."
			}
			else {
				use "${LEVEL2_ORDER_DATASET}", clear
				capture confirm variable level2id level2order
				if _rc != 0 {
					local exitflag 1
					di as error "LEVEL2_ORDER_DATASET should contain variables level2id and level2order."
					vcqi_log_comment $VCP 1 Error "LEVEL2_ORDER_DATASET should contain variables level2id and level2order."
				}
			}
		}
		
		* The software assumes that level 3 names are in the CM dataset
		* This code confirms contents of the level 3 order dataset, if level 3 output is requested
			
		if "$SHOW_LEVEL3_ALONE" == "1" | "$SHOW_LEVELS_2_3_TOGETHER" == "1" | ///
		   "$SHOW_LEVELS_3_4_TOGETHER" == "1" | "$SHOW_LEVELS_2_3_4_TOGETHER" == "1" {

			vcqi_log_global LEVEL3_ORDER_DATASET
			capture confirm file "${LEVEL3_ORDER_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1
				di as error "LEVEL3_ORDER_DATASET does not exist."
				vcqi_log_comment $VCP 1 Error "LEVEL3_ORDER_DATASET does not exist."
			}
			else {
				use "${LEVEL3_ORDER_DATASET}", clear
				capture confirm variable level3id level3order
				if _rc != 0 {
					local exitflag 1
					di as error "LEVEL3_ORDER_DATASET should contain variables level3id and level3order."
					vcqi_log_comment $VCP 1 Error "LEVEL3_ORDER_DATASET should contain variables level3id and level3order."
				}	
			}
		}
		
		* Confirm contents of level 4 names and order datasets, if VCQI_LEVEL4_STRATIFIER is requested
			
		if 	   "$VCQI_LEVEL4_STRATIFIER" != "" & ///
			   ( "$SHOW_LEVELS_1_4_TOGETHER" == "1" | "$SHOW_LEVELS_2_4_TOGETHER" == "1"   | ///
				 "$SHOW_LEVELS_3_4_TOGETHER" == "1" | "$SHOW_LEVELS_2_3_4_TOGETHER" == "1" ) {
		
			vcqi_log_global LEVEL4_ORDER_DATASET
			capture confirm file "${LEVEL4_ORDER_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1
				di as error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_ORDER_DATASET does not exist."
				vcqi_log_comment $VCP 1 Error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_ORDER_DATASET does not exist."
			}
			else {
				use "${LEVEL4_ORDER_DATASET}", clear
				capture confirm variable level4id level4order
				if _rc != 0 {
					local exitflag 1
					di as error "LEVEL4_ORDER_DATASET should contain variables level4id and level4order."
					vcqi_log_comment $VCP 1 Error "LEVEL4_ORDER_DATASET should contain variables level4id and level4order."
				}
			}
			
			vcqi_log_global LEVEL4_NAME_DATASET
			capture confirm file "${LEVEL4_NAME_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1
				di as error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_NAME_DATASET does not exist."
				vcqi_log_comment $VCP 1 Error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_NAME_DATASET does not exist."
			}
			else {
				use "${LEVEL4_NAME_DATASET}", clear
				capture confirm variable level4id level4name
				if _rc != 0 {
					local exitflag 1
					di as error "LEVEL4_NAME_DATASET should contain variables level4id and level4name."
					vcqi_log_comment $VCP 1 Error "LEVEL4_NAME_DATASET should contain variables level4id and level4name."
				}
			}
		}
		
		* If user requests level 4 output, they must specify a level 4 stratifier

		vcqi_log_global VCQI_LEVEL4_STRATIFIER
		vcqi_log_global VCQI_LEVEL4_SET_VARLIST
		vcqi_log_global VCQI_LEVEL4_SET_LAYOUT
		
		if 	( "$SHOW_LEVELS_1_4_TOGETHER"   == "1" | ///
			  "$SHOW_LEVELS_2_4_TOGETHER"   == "1" | ///
			  "$SHOW_LEVELS_3_4_TOGETHER"   == "1" | ///
			  "$SHOW_LEVELS_2_3_4_TOGETHER" == "1" ) & ///
			  "$VCQI_LEVEL4_STRATIFIER" == "" & "$VCQI_LEVEL4_SET_VARLIST" == "" {
			local exitflag 1
			di as error "If you request level 4 output, you must specify VCQI_LEVEL4_STRATIFIER or VCQI_LEVEL4_SET_VARLIST"
			if "$SHOW_LEVELS_1_4_TOGETHER"     == "1" di as error "SHOW_LEVELS_1_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
			if "$SHOW_LEVELS_2_4_TOGETHER"     == "1" di as error "SHOW_LEVELS_2_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
			if "$SHOW_LEVELS_3_4_TOGETHER"     == "1" di as error "SHOW_LEVELS_3_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
			if "$SHOW_LEVELS_2_3_4_TOGETHER"   == "1" di as error "SHOW_LEVELS_2_3_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
			vcqi_log_comment $VCP 1 Error "If you request level 4 output, you must specify VCQI_LEVEL4_STRATIFIER or VCQI_LEVEL4_SET_VARLIST""
			if "$SHOW_LEVELS_1_4_TOGETHER"     == "1" vcqi_log_comment $VCP 1 Error "SHOW_LEVELS_1_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
			if "$SHOW_LEVELS_2_4_TOGETHER"     == "1" vcqi_log_comment $VCP 1 Error "SHOW_LEVELS_2_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
			if "$SHOW_LEVELS_3_4_TOGETHER"     == "1" vcqi_log_comment $VCP 1 Error "SHOW_LEVELS_3_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
			if "$SHOW_LEVELS_2_3_4_TOGETHER"   == "1" vcqi_log_comment $VCP 1 Error "SHOW_LEVELS_2_3_4_TOGETHER is set to 1 but VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_VARLIST are empty"
		}
		
		* If the user asks for a stratifier, they cannot also specify a set.
		if "$VCQI_LEVEL4_STRATIFIER" != "" & ("$VCQI_LEVEL4_SET_LAYOUT" != "" | "$VCQI_LEVEL4_SET_VARLIST" != "") {
			local exitflag 1
			di as error "If you request level 4 output, you must specify either VCQI_LEVEL4_STRATIFIER or ( VCQI_LEVEL4_SET_VARLIST and VCQI_LEVEL4_SET_LAYOUT ).  You cannot specify VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_LAYOUT."
			vcqi_log_comment $VCP 1 Error "If you request level 4 output, you must specify either VCQI_LEVEL4_STRATIFIER or ( VCQI_LEVEL4_SET_VARLIST and VCQI_LEVEL4_SET_LAYOUT ).  You cannot specify VCQI_LEVEL4_STRATIFIER and VCQI_LEVEL4_SET_LAYOUT."
		}

		* If the user asks for a set, they must supply the set varlist
		if ("$VCQI_LEVEL4_SET_LAYOUT" != "" & "$VCQI_LEVEL4_SET_VARLIST" == "") {
			local exitflag 1
			di as error "If you specify VCQI_LEVEL4_SET_LAYOUT then you must also specify VCQI_LEVEL4_SET_VARLIST."
			vcqi_log_comment $VCP 1 Error "If you specify VCQI_LEVEL4_SET_LAYOUT then you must also specify VCQI_LEVEL4_SET_VARLIST."
		}
		
		* If they specify a set varlist, but no set layout, try to build the set layout dataset
		if ("$VCQI_LEVEL4_SET_LAYOUT" == "" & "$VCQI_LEVEL4_SET_VARLIST" != "") {
			foreach v in $VCQI_LEVEL4_SET_VARLIST {
				local continue 
				
				* We don't know which dataset holds each stratifier...most will be 
				* in the RI dataset but some might be in CM or another...so 
				* loop over the datasets and keep going 'til we find it
				
				foreach d in $VCQI_RI_DATASET $VCQI_SIA_DATASET $VCQI_TT_DATASET $VCQI_CM_DATASET $VCQI_RIHC_DATASET $VCQI_HM_DATASET $VCQI_HH_DATASET {
					use "$VCQI_DATA_FOLDER/`d'", clear
					capture confirm variable `v'
					if _rc == 0 {
						local continue continue, break
						if substr("`: type `v''",1,3) == "str" {
							levelsof `v', local(llist)
							local store_label `:variable label `v''
							if "`store_label'" == "" local store_label `v'
							clear
							set obs `=wordcount(`"`llist'"')+1'
							gen order = .
							gen label = ""
							gen condition = ""
							gen rowtype = "DATA_ROW"
							replace rowtype = "LABEL_ONLY"  in 1
							replace label = "`store_label'" in 1
							forvalues i = 1/`=_N-1' {
								replace label = `"`=word(`"`llist'"',`i')'"' in `=`i'+1'
								replace condition = "`v' == " + char(34) + `=word(`"`llist'"',`i')' + char(34) in `=`i'+1'
							}
							replace order = _n
							tempfile layout_`v'
							save `layout_`v'', replace
						}
						else {
							levelsof `v', local(llist)
							forvalues i = 1/`=wordcount("`llist'")' {
								local storeit_`i' `: label (`v') `=word("`llist'",`i')''
							}
							local store_label `: variable label `v''
							if "`store_label'" == "" local store_label `v'
							clear
							set obs `=wordcount("`llist'")+1'
							gen order = .
							gen label = ""
							gen condition = ""
							gen rowtype = "DATA_ROW"
							replace rowtype = "LABEL_ONLY"  in 1
							replace label = "`store_label'" in 1
							forvalues i = 1/`=_N-1' {
								replace label = "`storeit_`i''" in `=`i'+1'
								replace condition = "`v' ==  `=word("`llist'",`i')'" in `=`i'+1'
							}
							replace order = _n
							tempfile layout_`v'
							save `layout_`v'', replace
						}
					}
					* If the variable was found, skip to the next variable, 
					* and otherwise, look for the variable in the next dataset
					* in the list of datasets above
					`continue'
				}
				* If we haven't found the variable in any of the aforementioned
				* datasets then it's probably a typo...throw an error and stop
				if "`continue'" == "" {
					local exitflag 1
					di as error "User asked for variable `v' in VCQI_LEVEL4_SET_VARLIST but that variable doesn't seem to appear in VCQI_RI_DATASET VCQI_CM_DATASET VCQI_RIHC_DATASET VCQI_HM_DATASET or VCQI_HH_DATASET."
					vcqi_log_comment $VCP 1 Error "User asked for variable `v' in VCQI_LEVEL4_SET_VARLIST but that variable doesn't seem to appear in VCQI_RI_DATASET VCQI_CM_DATASET VCQI_RIHC_DATASET VCQI_HM_DATASET or VCQI_HH_DATASET."
				}
			}
			if `exitflag' != 1 {
				clear
				foreach v in $VCQI_LEVEL4_SET_VARLIST {
					append using `layout_`v''
				}
				replace order = _n
				save "$VCQI_OUTPUT_FOLDER/VCQI_LEVEL4_LAYOUT_automatic", replace
				vcqi_global VCQI_LEVEL4_SET_LAYOUT $VCQI_OUTPUT_FOLDER/VCQI_LEVEL4_LAYOUT_automatic
			}
		}
			
		* Put VCQI_LEVEL4_SET_LAYOUT into a set of globals
		if "$VCQI_LEVEL4_SET_LAYOUT" != "" {
			* List the two globals in the log
			vcqi_log_global $VCQI_LEVEL4_SET_VARLIST
			vcqi_log_global $VCQI_LEVEL4_SET_LAYOUT
			* Stop if the dataset does not exist
			capture confirm file "${VCQI_LEVEL4_SET_LAYOUT}.dta"
			if _rc != 0 {
				local exitflag 1
				di as error "VCQI_LEVEL4_SET_LAYOUT dataset does not exist"
				vcqi_log_comment $VCP 1 Error  "VCQI_LEVEL4_SET_LAYOUT dataset does not exist"
			}
			else {
				use "$VCQI_LEVEL4_SET_LAYOUT", clear
				compress
				* Stop if the dataset does not include the four variables we need 
				capture confirm numeric variable order
				local rc1 = _rc
				capture confirm str# variable rowtype label condition
				local rc2 = _rc
				if `rc1' != 0 | `rc2' != 0 {
					local exitflag 1
					di as error "VCQI_LEVEL4_SET_LAYOUT must contain a numeric variable named order and string variables named rowtype label and condition"
					vcqi_log_comment $VCP 1 Error  "VCQI_LEVEL4_SET_LAYOUT must contain a numeric variable named order and string variables named rowtype label and condition"
				}
				else {
					* Populate the globals with the contents of the layout dataset
					sort order
					global LEVEL4_SET_NROWS = _N
					* Clean up the variables, if needed
					replace rowtype   = trim(upper(rowtype))
					replace condition = trim(condition)
					replace condition = substr(condition,4,.) if lower(substr(condition,1,3)) == "if "
					replace label     = trim(label)
					forvalues i = 1/`=_N' {
						global LEVEL4_SET_ROWTYPE_`i'   `=rowtype[`i']'
						global LEVEL4_SET_ORDER_`i'     `=order[`i']'
						global LEVEL4_SET_LABEL_`i'     `=label[`i']'
						global LEVEL4_SET_CONDITION_`i' `=condition[`i']'
					}
				}
			}
		}
					

		* Check CI method
		if "$VCQI_CI_METHOD" == "" vcqi_global VCQI_CI_METHOD WILSON
		
		if !inlist(upper("$VCQI_CI_METHOD"),"LOGIT","WILSON","CLOPPER","CLOPPER-PEARSON","JEFFREYS") {
			di as error "Please set VCQI_CI_METHOD to either LOGIT, WILSON, CLOPPER-PEARSON or JEFFREYS."
			di as error "(It is currently set to: ${VCQI_CI_METHOD}.)"
			local exitflag 1
			vcqi_log_comment $VCP 1 Error "Please set VCQI_CI_METHOD to either LOGIT, WILSON, CLOPPER-PEARSON or JEFFREYS."
			vcqi_log_comment $VCP 1 Error "(It is currently set to: ${VCQI_CI_METHOD}.)"
		}
		
		* Check settings related to making tables and plots
		
		if "$EXPORT_TO_EXCEL" != "1" & "$EXPORT_TO_EXCEL" != "0" {
			di as error "Please set EXPORT_TO_EXCEL to 0 or 1."
			vcqi_log_comment $VCP 1 Error "Please set EXPORT_TO_EXCEL to 0 or 1."
			local exitflag 1
		}
		
		if "$EXPORT_TO_EXCEL" == "1" {
		
			foreach g in SHOW_LEVEL_1_ALONE SHOW_LEVEL_2_ALONE ///
					 SHOW_LEVEL_3_ALONE SHOW_LEVELS_2_3_TOGETHER ///
					 SHOW_LEVELS_1_4_TOGETHER SHOW_LEVELS_2_4_TOGETHER ///
					 SHOW_LEVELS_3_4_TOGETHER SHOW_LEVELS_2_3_4_TOGETHER ///
					 SHOW_BLANKS_BETWEEN_LEVELS {
								
				if "${`g'}" != "1" & "${`g'}" != "0" {
					di as error "Please set `g' to 0 or 1."
					vcqi_log_comment $VCP 1 Error "Please set `g' to 0 or 1."
					local exitflag 1
				}
			}
		}

		if "$EXPORT_TO_EXCEL" == "1" & ("$FORMAT_EXCEL" != "1" & "$FORMAT_EXCEL" != "0") {
			di as error "Please set FORMAT_EXCEL to 0 or 1."
			vcqi_log_comment $VCP 1 Error "Please set FORMAT_EXCEL to 0 or 1."
			local exitflag 1
		}

		if "$MAKE_PLOTS" != "1" & "$MAKE_PLOTS" != "0" {
			di as error "Please set MAKE_PLOTS to 0 or 1."
			vcqi_log_comment $VCP 1 Error "Please set MAKE_PLOTS to 0 or 1."
			local exitflag 1
		}
		
		* Do not make level2 plots by default
		if "$VCQI_MAKE_LEVEL2_IWPLOTS" == "" vcqi_global VCQI_MAKE_LEVEL2_IWPLOTS 0
		if "$VCQI_MAKE_LEVEL2_UWPLOTS" == "" vcqi_global VCQI_MAKE_LEVEL2_UWPLOTS 0

		if "$DELETE_VCQI_DATABASES_AT_END" != "1" & "$DELETE_VCQI_DATABASES_AT_END" != "0" {
			di as error "Please set DELETE_VCQI_DATABASES_AT_END to 0 or 1."
			vcqi_log_comment $VCP 1 Error "Please set DELETE_VCQI_DATABASES_AT_END to 0 or 1."
			local exitflag 1
		}
		
		if "$DELETE_TEMP_VCQI_DATASETS" != "1" & "$DELETE_TEMP_VCQI_DATASETS" != "0" {
			di as error "Please set DELETE_TEMP_VCQI_DATASETS to 0 or 1."
			vcqi_log_comment $VCP 1 Error "Please set DELETE_TEMP_VCQI_DATASETS to 0 or 1."
			local exitflag 1
		}
		
		if "$SAVE_VCQI_GPH_FILES" != "1" & "$SAVE_VCQI_GPH_FILES" != "0" {
			di as error "Please set SAVE_VCQI_GPH_FILES to 0 or 1."
			vcqi_log_comment $VCP 1 Error "Please set SAVE_VCQI_GPH_FILES to 0 or 1."
			local exitflag 1
		}

		* Default is to generate databases, although user can turn this off if they
		* already exist
		if "$VCQI_PREPROCESS_DATA" == ""    vcqi_global VCQI_PREPROCESS_DATA 1
		if "$VCQI_GENERATE_DVS" == ""       vcqi_global VCQI_GENERATE_DVS 1
		if "$VCQI_GENERATE_DATABASES" == "" vcqi_global VCQI_GENERATE_DATABASES 1
		
		
		* Default is to make all types of plots; user may override
		if "$MAKE_PLOTS" == "1" {	
			if "$VCQI_MAKE_OP_PLOTS" == "" 			vcqi_global VCQI_MAKE_OP_PLOTS 1
			if "$VCQI_MAKE_IW_PLOTS" == ""			vcqi_global VCQI_MAKE_IW_PLOTS 1
			if "$VCQI_MAKE_UW_PLOTS" == "" 			vcqi_global VCQI_MAKE_UW_PLOTS 1
			if "$VCQI_SAVE_OP_PLOT_DATA" == ""		vcqi_global VCQI_SAVE_OP_PLOT_DATA 0
		}
		
		
		global VCQI_SHOW4 =	$SHOW_LEVELS_1_4_TOGETHER   + ///
							$SHOW_LEVELS_2_4_TOGETHER   + ///
							$SHOW_LEVELS_3_4_TOGETHER   + ///
							$SHOW_LEVELS_2_3_4_TOGETHER > 0
					   
		global VCQI_SHOW3 = $SHOW_LEVEL_3_ALONE         + ///
							$SHOW_LEVELS_2_3_TOGETHER   + ///
							$SHOW_LEVELS_3_4_TOGETHER   + ///
							$SHOW_LEVELS_2_3_4_TOGETHER > 0 

		global VCQI_SHOW2 = $SHOW_LEVEL_2_ALONE         + ///
							$SHOW_LEVELS_2_3_TOGETHER   + ///
							$SHOW_LEVELS_2_4_TOGETHER   + ///
							$SHOW_LEVELS_2_3_4_TOGETHER > 0 
					   
		global VCQI_SHOW1 = $SHOW_LEVEL_1_ALONE + $SHOW_LEVELS_1_4_TOGETHER > 0	
		
		* If user specifies LEVEL4_SET with 2+ variables then turn off inchworm and unweighted plots
		if `=wordcount("$VCQI_LEVEL4_SET_VARLIST")' > 1 {	
			if "$VCQI_MAKE_IW_PLOTS" == "1" {
				vcqi_log_comment $VCP 2 Warning "VCQI does not make inchworm plots when the user asks for 2+ LEVEL4 stratifiers via the LEVEL4_SET syntax."
				vcqi_global VCQI_MAKE_IW_PLOTS 0
			}
			if "$VCQI_MAKE_UW_PLOTS" == "1" {
				vcqi_log_comment $VCP 2 Warning "VCQI does not make unweighted proportion plots when the user asks for 2+ LEVEL4 stratifiers via the LEVEL4_SET syntax."
				vcqi_global VCQI_MAKE_UW_PLOTS 0
			}
		}
		
		if "`exitflag'" == "1" {
			vcqi_global VCQI_ERROR 1
			noi vcqi_halt_immediately
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end