*! add_HH_vars_to_opplot_datasets version 1.01 - Biostat Global Consulting - 2017-02-21
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-21	1.01	Dale Rhoda		Sort before saving
*******************************************************************************

program define add_HH_vars_to_opplot_datasets

	local oldvcp $VCP
	global VCP add_HH_vars_to_opplot_datasets
	vcqi_log_comment $VCP 5 Flow "Starting"	
	
	quietly {
	
		local exitflag 0 
		
		*noi di "Adding stratum and cluster names to organ pipe plot data files"
		
		cd "$VCQI_OUTPUT_FOLDER"
		local folder_exists `: dir . dirs "Plots_OP"'
		if "`folder_exists'" != "" {
			cd "$VCQI_OUTPUT_FOLDER/Plots_OP"

			* Build a list of opplot datasets
			local dslist :  dir . files "*opplot*.dta"

			foreach d of local dslist {
			
				local surveytype
				if upper(substr("`d'",1,2)) == "RI"  local surveytype RI
				if upper(substr("`d'",1,2)) == "TT"  local surveytype TT
				if upper(substr("`d'",1,3)) == "SIA" local surveytype SIA
				
				if "`surveytype'" == "" {
					di as error "The opplot data file name does not start with RI, TT or SIA so this program does not know where to find the HH info."
					di as error "`d'"
					vcqi_log_comment $VCP 1 Error  "The opplot data file name does not start with RI, TT or SIA so this program does not know where to find the HH info."
					local exitflag 1
				}
				else {
					use "`d'", clear
					capture drop `surveytype'01
					capture drop `surveytype'02
					capture drop `surveytype'03
					capture drop `surveytype'04
					capture drop _merge
					merge 1:m clusterid using "$VCQI_OUTPUT_FOLDER/`surveytype'_with_ids", keepusing(`surveytype'01 `surveytype'03)
					keep if _merge == 1 | _merge == 3
					drop _merge
					duplicates drop
					capture drop HH01
					capture drop HH03
					rename `surveytype'01 HH01
					rename `surveytype'03 HH03
					merge 1:1 HH01 HH03 using "$VCQI_DATA_FOLDER/$VCQI_CM_DATASET", keepusing(HH02 HH04) 
					keep if inlist(_merge,1,3)
					drop _merge
					duplicates drop
					order HH02, after(stratum)
					order HH03 HH04, after(clusterid)
					label variable clusterid "VCQI cluster ID (may differ from data cluster ID)"
					label variable HH03 "Cluster ID from dataset (may differ from VCQI cluster ID)"
					label variable HH04 "Cluster name from dataset"
					sort barorder
					save, replace
				}
			}
		}
		cd "$VCQI_OUTPUT_FOLDER"
	}
	
	* Note that this program is called from within vcqi_halt_immediately so there's no need to call that program here
	if `exitflag' == 1 vcqi_global VCQI_ERROR 1
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end