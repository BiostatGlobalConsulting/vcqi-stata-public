*! RI_QUAL_12_06PO version 1.05 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-09-08	1.02	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2016-11-23	1.03	Dale Rhoda		Add threshold to filetag and name
*										so the same dose pair can be plotted
* 										using different thresholds
* 2017-02-03	1.04	Dale Rhoda		Switched to _DOSE_PAIR_LIST
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_12_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_12_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		if "$VCQI_MAKE_UW_PLOTS" == "1" {
		
			noi di _col(5) "Unweighted proportion plots"
			
			capture mkdir Plots_IW_UW
				
			local j 1
			local i 1
			while `i' <= `=wordcount("$RI_QUAL_12_THRESHOLD_LIST")' {
				local t `=word("$RI_QUAL_12_THRESHOLD_LIST",`i')'
				local d1 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
				local ++j
				local d2 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
				local ++j
				noi di _continue _col(7) "`d1' & `d2' "

				graph drop _all
				vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_12_${ANALYSIS_COUNTER}_`d1'_`d2'_`t'_database) ///
					filetag(RI_QUAL_12_`d1'_`d2'_`t') ///
					title("RI - Intervals Between `=upper("`d1'")' & `=upper("`d2'")'"  "that Exceed `t' Days (%)") ///
					name(RI_QUAL_12_${ANALYSIS_COUNTER}_uwplot_`d1'_`d2'_`t')
					
				vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot for `d1' & `d2' (threshold `t' days) was created and exported."
			
				local ++i
			}
			noi di ""
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
