*! vcqi_excel_convert_to_letter Version 1.0 - Biostat Global Consulting - 2015-10-09
*
* I have coded up the algorithm from
* http://stackoverflow.com/questions/22708/how-do-i-find-the-excel-column-name-that-corresponds-to-a-given-integer
* and it seems to work well.
*
* I use the same inputs and outputs as Mary's earlier program.
*

capture program drop vcqi_excel_convert_to_letter
program vcqi_excel_convert_to_letter, rclass  

version 14
	
	* Input:
	*  1 Excel column number reference  
	
	args n
	
	local result
	while (`n'>0) {
		local --n  
		local name `=char(`=65+mod(`n',26)')'`name'
		local n = int(`n'/26)
	}
	return local ConvertToLetter `name'

end

