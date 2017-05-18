% Code to calculate z1, z2 using the model and data

clc; clear all; close all;

global params;

%Setting up parameters
city_type   =   'linear'; %'circular' or 'linear'

tau_s   =  0.0171;
tau_m   =  0.0052;
tau_a   =  0.0081;

betta_s     =   0.13;
betta_m     =   0.1;
betta_a     =   0.23;

alfa_s  =   0.7695;
alfa_m  =   0.2192;
alfa_a  =   0.0113;

%creating parameter vectors
tau_vec = [tau_s tau_m tau_a];
betta_vec=[betta_s betta_m betta_a];
alfa_vec =[alfa_s alfa_m alfa_a];

%Creating parameter structure for easy function transfer
params.tau_vec = tau_vec;
params.betta_vec = betta_vec;
params.alfa_vec = alfa_vec;
params.city_type = city_type;

% import data from stata
fid = fopen('../../data/internal_val.txt','r');
XX  = fscanf(fid,'%f',[8 1458]);
fclose(fid);
XX  = XX';

vars_cell = {'city_id' 'sector' 'land_share' 'z3_area' 'z3_dist' 'emp_share' 'est_share' 'emp_w_distance'};
no_vars = length(vars_cell);

no_sec = 3;                     %number of sectors
no_cit = size(XX,1)/no_sec;     %number of cities

%Creating no_sec x no_cit matrices of variables
for ii=1:no_vars
    eval([vars_cell{ii} '= reshape(XX(:,' num2str(ii) '),no_sec,no_cit)'';']);
end;

%For each city calculate data implied sector border locations
%[z1_data,z2_data] 
z3 = z3_area(:,1); %or z3_dist(:,1)
switch city_type
    case 'circular'
        z1_data = sqrt(land_share(:,1)).*z3;
        z2_data = sqrt(land_share(:,2).*z3.^2.+z1_data.^2);
    case 'linear'
        z1_data = land_share(:,1).*z3;
        z2_data = land_share(:,2).*z3+z1_data;
end;
z_data_matr = [z1_data z2_data z3];

%For each city calculate model implied sector border locations [z1,z2]
%assuming circular cities
z_vec      =    zeros(no_cit,3);
z_vec(:,3) =    z3;
diff       =    zeros(no_cit,2);
exitf      =    NaN(no_cit,1);
ztilde_vec =    NaN(no_cit,3);
tic
for jj=1:no_cit
    params.z3   =   z3(jj);
    z_vec0 = z_data_matr(jj,1:2)';     %Using data as starting values
    options = optimset('display','off');
    %[z_vec(jj,1:2), diff(jj,1:2), exitf(jj,1)] = fsolve(@z_func,z_vec0,options);    
    itmax   =   100;
    crit    =  1e-6;
    [z_vec_p(1:2,1), exitf(jj,1)] = csolve(@z_func,z_vec0,[],crit,itmax);
    z_vec(jj,1:2) = z_vec_p';

    %Calculating ztilde for each
    min_vec = [0 z_vec(jj,1) z_vec(jj,2)];
    max_vec = [z_vec(jj,1) z_vec(jj,2) z3(jj)];

%%Calculating representative locations
    switch city_type
        case 'linear'
            ztilde_vec(jj,:) = -betta_vec./tau_vec.*log(1./(max_vec-min_vec).*...
                (-betta_vec./tau_vec.*exp(-tau_vec./betta_vec.*max_vec)+betta_vec./tau_vec.*exp(-tau_vec./betta_vec.*min_vec)));
        case 'circular'
            ztilde_vec(jj,:) = -betta_vec./tau_vec.*log(1./(max_vec.^2.*pi-min_vec.^2.*pi).*2.*pi.*...
                ((-betta_vec./tau_vec.*max_vec.*exp(-tau_vec./betta_vec.*max_vec)+betta_vec./tau_vec.*min_vec.*exp(-tau_vec./betta_vec.*min_vec))-...
                ((betta_vec./tau_vec).^2.*exp(-tau_vec./betta_vec.*max_vec)-(betta_vec./tau_vec).^2.*exp(-tau_vec./betta_vec.*min_vec))));
    end;
end;
toc

linind_fine = and(and(exitf(:,1)==0,min(z_vec(:,1:2),[],2)>zeros(no_cit,1)),min(ztilde_vec(:,1:3),[],2)>zeros(no_cit,1));
fprintf('\nAverage deviation relative to the true value\n');
fprintf('z1     z2\n');
mean((z_data_matr(linind_fine,1:2)-z_vec(linind_fine,1:2))./[z3(linind_fine,1) z3(linind_fine,1)])
[z_data_matr(linind_fine,1:3) z_vec(linind_fine,1:3)]

%Saving data
switch city_type
    case 'circular'
        save ../../data/circular.mat;
        fid     = fopen('../../data/circular.csv','w');
        ZZ  =   [z_data_matr(:,1:3) z_vec(:,1:3) linind_fine];
        fprintf(fid,'z1_data,z2_data,z3_data,z1_model,z2_model,z3_model,model_converged\n');
        fprintf(fid,'%3.8f,%3.8f,%3.8f,%3.8f,%3.8f,%3.8f,%1.0f\n',ZZ);
        fclose(fid);
    case 'linear'
        save ../../data/linear.mat;
        fid     = fopen('../../data/linear.csv','w');
        ZZ  =   [z_data_matr(:,1:3) z_vec(:,1:3) linind_fine];
        fprintf(fid,'z1_data,z2_data,z3_data,z1_model,z2_model,z3_model,model_converged\n');
        fprintf(fid,'%3.8f,%3.8f,%3.8f,%3.8f,%3.8f,%3.8f,%1.0f\n',ZZ);
        fclose(fid);
end;

figure(1);
subplot(1,2,1); scatter(z_data_matr(linind_fine,1),z_vec(linind_fine,1)); xlabel('data'); ylabel('model'); title('z_1');
subplot(1,2,2); scatter(z_data_matr(linind_fine,2),z_vec(linind_fine,2)); xlabel('data'); ylabel('model'); title('z_2');
%Setting background color for white
set(gcf, 'Color', 'w');
path_str    =   '../../../text/Figures/';
cd Export_fig;
eval(['export_fig ''' path_str 'fig_' city_type '.pdf'' -pdf;']);
cd ..;

figure(2);
subplot(1,2,1); scatter(z_data_matr(linind_fine,1)./z_data_matr(linind_fine,3),z_vec(linind_fine,1)./z_vec(linind_fine,3)); xlabel('data'); ylabel('model'); title('z_1/z_3');
subplot(1,2,2); scatter(z_data_matr(linind_fine,2)./z_data_matr(linind_fine,3),z_vec(linind_fine,2)./z_vec(linind_fine,3)); xlabel('data'); ylabel('model'); title('z_2/z_3');
%Setting background color for white
set(gcf, 'Color', 'w');
path_str    =   '../../../text/Figures/';
cd Export_fig;
eval(['export_fig ''' path_str 'fig_' city_type '_relative.pdf'' -pdf;']);
cd ..;


figure(3);
subplot(1,2,1); scatter(emp_w_distance(linind_fine,1),ztilde_vec(linind_fine,1)); xlabel('data'); ylabel('model'); title('z_1');
subplot(1,2,2); scatter(emp_w_distance(linind_fine,2),ztilde_vec(linind_fine,2)); xlabel('data'); ylabel('model'); title('z_2');
%Setting background color for white
set(gcf, 'Color', 'w');
path_str    =   '../../../text/Figures/';
cd Export_fig;
eval(['export_fig ''' path_str 'fig_' city_type '_empwdistance.pdf'' -pdf;']);
cd ..;


dist_min    =   0;
dist_max    =   300;
nn_dist     =   1000;
dist_inc    =   (dist_max-dist_min)/(nn_dist-1);
dist_vec    =   dist_min:dist_inc:dist_max;

transp_cost =   1-exp(-tau_vec'*dist_vec);

figure(4);
plot(dist_vec,transp_cost); legend('services','manufacturing','agriculture'); xlabel('Distance to the center (km)'); ylabel('Iceberg transport cost');
set(gcf, 'Color', 'w');
path_str    =   '../../../text/Figures/';
cd Export_fig;
eval(['export_fig ''' path_str 'fig_trans_cost.pdf'' -pdf;']);
cd ..;