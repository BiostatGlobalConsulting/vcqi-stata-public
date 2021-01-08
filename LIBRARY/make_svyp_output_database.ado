*! make_svyp_output_database version 1.18 - Biostat Global Consulting - 2020-12-14
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
* 2018-01-16	1.08	MK Trimner		Added $VCQI_SVYSET_SYNTAX
* 2018-07-05	1.09	Dale Rhoda		Added adjust to all svypd calls
* 2018-10-10	1.10	Dale Rhoda		Require some respondents to have 0 or 1
*										before calling svypd
* 2019-01-01	1.11	Dale Rhoda		Allow strings in db to be up to 255 chars
*                                       and added nwtd_est
* 2019-01-28	1.12	Dale Rhoda		Drop the old icc calculation as it did
*										not account for variability in weights;
*										base the icc estimation on output from
*										the loneway command.
* 2020-05-11	1.13	Dale Rhoda		Restring level4name before finishing
*                                       if it is empty
* 2020-12-01	1.14	Dale Rhoda		Use calcicc instead of loneway; we 
*                                       want to report negative values of ICC
*                                       if that's what we observe
* 2020-12-09	1.15	Dale Rhoda		Tostring the level1-4 names at the end
* 2020-12-11	1.16	Dale Rhoda		Add truncate to every svypd call
* 2020-12-12	1.17	Dale Rhoda		Allow user to SHOW_LEVEL_4_ALONE
* 2020-12-14	1.18	Dale Rhoda		Hard-code cilevel to be 95 for VCQI
* 										and add variable labels
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

		$VCQI_SVYSET_SYNTAX
				
		capture postclose go
		postfile go level id str255 level4id str255 level4name str255 outcome ///
					double estimate double stderr cilevel double cill ///
					double ciul double lcb double ucb double deff ///
					double icc n nwtd nclusters nwtd_est using ///
					"${VCQI_OUTPUT_FOLDER}/`measureid'_${ANALYSIS_COUNTER}_`vid'_database", replace
					
		global VCQI_DATABASES $VCQI_DATABASES `measureid'_${ANALYSIS_COUNTER}_`vid'_database

		local lastl 3
		if $VCQI_SHOW1 == 0 & $VCQI_SHOW2 == 0 & $VCQI_SHOW3 == 0 & $VCQI_SHOW4 == 1 local lastl 4		
		
		forvalues l = 1/`lastl' {
			
			* Take over l temporarily if l is 4 and set back to 1
			* to make the output come out right
			if `l' != 4 local l_was_4 0
			else {
				local l_was_4 1
				local l 1
			}
			
			quietly levelsof level`l'id, local(llist)
			if ("${VCQI_SHOW`l'}" == "1" & "`llist'" != "") | (`l_was_4') {
				foreach i in `llist' {
				
					* Only estimate the proportion if some of the respondents have non-missing 0s or 1s
					count if level`l'id == `i' & inlist(`variable',0,1)
					
					if r(N) > 0 {

						*quietly loneway `variable' clusterid if level`l'id == `i'
						*scalar icc = r(rho)
						quietly calcicc `variable' clusterid if level`l'id == `i'
						scalar icc = r(anova_icc)
						if icc == . {
							if r(sd_w) == 0 & r(sd_b)  > 0 scalar icc = 1
							if r(sd_w) == 0 & r(sd_b) == 0 scalar icc = 0
						}
						noi svypd `variable' if level`l'id == `i', method($VCQI_CI_METHOD) adjust truncate
						
						// Post if l was 1 or 2 or 3, but skip if l was 4
						if `l_was_4' == 0 ///
						post go (`l') (`i') ("") ("") ("`variable'") ///
								(r(svyp)) (r(stderr)) (95) (r(lb_alpha)) (r(ub_alpha)) ///
								(r(lb_2alpha)) (r(ub_2alpha)) (r(deff))  ///
								(icc) (r(N)) (r(Nwtd)) (r(clusters)) (`=r(Nwtd)*r(svyp)')

					}
								
					* if the user has asked for a stratified analysis, either by
					* urban/rural or some other stratifier, then calculate the 
					* coverage results for each sub-stratum within the current
					* level strata
							
					if "$VCQI_LEVEL4_STRATIFIER" != "" & ( "$SHOW_LEVEL_4_ALONE" == "1" | "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
					
						quietly levelsof $VCQI_LEVEL4_STRATIFIER, local(llist4)
						
						foreach j in `llist4' {
						
							count if level`l'id == `i' & $VCQI_LEVEL4_STRATIFIER == `j' & inlist(`variable',0,1)
							
							* only do the calculation and put out the results if there
							* are respondents in this sub-stratum
							if r(N) > 0 {
							
								*quietly loneway `variable' clusterid if level`l'id == `i' & $VCQI_LEVEL4_STRATIFIER == `j'
								*scalar icc = r(rho)
								quietly calcicc `variable' clusterid if level`l'id == `i' & $VCQI_LEVEL4_STRATIFIER == `j'
								scalar icc = r(anova_icc)
								if icc == . {
									if r(sd_w) == 0 & r(sd_b)  > 0 scalar icc = 1
									if r(sd_w) == 0 & r(sd_b) == 0 scalar icc = 0
								}

								noi svypd `variable' if level`l'id == `i' & ///
									$VCQI_LEVEL4_STRATIFIER == `j', method($VCQI_CI_METHOD)	adjust truncate	
								
								* pass along the name and id of the sub-stratum
								if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == ///
										"str" local l4name = "`j'"
								if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) != "str" ///
									local l4name = "`: label ($VCQI_LEVEL4_STRATIFIER) `j''"

								post go (`l') (`i') ("`j'") ("`l4name'") ///
									("`variable'") ///
									(r(svyp)) (r(stderr)) (95) (r(lb_alpha)) (r(ub_alpha)) ///
									(r(lb_2alpha)) (r(ub_2alpha)) (r(deff)) ///
									(icc) (r(N)) (r(Nwtd)) (r(clusters)) (`=r(Nwtd)*r(svyp)')
							}
						}
					}
					
					if "$VCQI_LEVEL4_SET_VARLIST" != "" & ( "$SHOW_LEVEL_4_ALONE" == "1" | "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
						
						forvalues j = 1/$LEVEL4_SET_NROWS {
						
							* pass along the name and id of the sub-stratum
							local l4name ${LEVEL4_SET_LABEL_`j'}
						
							if "${LEVEL4_SET_ROWTYPE_`j'}" == "DATA_ROW" {
						
								count if level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'} & inlist(`variable',0,1)
								
								* only do the calculation and put out the results if there
								* are respondents in this sub-stratum
								if r(N) > 0 {
								
									*quietly loneway `variable' clusterid if level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}										
									*scalar icc = r(rho)
									quietly calcicc `variable' clusterid if level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}										
									scalar icc = r(anova_icc)
									if icc == . {
										if r(sd_w) == 0 & r(sd_b)  > 0 scalar icc = 1
										if r(sd_w) == 0 & r(sd_b) == 0 scalar icc = 0
									}

									noi svypd `variable' if level`l'id == `i' & ///
										${LEVEL4_SET_CONDITION_`j'}, method($VCQI_CI_METHOD) adjust truncate

									if r(svyp) == 1 scalar icc = 0
									
									post go (`l') (`i') ("`j'") ("`l4name'") ///
										("`variable'") ///
										(r(svyp)) (r(stderr)) (95) (r(lb_alpha)) (r(ub_alpha)) ///
										(r(lb_2alpha)) (r(ub_2alpha)) (r(deff)) ///
										(icc) (r(N)) (r(Nwtd)) (r(clusters)) (`=r(Nwtd)*r(svyp)')
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
			
			* Now set l back to 4 if that's its value at the top of the 
			* loop so we exit the loop gracefully
			if `l_was_4' local l 4
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
		label variable icc  "Estimated with one-way ANOVA"
		label variable nwtd_est "(Weighted N) x (Point Estimate)"
		
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
		
		capture tostring level1name, replace
		capture tostring level2name, replace
		capture tostring level3name, replace
		capture tostring level4name, replace
		
		compress

		capture label variable level1name  "Level1 name"
		capture label variable level2id    "Level2 ID"
		capture label variable level2name  "Level2 stratum name"
		capture label variable level3id    "Level3 ID"
		capture label variable level3name  "Level3 stratum name"
				
		capture label variable level       "Stratum geographic level"
		capture label variable id          "Stratum ID (at its level)"
		capture label variable level4id    "Sub-stratum ID"
		capture label variable level4name  "Sub-stratum name"
		capture label variable outcome     "Outcome variable"
		capture label variable estimate    "Estimated proportion"
		capture label variable stderr      "Standard error"
		capture label variable cilevel     "Confidence level"
		capture label variable cill        "2-sided CI lower-bound"
		capture label variable ciul        "2-sided CI upper-bound"
		capture label variable lcb         "1-sided lower confidence bound"
		capture label variable ucb         "1-sided upper confidence bound"
		capture label variable deff        "Design effect"
		capture label variable icc         "Intracluster correlation coefficient"
		capture label variable n           "Sample size (unweighted)"
		capture label variable nwtd        "Sample size (weighted)"
		capture label variable nclusters   "Number of clusters"
		capture label variable nwtd_est    "Persons with outcome (weighted)"
		
		save, replace
	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
