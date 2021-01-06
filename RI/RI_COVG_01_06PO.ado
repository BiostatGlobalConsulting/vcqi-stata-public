*! RI_COVG_01_06PO version 1.07 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Check user global to see whether to
*										save .gph file
*
* 2016-02-12	1.02	MK Trimner		Moved export option (Issue61)
*
* 2016-04-04	1.03	Dale Rhoda		Add leading 0 to stratum ID for export
*
* 2016-07-06	1.04	Dale Rhoda		Added weightvar to opplot call
* 2016-09-08	1.05	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2016-05-16	1.06	Dale Rhoda		Tell user how many inchworm plots
*										will be made
* 2017-08-26	1.07	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_01_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_01_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		********************************
		* Make organ pipe plots
		
		if "$VCQI_MAKE_OP_PLOTS" == "1" {
		
			noi di as text _col(5) "Organ pipe plots"
		
			capture mkdir Plots_OP

			* Make a list of strata and their names
			
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear

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
			
			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear
			
			foreach d in $RI_DOSE_LIST {

				noi di _continue _col(7) "`d' "
				
				local subtitle RI_COVG_01: Crude Coverage of `=upper("`d'")'

				forvalues i = 1/`opp_nstrata' {
					
					local savegph
					if $SAVE_VCQI_GPH_FILES ///
						local savegph   saving("Plots_OP/RI_COVG_01_${ANALYSIS_COUNTER}_opplot_`d'_`opp_stratum_id_`i''_`opp_stratum_name_`i''", replace)

					local savedata
					if $VCQI_SAVE_OP_PLOT_DATA ///
						local savedata savedata(Plots_OP/RI_COVG_01_${ANALYSIS_COUNTER}_opplot_`d'_`opp_stratum_id_`i''_`opp_stratum_name_`i'')			
										
					opplot got_crude_`d'_to_analyze  , clustvar(clusterid) plotn  weightvar(psweight) ///
						   stratvar(stratumid) stratum(`=int(`opp_stratum_id_`i'')') ///
						   title("`opp_stratum_id_`i'' - `opp_stratum_name_`i''") ///
						   subtitle(`quote'"`subtitle'"`quote') ///
						   barcolor1(vcqi_level3) barcolor2(gs15) `savegph' `savedata' ///
						   export(Plots_OP/RI_COVG_01_${ANALYSIS_COUNTER}_opplot_`d'_`opp_stratum_id_`i''_`opp_stratum_name_`i''.png)
					
					vcqi_log_comment $VCP 3 Comment "Organ pipe plot was created and exported for `opp_stratum_name_`i''."

					graph drop _all

				}
			}
			noi di as text " "
		}

		
		********************************
		* Inchworm plots
			
		if "$VCQI_MAKE_IW_PLOTS" == "1" {
		
			* The number of plots per dose (ppd) depends on whether
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
			
			noi di as text _col(5) "Inchworm plots (`ppd' plots per dose)"
			
			capture mkdir Plots_IW_UW

			foreach d in $RI_DOSE_LIST {
			
				noi di _continue _col(7) "`d' "
				vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}_`d'_a_database) ///
					filetag(RI_COVG_01_${ANALYSIS_COUNTER}_`d') ///
					datafile(${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}) ///
					title(RI - Crude Coverage of `=upper("`d'")') ///
					name(RI_COVG_01_${ANALYSIS_COUNTER}_iwplot_`d') 
					
				vcqi_log_comment $VCP 3 Comment "Inchworm plot was created and exported."
			
				graph drop _all
				
				
			}
			noi di as text " "
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
