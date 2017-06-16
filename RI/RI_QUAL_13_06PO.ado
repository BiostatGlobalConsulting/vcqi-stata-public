*! RI_QUAL_13_06PO version 1.02 - Biostat Global Consulting - 2016-09-08
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-09-08	1.02	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2016-02-11	1.01	Dale Rhoda		
* 2016-09-08	1.02	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
*******************************************************************************

program define RI_QUAL_13_06PO

	version 14
	local oldvcp $VCP
	global VCP RI_QUAL_13_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		if "$VCQI_MAKE_UW_PLOTS" == "1" {
		
			noi di _col(5) "Unweighted proportion plot"
			
			capture mkdir Plots_IW_UW
		
			local d `=lower("$RI_QUAL_13_DOSE_NAME")'
			local t `=int($RI_QUAL_13_AGE_THRESHOLD)'

			vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_13_${ANALYSIS_COUNTER}_`d'_`t'_database) ///
				filetag(RI_QUAL_13_`d'_`t') ///
				title("RI - Proportion of `=upper("`d'")' Doses" "Rec'd Before `t' Days") ///
				name(RI_QUAL_13_${ANALYSIS_COUNTER}_uwplot_`d'_`t')
				
			vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot was created and exported."
			
			graph drop _all
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
