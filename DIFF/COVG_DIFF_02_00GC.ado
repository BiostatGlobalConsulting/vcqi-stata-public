*! COVG_DIFF_02_00GC version 1.04 - Biostat Global Consulting - 2016-08-25
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added 1 for vcqi_log_comment type for the below:
*										vcqi_log_comment $VCP 1 Error "Not able to merge COVG_DIFF_02_SUBPOP_VARIABLE into output from COVG_DIFF_02_INDICATOR."
*
*										Changed error message and vcqi_log_comment to match up for if !inlist($COVG_DIFF_02_STRATUM_LEVEL,1,2,3) {
*											Combined the two messages to give the user the most information: "COVG_DIFF_02: COVG_DIFF_02_STRATUM_LEVEL should be 1, 2, or 3; it is $COVG_DIFF_02_STRATUM_LEVEL."
*											Previous Error message:"COVG_DIFF_02_STRATUM_LEVEL should be 1, 2, or 3; it is $COVG_DIFF_02_STRATUM_LEVEL."
*											Previous vcqi_log_commnet:"COVG_DIFF_02_STRATUM_LEVEL should be 1, 2, or 3; it is $COVG_DIFF_02_STRATUM_LEVEL."
*
* 2016-01-18	1.02	Dale Rhoda		Switched to vcqi_global
* 2016-08-24	1.03	Dale Rhoda		Check to be sure that levels are 
* 										non-negative integers
* 2016-08-25	1.04	Dale Rhoda		Moved PP steps from here to PP program
*******************************************************************************

program COVG_DIFF_02_00GC

	local oldvcp $VCP
	global VCP COVG_DIFF_02_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local exitflag 0

		if !inlist($COVG_DIFF_02_STRATUM_LEVEL,1,2,3) {
			di as error "COVG_DIFF_02: COVG_DIFF_02_STRATUM_LEVEL should be 1, 2, or 3; it is $COVG_DIFF_02_STRATUM_LEVEL."
			vcqi_log_comment $VCP 1 Error "COVG_DIFF_02: COVG_DIFF_02_STRATUM_LEVEL should be 1, 2, or 3; it is $COVG_DIFF_02_STRATUM_LEVEL."
			local exitflag 1
		}
		local l $COVG_DIFF_02_STRATUM_LEVEL
		
		if !inlist("`=upper("$COVG_DIFF_02_ID_OR_NAME")'","NAME","ID") {
			di as error "COVG_DIFF_02_ID_OR_NAME must be either NAME or ID.  The current value is $COVG_DIFF_02_ID_OR_NAME."
			vcqi_log_comment $VCP 1 Error "COVG_DIFF_02_ID_OR_NAME must be either NAME or ID.  The current value is $COVG_DIFF_02_ID_OR_NAME."
			local exitflag 1
		}

		* Check to see that COVG_DIFF_02_STRATUM_ID is a
		* valid value, and store the name of the stratum in 
		* COVG_DIFF_02_STRATUM_NAME
		
		local idmatch 0
		
		if "`=upper("$COVG_DIFF_02_ID_OR_NAME")'" == "ID" {
		
			use "${LEVEL`l'_NAME_DATASET}", clear
			
			forvalues i= 1/`=_N' {
				if level`l'id[`i'] == ${COVG_DIFF_02_STRATUM_ID} {
					vcqi_global COVG_DIFF_02_STRATUM_NAME = level`l'name[`i']
					local idmatch 1
				}
			}
			
			if `id`j'match' == 0 {
				di as error "The value of COVG_DIFF_02_STRATUM_ID doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				di as error "COVG_DIFF_02_STRATUM_ID is ${COVG_DIFF_02_STRATUM_ID}"
				di as error "LEVEL`l'_NAME_DATASET is ${LEVEL`l'_NAME_DATASET}"
					
				vcqi_log_comment $VCP 1 Error  "The value of COVG_DIFF_02_STRATUM_ID doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				vcqi_log_comment $VCP 1 Error  "COVG_DIFF_02_STRATUM_ID is ${COVG_DIFF_02_STRATUM_ID}"
				vcqi_log_comment $VCP 1 Error  "LEVEL`l'_NAME_DATASET is ${LEVEL`l'_NAME_DATASET}"

				local exitflag 1
			}
		}
		

		* Check to see that COVG_DIFF_02_STRATUM_NAME is a
		* valid value, and store the id of the strata in 
		* COVG_DIFF_02_STRATUM_ID1 and COVG_DIFF_02_STRATUM_ID2
		
		local namematch 0
		
		if "`=upper("$COVG_DIFF_02_ID_OR_NAME")'" == "NAME" {
		
			use "${LEVEL`l'_NAME_DATASET}", clear
			
			forvalues i= 1/`=_N' {
				if trim(upper(level`l'name[`i'])) == trim(upper("${COVG_DIFF_02_STRATUM_NAME}")) {
					vcqi_global COVG_DIFF_02_STRATUM_NAME = level`l'name[`i'] // adopt capitalization from names dataset
					vcqi_global COVG_DIFF_02_STRATUM_ID = level`l'id[`i']
					local namematch 1
				}
			}
			
			if `name`j'match' == 0 {
				di as error "The value of COVG_DIFF_02_STRATUM_NAME doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				di as error "COVG_DIFF_02_STRATUM_NAME is $COVG_DIFF_02_STRATUM_NAME"
				di as error "LEVEL`l'_NAME_DATASET is ${LEVEL`l'_NAME_DATASET}"
						
				vcqi_log_comment $VCP 1 Error	"The value of COVG_DIFF_02_STRATUM_NAME doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				vcqi_log_comment $VCP 1 Error	"COVG_DIFF_02_STRATUM_NAME is ${COVG_DIFF_02_STRATUM_NAME}"
				vcqi_log_comment $VCP 1 Error "LEVEL`l'_NAME_DATASET is $LEVEL`l'_NAME_DATASET"

				local exitflag 1
			}
		}
		
		* Check to see if the COVG_DIFF_02_INDICATOR is valid
		vcqi_global COVG_DIFF_02_INDICATOR `=upper("$COVG_DIFF_02_INDICATOR")'

		local inlist 0
		foreach i in TT_COVG_01 SIA_COVG_01 SIA_COVG_02 SIA_QUAL_01 RI_ACC_01 RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04 RI_QUAL_01 RI_QUAL_02 RI_QUAL_07 {
						
			if "$COVG_DIFF_02_INDICATOR" == "`i'" local inlist 1
			
		}

		if `inlist' == 0 {
			di as error "The value of COVG_DIFF_02_INDICATOR doesn't seem to be valid."
			di as error "It should be in this list: TT_COVG_01 SIA_COVG_01 SIA_COVG_02 SIA_QUAL_01"
			di as error "RI_ACC_01 RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04"
			di as error "RI_QUAL_01 RI_QUAL_02 RI_QUAL_07"
			
			vcqi_log_comment $VCP 1 Error	 "The value of COVG_DIFF_02_INDICATOR doesn't seem to be valid."
			vcqi_log_comment $VCP 1 Error	 "It should be in this list: TT_COVG_01 SIA_COVG_01 SIA_COVG_02 SIA_QUAL_01"
			vcqi_log_comment $VCP 1 Error	 "RI_ACC_01 RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04"
			vcqi_log_comment $VCP 1 Error	 "RI_QUAL_01 RI_QUAL_02 RI_QUAL_07"

			local exitflag 1
		}
		
		if `exitflag' == 1 {
			vcqi_global VCQI_ERROR 1
			vcqi_halt_immediately
		}
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
