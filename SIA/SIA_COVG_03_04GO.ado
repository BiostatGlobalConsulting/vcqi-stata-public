*! SIA_COVG_03_04GO version 1.00 - Biostat Global Consulting - 2015-10-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define SIA_COVG_03_04GO

	local oldvcp $VCP
	global VCP SIA_COVG_03_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
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
		noi di ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
