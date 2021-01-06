*! SIA_COVG_04_06PO version 1.00 - Biostat Global Consulting - 2019-01-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-01	1.00 	Dale Rhoda		Original version
*******************************************************************************

program define SIA_COVG_04_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		********************************
		* Make the inchworm plot

		if "$VCQI_MAKE_IW_PLOTS" == "1" {
		
			* The number of plots (ppd) depends on whether
			* we are making level2 iwplots; calculate ppd and send
			* the number to the screen to calibrate the user's expectations
			
			local ppd 1
			
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
			
			noi di as text _col(5) "Inchworm plots (`ppd' plots)"		
			
			capture mkdir Plots_IW_UW

			graph drop _all

			vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/SIA_COVG_04_${ANALYSIS_COUNTER}_b_database) ///
				filetag(SIA_COVG_04) ///
				datafile(${VCQI_OUTPUT_FOLDER}/SIA_COVG_04_${ANALYSIS_COUNTER}) ///
				title(SIA - Received SIA Dose (%)) name(SIA_COVG_04_${ANALYSIS_COUNTER}_iwplot)
				
			vcqi_log_comment $VCP 3 Comment "Inchworm plot was created and exported."
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
