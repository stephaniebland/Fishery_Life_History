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
         
Z=[1;2;2;2;2;500];          
nicheweb=   [0 0 0 0 0 0; %1
             0 0 0 0 0 0; %2
             1 0 0 0 0 0; %3
             0 0 1 0 0 0; %4
             0 0 0 1 0 1; %5
             1 0 0 0 0 0];%6      
       
nicheweb=   [0 0 0 0 0 0 0 0 0; %1
             0 0 0 0 0 0 0 0 0; %2
             1 0 0 0 0 0 0 0 0; %3
             0 0 1 0 0 0 0 0 0; %4
             0 0 0 1 0 0 0 0 0; %5
             0 0 0 0 1 0 1 0 0; %6
             0 1 0 0 0 0 0 0 0; %7
             0 0 0 0 0 1 0 0 0; %8
             0 0 0 0 0 0 0 1 0];%9
Z=[1;2;2;2;2;2;500;2;2];                    
         
nichewebsize = length(nicheweb);
nicheweb1=+nicheweb;
prey=sum(nicheweb1,2); %sum of each row
basalsp = find(sum(nicheweb,2)==0);


Mass1=NaN(nichewebsize,1);  % Set up vector
    Mass1(basalsp)=Z(basalsp); % Basal species defined to have mass of 1
    
A=nicheweb.*Z;%Setup weighted nicheweb matrix - this is like the standard matrix used for Dijkstra algorithm, except weights represent allometric scaling instead of edge length (so multiplicative instead of additive)
    
j=0;k=0;
while j<2%We need to iterate the while loop one extra time than min req'd to calculate all Masses - because you only just got the right mass for all the prey species of an apex predator
    C=A*diag(Mass1);%Find shortest paths - so C_ij is the mass if it were calculated using path going from pred i to prey j.
    C(C==0)=NaN;%Don't mistake 0s for shortest path.  
    Mass1=min(C,[],2);%Find smallest path for each predator now that you excluded 0s
    Mass1(basalsp)=Z(basalsp);%Redefine basal species mass
    j=k*2;
    k= isnan(sum(Mass1))==0;%When this condition is met, you need to do one additional loop.
end
Mass1

    
%%%%%%%%%%%%%%%BELOW IS GARBAGE








    C=A*diag(Mass1)%Find shortest paths - so C_ij is the mass if it were calculated using path going from pred i to prey j.
    C(C==0)=NaN%Don't mistake 0s for shortest path.  
    thing=min(C,[],2)%Find smallest path for each predator now that you excluded 0s
    %Mass1=min(Mass1,thing)%Make sure that your new path isn't smaller than a previously calculated path!
    Mass1=thing
    Mass1(basalsp)=1
    
    


    %[visit,~]=find(B>0)
    %Mass1(visit)=thing(visit)
Z_0=Z 
front=basalsp;





while isnan(Z_0)~=1
    
    
    
    [visit,~]=find(nicheweb(:,done)~=0);
    smallest=find(Z_0==min(Z_0))
    
   
    B=A*diag(Mass1)
    [visit,~]=find(B>0)
    C=B
    C(:,basalsp)=min(A,B)
    D=C(:,basalsp)
    X=nicheweb
    X^2
    
    C=B
    C(C>0)=min(C(C>0))
    thing=min(B(B>0))
    
    C=B
    C(C==0) = nan
    
    thing=min(C')'
    [visit,~]=find(B>0)
    
    Mass1(visit)=thing(visit)
    
    
    
    
    
    Z_0(front)=NaN
    last_round=front
    [visit,~]=find(nicheweb(:,done)~=0);
    smallest=find(Z_0==min(Z_0))
    front=intersect(smallest,visit)
    Mass1(front)=Z(front)*Mass1(last_round(1))
    done=union(front,done)
end    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    Dijk_f=basalsp;%Frontier of Dijkstra's shortest path
    for j=2:nichewebsize
        [r,~]=find(nicheweb(:,ind)~=0);
        Dijk_ = unique(r);
        
        
        
        

        
        nichewebsize=size(nicheweb,2);
        Dijk_c=basalsp;%Start with basal species and add species connected to it
        front=basalsp;
        while length(Dijk_c)<nichewebsize % Each repetition of this loop adds species that are connected to the list
            list_size=length(Dijk_c); % Measure the length of the list before you add connected species
        
        front=basalsp;
        Z_0=Z
        while isnan(Z_0)~=1
            Z_0(front)=NaN
            last_round=front
            [visit,~]=find(nicheweb(:,last_round)~=0);
            smallest=find(Z_0==min(Z_0))
            front=intersect(smallest,visit)
            Mass1(front)=Z(front)*Mass1(last_round(1))
        end
            
            
            
            visit=unique(visit)
            min_visit=find(Z(visit)==min(Z(visit)))
            front=visit(min_visit)
            Mass1(front)=Z(front)*max(Mass1);
            Dijk_c=[Dijk_c;front]
        end
    
  
        
    % Assign other trophic levels.
    for j=2:nichewebsize
        last_level=ind;%Preserve previous trophic levels
        [r,~]=find(nicheweb(:,ind)~=0);%Find all species that eat previous trophic level
        ind = unique(r);%Unique Index of species that consume previous trophic level.
        short_val=min(Z(ind))
        shortest_opts=find(Z(ind)==short_val)
        Mass1(ind(shortest_opts))=min(Mass1(last_level))*Z(ind(shortest_opts))
        ind=ind(shortest_opts)
    end
    
    
    
    
    
nicheweb=nicheweb.*Z    
A=[1,zeros(1,nichewebsize);zeros(nichewebsize,1),nicheweb]
A*A
A^3





    % Assign other trophic levels.
    %for j=2:nichewebsize
    while numel(ind)>0
        last_level=ind;%Preserve previous trophic levels
        [r,~]=find(nicheweb(:,ind)~=0);%Find all species that eat previous trophic level
        ind = unique(r);%Unique Index of species that consume previous trophic level.
        for i=ind'
            prey_opts=intersect(last_level,find(nicheweb(i,:)));%find all options - all prey that were in the previous trophic level. IT MUST ALSO HAVE SHORTEST PATH(because otherwise it could take a "shortcut" through a chain with smaller masses, but a longer overall path)
            smallest_prey=min(Mass1(prey_opts));% Find mass of the smallest prey item in consumer i's diet
            Mass1(i)=min(Mass1(i),Z(i)*smallest_prey); %Allometrically scale the weight of the prey to find the consumer's weight
        end 
        nicheweb(:,last_level)=0;
    end
    
    



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
mass=prod(simpler2,2)
%is it reversible?
simpler.^(inv(I-Q))


syms y_1 y_2 y_3 y_4 y_5 y_6 y_7
eqn1= mass(1)==(y_1^X(1,1))*(y_2^X(1,2))*(y_3^X(1,3))*(y_4^X(1,4))*(y_5^X(1,5))*(y_6^X(1,6))*(y_7^X(1,7));
eqn2= mass(2)==(y_1^X(2,1))*(y_2^X(2,2))*(y_3^X(2,3))*(y_4^X(2,4))*(y_5^X(2,5))*(y_6^X(2,6))*(y_7^X(2,7));
eqn3= mass(3)==(y_1^X(3,1))*(y_2^X(3,2))*(y_3^X(3,3))*(y_4^X(3,4))*(y_5^X(3,5))*(y_6^X(3,6))*(y_7^X(3,7));
eqn4= mass(4)==(y_1^X(4,1))*(y_2^X(4,2))*(y_3^X(4,3))*(y_4^X(4,4))*(y_5^X(4,5))*(y_6^X(4,6))*(y_7^X(4,7));
eqn5= mass(5)==(y_1^X(5,1))*(y_2^X(5,2))*(y_3^X(5,3))*(y_4^X(5,4))*(y_5^X(5,5))*(y_6^X(5,6))*(y_7^X(5,7));
eqn6= mass(6)==(y_1^X(6,1))*(y_2^X(6,2))*(y_3^X(6,3))*(y_4^X(6,4))*(y_5^X(6,5))*(y_6^X(6,6))*(y_7^X(6,7));
eqn7= mass(7)==(y_1^X(7,1))*(y_2^X(7,2))*(y_3^X(7,3))*(y_4^X(7,4))*(y_5^X(7,5))*(y_6^X(7,6))*(y_7^X(7,7));
[y1,y2,y3,y4,y5,y6,y7]=solve(eqn1,eqn2,eqn3,eqn4,eqn5,eqn6,eqn7)

Y_t=[y_1, y_2, y_3, y_4, y_5, y_6, y_7]
Znew=sym('Z_%d', [1 nichewebsize]);

eqn= mass==prod((K*Znew).^(inv(I-Q)),2);
Znew=solve(eqn);
Znew=table2array(struct2table(Znew))'



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% DISCARD BELOW THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Y_t=Y
Y_t(:,3)=NaN
Y_t(3,3)=1
Y_t=Y_t-diag(diag(Y_t)-1)
X=inv(I-Q)
(mass./prod((Y_t.^X),2))
syms y_1 y_2 y_3 y_4 y_5 y_6 y_7
Y_t=[y_1, y_2, y_3, y_4, y_5, y_6, y_7]
Yay=[y_1; y_2; y_3; y_4; y_5; y_6; y_7]
Y_T=[Y_t; Y_t; Y_t; Y_t; Y_t; Y_t; Y_t]

y_1=1;
%y_2=1;
i=2
eqn1= y_1^(X(i,1))==mass(i)/(y_2^X(i,2)*y_3^X(i,3)*y_4^X(i,4)*y_5^X(i,5)*y_6^X(i,6)*y_7^X(i,7))
eqn2= y_2^(X(i,2))==mass(i)/(y_1^X(i,1)*y_3^X(i,3)*y_4^X(i,4)*y_5^X(i,5)*y_6^X(i,6)*y_7^X(i,7))
eqn3= y_3^(X(i,3))==mass(i)/(y_1^X(i,1)*y_2^X(i,2)*y_4^X(i,4)*y_5^X(i,5)*y_6^X(i,6)*y_7^X(i,7))
eqn4= y_4^(X(i,4))==mass(i)/(y_1^X(i,1)*y_2^X(i,2)*y_3^X(i,3)*y_5^X(i,5)*y_6^X(i,6)*y_7^X(i,7))
eqn5= y_5^(X(i,5))==mass(i)/(y_1^X(i,1)*y_2^X(i,2)*y_3^X(i,3)*y_4^X(i,4)*y_6^X(i,6)*y_7^X(i,7))
eqn6= y_6^(X(i,6))==mass(i)/(y_1^X(i,1)*y_2^X(i,2)*y_3^X(i,3)*y_4^X(i,4)*y_5^X(i,5)*y_7^X(i,7))
eqn7= y_7^(X(i,7))==mass(i)/(y_1^X(i,1)*y_2^X(i,2)*y_3^X(i,3)*y_4^X(i,4)*y_5^X(i,5)*y_6^X(i,6))
%sol = solve([eqn1,eqn2, eqn3,eqn4,eqn5,eqn6,eqn7], [y_1,y_2, y_3, y_4, y_5, y_6, y_7]);
sol = solve([eqn2, eqn3,eqn4,eqn5,eqn6,eqn7], [y_2, y_3, y_4, y_5, y_6, y_7]);
%sol.y_1
sol.y_2
sol.y_3
sol.y_4
sol.y_5
sol.y_6
sol.y_7

y_2=1
sol = solve([eqn3,eqn4,eqn5,eqn6,eqn7], [y_3, y_4, y_5, y_6, y_7]);
%sol.y_1
sol.y_3
sol.y_4
sol.y_5
sol.y_6
sol.y_7

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




