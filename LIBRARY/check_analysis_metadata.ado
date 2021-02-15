*! check_analysis_metadata version 1.28 - Biostat Global Consulting - 2021-02-13
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

* 2017-06-07 	1.05	MK Trimner		Added checks for CM, HH, HM and levels of datasets
* 										made levels1,2 and 3 datasets required
* 2017-07-05	1.06	MK Trimner		Added file checks within the variable checks
* 2017-07-18	1.07	MK Trimner		Put all other checks within main folder checks as
*										these will error out if folders are not set	
*										Added HM29 to required HM var list
* 2017-07-18	1.08	MK Trimner		Removed var type check for HH14, HM09			
* 2017-07-18	1.09	Dale Rhoda		Syntax cleanup
* 2017-07-19	1.10	Dale Rhoda		Syntax cleanup
* 2017-08-26	1.11	Mary Prier		Added version 14.1 line
* 2018-05-11	1.12	Dale Rhoda		Check all datasets for LEVEL4 variable 
*                                       before finally setting exitflag
*                                       Also, Added $VCQI_SVYSET_SYNTAX 
* 2018-05-14	1.13	Dale Rhoda		Moved another curly bracket to handle
*                                       case with LEVEL4_SET_VARLIST but no 
*                                       LEVEL4_SET_LAYOUT
* 2018-05-16	1.14	Dale Rhoda		Fixed indentation & problem(s) with }'s
* 2018-05-22	1.15	Dale Rhoda		Relax some of the checks to give 
*                                       warnings instead of errors
* 2018-05-30	1.16	Dale Rhoda		FORMAT_EXCEL defaults to 1 
* 2018-05-31	1.17	Dale Rhoda		Added SET to LAYOUT filename
* 2019-01-02	1.18	Dale Rhoda		Added VCQI_TEMP_STRATHOLDER to the list
*										of files where we search for 
*										stratifiers
* 2019-04-25	1.19	Dale Rhoda		Warnings should be level 2...not 1
* 2019-10-10	1.20	Dale Rhoda		Allow user to specify VCQI_NUM_DECIMAL_DIGITS
* 2019-10-13	1.21	Dale Rhoda		Post a warning to the log if user asks 
*										for bars instead of inchworms; VCQI does
*										NOT make double-inchworm plots with bars
* 2020-01-20	1.22	Dale Rhoda		Move CM checks to 
*										check_RI/SIA/TT_analysis_metadata
* 2020-12-12	1.23	Dale Rhoda		Allow SHOW_LEVEL_4_ALONE
* 2020-12-16	1.24	Cait Clary		Save user input for IWPLOT_SHOWBARS;
*										change log message for bars/double iw
* 2021-01-09	1.25	Dale Rhoda		If user asks for 2+ level 4 stratifiers
*                                       using the LEVEL4_SET syntax, then only
*                                       make inchworm and unweighted proportion
*                                       plots if they *also* ask for
*                                       PLOT_OUTCOMES_IN_TABLE_ORDER.
*                                       (the plots are very cluttered if there
*                                         are numerous stratifiers with 
*                                         numerous levels)
* 2021-01-14	1.25	Dale Rhoda		If user specifies HM dataset, the var
*                                       HM29 must be numeric
* 2021-01-17	1.26	Dale Rhoda		Check values of VCQI_DOUBLE_IWPLOT_CITEXT.
*                                       Set it to 2 if the user did not specify.
* 2021-02-11	1.27	Dale Rhoda		Set the global IWPLOT_TYPE so the 
*                                       messages to the screen reflect whether 
*                                       the user asked for inchworms or bar charts
* 2021-02-13	1.28	Dale Rhoda		Strip .dta off the level4 LAYOUT filename
*                                       if the user includes it in their control
*                                       program
*******************************************************************************

program define check_analysis_metadata
	version 14.1

	local oldvcp $VCP
	global VCP check_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {

		local exitflag 0	

		* Check globals that are populated		
		foreach g in VCQI_DATA_FOLDER VCQI_OUTPUT_FOLDER VCQI_ANALYSIS_NAME  {

			if "$`g'" == "" {
				di as error "Please set `g'."
				vcqi_log_comment $VCP 1 Error "Please set `g'"
				local exitflag 1
			}	

		}
		
		* This syntax should be set in Block E, set as default if user failed to specify
		if "$VCQI_SVYSET_SYNTAX"=="" vcqi_global VCQI_SVYSET_SYNTAX svyset clusterid, strata(stratumid) weight(psweight)

		* Check for variables if HH and HM dataset dataset is provided
		local HHlist HH01 HH03 HH14
		local HMlist HM01 HM03 HM09 HM22 HM29

		if "$VCQI_DATA_FOLDER" != "" {
			foreach d in HH HM {
				if "${VCQI_`d'_DATASET}" != "" {
					capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_`d'_DATASET}.dta"
					if _rc==0 {
						use "${VCQI_DATA_FOLDER}/${VCQI_`d'_DATASET}", clear

						foreach v in ``d'list' {
							capture confirm variable `v' 

							* If the variable exists, confirm the variable is not missing and has the correct variable type
							if _rc==0 {
								if !inlist("`v'", "HH14", "HM09", "HM29") {		
									capture confirm numeric variable `v'
									if _rc!=0 {
										di as error "`v' needs to be a numeric variable in `d' dataset."
										vcqi_log_comment $VCP 1 Error "`v' needs to be a numeric variable in `d' dataset."
										local exitflag 1
									}

									capture assert !missing(`v')
									if _rc!=0 {
										di as error "`v' should not have a missing value in the `d' dataset."
										vcqi_log_comment $VCP 2 Warning "`v' should not have a missing value in the `d' dataset."
									}
								}
							}
							else {
								di as error "Variable `v' does not exist in `d' dataset and is required to run VCQI."
								vcqi_log_comment $VCP 1 Error "Variable `v' does not exist in `d' dataset and is required to run VCQI."
								local exitflag 1
							}
						}
					}
					else if _rc!=0 {
						di as error "The file defined by global macros ${VCQI_DATA_FOLDER}/${VCQI_`d'_DATASET} does not exist." 
						vcqi_log_comment $VCP 1 Error  "The file defined by global macros ${VCQI_DATA_FOLDER}/${VCQI_`d'_DATASET} does not exist." 
						local exitflag 1
					}
				}
			}
		}

		* Check for existence of datasets listing strata names and orders

		* Confirm contents of levelof datasets to ensure dataset exists 
		* Confirm the level*id, level*name and level*order variables exist
		* Confirm variables are not missing and have the correct variable type.

		forvalues n = 1/3 {
			if "${LEVEL`n'_NAME_DATASET}" == "" {
				di as error "Please set LEVEL`n'_NAME_DATASET"
				vcqi_log_comment $VCP 1 Error "Please set LEVEL`n'_NAME_DATASET"
				local exitflag 1
			}
			else {					
				vcqi_log_global LEVEL`n'_NAME_DATASET
				capture confirm file "${LEVEL`n'_NAME_DATASET}.dta"
				if _rc != 0 {
					di as error "LEVEL`n'_NAME_DATASET does not exist"
					vcqi_log_comment $VCP 1 Error  "LEVEL`n'_NAME_DATASET does not exist"
					local exitflag 1
				}
				else {
					use "${LEVEL`n'_NAME_DATASET}", clear
					capture confirm variable level`n'id level`n'name
					if _rc != 0 {
						di as error "LEVEL`n'_NAME_DATASET should contain variables level`n'id and level`n'name."
						vcqi_log_comment $VCP 1 Error "LEVEL`n'_NAME_DATASET should contain variables level`n'id and level`n'name."
						local exitflag 1
					}
					else {
						foreach v in level`n'id level`n'name {
							if "`v'" == "level`n'id" local i numeric
							else local i string

							capture confirm `i' variable `v'
							if _rc != 0 {
								di as error "`v' needs to be a `i' variable in LEVEL`n'_NAME_DATASET."
								vcqi_log_comment $VCP 1 Error "`v' needs to be a `i' variable in LEVEL`n'_NAME_DATASET."
								local exitflag 1
							}

							capture assert !missing(`v')
							if _rc !=0 {
								di as error "`v' cannot have a missing value in the LEVEL`n'_NAME_DATASET."
								vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the LEVEL`n'_NAME_DATASET."
								local exitflag 1
							}
						}

						if "`n'" == "1" {
							capture assert _N==1
							if _rc!=0 {
								di as error "LEVEL`n'_NAME_DATASET can only have 1 observation."
								vcqi_log_comment $VCP 1 Error "LEVEL`n'_NAME_DATASET can only have 1 observation."
								local exitflag 1
							}
						}
					}
				}
			}

			if inlist("`n'", "2", "3") {
				if "${LEVEL`n'_ORDER_DATASET}" == "" {
					di as error "Please set LEVEL`n'_ORDER_DATASET"
					vcqi_log_comment $VCP 1 Error "Please set LEVEL`n'_ORDER_DATASET"
					local exitflag 1
				}
				else {

					vcqi_log_global LEVEL`n'_ORDER_DATASET
					capture confirm file "${LEVEL`n'_ORDER_DATASET}.dta"

					if _rc != 0 {
						di as error "LEVEL`n'_ORDER_DATASET does not exist."
						vcqi_log_comment $VCP 1 Error "LEVEL`n'_ORDER_DATASET does not exist."
						local exitflag 1
					}
					else {
						use "${LEVEL`n'_ORDER_DATASET}", clear
						capture confirm variable level`n'id level`n'order
						if _rc != 0 {
							di as error "LEVEL`n'_ORDER_DATASET should contain variables level`n'id and level`n'order."
							vcqi_log_comment $VCP 1 Error "LEVEL`n'_ORDER_DATASET should contain variables level`n'id and level`n'order."
							local exitflag 1
						}
						else {
							foreach v in level`n'id level`n'order {
								capture confirm numeric variable `v'
								if _rc != 0 {
									di as error "`v' needs to be a numeric variable in LEVEL`n'_ORDER_DATASET."
									vcqi_log_comment $VCP 1 Error "`v' needs to be a numeric variable in LEVEL`n'_ORDER_DATASET."
									local exitflag 1
								}

								capture assert !missing(`v')
								if _rc!=0 {
									di as error "`v' cannot have a missing value in the LEVEL`n'_ORDER_DATASET."
									vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the LEVEL`n'_ORDER_DATASET."
									local exitflag 1
								}
							}
						}
					}
				}
			}


			*************************************************************************

			* Confirm contents of level 4 names and order datasets, if VCQI_LEVEL4_STRATIFIER is requested
			* Confirm the level4id level4name level4order are not missing and have the correct variable type.

			if "$VCQI_LEVEL4_STRATIFIER" != "" & ///
				( "$SHOW_LEVELS_1_4_TOGETHER" == "1" | "$SHOW_LEVELS_2_4_TOGETHER"   == "1"   | ///
				"$SHOW_LEVELS_3_4_TOGETHER" == "1" | "$SHOW_LEVELS_2_3_4_TOGETHER" == "1" ) {

				vcqi_log_global LEVEL4_ORDER_DATASET
				capture confirm file "${LEVEL4_ORDER_DATASET}.dta"
				if _rc != 0 {
					di as error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_ORDER_DATASET does not exist."
					vcqi_log_comment $VCP 1 Error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_ORDER_DATASET does not exist."
					local exitflag 1
				}
				else {
					use "${LEVEL4_ORDER_DATASET}", clear
					capture confirm variable level4id level4order
					if _rc != 0 {
						di as error "LEVEL4_ORDER_DATASET should contain variables level4id and level4order."
						vcqi_log_comment $VCP 1 Error "LEVEL4_ORDER_DATASET should contain variables level4id and level4order."
						local exitflag 1
					}
					else {
						foreach v in level4id level4order {
							capture confirm numeric variable `v'
							if _rc != 0 {
								di as error "`v' needs to be a numeric variable in LEVEL4_ORDER_DATASET."
								vcqi_log_comment $VCP 1 Error "`v' needs to be a `i' variable in LEVEL4_ORDER_DATASET."
								local exitflag 1
							}

							capture assert !missing(`v')
							if _rc!=0 {
								di as error "`v' cannot have a missing value in the LEVEL4_ORDER_DATASET."
								vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the LEVEL4_ORDER_DATASET."
								local exitflag 1
							}
						}
					}
				}

				vcqi_log_global LEVEL4_NAME_DATASET
				capture confirm file "${LEVEL4_NAME_DATASET}.dta"
				if _rc != 0 {
					di as error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_NAME_DATASET does not exist."
					vcqi_log_comment $VCP 1 Error "The user has requested level 4 stratification using the stratifier variable $VCQI_LEVEL4_STRATIFIER but the global macro LEVEL4_NAME_DATASET does not exist."
					local exitflag 1
				}
				else {
					use "${LEVEL4_NAME_DATASET}", clear
					capture confirm variable level4id level4name
					if _rc != 0 {
						di as error "LEVEL4_NAME_DATASET should contain variables level4id and level4name."
						vcqi_log_comment $VCP 1 Error "LEVEL4_NAME_DATASET should contain variables level4id and level4name."
						local exitflag 1

					}
					else {
						foreach v in level4id level4name {
							if "`v'" == "level4id" local i numeric
							else local i string

							capture confirm `i' variable `v'
							if _rc != 0 {
								di as error "`v' needs to be a `i' variable in LEVEL4_NAME_DATASET."
								vcqi_log_comment $VCP 1 Error "`v' needs to be a `i' variable in LEVEL4_NAME_DATASET."
								local exitflag 1
							}

							capture assert !missing(`v')
							if _rc!=0 {
								di as error "`v' cannot have a missing value in the LEVEL4_NAME_DATASET."
								vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the LEVEL4_NAME_DATASET."
								local exitflag 1
							}
						}
					}
				}
			}
		}

		* If user requests level 4 output, they must specify a level 4 stratifier or a set varlist

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

				noi di as text "Looking for `v'..."
				local continue 

				* We don't know which dataset holds each stratifier...most will be 
				* in the RI/SIA/TT datasets but some might be in CM or another...so 
				* loop over the datasets and keep going 'til we find it
				
				* Note that it may be convenient sometimes to use a stratifier
				* that is constructed DURING the VCQI run, and therefore does
				* not exist in the datasets in the VCQI_DATA_FOLDER.  To 
				* accomodate this option, we include a global in this list
				* named $VCQI_TEMP_STRATHOLDER.  This global can point to a
				* file in the VCQI_OUTPUT_FOLDER.  Note, for instance how it 
				* is used in the indicator named SIA_COVG_04.

				foreach d in $VCQI_RI_DATASET $VCQI_SIA_DATASET $VCQI_TT_DATASET $VCQI_CM_DATASET $VCQI_RIHC_DATASET $VCQI_HM_DATASET $VCQI_HH_DATASET $VCQI_TEMP_STRATHOLDER {

					if `"`d'"' != `"$VCQI_TEMP_STRATHOLDER"' use "$VCQI_DATA_FOLDER/`d'", clear
					else use "$VCQI_OUTPUT_FOLDER/`d'", clear
					capture confirm variable `v'
					if _rc == 0 {		
						noi di as text "Found `v' in `d'..."
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
								replace label = "`: word `i' of `llist''" in `=`i'+1'
								replace condition = "`v' == " + char(34) + "`: word `i' of `llist''" + char(34) in `=`i'+1'
							}
							replace order = _n
							tempfile layout_`v'
							save `layout_`v'', replace
						}
						else {
							levelsof `v', local(llist)
							forvalues i = 1/`=wordcount("`llist'")' {
								local storeit_`i' `: label (`v') `: word `i' of `llist'''
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
								replace condition = "`v' ==  `: word `i' of `llist''" in `=`i'+1'
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
			}
			* If we haven't found the variable in any of the aforementioned
			* datasets then it's probably a typo...throw an error and stop
			if "`continue'" == "" {
				local exitflag 1
				di as error                   "User asked for variable `v' in VCQI_LEVEL4_SET_VARLIST but that variable doesn't seem to appear in VCQI_RI_DATASET VCQI_SIA_DATASET VCQI_TT_DATASET VCQI_CM_DATASET VCQI_RIHC_DATASET VCQI_HM_DATASET VCQI_HH_DATASET."
				vcqi_log_comment $VCP 1 Error "User asked for variable `v' in VCQI_LEVEL4_SET_VARLIST but that variable doesn't seem to appear in VCQI_RI_DATASET VCQI_SIA_DATASET VCQI_TT_DATASET VCQI_CM_DATASET VCQI_RIHC_DATASET VCQI_HM_DATASET VCQI_HH_DATASET."
			}
			if `exitflag' != 1 {
				clear
				foreach v in $VCQI_LEVEL4_SET_VARLIST {
					append using `layout_`v''
				}
				replace order = _n
				save "$VCQI_OUTPUT_FOLDER/VCQI_LEVEL4_SET_LAYOUT_automatic", replace
				vcqi_global VCQI_LEVEL4_SET_LAYOUT $VCQI_OUTPUT_FOLDER/VCQI_LEVEL4_SET_LAYOUT_automatic
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
				vcqi_global VCQI_ERROR 1
				vcqi_log_comment $VCP 1 Error  "VCQI_LEVEL4_SET_LAYOUT dataset does not exist"
			}
			else {
				use "$VCQI_LEVEL4_SET_LAYOUT", clear
				compress
				* Stop if the dataset does not include the four variables we need 
				capture confirm numeric variable order
				local rc1 = _rc
				capture confirm string variable rowtype label condition
				local rc2 = _rc
				if `rc1' != 0 | `rc2' != 0 {
					local exitflag 1
					di as error "VCQI_LEVEL4_SET_LAYOUT must contain a numeric variable named order and string variables named rowtype, label and condition"
					vcqi_log_comment $VCP 1 Error  "VCQI_LEVEL4_SET_LAYOUT must contain a numeric variable named order and string variables named rowtype, label and condition"
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

		* For backward compatibility, SHOW_LEVEL_4_ALONE may be missing;
		* we set it to 0 here by default.  If it is not missing, it
		* must be 0 or 1 just like the other similar globals
		if "$SHOW_LEVEL_4_ALONE" == "" vcqi_global SHOW_LEVEL_4_ALONE 0
			
		if "$EXPORT_TO_EXCEL" == "1" {

			foreach g in SHOW_LEVEL_1_ALONE SHOW_LEVEL_2_ALONE ///
				SHOW_LEVEL_3_ALONE SHOW_LEVEL_4_ALONE SHOW_LEVELS_2_3_TOGETHER ///
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

		if "$FORMAT_EXCEL" != "1" & "$FORMAT_EXCEL" != "0" vcqi_global FORMAT_EXCEL 1

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


		global VCQI_SHOW4 =	$SHOW_LEVEL_4_ALONE  + ///
		    $SHOW_LEVELS_1_4_TOGETHER   + ///
			$SHOW_LEVELS_2_4_TOGETHER   + ///
			$SHOW_LEVELS_3_4_TOGETHER   + ///
			$SHOW_LEVELS_2_3_4_TOGETHER > 0

		global VCQI_SHOW3 = $SHOW_LEVEL_3_ALONE  + ///
			$SHOW_LEVELS_2_3_TOGETHER   + ///
			$SHOW_LEVELS_3_4_TOGETHER   + ///
			$SHOW_LEVELS_2_3_4_TOGETHER > 0 

		global VCQI_SHOW2 = $SHOW_LEVEL_2_ALONE  + ///
			$SHOW_LEVELS_2_3_TOGETHER   + ///
			$SHOW_LEVELS_2_4_TOGETHER   + ///
			$SHOW_LEVELS_2_3_4_TOGETHER > 0 

		global VCQI_SHOW1 = $SHOW_LEVEL_1_ALONE + $SHOW_LEVELS_1_4_TOGETHER > 0	

		* If user specifies LEVEL4_SET with 2+ variables *AND*
		* does not ask to have outcomes plotted in TABLE_ORDER, 
		* then turn off inchworm and unweighted plots

		if `=wordcount("$VCQI_LEVEL4_SET_VARLIST")' > 1 & "$PLOT_OUTCOMES_IN_TABLE_ORDER" != "1" {	
			if "$VCQI_MAKE_IW_PLOTS" == "1" {
				vcqi_log_comment $VCP 2 Warning "VCQI does not make inchworm or bar plots when the user asks for 2+ LEVEL4 stratifiers via the LEVEL4_SET syntax and does NOT ask for PLOT_OUTCOMES_IN_TABLE_ORDER."
				vcqi_global VCQI_MAKE_IW_PLOTS 0
			}
			if "$VCQI_MAKE_UW_PLOTS" == "1" {
				vcqi_log_comment $VCP 2 Warning "VCQI does not make unweighted proportion plots when the user asks for 2+ LEVEL4 stratifiers via the LEVEL4_SET syntax and does NOT ask for PLOT_OUTCOMES_IN_TABLE_ORDER."
				vcqi_global VCQI_MAKE_UW_PLOTS 0
			}
		}

		* If user specifies VCQI_NUM_DECIMAL_DIGITS, use it; default to 1
		if "$VCQI_NUM_DECIMAL_DIGITS" == "" vcqi_global VCQI_NUM_DECIMAL_DIGITS 1
		vcqi_global VCQI_NUM_DECIMAL_DIGITS = int($VCQI_NUM_DECIMAL_DIGITS)
		
		* Default IWPLOT_SHOWBARS to 0 
		if "$IWPLOT_SHOWBARS" != "1"	vcqi_global IWPLOT_SHOWBARS 0

		if "$IWPLOT_SHOWBARS" == "1" ///
			vcqi_log_comment $VCP 3 Comment "The global macro IWPLOT_SHOWBARS is set to 1. So VCQI will make barcharts instead of inchworm plots."
			
		if "$IWPLOT_SHOWBARS" == "1" vcqi_global IWPLOT_TYPE Bar chart
		else                         vcqi_global IWPLOT_TYPE Inchworm plot
			
			
		*************************
		* Global that controls right side text for double inchworm plots
		
		* Default to point estimates only for both distributions
		if "$VCQI_DOUBLE_IWPLOT_CITEXT" == "" vcqi_global VCQI_DOUBLE_IWPLOT_CITEXT 1
		
		* If user specified something besides 1 or 2 or 3, reset to 2 and issue warning
		if !inlist("$VCQI_DOUBLE_IWPLOT_CITEXT","1","2","3") {			
			vcqi_log_comment $VCP 2 Warning "User specified an invalid value of VCQI_DOUBLE_IWPLOT_CITEXT.  Valid values include 1 or 2 or 3.  User specified ${VCQI_DOUBLE_IWPLOT_CITEXT}.  Resetting this parameter to default value of 1."
			vcqi_global VCQI_DOUBLE_IWPLOT_CITEXT 1
		}
		
		**************************
		
		* Aggregate databases unless (programmer's option) the user asks not to
		* by setting VCQI_AGGREGATE_VCQI_DATABASES to something other than 1 (like 0)
		if "$AGGREGATE_VCQI_DATABASES" == "" vcqi_global AGGREGATE_VCQI_DATABASES 1
			
		if "`exitflag'" == "1" {
			vcqi_global VCQI_ERROR 1
			noi vcqi_halt_immediately
		}
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
