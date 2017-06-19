*! RI_QUAL_13_04GO version 1.00 - Biostat Global Consulting - 2015-11-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed

*******************************************************************************

program define RI_QUAL_13_04GO

	local oldvcp $VCP
	global VCP RI_QUAL_13_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local d `=lower("$RI_QUAL_13_DOSE_NAME")'
	local t `=int($RI_QUAL_13_AGE_THRESHOLD)'

	make_unwtd_output_database, measureid(RI_QUAL_13) vid(`d'_`t') var(early_`d'_`t') estlabel(Received `=upper("`d'")' Before Age `t' Days (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

