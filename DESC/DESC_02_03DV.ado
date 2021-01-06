*! DESC_02_03DV version 1.06 - Biostat Global Consulting - 2018-06-19
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-22	1.02	Dale Rhoda		Only tabulate missing if denom == "ALL"
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2018-01-02	1.04	MK Trimner/Dale	Added global "${DESC02_VALUE_LEVEL_`i'}" 
*										to be passed thru for BEFORE/AFTER
*                                       purposes
* 2018-01-03	1.05	Dale Rhoda		Updated code so the output includes one
*                                       column for every value observed in the
*                                       dataset OR observed in the value label.
*                                       In other words, every value from the 
*                                       value label is listed in the table,
*                                       even if it does not appear in the data
*
* 2018-06-19	1.06	MK Trimner		Adjusted code after fetch labels to put
*										label values obtained from that program
*										before the value labels used in the dataset
*										Removed the sort code and replaced with 
*										setting local llist to ullist
*******************************************************************************

program define DESC_02_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		use "${VCQI_OUTPUT_FOLDER}/DESC_02_${ANALYSIS_COUNTER}_${DESC_02_COUNTER}", clear

		local vcounter 1
		
		* Only tabulate missing levels if denominator == "ALL"
		if upper("$DESC_02_DENOMINATOR")=="ALL" local missing missing
		
		foreach v in $DESC_02_VARIABLES {

			* What are the observed values of `v'?
			levelsof `v', local(llist) `missing'

			* What values of `v' are listed in its value label (if applicable)?
			capture local labname : value label `v'
			if "`labname'" != "" {
				noi fetch_label_values `labname'
				local llist `r(vlist)' `llist'
				local ullist  : list uniq llist
				local llist `ullist'
			}
								
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
				
				global DESC02_VALUE_LEVEL_`lcounter' `quote'`l'`quote'
				
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
				
				* Allow the user to specify (or overwrite) the label via input global macros
				if "$DESC_02_N_RELABEL_LEVELS" == "" vcqi_global DESC_02_N_RELABEL_LEVELS -1
				forvalues i = 1/$DESC_02_N_RELABEL_LEVELS {
					if "`l'" == "${DESC_02_RELABEL_LEVEL_`i'}" label variable desc02_`vcounter'_`lcounter' "${DESC_02_RELABEL_LABEL_`i'}"
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

