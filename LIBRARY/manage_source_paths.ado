*! manage_source_paths version 1.00 - Biostat Global Consulting - 2018-05-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-05-23	1.00	MK Trimner		original version		
*******************************************************************************

capture program drop manage_source_paths
program define manage_source_paths

	syntax, SOURCE(string asis)  // should be VCQI or MISS_VCQI
	
	* Confirm that source is VCQI or MISS_VCQI
	if !inlist("`=upper("`source'")'", "VCQI", "MISS_VCQI") {
		di as error "Error in VCQI program named manage_source_paths." 
		di as error "The SOURCE option must hold the string VCQI or MISS_VCQI depending on which program you are running." 
		di as error "Current value is `source'."
		exit 99
	}
	
	* Confirm that the folder for the source selected is provided
	foreach v in VCQI MISS_VCQI {
		if "`=upper("`source'")'"=="`v'" & "${S_`v'_SOURCE_CODE_FOLDER}"=="" {
			di as error "Global S_`v'_SOURCE_CODE_FOLDER must be populated so programs can be added to the correct path."			
			di as error "Populate a global macro with this name with the path to the source code folder."			
			exit 99
		}
	}

	* Set the VCQI and MISS VCQI actions based on which program is running
	
	* Set a local with the forward slash if the action is add
	* and forward and backward slashes if the action is remove
	if "`=upper("`source'")'"=="VCQI" {
		local vcqi_action 		+
		local v					/
		
		local miss_vcqi_action 	-
		local m					/ \
	}
	else if "`=upper("`source'")'"=="MISS_VCQI" {
		local vcqi_action 		-
		local v					/ \
		
		local miss_vcqi_action 	+
		local m					/
	}
	
	di as text "VCQI Action is: `vcqi_action'"
	di as text "MISS_VCQI Action is: `miss_vcqi_action'"
	
	* Make the changes to the adopath for VCQI_SOURCE_CODE_FOLDER
	foreach b in `v' {
		if "${S_VCQI_SOURCE_CODE_FOLDER}"!= "" {
						
			* sub in string VCQI_SOURCE_CODE_FOLDER path with local b
			* so all slashes are going the same way
			if "`b'"=="/" global S_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_VCQI_SOURCE_CODE_FOLDER}","\","/",.)'
			if "`b'"=="/" global S_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_VCQI_SOURCE_CODE_FOLDER}`b'","//","/",.)'
			if "`b'"=="\" global S_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_VCQI_SOURCE_CODE_FOLDER}","/","\",.)'
			if "`b'"=="\" global S_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_VCQI_SOURCE_CODE_FOLDER}`b'","\\","\",.)'
			
			* Complete add or removal of path
			capture adopath `vcqi_action' "${S_VCQI_SOURCE_CODE_FOLDER}DESC"
			capture adopath `vcqi_action' "${S_VCQI_SOURCE_CODE_FOLDER}DIFF"
			capture adopath `vcqi_action' "${S_VCQI_SOURCE_CODE_FOLDER}LIBRARY"
			capture adopath `vcqi_action' "${S_VCQI_SOURCE_CODE_FOLDER}PLOT"
			capture adopath `vcqi_action' "${S_VCQI_SOURCE_CODE_FOLDER}RI"
			capture adopath `vcqi_action' "${S_VCQI_SOURCE_CODE_FOLDER}SIA"
			capture adopath `vcqi_action' "${S_VCQI_SOURCE_CODE_FOLDER}TT"
		}
	}
	
	* Make the changes to the adopath for MISS_VCQI_SOURCE_CODE_FOLDER
	foreach b in `m' {
		if "${S_MISS_VCQI_SOURCE_CODE_FOLDER}"!= "" {
		
			* sub in string MISS_VCQI_SOURCE_CODE_FOLDER path with local b
			* so all slashes are going the same way
			if "`b'"=="/" global S_MISS_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_MISS_VCQI_SOURCE_CODE_FOLDER}","\","/",.)'
			if "`b'"=="/" global S_MISS_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_MISS_VCQI_SOURCE_CODE_FOLDER}`b'","//","/",.)'
			if "`b'"=="\" global S_MISS_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_MISS_VCQI_SOURCE_CODE_FOLDER}","/","\",.)'
			if "`b'"=="\" global S_MISS_VCQI_SOURCE_CODE_FOLDER `=subinstr("${S_MISS_VCQI_SOURCE_CODE_FOLDER}`b'","\\","\",.)'

			* Complete add or removal of path
			capture adopath `miss_vcqi_action' "${S_MISS_VCQI_SOURCE_CODE_FOLDER}DESC"
			capture adopath `miss_vcqi_action' "${S_MISS_VCQI_SOURCE_CODE_FOLDER}LIBRARY"
			capture adopath `miss_vcqi_action' "${S_MISS_VCQI_SOURCE_CODE_FOLDER}RI"
			capture adopath `miss_vcqi_action' "${S_MISS_VCQI_SOURCE_CODE_FOLDER}PLOT"
			capture adopath `miss_vcqi_action' "${S_MISS_VCQI_SOURCE_CODE_FOLDER}HW"
			capture adopath `miss_vcqi_action' "${S_MISS_VCQI_SOURCE_CODE_FOLDER}ES"
		}
	}
end
