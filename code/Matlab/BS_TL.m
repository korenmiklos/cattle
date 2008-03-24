%Two locations spatial Balassa-Samuelson code


clear all;
clc;

%Setting the parameters
theta   =   1;              %Elasticity of substitution in the production function
weight_l=   0.05;           %Factor weight of land
weight_n=   1-weight_l;     %Factor weight of labor

sigma   =   0.75;              %Elasticity of substitution in the utility function
A       =   1;              %TFP parameter
N1      =   1;              %labor in the village
N2      =   2;              %labor in the city
L       =   1;              %land
N1_over_L=   N1/L;            %population density
N2_over_L=   N2/L;            %population density
alpha   =   N2/(N1+N2);

weights =   [weight_n weight_l];

T_A     =   10;             %Number of A grids
A_min   =   1;              %Minimum A_grid
A_max   =   2;              %Maximum A_grid  

T_Dens  =   10;             %Number of density grids
Dens_min=   2;
Dens_max=   5;

%Creating grid for A
lnA_inc   =   (log(A_max)-log(A_min))/(T_A-1);
A_i     =   exp(log(A_min):lnA_inc:log(A_max));   

lambda_A    =   zeros(1,T_A);
x2_A        =   zeros(1,T_A);
diff1_A      =   zeros(1,T_A);
diff2_A      =   zeros(1,T_A);
exitf_A     =   zeros(1,T_A);
r1_A        =   zeros(1,T_A);
r2_A        =   zeros(1,T_A);
w_A         =   zeros(1,T_A);
R_sh_A      =   zeros(1,T_A);
F1_A        =   zeros(1,T_A);
dF1_L_A     =   zeros(1,T_A);
dF1_N_A     =   zeros(1,T_A);
x_A         =   zeros(1,T_A);

for i   =   1:T_A
    A   =   A_i(i);
    lambda0     =   0.5;
    x20         =   1;
    X0          =   [lambda0 x20];
    options     =   optimset('Display','off');
    [X,diff,exitf]  =   fsolve(@f_landshare_TL,X0,options,A,N1,N2,L,theta,weights,sigma);
    lambda      =   X(1);
    x2          =   X(2);
    
%Calculating r1,r2
    switch theta
        case 1
            dF1_L   =   dF_CD(2,[N1/L 1-lambda],weights);
            dF1_N   =   dF_CD(1,[N1/L 1-lambda],weights);
            F1      =   F_CD([N1 L*(1-lambda)],weights);
        otherwise
            dF1_L   =   dF_CES(2,theta,[N1/L 1-lambda],weights);
            dF1_N   =   dF_CES(1,theta,[N1/L 1-lambda],weights);
            F1      =   F_CES(theta,[N1 L*(1-lambda)],weights);
    end;

%Calculating w,r
    w   =   A*dF1_N;
    r1  =   A*dF1_L;
    r2  =   alpha/(1-alpha)*r1-x2/L;
    
%Calculating x
    x   =   A*F1;
    
%Share of rents in national income
%    R_sh    =   lambda*r*L/(A*F);
    
    lambda_A(i)     =   lambda;
    x2_A(i)         =   x2;
    diff1_A(i)       =   diff(1);
    diff2_A(i)       =   diff(2);    
    exitf_A(i)      =   exitf;
    r1_A(i)         =   r1;
    r2_A(i)         =   r2;
    w_A(i)          =   w;
    %R_sh_A(i)       =   R_sh;
    F1_A(i)          =   F1;
    dF1_L_A(i)       =   dF1_L;
    dF1_N_A(i)       =   dF1_N;
    x2_A(i)         =   x2;
    x_A(i)          =   x;
end;

%Creating grid for density
Dens_inc   =   (Dens_max-Dens_min)/(T_Dens-1);
Dens_i     =   Dens_min:Dens_inc:Dens_max;   

lambda_Dens    =   zeros(1,T_Dens);
diff1_Dens      =   zeros(1,T_Dens);
diff2_Dens      =   zeros(1,T_Dens);
exitf_Dens     =   zeros(1,T_Dens);
r1_Dens        =   zeros(1,T_Dens);
r2_Dens        =   zeros(1,T_Dens);
w_Dens         =   zeros(1,T_Dens);
R_sh_Dens      =   zeros(1,T_Dens);
F1_Dens        =   zeros(1,T_Dens);

for i   =   1:T_Dens;
    N2_over_L   =    Dens_i(i);
    N2          =    L*N2_over_L;
    lambda0     =   0.5;
    x20         =   1;
    X0         =    [lambda0 x20];
    options     =   optimset('Display','off','TolFun',1e-8,'TolX',1e-8);
    [X,diff,exitf]  =   fsolve(@f_landshare_TL,X0,options,A,N1,N2,L,theta,weights,sigma);
    lambda      =   X(1);
    x2          =   X(2);
%Calculating r
    switch theta
        case 1
            dF1_L    =   dF_CD(2,[N1/L 1-lambda],weights);
            dF1_N    =   dF_CD(1,[N1/L 1-lambda],weights);
            F1       =   F_CD([N1 L*(1-lambda)],weights);
        otherwise
            dF1_L    =   dF_CES(2,theta,[N1/L 1-lambda],weights);
            dF1_N    =   dF_CES(1,theta,[N1/L 1-lambda],weights);
            F1       =   F_CES(theta,[N1 L*(1-lambda)],weights);
    end;

%Calculating w,r
    w   =   A*dF1_N;
    r1   =   A*dF1_L;
    r2  =   alpha/(1-alpha)*r1-x2/L;
    
%Calculating x
    x   =   A*F1;
%Share of rents in national income
%    R_sh    =   lambda*r*L/(A*F);
    
    lambda_Dens(i)     =   lambda;
    diff1_Dens(i)       =   diff(1);
    diff2_Dens(i)       =   diff(2);
    exitf_Dens(i)      =   exitf;
    r1_Dens(i)         =   r1;
    r2_Dens(i)         =   r2;
    w_Dens(i)          =   w;
%    R_sh_Dens(i)       =   R_sh;
    F1_Dens(i)          =   F1;
    dF1_L_Dens(i)       =   dF1_L;
    dF1_N_Dens(i)       =   dF1_N;
    x_Dens(i)           =   x;
    x2_Dens(i)          =   x2;
end;


figure(1)
    subplot(2,2,1); plot(A_i,r1_A); title('Village rents relative to manufacturing prices');
    subplot(2,2,2); plot(A_i,r2_A); title('City rents relative to manufacturing prices');
    %    subplot(2,2,2); plot(A_i,r_A./w_A); title('Rents relative to wages');
    subplot(2,2,3); plot(A_i,lambda_A); title('\lambda');
    subplot(2,2,4); plot(A_i,x2_A); title('x_2');
%    subplot(2,2,4); plot(A_i,R_sh_A); title('Rent share');
    
    
figure(2)
    subplot(3,2,1); plot(Dens_i,r1_Dens); title('Village rents relative to manufacturing prices');
    subplot(3,2,2); plot(Dens_i,r2_Dens); title('City rents relative to manufacturing prices');    
    subplot(3,2,3); plot(Dens_i,r1_Dens./w_Dens); title('Village relative to wages');
    subplot(3,2,4); plot(Dens_i,r2_Dens./w_Dens); title('City relative to wages');    
    subplot(3,2,5); plot(Dens_i,lambda_Dens); title('\lambda');
    subplot(3,2,6); plot(Dens_i,x_Dens); title('Manufacturing output');
    %    subplot(2,2,4); plot(Dens_i,R_sh_Dens); title('Rent share');