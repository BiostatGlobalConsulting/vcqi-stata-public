*! RI_QUAL_02_04GO version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_02_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_02_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_svyp_output_database, measureid(RI_QUAL_02) vid(1) var(ever_had_an_ri_card) estlabel(Ever Received RI Card (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

