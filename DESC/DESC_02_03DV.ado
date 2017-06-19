*! DESC_02_03DV version 1.01 - Biostat Global Consulting - 2016-01-18
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-22	1.02	Dale Rhoda		Only tabulate missing if denom == "ALL"
*******************************************************************************

program DESC_02_03DV

	local oldvcp $VCP
	global VCP DESC_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		use "${VCQI_OUTPUT_FOLDER}/DESC_02_${ANALYSIS_COUNTER}_${DESC_02_COUNTER}", clear

		local vcounter 1
		
		* Only tabulate missing levels if denominator == "ALL"
		if upper("$DESC_02_DENOMINATOR")=="ALL" local missing missing
		
		foreach v in $DESC_02_VARIABLES {

			levelsof `v', local(llist) `missing'
					
			if substr("`:type `v''",1,3) == "str" {
				local quote """
				local vtype string
			}
			else {
				local quote
				local vtype number
			}
			
			local lcounter 1
			foreach l in `llist' {
				gen desc02_`vcounter'_`lcounter' = (`v' == `quote'`l'`quote')
				replace desc02_`vcounter'_`lcounter' = . if missing(`v') & upper("$DESC_02_DENOMINATOR")=="RESPONDED"
				if "`vtype'" == "string" {
					label variable desc02_`vcounter'_`lcounter' "`l'"
				}
				else if "`vtype'" == "number" {
					local lstring `l'
					if "`: value label `v''" != "" {
						local lstring = subinstr("`: label `: value label `v'' `l''","'","",.)
					}
					label variable desc02_`vcounter'_`lcounter' "`lstring'"
				}
				
				* If this level is a missing value then allow the user to specify the label via input global macros
				if "$DESC_02_N_MISSING_LEVELS" == "" vcqi_global DESC_02_N_MISSING_LEVELS -1
				forvalues i = 1/$DESC_02_N_MISSING_LEVELS {
					if "`l'" == "${DESC_02_MISSING_LEVEL_`i'}" label variable desc02_`vcounter'_`lcounter' "${DESC_02_MISSING_LABEL_`i'}"
				}
				
				if `lcounter' == 1 order desc02_`vcounter'_`lcounter', after(`v')
				if `lcounter'  > 1 order desc02_`vcounter'_`lcounter', after(desc02_`vcounter'_`=`lcounter'-1')
				local ++lcounter
			}
			
			vcqi_global DESC_02_LVL_COUNT_`vcounter' `=`lcounter'-1'
					
			if "$DESC_02_N_SUBTOTALS" == "" vcqi_global DESC_02_N_SUBTOTALS -1
			forvalues i = 1/$DESC_02_N_SUBTOTALS {
				gen desc02_`vcounter'_st`i' = 0 
				get_token_count ${DESC_02_SUBTOTAL_LEVELS_`i'}
				local tc = r(N)
				tokenize ${DESC_02_SUBTOTAL_LEVELS_`i'}
				forvalues j = 1/`tc' {
					local l ``j''
					replace desc02_`vcounter'_st`i' = 1 if `v' == `quote'`l'`quote'
				}
				replace desc02_`vcounter'_st`i' = . if missing(`v') & upper("$DESC_02_DENOMINATOR")=="RESPONDED"
				label variable desc02_`vcounter'_st`i' "${DESC_02_SUBTOTAL_LABEL_`i'}"
				if `i' == 1 order desc02_`vcounter'_st`i', after(desc02_`vcounter'_`=`lcounter'-1')
				if `i'  > 1 order desc02_`vcounter'_st`i', after(desc02_`vcounter'_st`=`i'-1')
			}
			
			vcqi_global DESC_02_ST_COUNT_`vcounter' $DESC_02_N_SUBTOTALS
			
			local ++vcounter
		}
			 
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

