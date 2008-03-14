%Single location Spatial Balassa-Samuelson code


clear all;
clc;

%Setting the parameters
theta   =   2;              %Elasticity of substitution in the production function
weight_l=   0.05;           %Factor weight of land
weight_n=   1-weight_l;     %Factor weight of labor

sigma   =   0.9;              %Elasticity of substitution in the utility function
A       =   1;              %TFP parameter
N_over_L=   1;              %population density

weights =   [weight_n weight_l];

T_A     =   10;             %Number of A grids
A_min   =   1;              %Minimum A_grid
A_max   =   2;              %Maximum A_grid  

T_Dens  =   10;             %Number of density grids
Dens_min=   1;
Dens_max=   5;

%Creating grid for A
lnA_inc   =   (log(A_max)-log(A_min))/(T_A-1);
A_i     =   exp(log(A_min):lnA_inc:log(A_max));   

lambda_A    =   zeros(1,T_A);
diff_A      =   zeros(1,T_A);
exitf_A     =   zeros(1,T_A);
r_A         =   zeros(1,T_A);
w_A         =   zeros(1,T_A);
R_sh_A      =   zeros(1,T_A);

for i   =   1:T_A;
    A   =   A_i(i);
    lambda0     =   0.5;
    options     =   optimset('Display','off');
    [lambda,diff,exitf]  =   fsolve(@f_landshare_SL,lambda0,options,A,N_over_L,theta,weights,sigma);

%Calculating r
    switch theta
        case 1
            dF_L    =   dF_CD(2,[N_over_L 1-lambda],weights);
            dF_N    =   dF_CD(1,[N_over_L 1-lambda],weights);
            F       =   F_CD([N_over_L 1-lambda],weights);
        otherwise
            dF_L    =   dF_CES(2,theta,[N_over_L 1-lambda],weights);
            dF_N    =   dF_CES(1,theta,[N_over_L 1-lambda],weights);
            F   =   F_CES(theta,[N_over_L 1-lambda],weights);
    end;

%Calculating w,r
    w   =   A*dF_N;
    r   =   A*dF_L;
    
%Share of rents in national income
    R_sh    =   lambda*r/(A*F);
    
    lambda_A(i)     =   lambda;
    diff_A(i)       =   diff;
    exitf_A(i)      =   exitf;
    r_A(i)          =   r;
    w_A(i)          =   w;
    R_sh_A(i)       =   R_sh;
end;

%Creating grid for density
Dens_inc   =   (Dens_max-Dens_min)/(T_Dens-1);
Dens_i     =   Dens_min:Dens_inc:Dens_max;   

lambda_Dens    =   zeros(1,T_Dens);
diff_Dens      =   zeros(1,T_Dens);
exitf_Dens     =   zeros(1,T_Dens);
r_Dens         =   zeros(1,T_Dens);
w_Dens         =   zeros(1,T_Dens);
R_sh_Dens      =   zeros(1,T_Dens);

for i   =   1:T_Dens;
    N_over_L   =   Dens_i(i);
    lambda0     =   0.5;
    options     =   optimset('Display','off');
    [lambda,diff,exitf]  =   fsolve(@f_landshare_SL,lambda0,options,A,N_over_L,theta,weights,sigma);

%Calculating r
    switch theta
        case 1
            dF_L    =   dF_CD(2,[N_over_L 1-lambda],weights);
            dF_N    =   dF_CD(1,[N_over_L 1-lambda],weights);
            F       =   F_CD([N_over_L 1-lambda],weights);
        otherwise
            dF_L    =   dF_CES(2,theta,[N_over_L 1-lambda],weights);
            dF_N    =   dF_CES(1,theta,[N_over_L 1-lambda],weights);
            F   =   F_CES(theta,[N_over_L 1-lambda],weights);
    end;

%Calculating w,r
    w   =   A*dF_N;
    r   =   A*dF_L;
    
%Share of rents in national income
    R_sh    =   lambda*r/(A*F);
    
    lambda_Dens(i)     =   lambda;
    diff_Dens(i)       =   diff;
    exitf_Dens(i)      =   exitf;
    r_Dens(i)          =   r;
    w_Dens(i)          =   w;
    R_sh_Dens(i)       =   R_sh;
end;


figure(1)
    subplot(2,2,1); plot(A_i,r_A); title('Rents relative to manufacturing prices');
    subplot(2,2,2); plot(A_i,r_A./w_A); title('Rents relative to wages');
    subplot(2,2,3); plot(A_i,lambda_A); title('Residential land share');
    subplot(2,2,4); plot(A_i,R_sh_A); title('Rent share');
    
    
figure(2)
    subplot(2,2,1); plot(Dens_i,r_Dens); title('Rents relative to manufacturing prices');
    subplot(2,2,2); plot(Dens_i,r_Dens./w_Dens); title('Rents relative to wages');
    subplot(2,2,3); plot(Dens_i,lambda_Dens); title('Residential land share');
    subplot(2,2,4); plot(Dens_i,R_sh_Dens); title('Rent share');