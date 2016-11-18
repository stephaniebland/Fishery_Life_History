function[] = attach(s)
%from https://www.mathworks.com/matlabcentral/fileexchange/35436-attach/content/attach.m
%ATTACH  attach fields in structure to current workspace
%
%This function works similarly to the attach function in R.
%
% Usage: attach(s)
%
%
%
%INPUTS:
%
%   s: a structure containing fields to be attached to current work space
%
%OUTPUTS:
%
%   <none>
%
% EXAMPLE:
%
%   %create a structure with fields x and y, to be assigned to the current
%   %workspace
%   vars = struct('x',10,'y',{{'apple' 'banana' 'cherry'}});
%
%   %attach x and y to the current workspace
%   attach(vars);
%
%   %verify that x and y can now be accessed
%   x
%   y
%
%
% SEE ALSO: EVAL, ASSIGNIN, STRUCT
%
%   AUTHOR: JEREMY R. MANNING
%  CONTACT: manning3@princeton.edu


%CHANGELOG
%3-16-10    JRM      Wrote it.

assert(length(s) <= 1,'struct arrays are not supported.  ensure length(s) <= 1.');
if isempty(s), return; end

assert(isstruct(s),'must pass in a structure');
names = fieldnames(s);
vals = cellfun(@getfield,repmat({s},size(names,1),size(names,2)),fieldnames(s),'UniformOutput',false);
cellfun(@assignin,repmat({'caller'},size(names,1),size(names,2)),names,vals);
