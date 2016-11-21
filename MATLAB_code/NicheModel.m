%--------------------------------------------------------------------------
% Program by: Rosalyn Rael
% Barbara Bauer added a part removing species not connected to a basal
% and changed the output to a 'row eats column' type matrix
% Coralie Picoche and Perrine Tonin changed the 'removing part' in 
% order not to change the connectance
% Ref: Williams and Martinez, Nature, 2000.
% Last modification : June 2011
%--------------------------------------------------------------------------
% This function produces a niche model food web with .
% Input: number of species, connectance
% Output: adjacency matrix called 'nicheweb' 
% A(i,j) = 1 if i eats j.(row eats column)
%--------------------------------------------------------------------------
%nicheweb,n_new,c_new,r_new
function [orig]= NicheModel(cannibal_invert,num_species, connectance)
% or uncomment below to use as stand-alone script
%num_species=10; %input('Enter number of species \n');
%connectance=.1; %input('Enter connectance \n'); Usually 0.09

%--------------------------------------------------------------------------
% loop until the right properties are found in the web.
    tries=10000;        %maximum number of tries
    ok_n=0;
    errorconnec=0.025;  %error on the connectance

%--------------------------------------------------------------------------
% verify that the allowed range of connectance allows an integer value of
% the number of links
    Lmin=ceil(connectance*(1-errorconnec)*num_species^2);
    Lmax=floor(connectance*(1+errorconnec)*num_species^2);
    if Lmin>Lmax
        error('Impossible to create a foodweb with the given number of species and connectance +/- 2.5%')
    end

%--------------------------------------------------------------------------
% assigns niche values from a uniform distribution
    while (tries>0 & ok_n==0)
        tries=tries-1;
        ok_n=1;
        n = rand(num_species,1);
        
       
        [web_mx,orig.n_new,orig.r_new,orig.c_new]=CreateWeb(num_species,connectance,n);
    
    %% Invertebrate Cannibalism
        if cannibal_invert==false
            web_mx=web_mx-diag(diag(web_mx));
        end
    
    %----------------------------------------------------------------------
    % if there is an isolated species or something not connected to a basal
    % or a disconnected group, it's removed
        
        %1. removal if isolates
        nicheweb=web_mx;
        nichewebsize=size(nicheweb,2);

        testmx1 = (nicheweb==zeros(nichewebsize)); %find zeros
        zerocols = find(sum(testmx1)==nichewebsize); %columns with only zero (they are not eaten by anyone)
        zerorows = find(sum(testmx1')==nichewebsize); %they don't eat anyone
        qq = intersect(zerorows,zerocols); %both: index of isolated species
  
        if numel(qq)~=0
            ok_n=0;
        else
            web_mx=nicheweb; %save the web

        %2. removal if species not connected to a basal
            nichewebsize=size(nicheweb,2);
            basalsp=find(sum(nicheweb,2)==0);

            %identify list1
            list1=basalsp;
            list2=[];
       
            while numel(list1)>0
            %look for connections
                for whichspec=1:length(list1)
                    whichcol=list1(whichspec);
                    list2=[list2; find(nicheweb(:,whichcol)==1)];
                    list2=unique(list2);
                end
 
            %make species connected to list1 zeros (isolates already removed)
                nicheweb(list1,:)=zeros(length(list1),nichewebsize);
                nicheweb(:,list1) = zeros(nichewebsize,length(list1));
   
            %make list2 the new list1
                list1=list2;
                list2=[];
            end

            %find indices of species not connected to basal
            list3=find(sum(nicheweb)>0);
            list3=[list3 find(sum(nicheweb,2)>0)'];
            list3=unique(list3);
       
            nicheweb = web_mx; %putting the web with no isolates and not connected to basals to nicheweb
       
            %if there are species not connected to basal, delete the web
            if numel(list3)>0
                ok_n=0;
            else
            %find if there are disconnected groups
                if isConnected(nicheweb)==1 
                    links = sum(web_mx>0);  %% indices of links (which element in web_mx?)
                    C_web = sum(links)/(num_species^2);  %% Actual connectance
                    if abs(C_web-connectance)*1.0/connectance>errorconnec
                        ok_n=0;
                    else
                        ok_n=1;
                    end
                else
                    ok_n=0;
                end   
            end
        end
    end
    orig.nicheweb=nicheweb;
%--------------------------------------------------------------------------
% stop searching for a possible web after too many tries
    if tries==0
        error('Impossible to create a foodweb within the number of tries you set')
    end