%            1 2 3 4 5 6 7
nicheweb=   [0 0 0 0 0 0 0; %1
             0 0 0 0 0 0 0; %2
             1 0 0 0 0 0 0; %3
             1 1 0 0 0 0 0; %4
             0 0 1 1 0 0 0; %5
             0 1 0 1 0 0 0; %6
             0 0 0 0 1 1 0];%7

Z=[1;1;100;100;100;500;500];
%            1 2 3 4 5 6 7
nicheweb=   [0 0 0 0 0 0 0; %1 %%%%LOOPED
             0 0 0 0 0 0 0; %2
             1 0 0 0 0 0 0; %3
             1 1 0 1 0 0 0; %4
             0 0 1 1 0 0 0; %5
             0 1 0 1 0 0 0; %6
             0 0 0 0 1 1 0];%7


%            1 2 3 4 5 6 7
nicheweb=   [1 0 0 0 0 0 0; %1
             0 1 0 0 0 0 0; %2
             1 0 0 0 0 0 0; %3
             1 1 0 0 0 0 0; %4
             0 0 1 1 0 0 0; %5
             0 1 0 1 0 0 0; %6
             0 0 0 0 1 1 0];%7
nichewebsize = length(nicheweb);
nicheweb1=+nicheweb;
prey=sum(nicheweb1,2); %sum of each row

    %Create unweighted Q matrix. So a matrix that gives proportion of the
    %diet given by each prey species.
    Q=nicheweb1./prey;  % Create unweighted Q matrix. (Proportion of predator diet that each species gives).
    Q(isnan(Q))=0; 

I=eye(nichewebsize);
%(I*Z).*(Q*Z).*(Q^2*Z).*(Q^3*Z).*(Q^4*Z).*(Q^5*Z)


%(I*Z).*(Q*Z).*(Q^2*Z).*(Q^3*Z).*(Q^4*Z).*(Q^5*Z)


%(I.*Z)*(Q.*Z')*(Q^2.*Z').*(Q^3*Z).*(Q^4*Z).*(Q^5*Z).*(Q^6*Z)*K


%(I.*Z')*(Q.*Z')*(Q.*Z')^2*(Q.*Z')^3.*(Q^4*Z).*(Q^5*Z)


A=Q.*Z';

K=ones(nichewebsize,1);


%A*(A*(A*(A*K*K')*K*K')*K*K')*K




%            1 2 3
nicheweb=   [0 0 0; %1
             1 0 0; %2
             1 1 0]; %3
nichewebsize = length(nicheweb);
Z=[1;2;3];
K
B=I.*Z;
%C_5=Q.*Z';
C_5=Q*B;
C_4=Q.*(B*C_5*K)';
%C_4=Q*(diag(C_5*K.*Z));
C_3=Q.*(B*C_4*K)';
%C_3=Q*(diag(C_4*K.*Z));
C_2=Q.*(B*C_3*K)';
C_1=Q.*(B*C_2*K)';
tots=B*C_1*K;



C=Q*B;
Y=K*Z';
for iter=1:80
    %C=Q.*(B*C*K)';
    %C=Q*(diag(C*K.*Z));
    C=Q*diag(diag(C*Y));
end
tots=B*C*K
  

xk=(Y.^I).*(Y.^Q).*(Y.^(Q^2)).*(Y.^(Q^3)).*(Y.^(Q^4)).*(Y.^(Q^5)).*(Y.^(Q^6))
xk=(Y.^I);
for iter=1:800
    xk=xk.*(Y.^(Q^iter));
end

Q=Q-diag(diag(Q))
simpler=Y.^(inv(I-Q));
simpler2=(K*Z').^(inv(I-Q));
prod(simpler2,2)
%is it reversible?
simpler.^(inv(I-Q))

item=[0 0 0 0 0 0 1];
prod(item*xk)%take row products of xk to get the thing you want


prod(item*simpler)%take row products of xk to get the thing you want
500*sqrt(500*sqrt(100*1)*100*sqrt(100*100))%So this is product, wheras other is different 

dspmtrx3(xk)







% C=((Q+I)*B)^-1;
% Y=(K*Z').^-1;
% Q=(Q+I)^-1; 
% for iter=1:80
%     C=diag(diag(Y*C))*Q;
% end
% C^-1
% tots=B*C*K

Z=[1;1;500;500;500;500;500]




