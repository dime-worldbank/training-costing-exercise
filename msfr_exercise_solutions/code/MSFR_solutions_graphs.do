*******************************************************************************
* Title: MSFR Costing Exercise - Solutions - Graphs
* Author: Alex Chen
* Last edited: 5/24/25
* First created: 5/24/25
* Status: Complete
*******************************************************************************			


*******************************************************************************
* 01 - GRAPHS - STATE  
*******************************************************************************

***************************
* (1) Pie Graph - State funding breakdown
***************************
clear all
use "$data_cl/ingr_yearly_state.dta"

graph pie total_cost, over(ingredient) plabel(_all percent) ///
	title("State Annual Funding Breakdown by Category")			

graph export "$output_fi/Fig_1_pie_yearly_state_funding.png", replace
	
	
	
*******************************************************************************
* 02 - GRAPHS - DISTRICT  
*******************************************************************************

***************************
* (1) Pie Graph - District funding breakdown
***************************
clear all
use "$data_cl/ingr_yearly_district.dta"

graph pie total_cost, over(ingredient) plabel(_all percent) ///
	title("District Annual Funding Breakdown by Category")			

graph export "$output_fi/Fig_2_pie_yearly_district_funding.png", replace

	

***************************
* (2) Stacked Bar Chart - Combined funding breakdown
***************************
clear all
use "$data_cl/district_yearly_budget_by_district.dta"

* Sum up costs across all categories
gen total_cost = unit_total_cost_food + unit_total_cost_mentors + unit_total_cost_office_supplies

* Rank based on the cost borne by the municipality and the state
sort(total_cost) 

* Make stacked bar chart
rename unit_total_cost_food Food_costs
rename unit_total_cost_mentors Mentor_costs
rename unit_total_cost_office_supplies Office_supplies_costs

graph hbar (sum) Food_costs Office_supplies_costs Mentor_costs, over(district, label(labsize(small)) sort(total_cost) descending) stack ///
    legend(label(1 "Food costs") label(2 "Office supplies") label(3 "Mentor costs")) ///
	title("Annual Cost Ranked by Districts") ///
	ytitle("Amount (in arseetis)") ///
	ylabel(,labsize(small))
	
graph export "$output_fi/Fig_5_stacked_yearly_districts.png", replace



*******************************************************************************
* 03 - GRAPHS - STATE+DISTRICT (COMBINED)  
*******************************************************************************

***************************
* (1) Pie Graph - Combined funding breakdown
***************************
clear all
use "$data_cl/funding_yearly_breakdown.dta"

graph pie total_cost, over(funder) plabel(_all percent) ///
	title("State & District Annual Funding Breakdown by Category")	
	
graph export "$output_fi/Fig_3_pie_yearly_state_district_combined_funding.png", replace
	
	
***************************
* (2) Stacked Bar Chart - Combined funding breakdown
***************************
clear all
use "$data_cl/ingr_yearly_state_district_combined.dta" 
browse
collapse (sum) total_cost, by(ingredient funder)
graph hbar (sum) total_cost, over(funder) over(ingredient, label(labsize(small))) stack asyvars ///
	title("Annual Cost Breakdown by Category and Funder") ///
	ytitle("Amount (in arseetis)") ///
	
graph export "$output_fi/Fig_4_stacked_yearly_state_district_stacked_funding.png", replace




*******************************************************************************
* 04 - GRAPH - COMPARATIVE COST-EFFECTIVENESS
*******************************************************************************

***************************
* (1) Bar Chart - Cost-effectiveness ratios
***************************
clear all
use "$data_cl/cost_effectiveness_ratios.dta"

replace CE_ratio_hover = CE_ratio_hover / 0.00001
replace CE_ratio_before_school = CE_ratio_before_school / 0.00001
replace CE_ratio_after_school = CE_ratio_after_school / 0.00001

rename CE_ratio_hover HoVER
rename CE_ratio_before_school Before_school_classes
rename CE_ratio_after_school After_school_classes

graph bar HoVER Before_school_classes After_school_classes, over(funder) ///
	title("Cost-effectiveness Ratios of Learning Programs by Funder", size(medlarge)) ///
	ytitle("Change in test score over total cost (in 0.00001 p.p.)", size(medsmall)) ///
	
graph export "$output_fi/Fig_6_bar_cost_effectiveness_ratios.png", replace




	
