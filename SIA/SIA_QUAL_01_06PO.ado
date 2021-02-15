*! SIA_QUAL_01_06PO version 1.06 - Biostat Global Consulting - 2021-02-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Moved export option in opplot
* 2016-04-04	1.02	Dale Rhoda		Add leading 0 to stratum ID for export
* 2016-09-08	1.03	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2017-01-31	1.04	Dale Rhoda		Fixed a typo
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
* 2021-02-14	1.06	Dale Rhoda		Make opplot filename fit 8 element pattern
*******************************************************************************

program define SIA_QUAL_01_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_QUAL_01_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
		********************************
		* Make organ pipe plots
		if "$VCQI_MAKE_OP_PLOTS" == "1" {
		
			noi di as text _col(5) "Organ pipe plots"

			capture mkdir Plots_OP
		
			* Make a list of strata and their names
			
			use "${VCQI_OUTPUT_FOLDER}/SIA_QUAL_01_${ANALYSIS_COUNTER}", clear

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
			
			use "${VCQI_OUTPUT_FOLDER}/SIA_QUAL_01_${ANALYSIS_COUNTER}", clear
			
			* limit the denominator to respondents who got the SIA dose
			keep if inlist(SIA20,1,2)
				
			forvalues i = 1/`opp_nstrata' {
			
				graph drop _all
				
				local filestub SIA_QUAL_01_${ANALYSIS_COUNTER}_opplot_siacard_`opp_stratum_id_`i''_`opp_stratum_name_`i''
				
				if $SAVE_VCQI_GPH_FILES ///
					local savegph   saving("Plots_OP/`filestub'", replace)

				if $VCQI_SAVE_OP_PLOT_DATA ///
					local savedata savedata(Plots_OP/`filestub')

				opplot got_campaign_card  , clustvar(clusterid) plotn  weightvar(psweight) ///
					   stratvar(stratumid) stratum(`=int(`opp_stratum_id_`i'')') ///
					   title("`opp_stratum_id_`i'' - `opp_stratum_name_`i''") ///
					   subtitle(Vaccinated Respondent Received SIA Card) ///
					   barcolor1(vcqi_level3) barcolor2(gs15) `savegph' `savedata' ///
					   export(Plots_OP/`filestub'.png) 
					   
				vcqi_log_comment $VCP 3 Comment "Graphic file: `filestub'.png was created and saved."

				graph drop _all
				
			}
		}
		
		********************************
		* Make the unweighted  sample proportion plot
		
		if "$VCQI_MAKE_UW_PLOTS" == "1" {
		
			noi di as text _col(5) "Unweighted proportion plots"

			capture mkdir Plots_IW_UW

			graph drop _all

			vcqi_to_uwplot , database(${VCQI_OUTPUT_FOLDER}/SIA_QUAL_01_${ANALYSIS_COUNTER}_a_database) ///
				filetag(SIA_QUAL_01) ///
				title(SIA - Received a Campaign Card (%) ) name(SIA_QUAL_01_${ANALYSIS_COUNTER}_uwplot)
				
			vcqi_log_comment $VCP 3 Comment "Unweighted sample proportion plot was created and exported."
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
