*! check_SIA_COVG_01_03DV version 1.00 - Biostat Global Consulting - 2018-10-25
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original Copied from check_RI_COVG_01_03DV
*******************************************************************************

* VCQI users are encouraged to generate output and then change the value of
* ANALYSIS_COUNTER and change some options and generate a second (or third...)
* set of output from within the same control program.

* When they do that, the indicators that rely on output from earlier indicators
* may be confused when they do not find output from upstream indicators 
* tagged with the new ANALYSIS_COUNTER.

* This program looks for the upstream output and if it is not found, it looks
* to see if there is output from when the ANALYSIS_COUNTER was 1.  If so, it
* copies the output into a new dataset and renames it to have _ANALYSIS_COUNTER
* in the name.

* The program puts a warning in the log if it copies and renames a file 
* because it is based on the assumption that the earlier indicator was run
* with ANALYSIS_COUNTER set to 1 and it is okay to use that output for 
* the new analysis.

program define check_SIA_COVG_01_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP check_SIA_COVG_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"	
	
	local exitflag 0
	
	capture confirm file "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}.dta"
	if _rc != 0 {
		capture confirm file "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_1.dta"
		if _rc == 0 {
			copy "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_1.dta" "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}.dta"
			vcqi_global SIA_COVG_01_TEMP_DATASETS $SIA_COVG_01_TEMP_DATASETS SIA_COVG_01_${ANALYSIS_COUNTER}
			vcqi_log_comment $VCP 2 Warning "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}.dta does not exist. VCQI will make a copy of SIA_COVG_01_1.dta and proceed."
		}			
		else {
			local exitflag 1 
			di as error  				  "The file ${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}.dta does not exist. Run SIA_COVG_01_03DV"
			vcqi_log_comment $VCP 1 Error "The file ${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}.dta does not exist. Run SIA_COVG_01_03DV"
		}
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
