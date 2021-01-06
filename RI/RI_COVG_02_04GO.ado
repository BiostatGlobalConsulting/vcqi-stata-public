*! RI_COVG_02_04GO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-11=18	1.01	Dale Rhoda		Do not calculate the 'by age 1' outcomes
*										if the dose is administered after age 1
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_02_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_02_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		foreach d in $RI_DOSE_LIST {

			noi di _continue _col(5) "`d' "

			local du `=upper("`d'")'
			make_svyp_output_database,     measureid(RI_COVG_02) vid(`d'_c)   var(got_valid_`d'_by_card)     estlabel(Valid `du', by card)
			if $RI_RECORDS_SOUGHT_FOR_ALL | $RI_RECORDS_SOUGHT_IF_NO_CARD {
				make_svyp_output_database, measureid(RI_COVG_02) vid(`d'_r)   var(got_valid_`d'_by_register) estlabel(Valid `du', by register)
				make_svyp_output_database, measureid(RI_COVG_02) vid(`d'_cr)  var(got_valid_`d'_c_or_r)      estlabel(Valid `du', by card or register)
			}
			make_svyp_output_database, measureid(RI_COVG_02) vid(`d'_a)   var(got_valid_`d'_to_analyze)  estlabel(Valid `du', to analyze)
			
			if `=scalar(`=lower("`d'")'_min_age_days)'  < 365 {
		
				make_svyp_output_database,     measureid(RI_COVG_02) vid(`d'_ca1)  var(valid_`d'_age1_card)       estlabel(Valid `du' by age 1, by card)
				if $RI_RECORDS_SOUGHT_FOR_ALL | $RI_RECORDS_SOUGHT_IF_NO_CARD {
					make_svyp_output_database, measureid(RI_COVG_02) vid(`d'_ra1)  var(valid_`d'_age1_register)   estlabel(Valid `du' by age 1, by register)
					make_svyp_output_database, measureid(RI_COVG_02) vid(`d'_cra1) var(valid_`d'_age1_c_or_r)     estlabel(Valid `du' by age 1, by card or register)
				}
				make_svyp_output_database, measureid(RI_COVG_02) vid(`d'_aa1)  var(valid_`d'_age1_to_analyze) estlabel(Valid `du' by age 1, to analyze)
			}
		}
		noi di as text ""
	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

