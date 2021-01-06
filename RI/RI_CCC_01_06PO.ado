*! RI_CCC_01_06PO version 1.05 - Biostat Global Consulting - 2020-04-29
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-23	1.01	Mary Prier		Added code to delete Plot_CCC folder
*                                       if it exists &
*                                       Updated filename to substitute "_" for
*                                        "." if "." was in stratum_name
* 2019-09-13	1.02	Mary Prier		Changed "CCC_pct" to "RI_CCC_pct"; added
*										code for temporary files to be deleted if
*  										requested by the user
* 2020-04-14	1.03	Dale Rhoda		Made 'n' calc consistent with 03DV
* 2020-04-28	1.04	Dale Rhoda		Made 'n' calc consistent with CCC_02;
*                                       added GPH saving
*                                       And drop x values beyond xmax.
* 2020-04-29	1.05	Dale Rhoda		Allow the user to add xlabel values via
*                                       RI_CCC_01_XLABEL_INCLUDE (i.e., 365)
*                                       Also extended margin line all the way 
*                                       around the plot and removed the vertical
*                                       line at xmax        
*******************************************************************************

program define RI_CCC_01_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CCC_01_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {		
		noi di as text _col(5) "Cumulative coverage curves (CCC)..."
	
		* Check if folder Plots_CCC exists
		capture confirm file "${VCQI_OUTPUT_FOLDER}/Plots_CCC/nul"
		if (_rc==0 & "$REFRESHED_CCC_FOLDER_ALREADY" != "1") {  // _rc will be 0 if folder exists
			* Delete folder & files
			*shell rmdir "${VCQI_OUTPUT_FOLDER}/Plots_CCC/" /s /q
			vcqi_global REFRESHED_CCC_FOLDER_ALREADY 1
		}
		* Make new (and empty) folder
		capture mkdir "${VCQI_OUTPUT_FOLDER}/Plots_CCC/"
	
		use "${VCQI_OUTPUT_FOLDER}/RI_CCC_01_${ANALYSIS_COUNTER}", clear

		*----------------------
		* Make dataset for CCCs
		*----------------------
		* Open postfile to store the proportion of respondents who had rec'd dose on or by given day
		capture postclose pfile
		postfile pfile str20 levelid str10 levelname stratum str100 stratum_name str10 dose str10 card_reg days pct n using RI_CCC_pct, replace
		
		* Add RI_CCC_pct to the list of files to delete if user wants to delete all temporary files
		vcqi_global RI_CCC_01_TEMP_DATASETS $RI_CCC_01_TEMP_DATASETS RI_CCC_pct
	
		* Loop over doses and days of age and post the cumulative % who were vx'd by that age
		*foreach l in 1 2 3 {  // 3 levels: nation/zone/stratum
		foreach l in $RI_CCC_01_PLOT_LEVELS {
			noi di as text _col(7) "Calculating statistics for level `l':"
			if(`l'==1) {
				local lname nation
			}
			else if (`l'==2) {
				local lname zone
			}
			else if (`l'==3) {
				local lname stratum
			}
			else {
				local lname 
			}
			levelsof level`l'id, local(l_list)
			foreach k of local l_list {
				noi di _continue _col(9) " `k'"
				* Get name of nation/zone/stratum (Will use as subtitle on plot)
				capture drop temp
				gen temp = level`l'name if level`l'id==`k'
				replace temp = temp[_n-1] if missing(temp)  // this fills in all the missing values below the chunk of filled cells
				local stratum_name=temp[_N]  // grab the last entry (which will always be filled)
				/*if(`l'==3) {
					capture drop temp
					gen temp = HH02 if level`l'==`k'
					replace temp = temp[_n-1] if missing(temp)  // this fills in all the missing values below the chunk of filled cells
					local stratum_name=temp[_N]  // grab the last entry (which will always be filled)
				}
				else if (`l'==2) {
					local stratum_name "Zone `k'"
				}
				else if (`l'==1) {
					local stratum_name "Nation"
				}
				else {
					local stratum_name ""
				}
				*/
				
				
				foreach d in `=lower("$RI_DOSE_LIST")' {
					di as text "   `d'"
					foreach cr in card register {
						local xmax = ${XMAX_`cr'}
						forvalues j = 0/`xmax' {					
							capture drop y
							qui gen y = age_at_`d'_`cr'<=`j' & denom_`cr'==1 if level`l'id==`k'
							*svypd y if `c`i''
							qui count if y==1
							local numer = r(N)
							qui count if denom_`cr'==1 & level`l'id==`k'
							local denom = r(N)
							local p = `numer' / `denom' * 100
							post pfile ("level`l'") ("`lname'") (`k') ("`stratum_name'") ("`d'") ("`cr'") (`j') (`p') (`denom')
						}
					}
				}
			}
			noi di as text ""
		}

		postclose pfile
		
		use RI_CCC_pct, clear
		compress
		
		drop if card_reg == "card" & days > $XMAX_card
		drop if card_reg == "register" & days > $XMAX_register
		
		save RI_CCC_pct, replace			

		*--------------------------------
		* Make cumulative coverage curves
		*--------------------------------
		noi di as text _col(7) "Make and save cumulative coverage curves..."
		use RI_CCC_pct, clear
	
		* Make list of antigens (will be replicates in this list)
		local antigen_list
		foreach d in `=lower("$RI_DOSE_LIST")' {
			local lastchar = substr("`d'",strlen("`d'"),1)
			local allbutlastchar = substr("`d'",1,`=strlen("`d'")-1')
			if (real("`lastchar'") == .) {
				local antigen_list `antigen_list' `d'
			} 
			else {
				local antigen_list `antigen_list' `allbutlastchar'
			}
		}

		* Now make a list of antigens that only contains unique values
		local antigen_family : list uniq antigen_list
		
		* Assign each antigen family a unique counter
		local a_counter = 0
		foreach a in `antigen_family' {
			local a_counter = `a_counter' + 1
			local counter_`a' = `a_counter'	
			
			* Make a note in the log what # is assigned to each antigen family so user can look at log and then go to ccc_globals.do to make color/line changes
			vcqi_log_comment $VCP 3 CCC "Cumulative coverage curve: Antigen `a' is assigned the number `a_counter'. Use this information to make changes in the ccc_globals.do program if want different colors or line types on CCC plots."
		}
		
		* Make list from 1 to max a_counter (for use in legend automation) (e.g., a_list = 1 2 3 4)
		local a_list
		forvalues b = 1(1)`a_counter' {
			local a_list `a_list' `b'
		}
		
		* For note part on plot...calculate ages at which children are supposed to receive their vaccines
		local vac_schedule_days
		foreach d in `=lower("$RI_DOSE_LIST")' { 
			local vac_schedule_days `vac_schedule_days' `=scalar(`d'_min_age_days)'
		}
		numlist "`: list uniq vac_schedule_days'", sort
		local vac_schedule_days `=r(numlist)'
		local uniq_days_in_schedule: list sizeof vac_schedule_days
		local counter 0
		global SECOND_PART_OF_NOTE
		foreach v of local vac_schedule_days {
			global SECOND_PART_OF_NOTE $SECOND_PART_OF_NOTE `v',
			local counter = `counter' + 1
			if `counter'==`=`uniq_days_in_schedule'-2' {
				continue, break
			}
		}
		global SECOND_PART_OF_NOTE "${SECOND_PART_OF_NOTE} `: word `=`uniq_days_in_schedule'-1' of `vac_schedule_days'' & `: word `uniq_days_in_schedule' of `vac_schedule_days'' days"
				
		* Figure out if looping over card and/or register
		if ($RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1) {
			local cr_loop card register
		}
		else {
			local cr_loop card
		}
		 
		* Update local cr_loop if $CARD_REGISTER is defined in ccc_globals.do
		if ("$RI_CCC_01_CARD_REGISTER" != "") {
			local cr_loop $RI_CCC_01_CARD_REGISTER
		}
	
		*-----------------------------------------------------------------------
		* Loop over levelid's user specified (e.g., 1=nation, 2=zone, 3=stratum)
		*-----------------------------------------------------------------------
		foreach ll in $RI_CCC_01_PLOT_LEVELS {
			* Set local to level#, which is used throughout the loop
			local l level`ll'
			
			* Loop over unique values within that levelid (e.g., nation will only have 1, but zone might have 1 or 2 or more, and stratum might have up to 15 or 30)
			qui levelsof stratum if levelid=="`l'", local(l_list)
			foreach k of local l_list {
				* Get stratum name (to use in subtitle & filename)
				capture drop temp
				gen temp = stratum_name if levelid=="`l'" & stratum==`k'
				replace temp = temp[_n-1] if missing(temp)  // this fills in all the missing values below the chunk of filled cells
				local stratum_name=temp[_N]  // grab the last entry (which will always be filled)
				
				* Loop over card and/or register outcomes
				foreach cr of local cr_loop {
					* Vertical lines (representing vaccination schedule)
					local vlines 
					foreach d in `=lower("$RI_DOSE_LIST")' {
						local vlines `vlines' `=`d'_min_age_days'
					}	
					
					* Make list of x-labels (usually coincides with vaccination schedule & xmax, but can involve other x-values...)
					local xlabels
					foreach v of local vac_schedule_days {
						local xlabels `xlabels' `v'
					}
					* Add XMAX as an x-label
					local xlabels `xlabels' ${XMAX_`cr'}
					* Allow user to over-ride automatic x-labels
					if("$RI_CCC_01_XLABELS" != "") {
						local xlabels $RI_CCC_01_XLABELS
					}
					* Add any labels the user wants to include (i.e., 365 days)
					if("$RI_CCC_01_XLABEL_INCLUDE" != "") {
						local xlabels `xlabels' $RI_CCC_01_XLABEL_INCLUDE
					}
					
					* Should the x-labels be alternated?
					if("$RI_CCC_01_XLABEL_ALTERNATE"=="1") {  //1=yes, alternate x-labels
						local xlabels_code xlabel(`xlabels',labsize($RI_CCC_01_XLABEL_SIZE) alternate)
					}
					else {
						local xlabels_code xlabel(`xlabels',labsize($RI_CCC_01_XLABEL_SIZE))
					}
		
					* Format n (to use in subtitle)

					* Load up some locals with sample size counts to use later on the plot
					
					preserve
					use "${VCQI_OUTPUT_FOLDER}/RI_CCC_01_${ANALYSIS_COUNTER}", clear

					count if `cr'_with_dates == 1 & level`ll'id == `k' 
					local n_with_`cr'_for_subtitle = r(N)
					restore
					
					local n_subtitle = `n_with_`cr'_for_subtitle'
					local width = strlen("`n_subtitle'") 
					if `n_subtitle' > 999    local ++width // adding 1 for comma
					if `n_subtitle' > 999999 local ++width // ditto
					local n_subtitle: di %`width'.0fc `n_subtitle'
										
					*---------------------------
					* Plot all doses on one plot
					*---------------------------
					* Make local of curves to plot (one curve for each dose)
					local curves
					local legend_counter = 1
					local legend_order 
					foreach d in `=lower("$RI_DOSE_LIST")' {
						local lastchar = substr("`d'",strlen("`d'"),1)
						local allbutlastchar = substr("`d'",1,`=strlen("`d'")-1')
						if (real("`lastchar'") == .) {
							local i `d'
						} 
						else {
							local i `allbutlastchar'
						} 
						local aa "`counter_`i''"
						local curves `curves' (line pct days if dose=="`d'" & levelid=="`l'" & stratum==`k' & card_reg=="`cr'", lcolor("${RI_CCC_01_COLOR`aa'}") lpattern("${RI_CCC_01_PATTERN`aa'}") lwidth("${RI_CCC_01_WIDTH`aa'}"))
						
						* Update legend local (i.e, building local: 1 "BCG" 2 "OPV" 3 "MCV" 4 "DPT")
						if(`legend_counter'==1) {
							local a_list2 = subinstr("`a_list'", " ", ",",.)
						}
						if (inlist(`aa',`a_list2')) {
							local i_upper = upper("`i'")
							local legend_order `legend_order' `legend_counter' `" `i_upper' "'
							local a_list2 = subinstr("`a_list2'", "`aa'", "-`aa'",.)  // this line negates the current "aa" in the a_list
						}
						local legend_counter = `legend_counter' + 1
					}

					* Finally, make plot of all doses
					twoway 	`curves' ///
							, title($RI_CCC_01_PLOT_TITLE) subtitle("`stratum_name'") ///
							note("Vertical dashed lines mark scheduled vaccination ages: ${SECOND_PART_OF_NOTE}." "Denominator is number of respondents with cards with dates (n=`n_subtitle').",span) ///
							xline(`vlines', lcolor($RI_CCC_01_VLINE_COLOR) lpattern($RI_CCC_01_VLINE_PATTERN) lwidth($RI_CCC_01_VLINE_WIDTH)) ///
							`xlabels_code' ///
							ytitle("Cumulative Unweighted % Vaccinated" "(According to `cr')") xtitle("Age (days)")  ///
							ylabel(0(20)100,angle(0) gmax) legend(on order(`legend_order') row($RI_CCC_01_NUM_LEGEND_ROWS) span) ///
							name(plot_temp,replace) graphregion(fcolor($RI_CCC_01_GRAPHREGION_COLOR)) ///
							plotregion(lcolor(black)) xlabel(,grid nogextend ) ylabel(,grid nogextend )
					
					* Replace any periods (.) in stratum name to underscore (_)
					local sn = subinstr("`stratum_name'",".","_",.)
					
					* Save plot
					graph export "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_01_${ANALYSIS_COUNTER}_`l'_`k'`sn'_alldoses_`cr'.png", width(2000) replace
					if "$SAVE_VCQI_GPH_FILES" == "1" graph save "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_01_${ANALYSIS_COUNTER}_`l'_`k'`sn'_alldoses_`cr'.gph", replace				
					vcqi_log_comment $VCP 3 Comment "Cumulative coverage curve was created and exported for `l'_`k'`sn'_alldoses_`cr'."

					graph drop _all
						
					*----------------------=
					* Plot by antigen family
					*----------------------=
					foreach a in `antigen_family' {  // loop over antigen family
						local a_upper = upper("`a'")
						levelsof dose, local(dose_list)
						local doses
						* Make list of specific doses in the anigen family
						foreach d of local dose_list {
							if (substr("`d'",1,`=strlen("`a'")')=="`a'") {
								local doses `doses' `d'
							}
						}
						
						* (1) Update vertical lines on plot to only be lines relevant for antigen family (representing vaccination schedule)
						* (2) Update x-labels on ticks to be first & last labels (i.e., 0 & max) PLUS any antigen family label
						* (3) Make local of curves to plot (one curve for each dose in the antigen family)
						local vlines2
						local xlabels2 0
						local curves
						local aa "`counter_`a''"
						foreach d in `doses' {	
							* (1) vertical lines...
							local vlines2 `vlines2' `=`d'_min_age_days'
							
							* (2) x-labels...
							if(`=`d'_min_age_days' != 0) {
								local xlabels2 `xlabels2' `=`d'_min_age_days'
							}
							
							* (3) dose curves...				
							local curves `curves' (line pct days if dose=="`d'" & levelid=="`l'" & stratum==`k' & card_reg=="`cr'", lcolor("${RI_CCC_01_COLOR`aa'}") lpattern("${RI_CCC_01_PATTERN`aa'}") lwidth("${RI_CCC_01_WIDTH`aa'}"))
						}
							
						* Add max to xlabels...
						local xlabels2 `xlabels2' ${XMAX_`cr'}
						* Allow user to over-ride automatic x-labels
						if("$RI_CCC_01_XLABELS" != "") {
							local xlabels2 $RI_CCC_01_XLABELS
						}
						* Add any labels the user wants to include (i.e., 365 days)
						if("$RI_CCC_01_XLABEL_INCLUDE" != "") {
							local xlabels2 `xlabels2' $RI_CCC_01_XLABEL_INCLUDE
						}
					
						* Should the x-labels be alternated?
						if("$RI_CCC_01_XLABEL_ALTERNATE"=="1") {  //1=yes, alternate x-labels
							local xlabels2_code xlabel(`xlabels2',labsize($RI_CCC_01_XLABEL_SIZE) alternate)
						}
						else {
							local xlabels2_code xlabel(`xlabels2',labsize($RI_CCC_01_XLABEL_SIZE))
						}
					
						* Update $SECOND_PART_OF_NOTE to include only vac'n schedule of doses plotted
						local temp `vlines2'
						local temp_size : list sizeof temp
						if (`temp_size'==1) {
							global SECOND_PART_OF_NOTE2 "`vlines2' days"
						}
						else if (`temp_size'==2) {
							local temp2=subinstr("`temp'"," "," & ",1)
							global SECOND_PART_OF_NOTE2 "`temp2' days"
						}
						else {
							local temp3=subinstr("`temp'"," "," & ",.)  // replace all spaces with &'s
							local temp3=subinstr("`temp3'"," & ", ", ",`=`temp_size'-2')  // replace all but the last & with commas
							global SECOND_PART_OF_NOTE2 "`temp3' days"
						}		
						
						* Finally, make antigen family plot
						twoway 	`curves' ///
								, title($RI_CCC_01_PLOT_TITLE) subtitle("`stratum_name'") ///
								note("Vertical dashed lines mark scheduled vaccination ages: ${SECOND_PART_OF_NOTE2}." "Denominator is number of respondents with cards with dates (n=`n_subtitle')",span) ///
								xline(`vlines2', lcolor($RI_CCC_01_VLINE_COLOR) lpattern($RI_CCC_01_VLINE_PATTERN) lwidth($RI_CCC_01_VLINE_WIDTH)) ///
								`xlabels2_code' ///
								ytitle("Cumulative Unweighted % Vaccinated" "(According to `cr')") xtitle("Age (days)")  ///
								ylabel(0(20)100,angle(0) gmax) legend(on order(1 "`a_upper'") row(1) span) ///
								name(plot_temp,replace) graphregion(fcolor($RI_CCC_01_GRAPHREGION_COLOR)) ///
								plotregion(lcolor(black)) xlabel(,grid nogextend ) ylabel(,grid nogextend )
							
						graph export "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_01_${ANALYSIS_COUNTER}_`l'_`k'`sn'_`a'_`cr'.png", width(2000) replace	
						if "$SAVE_VCQI_GPH_FILES" == "1" graph save "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_01_${ANALYSIS_COUNTER}_`l'_`k'`sn'_`a'_`cr'.gph", replace	
						
						vcqi_log_comment $VCP 3 Comment "Cumulative coverage curve was created and exported for `l'_`k'`sn'_`a'_`cr'."

						graph drop _all
						
					}  // end loop over antigen_family specific plot "a"
				
				}  // end loop over card/register loop
				
			}  // end loop over `k'
			
		} // end loop over levelid "l"
			
	} // close quietly brace

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
