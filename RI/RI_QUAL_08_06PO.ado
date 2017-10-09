*! RI_QUAL_08_06PO version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-03-11	1.01	Dale Rhoda		Fixed wording in vcqi_log_comment
* 2016-09-08	1.02	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_08_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_08_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		if "$VCQI_MAKE_UW_PLOTS" == "1" {
		
			noi di _col(5) "Unweighted proportion plots"
			
			capture mkdir Plots_IW_UW

			foreach d in $RI_DOSE_LIST {
		
				noi di _continue _col(7) "`d' "
				
				vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_08_${ANALYSIS_COUNTER}_`d'_database) ///
					filetag(RI_QUAL_08_`d') ///
					title(RI - Visits with MOV for `=upper("`d'")') ///
					name(RI_QUAL_08_${ANALYSIS_COUNTER}_uwplot_`d') 
					
				vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot for `d' was created and exported."

				graph drop _all
			
			}

			
			noi di _continue _col(7) "Totals..."
			
			vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_08_${ANALYSIS_COUNTER}_any_database) ///
				filetag(RI_QUAL_08_any) ///
				title(RI - Visits with MOV for Any Dose) ///
				name(RI_QUAL_08_${ANALYSIS_COUNTER}_uwplot_any) 
			
			vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot for any dose was created and exported."

			graph drop _all
			
			* The final measure in RI_QUAL_08 is not a proportion, but a ratio.
			* We do not currently have a plot for that.		
			
			noi di ""
			
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
