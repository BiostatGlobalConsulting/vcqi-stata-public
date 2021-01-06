*! RI_CCC_02_06PO version 1.07 - Biostat Global Consulting - 2020-12-02
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
* 2020-04-09	1.03	Dale Rhoda		Switch to a weighted estimate of coverage
*                                       and add shading and periscopes at the 
*                                       far right 
* 2020-04-17	1.04	Dale Rhoda		Add GPH save
* 2020-04-22	1.05	Dale Rhoda		Drop data beyond xmax
* 2020-04-29	1.06	Dale Rhoda		Allow the user to add xlabel values via
*                                       RI_CCC_02_XLABEL_INCLUDE (i.e., 365)
*                                       Also extended margin line all the way 
*                                       around the plot and removed the vertical
*                                       line at xmax   
* 2020-12-02	1.07	Dale Rhoda		Based on feedback from colleagues, 
*                                       suppress displaying the periscopes at
*                                       the right side of the figure; for now
*                                       we retain the code that generates the
*                                       periscope syntax, but do not execute it
*******************************************************************************

program define RI_CCC_02_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CCC_02_06PO
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
	
		use "${VCQI_OUTPUT_FOLDER}/RI_CCC_02_${ANALYSIS_COUNTER}", clear
		
		$VCQI_SVYSET_SYNTAX
		
		* Figure out if looping over card and/or register
		if ($RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1) {
			local cr_loop card register
		}
		else {
			local cr_loop card
		}
		 
		* Update local cr_loop if $CARD_REGISTER is defined in ccc_globals.do
		if ("$RI_CCC_02_CARD_REGISTER" != "") {
			local cr_loop $RI_CCC_02_CARD_REGISTER
		}		
		
		*----------------------
		* Make dataset for CCCs
		*----------------------
		
		* Open postfile to store periscope start and end y-values and the start x-values
		capture postclose peri
		postfile peri str20 levelid str10 levelname stratum str100 stratum_name str10 dose str10 card_reg ystart yend xstart using RI_CCC_02_periscope_${ANALYSIS_COUNTER}, replace
		
		* Add RI_CCC_pct and periscope to the list of files to delete if user wants to delete all temporary files
		vcqi_global RI_CCC_02_TEMP_DATASETS $RI_CCC_02_TEMP_DATASETS RI_CCC_02_pct_${ANALYSIS_COUNTER} RI_CCC_02_periscope_${ANALYSIS_COUNTER} 
	
		* Loop over doses and days of age and post the cumulative % who were vx'd by that age
		*foreach l in 1 2 3 {  // 3 levels: nation/zone/stratum
		foreach l in $RI_CCC_02_PLOT_LEVELS {
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
					*noi di as text " `d'"
					foreach cr in `cr_loop'  {
						local xmax = ${XMAX_`cr'}
						
						capture drop y
						qui gen y = age_at_`d'_`cr'<=`xmax'
																				
						* weighted p
						svypd y if level`l'id==`k', adjust truncate method($VCQI_CI_METHOD)
						local p = 100 * r(svyp)
											
						* Calculate wtd coverage for this dose
						* (This is the y-value where the periscope ends)
						svypd got_crude_`d'_to_analyze if level`l'id==`k', adjust truncate method($VCQI_CI_METHOD)
					
						post peri ("level`l'") ("`lname'") (`k') ("`stratum_name'") ("`d'") ("`cr'") (`p') (`=100*r(svyp)') (`xmax')
												
					}
				}
			}
			noi di as text ""
		}

		postclose peri	
		
		use RI_CCC_02_periscope_${ANALYSIS_COUNTER}, clear
		compress
		save, replace
		
		* Implement faster method of calculating cumulative pct curves
		
		* Make numerous copies of the dataset in a long format
		
		clear

		set obs 1 
		gen test = 1
		save longform, replace

		foreach cr in `cr_loop'  {
			local xmax = ${XMAX_`cr'}								
			foreach d in `=lower("$RI_DOSE_LIST")' {
				foreach l in $RI_CCC_02_PLOT_LEVELS {
					use "RI_CCC_02_1", clear
					gen card_reg = "`cr'"
					gen dose = "`d'"
					gen level = `l'
					rename level`l'id levelid
					rename level`l'name levelname
					rename age_at_`d'_`cr' days
					keep card_reg dose level levelid levelname psweight days
					gen xmax = `xmax'
					append using longform, force
					save longform, replace
				}
			}
		}
		
		* Now use bysort to do the cumulative calculations all at once
		
		use longform, clear
		drop if test == 1

		bysort level levelid card_reg dose: egen wttotal = total(psweight)
		bysort level levelid card_reg dose: gen bign = _N

		gen got_data = !missing(days)

		bysort level levelid card_reg dose: egen n = total(got_data)

		* We need to keep at least one record if no one has any evidence; put it at day 0
		replace psweight = 0 if n == 0
		replace days = 0 if n == 0

		drop got_data

		keep if !missing(days)

		bysort level levelid card_reg dose days: egen wtsum = total(psweight)

		duplicates drop level levelid card_reg dose days, force

		sort level levelid card_reg dose days

		bysort level levelid card_reg dose: gen wtcum = sum(wtsum)

		gen pctcum = 100 * wtcum / wttotal

		* Add an observation at day xmax for every stratum and dose 

		bysort level levelid card_reg dose: egen daysmax = max(days)
		gen lastday = days == daysmax
		expand 2 if lastday == 1 & days != xmax
		bysort level levelid card_reg dose lastday: gen lastn = _n if lastday == 1
		tab lastn

		replace days = xmax if lastn == 2
		drop lastn lastday daysmax
		
		* Add an observation at day 0 for every stratum and dose that doesn't have one
		
		bysort level levelid card_reg dose: egen daysmin = min(days)
		gen firstday = days == daysmin & daysmin > 0
		expand 2 if firstday == 1
		bysort level levelid card_reg dose firstday: gen firstn = _n if firstday == 1
		replace days = 0 if firstn == 1
		replace pctcum = 0 if firstn == 1

		drop firstn firstday daysmin
		
		* Make the dataset look like the one that used to be generated using loops and post

		rename levelid stratum
		gen levelid = "level" + string(level)
		rename levelname stratum_name
		gen levelname = "nation" if level == 1
		replace levelname = "zone" if level == 2
		replace levelname = "stratum" if level == 3

		compress

		keep  levelid levelname stratum stratum_name dose card_reg days pct n bign 
		order levelid levelname stratum stratum_name dose card_reg days pct n bign 

		sort levelid stratum dose card_reg days
		
		drop if card_reg == "card" & days > $XMAX_card
		drop if card_reg == "register" & days > $XMAX_register
		
		save RI_CCC_02_pct_${ANALYSIS_COUNTER}, replace		
		
		erase longform.dta		
	
		*--------------------------------
		* Make cumulative coverage curves
		*--------------------------------
		noi di as text _col(7) "Make and save cumulative coverage curves..."
		use RI_CCC_02_pct_${ANALYSIS_COUNTER}, clear
	
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
	
		*-----------------------------------------------------------------------
		* Loop over levelid's user specified (e.g., 1=nation, 2=zone, 3=stratum)
		*-----------------------------------------------------------------------
		foreach ll in $RI_CCC_02_PLOT_LEVELS {
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
					if("$RI_CCC_02_XLABELS" != "") {
						local xlabels $RI_CCC_02_XLABELS
					}
					* Add any labels the user wants to include (i.e., 365 days)
					if("$RI_CCC_02_XLABEL_INCLUDE" != "") {
						local xlabels `xlabels' $RI_CCC_02_XLABEL_INCLUDE
						numlist "`: list uniq xlabels'", sort
						local xlabels `=r(numlist)'
					}
					
					* Should the x-labels be alternated?
					if("$RI_CCC_02_XLABEL_ALTERNATE"=="1") {  //1=yes, alternate x-labels
						local xlabels_code xlabel(`xlabels',labsize($RI_CCC_02_XLABEL_SIZE) alternate)
					}
					else {
						local xlabels_code xlabel(`xlabels',labsize($RI_CCC_02_XLABEL_SIZE))
					}
		
					* Format n (to use in subtitle)
		
					* Load up some locals with sample size counts to use later on the plot
					
					preserve
					use "${VCQI_OUTPUT_FOLDER}/RI_CCC_02_${ANALYSIS_COUNTER}", clear

					count if `cr'_with_dates == 1 & level`ll'id == `k' 
					local n_with_`cr'_for_subtitle = r(N)
					
					count if level`ll'id == `k' 
					local bign_for_subtitle = r(N) 
					restore
					
					local n_subtitle = `n_with_`cr'_for_subtitle'
					local width = strlen("`n_subtitle'") 
					if `n_subtitle' > 999    local ++width // adding 1 for comma
					if `n_subtitle' > 999999 local ++width // ditto
					local n_subtitle: di %`width'.0fc `n_subtitle'
					
					local n_total_subtitle = `bign_for_subtitle'
					local width = strlen("`n_total_subtitle'") 
					if `n_total_subtitle' >    999 local ++width  // adding 1 for comma
					if `n_total_subtitle' > 999999 local ++width  // ditto
					local n_total_subtitle: di %`width'.0fc `n_total_subtitle'	
					
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
						
						* Store each curve in a local to use again later in dose family plot
						local curve_`d' (line pct days if dose=="`d'" & levelid=="`l'" & stratum==`k' & card_reg=="`cr'", connect(stairstep) lcolor("${RI_CCC_02_COLOR`aa'}") lpattern("${RI_CCC_02_PATTERN`aa'}") lwidth("${RI_CCC_02_WIDTH`aa'}"))

						local curves `curves' `curve_`d''
						
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
						
						* keep track of aa by dose to use later in periscope code
						local aa_for_dose_`d' `aa'		
					}
					
					*---------------------------
					* Generate periscope syntax
					*---------------------------
					preserve
					use RI_CCC_02_periscope_${ANALYSIS_COUNTER}, clear
					keep if levelid=="`l'" & stratum==`k' & card_reg=="`cr'"
					gsort - ystart
					gen xend = xstart + int(xstart * (${RI_CCC_02_CARD_SHADED_WIDTH_PCT}/100)) 
					gen xstep = (xend - xstart)/(_N+1) 
					gen xrise = xstart + _n * xstep
					local periscope_base (scatteri 100 `=xstart[1]' 100 `=xend[1]', recast(area) bcolor(gs12) plotr(m(zero)) )
					local periscope `periscope_base'
					
					forvalues perii = 1/`=_N' {
						local aap `aa_for_dose_`=dose[`perii']''
						
						* Each periscope consists of three line segments: horzontal, then vertical, then horizontal
												
						local periscope_`=dose[`perii']'
						local periscope_`=dose[`perii']' `periscope_`=dose[`perii']'' (scatteri `=ystart[`perii']' `=xstart[`perii']' `=ystart[`perii']' `=xrise[`perii']', ms(i) connect(l) lcolor("${RI_CCC_02_COLOR`aap'}") lpattern("${RI_CCC_02_PATTERN`aap'}") lwidth("${RI_CCC_02_WIDTH`aap'}"))
						local periscope_`=dose[`perii']' `periscope_`=dose[`perii']'' (scatteri `=ystart[`perii']' `=xrise[`perii']' `=yend[`perii']' `=xrise[`perii']',    ms(i) connect(l) lcolor("${RI_CCC_02_COLOR`aap'}") lpattern("${RI_CCC_02_PATTERN`aap'}") lwidth("${RI_CCC_02_WIDTH`aap'}"))
						local periscope_`=dose[`perii']' `periscope_`=dose[`perii']'' (scatteri `=yend[`perii']' `=xrise[`perii']' `=yend[`perii']' `=xend[`perii']',       ms(i) connect(l) lcolor("${RI_CCC_02_COLOR`aap'}") lpattern("${RI_CCC_02_PATTERN`aap'}") lwidth("${RI_CCC_02_WIDTH`aap'}"))	
						
						* Add the periscope syntax for this dose to the long set of syntax for all doses
						
						local periscope `periscope' `periscope_`=dose[`perii']'' 
						
					}

					* Calculate ymax rounded to next multiple of 20% if user asks to RI_CCC_02_ZOOM_Y_AXIS
					sum ystart
					local ymax = round(r(max),20) // round to nearest 20
					if r(max) > `ymax' local ymax = `ymax' + 20  // round up if the nearest was below r(max)
					local ymax = max(`ymax',20)
					if "$RI_CCC_02_ZOOM_Y_AXIS" != "1" local ymax 100
					
					foreach a in `antigen_family' {
						capture drop infam
						gen infam = strpos(dose,"`a'") > 0
						sum ystart if infam == 1
						local ymax_`a' = round(r(max),20)
						if r(max) > `ymax_`a'' local ymax_`a' = `ymax_`a'' + 20
						local ymax_`a' = max(`ymax_`a'', 20)
						if "$RI_CCC_02_ZOOM_Y_AXIS" != "1" local ymax_`a' 100
					}
						
					restore
					*---------------------------

/*
					* Finally, make plot of all doses
					twoway 	`curves' `periscope' ///
							, title($RI_CCC_02_PLOT_TITLE) subtitle("`stratum_name'") ///
							note("Vertical dashed lines mark scheduled vaccination ages: ${SECOND_PART_OF_NOTE}." ///
							"Denominator is all eligible respondents." ///
							"`n_subtitle' of `n_total_subtitle' respondents had `cr' records with dates." ///
							"Age at vaccination is unknown for respondents represented in the gray shaded region.",span) ///
							xline(`vlines', lcolor($RI_CCC_02_VLINE_COLOR) lpattern($RI_CCC_02_VLINE_PATTERN) lwidth($RI_CCC_02_VLINE_WIDTH)) ///
							`xlabels_code' ///
							ytitle("Cumulative Weighted % Vaccinated" "(According to `cr')") xtitle("Age (days)")  ///
							ylabel(0(20)100,angle(0) gmax) legend(on order(`legend_order') row($RI_CCC_02_NUM_LEGEND_ROWS) span) ///
							name(plot_temp,replace) graphregion(fcolor(${RI_CCC_02_GRAPHREGION_COLOR})) ///
							plotregion(lcolor(black)) xlabel(,grid nogextend ) ylabel(,grid nogextend )
*/

					* Finally, make plot of all doses
					twoway 	`curves'  ///
							, title($RI_CCC_02_PLOT_TITLE) subtitle("`stratum_name'") ///
							note("Vertical dashed lines mark scheduled vaccination ages: ${SECOND_PART_OF_NOTE}." ///
							"Denominator is all eligible respondents." ///
							"`n_subtitle' of `n_total_subtitle' respondents had `cr' records with dates." ,span) ///
							xline(`vlines', lcolor($RI_CCC_02_VLINE_COLOR) lpattern($RI_CCC_02_VLINE_PATTERN) lwidth($RI_CCC_02_VLINE_WIDTH)) ///
							`xlabels_code' ///
							ytitle("Cumulative Weighted % Vaccinated" "(According to `cr')") xtitle("Age (days)")  ///
							ylabel(0(20)`ymax',angle(0) gmax) legend(on order(`legend_order') row($RI_CCC_02_NUM_LEGEND_ROWS) span) ///
							name(plot_temp,replace) graphregion(fcolor(${RI_CCC_02_GRAPHREGION_COLOR})) ///
							plotregion(lcolor(black)) xlabel(,grid nogextend ) ylabel(,grid nogextend )

					
					* Replace any periods (.) in stratum name to underscore (_)
					local sn = subinstr("`stratum_name'",".","_",.)
					
					* Save plot
					graph export "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_02_${ANALYSIS_COUNTER}_`l'_`k'`sn'_alldoses_`cr'.png", width(2000) replace
					if "$SAVE_VCQI_GPH_FILES" == "1" graph save "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_02_${ANALYSIS_COUNTER}_`l'_`k'`sn'_alldoses_`cr'.gph", replace

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
						
						* Start a new reduced local to hold periscope code for this dose family
						local periscope `periscope_base'
						
						foreach d in `doses' {	
							* (1) vertical lines...
							local vlines2 `vlines2' `=`d'_min_age_days'
							
							* (2) x-labels...
							if(`=`d'_min_age_days' != 0) {
								local xlabels2 `xlabels2' `=`d'_min_age_days'
							}
							
							* (3) dose curves...				
							local curves `curves' `curve_`d''
						
							* Add the periscope syntax for this dose to the long set of syntax for all doses
							local periscope `periscope' `periscope_`d''
						
						}
							
						* Add max to xlabels...
						local xlabels2 `xlabels2' ${XMAX_`cr'}
						* Allow user to over-ride automatic x-labels
						if("$RI_CCC_02_XLABELS" != "") {
							local xlabels2 $RI_CCC_02_XLABELS
						}
						* Add any labels the user wants to include (i.e., 365 days)
						if("$RI_CCC_02_XLABEL_INCLUDE" != "") {
							local xlabels2 `xlabels2' $RI_CCC_02_XLABEL_INCLUDE
							numlist "`: list uniq xlabels2'", sort
							local xlabels2 `=r(numlist)'
						}						
						
						* Should the x-labels be alternated?
						if("$RI_CCC_02_XLABEL_ALTERNATE"=="1") {  //1=yes, alternate x-labels
							local xlabels2_code xlabel(`xlabels2',labsize($RI_CCC_02_XLABEL_SIZE) alternate)
						}
						else {
							local xlabels2_code xlabel(`xlabels2',labsize($RI_CCC_02_XLABEL_SIZE))
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
/*
						twoway 	`curves' `periscope' ///
								, title($RI_CCC_02_PLOT_TITLE) subtitle("`stratum_name'") ///
								note("Vertical dashed lines mark scheduled vaccination ages: $SECOND_PART_OF_NOTE2." ///
								"Denominator is all eligible respondents." ///
								"`n_subtitle' of `n_total_subtitle' respondents had `cr' records with dates." ///
								"Age at vaccination is unknown for respondents represented in the gray shaded region.",span) ///
								xline(`vlines2', lcolor($RI_CCC_02_VLINE_COLOR) lpattern($RI_CCC_02_VLINE_PATTERN) lwidth($RI_CCC_02_VLINE_WIDTH)) ///
								`xlabels2_code' ///
								ytitle("Cumulative Weighted % Vaccinated" "(According to `cr')") xtitle("Age (days)")  ///
								ylabel(0(20)100,angle(0) gmax) legend(on order(1 "`a_upper'") row(1) span) ///
								name(plot_temp,replace) graphregion(fcolor(${RI_CCC_02_GRAPHREGION_COLOR})) ///
								plotregion(lcolor(black)) xlabel(,grid nogextend ) ylabel(,grid nogextend )
*/

						twoway 	`curves' ///
								, title($RI_CCC_02_PLOT_TITLE) subtitle("`stratum_name'") ///
								note("Vertical dashed lines mark scheduled vaccination ages: $SECOND_PART_OF_NOTE2." ///
								"Denominator is all eligible respondents." ///
								"`n_subtitle' of `n_total_subtitle' respondents had `cr' records with dates." ,span) ///
								xline(`vlines2', lcolor($RI_CCC_02_VLINE_COLOR) lpattern($RI_CCC_02_VLINE_PATTERN) lwidth($RI_CCC_02_VLINE_WIDTH)) ///
								`xlabels2_code' ///
								ytitle("Cumulative Weighted % Vaccinated" "(According to `cr')") xtitle("Age (days)")  ///
								ylabel(0(20)`ymax_`a'',angle(0) gmax) legend(on order(1 "`a_upper'") row(1) span) ///
								name(plot_temp,replace) graphregion(fcolor(${RI_CCC_02_GRAPHREGION_COLOR})) ///
								plotregion(lcolor(black)) xlabel(,grid nogextend ) ylabel(,grid nogextend )
								
								
						graph export "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_02_${ANALYSIS_COUNTER}_`l'_`k'`sn'_`a'_`cr'.png", width(2000) replace	
						if "$SAVE_VCQI_GPH_FILES" == "1" graph save "${VCQI_OUTPUT_FOLDER}/Plots_CCC/RI_CCC_02_${ANALYSIS_COUNTER}_`l'_`k'`sn'_`a'_`cr'.gph", replace	
						
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
