*! RI_QUAL_07_06PO version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-09-08	1.01	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2016-01-31	1.02	Dale Rhoda		Use RI_COVG_02_1 if doing what-if
*										analysis and RI_COVG_02_$ANALYSIS_COUNTER
*										does not exist
* 2016-05-16	1.03	Dale Rhoda		Tell user how many inchworm plots
*										will be made
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_07_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		if "$VCQI_MAKE_IW_PLOTS" == "1" {
		
			* The number of plots per dose (ppd) depends on whether
			* we are making level2 iwplots; calculate ppd and send
			* the number to the screen to calibrate the user's expectations
			
			local ppd 2
			
			local show2 = $SHOW_LEVEL_2_ALONE         + ///
						  $SHOW_LEVELS_2_3_TOGETHER   + ///
						  $SHOW_LEVELS_2_4_TOGETHER   + ///
						  $SHOW_LEVELS_2_3_4_TOGETHER > 0 
			
			if `show2' == 1 & "$VCQI_MAKE_LEVEL2_IWPLOTS" == "1" {
				use "$VCQI_DATA_FOLDER/level2names", clear
				count
				local ppd = `ppd' + `ppd'*r(N)
				clear
			}			
			
			noi di _col(5) "Inchworm plots (`ppd' plots per dose)"
			
			capture mkdir Plots_IW_UW

			local vc  `=lower("$RI_QUAL_07_VALID_OR_CRUDE")'

			foreach d in $RI_DOSE_LIST {
			
				noi di _continue _col(7) "`d' "
				
				graph drop _all

				* Regular inchworm plot
				
				vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_07_${ANALYSIS_COUNTER}_`d'_`vc'_database) ///
					filetag(RI_QUAL_07_${ANALYSIS_COUNTER}_`d'_`vc') ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_QUAL_07_${ANALYSIS_COUNTER}) ///
					title("RI - Would have Valid `=upper("`d'")'" "if no MOVs (%)") name(RI_QUAL_07_${ANALYSIS_COUNTER}_iwplot_`d'_`vc')
					
				vcqi_log_comment $VCP 3 Comment "Inchworm plot was created and exported."

				graph drop _all

				* Double inchworm plot that shows valid coverage in gray and 
				* valid coverage if no MOVs in color
				
				* If user is doing what-if analysis and using a value of ANALYSIS_COUNTER for which 
				* RI_COVG_02_${ANALYSIS_COUNTER}_`d'_a_database does not exist, try
				* pointing to file RI_COVG_02_1_`d'_a_database and issue a warning
				*
				* If RI_COVG_02_1_`d'_a_database does not exist, skip this plot
				*
				local double_ac
				capture confirm file "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}_`d'_a_database.dta"
				if _rc == 0 local double_ac $ANALYSIS_COUNTER
				else {
					capture confirm file "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_1_`d'_a_database.dta"
					if _rc == 0 {
						local double_ac 1
						vcqi_log_comment $VCP 2 Warning "RI_QUAL_07 made a double inchworm plot using RI_COVG_02_1_`d'_a_database because RI_COVG_02_${ANALYSIS_COUNTER}_`d'_a_database did not exist."
					}
				}
				
				* Only make the double inchworm plot if we were able to find either
				* RI_COVG_02_${ANALYSIS_COUNTER}_`d'_a_database or 
				* RI_COVG_02_1_`d'_a_database
				* otherwise, skip it
				
				if "`double_ac'" != "" {
				
					vcqi_to_double_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_07_${ANALYSIS_COUNTER}_`d'_`vc'_database) ///
						filetag(RI_QUAL_07_${ANALYSIS_COUNTER}_`d'_`vc'_double) ///
						datafile(${VCQI_OUTPUT_FOLDER}/RI_QUAL_07_${ANALYSIS_COUNTER}) ///
						title("RI - Would have Valid `=upper("`d'")'" "if no MOVs (%)") name(RI_QUAL_07_${ANALYSIS_COUNTER}_iwplot_`d'_`vc'_double) ///
						database2(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_`double_ac'_`d'_a_database) ///
						datafile2(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_`double_ac') ///
						caption(Gray hollow shape is valid coverage; colored shape is valid coverage if no MOVs, size(vsmall) span)
						
					vcqi_log_comment $VCP 3 Comment "Double inchworm plot was created and exported."
					
					graph drop _all

				}
			}
			noi di ""
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
