*! RI_QUAL_05_03DV version 1.02 - Biostat Global Consulting - 2017-02-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added missing var labels for the below variables:
*										short_interval_`d'_`t'
* 2017-02-01	1.02	Dale Rhoda		Trim the labels
********************************************************************************

program define RI_QUAL_05_03DV

	local oldvcp $VCP
	global VCP RI_QUAL_05_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_05_${ANALYSIS_COUNTER}", clear

		local d `=lower("$RI_QUAL_05_DOSE_NAME")' 
		local t `=int($RI_QUAL_05_INTERVAL_THRESHOLD)'

		local abcard c
		local abregister r
		
		foreach s in card register {
			gen short_interval_`d'_`t'_`ab`s'' = (`s'_interval_days < `t') ///
												 if !missing(`s'_interval_days)
			label variable short_interval_`d'_`t'_`ab`s'' "`s' interval for `d' are < `t' days"
		}
		
		if $RI_RECORDS_NOT_SOUGHT {
			gen short_interval_`d'_`t' = short_interval_`d'_`t'_c
			label variable short_interval_`d'_`t' "Interval `d' < `t' days - RI_RECORDS_NOT_SOUGHT"
		}
		
		if $RI_RECORDS_SOUGHT_FOR_ALL {
			gen     short_interval_`d'_`t' = short_interval_`d'_`t'_c
			replace short_interval_`d'_`t' = short_interval_`d'_`t'_r if ///
				missing(short_interval_`d'_`t') | short_interval_`d'_`t'_r == 0
			label variable short_interval_`d'_`t' "Interval `d' < `t' days - RI_RECORDS_SOUGHT_FOR_ALL"
		}
		
		if $RI_RECORDS_SOUGHT_IF_NO_CARD {
			gen     short_interval_`d'_`t' = short_interval_`d'_`t'_c
			replace short_interval_`d'_`t' = short_interval_`d'_`t'_r if no_card == 1
			label variable short_interval_`d'_`t' "Interval `d' < `t' days - RI_RECORDS_SOUGHT_IF_NO_CARD"
		}

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end



	
