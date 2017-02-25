clearvars -except simnum; clear global;
beep off
warning off MATLAB:divideByZero;
global reprod cont_reprod Effort;

%--------------------------------------------------------------------------
% Protocol parameters
%--------------------------------------------------------------------------
Parameters;
[orig] = NicheModel(cannibal_invert,S_0,connectance);%Create a connected (no infinite degrees of separation) foodweb with realistic species (eg. no predators without prey), and no isolated species.
nicheweb=orig.nicheweb;
web_mx=nicheweb;



zerocols = find(sum(nicheweb,1)==0); %columns with only zero (they are not eaten by anyone)
basalsp = find(sum(nicheweb,2)==0); %they don't eat anyone
qq = intersect(basalsp,zerocols); %both: index of isolated species


nichewebsize=size(nicheweb,2);
list1=basalsp;
num_species=S_0;


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


links = sum(web_mx>0);  %% indices of links (which element in web_mx?)
C_web = sum(links)/(num_species^2);  %% Actual connectance



[abs(C_web-connectance)*1.0/connectance, length(list1)-30, isConnected(nicheweb)-1,numel(qq)]