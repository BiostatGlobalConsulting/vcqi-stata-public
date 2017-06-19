*! COVG_DIFF_02_04GO version 1.03 - Biostat Global Consulting - 2017-01-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Strip value label from levels 
*										variable for the over() calculation
* 										before lincom
* 2016-09-21	1.02	Dale Rhoda		Restrict observations to appropriate 
*										level in svy tab statement
* 2017-01-09	1.03	Dale Rhoda		Switch from svyp to svypd
*******************************************************************************

program COVG_DIFF_02_04GO

	local oldvcp $VCP
	global VCP COVG_DIFF_02_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/COVG_DIFF_02_${COVG_DIFF_02_INDICATOR}_${COVG_DIFF_02_ANALYSIS_COUNTER}", clear

		svyset clusterid, weight(psweight) strata(stratumid)
		
		local l $COVG_DIFF_02_STRATUM_LEVEL

		svypd $COVG_DIFF_02_VARIABLE if level`l'id == $COVG_DIFF_02_STRATUM_ID & $COVG_DIFF_02_SUBPOP_VARIABLE == $COVG_DIFF_02_SUBPOP_LEVEL1, method($VCQI_CI_METHOD) adjust
		scalar p1    = r(svyp) * 100
		scalar lb951 = r(lb_alpha) * 100
		scalar ub951 = r(ub_alpha) * 100
		scalar n1    = r(N)
		scalar nwtd1 = r(Nwtd)
		
		svypd $COVG_DIFF_02_VARIABLE if level`l'id == $COVG_DIFF_02_STRATUM_ID & $COVG_DIFF_02_SUBPOP_VARIABLE == $COVG_DIFF_02_SUBPOP_LEVEL2, method($VCQI_CI_METHOD) adjust
		scalar p2    = r(svyp) * 100
		scalar lb952 = r(lb_alpha) * 100
		scalar ub952 = r(ub_alpha) * 100
		scalar n2    = r(N)
		scalar nwtd2 = r(Nwtd)

		svy, subpop(if level`l'id == $COVG_DIFF_02_STRATUM_ID & inlist($COVG_DIFF_02_SUBPOP_VARIABLE,$COVG_DIFF_02_SUBPOP_LEVEL1,$COVG_DIFF_02_SUBPOP_LEVEL2)): tab $COVG_DIFF_02_VARIABLE $COVG_DIFF_02_SUBPOP_VARIABLE, pearson null col

		scalar df1 = e(df1_Penl)
		scalar df2 = e(df2_Penl)
		scalar frs = e(F_Penl)
		scalar pvalue = 1-F(df1,df2,frs)

		* For now, calculate the 95% CI for the difference using lincom
		

		* Create a version of the over() variable that does not have a value label
		tempvar cloned
		clonevar `cloned' = $COVG_DIFF_02_SUBPOP_VARIABLE
		label values `cloned'
		
		svy, subpop(if level`l'id == $COVG_DIFF_02_STRATUM_ID & inlist($COVG_DIFF_02_SUBPOP_VARIABLE,$COVG_DIFF_02_SUBPOP_LEVEL1,$COVG_DIFF_02_SUBPOP_LEVEL2)): prop $COVG_DIFF_02_VARIABLE, over(`cloned')

		* use the integer values themselves to run lincom
		lincom [_prop_2]$COVG_DIFF_02_SUBPOP_LEVEL1 - [_prop_2]$COVG_DIFF_02_SUBPOP_LEVEL2

		scalar df = r(df)
		scalar se = r(se)
		scalar diffhat = r(estimate)

		scalar difflb95 = 100* (diffhat - invt(df,0.975)*se)
		scalar diffub95 = 100* (diffhat + invt(df,0.975)*se)

		scalar diffhat = 100 * diffhat

		post cdiff02 ($COVG_DIFF_02_STRATUM_LEVEL) ("$COVG_DIFF_02_INDICATOR") ///
					 ("$COVG_DIFF_02_VARIABLE") ($COVG_DIFF_02_ANALYSIS_COUNTER) ///
					 ($COVG_DIFF_02_STRATUM_ID) ("$COVG_DIFF_02_STRATUM_NAME") ///
					 ("$COVG_DIFF_02_SUBPOP_VARIABLE") ("$COVG_DIFF_02_SUBPOP_LABEL") ///
					 ($COVG_DIFF_02_SUBPOP_LEVEL1) ("$COVG_DIFF_02_SUBPOP_NAME1") (n1) (nwtd1) (p1) (lb951) (ub951) ///
					 ($COVG_DIFF_02_SUBPOP_LEVEL2) ("$COVG_DIFF_02_SUBPOP_NAME2") (n2) (nwtd2) (p2) (lb952) (ub952) ///
					 (df) (diffhat) (difflb95) (diffub95) (pvalue)
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
