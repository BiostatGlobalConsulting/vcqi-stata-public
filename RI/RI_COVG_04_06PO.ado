*! RI_COVG_04_06PO version 1.11 - Biostat Global Consulting - 2020-12-16
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Check user global to see whether to
*										save .gph file
* 2016-02-17	1.02	MK Trimner		Move export option in opplot (issue61)
* 2016-04-04	1.03	Dale Rhoda		Add leading 0 to stratum ID for export
* 2016-07-06	1.04	Dale Rhoda		Add weightvar to organ pipe plot
* 2016-09-08	1.05	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2016-09-15	1.06	Dale Rhoda		Show valid and crude coverage together
* 										in a single inchworm plot
* 2016-01-07	1.07	Dale Rhoda		Skip valid dose plots if no respondent
*										has DOB data
* 2016-05-16	1.08	Dale Rhoda		Tell user how many inchworm plots
*										will be made
* 2017-08-26	1.09	Mary Prier		Added version 14.1 line
* 2019-10-13	1.10	Dale Rhoda		Supress double-inchworms if user requests bars
* 2020-12-16	1.11	Cait Clary		Allow double inchworms when showbars=1 then 
* 										reset IWPLOT_SHOWBARS global
*******************************************************************************

program define RI_COVG_04_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_04_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		********************************
		* Make organ pipe plots
		
		if "$VCQI_MAKE_OP_PLOTS" == "1" {
		
			noi di as text _col(5) "Organ pipe plots"

			capture mkdir Plots_OP
			
			* Make a list of strata and their names
			
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}", clear

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
			
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}", clear
			
			* Skip valid dose plots if no respondent has DOB data
			local vlist not_vaccinated_crude
			if "$VCQI_NO_DOBS" != "1" local vlist not_vaccinated_crude not_vaccinated_valid not_vaccinated_by_age1
			
			foreach v in `vlist' {
			
				noi di _continue _col(7) "`v' "

				if "`v'" == "not_vaccinated_crude" {
					local subtitle RI_COVG_04: Not Vaccinated - Crude Doses
					local abbrev nvc
				}
				if "`v'" == "not_vaccinated_valid" {
					local subtitle RI_COVG_04: Not Vaccinated - Valid Doses
					local abbrev nvv
				}
				if "`v'" == "not_vaccinated_by_age1" {
					local subtitle RI_COVG_04: Not Vaccinated by Age 1 - Valid Doses 
					local abbrev nva1
				}		
				
				forvalues i = 1/`opp_nstrata' {
										
					local savegph
					if $SAVE_VCQI_GPH_FILES ///
						local savegph   saving("Plots_OP/RI_COVG_04_${ANALYSIS_COUNTER}_opplot_`abbrev'_`opp_stratum_id_`i''_`opp_stratum_name_`i''", replace)

					local savedata
					if $VCQI_SAVE_OP_PLOT_DATA ///
						local savedata savedata(Plots_OP/RI_COVG_04_${ANALYSIS_COUNTER}_opplot_`abbrev'_`opp_stratum_id_`i''_`opp_stratum_name_`i'')			

					opplot `v'  , clustvar(clusterid) plotn  weightvar(psweight) ///
						   stratvar(stratumid) stratum(`=int(`opp_stratum_id_`i'')') ///
						   title("`opp_stratum_id_`i'' - `opp_stratum_name_`i''") ///
						   subtitle(`quote'"`subtitle'"`quote') ///
						   barcolor1(vcqi_level3) barcolor2(gs15) `savegph' `savedata' ///
						   export(Plots_OP/RI_COVG_04_${ANALYSIS_COUNTER}_opplot_`abbrev'_`opp_stratum_id_`i''_`opp_stratum_name_`i''.png)
					
					vcqi_log_comment $VCP 3 Comment "Organ pipe plot was created and exported for `opp_stratum_name_`i''."

					graph drop _all
				}
			}
			noi di as text ""
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
			
			noi di as text _col(5) "Inchworm plots (`ppd' plots)"
			
			capture mkdir Plots_IW_UW
		
			* not vaccinated - crude

			* Do not show crude and valid separately; show them in a combined plot below
			
			vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}_nvc_database) ///
				filetag(RI_COVG_04_${ANALYSIS_COUNTER}_nvc) ///
				datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}) ///
				title(RI - Not Vaccinated - Crude) name(RI_COVG_04_${ANALYSIS_COUNTER}_iwplot_nvc)

			vcqi_log_comment $VCP 3 Comment "Not vaccinated (crude) plot was created and exported."

			graph drop _all
			
			* Make valid dose plots if 1+ respondents has DOB data
			
			if "$VCQI_NO_DOBS" != "1" {
			
				* not vaccinated - valid

				vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}_nvv_database) ///
					filetag(RI_COVG_04_${ANALYSIS_COUNTER}_nvv) ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}) ///
					title(RI - Not Vaccinated - Valid) name(RI_COVG_04_${ANALYSIS_COUNTER}_iwplot_nvv)
				vcqi_log_comment $VCP 3 Comment "Not vaccinated (valid) plot was created and exported."
				
				graph drop _all
				
				* valid and crude coverage show together

				* Temporarily set IWPLOT_SHOWBARS to 0 so that the double inchworm plot is generated
				vcqi_global IWPLOT_SHOWBARS 0
		
				vcqi_to_double_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}_nvv_database) ///
					filetag(RI_COVG_04_${ANALYSIS_COUNTER}_nvv_double) ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}) ///
					title(RI - Not Vaccinated - Valid) ///
					name(RI_COVG_04_${ANALYSIS_COUNTER}_iwplot_nvv_double) ///
					database2(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}_nvc_database) ///
					datafile2(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}) ///
					caption(Gray hollow shape is crude coverage; colored shape is valid coverage, size(vsmall) span) 
					
				vcqi_log_comment $VCP 3 Comment "Valid & crude coverage inchworm plot was created and exported."

				graph drop _all

				* Revert IWPLOT_SHOWBARS back to the user's selection
				vcqi_global IWPLOT_SHOWBARS $IWPLOT_SHOWBARS_SAVEOPT
				
				* not vaccinated by age 1

				vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}_nva1_database) ///
					filetag(RI_COVG_04_${ANALYSIS_COUNTER}_nva1) ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}) ///
					title(RI - Not Vaccinated - Valid by Age 1) name(RI_COVG_04_${ANALYSIS_COUNTER}_iwplot_nva1)
				
				vcqi_log_comment $VCP 3 Comment "Not vaccinated (by age 1) plot was created and exported."
				
				graph drop _all
			}
		}
	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
