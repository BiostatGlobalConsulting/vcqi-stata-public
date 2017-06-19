*! RI_CONT_01_03DV version 1.02 - Biostat Global Consulting - 2017-01-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added var label for dropout_`d1'_`d2' 
*										label variable dropout_`d1'_`d2' 
*										"Child received `d1' but not `d2'"
*
* 2017-01-13	1.02	Dale Rhoda		Only calculate the indicator if the
*										child was eligible for both doses
*******************************************************************************

program define RI_CONT_01_03DV

	local oldvcp $VCP
	global VCP RI_CONT_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_CONT_01_${ANALYSIS_COUNTER}", clear
		
		local j 1
		while `j' <= `=wordcount("$RI_CONT_01_DROPOUT_LIST")' {
			local d1 `=word(lower("$RI_CONT_01_DROPOUT_LIST"),`j')'
			local ++j
			local d2 `=word(lower("$RI_CONT_01_DROPOUT_LIST"),`j')'
			local ++j
		
			noi di _continue _col(5) "`d1' to `d2' "
			gen dropout_`d1'_`d2' = got_crude_`d2'_to_analyze==0 if ///
									got_crude_`d1'_to_analyze==1
			label variable dropout_`d1'_`d2' "Child received `d1' but not `d2'"
			
			* Do not count if the child was not eligible for dose 2
			replace dropout_`d1'_`d2' = . if missing(got_crude_`d2'_to_analyze)
		}
		noi di ""

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

