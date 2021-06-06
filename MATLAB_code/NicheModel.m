%--------------------------------------------------------------------------
% Program by: Rosalyn Rael
% Barbara Bauer added a part removing species not connected to a basal
% and changed the output to a 'row eats column' type matrix
% Coralie Picoche and Perrine Tonin changed the 'removing part' in
% order not to change the connectance
% Ref: Williams and Martinez, Nature, 2000.
% Modified by Stephanie Bland
%--------------------------------------------------------------------------
% This function produces a niche model food web with .
% Input: number of species, connectance
% Output: adjacency matrix called 'nicheweb'
% A(i,j) = 1 if i eats j.(row eats column)
%--------------------------------------------------------------------------
%nicheweb,n_new,c_new,r_new
function [orig]= NicheModel(cannibal_invert,num_species, connectance)
    %% Loop until the right properties are found in the web.
    tries=10000;        % Maximum number of tries
    ok_n=0;             % ok_n=0 is to test if you have a suitable web
    errorconnec=0.025;  % Error on the connectance

    %% Does connectance error allow an integer value for the number of links?
    Lmin=ceil(connectance*(1-errorconnec)*num_species^2);
    Lmax=floor(connectance*(1+errorconnec)*num_species^2);
    if Lmin>Lmax
        error('Impossible to create a foodweb with the given number of species and connectance +/- 2.5%')
    end

    %% Create new webs until you have one that satisfies all the requirements
    while (tries>0 && ok_n==0)
        tries=tries-1;
        ok_n=1; % ok_n=1 when it's a suitable web. Assume true until you test it
        n = rand(num_species,1);% assigns niche values from a uniform distribution

        [nicheweb,orig.n_new,orig.r_new,orig.c_new]=CreateWeb(num_species,connectance,n);

        %% Invertebrate Cannibalism
        if cannibal_invert==false
            nicheweb=nicheweb-diag(diag(nicheweb));
        end

        %%-----------------------------------------------------------------
        % DISCARD UNSUITABLE WEBS
        %%-----------------------------------------------------------------
        %% 1. Discard Webs with isolated species
        zerocols = find(sum(nicheweb,1)==0); %columns with only zero (they are not eaten by anyone)
        basalsp = find(sum(nicheweb,2)==0); %they don't eat anyone
        qq = intersect(basalsp,zerocols); %both: index of isolated species

        if numel(qq)~=0
            ok_n=0;
            continue
        end

        %% 2. Discard webs that aren't connected (disconnected groups)
        if isConnected(nicheweb)==0
            ok_n=0;
            continue
        end

        %% 3. Discard webs that don't have a close enough connectance value
        links = sum(nicheweb>0);  %% indices of links (which element in nicheweb?)
        C_web = sum(links)/(num_species^2);  %% Actual connectance
        if abs(C_web-connectance)*1.0/connectance>errorconnec
            ok_n=0;
            continue
        end

        %% 4. Discard if there is a species not connected to a basal
        nichewebsize=size(nicheweb,2);
        list1=basalsp;%Start with basal species and add species connected to it

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
        
    end

    %% stop searching for a possible web after too many tries
    if tries==0
        error('Impossible to create a foodweb within the number of tries you set')
    end
    
    orig.nicheweb=nicheweb;
end

