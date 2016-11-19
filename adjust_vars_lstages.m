% function [varargout]=adjust_vars_lstages(varargin)
%     
%     trial=0;
%     testing=inputname(varargin);
%     %test=inputname(varargin);
%     for i=1:nargin
%         trial=trial+1;
%         varargout{i}=varargin{i}*2;
%         %varargout{i}=varargin{i}*2;
% %        	inputname(i)=varargin{i}*2;
% %         varargout{i}=
% 
%     end
% end

function [varargout]=adjust_vars_lstages(N_stages,varargin)
    for i=2:nargin
        varargout{:,i}=repelem(varargin{:,i},N_stages);
    end
end