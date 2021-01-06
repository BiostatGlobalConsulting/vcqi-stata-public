*! RI_QUAL_07B_03DV version 1.01 - Biostat Global Consulting - 2020-03-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-03-10	1.00	Mary Prier		Original version
* 2020-03-24	1.01	Mary Prier		Added if !missing(age_at_visit) & 
*										psweight>0 & !missing(psweight) when
*										generating <got_hypo_`d'> variables
*******************************************************************************

program define RI_QUAL_07B_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07B_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_07B_${ANALYSIS_COUNTER}", clear
		sort respid visitdate 

		gen age_at_visit = visitdate - dob
		label var age_at_visit "Age (in days) of child at visit date"
		drop dob visitdate

		bysort respid: gen num_days_since_last_visit = age_at_visit[_n] - age_at_visit[_n-1]  
		bysort respid: replace num_days_since_last_visit = 0 if _n==1 & !missing(age_at_visit)

		* NOTE: RI_QUAL_07_03DV  loops over $MOV_OUTPUT_DOSE_LIST, but
		*       RI_QUAL_07B_03DV loops over all doses...update if needed
		
		* Single doses
		foreach d in `=lower("$RI_SINGLE_DOSE_LIST")' {
			bysort respid: gen got_hypo_`d' = age_at_visit>=`=`d'_min_age_days' if !missing(age_at_visit) & psweight>0 & !missing(psweight)
			bysort respid: gen got_hypo_`d'_sum = sum(got_hypo_`d')
			replace got_hypo_`d'_sum = 0 if got_hypo_`d'_sum>1 
			replace got_hypo_`d'_sum = . if psweight==0 | missing(psweight)  // the previous line might set _sum=0 for obs with missing or no weight, but we want _sum=. for those cases
			replace got_hypo_`d' = got_hypo_`d'_sum
			drop got_hypo_`d'_sum
		}

		* Multi 2-doses
		foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
			* 1st dose in series...
			bysort respid: gen got_hypo_`d'1 = age_at_visit>=`=`d'1_min_age_days' if !missing(age_at_visit) & psweight>0 & !missing(psweight)		
			bysort respid: gen got_hypo_`d'1_sum = sum(got_hypo_`d'1)
			gen num_days_since_`d'1_temp = num_days_since_last_visit  // make this variable before replacing the _sum variable
			replace num_days_since_`d'1_temp = 0 if got_hypo_`d'1_sum==0 | got_hypo_`d'1_sum==1  // update new variable based on _sum values
			bysort respid: gen num_days_since_`d'1 = sum(num_days_since_`d'1_temp) 
			replace got_hypo_`d'1_sum = 0 if got_hypo_`d'1_sum>1 // now can replace _sum values
			replace got_hypo_`d'1_sum = . if psweight==0 | missing(psweight)  // the previous line might set _sum=0 for obs with missing or no weight, but we want _sum=. for those cases
			replace got_hypo_`d'1 = got_hypo_`d'1_sum
			drop got_hypo_`d'1_sum num_days_since_`d'1_temp
			
			* 2nd dose in series...
			bysort respid: gen got_hypo_`d'2 = age_at_visit>=`=`d'2_min_age_days' & num_days_since_`d'1>=`=`d'2_min_interval_days' if !missing(age_at_visit) & psweight>0 & !missing(psweight)
			bysort respid: gen got_hypo_`d'2_sum = sum(got_hypo_`d'2)
			replace got_hypo_`d'2_sum = 0 if got_hypo_`d'2_sum>1 
			replace got_hypo_`d'2_sum = . if psweight==0 | missing(psweight)  // the previous line might set _sum=0 for obs with missing or no weight, but we want _sum=. for those cases
			replace got_hypo_`d'2 = got_hypo_`d'2_sum
			drop got_hypo_`d'2_sum
			
			drop num_days_since_`d'1
		}

		* Multi 3-doses
		foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {

			* 1st dose in series...
			bysort respid: gen got_hypo_`d'1 = age_at_visit>=`=`d'1_min_age_days' if !missing(age_at_visit) & psweight>0 & !missing(psweight)
			bysort respid: gen got_hypo_`d'1_sum = sum(got_hypo_`d'1)
			gen num_days_since_`d'1_temp = num_days_since_last_visit  // make this variable before replacing the _sum variable
			replace num_days_since_`d'1_temp = 0 if got_hypo_`d'1_sum==0 | got_hypo_`d'1_sum==1  // update new variable based on _sum values
			bysort respid: gen num_days_since_`d'1 = sum(num_days_since_`d'1_temp) 
			replace got_hypo_`d'1_sum = 0 if got_hypo_`d'1_sum>1  // now can replace _sum values
			replace got_hypo_`d'1_sum = . if psweight==0 | missing(psweight)  // the previous line might set _sum=0 for obs with missing or no weight, but we want _sum=. for those cases
			replace got_hypo_`d'1 = got_hypo_`d'1_sum
			drop got_hypo_`d'1_sum num_days_since_`d'1_temp
			
			* 2nd dose in series...
			bysort respid: gen got_hypo_`d'2 = age_at_visit>=`=`d'2_min_age_days' & num_days_since_`d'1>=`=`d'2_min_interval_days' if !missing(age_at_visit) & psweight>0 & !missing(psweight)
			bysort respid: gen got_hypo_`d'2_sum = sum(got_hypo_`d'2)
			gen num_days_since_`d'2_temp = num_days_since_last_visit  // make this variable before replacing the _sum variable
			replace num_days_since_`d'2_temp = 0 if got_hypo_`d'2_sum==0 | got_hypo_`d'2_sum==1  // update new variable based on _sum values
			bysort respid: gen num_days_since_`d'2 = sum(num_days_since_`d'2_temp) 
			replace got_hypo_`d'2_sum = 0 if got_hypo_`d'2_sum>1  // now can replace _sum values
			replace got_hypo_`d'2_sum = . if psweight==0 | missing(psweight)  // the previous line might set _sum=0 for obs with missing or no weight, but we want _sum=. for those cases
			replace got_hypo_`d'2 = got_hypo_`d'2_sum
			drop got_hypo_`d'2_sum num_days_since_`d'2_temp
			
			* 3rd dose in series...
			bysort respid: gen got_hypo_`d'3 = age_at_visit>=`=`d'3_min_age_days' & num_days_since_`d'2>=`=`d'3_min_interval_days' if !missing(age_at_visit) & psweight>0 & !missing(psweight)
			bysort respid: gen got_hypo_`d'3_sum = sum(got_hypo_`d'3)
			replace got_hypo_`d'3_sum = 0 if got_hypo_`d'3_sum>1 
			replace got_hypo_`d'3_sum = . if psweight==0 | missing(psweight)  // the previous line might set _sum=0 for obs with missing or no weight, but we want _sum=. for those cases
			replace got_hypo_`d'3 = got_hypo_`d'3_sum
			drop got_hypo_`d'3_sum
			
			drop num_days_since_`d'1 num_days_since_`d'2
		}
		
		* Save dataset in long form
		save RI_QUAL_07B_${ANALYSIS_COUNTER}_LONG, replace
		vcqi_global RI_QUAL_07B_TEMP_DATASETS $RI_QUAL_07B_TEMP_DATASETS RI_QUAL_07B_${ANALYSIS_COUNTER}_LONG
		
		* Now save dataset with 1 row per respid
		* NOTE: RI_QUAL_07_03DV  loops over $MOV_OUTPUT_DOSE_LIST, but
		*       RI_QUAL_07B_03DV loops over all doses...update if needed
		foreach d in $RI_DOSE_LIST {
			bysort respid: egen got_hypo_`d'_max=max(got_hypo_`d')
			drop got_hypo_`d'
			rename got_hypo_`d'_max got_hypo_`d'
			label var got_hypo_`d' "Received `d' (1=yes; 0=no)"			
		}
		bysort respid: keep if _n==1

		save RI_QUAL_07B_${ANALYSIS_COUNTER}, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
