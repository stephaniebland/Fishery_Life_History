% A single source shortest path algorithm

clear;%clears the workspace

%% Set Up - Inputs are A (the web), and s (the source node)
%  Start with a weighted graph A, where a_ij indicates the weight of the edge from node i to j. 
%  We also have a source node that the distances are calculated from.
A       =   [0 0 0 0 0 0 0 0 0; %1
             1 0 0 0 0 0 0 0 0; %2
             5 0 0 0 0 0 0 0 0; %3
             0 0 2 0 0 0 0 0 0; %4
             0 0 0 6 0 0 0 0 0; %5
             0 0 0 0 8 0 3 0 0; %6
             0 9 0 0 0 0 0 0 0; %7
             0 0 0 0 0 2 0 0 0; %8
             0 0 0 0 0 0 0 4 0];%9

source = 1; %The element that we are calculating the distance from. the distance (d_i) will tell you the distance from node i to the source s.

%% Transform the data so that we can use the multiplicative method. maxelem just makes sure that the values aren't too large for MATLAB
maxelem=max(abs(A(:)));% Find largest element - MATLAB doesn't deal with exponents very well. 
A=A*100/maxelem;%MATLAB deals with things up to roughly 100.
A(A~=0)=exp(A(A~=0));%Transform the data (take the exponents)

%% Find size of web - n is the number of nodes
n=length(A);

%% Set up the Distance Vector - Assume that all nodes have exp(d_i)=0 to begin with (because it works this way)
exp_d=zeros(n,1);% Distance is set to -infinity to begin with  (so 0 because exp(-infinity)=0).
old_exp_d=exp_d; % Set up a vector to track changes in distance - we will run the loop until the distance is constant
A(source,source)=exp(0); %Set up a loop between the source and itself of distance 0, so that the source gets it's energy from itself.
exp_d(source)=exp(0); % The source has a distance of 0 from itself, but we are using exponents, so 1.

%% The While Loop:
while sum(old_exp_d~=exp_d)~=0  %Iterate the loop until distance no longer changes
    old_exp_d=exp_d;            %Keep track of changes in distance.
    C=A*diag(exp_d);            %Find shortest paths - so C_ij is the mass if it were calculated using path going from pred i to prey j.
    C(C==0)=NaN;                %Don't mistake 0s for shortest path.
    exp_d=min(C,[],2);          %Find shortest path, now that you exclude 
end

%% Distance from Source Node:
distance=log(exp_d)*maxelem/100%Transform the data again to give you the distance from source node

exp_d;