set memory 25m

use MSA_02
regress rel_empl lnpop
sort lnpop
scatter rel_empl rel_empl_lnpop lnpop, msymbol(o i) connect(i l)

regress rel_empl pop_dens
sort pop_dens
scatter rel_empl rel_empl_pred pop_dens, msymbol(o i) connect(i l)

use US_states_02
regress rel_empl lnpop_dens
sort lnpop_dens
scatter rel_empl rel_empl_pred lnpop_dens, msymbol(o i) connect(i l)
regress rel_empl lnpop_dens lnpci
regress rel_empl lnpci urban
regress rel_serv_empl urban
regress rel_serv_empl lnpop_dens

use pwtwdi
regress rel_empl_stan urban if year==2000
regress rel_empl_stan dens if year==2000
regress rel_serv_empl_stan urban if year==2000
regress rel_serv_empl_stan dens if year==2000