*! RI_QUAL_02_04GO version 1.00 - Biostat Global Consulting - 2015-10-22
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define RI_QUAL_02_04GO

	local oldvcp $VCP
	global VCP RI_QUAL_02_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_svyp_output_database, measureid(RI_QUAL_02) vid(1) var(ever_had_an_ri_card) estlabel(Ever Received RI Card (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

