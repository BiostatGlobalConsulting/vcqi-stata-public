*! RI_COVG_03_04GO version 1.01 - Biostat Global Consulting - 2017-01-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 
* 2017-01-09	1.01	Dale Rhoda		Skip valid dose calculations if none
*										of the respondents have complete DOB
*******************************************************************************

program define RI_COVG_03_04GO

	local oldvcp $VCP
	global VCP RI_COVG_03_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_svyp_output_database, measureid(RI_COVG_03) vid(fvc)  var(fully_vaccinated_crude)     estlabel(Fully vaccinated - crude)
	if "$VCQI_NO_DOBS" != "1" make_svyp_output_database, measureid(RI_COVG_03) vid(fvv)  var(fully_vaccinated_valid)     estlabel(Fully vaccinated - valid)
	if "$VCQI_NO_DOBS" != "1" make_svyp_output_database, measureid(RI_COVG_03) vid(fva1) var(fully_vaccinated_by_age1)   estlabel(Fully vaccinated with valid doses by age 1)

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

