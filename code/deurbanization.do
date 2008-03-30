clear
set mem 300m
set more off

tempfile densities 
local K 100
local location ../data/census/location

/* save an empty file for future appending */
* save `location', replace emptyok

/* save a tempfile of country densities */
xmluse ../data/census/county_census.xml
ren geo fips
keep fips density

/* select top 100 counties by popdens*/
egen rank = rank(-density)
keep if rank<=`K'

keep fips
sort fips

save `densities'


foreach Y of any /*86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02*/ 03 04 05 {

	clear

	/* download data from Census website for year Y. this will not work on windows */
	shell wget http://www.census.gov/epcd/cbp/download/`Y'_data/cbp`Y'co.zip -O ~/share/data/CBP/tempfile.zip
	shell unzip  -o -d ~/share/data/CBP ~/share/data/CBP/tempfile.zip
	capture insheet using ~/share/data/CBP/cbp`Y'co.txt
	if (_rc!=0) {
		/* eljen a census kovetkezetessege */
		insheet using ~/share/data/CBP/Cbp`Y'co.txt
	}
	capture erase ~/share/data/CBP/cbp`Y'co.txt
	erase ~/share/data/CBP/tempfile.zip

	/* fips code */
	gen fips = fipstate*1000+fipscty

	/* check naics or sic */
	capture su naics
	if (_rc==0) {
		keep if substr(naics,3,4)=="----"

		gen str3 sector = "tot" if naics=="------"
		replace sector = "man" if naics=="31----"

		drop if sector==""
	}
	else {
		gen str3 sector = "tot" if sic=="----"
		replace sector = "man" if sic=="20--" | sic=="19--" /* they have different codes for manuf... */

		drop if sector==""
	}


		gen empclass=0
		replace empclass=10 	if empflag=="A"
		replace empclass=60 	if empflag=="B"
		replace empclass=175 	if empflag=="C"
		replace empclass=375 	if empflag=="E"
		replace empclass=750 	if empflag=="F"
		replace empclass=1750 	if empflag=="G"
		replace empclass=3750 	if empflag=="H"
		replace empclass=7500 	if empflag=="I"
		replace empclass=17500 	if empflag=="J"
		replace empclass=37500 	if empflag=="K"
		replace empclass=75000 	if empflag=="L"
		replace empclass=100000 if empflag=="M"

		replace emp=emp+empclass
		drop empclass

	compress

	/* reshape so that each county is one line */
	keep fips sector emp
	reshape wide emp, i(fips) j(sector) string

	foreach X of var emp*{
		replace `X' = 0 if missing(`X')
	}

	/* select top 100 counties */
	sort fips
	merge fips using `densities'
	gen byte top = (_merge==3)
	drop _merge

	collapse (sum) emptot empman, by(top)
	egen tottot = sum(emptot)
	egen totman = sum(empman)
	keep if top

	gen totshare = emptot/tottot
	gen manshare = empman/totman

	label var totshare "Share of employment in `K' most dense counties"
	label var manshare "Share of manufacturing employment in `K' most dense counties"

	gen int year = 19`Y'
	replace year = year+100 if year<1980

	keep year *share

	/* append with other years */
	append using `location'
	save `location', replace
}

/* now file is ready for final saving */
xmlsave ../data/census/location, replace


/* you can copy the graph commands from here */
label var totshare "in total employment"
label var manshare "in manufacturing"

line totshare manshare year, sort title(Share of 100 most densely populated counties) scheme(s2color)
graph export ../text/figures/deurbanization.eps, as(eps) replace

