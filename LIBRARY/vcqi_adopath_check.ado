*! vcqi_adopath_check version 1.00 - Biostat Global Consulting - 2020-01-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-01-17	1.00	Dale Rhoda		Original version		
*******************************************************************************

program vcqi_adopath_check

version 14.1

* Check to see if svypd.ado is in the current adopath; if yes, we assume that
* all the VCQI programs are in the adopath.

capture which svypd

if _rc == 111 {

	di as error "The VCQI Stata programs are not currently in your adopath."
	di as error " "
	di as error "Be sure to set a global macro named S_VCQI_SOURCE_CODE_FOLDER"
	di as error "that points to the file folder holding VCQI's source code folders."
	di as error "(It holds folders named CONTROL, DESC, DIFF, PLOT, RI, SIA and TT.)"
	di as error " "
	di as error "Frequent VCQI users set this global once in the profile.do program"
	di as error "that lives in their Stata personal folder.  (Type the command 'personal'"
	di as error "to learn where Stata stores your personal files.)"
	di as error " "
	di as error "You may also set the global S_VCQI_SOURCE_CODE_FOLDER at the top"
	di as error "of Block B in your VCQI control program."
	di as error " "
	di as error "Set this global and then re-run the control program."

	exit 99

}

end