*! RI_CIC_02_01PP version 1.02 - Biostat Global Consulting - 2021-01-27
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-10	1.00	Mary Prier		Original version
* 2020-04-11	1.01	Dale Rhoda		Also keep got_crude_*_to_analyze which
*                                       is used for the periscopes at far right
* 2021-01-27	1.02	Dale Rhoda		Check to be sure RI_COVG_01 was run
*******************************************************************************

program define RI_CIC_02_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CIC_02_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"

	qui use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear

	* This program assumes dates and tick marks have been cleaned upstream
	
	* This chunk of code was copied from RI_dose_intervals.ado
	local dlist	
	foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' `=lower("$RI_MULTI_3_DOSE_LIST")' {
		local dlist `dlist' `d'1_card_date `d'1_register_date `d'2_card_date `d'2_register_date	
		local alist `alist' got_crude_`d'2_to_analyze		
	}
	foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
		local dlist `dlist' `d'3_card_date `d'3_register_date	
		local alist `alist' got_crude_`d'3_to_analyze		
	}
	
	*Only keep variables necessary to calculate dose intervals
	keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
		 $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST `dlist' no_card psweight  ///
		 HH02 HH04 urban_cluster dob_for_valid_dose_calculations ///
		 level1name level2name level3name

 	check_RI_COVG_01_03DV	 

	qui merge 1:1 respid using RI_COVG_01_${ANALYSIS_COUNTER}, keepusing(`alist')
	qui keep if _merge == 1 | _merge == 3
	drop _merge
	
	qui save "${VCQI_OUTPUT_FOLDER}/RI_CIC_02_${ANALYSIS_COUNTER}", replace

	vcqi_global RI_CIC_02_TEMP_DATASETS $RI_CIC_02_TEMP_DATASETS RI_CIC_02_${ANALYSIS_COUNTER}

	* Now, parse the globals: RI_CIC_02_COLOR, RI_CIC_02_PATTERN, RI_CIC_02_WIDTH, RI_CIC_02_VLINE_COLOR, RI_CIC_02_VLINE_PATTERN, RI_CIC_02_VLINE_WIDTH    
	* Loop over these globals...
	foreach i in RI_CIC_02_COLOR RI_CIC_02_PATTERN RI_CIC_02_WIDTH RI_CIC_02_VLINE_COLOR RI_CIC_02_VLINE_PATTERN RI_CIC_02_VLINE_WIDTH {
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
