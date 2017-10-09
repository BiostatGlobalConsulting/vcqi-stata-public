*! COVG_DIFF_02_01PP version 1.06 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-02-14	1.02	Dale Rhoda		Make list of temp datasets
* 2016-08-25	1.03	Dale Rhoda		Moved PP steps from GC program to here
* 2016-09-21	1.04	Dale Rhoda		Clear exitflag at top
* 2017-02-09	1.05	Dale Rhoda		Obtain value label from variable name 
*										directly
* 2017-08-26	1.06	Mary Prier		Added version 14.1 line
*******************************************************************************

program define COVG_DIFF_02_01PP
	version 14.1

	local oldvcp $VCP
	global VCP COVG_DIFF_02_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local exitflag 0
		
		* Check to see that dataset exists and variable exists in it
		local nofileflag 0
		
		capture confirm file "${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}.dta"
		if _rc != 0 {
			di as error "COVG_DIFF_02 is looking for {VCQI_OUTPUT_FOLDER}/{COVG_DIFF_02_INDICATOR}_{COVG_DIFF_02_ANALYSIS_COUNTER}.dta"
			di as error "It should be ${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}.dta"
			di as error "The file doesn't seem to exist."

			vcqi_log_comment $VCP 1 Error	 "COVG_DIFF_02 is looking for {VCQI_OUTPUT_FOLDER}/{COVG_DIFF_02_INDICATOR}_{COVG_DIFF_02_ANALYSIS_COUNTER}"
			vcqi_log_comment $VCP 1 Error	 "It should be ${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}"
			vcqi_log_comment $VCP 1 Error	 "The file doesn't seem to exist."
			
			local nofileflag 1
			local exitflag 1
		}	
		
		local novarflag 0
		if `nofileflag' != 1 {
		
			use "${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}", clear
			
			capture confirm variable $COVG_DIFF_02_VARIABLE

			if _rc != 0 {
				di as error "The COVG_DIFF_02_VARIABLE doesn't seem to exist in the file defined by COVG_DIFF_02_INDICATOR and COVG_DIFF_02_ANALYSIS_COUNTER."
				vcqi_log_comment $VCP 1 Error	"The COVG_DIFF_02_VARIABLE doesn't seem to exist in the file defined by COVG_DIFF_02_INDICATOR and COVG_DIFF_02_ANALYSIS_COUNTER."
				
				local novarflag 1
				local exitflag 1
			}
		}
		
		if `nofileflag' != 1 & `novarflag' != 1 {
		
			capture assert inlist($COVG_DIFF_02_VARIABLE,0,1,.)
			
			if _rc != 0 {
				di as error "The COVG_DIFF_02_VARIABLE takes unexpected values (other than 0, 1, and missing)."
				vcqi_log_comment $VCP 1 Error	 "The COVG_DIFF_02_VARIABLE takes unexpected values (other than 0, 1, and missing)."

				local exitflag 1
			}
		}
		
		if `exitflag' == 1 {
			vcqi_global VCQI_ERROR 1
			vcqi_halt_immediately
		}

		* make the analysis dataset
		use "${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}", clear
		save "${VCQI_OUTPUT_FOLDER}/COVG_DIFF_02_${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}", replace

		vcqi_global COVG_DIFF_02_TEMP_DATASETS $COVG_DIFF_02_TEMP_DATASETS COVG_DIFF_02_${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}
		
		
		* merge in the subpopulation variable, if necessary
		capture confirm variable $COVG_DIFF_02_SUBPOP_VARIABLE

		if _rc != 0 {
			merge 1:1 respid using `=word(subinstr("$COVG_DIFF_02_INDICATOR","_"," ",.),1)'_with_ids, keepusing($COVG_DIFF_02_SUBPOP_VARIABLE)
			keep if _merge == 1 | _merge == 3
			drop _merge
		}

			
		* merge in the subpopulation variable, if necessary
		capture confirm variable $COVG_DIFF_02_SUBPOP_VARIABLE
		if _rc != 0 {
			di as error "Not able to merge COVG_DIFF_02_SUBPOP_VARIABLE into output from COVG_DIFF_02_INDICATOR."
			vcqi_log_comment $VCP 1 Error "Not able to merge COVG_DIFF_02_SUBPOP_VARIABLE into output from COVG_DIFF_02_INDICATOR."
			vcqi_global VCQI_ERROR 1
		if "$VCQI_ERROR" == "1" vcqi_halt_immediately
		}
		
		* only keep observations that have the subpopulation(s) of interest
		keep if inlist($COVG_DIFF_02_SUBPOP_VARIABLE,$COVG_DIFF_02_SUBPOP_LEVEL1,$COVG_DIFF_02_SUBPOP_LEVEL2)
		save "${VCQI_OUTPUT_FOLDER}/COVG_DIFF_02_${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}", replace

		* Grab the label of the variable that defines the subpopulations, so we can put it in Excel
		vcqi_global COVG_DIFF_02_SUBPOP_LABEL `: variable label $COVG_DIFF_02_SUBPOP_VARIABLE'
		
		* Be sure there are some observations at level 1
		count if $COVG_DIFF_02_SUBPOP_VARIABLE == $COVG_DIFF_02_SUBPOP_LEVEL1
		
		if r(N) == 0 {
			di as error "The COVG_DIFF_02_SUBPOP_VARIABLE does not take on the requested COVG_DIFF_02_SUBPOP_LEVEL1 value, which is $COVG_DIFF_02_SUBPOP_LEVEL1."
			vcqi_log_comment $VCP 1 Error	 "The COVG_DIFF_02_SUBPOP_VARIABLE does not take on the requested COVG_DIFF_02_SUBPOP_LEVEL1 value, which is $COVG_DIFF_02_SUBPOP_LEVEL1."

			local exitflag 1
		}
		
		* Be sure level 1 is a non-negative integer
		if $COVG_DIFF_02_SUBPOP_LEVEL1 < 0 | ( $COVG_DIFF_02_SUBPOP_LEVEL1 != int($COVG_DIFF_02_SUBPOP_LEVEL1) ) {
			di as error "The COVG_DIFF_02_SUBPOP_LEVEL1 must be a non-negative integer; its current alue is $COVG_DIFF_02_SUBPOP_LEVEL1."
			vcqi_log_comment $VCP 1 Error	 "The COVG_DIFF_02_SUBPOP_LEVEL1 must be a non-negative integer; its current alue is $COVG_DIFF_02_SUBPOP_LEVEL1."

			local exitflag 1
		}
		
		* Be sure there are some observations at level 2
		count if $COVG_DIFF_02_SUBPOP_VARIABLE == $COVG_DIFF_02_SUBPOP_LEVEL2
		
		if r(N) == 0 {
			di as error "The COVG_DIFF_02_SUBPOP_VARIABLE does not take on the requested COVG_DIFF_02_SUBPOP_LEVEL2 value, which is $COVG_DIFF_02_SUBPOP_LEVEL2."
			vcqi_log_comment $VCP 1 Error	 "The COVG_DIFF_02_SUBPOP_VARIABLE does not take on the requested COVG_DIFF_02_SUBPOP_LEVEL2 value, which is $COVG_DIFF_02_SUBPOP_LEVEL2."

			local exitflag 1
		}

		* Be sure level 2 is a non-negative integer
		if $COVG_DIFF_02_SUBPOP_LEVEL2 < 0 | ( $COVG_DIFF_02_SUBPOP_LEVEL2 != int($COVG_DIFF_02_SUBPOP_LEVEL2) ) {
			di as error "The COVG_DIFF_02_SUBPOP_LEVEL2 must be a non-negative integer; its current alue is $COVG_DIFF_02_SUBPOP_LEVEL2."
			vcqi_log_comment $VCP 1 Error	 "The COVG_DIFF_02_SUBPOP_LEVEL2 must be a non-negative integer; its current alue is $COVG_DIFF_02_SUBPOP_LEVEL2."

			local exitflag 1
		}
		
		* Look up the name of subpop1 and subpop2 assuming they are stored in the value label for COVG_DIFF_02_SUBPOP_LEVEL1 and LEVEL2
		if `exitflag' == 0 {
			vcqi_global COVG_DIFF_02_SUBPOP_NAME1 `: label ($COVG_DIFF_02_SUBPOP_VARIABLE) $COVG_DIFF_02_SUBPOP_LEVEL1'
			vcqi_global COVG_DIFF_02_SUBPOP_NAME2 `: label ($COVG_DIFF_02_SUBPOP_VARIABLE) $COVG_DIFF_02_SUBPOP_LEVEL2'
		}
		
		if `exitflag' == 1 {
			vcqi_global VCQI_ERROR 1
			vcqi_halt_immediately
		}
		
		* Open the postfile if it isn't open already

		if "$COVG_DIFF_02_POSTOPEN" != "1" {

			capture postclose cdiff02

			postfile cdiff02 stratum_level str100 indicator str100 variable ///
							 analysis_counter stratum_id str100 stratum_name ///
							 str100 subpop_variable str100 subpop_label ///
							 subpop_level1 str100 subpop_name1 n1 nwtd1 p1 lb951 ub951 ///
							 subpop_level2 str100 subpop_name2 n2 nwtd2 p2 lb952 ub952 ///
							 df difference difflb95 diffub95 pvalue ///
							 using "${VCQI_OUTPUT_FOLDER}/COVG_DIFF_02_${ANALYSIS_COUNTER}" ///
							 , replace
		
			vcqi_global COVG_DIFF_02_TEMP_DATASETS $COVG_DIFF_02_TEMP_DATASETS COVG_DIFF_02_${ANALYSIS_COUNTER}
			
			vcqi_global COVG_DIFF_02_POSTOPEN 1
			
			vcqi_global COVG_DIFF_02_FILENAME ${VCQI_OUTPUT_FOLDER}/COVG_DIFF_02_${ANALYSIS_COUNTER}
			
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
