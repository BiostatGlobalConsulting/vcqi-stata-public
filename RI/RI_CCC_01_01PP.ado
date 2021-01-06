*! RI_CCC_01_01PP version 1.00 - Biostat Global Consulting - 2018-12-06
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-12-06	1.00	Mary Prier		Original version
*******************************************************************************

program define RI_CCC_01_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CCC_01_01PP
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
	}
	
	keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
	     HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
		 `dlist' no_card age_at_interview dob_for_valid_dose_calculations ///
		 urban_cluster level1name level2name level3name

	qui save "${VCQI_OUTPUT_FOLDER}/RI_CCC_01_${ANALYSIS_COUNTER}", replace

	vcqi_global RI_CCC_01_TEMP_DATASETS $RI_CCC_01_TEMP_DATASETS RI_CCC_01_${ANALYSIS_COUNTER}

	* Now, parse the globals: RI_CCC_01_COLOR, RI_CCC_01_PATTERN, RI_CCC_01_WIDTH
	* Loop over these globals...
	foreach i in RI_CCC_01_COLOR RI_CCC_01_PATTERN RI_CCC_01_WIDTH {
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
