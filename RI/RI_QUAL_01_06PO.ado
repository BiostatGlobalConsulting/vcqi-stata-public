*! RI_QUAL_01_06PO version 1.14 - Biostat Global Consulting - 2021-02-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Check user global to see whether to
*										save .gph file
* 2016-02-17	1.02	MK Trimner		Move export option in opplot (Issue61)
* 2016-04-04	1.03	Dale Rhoda		Add leading 0 to stratum ID for export
* 2016-07-06	1.04	Dale Rhoda		Add weightvar to organ pipe plot
* 2016-09-08	1.05	Dale Rhoda		Add VCQI_MAKE_XX_PLOTS macros
* 2016-05-16	1.06	Dale Rhoda		Tell user how many inchworm plots
*										will be made
* 2017-08-26	1.07	Mary Prier		Added version 14.1 line
* 2018-08-15	1.08	MK Trimner		Added code to create op and iw plots for 
*										new card availabilty variable as well as
*										double iw plot to show card plus register
*										availability 
* 2018-10-04	1.09	MK Trimner		Changed "has" to "had"
* 2018-10-24	1.10	Dale Rhoda		Only make organ pipes for 
*											had_card_or_register
* 2019-10-13	1.11	Dale Rhoda		Supress double-inchworms if user requests bars
* 2020-12-16	1.12	Cait Clary		Allow double inchworms when showbars=1 then 
* 										reset IWPLOT_SHOWBARS global
* 2021-02-11	1.13	Dale Rhoda		Cleaner code for double inchworms or bar charts
* 2021-02-14	1.14	Dale Rhoda		Make opplot filename fit 8 element pattern
*******************************************************************************

program define RI_QUAL_01_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_01_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		********************************
		* Make organ pipe plots for card or register availability

		if "$VCQI_MAKE_OP_PLOTS" == "1" {
		
			noi di as text _col(5) "Organ pipe plots (card or register availability)"
				
			capture mkdir Plots_OP
			
			* Make a list of strata and their names
			
			use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}", clear

			keep stratumid HH02
			duplicates drop
			sort stratumid 
			local opp_nstrata = _N
			forvalues i = 1/`=_N' {
				if stratumid[`i'] < 10 local opp_stratum_id_`i' 0`=stratumid[`i']'
				else local opp_stratum_id_`i' = stratumid[`i']
				local opp_stratum_name_`i' = HH02[`i']
			}
			
			use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}", clear

			* Now make the plots themselves - one for each stratum
				
			local subtitle RI_QUAL_01: RI Card or Register Availability

			forvalues i = 1/`opp_nstrata' {

				graph drop _all
				
				local filestub RI_QUAL_01_${ANALYSIS_COUNTER}_opplot_sawcard_`opp_stratum_id_`i''_`opp_stratum_name_`i''
				
				local savegph
				if $SAVE_VCQI_GPH_FILES ///
					local savegph   saving("Plots_OP/`filestub'", replace)

				local savedata
				if $VCQI_SAVE_OP_PLOT_DATA ///
					local savedata savedata(Plots_OP/`filestub')			
				
				opplot had_card_or_register , clustvar(clusterid) plotn  weightvar(psweight) ///
					   stratvar(stratumid) stratum(`=int(`opp_stratum_id_`i'')') ///
					   title("`opp_stratum_id_`i'' - `opp_stratum_name_`i''") ///
					   subtitle(`quote'"`subtitle'"`quote') ///
					   barcolor1(vcqi_level3) barcolor2(gs15) `savegph' `savedata' ///
					   export(Plots_OP/`filestub'.png)
				
				vcqi_log_comment $VCP 3 Comment "Graphic file: `filestub'.png was created and saved."

				graph drop _all

			}
		}
		
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
			
			if ($RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 ) local ppd = `ppd' * 2
			
			noi di as text _col(5) "${IWPLOT_TYPE}s (`ppd' plots)"		
			
			capture mkdir Plots_IW_UW

			graph drop _all

			vcqi_to_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}_card_database) ///
				filetag(RI_QUAL_01_${ANALYSIS_COUNTER}) ///
				datafile(${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}) ///
				title(RI - Card Availability) name(RI_QUAL_01_${ANALYSIS_COUNTER}_iwplot)
				
			vcqi_log_comment $VCP 3 Comment "$IWPLOT_TYPE was created and exported."
		}
	

		if "$VCQI_MAKE_IW_PLOTS" == "1" & ($RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 ) {
		
			* Double inchworm plot that shows card availability in gray and card plus register in color

			graph drop _all

			vcqi_to_double_iwplot , database(${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}_card_or_register_database) ///
				filetag(RI_QUAL_01_${ANALYSIS_COUNTER}_double) ///
				datafile(${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}) ///
				title(RI - Card and Register Availability) /// 
				name(RI_QUAL_01_${ANALYSIS_COUNTER}_iwplot_double) ///
				database2(${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}_card_database) ///
				datafile2(${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}) ///
				caption(Gray hollow shape is card availability; colored shape is card plus register availability, size(vsmall) span) 				

			vcqi_log_comment $VCP 3 Comment "Card & Register Availability double ${IWPLOT_TYPE} was created and exported."

		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
