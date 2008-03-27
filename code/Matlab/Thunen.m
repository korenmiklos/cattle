clc;
clear all;

%Setting parameters
gamma   =   0.5;       %relative C-D weight of the manufacturing good
N       =   17;        %Size of the population  
H       =   1;         %size of the house
A       =   1;         %technology parameter
tau_s   =   1.1;       %transportation costs for the services
tau_h   =   1.2;       %transportation costs for the households

c       =   1/(gamma^gamma*(1-gamma)^(1-gamma));    %parameter for the aggregate prices

T_A     =   10;             %Number of A grids
A_min   =   1;              %Minimum A_grid
A_max   =   2;              %Maximum A_grid  

T_H     =   10;             %Number of H grids
H_min   =   1;              %Minimum H_grid
H_max   =   2;              %Maximum H_grid

%Checking Balassa-Samuelson
%Creating grid for A
lnA_inc     =   (log(A_max)-log(A_min))/(T_A-1);
A_i         =   exp(log(A_min):lnA_inc:log(A_max));   

z_A         =   zeros(2,T_A);
ps_A        =   zeros(1,T_A);
diff_A      =   zeros(2,T_A);
exitf_A     =   zeros(1,T_A);

for i   =   1:T_A
    A   =   A_i(i);

%Solving for z1 and z2 both between 0 and 1
    z1_init     =   0.3;
    z2_init     =   0.6;
    Z0          =   [tan(z1_init*pi-pi/2) tan(z2_init*pi-pi/2)];
    options     =   optimset('Display','off');
    [Z,diff,exitf]  =   fsolve(@f_Thunen,Z0,options,gamma,tau_s,H,A);
    z1  =   (pi/2+atan(Z(1)))/pi;
    z2  =   (pi/2+atan(Z(2)))/pi;
    
    ps  =   (1-z2)/(1-tau_s*z2);
    u   =   pi/(N*H)*z1^2;
    
    diff_A(:,i) =   diff;
    exitf_A(1,i)=   exitf;
    z_A(:,i)    =   [z1;z2];
    ps_A(1,i)   =   ps;
end;

%Checking what happens with H
lnH_inc     =   (log(H_max)-log(H_min))/(T_H-1);
H_i         =   exp(log(H_min):lnH_inc:log(H_max));   

z_H         =   zeros(2,T_H);
ps_H        =   zeros(1,T_H);
diff_H      =   zeros(2,T_H);
exitf_H     =   zeros(1,T_H);

for i   =   1:T_H
    H   =   H_i(i);

%Solving for z1 and z2 both between 0 and 1
    z1_init     =   0.3;
    z2_init     =   0.6;
    Z0          =   [tan(z1_init*pi-pi/2) tan(z2_init*pi-pi/2)];
    options     =   optimset('Display','off');
    [Z,diff,exitf]  =   fsolve(@f_Thunen,Z0,options,gamma,tau_s,H,A);
    z1  =   (pi/2+atan(Z(1)))/pi;
    z2  =   (pi/2+atan(Z(2)))/pi;
    
    ps  =   (1-z2)/(1-tau_s*z2);
    u   =   pi/(N*H)*z1^2;
    
    diff_H(:,i) =   diff;
    exitf_H(1,i)=   exitf;
    z_H(:,i)    =   [z1;z2];
    ps_H(1,i)   =   ps;
end;

figure(1)
subplot(2,1,1); plot(A_i,z_A(1,:),'b',A_i,z_A(2,:),'r-'); ylabel('z'); xlabel('A');
subplot(2,1,2); plot(A_i,ps_A); ylabel('p_s'); xlabel('A');

figure(2)
subplot(2,1,1); plot(H_i,z_H(1,:),'b',H_i,z_H(2,:),'r-'); ylabel('z'); xlabel('H');
subplot(2,1,2); plot(H_i,ps_H); ylabel('p_s'); xlabel('H');