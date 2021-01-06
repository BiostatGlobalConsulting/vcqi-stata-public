*! DESC_03_04GO version 1.03 - Biostat Global Consulting - 2018-01-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	Dale Rhoda		Switched to DESC_03_TO_TITLE
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2018-01-23	1.03	MK Trimner		Added double quotes to global if missin
*******************************************************************************

program define DESC_03_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_03_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_DESC_0203_output_database, measureid(DESC_03) vid($DESC_03_COUNTER) var(desc03_${ANALYSIS_COUNTER}_${DESC_03_COUNTER}) label($DESC_03_TO_TITLE)

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


