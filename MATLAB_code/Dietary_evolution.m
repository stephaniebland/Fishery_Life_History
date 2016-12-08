%% Shift Diet up or down trophic levels for Dietary evolution that occurs part way through simulation

function [shifted_web]=Dietary_evolution(nicheweb,isfish,evolv_diet,n)
[~, Indx] = sort(n);
keepindex(Indx)=1:length(nicheweb);

shifted_web=nicheweb(Indx,Indx);%Reorder according to niche index or whatever you use to compare size of species

[~,startIndex]=max(shifted_web>0,[],2);%For each row, index smallest prey
[~,endIndex]=max(fliplr(shifted_web)>0,[],2);%For each row, index largest prey
for i=1:size(shifted_web,1)
    shifted_web(i,:)=circshift(shifted_web(i,:),max(1-startIndex(i),min(evolv_diet,0)));%Shift diet left (negative numbers make fish eat smaller things)
    shifted_web(i,:)=circshift(shifted_web(i,:),min(endIndex(i)-1,max(evolv_diet,0)));%Shift diet right (positive numbers make fish eat larger things)
end

shifted_web=shifted_web(keepindex,keepindex);%revert to actual species order
shifted_web(~isfish,:)=nicheweb(~isfish,:);%preserve diets of non-fish species (indexed by species, not n, so comes after reverting index)

end

