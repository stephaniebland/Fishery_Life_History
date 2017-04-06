%% A Single Source Shortest Path Algorithm.
% Stephanie Bland
%% Input: This function takes two inputs
% * $A$ - A weighted web where $a_{ij}$ is the distance from node $i$ to
% $j$.
% * $s$ - The source node that shortest distance is calculated from.
%% Output: Distance
% * $d$ - A vector that gives the distance ($d_i$) from node $i$ to the
% source $s$.

%% Clear Workspace
clear;                          % Clears the workspace

%% Set Up - Inputs are A (the web), and s (the source node)
% * Start with a weighted graph $A$, where $a_{ij}$ indicates the weight of
% the edge from node $i$ to $j$.
% * We also have a source node that the distances are calculated from.
% ($d_i$ is distance from source $s$ to node $i$).
A       =   [0 0 0 0 0 0 0 0 0; %1
             1 0 0 0 0 0 0 0 0; %2
             5 0 0 0 0 0 0 0 0; %3
             0 0 2 0 0 0 0 0 0; %4
             0 0 0 6 0 0 0 0 0; %5
             0 0 0 0 8 0 3 0 0; %6
             0 9 0 0 0 0 0 0 0; %7
             0 0 0 0 0 2 0 0 0; %8
             0 0 0 0 0 0 0 4 0];%9

s = 1;                          % The element that we are calculating the distance from. the distance ($d_i$) will tell you the distance from node i to the source (s).

%% Transform the data (exponents) so that we can use the multiplicative method.
A(A~=0)=exp(A(A~=0));           % Transform the data (take the exponents of links) - nodes that aren't linked remain 0.

%% Find size of web - n is the number of nodes
n=length(A);

%% Set up the Distance Vector
% Assume that all nodes have $e^{d_i}=0$ to begin with (because it works
% this way)
exp_d=zeros(n,1);               % Distance is set to -infinity to begin with  (so 0 because exp(-infinity)=0).
old_exp_d=exp_d;                % Set up a vector to track changes in distance - we will run the loop until the distance is constant
A(s,s)=exp(0);                  % Set up a loop between the source and itself of distance 0, so that the source gets it's energy from itself.
exp_d(s)=exp(0);                % The source has a distance of 0 from itself, but we are using exponents, so 1.

%% The While Loop:
% This loops until distance is constant (because if there is a shorter path
% available between node $i$ and $s$, it will need to go through $j$ first,
% so the shortest distance for node $j$ would need to change in the
% previous loop - proof by induction).
while sum(old_exp_d~=exp_d)~=0  % Iterate the loop until distance no longer changes
    old_exp_d=exp_d;            % Keep track of changes in distance. We loop until this is constant, meaning we found the shortest distance. 
    C=A*diag(exp_d);            % Find shortest paths - so log(c_ij) is the distance between the source and node i, if we take the shortest route through i's neighbour (j). 
    C(C==0)=NaN;                % Don't mistake 0s for shortest path. (since log(0) is -infinity, it doesn't make sense to use them)
    exp_d=min(C,[],2);          % Find shortest path (We excluded 0s, so it's the second smallest element in each row of matrix C)
end

%% Distance from Source Node:
distance=log(exp_d)             % Transform the data again to give you the distance from source node




