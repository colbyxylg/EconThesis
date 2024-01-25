* 4/3/21


*Keep the below
use "/Users/colby/Desktop/Thesis/Data/IPUMS_2019/USA_00009/Colby Thesis Data.dta"

log using "/Users/colby/Desktop/Thesis/Data/IPUMS_2019/USA_00009/4.3.21.smcl", append

*Summary statistics
*use this
tab race
tab race, nol
tab race_sp, nol

* raced is too detailed
tab raced

tab sex
	*no spouse or partner link are single people. level 11 and 21 
tab sprule 
tab marst
*2019 is cleaner than 2018 bc no third category for incomplete info
tab ssmc
*male
tab ssmc if sex == 1
*female
tab ssmc if sex == 2
*moved within the last year
tab migrate1
*super interesting at the county level but i don't have housing info that specific? 
	*too narrow for my scope
tab migrate1d
*time since moved into a new residence - i think migrate1 is better
tab movedin
tab educd
tab educd if sprule != 0


* Create race categories for HH head
	* race == 7 is "Other race, nec"?? 
*white
gen hhrace = 1 if race == 1
*Black
replace hhrace = 2 if race == 2
*Native
replace hhrace = 3 if race == 3
*Asian
replace hhrace = 4 if race == 4 | race == 5 | race == 6
*Mixed 2 races
replace hhrace = 5 if race == 8
*Mixed 3 races
replace hhrace = 6 if race == 9
*Other race
replace hhrace = 7 if race == 7

tab hhrace 

* Create race categories for Spouse 
*white
gen hhrace_sp = 1 if race_sp == 1
*Black
replace hhrace_sp = 2 if race_sp == 2
*Native
replace hhrace_sp = 3 if race_sp == 3
*Asian
replace hhrace_sp = 4 if race_sp == 4 | race_sp == 5 | race_sp == 6
*Mixed 2 races
replace hhrace_sp = 5 if race_sp == 8
*Mixed 3 races
replace hhrace_sp = 6 if race_sp == 9
*Other race
replace hhrace_sp = 7 if race_sp == 7

tab hhrace_sp


* Create race matching categories for partnered people
	* race match is true (1) if the head and the spouse have the same race
	* race match is false (0) if the head and the spouse don't have the same race_sp
		*thus their difference will NOT equal 0

gen racematch = 1 if hhrace - hhrace_sp == 0 
replace racematch = 0 if hhrace - hhrace_sp != 0
replace racematch = . if sprule == 0

tab racematch

*Create educational attainment categories
	
gen lessHS = educd > 1 & educd < 62
gen HSgrad = educd == 63 | educd == 64
gen somecoll = educd == 65 | educd == 71 | educd == 81
gen collgrad = educd == 101 
gen graddeg = educd == 114 | educd == 115 | educd == 116

*Create SPOUSAL educational attainment categories
gen lessHS_sp = educd_sp > 1 & educd_sp < 62
gen HSgrad_sp = educd_sp == 63 | educd_sp == 64
gen somecoll_sp = educd_sp == 65 | educd_sp == 71 | educd_sp == 81
gen collgrad_sp = educd_sp == 101 
gen graddeg_sp = educd_sp == 114 | educd_sp == 115 | educd_sp == 116

*Includes partnered people
sum lessHS-graddeg_sp

* this replaces all the non-values with a 
for var less-HS-graddeg_sp: replace X=. if sprule == 0

*This gives the educational attainment info for partnered people 
sum lessHS-graddeg_sp if sprule != 0

*Create educational categorizations for household head and spouse
gen edcount = 1 if lessHS == 1
replace edcount = 2 if HSgrad == 1
replace edcount = 3 if somecoll == 1
replace edcount = 4 if collgrad == 1
replace edcount = 5 if graddeg == 1

gen edcount_sp = 1 if lessHS_sp == 1
replace edcount_sp = 2 if HSgrad_sp == 1
replace edcount_sp = 3 if somecoll_sp == 1
replace edcount_sp = 4 if collgrad_sp == 1
replace edcount_sp = 5 if graddeg_sp == 1

tab edcount
tab edcount_sp

*Create educational distance - only magnitude matters
gen eddist = edcount - edcount_sp
replace eddist = eddist * (-1) if eddist < 0 
tab eddist

tab eddist ssmc

gen notzeroeddist = eddist
replace notzeroeddist = . if eddist == 0
tab notzeroeddist

 
*create a samesex variable that's 1 if a samesex married couple 
gen samesex = ssmc == 2
replace samesex = 0 if ssmc == 0
replace samesex = . if ssmc == 1
tab samesex 
tab eddist samesex

*ttest: pop mean of eddist is the same for opposite sex and same sex couples
*on avg straight couples have slightly lower ed distance than same sex couples
ttest eddist, by(samesex)

tab eddist, gen(eddistind)
sum eddistind*

*hypothesis that the population mean of eddist 1 is the same for opposite sex and same sex couples
ttest eddistind1, by(samesex)

*hypothesis that the population mean of eddist 5 is the same for opposite sex and same sex couples
ttest eddistind5, by(samesex)

*almost 50/50 for gay men and lesbian women
tab samesex sex 

*generate same-sex male and female couples --> samesex_m = 1 MALE
gen samesex_m = samesex == 1 & sex == 1
replace samesex_m = . if samesex == 0

tab samesex_m

*ttest: pop mean of eddist is the same for male ss and female ss couples
ttest eddist, by(samesex_m)
*ttest: pop mean of max eddist is the same for mae ss and female ss couples
ttest eddistind5, by(samesex_m)
*ttest: pop mean of 0 eddist (aka perf homog) is the same for mae ss and female ss couples
ttest eddistind1, by(samesex_m)
**ttest pop means of 0 eddist is the same for starights and gays
ttest eddistind1, by(samesex)

**test opposite sex couples and female same-sex couples
ttest eddist if samesex == 0 | samesex_m == 0, by(samesex)


** for haven't directly written in thesis about that test
 

*location
tab met2013
tab met2013, nol

sort met2013 

save "/Users/colby/Desktop/Thesis/Data/IPUMS_2019/USA_00009/Colby Thesis Data v2.dta", replace 

bysort met2013 : gen pop = _N 
tab pop

*cutoffs 
	* weight is frequency weight ? 
tabstat pop [fweight=perwt] if met2013 != 0, stats(p25 p50 p75 p95)

*location cutoffs
gen rural = pop < 10445 | met2013 == 0
gen smallcity = (pop > 10444 & pop < 32378)
gen midcity = (pop > 32377 & pop < 70839)
gen bigcity = (pop > 70838 & pop < .) & met2013 != 0 

tab rural
tab smallcity
tab midcity
tab bigcity

tab met2013 if bigcity == 1
tab met2013 if rural == 1
sum bigcity if met2013 == 0



for var rural-bigcity : ttest eddist , by(X)
*ex: coef: 1 unit increase in small city is associated with a a decrease in educaional distance by .008 for 
reg eddist smallcity midcity bigcity 

*straights
reg eddist smallcity midcity bigcity if samesex == 0 [aweight = perwt]
*LGBT
reg eddist smallcity midcity bigcity if samesex == 1 [aweight = perwt]
*big city LGBT and not rural ??
reg eddist bigcity if samesex == 1 & rural == 0 [aweight = perwt]

*lesbians *aweight relative to eo
reg eddist smallcity midcity bigcity if samesex_m == 0 [aweight = perwt]
*gays
reg eddist smallcity midcity bigcity if samesex_m == 1 [aweight = perwt]


*for notzeroeddist
*any couple
reg notzeroeddist smallcity midcity bigcity 
*straights
reg notzeroeddist smallcity midcity bigcity if samesex == 0 [aweight = perwt]
*LGBT
reg notzeroeddist smallcity midcity bigcity if samesex == 1 [aweight = perwt]
*big city LGBT and not rural ??
reg notzeroeddist bigcity if samesex == 1 & rural == 0 [aweight = perwt]

*lesbians *aweight relative to eo
reg notzeroeddist smallcity midcity bigcity if samesex_m == 0 [aweight = perwt]
*gays
reg notzeroeddist smallcity midcity bigcity if samesex_m == 1 [aweight = perwt]


*ex: living in a small city is assoicated with a X in max educational distance 
reg eddistind5 smallcity midcity bigcity 
*straights
reg eddistind5 smallcity-bigcity if samesex == 0 [aweight = perwt]
*LGBT
reg eddistind5 smallcity-bigcity if samesex == 1 [aweight = perwt]
*lesbians
reg eddistind5 smallcity-bigcity if samesex_m == 0 [aweight = perwt]
*gays
reg eddistind5 smallcity-bigcity if samesex_m == 1  [aweight = perwt]

tab sprule, nol

* Create a larger bucket, large educational distance 
gen eddistlarge = eddist > 1 & eddist != . 
replace eddistlarge = . if sprule == 0
tab eddistlarge


*ex: 1 unit increase in small city is assoicated with a X in  a large ed distance 
reg eddistlarge smallcity midcity bigcity 
*straights
reg eddistlarge smallcity midcity bigcity if samesex == 0 [aweight = perwt]
*LGBT
reg eddistlarge smallcity midcity bigcity if samesex == 1 [aweight = perwt]
*lesbians
reg eddistlarge smallcity midcity bigcity if samesex_m == 0 [aweight = perwt]
*gays
reg eddistlarge smallcity midcity bigcity if samesex_m == 1  [aweight = perwt]

**look if living in a big city is associated with a - big city is associaed with smallest ed dist of 1
reg eddistind1 smallcity midcity bigcity 

tab movedin
tab migrate1
tab migrate1d, nol

*generate mover 
	* mover = 0: if not a mover - in the same house and diff house within county
	* mover = 1: if moved - diff house between counties or states or were abroad
gen mover = 0 if migrate1d == 10 | migrate1d == 23
replace mover = 1 if migrate1d > 23 & migrate1d < .

tab mover

*LGBT: see if living in cities if not moved has an impact on educational distance 
reg eddistlarge smallcity midcity bigcity if samesex == 1 & mover == 0 [aweight = perwt]


tab rural edcount
tab bigcity edcount
tab rural if edcount < 4

** 3/7 RACE

*
tab racematch rural
tab racematch smallcity 
tab racematch midcity
tab racematch bigcity

*pop means of racematch is the same for starights and gays
ttest racematch, by(samesex) 

*pop means of racematch is the same for lesbians and gays
ttest racematch, by(samesex_m) 


*Racial homogamous couples: see if moreless likely to be racial homog if live in a city
reg racematch smallcity midcity bigcity
*Racial homogamy for straight couples
reg racematch smallcity midcity bigcity if samesex == 0 [aweight = perwt]
*Racial homogamy for LGBT couples
reg racematch smallcity midcity bigcity if samesex == 1 [aweight = perwt]
*Racial homogamy for lesbians
reg racematch smallcity midcity bigcity if samesex_m == 0 [aweight = perwt]
*Racial homogamy for gays
reg racematch smallcity midcity bigcity if samesex_m == 1 [aweight = perwt]


*see if more less likely to have a large ed dist if live in a particiular place if people have same race
reg eddistlarge smallcity midcity bigcity if racematch == 1 [aweight = perwt]
*straight
reg eddistlarge smallcity midcity bigcity if racematch == 1 & samesex == 0 [aweight = perwt]
*LGBT race homogomouse
reg eddistlarge smallcity midcity bigcity if racematch == 1 & samesex == 1 [aweight = perwt]


*from Fu (2001) paper
	*look at race and educational attainment
	*want to see if lower educated woman marrying man of less desirable racial group
tab hhrace edcount_sp
tab hhrace_sp edcount

*Summary Stats

	*table 1 / Appendix C
tab sex
tab sprule
tab marst
tab samesex
tab samesex if sex == 1 
tab samesex if sex == 2
tab migrate1

tab hhrace 
tab citysize

	*tab 1.5 / Appendix D
	*in paper
sum lessHS-graddeg if sprule != 0
sum lessHS_sp-graddeg_sp if sprule != 0

tab eddist
tab notzeroeddist
tab eddistlarge

	*table2 / Appendix E
	*in tables
tab edcount
tab samesex edcount
tab samesex_m edcount

tab samesex eddist 
tab samesex_m eddist



gen citysize = 1 if rural == 1
replace citysize = 2 if smallcity == 1
replace citysize = 3 if midcity == 1
replace citysize = 4 if bigcity == 1

tab citysize 
tab samesex citysize
tab samesex_m citysize

	*table 2.5 / Appendix 
tab racematch
tab racematch rural
tab racematch smallcity
tab racematch midcity
tab racematch bigcity


	*table 4
tab samesex eddist if citysize == 1
tab samesex_m eddist if citysize == 1
tab samesex eddist if citysize == 2
tab samesex_m eddist if citysize == 2
tab samesex eddist if citysize == 3
tab samesex_m eddist if citysize == 3
tab samesex eddist if citysize == 4
tab samesex_m eddist if citysize == 4

	*table5
ttest eddist, by(samesex)
ttest eddist, by(samesex_m)
ttest eddistind5, by(samesex)

ttest eddistind5, by(samesex_m)
	*using notzeroeddist
ttest notzeroeddist, by(samesex)
ttest notzeroeddist, by(samesex_m)	
ttest notzeroeddist if samesex == 0 | samesex_m == 0, by(samesex)



*3.13 redo

ttest eddist by(samesex=0, samesex_m=0)

	*ss couples nearly 2x as likely as straight couples to have a maximum educational distance. thin dating market or diff pref? diff pref will be true if:
		*the max eddist (or large eddist) for same sex couples does NOT decrease as metro area gets bigger --> as theeir dating market thickens

	*living in a mid and large city relative to a rural area is ass. with an increase in prob of exhibiting a max ed dist... so as market thickens, ss couples not choosing partners with similar levels of education
reg eddistind5 smallcity-bigcity if samesex == 1 [aweight = perwt]
	*not significant
reg eddistlarge smallcity-bigcity if samesex == 1 [aweight = perwt] 


*3.28

tab edcount rural
tab edcount smallcity
tab edcount midcity
tab edcount bigcity
