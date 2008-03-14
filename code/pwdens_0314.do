clear
set memory 25m

xmluse ..\data\pwtwdi\pwtwdi.xml
regress lnP_pwt lnY_pwt lnpwdens pwdensX if year==2000, robust
regress lnP_pwt lnY_pwt lnpwdens pwdensX if year==1996 & benchm_96, robust
regress relp_C lnY_pwt lnpwdens pwdensX if year==1996, robust