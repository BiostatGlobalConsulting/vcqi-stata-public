*! SIA_COVG_05_00GC version 1.00 - Biostat Global Consulting - 2018-10-25
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original copied from RI_COVG_05
*******************************************************************************

program define SIA_COVG_05_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_05_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	foreach g in SIA_COVG_05_THRESHOLD_TYPE SIA_COVG_05_THRESHOLD SIA_COVG_05_TABLES {
		vcqi_log_global `g'
	}
	
	local exitflag 0

	*Confirm global SIA_COVG_05_THRESHOLD_TYPE is defined and has the appropriate values
	if !inlist("`=upper("$SIA_COVG_05_THRESHOLD_TYPE")'","COUNT","PERCENT"){
		di as error "SIA_COVG_05_THRESHOLD_TYPE must be either COUNT or PERCENT.  The current value is $SIA_COVG_05_THRESHOLD_TYPE."
		vcqi_log_comment $VCP 1 Error "SIA_COVG_05_THRESHOLD_TYPE must be either COUNT or PERCENT.  The current value is $SIA_COVG_05_THRESHOLD_TYPE."
		local exitflag 1
	}
	
	*Confirm global SIA_COVG_05_THRESHOLD is defined with the appropriate values based on SIA_COVG_05_THRESHOLD_TYPE
	capture confirm number $SIA_COVG_05_THRESHOLD
	if _rc !=0 {
		di as error "Global variable SIA_COVG_05_THRESHOLD must be a numeric value"
		vcqi_log_comment $VCP 1 Error "Global variable SIA_COVG_05_THRESHOLD must be a numeric value"
		local exitflag 1
	}

	
	if "$SIA_COVG_05_THRESHOLD_TYPE"== "COUNT" {
		if $SIA_COVG_05_THRESHOLD < 0 {
			di as error "SIA_COVG_05_THRESHOLD must be a number >= zero because COUNT was selected as the SIA_COVG_05_THRESHOLD_TYPE"	
			vcqi_log_comment $VCP 1 Error "SIA_COVG_05_THRESHOLD must be a number >= zero because COUNT was selected as the SIA_COVG_05_THRESHOLD_TYPE"
			local exitflag 1
		}
	}
	if "$SIA_COVG_05_THRESHOLD_TYPE"== "PERCENT" {
		if $SIA_COVG_05_THRESHOLD < 0 | $SIA_COVG_05_THRESHOLD > 100 {
			di as error "SIA_COVG_05_THRESHOLD must be between 0 and 100 (inclusive) because PERCENT was selected as the SIA_COVG_05_THRESHOLD_TYPE"
			vcqi_log_comment $VCP 1 Error "SIA_COVG_05_THRESHOLD must be between 0 and 100 (inclusive) because PERCENT was selected as the SIA_COVG_05_THRESHOLD_TYPE"
			local exitflag 1
		}
	}
	
	*Confirm global SIA_COVG_05_TABLES is defined and has the appropriate values
	if !inlist("`=upper("$SIA_COVG_05_TABLES")'","ALL_CLUSTERS","ONLY_LOW_CLUSTERS") {
		di as error "SIA_COVG_05_TABLES must be either ALL_CLUSTERS or ONLY_LOW_CLUSTERS.  The current value is $SIA_COVG_05_TABLES."
		vcqi_log_comment $VCP 1 Error "SIA_COVG_05_TABLES must be either ALL_CLUSTERS or ONLY_LOW_CLUSTERS.  The current value is $SIA_COVG_05_TABLES."
		local exitflag 1
	}
	
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


	

	
