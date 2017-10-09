*! RI_COVG_04_04GO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-07	1.01	Dale Rhoda		Skip valid dose tables if no respondent
*										has DOB data
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_04_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_04_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_svyp_output_database, measureid(RI_COVG_04) vid(nvc)  var(not_vaccinated_crude)     estlabel(Not vaccinated - crude)
	if "$VCQI_NO_DOBS" != "1" make_svyp_output_database, measureid(RI_COVG_04) vid(nvv)  var(not_vaccinated_valid)     estlabel(Not vaccinated - valid)
	if "$VCQI_NO_DOBS" != "1" make_svyp_output_database, measureid(RI_COVG_04) vid(nva1) var(not_vaccinated_by_age1)   estlabel(No valid doses by age 1)

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

