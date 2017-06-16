*! DESC_01_04GO version 1.02 - Biostat Global Consulting 2017-01-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added var name to new variable name: 
*										label variable name "Survey name for table output"
* 2017-01-31	1.02	Dale Rhoda		Incorporate VCQI_LEVEL4_SET
*******************************************************************************
*
program define DESC_01_04GO

	local oldvcp $VCP
	global VCP DESC_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		****************************************************
		* First concentrate on the left-hand portion of the table
		* concerning the households (HH) visited 
		
		use "$VCQI_OUTPUT_FOLDER/DESC_01_CM_DATASET", clear

		merge 1:m HH01 HH03 using "$VCQI_OUTPUT_FOLDER/DESC_01_HH_DATASET"
		drop _merge

		gen level3id = HH01
		gen level1id = 1

		sort HH01 HH03
		egen clusterid = group(HH01 HH03)

		bysort clusterid: gen firstrow = (_n == 1)

		capture postclose d01hh
		postfile d01hh level id str30 level4id str30 level4name expected_n visited_n ///
					 info_from_occupant_n info_from_occupant_pct ///
					 eligible_occupant_n eligible_occupant_pct ///
					 info_from_neighbor_n info_from_neighbor_pct ///
					 eligible_neighbor_n eligible_neighbor_pct ///
					 no_info_n no_info_pct using ///
					 "$VCQI_OUTPUT_FOLDER/DESC_01_HH_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", replace

		global VCQI_DATABASES $VCQI_DATABASES DESC_01_HH_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database

		gen hh_has_eligibles = ${DESC_01_DATASET}_eligible_in_hh > 0 & !missing(${DESC_01_DATASET}_eligible_in_hh)		 

		forvalues l = 1/3 {
			
			levelsof level`l'id, local(llist)
			
			foreach i in `llist' {
			
				local pl (`l') (`i') ("") ("")
				* expected # of hh in all clusters in this stratum
				sum expected_hh_to_visit if firstrow == 1 & level`l'id == `i', detail
				local pl `pl' (`=scalar(r(sum))')
				
				* hh listed in this stratum
				count if !missing(HH14) & level`l'id == `i'			
				local bign = r(N)
				local pl `pl' (`bign')
				
				* hh with info from resident or occupant
				count if HH18 == 1 & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bign'')

				* HH has eligibles according to occupant
				count if hh_has_eligibles == 1 & HH18 == 1 & level`l'id == `i'
				local total = r(N)
				local pl `pl' (`total') (`=`total'/`smalln'')
				
				* hh with info from neighbor
				count if HH18 == 2 & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bign'')

				* HH has eligibles according to neighbor
				count if hh_has_eligibles == 1 & HH18 == 2 & level`l'id == `i'
				local total = r(N)
				local pl `pl' (`total') (`=`total'/`smalln'')

				* HH has no info regarding eligibility from occupant or neighbor
				count if !missing(HH14) & !inlist(HH18,1,2) & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bign'')
				
				post d01hh `pl' 
				
				if "$VCQI_LEVEL4_STRATIFIER" != "" {
				
					if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == "str" {
						local quote """
					}
					else local quote
				
					levelsof $VCQI_LEVEL4_STRATIFIER, local(llist4)
					
					foreach j in `llist4' {

						* pass along the name and id of the sub-stratum
						if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == ///
								"str" local l4name = "`j'"
						if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) != "str" ///
							local l4name = "`: label ($VCQI_LEVEL4_STRATIFIER) `j''"
				
						local pl (`l') (`i') ("`j'") ("`l4name'")
						* expected # of hh in all clusters in this stratum
						sum expected_hh_to_visit if firstrow == 1 & ///
							level`l'id == `i' ///
							& $VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote', detail
						
						local pl `pl' (`=scalar(r(sum))')
						
						* hh listed in this stratum
						count if !missing(HH14) & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'				
						local bign = r(N)
						local pl `pl' (`bign')
						
						* hh with info from resident or occupant
						count if HH18 == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'			
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bign'')
						
						* HH has eligibles according to occupant
						count if hh_has_eligibles == 1 & HH18 == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'				
						local total = r(N)
						local pl `pl' (`total') (`=`total'/`smalln'')
						
						* hh with info from neighbor
						count if HH18 == 2 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'				
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bign'')

						* HH has eligibles according to neighbor
						count if hh_has_eligibles == 1 & HH18 == 2 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'									
						local total = r(N)
						local pl `pl' (`total') (`=`total'/`smalln'')

						* HH has no info regarding eligibility from occupant or neighbor
						count if !missing(HH14) & !inlist(HH18,1,2) & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'				
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bign'')
						
						post d01hh `pl' 
					}
				}		
				
				
				if "$VCQI_LEVEL4_SET_VARLIST" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
						
					forvalues j = 1/$LEVEL4_SET_NROWS {
						
						* pass along the name and id of the sub-stratum
						local l4name ${LEVEL4_SET_LABEL_`j'}

						if "${LEVEL4_SET_ROWTYPE_`j'}" == "DATA_ROW" {

							local pl (`l') (`i') ("`j'") ("`l4name'")
							* expected # of hh in all clusters in this stratum
							sum expected_hh_to_visit if firstrow == 1 & ///
								level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}, detail
							
							local pl `pl' (`=scalar(r(sum))')
							
							* hh listed in this stratum
							count if !missing(HH14) & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}				
							local bign = r(N)
							local pl `pl' (`bign')
							
							* hh with info from resident or occupant
							count if HH18 == 1 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}			
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bign'')
							
							* HH has eligibles according to occupant
							count if hh_has_eligibles == 1 & HH18 == 1 &  ///
								level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}				
							local total = r(N)
							local pl `pl' (`total') (`=`total'/`smalln'')
							
							* hh with info from neighbor
							count if HH18 == 2 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}				
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bign'')

							* HH has eligibles according to neighbor
							count if hh_has_eligibles == 1 & HH18 == 2 & ///
								level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}									
							local total = r(N)
							local pl `pl' (`total') (`=`total'/`smalln'')

							* HH has no info regarding eligibility from occupant or neighbor
							count if !missing(HH14) & !inlist(HH18,1,2) & ///
								level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}				
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bign'')
							
							post d01hh `pl' 
						}

						if "${LEVEL4_SET_ROWTYPE_`j'}" == "BLANK_ROW" {
							post d01hh (`l') (`i') ("`j'") ("") ///
								(.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) 
						}

						if "${LEVEL4_SET_ROWTYPE_`j'}" == "LABEL_ONLY" {
							post d01hh (`l') (`i') ("`j'") ("`l4name'") ///
								(.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) 
						}	
					}
				}		
			}
		}

		capture postclose d01hh

		use "$VCQI_OUTPUT_FOLDER/DESC_01_HH_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", clear

		qui compress
		destring _all, replace
		capture tostring level4name, replace

		save, replace
		
		************************************************************************
		* Now write out the right-hand portion of the database concerning
		* what happened with the eligible (EL) respondents
		
		use "$VCQI_OUTPUT_FOLDER/DESC_01_CM_DATASET", clear
		gen HM01 = HH01
		gen HM03 = HH03

		merge 1:m HM01 HM03 using "$VCQI_OUTPUT_FOLDER/DESC_01_HM_DATASET", nogen

		merge 1:1 HM01 HM03 HM09 HM22 using "$VCQI_OUTPUT_FOLDER/DESC_01_${DESC_01_DATASET}_got_register", nogen

		gen level3id = HM01
		gen level1id = 1

		keep if eligible == 1

		gen unavailable = survey_disp == 2
		gen refused     = survey_disp == 3
		gen completed   = survey_disp == 4

		* If there is no disposition code, make it incomplete
		replace unavailable = 1 if eligible == 1 & missing(survey_disp)

		capture postclose d01el
		postfile d01el 	level id str30 level4id str30 level4name ///
						eligible_n selected_n completed_n completed_pct  ///
						male_n male_pct female_n female_pct ///
						register_n register_pct ///
						unavailable_n unavailable_pct refused_n refused_pct ///
						other_n other_pct ///
						using ///
			"$VCQI_OUTPUT_FOLDER/DESC_01_EL_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", replace

		global VCQI_DATABASES $VCQI_DATABASES DESC_01_EL_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database

		forvalues l = 1/3 {
			
			levelsof level`l'id, local(llist)
			
			foreach i in `llist' {
			
				local pl (`l') (`i') ("") ("")

				* Eligible
				count if eligible == 1 & level`l'id == `i'
				local pl `pl' (`=scalar(r(N))')
				
				* Selected
				count if selected == 1 & level`l'id == `i'
				local bign = r(N)
				local pl `pl' (`bign')

				* Completed
				count if completed == 1 & level`l'id == `i'
				local bignc = r(N)
				local pl `pl' (`bignc') (`=`bignc'/`bign'')
				
				* Male completed
				count if completed == 1 & male == 1 & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bignc'')

				* Female completed
				count if completed == 1 & male == 0 & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bignc'')		

				* Register completed
				count if got_register == 1 & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bignc'')		

				* Unavailable caretaker
				count if unavailable == 1 & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bign'')
				
				* Refused
				count if refused == 1 & level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bign'')
				
				* Other
				count if eligible == 1 & (complete + unavailable + refused) == 0 & ///
					level`l'id == `i'
				local smalln = r(N)
				local pl `pl' (`smalln') (`=`smalln'/`bign'')
				
				post d01el `pl' 
				
				if "$VCQI_LEVEL4_STRATIFIER" != "" {
				
					if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == "str" {
						local quote """
					}
					else local quote
				
					levelsof $VCQI_LEVEL4_STRATIFIER, local(llist4)
					
					foreach j in `llist4' {

						* pass along the name and id of the sub-stratum
						if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) == ///
								"str" local l4name = "`j'"
						if substr("`: type $VCQI_LEVEL4_STRATIFIER'",1,3) != "str" ///
							local l4name = "`: label ($VCQI_LEVEL4_STRATIFIER) `j''"
				
						local pl (`l') (`i') ("`j'") ("`l4name'")

						* Eligible
						count if eligible == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local pl `pl' (`=scalar(r(N))')
						
						* Selected
						count if selected == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local bign = r(N)
						local pl `pl' (`bign')

						* Completed
						count if completed == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local bignc = r(N)
						local pl `pl' (`bignc') (`=`bignc'/`bign'')
						
						* Male completed
						count if completed == 1 & male == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bignc'')

						* Female completed
						count if completed == 1 & male == 0 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bignc'')		

						* Register completed
						count if got_register == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bignc'')		

						* Unavailable caretaker
						count if unavailable == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bign'')
						
						* Refused
						count if refused == 1 & level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bign'')
						
						* Other
						count if eligible == 1 & (complete + unavailable + refused) == 0 & ///
							level`l'id == `i' & ///
							$VCQI_LEVEL4_STRATIFIER == `quote'`j'`quote'
						local smalln = r(N)
						local pl `pl' (`smalln') (`=`smalln'/`bign'')
						
						post d01el `pl' 
					}
				}		
				
				if "$VCQI_LEVEL4_SET_VARLIST" != "" & ( "${SHOW_LEVELS_`l'_4_TOGETHER}" == "1"  | ( inlist(`l',2,3) & "$SHOW_LEVELS_2_3_4_TOGETHER" == "1"  )) {
						
					forvalues j = 1/$LEVEL4_SET_NROWS {
						
						* pass along the name and id of the sub-stratum
						local l4name ${LEVEL4_SET_LABEL_`j'}
					
						if "${LEVEL4_SET_ROWTYPE_`j'}" == "DATA_ROW" {

							local pl (`l') (`i') ("`j'") ("`l4name'")

							* Eligible
							count if eligible == 1 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local pl `pl' (`=scalar(r(N))')
							
							* Selected
							count if selected == 1 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local bign = r(N)
							local pl `pl' (`bign')

							* Completed
							count if completed == 1 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local bignc = r(N)
							local pl `pl' (`bignc') (`=`bignc'/`bign'')
							
							* Male completed
							count if completed == 1 & male == 1 & ///
								level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bignc'')

							* Female completed
							count if completed == 1 & male == 0 & ///
								level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bignc'')		

							* Register completed
							count if got_register == 1 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bignc'')		

							* Unavailable caretaker
							count if unavailable == 1 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bign'')
							
							* Refused
							count if refused == 1 & level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bign'')
							
							* Other
							count if eligible == 1 & ///
								(complete + unavailable + refused) == 0 & ///
								level`l'id == `i' & ${LEVEL4_SET_CONDITION_`j'}
							local smalln = r(N)
							local pl `pl' (`smalln') (`=`smalln'/`bign'')
							
							post d01el `pl' 
						}
					}	

					if "${LEVEL4_SET_ROWTYPE_`j'}" == "BLANK_ROW" {
						post d01el (`l') (`i') ("`j'") ("") ///
							(.) (.) (.) (.) (.) (.) (.) (.) ///
							(.) (.) (.) (.) (.) (.) (.) (.) 
					}

					if "${LEVEL4_SET_ROWTYPE_`j'}" == "LABEL_ONLY" {
						post d01el (`l') (`i') ("`j'") ("`l4name'") ///
							(.) (.) (.) (.) (.) (.) (.) (.) ///
							(.) (.) (.) (.) (.) (.) (.) (.) 
					}	
				}
			}
		}

		capture postclose d01el

		use "$VCQI_OUTPUT_FOLDER/DESC_01_EL_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", clear

		qui compress
		destring _all, replace
		capture tostring level4name, replace
		save, replace

		************************************
		* Merge the two halves of the tables and load in the stratum names

		use "$VCQI_OUTPUT_FOLDER/DESC_01_HH_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", clear

		merge 1:1 level id level4id using "$VCQI_OUTPUT_FOLDER/DESC_01_EL_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", nogen

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

		save "$VCQI_OUTPUT_FOLDER/DESC_01_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", replace

		global VCQI_DATABASES $VCQI_DATABASES DESC_01_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
