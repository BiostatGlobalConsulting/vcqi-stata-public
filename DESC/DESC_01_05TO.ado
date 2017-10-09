*! DESC_01_05TO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define DESC_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
		
	quietly {
		vcqi_global DESC_01_TO_TITLE    $DESC_01_DATASET Survey Sample Summary
		
		vcqi_global DESC_01_TO_SUBTITLE
		
		vcqi_global DESC_01_TO_FOOTNOTE_1  Abbreviations: HH = Households	
		
		make_tables_from_DESC_01, measureid(DESC_01) sheet(DESC_01_${DESC_01_DATASET}) 
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
