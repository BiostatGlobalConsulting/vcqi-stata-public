*! RI_QUAL_01_03DV version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_01_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}", clear

		gen card_date_count=0
		label variable card_date_count "Number of Dates on Card"

		foreach d in $RI_DOSE_LIST {
			replace card_date_count= card_date_count + 1 if !missing(`d'_card_date)
		}

		gen showed_card_with_dates=(RI27==1 & card_date_count>0)	
		label variable showed_card_with_dates "Card Seen- Dates listed on Card"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

