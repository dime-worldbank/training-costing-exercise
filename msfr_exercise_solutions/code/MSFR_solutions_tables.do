*******************************************************************************
* Title: MSFR Costing Exercise - Solutions - Tables
* Author: Alex Chen
* Last edited: 5/24/25
* First created: 5/24/25
* Status: Complete
*******************************************************************************			


*******************************************************************************
* 01 - SET PARAMETERS (LOCALS)
******************************************************************************
// The following parameters are gathered from information collected throughout the exercise.


***************************
* Overall Parameters
***************************
local program_months 12
local districts_count 20
local families_count 5000
local children_count_served = 5000 * 1.2


***************************
* State Budget Items
***************************

* State officials
local state_officials_qty = 15*20
local state_officials_unit "PTE"
local state_officials_price 85

* Learning materials
local learning_materials_qty = 3 * `children_count_served'
local learning_materials_unit "Bundle"
local learning_materials_price = 62486 / `learning_materials_qty'

* Home visitors
local home_visitors_qty = 75 * 20
local home_visitors_unit "Person"
local home_visitors_price = 85294 / `home_visitors_qty'

* Trainings
local trainings_qty = `home_visitors_qty' * 2 * 3
local trainings_unit "Person*Course*Day"
local trainings_price 4

* Food
local food_qty = `children_count_served'
local food_unit "Beneficiary"
local food_price = 37222 / `food_qty'

* Miscellaneous
local miscellaneous_qty = `home_visitors_qty' * 2 * 3
local miscellaneous_unit "Person*Course*Day"
local miscellaneous_price = 13756 / `miscellaneous_qty'


***************************
* District Budget Items
***************************

* Food
local district_food_unit "Beneficiary"

* Mentors
local district_mentors_unit "Mentor"

* Office supplies
local district_office_supplies_unit "Beneficiary"


***************************
* Impact Measures
***************************

* Impact
local impact_hover = 3.5
local impact_before_school_classes = 1.6
local impact_after_school_classes = 1.9


*/

*******************************************************************************
* 02 - CONSTRUCT TABLE 1 - PERCENTAGE RANK OF INGREDIENTS
******************************************************************************

clear all
use "$data_cl/ingr_yearly_state.dta"

***************************
* (1) Append new row
***************************

* Total row

preserve
local children_count_served = 5000 * 1.2
collapse (sum) total_cost
gen ingredient = "Total"
gen cost_per_child_per_month = total_cost / `children_count_served' / 12
gen annual_cost_per_child = total_cost / `children_count_served'
tempfile total_row
save `total_row'
restore
append using `total_row'


***************************
* (2) Add new columns
***************************

* Scalar for annual price
summarize cost_per_child_per_month if ingredient == "Total"
scalar monthly_total_cost_per_child = r(mean)

* Annual cost per child
replace annual_cost_per_child = cost_per_child_per_month * 12

* Percent of total
gen percent_of_total = cost_per_child_per_month / monthly_total_cost_per_child * 100


***************************
* (4) Clean and save
***************************

* Sort descending %, with total at bottom
gsort -percent_of_total
gen total_pos = 0
replace total_pos = 1 if ingredient == "Total"
sort total_pos
drop total_pos
destring _all, replace

* Drop variables and round
drop total_cost
drop quantity
drop unit
drop price
foreach var of varlist cost_per_child_per_month annual_cost_per_child percent_of_total {
    replace `var' = round(`var', 0.0001)
}

* ID, all except total
gen ranking = _n
replace ranking = . if ingredient == "Total"
order ranking, before(ingredient)


* Rename header row
lab var ranking "Ranking"
lab var ingredient "Ingredient"
lab var cost_per_child_per_month "Monthly cost per child"
lab var annual_cost_per_child "Annual cost per child"
lab var percent_of_total "Percent of total"


* Save as .csv
export delimited using "$output_ta/Table_1_percentage_rank_ingredients.csv", replace 

*/



*******************************************************************************
* 03 - CONSTRUCT TABLE 2A - STATE INGREDIENTS MATRIX
******************************************************************************

clear all
use "$data_cl/ingr_yearly_state.dta"

***************************
* (1) Add new columns
***************************

* Monthly price
gen monthly_price = price / 12

* Monthly cost
gen monthly_cost = quantity * price / 12

* Cost per child per year
gen cost_per_child_per_year = cost_per_child_per_month * 12


***************************
* (2) Append new row
***************************

* Total row

preserve
collapse (sum) monthly_cost cost_per_child_per_month total_cost cost_per_child_per_year
gen ingredient = "Total"
tempfile total_row
save `total_row'
restore
append using `total_row'

***************************
* (3) Clean and save
***************************

* Order variables
order funder ingredient quantity unit monthly_price monthly_cost cost_per_child_per_month price total_cost cost_per_child_per_year
destring _all, replace

* Round
foreach var of varlist monthly_price monthly_cost cost_per_child_per_month price total_cost cost_per_child_per_year {
    replace `var' = round(`var', 0.0001)
}

* Rename header row
rename price annual_price
rename total_cost total_cost_per_year

lab var ingredient "Ingredient"
lab var quantity "Quantity per year"
lab var unit "Unit"
lab var monthly_price "Monthly price"
lab var monthly_cost "Monthly cost"
lab var cost_per_child_per_month "Cost per child per month"
lab var annual_price "Annual price"
lab var total_cost_per_year "Total cost per year"
lab var cost_per_child_per_year "Cost per child per year"


* Save as .csv

export delimited using "$output_ta/Table_2A_ingr_state.csv", replace 

*/




*******************************************************************************
* 04 - CONSTRUCT TABLE 2B - DISTRICT INGREDIENTS MATRIX
******************************************************************************

clear all
use "$data_cl/ingr_yearly_district.dta"

***************************
* (1) Add new columns
***************************

* Monthly price
gen monthly_price = price / 12

* Monthly cost
gen monthly_cost = quantity * price / 12

* Cost per child per year
gen cost_per_child_per_year = cost_per_child_per_month * 12


***************************
* (2) Append new row
***************************

* Total row

preserve
collapse (sum) monthly_cost cost_per_child_per_month total_cost cost_per_child_per_year
gen ingredient = "Total"
tempfile total_row
save `total_row'
restore
append using `total_row'

***************************
* (3) Clean and save
***************************

* Order variables
order funder ingredient quantity unit monthly_price monthly_cost cost_per_child_per_month price total_cost cost_per_child_per_year
destring _all, replace

* Rename header row
rename price annual_price
rename total_cost total_cost_per_year

lab var ingredient "Ingredient"
lab var quantity "Quantity per year"
lab var unit "Unit"
lab var monthly_price "Monthly price"
lab var monthly_cost "Monthly cost"
lab var cost_per_child_per_month "Cost per child per month"
lab var annual_price "Annual price"
lab var total_cost_per_year "Total cost per year"
lab var cost_per_child_per_year "Cost per child per year"


* Save as .csv

export delimited using "$output_ta/Table_2B_ingr_district.csv", replace 

*/