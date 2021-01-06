*! RI_QUAL_09_06PO version 1.07 - Biostat Global Consulting - 2019-11-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-04	1.01	MK Trimner		changed Plot title for last plot in file
* 2016-03-11	1.02	Dale Rhoda		corrected log comments and indenting
* 2016-09-08	1.03	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2017-02-03	1.04	Dale Rhoda		Cosmetic changes
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
* 2019-03-18  	1.06	Mary Prier		Added vcqi_global SORT_PLOT_LOW_TO_HIGH 
*										  4 times (once before each plot call)
* 2019-11-09	1.07 	Dale Rhoda		Introduced MOV_OUTPUT_DOSE_LIST
*******************************************************************************

program define RI_QUAL_09_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_09_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
			
		if "$VCQI_MAKE_UW_PLOTS" == "1" {
		
			noi di as text _col(5) "Unweighted proportion plots"
			
			capture mkdir Plots_IW_UW

			foreach d in $MOV_OUTPUT_DOSE_LIST {
			
				noi di _continue _col(7) "`d' "
			
				use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_`d'_database", clear
				
				save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_`d'_plot_database", replace
				gen estimate = n_mov / n_eligible if n_eligible != 0
				replace estimate = 0 if n_eligible == 0
				gen estimate_cor = n_cor_mov / n_mov if n_mov != 0
				replace estimate_cor = 0 if n_mov == 0
				gen n = n_eligible
				gen outcome = "Percent of respondents with MOV for `d'"
				save, replace
				vcqi_global RI_QUAL_09_TEMP_DATASETS $RI_QUAL_09_TEMP_DATASETS RI_QUAL_09_${ANALYSIS_COUNTER}_`d'_plot_database
					
				save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_`d'_corplot_database", replace
				replace estimate = estimate_cor
				replace n = n_mov
				drop n_eligible n_mov
				save, replace
				vcqi_global RI_QUAL_09_TEMP_DATASETS $RI_QUAL_09_TEMP_DATASETS RI_QUAL_09_${ANALYSIS_COUNTER}_`d'_corplot_database
				
				vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite
				vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_`d'_plot_database) ///
					filetag(RI_QUAL_09_`d') ///
					title(RI - Respondents with MOV for `=upper("`d'")') ///
					name(RI_QUAL_09_${ANALYSIS_COUNTER}_uwplot_`d')
					
				vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot for `d' was created and exported."

				graph drop _all
				vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite
				vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_`d'_corplot_database) ///
					filetag(RI_QUAL_09_`d'_cor) ///
					title("RI - Proportion of MOVs for `=upper("`d'")'" "that were Later Corrected") ///
					name(RI_QUAL_09_${ANALYSIS_COUNTER}_uwplot_`d'_cor) 
					
				vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot for Corrected `d' was created and exported."
			
				graph drop _all
			}
			
			noi di as text _col(7) "Totals..."
			
			use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_anydose_database", clear
			save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_anydose_plot_database", replace
			gen estimate = n_mov / n_eligible if n_eligible != 0
			replace estimate = 0 if n_eligible == 0
			gen estimate_cor = n_cor_mov / n_mov if n_mov != 0
			replace estimate_cor = 0 if n_mov == 0
			gen n = n_eligible
			gen outcome = "Percent of respondents with MOV for any dose"
			save, replace
			vcqi_global RI_QUAL_09_TEMP_DATASETS $RI_QUAL_09_TEMP_DATASETS RI_QUAL_09_${ANALYSIS_COUNTER}_anydose_plot_database
			
			save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_anydose_corplot_database", replace
			replace estimate = estimate_cor
			replace n = n_mov
			drop n_eligible n_mov
			save, replace
			vcqi_global RI_QUAL_09_TEMP_DATASETS $RI_QUAL_09_TEMP_DATASETS RI_QUAL_09_${ANALYSIS_COUNTER}_anydose_corplot_database
			
			vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite
			vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_anydose_plot_database) ///
				filetag(RI_QUAL_09_anydose) ///
				title(RI - Respondents with MOV for Any Dose) ///
				name(RI_QUAL_09_${ANALYSIS_COUNTER}_uwplot_anydose) 
				
			vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot for any dose was created and exported."
			graph drop _all

			vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite
			vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}_anydose_corplot_database) ///
				filetag(RI_QUAL_09_anydose_cor) ///
				title("RI - Percent of Respondents with MOVs" "that had All MOVs Later Corrected") ///
				name(RI_QUAL_09_${ANALYSIS_COUNTER}_uwplot_anydose_cor)
			
			vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot for any dose corrected was created and exported."

			graph drop _all
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
