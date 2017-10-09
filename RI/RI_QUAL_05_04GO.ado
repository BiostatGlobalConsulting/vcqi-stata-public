*! RI_QUAL_05_04GO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-05-17	1.01	Dale Rhoda		Add threshold to vid
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_05_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_05_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local d `=lower("$RI_QUAL_05_DOSE_NAME")' 
	local t `=int($RI_QUAL_05_INTERVAL_THRESHOLD)'

	make_unwtd_output_database, measureid(RI_QUAL_05) vid(`d'_`t') var(short_interval_`d'_`t') estlabel(`=upper("`d'")' Interval < `t' Days (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

