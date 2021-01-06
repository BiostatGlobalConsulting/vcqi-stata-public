*! SIA_COVG_03_04GO version 1.02 - Biostat Global Consulting - 2018-04-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2018-04-26	1.02	Dale Rhoda		Also calculate coverage regardless
*										of age
*******************************************************************************

program define SIA_COVG_03_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_03_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		* All ages combined
		noi di _continue _col(3) "All ages "
		make_svyp_output_database, measureid(SIA_COVG_03) vid(all0d) var(lifetime_mcv_0) estlabel(Zero liftetime MCV doses )
		make_svyp_output_database, measureid(SIA_COVG_03) vid(all1d) var(lifetime_mcv_1) estlabel(One lifetime MCV dose)
		make_svyp_output_database, measureid(SIA_COVG_03) vid(all2d) var(lifetime_mcv_2) estlabel(Two or more lifetime MCV doses )
		
		local d0 0
		local d1 1
		local d2 2+

		local k 1
		forvalues i = $MIN_SIA_YEARS/$MAX_SIA_YEARS {
			noi di _continue _col(3) "`i' "
			forvalues j = 0/2 {
				make_svyp_output_database, measureid(SIA_COVG_03) vid(`k') var(lifetime_mcv_`j'_`i') estlabel(Age: `i' Doses: `d`j'' )
				local ++k
			}
		}
		noi di as text ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

