*! RI_QUAL_04_03DV version 1.02 - Biostat Global Consulting - 2016-09-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added missing var label to early_`d'_`t'_`s'
* 2016-09-13	1.02	Dale Rhoda		Made label consistent with RI_QUAL_13
*******************************************************************************

program define RI_QUAL_04_03DV

	local oldvcp $VCP
	global VCP RI_QUAL_04_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_04_${ANALYSIS_COUNTER}", clear
		
		local d `=lower("$RI_QUAL_04_DOSE_NAME")'
		local t `=int($RI_QUAL_04_AGE_THRESHOLD)'

		foreach s in card register {
			gen early_`d'_`t'_`s' = ///
				((`d'_`s'_date - dob_for_valid_dose_calculations) < `t') if ///
				!missing(dob_for_valid_dose_calculations) & ///
				!missing(`d'_`s'_date)
			label variable early_`d'_`t'_`s' "Received `d' before age `t' days on `s'"
		}
		
		if $RI_RECORDS_NOT_SOUGHT {
			gen early_`d'_`t' = early_`d'_`t'_card
		}
		if $RI_RECORDS_SOUGHT_FOR_ALL {
			gen     early_`d'_`t' = early_`d'_`t'_card 
			replace early_`d'_`t' = early_`d'_`t'_register  if ///
				missing(early_`d'_`t') | early_`d'_`t'_register == 0
		}
		if $RI_RECORDS_SOUGHT_IF_NO_CARD {
			gen early_`d'_`t'     = early_`d'_`t'_card
			replace early_`d'_`t' = early_`d'_`t'_register if no_card == 1
		}

		replace early_`d'_`t' = . if missing(dob_for_valid_dose_calculations)
			
		label variable early_`d'_`t'  "Received `=upper("`d'")' Before Age `t' Days"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
