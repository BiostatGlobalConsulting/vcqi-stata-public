*! RI_CONT_01_06PO version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-09-08	1.02	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_CONT_01_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CONT_01_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
		
		if "$VCQI_MAKE_UW_PLOTS" == "1" {
		
			capture mkdir Plots_IW_UW
		
			local j 1
			while `j' <= `=wordcount("$RI_CONT_01_DROPOUT_LIST")' {
				local d1 `=word(lower("$RI_CONT_01_DROPOUT_LIST"),`j')'
				local ++j
				local d2 `=word(lower("$RI_CONT_01_DROPOUT_LIST"),`j')'
				local ++j
				noi di _continue _col(5) "`d1' to `d2' "
				
				graph drop _all

				vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_CONT_01_${ANALYSIS_COUNTER}_`d1'_`d2'_database) ///
					filetag(RI_CONT_01_`d1'_`d2') ///
					title(RI - Dropout `=upper("`d1'")' to `=upper("`d2'")') ///
					name(RI_CONT_01_${ANALYSIS_COUNTER}_uwplot_`d1'_`d2')
					
				vcqi_log_comment $VCP 3 Comment "Dropout plot (`=upper("`d1'")' to `=upper("`d2'")') was created and exported."

			}
			noi di ""
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
