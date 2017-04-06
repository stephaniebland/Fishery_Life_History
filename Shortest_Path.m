%% A Single Source Shortest Path Algorithm.
% An alternative to Dijkstra's algorithm.
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
% This function takes the exponent of all non-zero elements
% The resulting matrix $B$ has elements $b_{ij}=e^{a_{ij}}$.
B=A;                            % Preserve the original matrix
B(B~=0)=exp(B(B~=0));           % Transform the data (take the exponents of links) - nodes that aren't linked remain 0.

%% Find size of web - n is the number of nodes
n=length(B);

%% Set up the Distance Vector
% # Assume that all nodes except the source have $e^{d_i}=0$ to begin with.
% (because this way my code works)
% # We need to track changes in distance because the loop will run until
% distance is constant, so we initialize the distance vector here.
% # Set up a loop between the source and itself with a distance of 0: the
% first step is to establish the loop by setting $b_{ss}=e^0=1$
% # The second step is to set the distance from the source node to itself. 
% It makes sense to say that it has 0 distance from itself, so we set
% $e^{d_s}=e^{0}=1$.
exp_d=zeros(n,1);               % Distance is set to -infinity to begin with  (so 0 because exp(-infinity)=0).
old_exp_d=exp_d;                % Set up a vector to track changes in distance - we will run the loop until the distance is constant
B(s,s)=exp(0);                  % Set up a loop between the source and itself of distance 0, so that the source gets it's energy from itself.
exp_d(s)=exp(0);                % The source has a distance of 0 from itself, but we are using exponents, so 1.

%% The While Loop:
% * This loops until distance is constant. This method guarantees that we
% will find the shortest distance $d_{i}$. Proof by induction: If there is
% a shorter path between node $i$ and $s$, it will need to go through node 
% $j$ first, so the shortest distance for node $j$ would need to change in 
% the previous loop.
% * Update the vector to keep track of changes in distance. We will
% continue to loop until distance is constant.
% * Find a matrix 
%
% $C=B\times  \pmatrix{e^{d_1} &&&  \cr
%                       & e^{d_2} && \cr
%                       && \ddots  & \cr
%                       &&& e^{d_n} \cr}$
% 
% Of course for the first few rounds, $e^{d_i}=0$ for almost all $i$. Each
% round we will add more known values to this. So the log of element 
% $c_{ij}$ is the shortest known distance between nodes $i$ and $s$ that 
% goes through node $i$'s neighbour, $j$. This is because $b_{ij}$ is the
% log of the distance between node $i$ and it's neighbour, $j$, and
% $e^{d_j}$ is the shortest known distance between $j$ and s. So
% $c_{ij}=b_{ij}e^{d_j}=e^{a_{ij}}e^{d_j}=e^{a_{ij}+d_j}$. So the log of
% $c_{ij}$ is: $\log c_{ij}=\log e^{a_{ij}+d_j}=a_{ij}+d_j$, which is the
% shortest distance between $i$ and $s$, calculated with the shortest known
% value for $d_j$. Every time you run this loop you will update the
% distance for the neighbouring nodes, so eventually it will optimize,
% provided:
%
% all distances are positive OR there are no loops. 
%%
% * Correct for 0 values: $c_{ij}=0$ for distances you have not calculated
% yet, so we will set them NaN for now so we don't mistake them for the
% shortest distance. 
% * We need to find the shortest distance, so we need to find the smallest
% known distance between node i and the source. So updated the distance
% vector with $e^{d_i}=\min_{j}c_{ij}$.

while sum(old_exp_d~=exp_d)~=0  % Iterate the loop until distance no longer changes
    old_exp_d=exp_d;            % Keep track of changes in distance. We loop until this is constant, meaning we found the shortest distance. 
    C=B*diag(exp_d);            % Find shortest paths - so log(c_ij) is the distance between the source and node i, if we take the shortest route through i's neighbour (j). 
    C(C==0)=NaN;                % Don't mistake 0s for shortest path. (since log(0) is -infinity, it doesn't make sense to use them)
    exp_d=min(C,[],2);          % Find shortest path (We excluded 0s, so it's the second smallest element in each row of matrix C)
end

%% Distance from Source Node:
distance=log(exp_d)             % Transform the data again to give you the distance from source node




