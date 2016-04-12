%--------------------------------------------------------------------------
% Program by Perrine Tonin
% June 2011
%--------------------------------------------------------------------------
% Determines whether the web is fully connected
%--------------------------------------------------------------------------

function z = isConnected(M)

m = length(M);

M=max(M,M');     % symetrize the matrix  
C = false(1, m); % marks nodes in the same component as node 1
N = [true false(1, m-1)]; % marks newly found nodes to be added to C

while any(N)
  C = C | N;
  N = sum(M(N,:), 1) & ~C;
end

z = all(C);
