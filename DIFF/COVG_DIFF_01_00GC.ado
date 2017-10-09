*! COVG_DIFF_01_00GC version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added end double quote (") to "COVG_DIFF_01_01 only supports hypothesis tests between strata in level 2 or strata in level 3 at this time.
*
*										Adjusted Error message and vcqi_log_comment to match up for 	if !inlist($COVG_DIFF_01_STRATUM_LEVEL,2,3) {
*											Combined the two messages to give user most information: "Attempt to call COVG_DIFF_01_01 with COVG_DIFF_01_STRATUM_LEVEL set to $COVG_DIFF_01_STRATUM_LEVEL; COVG_DIFF_01_01 only supports hypothesis tests between strata in level 2 or strata in level 3 at this time."
*											Previous Error:"COVG_DIFF_01_01 only supports hypothesis tests between strata in level 2 or strata in level 3 at this time.
*											Previous vcqi_log_comment: Attempt to call COVG_DIFF_01_01 with COVG_DIFF_01_STRATUM_LEVEL set to $COVG_DIFF_01_STRATUM_LEVEL; it should be 2 or 3.
*
* 2016-01-18	1.02	Dale Rhoda		Switched to vcqi_global
* 2016-08-25	1.03	Dale Rhoda		Moved PP steps from here to PP program
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define COVG_DIFF_01_00GC
	version 14.1

	local oldvcp $VCP
	global VCP COVG_DIFF_01_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local exitflag 0

	if !inlist($COVG_DIFF_01_STRATUM_LEVEL,2,3) {
		di as error "Attempt to call COVG_DIFF_01_01 with COVG_DIFF_01_STRATUM_LEVEL set to $COVG_DIFF_01_STRATUM_LEVEL; COVG_DIFF_01_01 only supports hypothesis tests between strata in level 2 or strata in level 3 at this time."
		vcqi_log_comment $VCP 1 Error "Attempt to call COVG_DIFF_01_01 with COVG_DIFF_01_STRATUM_LEVEL set to $COVG_DIFF_01_STRATUM_LEVEL; COVG_DIFF_01_01 only supports hypothesis tests between strata in level 2 or strata in level 3 at this time."
		local exitflag 1
	}
	local l $COVG_DIFF_01_STRATUM_LEVEL
	
	if !inlist("`=upper("$COVG_DIFF_01_ID_OR_NAME")'","NAME","ID") {
		di as error "COVG_DIFF_01_ID_OR_NAME must be either NAME or ID.  The current value is $COVG_DIFF_01_ID_OR_NAME."
		vcqi_log_comment $VCP 1 Error "COVG_DIFF_01_ID_OR_NAME must be either NAME or ID.  The current value is $COVG_DIFF_01_ID_OR_NAME."
		local exitflag 1
	}

	* Check to see that COVG_DIFF_01_STRATUM_ID1 and COVG_DIFF_01_STRATUM_ID2 are
	* valid values, and store the names of the strata in 
	* COVG_DIFF_01_STRATUM_NAME1 and COVG_DIFF_01_STRATUM_NAME2
	
	local id1match 0
	local id2match 0
	
	if "`=upper("$COVG_DIFF_01_ID_OR_NAME")'" == "ID" {
	
		use "${LEVEL`l'_NAME_DATASET}", clear
		
		forvalues i= 1/`=_N' {
			forvalues j = 1/2 {
				if level`l'id[`i'] == ${COVG_DIFF_01_STRATUM_ID`j'} {
					vcqi_global COVG_DIFF_01_STRATUM_NAME`j' = level`l'name[`i']
					local id`j'match 1
				}
			}
		}
		
		forvalues j = 1/2 {
			if `id`j'match' == 0 {
				di as error "The value of COVG_DIFF_01_STRATUM_ID`j' doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				di as error "COVG_DIFF_01_STRATUM_ID`j' is ${COVG_DIFF_01_STRATUM_ID`j'}"
				di as error "LEVEL`l'_NAME_DATASET is ${LEVEL`l'_NAME_DATASET}"
				
				vcqi_log_comment $VCP 1 Error	"The value of COVG_DIFF_01_STRATUM_ID`j' doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				vcqi_log_comment $VCP 1 Error	"COVG_DIFF_01_STRATUM_ID`j' is ${COVG_DIFF_01_STRATUM_ID`j'}"
				vcqi_log_comment $VCP 1 Error   "LEVEL`l'_NAME_DATASET is ${LEVEL`l'_NAME_DATASET}"

				local exitflag 1
			}
		}
	}
	

	* Check to see that COVG_DIFF_01_STRATUM_NAME1 and COVG_DIFF_01_STRATUM_NAME2 are
	* valid values, and store the ids of the strata in 
	* COVG_DIFF_01_STRATUM_ID1 and COVG_DIFF_01_STRATUM_ID2
	
	local name1match 0
	local name2match 0
	
	if "`=upper("$COVG_DIFF_01_ID_OR_NAME")'" == "NAME" {
	
		use "${LEVEL`l'_NAME_DATASET}", clear
		
		forvalues i= 1/`=_N' {
			forvalues j = 1/2 {
				if trim(upper(level`l'name[`i'])) == trim(upper("${COVG_DIFF_01_STRATUM_NAME`j'}")) {
					vcqi_global COVG_DIFF_01_STRATUM_NAME`j' = level`l'name[`i'] // adopt capitalization from names dataset
					vcqi_global COVG_DIFF_01_STRATUM_ID`j' = level`l'id[`i']
					local name`j'match 1
				}
			}
		}
		
		forvalues j = 1/2 {
			if `name`j'match' == 0 {
				di as error "The value of COVG_DIFF_01_STRATUM_NAME`j' doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				di as error "COVG_DIFF_01_STRATUM_NAME`j' is $COVG_DIFF_01_STRATUM_NAME`j'"
				di as error "LEVEL`l'_NAME_DATASET is ${LEVEL`l'_NAME_DATASET}"
					
				vcqi_log_comment $VCP 1 Error	"The value of COVG_DIFF_01_STRATUM_NAME`j' doesn't seem to be valid; it does not appear in LEVEL`l'NAMES_DATASET"
				vcqi_log_comment $VCP 1 Error	"COVG_DIFF_01_STRATUM_NAME`j' is ${COVG_DIFF_01_STRATUM_NAME`j'}"
				vcqi_log_comment $VCP 1 Error "LEVEL`l'_NAME_DATASET is $LEVEL`l'_NAME_DATASET"

				local exitflag 1
			}
		}
	}
	
	* Check to see if the COVG_DIFF_01_INDICATOR is valid
	vcqi_global COVG_DIFF_01_INDICATOR `=upper("$COVG_DIFF_01_INDICATOR")'

	local inlist 0
	foreach i in TT_COVG_01 SIA_COVG_01 SIA_COVG_02 SIA_QUAL_01 RI_ACC_01 RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04 RI_QUAL_01 RI_QUAL_02 RI_QUAL_07 {
				 	
		if "$COVG_DIFF_01_INDICATOR" == "`i'" local inlist 1
		
	}

	if `inlist' == 0 {
		di as error "The value of COVG_DIFF_01_INDICATOR doesn't seem to be valid."
		di as error "It should be in this list: TT_COVG_01 SIA_COVG_01 SIA_COVG_02 SIA_QUAL_01"
		di as error "RI_ACC_01 RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04"
		di as error "RI_QUAL_01 RI_QUAL_02 RI_QUAL_07"
		
		vcqi_log_comment $VCP 1 Error	 "The value of COVG_DIFF_01_INDICATOR doesn't seem to be valid."
		vcqi_log_comment $VCP 1 Error	 "It should be in this list: TT_COVG_01 SIA_COVG_01 SIA_COVG_02 SIA_QUAL_01"
		vcqi_log_comment $VCP 1 Error	 "RI_ACC_01 RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04"
		vcqi_log_comment $VCP 1 Error	 "RI_QUAL_01 RI_QUAL_02 RI_QUAL_07"

		local exitflag 1
	}
	
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
