*! RI_CIC_01_06PO version 1.04 - Biostat Global Consulting - 2020-04-14
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
* 2020-04-14	1.04	Dale Rhoda		Updated n to be consistent with DV03
*******************************************************************************

program define RI_CIC_01_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CIC_01_06PO
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
	
		use "${VCQI_OUTPUT_FOLDER}/RI_CIC_01_${ANALYSIS_COUNTER}", clear

				
		* Count persons with data for each outcome - for plot notes later
		foreach d in $dose_interval_groups {
			count if !missing(`d')
			local n_`=subinstr("`d'","interval_days_","",.)' = r(N)
		}
		
		count
		local bign_for_subtitle = r(N)
		
		*----------------------
		* Make dataset for CICs
		*----------------------
		* Open postfile to store the proportion of respondents who had rec'd dose on or by given day
		capture postclose pfile
		postfile pfile str20 levelid str10 levelname stratum str100 stratum_name str100 dose_interval_group str10 card_reg interval_days pct n using RI_CIC_pct, replace

		* Add RI_CIC_pct to the list of files to delete if user wants to delete all temporary files
		vcqi_global RI_CIC_01_TEMP_DATASETS $RI_CIC_01_TEMP_DATASETS RI_CIC_pct
		
		* Loop over doses and days of age and post the cumulative % who were vx'd by that age
		foreach l in $RI_CIC_01_PLOT_LEVELS {  // 3 levels: nation/zone/stratum
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
					forvalues j = 0/`xmax' {					
						capture drop y
						qui gen y = `d'<=`j' if level`l'id==`k' & !missing(`d')
						qui count if y==1
						local numer = r(N)
						qui count if level`l'id==`k' & !missing(`d')
						local denom = r(N)
						local p = `numer' / `denom' * 100
						post pfile ("level`l'") ("`lname'") (`k') ("`stratum_name'") ("`d'") ("`cr'") (`j') (`p') (`r(N)')
					}
				}
				
			}
			noi di as text ""
		}

		postclose pfile
		
		use RI_CIC_pct, clear
		compress
		save RI_CIC_pct, replace			

		*--------------------------------
		* Make cumulative interval curves
		*--------------------------------
		noi di as text _col(7) "Make and save cumulative interval curves..."
		use RI_CIC_pct, clear
	
		* Figure out if looping over card and/or register
		if ($RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1) {
			local cr_loop card register
		}
		else {
			local cr_loop card
		}
		 
		* Update local cr_loop if $CARD_REGISTER is defined in CIC_globals.do
		if ("$RI_CIC_01_CARD_REGISTER" != "") {
			local cr_loop $RI_CIC_01_CARD_REGISTER
		}
		
		
	
		*-----------------------------------------------------------------------
		* Loop over levelid's user specified (e.g., 1=nation, 2=zone, 3=stratum)
		*-----------------------------------------------------------------------
		foreach ll in $RI_CIC_01_PLOT_LEVELS {
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
							local xlines xline(`vlines1', lcolor($RI_CIC_01_VLINE_COLOR1) lpattern($RI_CIC_01_VLINE_PATTERN1) lwidth($RI_CIC_01_VLINE_WIDTH1)) xline(`vlines2', lcolor($RI_CIC_01_VLINE_COLOR2) lpattern($RI_CIC_01_VLINE_PATTERN2) lwidth($RI_CIC_01_VLINE_WIDTH2))
							local note1 "Vertical lines mark (1) scheduled interval age and (2) the difference between the minimum age for each dose"
						}
						else {
							local xlines xline(`vlines1', lcolor($RI_CIC_01_VLINE_COLOR1) lpattern($RI_CIC_01_VLINE_PATTERN1) lwidth($RI_CIC_01_VLINE_WIDTH1))
							local note1 "Vertical line marks scheduled interval age"
						}
						
						* Make list of x-labels (usually coincides with vaccination schedule & xmax, but can involve other x-values if user specifies so)
						local xlabels 0 `vlines1' `vlines2' ${XMAX_`cr'}
						if("$RI_CIC_01_XLABELS" != "") {
							local xlabels $RI_CIC_01_XLABELS
						}
						
						* Should the x-labels be alternated?
						if("$RI_CIC_01_XLABEL_ALTERNATE"=="1") {  //1=yes, alternate x-labels
							local xlabels_code xlabel(`xlabels',labsize($RI_CIC_01_XLABEL_SIZE) alternate)
						}
						else {
							local xlabels_code xlabel(`xlabels',labsize($RI_CIC_01_XLABEL_SIZE))
						}
			
						* Format n (to use in the subtitle)
						local n_subtitle = `n_`cr'_`dp''  
						local width = strlen("`n_subtitle'") 
						if `n_subtitle' > 999    local ++width // adding 1 for comma
						if `n_subtitle' > 999999 local ++width // ditto
						local n_subtitle: di %`width'.0fc `n_subtitle'
								
						* Make local of curve to plot
						local curves (line pct interval_days if dose_interval_group=="`cr'_interval_days_`dp'" & levelid=="`l'" & stratum==`k' & card_reg=="`cr'", lcolor("${RI_CIC_01_COLOR}") lpattern("${RI_CIC_01_PATTERN}") lwidth("${RI_CIC_01_WIDTH}"))
		
						* Make plot
						twoway 	`curves' ///
								, title($RI_CIC_01_PLOT_TITLE) subtitle("`stratum_name'" "`=upper("`dose_name'")'`dose_num1' & `=upper("`dose_name'")'`dose_num2' Interval", size(medium)) ///
								note("`note1'" "Denominator is number of respondents who had dates for both doses" "(n=`n_subtitle')",span) ///
								`xlines' ///
								`xlabels_code' ///
								ytitle("Cumulative Unweighted % Vaccinated" "(According to `cr')") xtitle("Days Between Doses")  ///
								ylabel(0(20)100,angle(0) gmax) ///
								name(plot_temp,replace) graphregion(fcolor($RI_CIC_01_GRAPHREGION_COLOR))	
						
						* Replace any periods (.) in stratum name to underscore (_)
						local sn = subinstr("`stratum_name'",".","_",.)
					
						graph export "${VCQI_OUTPUT_FOLDER}/Plots_CIC/RI_CIC_01_${ANALYSIS_COUNTER}_`l'_`k'`sn'_`dp'_`cr'.png", width(2000) replace	
						
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
