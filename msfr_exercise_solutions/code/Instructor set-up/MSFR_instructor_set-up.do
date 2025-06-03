*******************************************************************************
* Title: MSFR Costing Exercise - Set-Up - Dataset generation (.dta and .csv)
* Author: Alex Chen
* Last edited: 5/22/25
* First created: 5/22/25
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
	* Username
	*****************************************************
	
	global user "C:/Users/wb644717/OneDrive - WBG/Alex Chen - OneDrive/- DIME Files - Costing resources/04 Public Goods/05 Trainings/06.11.25_MSFR_Costing/msfr_exercise_solutions"
	* Filepath to the folder for this exercise  
	
	
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

 *****************************************************
	* Make Directories
 *****************************************************

	mkdir "$user"
	mkdir "$data"
		mkdir "$data_or"
		mkdir "$data_de"
		mkdir "$data_cl"
	mkdir "$code"
	mkdir "$output"
		mkdir "$output_fi"
		mkdir "$output_ta"

	
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
* 02 - PREP DATASET 1 - DISTRICT BUDGET  
*******************************************************************************
clear all

***************************
* (1) Create districts 
***************************

* Generate "base" of 12 months per district (240 obs, non-random)

set obs 240  // 20 districts × 12 months

gen district_id = ceil(_n / 12)
gen month_id = mod(_n, 12)
replace month_id = 12 if month_id == 0
gen from_base = 1
gen id = _n   
tempfile base
save `base'

* Generate remaining obs (4760 obs, random)
clear
set seed 12345

set obs 4760

gen district_id = runiformint(1, 20)
gen month_id = runiformint(1, 12)
gen from_base = 0
gen id = _n + 240   // Continue from forced IDs
tempfile rand
save `rand'

* Combine forced + random datasets
use `base', clear
append using `rand'

* Drop helper variables
drop from_base


***************************
* (2) Define variables 
***************************

* Numerical variables

gen unit_qty = runiformint(1,20) // unit qty
gen unit_price = round(runiform()*3, 0.01) // unit price
gen unit_total_cost = unit_qty * unit_price // unit price * unit qty

tostring district_id, gen(district_str) // adjust district (decode/rename)
gen district = "District "+ district_str
drop district_str

* Relabel months

label define month_lbl 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
gen month_name = month_id
label values month_name month_lbl
decode month_name, gen(month)
drop month_name

* Categories - Food + Office Supplies

gen category_id = runiformint(1,2) // office supplies + food

* Categories - Mentors (2 mentors, each get $3/month)

set seed 12345
gen rand = runiform() 
sort month_id rand
gen category_id_me = 0
by district month_id (rand), sort: replace category_id_me = 1 if _n == 1
replace category_id = 3 if category_id_me == 1 
drop rand category_id_me

label define category_lbl 1 "Office supplies" 2 "Food" 3 "Mentors"
label values category_id category_lbl
decode category_id, gen(category)
drop category_id

replace unit_qty = 2 if category == "Mentors"
replace unit_price = 5 if category == "Mentors"
replace unit_total_cost = unit_qty * unit_price if category == "Mentors"


***************************
* (3) Finalize dataset
***************************

* Order variables

keep district month category unit_qty unit_price unit_total_cost
order district month category unit_qty unit_price unit_total_cost

* Save
save "$data_de/district_budget", replace
browse

*/

*******************************************************************************
* 03 - PREP DATASET 2 - STATE BUDGET  
*******************************************************************************
clear all

set seed 12345
set obs 6
gen id = _n

***************************
* (1) Create variables 
***************************

* Funder
gen funder = "STATE" 

* Item
gen str20 item = "" 

local items "State_officials Learning_materials Trainings Home_visitors Food Miscellaneous??"
forvalues i = 1/6{
	replace item = word("`items'",`i') in `i'
}
replace item = subinstr(item, "_", " ", .)

* Cost
gen cost_num = runiformint(10000, 99999) 
tostring cost_num, gen(cost) // make into strings
replace cost = "" if item == "Trainings" 
replace cost = "??" if item == "State officials"
drop id cost_num

* Save
save "$data_de/state_budget", replace
browse

*/



*******************************************************************************
* 04 - CONVERT .DTA to .CSV
*******************************************************************************

use "$data_de/district_budget", clear
export delimited "$data_or/district_budget"

use "$data_de/state_budget", clear
export delimited "$data_or/state_budget"
