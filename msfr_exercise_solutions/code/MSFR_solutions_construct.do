*******************************************************************************
* Title: MSFR Costing Exercise - Solutions - Construct
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
local home_visitors_unit "PTE"
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
* 02 - CONSTRUCT INGREDIENTS MATRIX -- STATE
******************************************************************************

clear all
use "$data_cl/state_yearly_budget_cleaned.dta"

***************************
* (1) Create columns
***************************
rename item ingredient
gen quantity = .
gen unit = ""
gen price = .
gen total_cost = .
gen cost_per_child_per_month = .
order funder ingredient quantity unit price total_cost cost_per_child_per_month

***************************
* (2) Replace column values
***************************

* Miscellaneous 

replace ingredient = "Lodging, transport, facilities" if ingredient == "Miscellaneous??"


* Quantities

local state_qtys state_officials_qty learning_materials_qty trainings_qty home_visitors_qty food_qty miscellaneous_qty
local i = 1
foreach qty of local state_qtys {
	replace quantity = ``qty'' in `i'
	local ++i
}

* Units*

local state_units state_officials_unit learning_materials_unit trainings_unit home_visitors_unit food_unit miscellaneous_unit
local i = 1
foreach un of local state_units {
	replace unit = "``un''" in `i'
	local ++i
}


* Prices

local state_prices state_officials_price learning_materials_price trainings_price home_visitors_price food_price miscellaneous_price
local i = 1
foreach prc of local state_prices {
	replace price = ``prc'' in `i'
	local ++i
}

* Total cost
replace total_cost = quantity * price

* Cost per child per month
replace cost_per_child_per_month = total_cost / `children_count_served' / 12


***************************
* (3) Relabel variables
***************************

lab var quantity "Total quantity per year"
lab var price "Price"
lab var unit "Unit"
lab var total_cost "Total cost per year"
lab var cost_per_child_per_month "Cost per child per month"

***************************
* (4) Clean and save
***************************

foreach var of varlist price total_cost cost_per_child_per_month {
    replace `var' = round(`var', 0.0001)
}
drop cost

* Save
save "$data_cl/ingr_yearly_state", replace
browse
*/

*******************************************************************************
* 03 - CONSTRUCT INGREDIENTS MATRIX -- DISTRICT
******************************************************************************

clear all
use "$data_cl/district_yearly_budget_by_category.dta"
browse

***************************
* (1) Create columns
***************************
gen funder = "DISTRICT"
rename category ingredient
rename unit_total_qty quantity
gen unit = ""
gen price = .
rename unit_total_cost total_cost 
gen cost_per_child_per_month = .
order funder ingredient quantity unit price total_cost cost_per_child_per_month

***************************
* (2) Replace column values
***************************

* Units

local district_units district_food_unit district_mentors_unit district_office_supplies_unit
local i = 1
foreach un of local district_units {
	replace unit = "``un''" in `i'
	local ++i
}

* Prices (average across units)
replace price = total_cost / quantity

* Cost per child per month
replace cost_per_child_per_month = total_cost / `children_count_served' / 12


***************************
* (3) Relabel variables
***************************

lab var quantity "Total quantity per year"
lab var price "Price"
lab var unit "Unit"
lab var total_cost "Total cost per year"
lab var cost_per_child_per_month "Cost per child per month"


***************************
* (4) Clean and save
***************************

foreach var of varlist price cost_per_child_per_month {
    replace `var' = round(`var', 0.0001)
}

* Save
save "$data_cl/ingr_yearly_district", replace
*/

*******************************************************************************
* 04 - CONSTRUCT INGREDIENTS MATRIX -- STATE+DISTRICT (COMBINED)
*******************************************************************************

* Combine datasets
use "$data_cl/ingr_yearly_state", clear
append using "$data_cl/ingr_yearly_district"

save "$data_cl/ingr_yearly_state_district_combined", replace
*/

*******************************************************************************
* 05 - FUNDING BREAKDOWN -- STATE vs. DISTRICT
*******************************************************************************

clear all
use "$data_cl/ingr_yearly_state_district_combined"
browse

* Calculate total cost for each category 
collapse (sum) total_cost, by(funder)

* Save
save "$data_cl/funding_yearly_breakdown", replace
*/


*******************************************************************************
* 06 - CALCULATE COST-EFFECTIVENESS RATIOS
*******************************************************************************

clear all
use "$data_cl/funding_yearly_breakdown"
browse

***************************
* (1) Add new columns
***************************

gen CE_ratio_hover = `impact_hover' / total_cost
gen CE_ratio_before_school = `impact_before_school_classes' / total_cost
gen CE_ratio_after_school = `impact_after_school_classes' / total_cost


***************************
* (2) Append new row
***************************

* Total row

preserve
collapse (sum) total_cost
gen funder = "COMBINED"
gen CE_ratio_hover = `impact_hover' / total_cost
gen CE_ratio_before_school = `impact_before_school_classes' / total_cost
gen CE_ratio_after_school = `impact_after_school_classes' / total_cost
tempfile total_row
save `total_row'
restore
append using `total_row'


***************************
* (3) Relabel variables
***************************

lab var CE_ratio_hover "Cost-effectiveness ratio of HoVER"
lab var CE_ratio_before_school "Cost-effectiveness ratio of before-school classes"
lab var CE_ratio_after_school "Cost-effectiveness ratio of after-school classes"


***************************
* (4) Clean and save
***************************

* Save
save "$data_cl/cost_effectiveness_ratios", replace
*/

