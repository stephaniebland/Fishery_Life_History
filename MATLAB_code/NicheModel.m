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

% uncomment below to use as a function if called by another script:
 %function [nicheweb,Index_par]= NicheModel(num_species, connectance)%old
 %line, no idea what Index_par is even supposed to be.
 function [nicheweb,n_new,c_new,r_new]= NicheModel(num_species, connectance)
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

    %----------------------------------------------------------------------
    % designate range for each species
    % parameters for beta distribution:
        alpha = 1;
        beta = (1-2*connectance)/(2*connectance); %Coralie : ???
        r = betarnd(alpha,beta,num_species,1);    %vector of ranges
        r = r.*n; 

    %----------------------------------------------------------------------    
    % set center of range, uniformly distributed in [r_i/2,n_i];
        c = min(1-r./2,rand(num_species,1).*(n-r./2)+r./2); %CP : rand was always the same
        %The min term (1-r/2) is just to make sure that you don't exceed
        %the web; your predator will always prey on food in the web.  So if
        %you look at the species with the largest niche index, the center
        %of range can go all the way up to 1, but then the predator will be
        %deprived of half of it's food. So set min to guarantee it gets
        %fed. I still think this probably is biased though.
        c=rand(num_species,1).*(min(n,1-r./2)-r./2)+r./2; %Possible correction, because I think the first one was wrong.
     

    %----------------------------------------------------------------------
    % sort everything
        [n_new Indx] = sort(n);
        %n_new: niche values in ascending order
        %Indx: indexes of species in descending order
        %(-> 1 is the index of the smallest niche range, 10 is the index of
        %the largest)
        r_new = r(Indx); %the smallest r to highest index species
        c_new = c(Indx);
        r_new(1) = 0; %change the r of lowest index species to 0
        %so we have a basal species in every web

    %----------------------------------------------------------------------
    % Construct the web adjacency matrix
        web_mx = zeros(num_species);

        preymins = c_new - r_new/2; %lower border of niche range for every prey
        preymaxs = c_new + r_new/2; %upper border of niche range for every predator

        n_mx = n_new*ones(1,num_species); %fills the empty matrix with niche ranges
        preymins_mx = ones(num_species,1)*preymins'; %matrix with the lowest points of ranges in every column
        preymaxs_mx = ones(num_species,1)*preymaxs'; %same, with highest

        web_mx=((n_mx>=preymins_mx)+(n_mx<=preymaxs_mx)==2*ones(num_species));
    %if species in the row is in the niche range of the species in the
    %column, it gets eaten

    %----------------------------------------------------------------------
    % if there is an isolated species or something not connected to a basal
    % or a disconnected group, it's removed
        
        %1. removal if isolates
        nicheweb = web_mx'; %transposing the matrix (in the following codes we need that format)
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
    
%--------------------------------------------------------------------------
% stop searching for a possible web after too many tries
    if tries==0
        error('Impossible to create a foodweb within the number of tries you set')
    end