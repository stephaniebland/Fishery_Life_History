%% Experimental Project
%  by Stephanie Bland
%%

%% Inputs:
%  Complete Food Web
%  Allometric Ratio
%  Trophic Position

%% Testing code, set up
clear;
Parameters;
%S_0=10;% Number of original nodes (species)
setup;
%nicheweb=magic(5); %nicheweb
nichewebsize=length(nicheweb);


%% Remove some links from the food web 
A=nicheweb; % Matrix from which we will remove nodes.
Asize_sqrd=nichewebsize^2;
n=1;%round(Asize_sqrd*.01); % Number of nodes to remove
to_remove=randsample(Asize_sqrd,n,false);
B=sym('A', [nichewebsize]);
%A(to_remove)=NaN;
A=sym(A);
A(to_remove)=B(to_remove);

%% Check out Parameters:
orig.TrophLevel
A
Z


%% Reminder of Trophic Levels
% Add up how many prey items each species has:
prey=sum(A,2); %sum of each row

% Create unweighted Q matrix. So a matrix that gives proportion of the
% diet given by each prey species.
Q=A./(prey*ones(1,nichewebsize));  % Create unweighted Q matrix. (Proportion of predator diet that each species gives).
Q(isnan(Q))=0;      % Set NaN values to 0. 

%Calculate trophic levels as T2=(I-Q)^-1 * 1  %Levine 1980 geometric series 
T2=(inv(eye(nichewebsize)-B))*ones(nichewebsize,1); % Or sum over the rows "sum(A,2)"
T2=(inv(eye(nichewebsize)-Q))*ones(nichewebsize,1); % Or sum over the rows "sum(A,2)"

xk=inv(B);

%%  Try to Reconstruct Web
% Hmmm, well syms isnt working out for me so well, so maybe I should just
% try every combo of 1 and 0, because it would max out at 2^n calculations
% so for 10 missing links, you'd get 1024 calculations.

%% Check Accuracy of web reconstruction
% Percentage of web reconstructed


















