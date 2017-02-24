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

            %list1 starts as the basal species and we will add species connected to it.
            list1=basalsp;
            
            while length(list1)<nichewebsize % Each repetition of this loop adds species that are connected to the list
                list_size=length(list1); % Measure the length of the list before you add connected species
                
                for whichspec=list1' %Go through all the elements in the list of species connected to basal species
                    list1=[list1; find(nicheweb(:,whichspec)==1)]; % Add species connected to the species in the list
                end
                list1=unique(list1); % Make sure you're not adding redundant species
                
                if list_size==length(list1) %If the list is not increasing in size, you can quit.
                    ok_n=0; %if there are species not connected to basal, delete the web
                    break
                end
            end
       
            if ok_n==1
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