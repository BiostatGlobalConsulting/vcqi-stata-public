*! TT_COVG_01_02DQ version 1.03 - Biostat Global Consulting - 2018-05-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-03	1.01	Dale Rhoda		Cosmetic changes
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2018-05-31	1.03	Dale Rhoda		TT39 must be > 0 to represent 1+ doses
*******************************************************************************

program define TT_COVG_01_02DQ
	version 14.1
	
	local oldvcp $VCP
	global VCP TT_COVG_01_02DQ
	
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		use "${VCQI_OUTPUT_FOLDER}/TT_COVG_01_${ANALYSIS_COUNTER}", clear
		
		local bigN `=_N'	

		* Write some messages to the log if there are records that seem to be missing any TT dose-related info
		*
		* These checks do not affect the processing...if we do not have evidence of a dose then that dose s
		* cannot contribute toward lifetime doses, but it does not halt the calculation.
		*
		* These checks warrant additional scrutiny
		
		* no dates on card
		count if missing(TT30) & missing(TT31) & missing(TT32) & ///
				 missing(TT33) & missing(TT34) & missing(TT35)
		local dropthis = r(N)
		if r(N) > 0 vcqi_log_comment $VCP 2 Warning "No TT dates on card for `dropthis' out of `bigN' records."

		* no info on doses in index pregnancy
		count if !inlist(TT37,0,1,2,3,99) & TT36 == 1
		local dropthis = r(N)
		if r(N) > 0 vcqi_log_comment $VCP 2 Warning "No info on # of doses during index pregnancy for `dropthis' out of `bigN' records."

		* no info on doses in earlier pregnancies
		count if (missing(TT39) | TT39 == 99) & TT38 == 1
		local dropthis = r(N)
		if r(N) > 0 vcqi_log_comment $VCP 2 Warning "No info on # of doses during earlier pregnancies for `dropthis' out of `bigN' records."
		
		* no info in doses in index pregnancy
		count if !inlist(TT41,0,1,2,3,4,5,6,7,99) & TT40 == 1
		local dropthis = r(N)
		if r(N) > 0 vcqi_log_comment $VCP 2 Warning "No info on # of doses outside pregnancy `dropthis' out of `bigN' records."

		* women whose history says they got 1+ doses
		count if (inlist(TT37,1,2,3) | (TT39 > 0 & TT39 < 99) | inlist(TT41,1,2,3,4,5,6,7))
		local bigN = r(N)
		
		* years since last TT dose is missing, but they got 1+ doses
		count if (missing(TT42) | TT42 == 98 | TT42 == 99) & (inlist(TT37,1,2,3) | (TT39 > 0 & TT39 < 99) | inlist(TT41,1,2,3,4,5,6,7))
		local dropthis = r(N)
		if r(N) > 0 vcqi_log_comment $VCP 2 Warning "Years since last TT is not set for `dropthis' out of `bigN' respondents who got 1+ doses."
		
		* years since last TT dose should be no higher than the woman's age	
		count if (TT42 > TT16 & TT42 != 99 & !missing(TT42) & !missing(TT16)) & (inlist(TT37,1,2,3) | (TT39 > 0 & TT39 < 99) | inlist(TT41,1,2,3,4,5,6,7))
		local dropthis = r(N)
		if r(N) > 0 vcqi_log_comment $VCP 2 Warning "Years since last dose is > age for `dropthis' out of `bigN' records who got 1+ doses."
		
		* It is a disappointing data quality problem if years since last TT dose is > age, but it will not be a problem for the protected at birth
		* calculation because the child will either be protected by virtue of 5+ lifetime maternal doses, or they will not be protected because
		* the years since last dose will be > 9.  (Presuming that the age of women who gave birth in the last 12 months is > 9.)

		vcqi_log_comment $VCP 3 Comment "This program does not check to see whether the woman said she had doses during the last pregnancy, earlier pregnancies, or outside of pregnancy; it skips directly to the NUMBER OF DOSES she says she had in those periods."
		vcqi_log_comment $VCP 3 Comment "If there are inconsistencies between variables recording WHETHER she had doses and variables recording HOW MANY, those will not be picked up by this program; it focuses on HOW MANY."
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
