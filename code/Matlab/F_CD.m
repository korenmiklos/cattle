function [F]=F_CD(factors,weights)
%       Calculating the weighted Cobb-Douglas aggregation of factors

%Inputs:    factors: 1 x n vector of factors
%           weights: 1 x n vector of weights in the function

NN   =  length(factors);

if nargin==1
    weights=(1/NN)*ones(1,NN);
end;

F   =   prod(factors.^(weights));