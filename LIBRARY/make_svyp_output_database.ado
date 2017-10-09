*! make_svyp_output_database version 1.07 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added var name to new variable name: label variable name "Survey name for table output"
* 2016-02-12	1.02	Dale Rhoda		Added $VCQI_DATABASES
* 2016-02-24	1.03	Dale Rhoda		Cleaned up Starting line
* 2016-12-01	1.04	Dale Rhoda		Switch to svypd
* 2017-01-30	1.05	Dale Rhoda		Generate LEVEL4 output using
*										VCQI_LEVEL4_SET_VARLIST & 
*										VCQI_LEVEL4_SET_LAYOUT
* 2017-05-15	1.06	Dale Rhoda		Put stderr in the database
* 2017-08-26	1.07	Mary Prier		Added version 14.1 line
*******************************************************************************

program define make_svyp_output_database
	version 14.1
	
	syntax , VARiable(string) ESTLABel(string asis) VID(string) MEASureid(string)
	
	local oldvcp $VCP
	global VCP make_svyp_output_database
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {

		vcqi_log_comment $VCP 3 Comment "measureid: `measureid' variable: `variable' vid: `vid'  label: `estlabel' "

		use "${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}", clear

		svyset clusterid, weight(psweight) strata(stratumid)
				
		capture postclose go
		postfile go level id str30 level4id str30 level4name str30 outcome ///
					double estimate double stderr cilevel double cill ///
					double ciul double lcb double ucb double deff ///
					double icc n nwtd double icc2 nclusters using ///
					"${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}_`vid'_database", replace
					
		global VCQI_DATABASES $VCQI_DATABASES `measureid'_${ANALYSIS_COUNTER}_`vid'_database
							
		forvalues l = 1/3 {
			quietly levelsof level`l'id, local(llist)
			if "${VCQI_SHOW`l'}" == "1" & "`llist'" != "" {
				foreach i in `llist' {
					quietly loneway `variable' clusterid if level`l'id == `i'
					scalar icc2 = r(rho)
					noi svypd `variable' if level`l'id == `i', method($VCQI_CI_METHOD) 
					scalar icc = (r(deff) - 1) / ((r(N)/r(clusters)) - 1)
					post go (`l') (`i') ("") ("") ("`variable'") ///
							(r(svyp)) (r(stderr)) (r(level)) (r(lb_alpha)) (r(ub_alpha)) ///
							(r(lb_2alpha)) (r(ub_2alpha)) (r(deff))  ///
							(icc) (r(N)) (r(Nwtd)) (icc2) (r(clusters))

					* if the user has asked for a stratified analysis, either by
					* urban/rural or some other stratifier, then calculate the 
					* coverage results for each sub-stratum within the third
					* level strata
							
					if "$VCQI_LEVEL4_STRATIFIER" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
					
						quietly levelsof $VCQI_LEVEL4_STRATIFIER, local(llist4)
						
						foreach j in `llist4' {
						
							count if level`l'id == `i' & $VCQI_LEVEL4_STRATIFIER == `j'
							
							* only do the calculation and put out the results if there
							* are respondents in this sub-stratum
							if r(N) > 0 {
							
								quietly loneway `variable' clusterid if level`l'id == `i' & ///
									$VCQI_LEVEL4_STRATIFIER == `j'
								scalar icc2 = r(rho)

								noi svypd `variable' if level`l'id == `i' & ///
									$VCQI_LEVEL4_STRATIFIER == `j', method($VCQI_CI_METHOD)		
								
								scalar icc =(r(deff) - 1) / ((r(N)/r(clusters)) - 1)
								* pass along the name and id of the sub-stratum
								if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == ///
										"str" local l4name = "`j'"
								if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) != "str" ///
									local l4name = "`: label ($VCQI_LEVEL4_STRATIFIER) `j''"

								post go (`l') (`i') ("`j'") ("`l4name'") ///
									("`variable'") ///
									(r(svyp)) (r(stderr)) (r(level)) (r(lb_alpha)) (r(ub_alpha)) ///
									(r(lb_2alpha)) (r(ub_2alpha)) (r(deff)) ///
									(icc) (r(N)) (r(Nwtd)) (icc2) (r(clusters))
							}
						}
					}
					
					if "$VCQI_LEVEL4_SET_VARLIST" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
						
						forvalues j = 1/$LEVEL4_SET_NROWS {
						
							* pass along the name and id of the sub-stratum
							local l4name ${LEVEL4_SET_LABEL_`j'}
						
							if "${LEVEL4_SET_ROWTYPE_`j'}" == "DATA_ROW" {
						
								count if level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
								
								* only do the calculation and put out the results if there
								* are respondents in this sub-stratum
								if r(N) > 0 {
								
									quietly loneway `variable' clusterid if ///
										level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
										
									scalar icc2 = r(rho)

									noi svypd `variable' if level`l'id == `i' & ///
										${LEVEL4_SET_CONDITION_`j'}, method($VCQI_CI_METHOD)		
									
									scalar icc =(r(deff) - 1) / ((r(N)/r(clusters)) - 1)

									post go (`l') (`i') ("`j'") ("`l4name'") ///
										("`variable'") ///
										(r(svyp)) (r(stderr)) (r(level)) (r(lb_alpha)) (r(ub_alpha)) ///
										(r(lb_2alpha)) (r(ub_2alpha)) (r(deff)) ///
										(icc) (r(N)) (r(Nwtd)) (icc2) (r(clusters))
								}
							}
							
							if "${LEVEL4_SET_ROWTYPE_`j'}" == "BLANK_ROW" {
						
								post go (`l') (`i') ("`j'") ("BLANK_ROW") ///
									("`variable'") ///
									(.) (.) (.) (.) (.) ///
									(.) (.) (.) ///
									(.) (.) (.) (.) (.)
							}

							if "${LEVEL4_SET_ROWTYPE_`j'}" == "LABEL_ONLY" {
						
								post go (`l') (`i') ("`j'") ("`l4name'") ///
									("`variable'") ///
									(.) (.) (.) (.) (.) ///
									(.) (.) (.) ///
									(.) (.) (.) (.) (.)
							}	
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
		
		label variable estimate `"`estlabel'"'
		label variable icc  "Estimated from DEFF and m"
		label variable icc2 "Estimated with loneway command"
		
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
		**replace name = name + " - " + level4name if "$VCQI_LEVEL4_SET_VARLIST" != "" & !missing(level4name)
		replace name =                level4name if !missing(level4name)
		replace name = "" if level4name == "BLANK_ROW"
		
		label variable name "Survey name for table output"
		
		order name level1id level1name level2id level2name level3id level3name ///
			  level4id level4name, after(level)

		* if the user has NOT asked for results by sub-strata, drop the 
		* variable that lists sub-stratum names
		if "$VCQI_LEVEL4_STRATIFIER" == "" & "$VCQI_LEVEL4_SET_VARLIST" == "" drop level4name
		
		sort level id name
		
		destring _all, replace
		
		compress

		save, replace
	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
