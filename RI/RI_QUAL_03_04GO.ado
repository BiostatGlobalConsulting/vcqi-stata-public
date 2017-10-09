*! RI_QUAL_03_04GO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-09	1.01	Dale Rhoda		Skip if no respondents have DOB
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_03_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_03_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local d = lower("$RI_QUAL_03_DOSE_NAME")
	
	make_unwtd_output_database, measureid(RI_QUAL_03) vid(`d') var(got_invalid_`d') estlabel(Received Invalid `=upper("`d'")' (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

