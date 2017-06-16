*! SIA_COVG_03_01PP version 1.04 - Biostat Global Consulting - 2017-06-08
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-02-04	1.02	Dale Rhoda		Minor edits
* 2017-02-13	1.03	Dale Rhoda		Fixed a typo
* 2017-06-08	1.04	Dale Rhoda		Added $VCQI_LEVEL4_SET_VARLIST 
*******************************************************************************

program define SIA_COVG_03_01PP

	local oldvcp $VCP
	global VCP SIA_COVG_03_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/SIA_with_ids", clear
			
		keep level1id level2id level3id stratumid clusterid respid SIA01 SIA03 ///
			 SIA11 SIA12 SIA20 SIA27 SIA28 SIA29 SIA30 SIA31 SIA32 SIA33 HH02  ///
			 HH04 psweight $VCQI_LEVEL4_STRATIFIER  $VCQI_LEVEL4_SET_VARLIST 
		
		* merge the child's age in completed years onto the SIA dataset
		
		gen HM01 = SIA01
		gen HM03 = SIA03
		gen HM09 = SIA11
		gen HM22 = SIA12
		
		merge 1:1 HM01 HM03 HM09 HM22 using "${VCQI_DATA_FOLDER}/${VCQI_HM_DATASET}", keepusing(HM29)
		keep if _merge == 3 | _merge == 1
		drop _merge HM01 HM03 HM09 HM22

		*Count the number of children that are older than the SIA_MAX_AGE
		count if HM29 > int(${SIA_MAX_AGE}/365.25)
		if r(N) > 0 vcqi_log_comment $VCP 4 Data "Based on the user specified min age in SIA_MIN_AGE and max age in SIA_MAX_AGE, we are only analyzing children within this age range. `=scalar(r(N))' children will be excluded because they are above the SIA_MAX_AGE of $SIA_MAX_AGE (days) provided."

		*Count the number of children that are younger than the SIA_MIN_AGE
		count if HM29 < int(${SIA_MIN_AGE}/365.25)
		if r(N) > 0 vcqi_log_comment $VCP 4 Data "Based on the user specified min age in SIA_MIN_AGE and max age in SIA_MAX_AGE, we are only analyzing children within this age range. `=scalar(r(N))' children will be excluded because they are below the SIA_MIN_AGE of $SIA_MIN_AGE (days) provided."
		
		*Only keep records that are within the user specified age range 
		drop if HM29 > int(${SIA_MAX_AGE}/365.25)
		drop if HM29 < int(${SIA_MIN_AGE}/365.25)
		
		save "${VCQI_OUTPUT_FOLDER}/SIA_COVG_03_${ANALYSIS_COUNTER}", replace

		vcqi_global SIA_COVG_03_TEMP_DATASETS $SIA_COVG_03_TEMP_DATASETS SIA_COVG_03_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
