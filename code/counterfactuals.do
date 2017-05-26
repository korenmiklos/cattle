capture log close
log using ../doc/counterfactuals, text replace
set more off

clear all

local sectors services manufacturing agriculture

use ../data/wdi/wdi_2007
ren countrycode iso

merge 1:1 iso using ../data/ICP/2005/sector-price-levels, keep(master match)
drop _m
ren priceagri price3
ren pricemanu price2
ren priceserv price1

gen iso3 = iso
merge 1:m iso3 year using ../data/oecd/cities/consistent/cities, 
drop if _m==2
drop _m
egen rank = rank(-pop), by(iso)

gen y = ln(gdppercap)
label var y "GDP per capita (PPP, log)"
gen density = population/area

* only do counterfactual with largest city
* keep if rank==1

* reshape sectors into long
ren agrishare share3
ren industryshare share2
ren serviceshare share1

loca prod mfprod
ren agri_`prod' A3
ren ind_`prod' A2
ren serv_`prod' A1

forval i=1/3 {
	replace share`i' = share`i'/100
	gen lnA`i' = ln(A`i')
}

ren agriprice P3
ren industryprice P2
ren serviceprice P1

*land shares
gen beta1 = 0.13
gen beta2 = 0.10
gen beta3 = 0.23

* taus calibrated to employment gradients
gen tau3 = 0
gen tau2 = 0.22/100
gen tau1 = 1.71/100

* estimate city boundaries with constant population density
gen citydensity = pop/(surf_core+surf_hinter)
gen city_area = (surf_core+surf_hinter)
gen z2 = sqrt(city_area/3.1416)

scalar pi = 3.1416

forval m = 1/1 {

	* initial guess for rent gradient
	gen R1 = 1
	gen R2 = 0.2
	gen R3 = 0.1
	
	forval i=1/3 {
		* initial guesses
		gen R`i'low = R`i'
	}


	* iterate and hope for convergence
	forval k=1/20 {
		capture drop z*1 ztilde2
		
		* approximate sector cutoffs
		gen z2pz1 = sqrt(1+R1/R2*share2*beta2/share1/beta1)

		gen z1 = z2/z2pz1

		* there are convergence problems at the top
		forval i=1/2 {
			capture drop z`i'max
			egen z`i'max = max(cond(z2<100,z`i',.)), by(iso)
			replace z`i' = z`i'max if z2>=100
		}
		* create representative sector locations (ztilde) 
		local previous 0
		forval i=1/2 {
			gen ztilde`i' = -beta`i'/tau`i'*log(1/(z`i'^2*pi-`previous'^2*pi)*2*pi*((-beta`i'/tau`i'*z`i'*exp(-tau`i'/beta`i'*z`i')+beta`i'/tau`i'*`previous'*exp(-tau`i'/beta`i'*`previous'))-((beta`i'/tau`i')^2*exp(-tau`i'/beta`i'*z`i')-(beta`i'/tau`i')^2*exp(-tau`i'/beta`i'*`previous')))) 
			local previous ztilde`i'
		}
		
		su ztilde?
		
		* check arbitrage conditions
		local previousz 0
		local previousR 1
		forval i=1/2 {
			capture drop R`i'
			* shrink for faster convergence
			replace R`i'low = 0.5*R`i'low+0.5*exp(-tau`i'/beta`i'*(z`i'-`previousz'))*`previousR'
			gen R`i' = exp(tau`i'/beta`i'*(z`i'-ztilde`i'))*R`i'low
			local previousz z1
			local previousR R`i'low 
		}
		su R?
	}

	local previous 0
	forval i=1/2 {
		gen L`i' = pi*z`i'^2-`previous'
		local previous L`i'
	}

}

BRK

*convergence check
* scatter z1 z3 if iso=="USA"

forval i=1/2 {
	* calculate employment densities by sector
	gen N`i' = citypopulation * share`i'*(1-beta`i')
	gen density_contribution`i' = -beta`i'*ln(N`i'/L`i')
	gen location_contribution`i' = -tau`i'*ztilde`i'
	gen lnP`i' = ln(price`i')

	* estimate productivity, approximating wages with GDP/cap	
	gen lnAhat`i' = y-lnP`i'-location_contribution`i'-density_contribution`i'
	gen naive`i' = y-lnP`i'
}

* agriculture is outside the cities
egen urbanpopulation = sum(citypopulation), by(iso year)
gen ruralpopulation = population - urbanpopulation

egen urbanarea = sum(L1+L2), by(iso year)
gen ruralarea = area-urbanarea

* formulas for agriculture
	gen density_contribution3 = -beta3*ln(ruralpopulation/urbanpopulation)
	gen location_contribution3 = 0
	gen lnP3 = ln(price3)
	gen ztilde3 = 0

	* estimate productivity, approximating wages with GDP/cap	
	gen lnAhat3 = y-lnP3-location_contribution3-density_contribution3
	gen naive3 = y-lnP3

gen relative_services_naive = naive1-naive3
gen relative_services_corrected = lnAhat1-lnAhat3

label var y "GDP per capita (log)"
forval i=1/3 {
	local sector: word `i' of `sectors'
	label var ztilde`i' "Average distance of `sector' (km)"
	label var share`i' "GDP share of `sector'"
	label var location_contribution`i' "Location contribution to output per worker (`sector')"
	label var density_contribution`i' "Land contribution to output per worker (`sector')"

	foreach plot in "ztilde`i' share`i'" "location_contribution`i' share`i'" "location_contribution`i' y" "density_contribution`i' y" {
		local y: word 1 of `plot'
		local x: word 2 of `plot'
		scatter `y' `x' if rank==1, mlabel(iso) msize(tiny)
		graph export ../text/figures/`y'-`x'-largest.png, width(800) replace
		scatter `y' `x' [w=citypop]
		graph export ../text/figures/`y'-`x'-all.png, width(800) replace
	}
}


set more on
log close
