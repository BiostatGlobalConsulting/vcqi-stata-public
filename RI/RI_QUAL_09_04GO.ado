*! RI_QUAL_09_04GO version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added var name to new variable name: label variable name "Survey name for table output"
* 2017-01-31	1.02	Dale Rhoda		Generate LEVEL4 output using
*										VCQI_LEVEL4_SET_VARLIST & 
*										VCQI_LEVEL4_SET_LAYOUT
* 2017-05-17	1.03	Dale Rhoda		Only calculate anydose results for levels
*										the user has requested
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_09_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_09_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local vc  `=lower("$RI_QUAL_09_VALID_OR_CRUDE")'
		local pvc `=proper("`vc'")'
		local measureid RI_QUAL_09
		
		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}", clear
		
		foreach d in $RI_DOSE_LIST {
		
			noi di _continue _col(5) "`d' "

			capture postclose go
			postfile go level id str30 level4id str30 level4name str30 dose ///
				n_eligible n_mov n_uncor_mov n_cor_mov using ///
				"${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}_`d'_database", replace

			global VCQI_DATABASES $VCQI_DATABASES `measureid'_${ANALYSIS_COUNTER}_`d'_database
								
			forvalues l = 1/3 {
				quietly levelsof level`l'id, local(llist)
				if "${VCQI_SHOW`l'}" == "1" & "`llist'" != "" {
					foreach i in `llist' {
						local plist
						count if !missing(child_had_mov_`d') & level`l'id == `i'
						local plist `plist' (`=scalar(r(N))')
						count if child_had_mov_`d' == 1 & level`l'id == `i'
						local plist `plist' (`=scalar(r(N))')
						count if child_had_uncor_mov_`d' == 1 & level`l'id == `i'
						local plist `plist' (`=scalar(r(N))')
						count if child_had_cor_mov_`d' == 1 & level`l'id == `i'
						local plist `plist' (`=scalar(r(N))')
						post go (`l') (`i') ("") ("") ("`=upper("`d'")'") `plist'

						* if the user has asked for a stratified analysis, either by
						* urban/rural or some other stratifier, then calculate the 
						* coverage results for each sub-stratum within the third
						* level strata
								

						if "$VCQI_LEVEL4_STRATIFIER" != "" {
						
							levelsof $VCQI_LEVEL4_STRATIFIER, local(llist4)
							
							foreach j in `llist4' {
							
								* pass along the name and id of the sub-stratum
								if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == ///
										"str" local l4name = "`j'"
								if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) != "str" ///
									local l4name = "`: label ($VCQI_LEVEL4_STRATIFIER) `j''"
								
								count if !missing(child_had_mov_`d') & level`l'id == `i' & ///
									$VCQI_LEVEL4_STRATIFIER == `j'	
								local plist (`=scalar(r(N))')
								count if child_had_mov_`d' == 1 & level`l'id == `i' & ///
									$VCQI_LEVEL4_STRATIFIER == `j'	
								local plist `plist' (`=scalar(r(N))')
								count if child_had_uncor_mov_`d' == 1 & level`l'id == `i' & ///
									$VCQI_LEVEL4_STRATIFIER == `j'	
								local plist `plist' (`=scalar(r(N))')
								count if child_had_cor_mov_`d' == 1 & level`l'id == `i' & ///
									$VCQI_LEVEL4_STRATIFIER == `j'	
								local plist `plist' (`=scalar(r(N))')
								post go (`l') (`i') ("`j'") ("`l4name'") ///
									("`=upper("`d'")'") `plist'
								
							}
						}	
						
						if "$VCQI_LEVEL4_SET_VARLIST" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
							
							forvalues j = 1/$LEVEL4_SET_NROWS {
							
								* pass along the name and id of the sub-stratum
								local l4name ${LEVEL4_SET_LABEL_`j'}
							
								if "${LEVEL4_SET_ROWTYPE_`j'}" == "DATA_ROW" {
								
									count if !missing(child_had_mov_`d') & ///
										level`l'id == `i' & ///
										${LEVEL4_SET_CONDITION_`j'}	
									
									local plist (`=scalar(r(N))')
									
									count if child_had_mov_`d' == 1 & ///
										level`l'id == `i' & ///
										${LEVEL4_SET_CONDITION_`j'}	
									
									local plist `plist' (`=scalar(r(N))')
									
									count if child_had_uncor_mov_`d' == 1 & ///
										level`l'id == `i' & ///
										${LEVEL4_SET_CONDITION_`j'}	
									
									local plist `plist' (`=scalar(r(N))')
									
									count if child_had_cor_mov_`d' == 1 & ///
										level`l'id == `i' & ///
										${LEVEL4_SET_CONDITION_`j'}	
									
									local plist `plist' (`=scalar(r(N))')
									
									post go (`l') (`i') ("`j'") ("`l4name'") ///
										("`=upper("`d'")'") `plist'
								}
								
								if "${LEVEL4_SET_ROWTYPE_`j'}" == "BLANK_ROW" {
									post go (`l') (`i') ("`j'") ("") ("") (.) (.) (.) (.) 
								}

								if "${LEVEL4_SET_ROWTYPE_`j'}" == "LABEL_ONLY" {
									post go (`l') (`i') ("`j'") ("`l4name'") ("") (.) (.) (.) (.) 
								}	
							}
						}						
					}
				}
			}
		
			capture postclose go
		}

		* Now put out the info across all doses
		
		noi di  _col(5) "Totals... "
		
		capture postclose go
		postfile go level id str30 level4id str30 level4name str30 dose ///
			n_eligible n_mov n_uncor_mov n_cor_mov using ///
			"${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}_anydose_database", replace
			
		global VCQI_DATABASES $VCQI_DATABASES `measureid'_${ANALYSIS_COUNTER}_anydose_database
							
		forvalues l = 1/3 {
			levelsof level`l'id, local(llist)
			if "${VCQI_SHOW`l'}" == "1" & "`llist'" != "" {
				foreach i in `llist' {
					count if !missing(child_had_mov) & level`l'id == `i'
					local plist (`=scalar(r(N))')
					count if child_had_mov == 1 & level`l'id == `i'
					local plist `plist' (`=scalar(r(N))')
					count if child_had_only_uncor_mov == 1 & level`l'id == `i'
					local plist `plist' (`=scalar(r(N))')
					count if child_had_only_cor_mov == 1 & level`l'id == `i'
					local plist `plist' (`=scalar(r(N))')
					post go (`l') (`i') ("") ("") ("ALLDOSES") `plist'

					* if the user has asked for a stratified analysis, either by
					* urban/rural or some other stratifier, then calculate the 
					* coverage results for each sub-stratum within the third
					* level strata
							
					if "$VCQI_LEVEL4_STRATIFIER" != "" {
					
						levelsof $VCQI_LEVEL4_STRATIFIER, local(llist4)
						
						foreach j in `llist4' {
						
							* pass along the name and id of the sub-stratum
							if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == ///
									"str" local l4name = "`j'"
							if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) != "str" ///
								local l4name = "`: label ($VCQI_LEVEL4_STRATIFIER) `j''"
							
							local plist
							count if !missing(child_had_mov) & level`l'id == `i' & ///
								$VCQI_LEVEL4_STRATIFIER == `j'	
							local plist `plist' (`=scalar(r(N))')
							count if child_had_mov == 1 & level`l'id == `i' & ///
								$VCQI_LEVEL4_STRATIFIER == `j'	
							local plist `plist' (`=scalar(r(N))')
							count if child_had_only_uncor_mov == 1 & level`l'id == `i' & ///
								$VCQI_LEVEL4_STRATIFIER == `j'	
							local plist `plist' (`=scalar(r(N))')
							count if child_had_only_cor_mov == 1 & level`l'id == `i' & ///
								$VCQI_LEVEL4_STRATIFIER == `j'	
							local plist `plist' (`=scalar(r(N))')
							post go (`l') (`i') ("`j'") ("`l4name'") ("ALLDOSES") `plist'
							
						}
					}
							
					if "$VCQI_LEVEL4_SET_VARLIST" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
						
						forvalues j = 1/$LEVEL4_SET_NROWS {
						
							* pass along the name and id of the sub-stratum
							local l4name ${LEVEL4_SET_LABEL_`j'}
						
							if "${LEVEL4_SET_ROWTYPE_`j'}" == "DATA_ROW" {
					
								local plist
								count if !missing(child_had_mov) & ///
									level`l'id == `i' & ///
									${LEVEL4_SET_CONDITION_`j'}		
								
								local plist `plist' (`=scalar(r(N))')
								
								count if child_had_mov == 1 & ///
									level`l'id == `i' & ///
									${LEVEL4_SET_CONDITION_`j'}		
								
								local plist `plist' (`=scalar(r(N))')
								
								count if child_had_only_uncor_mov == 1 & ///
									level`l'id == `i' & ///
									${LEVEL4_SET_CONDITION_`j'}		
								
								local plist `plist' (`=scalar(r(N))')
								
								count if child_had_only_cor_mov == 1 & ///
									level`l'id == `i' & ///
									${LEVEL4_SET_CONDITION_`j'}		
								
								local plist `plist' (`=scalar(r(N))')
								
								post go (`l') (`i') ("`j'") ("`l4name'") ("ALLDOSES") `plist'
							}

							if "${LEVEL4_SET_ROWTYPE_`j'}" == "BLANK_ROW" {
						
								post go (`l') (`i') ("`j'") ("") ("") (.) (.) (.) (.) 
							}

							if "${LEVEL4_SET_ROWTYPE_`j'}" == "LABEL_ONLY" {
						
								post go (`l') (`i') ("`j'") ("`l4name'") ("") (.) (.) (.) (.) 
							}	
						}
					}
				}
			}
		}

		capture postclose go
		
		* Now do a little work to put the ids and names of the various stratum 
		* levels into the databases
		*
		* The database will serve at least two purposes:
		*
		* 1. It can be exported to a flat file or excel file or database and
		*    may be used with mail-merge software to generate reporting forms
		*    in programs like Microsoft Word.  This provides future flexibility.
		*
		* 2. It will serve as the basis of the `measureid'_05TO program that
		*    exports requested records out to Microsoft Excel.

		foreach d in $RI_DOSE_LIST anydose {
			
			use "${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}_`d'_database", clear
			qui compress
				
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
			label variable name "Stratum name for table output"
			
			order name level1id level1name level2id level2name level3id level3name ///
				  level4id level4name, after(level)

			* if the user has NOT asked for results by sub-strata, drop the 
			* variable that lists sub-stratum names
			if "$VCQI_LEVEL4_STRATIFIER" == "" & "$VCQI_LEVEL4_SET_VARLIST" == "" drop level4name
			
			sort level id name
			
			destring _all, replace
			
			qui compress

			save, replace
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

