*! RI_COVG_03_02DQ version 1.00 - Biostat Global Consulting - 2015-10-13

program define RI_COVG_03_02DQ

	local oldvcp $VCP
	global VCP RI_COVG_03_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"


	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
