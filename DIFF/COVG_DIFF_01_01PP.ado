*! COVG_DIFF_01_01PP version 1.03 - Biostat Global Consulting - 2016-08-25
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-02-14	1.02	Dale Rhoda		Make list of temp datasets
* 2016-08-25	1.03	Dale Rhoda		Moved PP steps from GC program to here
*******************************************************************************

program COVG_DIFF_01_01PP

	local oldvcp $VCP
	global VCP COVG_DIFF_01_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local exitflag 0
		
		* Check to see that dataset exists and variable exists in it
		
		capture confirm file "${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_01_INDICATOR}_${COVG_DIFF_01_ANALYSIS_COUNTER}.dta"
		if _rc != 0 {
			di as error "COVG_DIFF_01 is looking for {VCQI_OUTPUT_FOLDER}/{COVG_DIFF_01_INDICATOR}_{COVG_DIFF_01_ANALYSIS_COUNTER}.dta"
			di as error "It should be ${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_01_INDICATOR}_${COVG_DIFF_01_ANALYSIS_COUNTER}.dta"
			di as error "The file doesn't seem to exist."

			vcqi_log_comment $VCP 1 Error	 "COVG_DIFF_01 is looking for {VCQI_OUTPUT_FOLDER}/{COVG_DIFF_01_INDICATOR}_{COVG_DIFF_01_ANALYSIS_COUNTER}"
			vcqi_log_comment $VCP 1 Error	 "It should be ${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_01_INDICATOR}_${COVG_DIFF_01_ANALYSIS_COUNTER}"
			vcqi_log_comment $VCP 1 Error	 "The file doesn't seem to exist."

			local exitflag 1
		}	
		
		if `exitflag' != 1 {
		
			use "${VCQI_OUTPUT_FOLDER}/${COVG_DIFF_01_INDICATOR}_${COVG_DIFF_01_ANALYSIS_COUNTER}", clear
			
			capture confirm variable $COVG_DIFF_01_VARIABLE

			if _rc != 0 {
				di as error "The COVG_DIFF_01_VARIABLE doesn't seem to exist in the file defined by COVG_DIFF_01_INDICATOR and COVG_DIFF_01_ANALYSIS_COUNTER."
				vcqi_log_comment $VCP 1 Error	"The COVG_DIFF_01_VARIABLE doesn't seem to exist in the file defined by COVG_DIFF_01_INDICATOR and COVG_DIFF_01_ANALYSIS_COUNTER."

				local exitflag 1
			}
		}
		
		if `exitflag' != 1 {
		
			capture assert inlist($COVG_DIFF_01_VARIABLE,0,1,.)
			
			if _rc != 0 {
				di as error "The COVG_DIFF_01_VARIABLE takes unexpected values (other than 0, 1, and missing)."
				vcqi_log_comment $VCP 1 Error	 "The COVG_DIFF_01_VARIABLE takes unexpected values (other than 0, 1, and missing)."

				local exitflag 1
			}
		}
		
		if `exitflag' == 1 {
			vcqi_global VCQI_ERROR 1
			vcqi_halt_immediately
		}
		
		* Open the postfile if it isn't open already

		if "$COVG_DIFF_01_POSTOPEN" != "1" {

			capture postclose cdiff01

			postfile cdiff01 stratum_level str100 indicator str100 variable ///
							 analysis_counter ///
							 stratum_id1 str100 stratum_name1 n1 nwtd1 p1 lb951 ub951 ///
							 stratum_id2 str100 stratum_name2 n2 nwtd2 p2 lb952 ub952 ///			   
							 df difference difflb95 diffub95 pvalue ///
							 using "${VCQI_OUTPUT_FOLDER}/COVG_DIFF_01_${ANALYSIS_COUNTER}" ///
							 , replace
							 
			vcqi_global COVG_DIFF_01_TEMP_DATASETS $COVG_DIFF_01_TEMP_DATASETS COVG_DIFF_01_${ANALYSIS_COUNTER}
		
			vcqi_global COVG_DIFF_01_POSTOPEN 1
			
			vcqi_global COVG_DIFF_01_FILENAME ${VCQI_OUTPUT_FOLDER}/COVG_DIFF_01_${ANALYSIS_COUNTER}
			
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
