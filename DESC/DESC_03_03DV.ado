*! DESC_03_03DV version 1.01 - Biostat Global Consulting - 2016-01-18
*
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
*******************************************************************************

program DESC_03_03DV


	local oldvcp $VCP
	global VCP DESC_03_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		use "${VCQI_OUTPUT_FOLDER}/DESC_03_${ANALYSIS_COUNTER}_${DESC_03_COUNTER}", clear

		local vcounter $DESC_03_COUNTER
		
		* Assume that all the variables are of the same type: string or numeric
		if substr("`:type `=word("$DESC_03_VARIABLES",1)''",1,3) == "str" {
			local quote """
			local vtype string
		}
		else {
			local quote
			local vtype number
		}
		
		* generate variables for each of the levels, using one variable per level
		* in the order the variables are listed in DESC_03_VARIABLES
		local lcounter 1
		foreach v of varlist $DESC_03_VARIABLES {
			gen desc03_`vcounter'_`lcounter' = (`v' == `quote'${DESC_03_SELECTED_VALUE}`quote')
			replace desc03_`vcounter'_`lcounter' = . if missing(`v') & upper("$DESC_03_DENOMINATOR")=="RESPONDED"

			label variable desc03_`vcounter'_`lcounter' "`: variable label `v''"

			* If this level is a missing value then allow the user to specify the label via input global macros
			* (Actually you could use this options to overwrite the label for any option...we just call it 'missing'
			*
			if "$DESC_03_N_MISSING_LEVELS" == "" vcqi_global DESC_03_N_MISSING_LEVELS -1
			forvalues i = 1/$DESC_03_N_MISSING_LEVELS {
				if "`v'" == "${DESC_03_MISSING_LEVEL_`i'}" label variable desc03_`vcounter'_`lcounter' "${DESC_03_MISSING_LABEL_`i'}"
			}		
			
			order desc03_`vcounter'_`lcounter', after(`v')
			local ++lcounter
		}
			
		vcqi_global DESC_03_LVL_COUNT_`vcounter' `=`lcounter'-1'
		
		* Now calculate the subtotal variables...setting the outcome to 1 if any
		* of the subtotal components is 1
		*
		* Subtotal 
		if "$DESC_03_N_SUBTOTALS" == "" vcqi_global DESC_03_N_SUBTOTALS -1
		forvalues i = 1/$DESC_03_N_SUBTOTALS {
			gen desc03_`vcounter'_st`i' = 0 
			gen desc03_missing_`vcounter'_st`i' = 1
			foreach v of varlist ${DESC_03_SUBTOTAL_LEVELS_`i'} {
				replace desc03_`vcounter'_st`i' = 1 if (`v' == `quote'${DESC_03_SELECTED_VALUE}`quote')
				replace desc03_missing_`vcounter'_st`i' = 0 if !missing(`v')
			}
			replace desc03_`vcounter'_st`i' = . if desc03_missing_`vcounter'_st`i' == 1 & upper("$DESC_03_DENOMINATOR")=="RESPONDED"
			drop desc03_missing_`vcounter'_st`i'
			label variable    desc03_`vcounter'_st`i' "${DESC_03_SUBTOTAL_LABEL_`i'}"
			if `i' == 1 order desc03_`vcounter'_st`i', after(desc03_`vcounter'_`=`lcounter'-1')
			if `i'  > 1 order desc03_`vcounter'_st`i', after(desc03_`vcounter'_st`=`i'-1')
		}
			
		vcqi_global DESC_03_ST_COUNT_`vcounter' $DESC_03_N_SUBTOTALS
			
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

