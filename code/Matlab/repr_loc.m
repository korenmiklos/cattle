%% Code calculating the US representative locations from sector bounds and technology parameters

%% Setting up parameters
%Bounds (from location quotient)
s_min   = 0;
s_max   = 30;

m_min   =   10;
m_max   =   60;

a_min = 60;
a_max = 100;

tau_s   =  0.0171;
tau_m   =  0.0052;
tau_a   =  0.0081;

betta_s     =   0.13;
betta_m     =   0.1;
betta_a     =   0.23;

%% Creating parameter vectors (s,m,a)
min_vec = [s_min m_min a_min];
max_vec = [s_max m_max a_max];
tau_vec = [tau_s tau_m tau_a];
betta_vec=[betta_s betta_m betta_a];

%%Calculating representative locations
%z_vec = -betta_vec./tau_vec.*log(1./(max_vec-min_vec).*(-betta_vec./tau_vec.*exp(-tau_vec./betta_vec.*max_vec)+betta_vec./tau_vec.*exp(-tau_vec./betta_vec.*min_vec)));
z_vec = -betta_vec./tau_vec.*log(1./(max_vec.^2.*pi-min_vec.^2.*pi).*2.*pi.*...
    ((-betta_vec./tau_vec.*max_vec.*exp(-tau_vec./betta_vec.*max_vec)+betta_vec./tau_vec.*min_vec.*exp(-tau_vec./betta_vec.*min_vec))-...
    ((betta_vec./tau_vec).^2.*exp(-tau_vec./betta_vec.*max_vec)-(betta_vec./tau_vec).^2.*exp(-tau_vec./betta_vec.*min_vec))));

%%Printing
disp('    z_s,        z_m,        z_a');
disp(z_vec);