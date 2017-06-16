*! RI_QUAL_12_03DV version 1.03 - Biostat Global Consulting - 2017-02-03
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		added var labels
* 2017-01-31	1.02	Dale Rhoda		Reworked to be one row per child
* 2017-02-03	1.03	Dale Rhoda		Switched to _DOSE_PAIR_LIST
*******************************************************************************

program define RI_QUAL_12_03DV

	local oldvcp $VCP
	global VCP RI_QUAL_12_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_12_${ANALYSIS_COUNTER}", clear
		
		local abcard c
		local abregister r
		
		* Loop over the dose pairs and generate three variables for each:
		* Is the interval from the card greater than the threshold?
		* Is the interval from the register greater than the threshold?
		* Is the interval to analyze greater than the threshold?
		
		local j 1
		local i 1
		while `i' <= `=wordcount("$RI_QUAL_12_THRESHOLD_LIST")' {
			local thresh `=word("$RI_QUAL_12_THRESHOLD_LIST",`i')'
			local d1 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
			local ++j
			local d2 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
			local ++j
		
			foreach s in card register {
				gen igt_`d1'_`d2'_`thresh'_`ab`s'' = ///
					(`d2'_`s'_date - `d1'_`s'_date > `thresh') ///
					if !missing(`d2'_`s'_date) & !missing(`d1'_`s'_date)
				label variable igt_`d1'_`d2'_`thresh'_`ab`s'' "Days b/t `d1' & `d2' > `thresh' - on `s'"
			}

			* Some notes for the user's manual:
			*
			* Depending on what the user specifies for a threshold, it might
			* be a good thing for the interval to exceed the threshold 
			* (i.e., that might mean it's a valid interval) or it might be
			* a bad thing (i.e., the interval is 365 days).  In coding the
			* variable for analysis, we assume that it is a bad thing for the
			* interval to exceed the threshold...and so if 
			* $RI_RECORDS_SOUGHT_FOR_ALL then we record a 0 if either the 
			* card or register indicates a zero
			*
			* Hence this indicator should NOT be used to establish whether 
			* the second dose in the interval is valid...it should rather be
			* used to estimate the proportion of times the interval is 
			* unacceptably long.
			
			if $RI_RECORDS_NOT_SOUGHT {
				gen igt_`d1'_`d2'_`thresh' = igt_`d1'_`d2'_`thresh'_c
				label variable igt_`d1'_`d2'_`thresh' "Days b/t `d1' & `d2' > `thresh' - RI_RECORDS_NOT_SOUGHT"

			}
			if $RI_RECORDS_SOUGHT_FOR_ALL {
				gen     igt_`d1'_`d2'_`thresh' = igt_`d1'_`d2'_`thresh'_c
				replace igt_`d1'_`d2'_`thresh' = igt_`d1'_`d2'_`thresh'_r if ///
				missing(igt_`d1'_`d2'_`thresh')| igt_`d1'_`d2'_`thresh'_r == 0
				label variable igt_`d1'_`d2'_`thresh' "Days b/t `d1' & `d2' > `thresh' - RI_RECORDS_SOUGHT_FOR_ALL"
				
			}
			if $RI_RECORDS_SOUGHT_IF_NO_CARD {
				gen     igt_`d1'_`d2'_`thresh' = igt_`d1'_`d2'_`thresh'_c
				replace igt_`d1'_`d2'_`thresh' = igt_`d1'_`d2'_`thresh'_r if no_card == 1
				label variable igt_`d1'_`d2'_`thresh' "Days b/t `d1' & `d2' > `thresh' - RI_RECORDS_SOUGHT_IF_NO_CARD"

			}
			
			local ++i
		}

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end



	
