*******************************************************************************
* Title: MSFR Costing Exercise - Master Replication Do-File
* Author: Alex Chen
* Last edited: 5/27/25
* First created: 5/27/25
* Status: Completed
*******************************************************************************			

*******************************************************************************
* 01 - SET UP WORKSPACE  
*******************************************************************************


capture log close
	drop _all
	clear all
	set more off, 
	clear mata
	version 18
	cap log close
	set varabbrev on


	*****************************************************
	* Define base directory
	*****************************************************
	
	global user "C:/Users/wb644717/OneDrive - WBG/Alex Chen - OneDrive/- DIME Files - Costing resources/04 Public Goods/05 Trainings/06.11.25_MSFR_Costing/msfr_exercise_solutions"
	* Filepath to the parent directory
	
	*****************************************************
	* Filepaths
	*****************************************************

	global data = "$user/data"
		global data_de = "$user/data/1_De-identified"
		global data_cl = "$user/data/2_Cleaned"
		global data_or = "$user/data/0_Original"
	global code = "$user/code"
	global output = "$user/output"
		global output_fi = "$user/output/figures"
		global output_ta = "$user/output/tables"

	
 /* Install packages

		* If needed, install the required packages as follows:
		local commands = "estout ietoolkit kmatch ritest moremata ivreg2 ranktest"
		foreach c of local commands {
			*ssc uninstall `c'
			qui capture which `c' 
			qui if _rc!=0 {
				noisily di "This command requires '`c''. The package will now be downloaded and installed."
				ssc install `c'
			}
		}
*/


*******************************************************************************
* 02 - RUN DO-FILES
*******************************************************************************
clear all

********************************************************************************************
* do "$code/Instructor set-up/MSFR_instructor_set-up" // No need to run this if downloading replicability package that already contains the CSV datasets. This do-file allows the user to make directories and generate the original datasets from scratch.
	********************************************************************************************
	do "$code/MSFR_solutions_clean" 
	do "$code/MSFR_solutions_construct"
	do "$code/MSFR_solutions_graphs"
	do "$code/MSFR_solutions_tables"
	

