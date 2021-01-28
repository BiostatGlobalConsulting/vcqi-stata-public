*! RI_CIC_02_06PO version 1.08 - Biostat Global Consulting - 2021-01-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-23	1.01	Mary Prier		Added code to delete Plot_CIC folder
*                                       if it exists &
*                                       Updated filename to substitute "_" for
*                                        "." if "." was in stratum_name
* 2019-06-20	1.02	Mary Prier		Added 0 to local xlabels, so 0 is labeled 
* 											on the x-axis 
* 2019-09-13	1.03	Mary Prier		Changed "CIC_pct" to "RI_CIC_pct"; added
*										code for temporary files to be deleted if
*  										requested by the user
* 2020-04-09	1.04	Dale Rhoda		Move to a weighted calculation
*                                       and add shading and periscopes at the 
*                                       far right 
* 2020-04-17	1.05	Dale Rhoda		Added GPH save
* 2020-04-22	1.06	Dale Rhoda		Drop data beyond XMAX
* 2020-12-02	1.07	Dale Rhoda		Based on feedback from colleagues, 
*                                       suppress displaying the periscopes at
*                                       the right side of the figure; for now
*                                       we retain the code that generates the
*                                       periscope syntax, but do not execute it
* 2021-01-26	1.08	Dale Rhoda		Change hardcoded _1 to _$ANALYSIS_COUNTER
*******************************************************************************

program define RI_CIC_02_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CIC_02_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {		
		noi di as text _col(5) "Cumulative interval curves (CIC)..."
	
		* Check if folder Plots_CIC exists
		capture confirm file "${VCQI_OUTPUT_FOLDER}/Plots_CIC/nul"
		if (_rc==0 & "$REFRESHED_CIC_FOLDER_ALREADY" != "1") {  // _rc will be 0 if folder exists
			* Delete folder & files
			*shell rmdir "${VCQI_OUTPUT_FOLDER}/Plots_CIC/" /s /q
			vcqi_global REFRESHED_CIC_FOLDER_ALREADY 1
		}
		* Make new (and empty) folder
		capture mkdir "${VCQI_OUTPUT_FOLDER}/Plots_CIC/"
	
		use "${VCQI_OUTPUT_FOLDER}/RI_CIC_02_${ANALYSIS_COUNTER}", clear

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
		* Make dataset for CICs
		*----------------------
		* Open postfile to store the proportion of respondents who had rec'd dose on or by given day
		capture postclose pfile
		*postfile pfile str20 levelid str10 levelname stratum str100 stratum_name str100 dose_interval_group str10 card_reg interval_days pct n bign using RI_CIC_02_pct_${ANALYSIS_COUNTER}, replace

		* Open postfile to store periscope start and end y-values and the start x-values
		capture postclose peri
		postfile peri  str20 levelid str10 levelname stratum str100 stratum_name str100 dose_interval_group str10 card_reg ystart yend xstart using RI_CIC_02_periscope_${ANALYSIS_COUNTER}, replace
	
		* Add RI_CIC_pct to the list of files to delete if user wants to delete all temporary files
		vcqi_global RI_CIC_02_TEMP_DATASETS $RI_CIC_02_TEMP_DATASETS RI_CIC_02_pct_${ANALYSIS_COUNTER} RI_CIC_02_periscope_${ANALYSIS_COUNTER} 
		
		* Loop over doses and days of age and post the cumulative % who were vx'd by that age
		foreach l in $RI_CIC_02_PLOT_LEVELS {  // 3 levels: nation/zone/stratum
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
				/*
				* Get name of stratum (right now RI_with_ids.dta does not have zone names saved as a variable)
				if(`l'==3) {
					capture drop temp
					qui gen temp = HH02 if level`l'==`k'
					qui replace temp = temp[_n-1] if missing(temp)  // this fills in all the missing values below the chunk of filled cells
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
				
				* For each interval variable, count how many respondents got next dose with interval <=j
				foreach d of varlist $dose_interval_groups {
					di as text "   `d'"
				
					* Parse variable if data from card or register
					local first_underscore = strpos("`d'","_")
					local cr = substr("`d'",1,`=`first_underscore'-1')
					
					local xmax = ${XMAX_`cr'}

					capture drop y
					qui gen y = `d'<=`xmax'
					
					* weighted p
					svypd y if level`l'id==`k' , adjust truncate method($VCQI_CI_METHOD)
					local p = 100 * r(svyp)						
				
					* Calculate wtd coverage for the latter dose in the pair
					* (This is the y-value where the periscope ends)
					svypd got_crude_${latter_`=subinstr("`d'","_interval_days","",1)'}_to_analyze if level`l'id==`k', adjust truncate method($VCQI_CI_METHOD)
				
					post peri ("level`l'") ("`lname'") (`k') ("`stratum_name'") ("`d'") ("`cr'") (`p') (`=100*r(svyp)') (`xmax')					
				}
				
			}
			noi di as text ""
		}

		postclose peri		
		
		use RI_CIC_02_periscope_${ANALYSIS_COUNTER}, clear
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
			foreach d in $dose_interval_groups {
				foreach l in $RI_CIC_02_PLOT_LEVELS {
					use "RI_CIC_02_${ANALYSIS_COUNTER}", clear
					gen card_reg = "`cr'"
					gen dose_interval_group = "`d'"
					gen level = `l'
					rename level`l'id levelid
					rename level`l'name levelname
					rename `d' interval_days
					keep card_reg dose_interval_group level levelid levelname psweight interval_days
					gen xmax = `xmax'
					append using longform, force
					save longform, replace
				}
			}
		}
		
		* Now use bysort to do the cumulative calculations all at once
		
		use longform, clear
		drop if test == 1

		bysort level levelid card_reg dose_interval_group: egen wttotal = total(psweight)
		bysort level levelid card_reg dose_interval_group: gen bign = _N

		gen got_data = !missing(interval_days)

		bysort level levelid card_reg dose_interval_group: egen n = total(got_data)

		* We need to keep at least one record if no one has any evidence; put it at day 0
		replace psweight = 0 if n == 0
		replace interval_days = 0 if n == 0

		drop got_data

		keep if !missing(interval_days)

		bysort level levelid card_reg dose_interval_group interval_days: egen wtsum = total(psweight)

		duplicates drop level levelid card_reg dose_interval_group interval_days, force

		sort level levelid card_reg dose_interval_group interval_days

		bysort level levelid card_reg dose_interval_group: gen wtcum = sum(wtsum)

		gen pctcum = 100 * wtcum / wttotal

		* Add an observation at day xmax for every stratum and dose_interval_group 

		bysort level levelid card_reg dose_interval_group: egen daysmax = max(interval_days)
		gen lastday = interval_days == daysmax
		expand 2 if lastday == 1 & interval_days != xmax
		bysort level levelid card_reg dose_interval_group lastday: gen lastn = _n if lastday == 1
		tab lastn

		replace interval_days = xmax if lastn == 2
		drop lastn lastday daysmax
		
		* Add an observation at day 0 for every stratum and dose_interval_group that doesn't have one
		
		bysort level levelid card_reg dose_interval_group: egen daysmin = min(interval_days)
		gen firstday = interval_days == daysmin & daysmin > 0
		expand 2 if firstday == 1
		bysort level levelid card_reg dose_interval_group firstday: gen firstn = _n if firstday == 1
		replace interval_days = 0 if firstn == 1
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

		keep  levelid levelname stratum stratum_name dose_interval_group card_reg interval_days pct n bign 
		order levelid levelname stratum stratum_name dose_interval_group card_reg interval_days pct n bign 

		sort levelid stratum dose_interval_group card_reg interval_days

		drop if card_reg == "card" & interval_days > $XMAX_card
		drop if card_reg == "register" & interval_days > $XMAX_register
		
		save RI_CIC_02_pct_${ANALYSIS_COUNTER}, replace		
		
		erase longform.dta		
			
		*--------------------------------
		* Make cumulative interval curves
		*--------------------------------
		noi di as text _col(7) "Make and save cumulative interval curves..."
		use RI_CIC_02_pct_${ANALYSIS_COUNTER}, clear
			
		*-----------------------------------------------------------------------
		* Loop over levelid's user specified (e.g., 1=nation, 2=zone, 3=stratum)
		*-----------------------------------------------------------------------
		foreach ll in $RI_CIC_02_PLOT_LEVELS {
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
					
					*----------------------
					* Plot by dose pair
					*----------------------
					foreach dp in $dose_pair {  // loop over dose pairs (e.g., penta1_2, penta2_3)
							
						* Parse dose pair
						local first_underscore = strpos("`dp'","_")
						local dose_name = substr("`dp'",1,`=`first_underscore'-1')
						local dose_num1 = substr("`dp'",`=strlen("`dp'")-2',1)
						local dose_num2 = substr("`dp'",strlen("`dp'"),1)
						
						* Figure out if <dose>_min_interval_days = <dose#+1>_min_age_days-<dose#>_min_age_days
						*  (i.e., if AFRO schedule or PAHO schedule...will there be 1 or 2 vertical lines when child was eligible for dose)
						local schedule_age_diff = `dose_name'`dose_num2'_min_age_days - `dose_name'`dose_num1'_min_age_days
					
						* Vertical lines (representing vaccination schedule) (will be 1 or 2 lines on plot)
						* Note: Making 2 locals in case user defines two different colors/patterns/widths...then need 2 xline() in twoway command
						* Also, write a note corresponding to the vertical lines
						local vlines1 `=`dose_name'`dose_num2'_min_interval_days' 
						local vlines2 `schedule_age_diff'
						if(`vlines1'!=`vlines2') {
							local xlines xline(`vlines1', lcolor($RI_CIC_02_VLINE_COLOR1) lpattern($RI_CIC_02_VLINE_PATTERN1) lwidth($RI_CIC_02_VLINE_WIDTH1)) xline(`vlines2', lcolor($RI_CIC_02_VLINE_COLOR2) lpattern($RI_CIC_02_VLINE_PATTERN2) lwidth($RI_CIC_02_VLINE_WIDTH2))
							local note1 "Vertical lines mark (1) scheduled interval age and (2) the difference between the minimum age for each dose."
						}
						else {
							local xlines xline(`vlines1', lcolor($RI_CIC_02_VLINE_COLOR1) lpattern($RI_CIC_02_VLINE_PATTERN1) lwidth($RI_CIC_02_VLINE_WIDTH1))
							local note1 "Vertical line marks scheduled interval age."
						}
						
						* Make list of x-labels (usually coincides with vaccination schedule & xmax, but can involve other x-values if user specifies so)
						local xlabels 0 `vlines1' `vlines2' ${XMAX_`cr'}
						if("$RI_CIC_02_XLABELS" != "") {
							local xlabels $RI_CIC_02_XLABELS
						}
						
						numlist "`: list uniq xlabels'", sort
						local xlabels `=r(numlist)'						
						
						* Should the x-labels be alternated?
						if("$RI_CIC_02_XLABEL_ALTERNATE"=="1") {  //1=yes, alternate x-labels
							local xlabels_code xlabel(`xlabels',labsize($RI_CIC_02_XLABEL_SIZE) alternate)
						}
						else {
							local xlabels_code xlabel(`xlabels',labsize($RI_CIC_02_XLABEL_SIZE))
						}
			
						* Format n (to use in the subtitle)
						
						* Count persons with data for each outcome - for plot notes later
						
						preserve
						use "${VCQI_OUTPUT_FOLDER}/RI_CIC_02_${ANALYSIS_COUNTER}", clear

						count if !missing(`cr'_interval_days_`dp') & level`ll'id== `k' 
						local n_subtitle = r(N)
												
						count if level`ll'id==`k' 
						local bign_for_subtitle = r(N)
						restore
		
						local width = strlen("`n_subtitle'") 
						if `n_subtitle' > 999    local ++width // adding 1 for comma
						if `n_subtitle' > 999999 local ++width // ditto
						local n_subtitle: di %`width'.0fc `n_subtitle'

						local n_total_subtitle = `bign_for_subtitle'
						local width = strlen("`n_total_subtitle'") 
						if `n_total_subtitle' >    999 local ++width // adding 1 for comma
						if `n_total_subtitle' > 999999 local ++width // ditto
						local n_total_subtitle: di %`width'.0fc `n_total_subtitle'					
								
						* Make local of curve to plot
						local curves (line pct interval_days if dose_interval_group=="`cr'_interval_days_`dp'" & levelid=="`l'" & stratum==`k' & card_reg=="`cr'", connect(stairstep) lcolor("${RI_CIC_02_COLOR}") lpattern("${RI_CIC_02_PATTERN}") lwidth("${RI_CIC_02_WIDTH}"))
					
						*---------------------------
						* Generate periscope syntax
						*---------------------------
						preserve
						use RI_CIC_02_periscope_${ANALYSIS_COUNTER}, clear
						keep if levelid=="`l'" & stratum==`k' & card_reg=="`cr'" & dose_interval_group == "`cr'_interval_days_`dp'"
						gsort - ystart
						gen xend = xstart + int(xstart * (${RI_CIC_02_CARD_SHADED_WIDTH_PCT}/100)) 
						gen xstep = (xend - xstart)/(_N+1) 
						gen xrise = xstart + _n * xstep
						local periscope (scatteri 100 `=xstart[1]' 100 `=xend[1]', recast(area) bcolor(gs12) plotr(m(zero)) )
						forvalues perii = 1/`=_N' {
							
							* Each periscope consists of three line segments: horzontal, then veritcal, then horizontal
													
							local periscope `periscope' (scatteri `=ystart[`perii']' `=xstart[`perii']' `=ystart[`perii']' `=xrise[`perii']', ms(i) connect(l) lcolor("${RI_CIC_02_COLOR}") lpattern("${RI_CIC_02_PATTERN}") lwidth("${RI_CIC_02_WIDTH}"))
							local periscope `periscope' (scatteri `=ystart[`perii']' `=xrise[`perii']' `=yend[`perii']' `=xrise[`perii']',    ms(i) connect(l) lcolor("${RI_CIC_02_COLOR}") lpattern("${RI_CIC_02_PATTERN}") lwidth("${RI_CIC_02_WIDTH}"))
							local periscope `periscope' (scatteri `=yend[`perii']' `=xrise[`perii']' `=yend[`perii']' `=xend[`perii']',       ms(i) connect(l) lcolor("${RI_CIC_02_COLOR}") lpattern("${RI_CIC_02_PATTERN}") lwidth("${RI_CIC_02_WIDTH}"))

						}
						
						* Calculate ymax rounded to next multiple of 20% if user asks to RI_CCC_02_ZOOM_Y_AXIS
						sum ystart
						local ymax = round(r(max),20) // round to nearest 20
						if r(max) > `ymax' local ymax = `ymax' + 20  // round up if the nearest was below r(max)
						local ymax = max(`ymax',20)
						if "$RI_CIC_02_ZOOM_Y_AXIS" != "1" local ymax 100
						
						restore
						*---------------------------
					
						* Make plot
/*
						twoway 	`curves' `periscope' ///
								, title($RI_CIC_02_PLOT_TITLE) subtitle("`stratum_name'" "`=upper("`dose_name'")'`dose_num1' & `=upper("`dose_name'")'`dose_num2' Interval", size(medium)) ///
								note("`note1'" "Denominator is all eligible respondents." ///
								"`n_subtitle' of `n_total_subtitle' respondents had `cr' dates for both doses." ///
								"Days between doses is unknown for respondents represented in the gray shaded region.",span) ///
								`xlines' ///
								`xlabels_code' ///
								ytitle("Cumulative Weighted % Vaccinated" "(According to `cr')") xtitle("Days Between Doses")  ///
								ylabel(0(20)100,angle(0) gmax) ///
								name(plot_temp,replace) graphregion(fcolor($RI_CIC_02_GRAPHREGION_COLOR)) ///
								legend(off)
*/
								
						twoway 	`curves'  ///
								, title($RI_CIC_02_PLOT_TITLE) subtitle("`stratum_name'" "`=upper("`dose_name'")'`dose_num1' & `=upper("`dose_name'")'`dose_num2' Interval", size(medium)) ///
								note("`note1'" "Denominator is all eligible respondents." ///
								"`n_subtitle' of `n_total_subtitle' respondents had `cr' dates for both doses." ,span) ///
								`xlines' ///
								`xlabels_code' ///
								ytitle("Cumulative Weighted % Vaccinated" "(According to `cr')") xtitle("Days Between Doses")  ///
								ylabel(0(20)`ymax',angle(0) gmax) ///
								name(plot_temp,replace) graphregion(fcolor($RI_CIC_02_GRAPHREGION_COLOR)) ///
								legend(off)
						
						* Replace any periods (.) in stratum name to underscore (_)
						local sn = subinstr("`stratum_name'",".","_",.)
					
						graph export "${VCQI_OUTPUT_FOLDER}/Plots_CIC/RI_CIC_02_${ANALYSIS_COUNTER}_`l'_`k'`sn'_`dp'_`cr'.png", width(2000) replace	
						if "$SAVE_VCQI_GPH_FILES" == "1" graph save "${VCQI_OUTPUT_FOLDER}/Plots_CIC/RI_CIC_02_${ANALYSIS_COUNTER}_`l'_`k'`sn'_`dp'_`cr'.gph", replace
						
						vcqi_log_comment $VCP 3 Comment "Cumulative interval curve was created and exported for `l'_`k'`sn'_`dp'_`cr'."

						graph drop _all
						
					}  // end loop over antigen_family specific plot "a"
				
				}  // end loop over card/register loop
				
			}  // end loop over `k'
			
		} // end loop over levelid "l"
			
	} // close quietly brace


	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
