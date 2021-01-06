*! RI_VCTC_01_05TO version 1.00 - Biostat Global Consulting - 2020-09-25
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-09-25	1.00	Dale Rhoda		Original version
*******************************************************************************

program define RI_VCTC_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_VCTC_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	if $VCQI_CHECK_INSTEAD_OF_RUN != 1 {

		quietly{

			use  "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}_TO", clear

			export excel using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx", sheet(RI_VCTC_01_${ANALYSIS_COUNTER}) firstrow(varlabels) sheetreplace
			
			* Use mata to populate column labels and worksheet titles and footnotes
			mata: b = xl()
			mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx")
			mata: b.set_mode("open")
			mata: b.set_sheet("RI_VCTC_01_${ANALYSIS_COUNTER}")
			
			*Overwrite the stratum variable name...it is not needed
			mata: b.put_string(`=_N+3',1,"Note: This table is not meant to be copied and pasted into a report, but rather to help someone who is looking at a RI_VCTC_01 plot and wants to know (or mention in a report) the vertical height of some of the colored tiles in the stacked bars.")
			
			mata: b.put_string(`=_N+4',1,"Note: The sheet is sorted by level and levelid and then reverse sorted by order, so the tile numbers in the sheet appear, bottom-to-top, in the same orientation and order as the tiles in the plot.")
			
			mata: b.close_book()
		
		}
	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
