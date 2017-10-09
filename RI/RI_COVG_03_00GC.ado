*! RI_COVG_03_00GC version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 
* 2017-01-27	1.00	Dale Rhoda		Original version; used for both
*										RI_COVG_03 and RI_COVG_04
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_03_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_03_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	foreach g in RI_DOSES_TO_BE_FULLY_VACCINATED RI_DOSE_LIST RI_SINGLE_DOSE_LIST RI_MULTI_2_DOSE_LIST RI_MULTI_3_DOSE_LIST {
		vcqi_log_global `g'
	}
	
	local exitflag 0
	
	*Confirm global RI_DOSES_TO_BE_FULLY_VACCINATED is defined 
	if "$RI_DOSES_TO_BE_FULLY_VACCINATED" == "" {
		di as error "RI_DOSES_TO_BE_FULLY_VACCINATED must be defined by the user in order to calculate RI_COVG_03 or RI_COVG_04. It is currently not defined."
		vcqi_log_comment $VCP 1 Error "RI_DOSES_TO_BE_FULLY_VACCINATED must be defined by the user in order to calculate RI_COVG_03. It is currently not defined."
		local exitflag 1
	}
	
	*Check to see that each dose listed in RI_DOSES_TO_BE_FULLY_VACCINATED is included in the analysis
	if "$RI_DOSES_TO_BE_FULLY_VACCINATED" != "" {
		foreach d in `=upper("$RI_DOSES_TO_BE_FULLY_VACCINATED")' {
			if strpos("`=upper("$RI_DOSE_LIST")'","`d'") == 0 {
				di as error "RI_DOSES_TO_BE_FULLY_VACCINATED includes `d', but `d' does not appear in the RI_DOSE_LIST which is set using the global macros RI_SINGLE_DOSE_LIST or RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST.  Either add `d' to one of those macros or remove it from RI_DOSES_TO_BE_FULLY_VACCINATED"
				vcqi_log_comment $VCP 1 Error "RI_DOSES_TO_BE_FULLY_VACCINATED includes `d', but `d' does not appear in the RI_DOSE_LIST which is set using the global macros RI_SINGLE_DOSE_LIST or RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST.  Either add `d' to one of those macros or remove it from RI_DOSES_TO_BE_FULLY_VACCINATED" 
				local exitflag 1
			}
		}
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
