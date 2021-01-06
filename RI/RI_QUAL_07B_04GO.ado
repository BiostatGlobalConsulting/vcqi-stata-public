*! RI_QUAL_07B_04GO version 1.01 - Biostat Global Consulting - 2020-09-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-03-10	1.00	Mary Prier		Original version
* 2020-09-13	1.01	Dale Rhoda		Switch to MOV_OUTPUT_DOSE_LIST
*******************************************************************************

program define RI_QUAL_07B_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07B_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* NOTE: RI_QUAL_07_04GO  loops over $MOV_OUTPUT_DOSE_LIST, but
	*       RI_QUAL_07B_04GO loops over all doses...update if needed
	*foreach d in $MOV_OUTPUT_DOSE_LIST {
	foreach d in $MOV_OUTPUT_DOSE_LIST {
		noi di _continue _col(5) "`d' "
		make_svyp_output_database, measureid(RI_QUAL_07B) vid(`d') var(got_hypo_`d') estlabel(Would have valid `=upper("`d'")' if no MOVs (%))
	}
	noi di as text ""
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

