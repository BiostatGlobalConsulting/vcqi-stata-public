*! RI_COVG_05_03DV version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-07-06	1.01	Dale Rhoda		Fix got_`d'_count calculation and
*										fixed percent when count == 0
* 2017-01-31	1.02	Dale Rhoda		Check global to see whether to save
*										database or not
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_05_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_05_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_05_${ANALYSIS_COUNTER}", clear
			
		bysort clusterid: gen cluster_n = _N
		bysort clusterid: egen cluster_sumwt = total(psweight)

		foreach d in `=lower("$RI_COVG_05_DOSE_LIST")' {
		
			noi di _continue _col(5) "`d' "
		
			bysort clusterid: egen got_`d'_count = total(got_crude_`d'_to_analyze)
			
			bysort clusterid: egen dropthis_`d' = total(psweight) if got_crude_`d'_to_analyze == 1
			* populate those results to all rows in the cluster
			bysort clusterid: egen got_`d'_sumwt = max(dropthis_`d')
			
			gen got_`d'_pct = 100 * got_`d'_sumwt / cluster_sumwt
			
			replace got_`d'_pct = 0 if got_`d'_count == 0
			
			label variable cluster_n "Respondents in cluster"
			label variable got_`d'_count "Respondents got `d' in cluster"
			label variable got_`d'_sumwt "Sum of weights for those who got `d' in cluster"
			label variable cluster_sumwt "Sum of weights for all respondents in cluster"
			label variable got_`d'_pct "Weighted pct who got `d' in cluster"
			
			drop dropthis_`d'
		}
		
		noi di as text ""
		
		bysort clusterid: keep if _n == 1
		
		*keep level1id level2id level3id stratumid stratum_name clusterid cluster_name cluster_n cluster_sumwt got*_count got*sumwt got*pct
		
		sort stratumid clusterid

		save, replace
		
		* Copy the file to one with _database in the name, so it can be saved
		* if the user requests that databases be saved
		if "$VCQI_GENERATE_DATABASES" == "1" {
			save "${VCQI_OUTPUT_FOLDER}/RI_COVG_05_${ANALYSIS_COUNTER}_database", replace
			global VCQI_DATABASES $VCQI_DATABASES RI_COVG_05_${ANALYSIS_COUNTER}_database
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
