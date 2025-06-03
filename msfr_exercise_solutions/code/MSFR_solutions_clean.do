*******************************************************************************
* Title: MSFR Costing Exercise - Solutions - Clean
* Author: Alex Chen
* Last edited: 5/2/25
* First created: 5/23/25
* Status: Complete
*******************************************************************************			


*******************************************************************************
* 01 - DOWNLOAD .CSV & CONVERT TO .DTA
*******************************************************************************
clear all

import delimited "$data_or/district_budget.csv", clear // use file path where you have saved the CSVs
save "$data_cl/district_budget", replace

import delimited "$data_or/state_budget.csv", clear // use file path where you have saved the CSVs
save "$data_cl/state_budget", replace


*******************************************************************************
* 02 - DISTRICT BUDGET -- RESHAPE DATASET , 4 WAYS
*******************************************************************************

***************************
* (1) Total quantities and costs per category, by district
***************************

clear all
use "$data_de/district_budget.dta"

* Generate IDs

gen district_id_str = subinstr(district, "District ", "", .)
gen district_id = real(district_id_str)
encode category, gen(category_num)

* Calculate total cost for each district 
collapse (sum) unit_qty unit_total_cost, by(district category_num district_id)

* Find out what the labels are to prepare for reshape
describe category_num
label list category_num

* Reshape, rename variables
reshape wide unit_qty unit_total_cost, i(district) j(category_num)
rename unit_qty1 unit_total_qty_food
rename unit_total_cost1 unit_total_cost_food
rename unit_qty2 unit_total_qty_mentors
rename unit_total_cost2 unit_total_cost_mentors
rename unit_qty3 unit_total_qty_office_supplies
rename unit_total_cost3 unit_total_cost_office_supplies

* Relabel variables
lab var district "District"
lab var unit_total_qty_food "Total quantity of food per district per year"
lab var unit_total_qty_mentors "Total quantity of mentor salaries per district per year"
lab var unit_total_qty_office_supplies "Total quantity of office supplies per district per year"
lab var unit_total_cost_food "Total cost of food per district per year"
lab var unit_total_cost_mentors "Total cost of mentor salaries per district per year"
lab var unit_total_cost_office_supplies "Total cost of office supplies per district per year"

* Sort 
sort district_id
drop district_id

* Save
save "$data_cl/district_yearly_budget_by_district", replace



***************************
* (2) - Total quantities and costs per category, districts aggregated
***************************

clear all
use "$data_de/district_budget.dta"

* Calculate total cost for each category 
collapse (sum) unit_qty unit_total_cost, by(category)

* Rename variables
rename unit_qty unit_total_qty

* Relabel variables
lab var category "Ingredient category"
lab var unit_total_qty "Total quantity across all districts per year"
lab var unit_total_cost "Total cost across all districts per year"

* Save
save "$data_cl/district_yearly_budget_by_category", replace




*******************************************************************************
* 03 - STATE BUDGET -- CLEAN DATASET 
*******************************************************************************

clear all
use "$data_de/state_budget.dta"
browse

* Encode costs

replace cost = "" if cost == "??"
encode cost, gen(cost_num)

* Clean
drop cost
rename cost_num cost

* Relabel variables
lab var funder "Funder"
lab var item "Ingredient"
lab var cost "Cost"

* Save
save "$data_cl/state_yearly_budget_cleaned", replace

