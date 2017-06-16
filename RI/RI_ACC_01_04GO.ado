*! RI_ACC_01_04GO version 1.00 - Biostat Global Consulting - 2015-10-22
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define RI_ACC_01_04GO

	local oldvcp $VCP
	global VCP RI_ACC_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local dl `=lower("$RI_ACC_01_DOSE_NAME")'
	local du `=upper("`dl'")'
	
	make_svyp_output_database, measureid(RI_ACC_01) vid(`dl') var(got_crude_`dl'_to_analyze) estlabel(Received `du' - Crude(%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

