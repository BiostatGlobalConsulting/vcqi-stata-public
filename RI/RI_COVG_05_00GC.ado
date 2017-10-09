*! RI_COVG_05_00GC version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_05_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_05_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	foreach g in RI_COVG_05_DOSE_LIST RI_COVG_05_THRESHOLD_TYPE RI_COVG_05_THRESHOLD RI_COVG_05_TABLES RI_DOSE_LIST {
		vcqi_log_global `g'
	}
	
	local exitflag 0
	
	*Confirm global RI_COVG_05_DOSE_LIST is defined
	if "$RI_COVG_05_DOSE_LIST"=="" {
		di as error "You must define global variable RI_COVG_05_DOSE_LIST."
		vcqi_log_comment $VCP 1 Error "You must define global variable RI_COVG_05_DOSE_LIST."
		local exitflag 1
	}
		
	*Confirm dose names in global RI_COVG_05_DOSE_LIST are found in global RI_DOSE_LIST 
	local match 0
	foreach g in `=lower("$RI_COVG_05_DOSE_LIST")' {
		foreach d in `=lower("$RI_DOSE_LIST")' {
			if "`d'" == "`g'" local ++match  
		}
	}
	if `match'!= `=wordcount("$RI_COVG_05_DOSE_LIST")' {
		di as error "All dose names for global variable RI_COVG_05_DOSE_LIST are not included in the RI_DOSE_LIST provided."
		vcqi_log_comment $VCP 1 Error  "All dose name for global variable RI_COVG_05_DOSE_LIST are not included in the RI_DOSE_LIST provided."
		local exitflag 1
	}
	
	*Confirm global RI_COVG_05_THRESHOLD_TYPE is defined and has the appropriate values
	if !inlist("`=upper("$RI_COVG_05_THRESHOLD_TYPE")'","COUNT","PERCENT"){
		di as error "RI_COVG_05_THRESHOLD_TYPE must be either COUNT or PERCENT.  The current value is $RI_COVG_05_THRESHOLD_TYPE."
		vcqi_log_comment $VCP 1 Error "RI_COVG_05_THRESHOLD_TYPE must be either COUNT or PERCENT.  The current value is $RI_COVG_05_THRESHOLD_TYPE."
		local exitflag 1
	}
	
	*Confirm global RI_COVG_05_THRESHOLD is defined with the appropriate values based on RI_COVG_05_THRESHOLD_TYPE
	capture confirm number $RI_COVG_05_THRESHOLD
	if _rc !=0 {
		di as error "Global variable RI_COVG_05_THRESHOLD must be a numeric value"
		vcqi_log_comment $VCP 1 Error "Global variable RI_COVG_05_THRESHOLD must be a numeric value"
		local exitflag 1
	}

	
	if "$RI_COVG_05_THRESHOLD_TYPE"== "COUNT" {
		if $RI_COVG_05_THRESHOLD < 0 {
			di as error "RI_COVG_05_THRESHOLD must be a number >= zero because COUNT was selected as the RI_COVG_05_THRESHOLD_TYPE"	
			vcqi_log_comment $VCP 1 Error "RI_COVG_05_THRESHOLD must be a number >= zero because COUNT was selected as the RI_COVG_05_THRESHOLD_TYPE"
			local exitflag 1
		}
	}
	if "$RI_COVG_05_THRESHOLD_TYPE"== "PERCENT" {
		if $RI_COVG_05_THRESHOLD < 0 | $RI_COVG_05_THRESHOLD > 100 {
			di as error "RI_COVG_05_THRESHOLD must be between 0 and 100 (inclusive) because PERCENT was selected as the RI_COVG_05_THRESHOLD_TYPE"
			vcqi_log_comment $VCP 1 Error "RI_COVG_05_THRESHOLD must be between 0 and 100 (inclusive) because PERCENT was selected as the RI_COVG_05_THRESHOLD_TYPE"
			local exitflag 1
		}
	}
	
	*Confirm global RI_COVG_05_TABLES is defined and has the appropriate values
	if !inlist("`=upper("$RI_COVG_05_TABLES")'","ALL_CLUSTERS","ONLY_LOW_CLUSTERS") {
		di as error "RI_COVG_05_TABLES must be either ALL_CLUSTERS or ONLY_LOW_CLUSTERS.  The current value is $RI_COVG_05_TABLES."
		vcqi_log_comment $VCP 1 Error "RI_COVG_05_TABLES must be either ALL_CLUSTERS or ONLY_LOW_CLUSTERS.  The current value is $RI_COVG_05_TABLES."
		local exitflag 1
	}
	
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


	

	
