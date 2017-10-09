*! RI_ACC_01_04GO version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_ACC_01_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_ACC_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local dl `=lower("$RI_ACC_01_DOSE_NAME")'
	local du `=upper("`dl'")'
	
	make_svyp_output_database, measureid(RI_ACC_01) vid(`dl') var(got_crude_`dl'_to_analyze) estlabel(Received `du' - Crude(%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

