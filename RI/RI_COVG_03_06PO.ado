*! RI_COVG_03_06PO version 1.08 - Biostat Global Consulting - 2017-05-16
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
* 2016-09-15	1.06	Dale Rhoda		Add inchworm plot showing both valid
*                                       and crude coverage
* 2017-01-09	1.07	Dale Rhoda		Skip valid dose calculations if none
*										of the respondents have complete DOB
* 2016-05-16	1.08	Dale Rhoda		Tell user how many inchworm plots
*										will be made
*******************************************************************************

program define RI_COVG_03_06PO

	version 14
	local oldvcp $VCP
	global VCP RI_COVG_03_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"	

	quietly {
	
		********************************
		* Make organ pipe plots
		
		if "$VCQI_MAKE_OP_PLOTS" == "1" {
		
			noi di _col(5) "Organ pipe plots"

			capture mkdir Plots_OP
			
			* Make a list of strata and their names
		
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}", clear

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
			
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}", clear
			
			* Skip plots for valid doses if no respondent had DOB data
			local vlist fully_vaccinated_crude 
			if "$VCQI_NO_DOBS" != "1" local vlist fully_vaccinated_crude fully_vaccinated_valid fully_vaccinated_by_age1
			
			foreach v in `vlist' {
			
				noi di _continue _col(7) "`v' "
				
				if "`v'" == "fully_vaccinated_crude" {
					local subtitle RI_COVG_03: Fully Vaccinated - Crude Doses
					local abbrev fvc
				}
				if "`v'" == "fully_vaccinated_valid" {
					local subtitle RI_COVG_03: Fully Vaccinated - Valid Doses
					local abbrev fvv
				}
				if "`v'" == "fully_vaccinated_by_age1" {
					local subtitle RI_COVG_03: Fully Vaccinated by Age 1 - Valid Doses 
					local abbrev fva1
				}		
				
				forvalues i = 1/`opp_nstrata' {
					
					graph drop _all
					
					local savegph
					if $SAVE_VCQI_GPH_FILES ///
						local savegph   saving("Plots_OP/RI_COVG_03_${ANALYSIS_COUNTER}_opplot_`abbrev'_`opp_stratum_id_`i''_`opp_stratum_name_`i''", replace)

					local savedata
					if $VCQI_SAVE_OP_PLOT_DATA ///
						local savedata savedata(Plots_OP/RI_COVG_03_${ANALYSIS_COUNTER}_opplot_`abbrev'_`opp_stratum_id_`i''_`opp_stratum_name_`i'')			
					
					opplot `v'  , clustvar(clusterid) weightvar(psweight) ///
						   stratvar(stratumid) stratum(`=int(`opp_stratum_id_`i'')') ///
						   title("`opp_stratum_id_`i'' - `opp_stratum_name_`i''") ///
						   subtitle(`quote'"`subtitle'"`quote') ///
						   barcolor1(ltblue) `savegph' `savedata' ///
						   export (Plots_OP/RI_COVG_03_${ANALYSIS_COUNTER}_opplot_`abbrev'_`opp_stratum_id_`i''_`opp_stratum_name_`i''.png)
					
					vcqi_log_comment $VCP 3 Comment "Organ pipe plot was created and exported for `opp_stratum_name_`i''."

				}
			}
			noi di ""
		}
		
		********************************
		* Inchworm plots
		
		if "$VCQI_MAKE_IW_PLOTS" == "1" {
		
			* The number of plots (ppd) depends on whether
			* we are making level2 iwplots; calculate ppd and send
			* the number to the screen to calibrate the user's expectations
			
			local ppd 1
			if "$VCQI_NO_DOBS" != "1" local ppd 4
			
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
			
			noi di _col(5) "Inchworm plots (`ppd' plots)"
			
			capture mkdir Plots_IW_UW
			
			* Do not show the plots with only crude or only valid coverage; just show
			* the combined "double" plot referenced below
			
			* fully vaccinated - crude
			graph drop _all

			vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}_fvc_database) ///
				filetag(RI_COVG_03_${ANALYSIS_COUNTER}_fvc) ///
				datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}) ///
				title(RI - Fully Vaccinated - Crude) name(RI_COVG_03_${ANALYSIS_COUNTER}_iwplot_fvc)
			vcqi_log_comment $VCP 3 Comment "Fully vaccinated (crude) plot was created and exported."

			* Skip valid dose plots if no respondent had DOB data
			if "$VCQI_NO_DOBS" != "1" {
			
				* fully vaccinated - valid
				graph drop _all
				
				vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}_fvv_database) ///
					filetag(RI_COVG_03_${ANALYSIS_COUNTER}_fvv) ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}) ///
					title(RI - Fully Vaccinated - Valid) name(RI_COVG_03_${ANALYSIS_COUNTER}_iwplot_fvv)
				vcqi_log_comment $VCP 3 Comment "Fully vaccinated (valid) plot was created and exported."
				
				* fully vaccinated - valid and crude
				graph drop _all

				vcqi_to_double_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}_fvv_database) ///
					filetag(RI_COVG_03_${ANALYSIS_COUNTER}_fvv_double) ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}) ///
					title(RI - Fully Vaccinated - Valid) ///
					name(RI_COVG_03_${ANALYSIS_COUNTER}_iwplot_fvv_double) ///
					database2(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}_fvc_database) ///
					datafile2(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}) ///
					caption(Gray hollow shape is crude coverage; colored shape is valid coverage, size(vsmall) span) 
					
				vcqi_log_comment $VCP 3 Comment "Valid & crude coverage inchworm plot was created and exported."

				* fully vaccinated by age 1
				graph drop _all
				
				vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}_fva1_database) ///
					filetag(RI_COVG_03_${ANALYSIS_COUNTER}_fva1) ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}) ///
					title(RI - Fully Vaccinated - Valid by Age 1) name(RI_COVG_03_${ANALYSIS_COUNTER}_iwplot_fva1)
				vcqi_log_comment $VCP 3 Comment "Fully vaccinated (by age 1) plot was created and exported."
			}
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
