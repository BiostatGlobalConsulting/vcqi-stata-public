*! RI_QUAL_07_04GO version 1.00 - Biostat Global Consulting - 2015-09-28
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define RI_QUAL_07_04GO

	local oldvcp $VCP
	global VCP RI_QUAL_07_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"

	local vc  `=lower("$RI_QUAL_07_VALID_OR_CRUDE")'
	local pvc `=proper("`vc'")'
	
	foreach d in $RI_DOSE_LIST {
		noi di _continue _col(5) "`d' "
		make_svyp_output_database, measureid(RI_QUAL_07) vid(`d'_`vc') var(valid_`d'_if_no_movs) estlabel(Would have valid `=upper("`d'")' if no MOVs (`pvc')(%))
	}
	noi di ""
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

