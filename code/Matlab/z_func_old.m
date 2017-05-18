function diff=z_func(z_vec_p)

global params;

%Number of columns
no_vecs = size(z_vec_p,2);

for kk=1:no_vecs
z_vec   =   z_vec_p(:,kk)';
%Creating parameters
params_names    =   fieldnames(params);
no_params   =   length(params_names);
for ii=1:no_params
    eval([params_names{ii} '=params.' params_names{ii} ';']);
end;

min_vec = [0 z_vec(1,1) z_vec(1,2)];
max_vec = [z_vec(1,1) z_vec(1,2) z3];

%%Calculating representative locations
switch city_type
    case 'linear'
        ztilde_vec = -betta_vec./tau_vec.*log(1./(max_vec-min_vec).*...
            (-betta_vec./tau_vec.*exp(-tau_vec./betta_vec.*max_vec)+betta_vec./tau_vec.*exp(-tau_vec./betta_vec.*min_vec)));
    case 'circular'
        ztilde_vec = -betta_vec./tau_vec.*log(1./(max_vec.^2.*pi-min_vec.^2.*pi).*2.*pi.*...
            ((-betta_vec./tau_vec.*max_vec.*exp(-tau_vec./betta_vec.*max_vec)+betta_vec./tau_vec.*min_vec.*exp(-tau_vec./betta_vec.*min_vec))-...
            ((betta_vec./tau_vec).^2.*exp(-tau_vec./betta_vec.*max_vec)-(betta_vec./tau_vec).^2.*exp(-tau_vec./betta_vec.*min_vec))));
end;

z_vec(1,3)  =   z3;

params_short_names = {'alfa' 'betta' 'tau' 'ztilde' 'z'};
no_params_short     =   length(params_short_names);
for ii=1:no_params_short
    for jj=1:3
        eval([params_short_names{ii} num2str(jj) '=' params_short_names{ii} '_vec(1,' num2str(jj) ');']);
    end;
end;

switch city_type
    case 'linear'
        diff(1,kk) = alfa1*betta1/(alfa2*betta2)-(z1)/(z2-z1)*...
            exp(tau1/betta1*(z1-ztilde1)-tau2/betta2*(z1-ztilde2));
        diff(2,kk) = alfa2*betta2/(alfa3*betta3)-(z2-z1)/(z3-z2)*...
            exp(tau2/betta2*(z2-ztilde2)-tau3/betta3*(z2-ztilde3));
    case 'circular'
        diff(1,kk) = alfa1*betta1/(alfa2*betta2)-(z1^2-0^2)/(z2^2-z1^2)*...
            exp(tau1/betta1*(z1-ztilde1)-tau2/betta2*(z1-ztilde2));
        diff(2,kk) = alfa2*betta2/(alfa3*betta3)-(z2^2-z1^2)/(z3^2-z2^2)*...
            exp(tau2/betta2*(z2-ztilde2)-tau3/betta3*(z2-ztilde3));
end;
end;

