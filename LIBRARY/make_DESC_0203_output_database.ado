*! make_DESC_0203_output_database version 1.08 - Biostat Global Consulting - 2017-03-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added var name to new variable name: label variable name "Survey name for table output"
* 2016-02-12	1.02	Dale Rhoda		Added VCQI_DATABASES
* 2016-02-24	1.03	Dale Rhoda		Cleaned up Starting line
* 2017-01-09	1.04	Dale Rhoda		Switch from svyp to svypd
* 2017-01-31	1.05	Dale Rhoda		Generate LEVEL4 output using
*										VCQI_LEVEL4_SET_VARLIST & 
*										VCQI_LEVEL4_SET_LAYOUT
* 2017-03-07	1.06	Dale Rhoda		Guard against the case where N is 0
*										(Simply return . or . . . if wtd = 1)
* 2017-03-09	1.07	Dale Rhoda		Fixed logic for case where N is 0
* 2017-03-26	1.08	Dale Rhoda		Allow user to :
*										a) put sub-total BEFORE a variable or response
*										b) put sub-total AFTER  a variable or response
*										c) show sub-totals only
*******************************************************************************

program define make_DESC_0203_output_database

	syntax , VARiable(string) LABel(string asis) VID(string) MEASureid(string)

	local oldvcp $VCP
	global VCP make_DESC_0203_output_database
	vcqi_log_comment $VCP 5 Flow "Starting"

	
	quietly {
	
		* This program is used for DESC_02 and DESC_03...sort out which
		* is calling it now and set the appropriate local macro
			
		if "`measureid'" == "DESC_02" local mid 02
		if "`measureid'" == "DESC_03" local mid 03
		if "`mid'" == "" {
			di as error "MEASUREID should be DESC_02 or DESC_03 to call $VCP"
			vcqi_log_comment $VCP 1 Error "MEASUREID should be DESC_02 or DESC_03 to call $VCP"
			vcqi_global VCQI_ERROR 1
			vcqi_halt_immediately
		}

		vcqi_log_comment $VCP 3 Comment "measureid: `measureid' variable: `variable' vid: `vid'  label: `label' "

		use "${VCQI_OUTPUT_FOLDER}/DESC_`mid'_${ANALYSIS_COUNTER}_${DESC_`mid'_COUNTER}", clear
		
		if "`=upper("${DESC_`mid'_WEIGHTED}")'" == "YES" {
			svyset clusterid, weight(psweight) strata(stratumid)
			local wtd 1
		}
		if "`=upper("${DESC_`mid'_WEIGHTED}")'" == "NO" {
			svyset _n
			local wtd 0
		}

		* Build the lists of variables to post
		local vlist
		local plist
		local blist
		
		global DESC_`mid'_VORDER
		
		local level_count_without_subtotals = ${DESC_`mid'_LVL_COUNT_`vid'}
		
				
		* Skip this section of code if the user has asked for subtotals only to be listed
		if "${DESC_`mid'_SHOW_SUBTOTALS_ONLY"}" == "" {
		
			forvalues i = 1/${DESC_`mid'_LVL_COUNT_`vid'} {
			
				* If a subtotal is supposed to be listed *before* this individual response...add it here
				forvalues k = 1/${DESC_`mid'_ST_COUNT_`vid'} {
					if "${DESC_`mid'_SUBTOTAL_LIST_`k'}" != "" {
						if upper(word("${DESC_`mid'_SUBTOTAL_LIST_`k'}",1)) == "BEFORE" & word("${DESC_`mid'_SUBTOTAL_LIST_`k'}",2) == word("${DESC_`mid'_VARIABLES}",`i') {
							global DESC_`mid'_VORDER ${DESC_`mid'_VORDER} `=`level_count_without_subtotals' + `k''
							local j `=${DESC_`mid'_LVL_COUNT_`vid'}+`k''
							local vlist `vlist' desc`mid'_`vid'_st`k'
							local plist `plist' pct`j'
							local blist `blist' (.)
							if `wtd' local plist `plist' cill`j' ciul`j'
							if `wtd' local blist `blist' (.) (.)
							local vlabel`j' `: variable label desc`mid'_`vid'_st`k''
						}
					}
				}
						
				* List the individual variable		
						
				global DESC_`mid'_VORDER ${DESC_`mid'_VORDER} `i'
				local vlist `vlist' desc`mid'_`vid'_`i'
				local plist `plist' pct`i'
				local blist `blist' (.)
				if `wtd' local plist `plist' cill`i' ciul`i'
				if `wtd' local blist `blist' (.) (.)
				local vlabel`i' `: variable label desc`mid'_`vid'_`i''
				
				* If a subtotal is supposed to be listed *after* this individual response...add it here
				
				forvalues k = 1/${DESC_`mid'_ST_COUNT_`vid'} {
					if "${DESC_`mid'_SUBTOTAL_LIST_`k'}" != "" {
						if upper(word("${DESC_`mid'_SUBTOTAL_LIST_`k'}",1)) == "AFTER" & word("${DESC_`mid'_SUBTOTAL_LIST_`k'}",2) == word("${DESC_`mid'_VARIABLES}",`i') {
							global DESC_`mid'_VORDER ${DESC_`mid'_VORDER} `=`level_count_without_subtotals' + `k''
							local j `=${DESC_`mid'_LVL_COUNT_`vid'}+`k''
							local vlist `vlist' desc`mid'_`vid'_st`k'
							local plist `plist' pct`j'
							local blist `blist' (.)
							if `wtd' local plist `plist' cill`j' ciul`j'
							if `wtd' local blist `blist' (.) (.)
							local vlabel`j' `: variable label desc`mid'_`vid'_st`k''
						}
					}
				}
			}
		}
		
		forvalues k = 1/${DESC_`mid'_ST_COUNT_`vid'} {
			*If we haven't already listed this subtotal above either before or after an individual response, then list it here
			if "${DESC_`mid'_SUBTOTAL_LIST_`k'}"=="" {
				global DESC_`mid'_VORDER ${DESC_`mid'_VORDER} `=`level_count_without_subtotals' + `k''
				local j `=${DESC_`mid'_LVL_COUNT_`vid'}+`k''
				local vlist `vlist' desc`mid'_`vid'_st`k'
				local plist `plist' pct`j'
				local blist `blist' (.)
				if `wtd' local plist `plist' cill`j' ciul`j'
				if `wtd' local blist `blist' (.) (.)
				local vlabel`j' `: variable label desc`mid'_`vid'_st`k''
			}
		}
		
		* If the analysis is not weighted, include a column with n at the far right
		* If the analysis is weighted, also include nwtd
		local nlist n
		local blist `blist' (.)
		if `wtd' local nlist n nwtd
		if `wtd' local blist `blist' (.)
				
		capture postclose go

		postfile go level id str30 level4id str30 level4name str30 outcome ///
					`plist' `nlist' using ///
		  "${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}_`vid'_database", replace			

		global VCQI_DATABASES $VCQI_DATABASES `measureid'_${ANALYSIS_COUNTER}_`vid'_database
							
		forvalues l = 1/3 {
			
			quietly levelsof level`l'id, local(llist)
			if "${VCQI_SHOW`l'}" == "1" & "`llist'" != "" {	
			
				foreach i in `llist' {
				
					local postlist
					forvalues k = 1/`=wordcount("`vlist'")' {
						count if !missing(`=word("`vlist'",`k')') & level`l' == `i' 
						if r(N) > 0 {
							svypd `=word("`vlist'",`k')' if level`l'id == `i', method($VCQI_CI_METHOD) adjust 
							local postlist `postlist' (`=scalar(r(svyp))') 
							if `wtd' local postlist `postlist' (`=scalar(r(lb_alpha))') (`=scalar(r(ub_alpha))')
						}
						else {
							local postlist `postlist' (.)
							if `wtd' local postlist `postlist' (.) (.)
						}
					}
					local postlist `postlist' (`=scalar(r(N))')
					if `wtd' local postlist `postlist' (`=scalar(r(Nwtd))')

					post go (`l') (`i') ("") ("") ("`variable'") `postlist'
				
					* if the user has asked for a stratified analysis, either by
					* urban/rural or some other stratifier, then calculate the 
					* coverage results for each sub-stratum within the third
					* level strata
							
					if "$VCQI_LEVEL4_STRATIFIER" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
					
						levelsof $VCQI_LEVEL4_STRATIFIER, local(llist4)
						
						foreach j in `llist4' {
						
							local postlist
							forvalues k = 1/`=wordcount("`vlist'")' {
								count if !missing(`=word("`vlist'",`k')') & level`l'id == `i' & $VCQI_LEVEL4_STRATIFIER == `j'
								if r(N) > 0 {
									svypd `=word("`vlist'",`k')' if level`l'id == `i' & ///
										$VCQI_LEVEL4_STRATIFIER == `j', method($VCQI_CI_METHOD) adjust
									local postlist `postlist' (`=scalar(r(svyp))') 
									if `wtd' local postlist `postlist' (`=scalar(r(lb_alpha))') (`=scalar(r(ub_alpha))')
								}
								else {
									local postlist `postlist' (.)
									if `wtd' local postlist `postlist' (.) (.)
								}
							}
							local postlist `postlist' (`=scalar(r(N))')
							if `wtd' local postlist `postlist' (`=scalar(r(Nwtd))')
						
							* pass along the name and id of the sub-stratum
							if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == ///
									"str" local l4name = "`j'"
							if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) != "str" ///
								local l4name = "`: label ($VCQI_LEVEL4_STRATIFIER) `j''"

							post go (`l') (`i') ("`j'") ("`l4name'") ///
								("`variable'") `postlist'
						}
					}			
					
					if "$VCQI_LEVEL4_SET_VARLIST" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
						
						forvalues j = 1/$LEVEL4_SET_NROWS {
						
							local l4name ${LEVEL4_SET_LABEL_`j'}

							if "${LEVEL4_SET_ROWTYPE_`j'}" == "DATA_ROW" {
										
								local postlist
								forvalues k = 1/`=wordcount("`vlist'")' {
									count if !missing(`=word("`vlist'",`k')') & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
									if r(N) > 0 {
										svypd `=word("`vlist'",`k')' if level`l'id == `i' & ///
											${LEVEL4_SET_CONDITION_`j'}, method($VCQI_CI_METHOD) adjust
										local postlist `postlist' (`=scalar(r(svyp))') 
										if `wtd' local postlist `postlist' (`=scalar(r(lb_alpha))') (`=scalar(r(ub_alpha))')
									}
									else {
										local postlist `postlist' (.)
										if `wtd' local postlist `postlist' (.) (.)
									}
								}
								local postlist `postlist' (`=scalar(r(N))')
								if `wtd' local postlist `postlist' (`=scalar(r(Nwtd))')

								post go (`l') (`i') ("`j'") ("`l4name'") ("`variable'") `postlist'
							}
							
							if "${LEVEL4_SET_ROWTYPE_`j'}" == "BLANK_ROW" ///
								post go (`l') (`i') ("`j'") ("") ("") `blist'

							if "${LEVEL4_SET_ROWTYPE_`j'}" == "LABEL_ONLY" ///
								post go (`l') (`i') ("`j'") ("`l4name'") ("") `blist'
							
						}
					}						
				}
			}
		}

		capture postclose go
		
		* Now do a little work to put the ids and names of the various stratum 
		* levels into the database 
		*
		* The database will serve at least two purposes:
		*
		* 1. It can be exported to a flat file or excel file or database and
		*    may be used with mail-merge software to generate reporting forms
		*    in programs like Microsoft Word.  This provides future flexibility.
		*
		* 2. It will serve as the basis of the `measureid'_05TO program that
		*    exports requested records out to Microsoft Excel.
		
		use "${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}_`vid'_database", clear
		qui compress
		
		label variable outcome `"`label'"'
		
		if "${DESC_`mid'_SHOW_SUBTOTALS_ONLY"}" == "" {

			forvalues i = 1/${DESC_`mid'_LVL_COUNT_`vid'} {
				label variable pct`i' "`vlabel`i''"
			}
		}
		
		forvalues i = 1/${DESC_`mid'_ST_COUNT_`vid'} {
			local j `=${DESC_`mid'_LVL_COUNT_`vid'}+`i''
			label variable pct`j' "`vlabel`j''"
		}	
		
		* bring in level 1 name
		gen level1id = 1
		merge m:1 level1id using "${LEVEL1_NAME_DATASET}"
		keep if _merge == 1 | _merge == 3
		drop _merge
		
		* bring in level 2 names
		gen level2id = id if level == 2
		merge m:1 level2id using "${LEVEL2_NAME_DATASET}"
		keep if _merge == 1 | _merge == 3
		drop _merge
		
		* bring in level 3 names
		gen level3id = id if level == 3
		merge m:1 level3id using "${LEVEL3_NAME_DATASET}"
		keep if _merge == 1 | _merge == 3
		drop _merge
		
		* bring in level 2 names for level 3
		merge m:1 level3id using level2namesforlevel3, keepusing(level2nameforlevel3)
		keep if _merge == 1 | _merge == 3
		drop _merge
		replace level2name = level2nameforlevel3 if level == 3
		drop level2nameforlevel3

		* bring in the level 2 names for the level 3 rows, also
		merge m:1 level2name using "${LEVEL2_NAME_DATASET}", update
		keep if _merge == 1 | _merge == 3 | _merge == 4
		drop _merge
		
		* we have all the components of the names; make a single name variable
		* that holds what we think would be best to list in a table
		* (but also keep the components)
		
		gen name = ""
		replace name = level1name if level == 1
		replace name = level2name if level == 2
		replace name = level3name if level == 3
		capture replace level4name = string(level4name)
		* Append the name to the front of the level4name if we have a single stratifier
		* Otherwise leave it off
		*replace name = name + " - " + level4name if !missing(level4name) & "$VCQI_LEVEL4_STRATIFIER"  != ""
		replace name =                level4name if !missing(level4name) & "$VCQI_LEVEL4_SET_VARLIST" != ""
		label variable name "Survey name for table output"

		order name level1id level1name level2id level2name level3id level3name ///
			  level4id level4name, after(level)

		* if the user has NOT asked for results by sub-strata, drop the 
		* variable that lists sub-stratum names
		if "$VCQI_LEVEL4_STRATIFIER" == "" & "$VCQI_LEVEL4_SET_VARLIST" == "" drop level4name
		
		sort level id name
		
		destring _all, replace
		
		* Save these variables to the database for future reference...
		gen weighted = "${DESC_`mid'_WEIGHTED}"
		label variable weighted "Are the percentages weighted?"
		gen denominator = "${DESC_`mid'_DENOMINATOR}"
		label variable denominator "Which respondents are in the denominator?"
		
		qui compress

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end