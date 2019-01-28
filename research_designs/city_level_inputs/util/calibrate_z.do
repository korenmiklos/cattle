confirm numeric variable rural_density city_employment
confirm new variable z z_tilde city_area

tempvar predicted_city_employment diff
tempname tolerance gap step_size

* start with large guess, can only be reduced
gen double z = sqrt(city_employment/rural_density)/pi
gen double city_area = .
gen double `predicted_city_employment' = .
gen double `diff' = .

scalar `tolerance' = .05
scalar `gap' = 999
scalar `step_size' = 0.25
while `gap'>`tolerance' {
	z_to_tilde z_tilde z tau/beta
	qui replace city_area = z^2 * pi
	qui replace `predicted_city_employment' = city_area * rural_density * exp((z - z_tilde)*tau/beta)
	
	qui replace `diff' = abs(ln(`predicted_city_employment')-ln(city_employment))
	su `diff'
	scalar `gap' = r(max)
	
	qui replace z = z/sqrt(`predicted_city_employment'/city_employment)^`step_size'
	drop z_tilde
}
z_to_tilde z_tilde z tau/beta
