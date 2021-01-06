*! RI_VCTC_01_06PO version 1.00 - Biostat Global Consulting - 2020-09-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-09-24	1.00	Dale Rhoda		Original version
*******************************************************************************

program define RI_VCTC_01_06PO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_VCTC_01_06PO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
			set tracedepth 2
			*set trace on
	if $VCQI_CHECK_INSTEAD_OF_RUN != 1 {

		quietly {

			foreach lvl in $RI_VCTC_01_LEVELS {
				
				use "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}", clear // need to repeat this because of the loop

				levelsof level`lvl'id, local(llist)
				
				foreach l in `llist' {
					
					use "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}", clear // need to repeat this because of the loop
					
					keep if level`lvl'id == `l'
							
					graph drop _all
					
					* Establish stratum text names to use in labels or filenames
					local name = strtrim(stritrim(level`lvl'name[1]))
					local namens = subinstr("`name'"," ","_",.)
					
					* Populate a local macro named `textit' with the bars of text that should appear across the top of the chart
					*
					* (The user can request seeing the estimated coverage, sample size, number of respondents with HBRs, effective sample size, design effect or intracluster correlation coefficient.)
					*
					* The order in which these appear is controlled by the TIMELY_TEXTBAR_X coordinates, which should be set by the user in the control program.
					local textit
					foreach e in $TIMELY_TEXTBAR_ORDER {
						local i 0
						foreach d in `=lower("$TIMELY_DOSE_ORDER")' {
							
							local ++i
							
							if "`e'" == "COVG" {
								svypd got_crude_`d'_to_analyze, adjust truncate
								local textit `textit' text( ${TIMELY_YVAL_`i'} ${TIMELY_TEXTBAR_X_`e'} "`=string(`=100*r(svyp)',"%4.${TIMELY_TEXTBAR_COVG_DEC_DIGITS}f")'" , placement(c) size(${TIMELY_TEXTBAR_SIZE_`e'}) color(${TIMELY_TEXTBAR_COLOR_`e'}))
							}
							
							if "`e'" == "N" {
								count if inlist(got_crude_`d'_to_analyze,0,1)
								local textit `textit' text(${TIMELY_YVAL_`i'} ${TIMELY_TEXTBAR_X_`e'} "`=string(`=r(N)',"%5.0fc")'" , placement(c) size(${TIMELY_TEXTBAR_SIZE_`e'}) color(${TIMELY_TEXTBAR_COLOR_`e'}))
							}
							
							if "`e'" == "NHBR" {
								count if $TIMELY_HBR_LINE_VARIABLE == 1
								local textit `textit' text(${TIMELY_YVAL_`i'} ${TIMELY_TEXTBAR_X_`e'} "`=string(`=r(N)',"%5.0fc")'" , placement(c) size(${TIMELY_TEXTBAR_SIZE_`e'}) color(${TIMELY_TEXTBAR_COLOR_`e'}))		
							}

							if "`e'" == "NEFF" {
								svypd got_crude_`d'_to_analyze, adjust truncate
								local textit `textit' text(${TIMELY_YVAL_`i'} ${TIMELY_TEXTBAR_X_`e'} "`=string(`=r(neff)',"%5.0fc")'" , placement(c) size(${TIMELY_TEXTBAR_SIZE_`e'}) color(${TIMELY_TEXTBAR_COLOR_`e'}))
							}

							if "`e'" == "DEFF" {
								svypd got_crude_`d'_to_analyze, adjust truncate
								local textit `textit' text(${TIMELY_YVAL_`i'} ${TIMELY_TEXTBAR_X_`e'} "`=string(`=r(deff)',"%6.1f")'" , placement(c) size(${TIMELY_TEXTBAR_SIZE_`e'}) color(${TIMELY_TEXTBAR_COLOR_`e'}))		
							}
							
							if "`e'" == "ICC" {
								calcicc got_crude_`d'_to_analyze clusterid
								local textit `textit' text(${TIMELY_YVAL_`i'} ${TIMELY_TEXTBAR_X_`e'} "`=string(`=r(anova_icc)',"%7.${TIMELY_TEXTBAR_ICC_DEC_DIGITS}f")'" , placement(c) size(${TIMELY_TEXTBAR_SIZE_`e'}) color(${TIMELY_TEXTBAR_COLOR_`e'}))
							}
						}
						local textit `textit' text(`=${TIMELY_YVAL_`=${TIMELY_N_DOSES}'} + $TIMELY_TEXTBAR_LABEL_Y_SPACE' ${TIMELY_TEXTBAR_X_`e'}  "${TIMELY_TEXTBAR_LABEL_`e'}", placement(c) size(${TIMELY_TEXTBAR_SIZE_`e'}) color(${TIMELY_TEXTBAR_COLOR_`e'}))
					}

					local plotit twoway (scatter y y , ms(i))  // first plot to get the y-labels right using the valuelabel option

					
					* Estimate the % of respondents with HBRs if the user has asked for it
					if "$TIMELY_HBR_LINE_PLOT" == "1" {
						svypd $TIMELY_HBR_LINE_VARIABLE, adjust truncate  // where to plot HBR line
						local x_hbr = 100 * r(svyp)
						local textit `textit' text(0.05 `=`x_hbr'+1' "$TIMELY_HBR_LINE_LABEL", placement(3) size($TIMELY_TEXTBAR_SIZE_N) color(gs8))
						
						* Plot the line on the figure
						local plotit `plotit' (scatteri 0 `x_hbr' `=${TIMELY_YVAL_`=${TIMELY_N_DOSES}'} + $TIMELY_BARWIDTH' `x_hbr', ms(i) connect(direct) lw($TIMELY_HBR_LINE_WIDTH) lc($TIMELY_HBR_LINE_COLOR) lp($TIMELY_HBR_LINE_PATTERN) )
						local twoway_order 3
					}
					else {
						local twoway_order 2
					}
										
					* Establish a postfile for holding the legend labels; populate that dataset at the same time
					* as generating the twoway plotit macro
					capture postclose handle
					postfile handle sequence order str255 label str255 dose using timely_legend_info, replace

					* Loop over the doses and build the set of twoway bar, rbar, and rcap commands that will make the stacked bar and confidence interval
					local i 0
					foreach D in `=upper("$TIMELY_DOSE_ORDER")' {
						local ++i
						
						if ${dd_`D'} == 1 {  // code for doses that use the DEFAULT tile definitions
							local plotit `plotit' (bar tplot1 y if y == ${TIMELY_YVAL_`i'}, horizontal fc($TIMELY_DT_COLOR_1) lc($TIMELY_DT_LCOLOR_1) lw($TIMELY_DT_LWIDTH_1) barwidth($TIMELY_BARWIDTH))
							if "$TIMELY_DT_LEGEND_ORDER_1" != "" post handle (`twoway_order') ($TIMELY_DT_LEGEND_ORDER_1) ("$TIMELY_DT_LEGEND_LABEL_1") ("DEFAULT")
							local ++twoway_order
							forvalues j = 2/$TIMELY_N_DTS {
								local plotit `plotit' (rbar tplot`=`j'-1' tplot`j' y if y == ${TIMELY_YVAL_`i'}, horizontal fc(${TIMELY_DT_COLOR_`j'}) lc(${TIMELY_DT_LCOLOR_`j'}) lw(${TIMELY_DT_LWIDTH_`j'}) barwidth($TIMELY_BARWIDTH))
								if "${TIMELY_DT_LEGEND_ORDER_`j'}" != "" post handle (`twoway_order') (${TIMELY_DT_LEGEND_ORDER_`j'}) ("${TIMELY_DT_LEGEND_LABEL_`j'}") ("DEFAULT")
								local ++twoway_order
							}
							local plotit `plotit' (rcap tplot`=$max_ntiles +1' tplot`=$max_ntiles +2' y if y == ${TIMELY_YVAL_`i'} , horizontal lc($TIMELY_CI_LCOLOR) lw($TIMELY_CI_LWIDTH) msize($TIMELY_CI_MSIZE)) // confidence interval
							local ++twoway_order
						}
						
						if ${dd_`D'} != 1 {  // code for doses that use CUSTOM tile definitions
							local plotit `plotit' (bar tplot1 y if y == ${TIMELY_YVAL_`i'}, horizontal fc(${TIMELY_CD_`D'_COLOR_1}) lc(${TIMELY_CD_`D'_LCOLOR_1}) lw(${TIMELY_CD_`D'_LWIDTH_1}) barwidth($TIMELY_BARWIDTH))
							if "{TIMELY_CD_`D'_LEGEND_ORDER_1}" != "" post handle (`twoway_order') (${TIMELY_CD_`D'_LEGEND_ORDER_1}) ("${TIMELY_CD_`D'_LEGEND_LABEL_1}") ("`D'")
							local ++twoway_order
							forvalues j = 2/`=${TIMELY_CD_`D'_NTILES}' {
								local plotit `plotit' (rbar tplot`=`j'-1' tplot`j' y if y == ${TIMELY_YVAL_`i'}, horizontal fc(${TIMELY_CD_`D'_COLOR_`j'}) lc(${TIMELY_CD_`D'_LCOLOR_`j'}) lw(${TIMELY_CD_`D'_LWIDTH_`j'}) barwidth($TIMELY_BARWIDTH))
								if "${TIMELY_CD_`D'_LEGEND_ORDER_`j'}" != "" post handle (`twoway_order') (${TIMELY_CD_`D'_LEGEND_ORDER_`j'}) ("${TIMELY_CD_`D'_LEGEND_LABEL_`j'}") ("`D'")
								local ++twoway_order
							}
							local plotit `plotit' 	  (rcap tplot`=$max_ntiles +1' tplot`=$max_ntiles +2' y if y == ${TIMELY_YVAL_`i'} , horizontal lc($TIMELY_CI_LCOLOR) lw($TIMELY_CI_LWIDTH) msize($TIMELY_CI_MSIZE)) // confidence interval
							local ++twoway_order
						}
					}

					* Take a moment to sort the legend order dataset and build the `legend' macro to use later as part of the twoway options
					capture postclose handle

					use timely_legend_info, clear
					compress
					save, replace
					duplicates drop order label, force
					drop if missing(order)
					gsort order
					local legend_order order(
					forvalues i = 1/`=_N' {
						local legend_order `legend_order' `=sequence[`i']' "`=label[`i']'"
					}
					local legend_order `legend_order' )
					local legend legend( `legend_order' pos(6) symplacement(left)  $TIMELY_LEGEND_OPTIONS )
					
					*capture erase timely_legend_info.dta
					
					* Pack the plot options into a local macro
					* The user can override these choices or specify any additional options, using the TIMELY_TWOWAY_OPTIONS global
					local plotoptions  ylabel( $TIMELY_Y_COORDS , valuelabel angle(0) labsize($TIMELY_YLABEL_SIZE) labcolor($TIMELY_YLABEL_COLOR) nogrid) 
					
						local plotoptions `plotoptions' xscale(range(0 $TIMELY_XSCALE_MAX) titlegap(*5)) xlabel(0(20)100, angle(0) labsize($TIMELY_XLABEL_SIZE))  xtitle("")
						
						if "$TIMELY_YLINE_LIST" != "" local plotoptions `plotoptions' yline($TIMELY_YLINE_LIST, lc($TIMELY_YLINE_LCOLOR) lw($TIMELY_YLINE_LWIDTH))
						
						local plotoptions `plotoptions' xtitle(Estimated Coverage (%), size($TIMELY_XLABEL_SIZE)) ytitle(" ")
						
						local plotoptions `plotoptions' title("Vaccination Coverage & Timeliness: `name'", span size(medium) place(w)) subtitle("${TIMELY_SUBTITLE} ", size(small) place(w))
						
						if  `"$TIMELY_NOTE"' != `""' local plotoptions `plotoptions' note(`"$TIMELY_NOTE"' , size($TIMELY_NOTE_SIZE) $TIMELY_NOTE_SPAN)
						
						local plotoptions `plotoptions' graphregion(fcolor(white)) plotregion(fcolor(white) lcolor(white))
						
						local plotoptions `plotoptions' `legend' `textit'
						
						local plotoptions `plotoptions' $TIMELY_TWOWAY_OPTIONS
					
					* Now it is time to bring the "tile" y-coordinates into memory so the `plotit' code will run correctly
					use "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}_tplot_`lvl'_`l'", clear
					
					graph set window fontface "Lato"

					`plotit' , `plotoptions'
					
					if $SAVE_VCQI_GPH_FILES graph save "Plots_VCTC/VCTC_01_${ANALYSIS_COUNTER}_level_`lvl'_id_`l'_`namens'${TIMELY_PLOTNAME_STUB}.gph" , replace

					graph export "Plots_VCTC/VCTC_01_${ANALYSIS_COUNTER}_level_`lvl'_id_`l'_`namens'${TIMELY_PLOTNAME_STUB}.png" , width(2000) replace
					
					vcqi_log_comment $VCP 3 Comment "Vaccination coverage and timeliness chart was created and exported for level `lvl' ID `l'."
					
					*graph drop _all
					
				}
			}
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
