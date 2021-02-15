*! RI_COVG_02_06PO version 1.15 - Biostat Global Consulting - 2021-02-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Check user global to see whether to
*										save .gph file
* 2016-02-17	1.02	MK Trimner		Moved export option in opplot (issue61)
* 2016-04-04	1.03	Dale Rhoda		Add leading 0 to stratum ID for export
* 2016-07-06	1.04	Dale Rhoda		Add weightvar to organ pipe plot
* 2016-09-08	1.05	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2016-09-14 	1.06	Dale Rhoda		Add double inchworm plots
* 2016-11-17	1.07	Dale Rhoda		Only plot 'by age 1' if the dose is
*										given before age 1
* 2016-05-16	1.08	Dale Rhoda		Tell user how many inchworm plots
*										will be made
* 2017-06-06	1.09	MK Trimner		fixed comment under double plot
* 2017-08-26	1.10	Mary Prier		Added version 14.1 line
* 2019-10-13	1.11	Dale Rhoda		Supress double-inchworms if user requests bars
* 2020-12-11    1.12	Dale Rhoda		Copy _1_a_database from RI_COVG_01 if
*                                       the user didn't run RI_COVG_01 using 
*                                       the current value of ANALYSIS_COUNTER
* 2020-12-16	1.13	Cait Clary		Allow double inchworms when showbars=1 then 
* 										reset IWPLOT_SHOWBARS global
* 2021-02-11	1.14	Dale Rhoda		Cleaner code for double inchworms or bar charts
* 2021-02-14	1.15	Dale Rhoda		Implement filestub for OP plot calls
*******************************************************************************

program define RI_COVG_02_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_02_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		********************************
		* Make organ pipe plots

		if "$VCQI_MAKE_OP_PLOTS" == "1" {
		
			noi di as text _col(5) "Organ pipe plots"

			capture mkdir Plots_OP
			
			* Make a list of strata and their names
			
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}", clear

			keep stratumid HH02
			duplicates drop
			sort stratumid 
			local opp_nstrata = _N
			forvalues i = 1/`=_N' {
				if stratumid[`i'] < 10 local opp_stratum_id_`i' 0`=stratumid[`i']'
				else local opp_stratum_id_`i' = stratumid[`i']
				local opp_stratum_name_`i' = HH02[`i']
			}
			
			* Now make the plots themselves - one for each stratum
			
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}", clear
			
			foreach d in $RI_DOSE_LIST {

				noi di _continue _col(7) "`d' "

				local subtitle RI_COVG_02: Valid Coverage of `=upper("`d'")'

				forvalues i = 1/`opp_nstrata' {
					
					graph drop _all
					
					local filestub RI_COVG_02_${ANALYSIS_COUNTER}_opplot_`d'_`opp_stratum_id_`i''_`opp_stratum_name_`i''
					
					local savegph
					if $SAVE_VCQI_GPH_FILES ///
						local savegph   saving("Plots_OP/`filestub'", replace)

					local savedata
					if $VCQI_SAVE_OP_PLOT_DATA ///
						local savedata savedata(Plots_OP/`filestub')			
										
					opplot got_valid_`d'_to_analyze  , clustvar(clusterid) plotn  weightvar(psweight) ///
						   stratvar(stratumid) stratum(`=int(`opp_stratum_id_`i'')') ///
						   title("`opp_stratum_id_`i'' - `opp_stratum_name_`i''") ///
						   subtitle(`quote'"`subtitle'"`quote') ///
						   barcolor1(vcqi_level3) barcolor2(gs15) `savegph' `savedata' ///
						   export(Plots_OP/`filestub'.png)
					
					vcqi_log_comment $VCP 3 Comment "Graphic file: `filestub'.png was created and saved."

					graph drop _all
										
				}
			}
			noi di as text ""
		}
		
		********************************
		 * Inchworm or barchart plots
		
		if "$VCQI_MAKE_IW_PLOTS" == "1" {
		
			* The number of plots per dose (ppd) depends on whether
			* we are making level2 iwplots; calculate ppd and send
			* the number to the screen to calibrate the user's expectations
			
			local ppd 4
			local show2 = $SHOW_LEVEL_2_ALONE         + ///
						  $SHOW_LEVELS_2_3_TOGETHER   + ///
						  $SHOW_LEVELS_2_4_TOGETHER   + ///
						  $SHOW_LEVELS_2_3_4_TOGETHER > 0 
			if `show2' == 1 & "$VCQI_MAKE_LEVEL2_IWPLOTS" == "1" {
				use "$VCQI_DATA_FOLDER/level2names", clear
				count
				local ppd = 4 + 4*r(N)
				clear
			}			
			
			noi di as text _col(5) "${IWPLOT_TYPE}s (`ppd' plots per dose)"
		
			capture mkdir Plots_IW_UW
		
			foreach d in $RI_DOSE_LIST {
			
				graph drop _all

				noi di _continue _col(7) "`d' "
				vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}_`d'_a_database) ///
					filetag(RI_COVG_02_${ANALYSIS_COUNTER}_`d') ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}) ///
					title(RI - Valid Coverage of `=upper("`d'")') ///
					name(RI_COVG_02_${ANALYSIS_COUNTER}_iwplot_`d') 

				vcqi_log_comment $VCP 3 Comment "Valid coverage ${IWPLOT_TYPE} for `d' was created and exported."

				
				if `=scalar(`=lower("`d'")'_min_age_days)'  < 365 {

					graph drop _all
					
					vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}_`d'_aa1_database) ///
						filetag(RI_COVG_02_${ANALYSIS_COUNTER}_`d'_age1) ///
						datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}) ///
						title(RI - Valid Coverage by Age 1 of `=upper("`d'")') ///
						name(RI_COVG_02_${ANALYSIS_COUNTER}_iwplot_`d'_age1) 		

					vcqi_log_comment $VCP 3 Comment "Valid coverage by age 1 ${IWPLOT_TYPE} for `d' was created and exported."
				}
				
				* Double inchworm plot that shows crude coverage in gray and 
				* valid coverage in color
				
				* Double inchworm plot that shows crude coverage in gray and 
				* valid coverage in color
				
				graph drop _all

				vcqi_to_double_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}_`d'_a_database) ///
					filetag(RI_COVG_02_${ANALYSIS_COUNTER}_`d'_double) ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}) ///
					title(RI - Valid Coverage of `=upper("`d'")') /// 
					name(RI_COVG_02_${ANALYSIS_COUNTER}_iwplot_`d'_double) ///
					database2(${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}_`d'_a_database) ///
					datafile2(${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}) ///
					caption(Gray hollow shape is crude coverage; colored shape is valid coverage, size(vsmall) span) 
					

				vcqi_log_comment $VCP 3 Comment "Valid & crude coverage double ${IWPLOT_TYPE} for `d' was created and exported."

				if `=scalar(`=lower("`d'")'_min_age_days)'  < 365 {
				
					graph drop _all
					
					vcqi_to_double_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}_`d'_aa1_database) ///
						filetag(RI_COVG_02_${ANALYSIS_COUNTER}_`d'_age1_double) ///
						datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}) ///
						title(RI - Valid Coverage by Age 1 of `=upper("`d'")') /// 
						name(RI_COVG_02_${ANALYSIS_COUNTER}_iwplot_`d'_age1_double) ///
						database2(${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}_`d'_a_database) ///
						datafile2(${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}) ///
						caption(Gray hollow shape is crude coverage; colored shape is valid coverage, size(vsmall) span)

					vcqi_log_comment $VCP 3 Comment "Valid & crude coverage by age 1 double ${IWPLOT_TYPE} for `d' was created and exported."
				}				
			}	
			noi di as text ""
		}
	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
