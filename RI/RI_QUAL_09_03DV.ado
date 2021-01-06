*! RI_QUAL_09_03DV version 1.05 - Biostat Global Consulting - 2019-11-10
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added missing var labels
* 2017-03-21	1.02	Dale Rhoda		Set anydose outcomes to missing if
*										total_elig_visits is missing 
*										(because missing DOB or dose dates so
*										MOV flags are not calculable)
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2019-11-09	1.04	Dale Rhoda		Introduced MOV_OUTPUT_DOSE_LIST
* 2019-11-10	1.05	Dale Rhoda		Add _`vc' to names of DVs
*******************************************************************************

program define RI_QUAL_09_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_09_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		local vc  `=lower("$RI_QUAL_09_VALID_OR_CRUDE")'

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_09_${ANALYSIS_COUNTER}", clear

		gen doses_with_mov_`vc' = 0
		label variable doses_with_mov_`vc' "Number of doses with MOVs"
		
		gen doses_with_uncor_mov_`vc' = 0
		label variable doses_with_uncor_mov_`vc' "Number of uncorrected MOVs"

		gen doses_with_cor_mov_`vc' = 0
		label variable doses_with_cor_mov_`vc' "Number of corrected MOVs"

		foreach d in $MOV_OUTPUT_DOSE_LIST {
		
			noi di _continue _col(5) "`d' "
			
			gen child_had_mov_`d'_`vc' = flag_had_mov_`d'_`vc' if !missing(total_elig_`d'_`vc') & total_elig_`d'_`vc' > 0 
			label variable child_had_mov_`d'_`vc' "Child had a MOV on dose `d'"
			
			gen child_had_uncor_mov_`d'_`vc' = flag_uncor_mov_`d'_`vc' if child_had_mov_`d'_`vc' == 1
			label variable child_had_uncor_mov_`d'_`vc' "Child had an uncorrected MOV on dose `d'"
			
			gen child_had_cor_mov_`d'_`vc' = flag_cor_mov_`d'_`vc' if child_had_mov_`d'_`vc' == 1
			label variable child_had_cor_mov_`d'_`vc' "Child had a corrected MOV on dose `d'"

			replace doses_with_mov_`vc'       = doses_with_mov_`vc'       + 1 if child_had_mov_`d'_`vc' == 1
			replace doses_with_uncor_mov_`vc' = doses_with_uncor_mov_`vc' + 1 if child_had_uncor_mov_`d'_`vc' == 1
			replace doses_with_cor_mov_`vc'   = doses_with_cor_mov_`vc'   + 1 if child_had_cor_mov_`d'_`vc' == 1
		}
		
		noi di as text _col(5) "Totals..."

		* had 1+ MOVs over all doses
		gen child_had_mov_`vc' = doses_with_mov_`vc' > 0
		replace child_had_mov_`vc' = .  if missing(total_elig_visits_`vc') | total_elig_visits_`vc' == 0
		label variable child_had_mov_`vc' "Child had 1+ MOVs over all doses"
		
		* had only uncorrected MOVs
		gen child_had_only_uncor_mov_`vc' = doses_with_mov_`vc' > 0 & doses_with_cor_mov_`vc' == 0
		replace child_had_only_uncor_mov_`vc' = .  if missing(total_elig_visits_`vc') | total_elig_visits_`vc' == 0
		label variable child_had_only_uncor_mov_`vc' "Child only had uncorrected MOVs"
		
		* had only corrected MOVs
		gen child_had_only_cor_mov_`vc'   = doses_with_mov_`vc' > 0 & doses_with_uncor_mov_`vc' == 0
		replace child_had_only_cor_mov_`vc' = .  if missing(total_elig_visits_`vc') | total_elig_visits_`vc' == 0
		label variable child_had_only_cor_mov_`vc' "Child only had corrected MOVs"

		* had both uncorrected and corrected MOVs
		gen child_had_cor_n_uncor_mov_`vc' = doses_with_cor_mov_`vc' > 0 & doses_with_uncor_mov_`vc' > 0
		replace child_had_cor_n_uncor_mov_`vc' = .  if missing(total_elig_visits_`vc') | total_elig_visits_`vc' == 0
		label variable child_had_cor_n_uncor_mov_`vc' "Child had both corrected and uncorrected MOVs"
		
		save, replace
	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
