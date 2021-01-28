*! RI_CCC_02_01PP version 1.02 - Biostat Global Consulting - 2021-01-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-12-06	1.00	Mary Prier		Original version
* 2020-04-11	1.01	Dale Rhoda		Also keep got_crude_*_to_analyze which
*                                       is used for the periscopes at far right
* 2021-01-16	1.02	Dale Rhoda		Check to be sure RI_COVG_01 has been run
*******************************************************************************

program define RI_CCC_02_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CCC_02_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"

	qui use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear

	*this program assumes dates and tick marks have been cleaned upstream
	
	* keep only the variables that pertain to evidence of vaccination
	* for those doses being analyzed
	
	local dlist	
	foreach d in `=lower("$RI_DOSE_LIST")' {
		*local dlist `dlist' `d'_card_date `d'_register_date `d'_card_tick `d'_register_tick `d'_history
		local dlist `dlist' `d'_card_date `d'_register_date
	
		*if "`d'" == "bcg" local dlist `dlist' bcg_scar_history
		
		local alist `alist' got_crude_`d'_to_analyze
	}
	
	keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
	     HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
		 `dlist' no_card age_at_interview dob_for_valid_dose_calculations ///
		 urban_cluster level1name level2name level3name

	check_RI_COVG_01_03DV	 
		 
	qui merge 1:1 respid using RI_COVG_01_${ANALYSIS_COUNTER}, keepusing(`alist')
	qui keep if _merge == 1 | _merge == 3
	drop _merge

	qui save "${VCQI_OUTPUT_FOLDER}/RI_CCC_02_${ANALYSIS_COUNTER}", replace
		
	vcqi_global RI_CCC_02_TEMP_DATASETS $RI_CCC_02_TEMP_DATASETS RI_CCC_02_${ANALYSIS_COUNTER}

	* Now, parse the globals: RI_CCC_02_COLOR, RI_CCC_02_PATTERN, RI_CCC_02_WIDTH
	* Loop over these globals...
	foreach i in RI_CCC_02_COLOR RI_CCC_02_PATTERN RI_CCC_02_WIDTH {
		* Find out how many elements are in the list
		local temp_size : list sizeof global(`i')
		forvalues j=1/`temp_size' {
			* Assign word j to globalj
			local temp_word `: word `j' of ${`i'}'
			vcqi_global `i'`j' `temp_word'
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
