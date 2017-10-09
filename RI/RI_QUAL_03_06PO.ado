*! RI_QUAL_03_06PO version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*               1.00	Dale Rhoda		Original
* 2016-02-11	1.01	Dale Rhoda
* 2016-09-08	1.02	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2017-03-16	1.03	Dale Rhoda		Add dose to plot name
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_03_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_03_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		if "$VCQI_MAKE_UW_PLOTS" == "1" {
		
			noi di _col(5) "Unweighted proportion plot"
		
			capture mkdir Plots_IW_UW
		
			local d = lower("$RI_QUAL_03_DOSE_NAME")
			
			vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_03_${ANALYSIS_COUNTER}_`d'_database) ///
				filetag(RI_QUAL_03_`d') ///
				title(RI - Percentage of `=upper("`d'")' Doses Invalid) ///
				name(RI_QUAL_03_${ANALYSIS_COUNTER}_uwplot_`d')
				
			vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot was created and exported."
		}
		graph drop _all
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
