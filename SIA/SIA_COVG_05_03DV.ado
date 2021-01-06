*! SIA_COVG_05_03DV version 1.00 - Biostat Global Consulting - 2018-10-25
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original copied from RI_COVG_05
*******************************************************************************

program define SIA_COVG_05_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_05_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_05_${ANALYSIS_COUNTER}", clear
			
		bysort clusterid: gen cluster_n = _N
		bysort clusterid: egen cluster_sumwt = total(psweight)		
		bysort clusterid: egen got_sia_count = total(got_sia_dose)
			
		bysort clusterid: egen dropthis_sia = total(psweight) if got_sia_dose == 1

		* populate those results to all rows in the cluster
		bysort clusterid: egen got_sia_sumwt = max(dropthis_sia)
			
		gen got_sia_pct = 100 * got_sia_sumwt / cluster_sumwt
			
		replace got_sia_pct = 0 if got_sia_count == 0
			
		label variable cluster_n "Respondents in cluster"
		label variable got_sia_count "Respondents got sia in cluster"
		label variable got_sia_sumwt "Sum of weights for those who got sia in cluster"
		label variable cluster_sumwt "Sum of weights for all respondents in cluster"
		label variable got_sia_pct "Weighted pct who got sia in cluster"
			
		drop dropthis_sia
		
		bysort clusterid: keep if _n == 1
		
		*keep level1id level2id level3id stratumid stratum_name clusterid cluster_name cluster_n cluster_sumwt got*_count got*sumwt got*pct
		
		sort stratumid clusterid

		save, replace
		
		* Copy the file to one with _database in the name, so it can be saved
		* if the user requests that databases be saved
		if "$VCQI_GENERATE_DATABASES" == "1" {
			save "${VCQI_OUTPUT_FOLDER}/SIA_COVG_05_${ANALYSIS_COUNTER}_database", replace
			global VCQI_DATABASES $VCQI_DATABASES SIA_COVG_05_${ANALYSIS_COUNTER}_database
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
