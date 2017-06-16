*! RI_QUAL_06_04GO version 1.00 - Biostat Global Consulting - 2015-10-22
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define RI_QUAL_06_04GO

	local oldvcp $VCP
	global VCP RI_QUAL_06_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local d `=lower("$RI_QUAL_06_DOSE_NAME")' 

	make_unwtd_output_database, measureid(RI_QUAL_06) vid(`d') var(valid_`d'_before_age1) estlabel(Valid `=upper("`d'")' Given by Age 1 (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

