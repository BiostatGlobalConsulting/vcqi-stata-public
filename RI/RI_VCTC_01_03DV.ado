*! RI_VCTC_01_03DV version 1.03 - Biostat Global Consulting - 2021-01-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-09-24	1.00	Dale Rhoda		Original version
* 2021-01-19	1.01	Dale Rhoda		Updated data values in the 
*                                       'Timing Unknown' row
* 2021-01-22	1.02	Dale Rhoda		Change calculation from <= to <
* 2021-01-24	1.03	Dale Rhoda		Small edit to Excel column label
********************************************************************************

program define RI_VCTC_01_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_VCTC_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	if $VCQI_CHECK_INSTEAD_OF_RUN != 1 {
	    
		quietly {
			
			capture erase "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}_TO.dta" // empty out the tabulation dataset
			
			foreach lvl in $RI_VCTC_01_LEVELS {
				
				use "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}", clear
				
				levelsof level`lvl'id, local(llist)
				
				foreach l in `llist' {
				
					use "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}", clear
					
					keep if level`lvl'id == `l'

					* Establish stratum text names to use in labels or filenames
					local name = level`lvl'name[1]
					local namens = subinstr("`name'"," ","_",.)
				
					vcqi_global RI_VCTC_01_TEMP_DATASETS $RI_VCTC_01_TEMP_DATASETS RI_VCTC_01_${ANALYSIS_COUNTER}_`lvl'_`l'

					* Calculate the maximum number of tiles across all doses
					global max_ntiles = $TIMELY_N_DTS
					foreach d in $TIMELY_CD_LIST {
						if ${TIMELY_CD_`d'_NTILES} > $max_ntiles global max_ntiles ${TIMELY_CD_`d'_NTILES}
					}

					* Set dd_<DOSE> to 1 for "default doses"
					foreach d in $TIMELY_DOSE_ORDER {
						if !index("$TIMELY_CD_LIST", "`d'") global dd_`d' 1
						else global dd_`d' 0
					}

					* Start with empty matrix
					capture matrix drop tplot
					matrix tplot = J($TIMELY_N_DOSES, `= $max_ntiles + 2', .)

					local i 0
					foreach d in `=lower("$TIMELY_DOSE_ORDER")' {
						local ++i
						local D = upper("`d'") // upper case dose
						local cd_index 0
						
						* Curate the age variable
						gen timely_age_at_`d' = age_at_`d'_card
						
						if $RI_RECORDS_NOT_SOUGHT replace timely_age_at_`d' = min(age_at_`d'_card, age_at_`d'_register)
						
						* Make missing if not eligible
						replace timely_age_at_`d' = . if got_crude_`d'_to_analyze == .
							
						if ${dd_`D'} == 1 {                            // use default tiles
							forvalues j = 1/`=${TIMELY_N_DTS}-1' {
								capture drop timely_y 
								gen timely_y = timely_age_at_`d' < `d'_min_age_days + ${TIMELY_DT_UB_`j'}
								if `d'_min_age_days == 0 & `j' == 1 replace timely_y = 0 // if it's a birth dose, it cannot be early
								svypd timely_y, adjust truncate
								matrix tplot[`i',`j'] = 100 * r(svyp)
							}
						}
						else {                                          // use customized dose tiles
							forvalues j = 1/`=${TIMELY_CD_`D'_NTILES}-1' {
								capture drop timely_y
								gen timely_y = timely_age_at_`d' < `d'_min_age_days + ${TIMELY_CD_`D'_UB_`j'}
								svypd timely_y, adjust truncate
								matrix tplot[`i', `j'] = 100 * r(svyp)
							}
						}
						
						* The final tile goes all the way up to the level of crude coverage
						svypd got_crude_`d'_to_analyze, adjust truncate method($VCQI_CI_METHOD)
						if ${dd_`D'} == 1 matrix tplot[`i',${TIMELY_N_DTS}]         = 100 * r(svyp)
						else              matrix tplot[`i',${TIMELY_CD_`D'_NTILES}] = 100 * r(svyp)

						* Save the CI in the last two columns
						local j = $max_ntiles
						matrix tplot[`i',`=`j'+1'] = 100 * r(lb_alpha)
						matrix tplot[`i',`=`j'+2'] = 100 * r(ub_alpha)
					}
					
					************************************
					*
					* Make a dataset for graphic output
					*
					clear
					svmat tplot
					gen y = _n
					gen dose = ""
					
					local flist 
					* If the user did not specify y coordinates, use integers from 1 up to the number of doses
					if "$TIMELY_Y_COORDS" == "" {
					    numlist "1(1)`=wordcount("$TIMELY_DOSE_ORDER")'"
						global TIMELY_Y_COORDS = r(numlist)
					}
					* Add the y-coordinates to the dataset and specify the value label for the y-axis
					forvalues ii = 1 /`=wordcount("$TIMELY_DOSE_ORDER")' {
						local yy = word("$TIMELY_Y_COORDS" , `ii')
						global TIMELY_YVAL_`ii' = `yy'
						local dd = word("$TIMELY_DOSE_ORDER", `ii')
						replace y = `yy' in `ii'
						local flist `flist' `yy' "`dd'"
						replace dose = "`dd'" in `ii'
					}
					label define y `flist'
					label values y y
										
					notes: "Vaccination Coverage and Timeliness Chart Inputs for level `lvl' stratum `l' named `name'."

					save "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}_tplot_`lvl'_`l'", replace
					
					vcqi_global RI_VCTC_01_TEMP_DATASETS $RI_VCTC_01_TEMP_DATASETS RI_VCTC_01_${ANALYSIS_COUNTER}_tplot_`lvl'_`l'

					************************************
					*
					* Make a dataset for tabular output
					*
					
					matrix tplott = tplot'
					matrix colnames tplott = `=lower("$TIMELY_DOSE_ORDER")'
					clear
					svmat tplott, names(col)
					drop in `=_N' // drop CI
					drop in `=_N' // drop CI
					
					foreach d in `=lower("$TIMELY_DOSE_ORDER")' {
						
						rename `d' `d'_tile_top_pct
						
						local D = upper("`d'")
						gen `d'_label = ""
						gen `d'_agespan = ""
						gen `d'_tile_height = `d'_tile_top_pct in 1 // populate the first row here; others below
						
						order `d'_tile_height `d'_agespan `d'_label , after(`d'_tile_top_pct)

						label variable `d'_label         "Tile label for `D'"
						label variable `d'_agespan       "Tile span of days for `D'"
						label variable `d'_tile_top_pct  "Cum pct for `D'"
						label variable `d'_tile_height   "Pct width of tile for `D'"

						if ${dd_`D'} == 1 {
							forvalues j = 1/`=${TIMELY_N_DTS}-1' {
								replace `d'_label = "${TIMELY_DT_LABEL_`j'}" in `j'
								if `j' == 1 replace `d'_agespan = "Age < `=min($VCQI_RI_MAX_AGE_OF_ELIGIBILITY, ${TIMELY_DT_UB_`j'})' days" in `j'
								if `j'  > 1 & "${TIMELY_DT_UB_`j'}" != "" replace `d'_agespan = "Age < `=min($VCQI_RI_MAX_AGE_OF_ELIGIBILITY, `=`d'_min_age_days + ${TIMELY_DT_UB_`j'}')' days" in `j'
								if `j'  > 1 & !missing(`d'_tile_top_pct[`j']) replace `d'_tile_height = (`d'_tile_top_pct[`j'] - `d'_tile_top_pct[`=`j'-1']) in `j'
							}
							local j ${TIMELY_N_DTS}
							replace `d'_tile_height = (`d'_tile_top_pct[`j'] - `d'_tile_top_pct[`=`j'-1']) in `j'
							replace `d'_agespan = "Timing unknown" in `j'
							replace `d'_label   = "All ages" in `j'
						}
						else {
							forvalues j = 1/`=${TIMELY_CD_`D'_NTILES}-1' {
								replace `d'_label = "${TIMELY_CD_`D'_LABEL_`j'}" in `j'
								if `j' == 1 replace `d'_agespan = "Age < `=min($VCQI_RI_MAX_AGE_OF_ELIGIBILITY, ${TIMELY_CD_`D'_UB_`j'})' days" in `j'
								if `j'  > 1 & "${TIMELY_CD_`D'_UB_`j'}" != "" replace `d'_agespan = "Age < `=min($VCQI_RI_MAX_AGE_OF_ELIGIBILITY, ${TIMELY_CD_`D'_UB_`j'})' days" in `j'
								if `j'  > 1 & !missing(`d'_tile_top_pct[`j']) replace `d'_tile_height = (`d'_tile_top_pct[`j'] - `d'_tile_top_pct[`=`j'-1']) in `j'
							}
							local j ${TIMELY_CD_`D'_NTILES}
							replace `d'_tile_height = (`d'_tile_top_pct[`j'] - `d'_tile_top_pct[`=`j'-1']) in `j'
							replace `d'_agespan = "Timing unknown" in `j'
							replace `d'_label   = "All ages" in `j'							
						}

					}
					
					
					foreach v of varlist *tile_top_pct *_tile_height {
						replace `v' = round(`v', 0.1)  // round pct figures to a single decimal point
					}				
					
					gen level = `lvl'
					
					gen levelid = `l'
					
					gen stratum_name = "`name'"
					
					gen order = _n
					
					label variable level "Level"
					label variable levelid "ID"
					label variable stratum_name "Stratum name"
					label variable order "Chart tile order (left to right)"
					
					order level levelid stratum_name order, first
					
					notes : "Vaccination Coverage and Timeliness Tabular data for level `lvl' stratum `l' named `name'."

					capture append using "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}_TO", force
					
					gsort level levelid order
					
					save "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}_TO", replace
					
				}
					
			}

			vcqi_global RI_VCTC_01_TEMP_DATASETS $RI_VCTC_01_TEMP_DATASETS RI_VCTC_01_${ANALYSIS_COUNTER}_TO
			
			use  "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}_TO", clear
			
			notes : "Data are sorted by level and levelid and by bar category order."
			
			save, replace

		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
