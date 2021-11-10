classdef ShortChannelRegression < nirs.modules.AbstractModule
%% AverageChannels - average raw channel data based on 3 distance groups (created by zhaoxin).
% 
% dOD = -log( raw/raw_0 )

    methods
        function obj = ShortChannelRegression( prevJob )
           obj.name = 'Short Channel Regression';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
			
            for i = 1:numel(data)
                d = data(i).data;
				wl_n = length(data(i).probe.types);
				
                
                alpha_m_s = dot(d(:,7:12),d(:,1:6))./(dot(d(:,1:6),d(:,1:6)));
                d(:,7:12) = d(:,7:12) - alpha_m_s .* d(:,1:6);
                
                alpha_l_s = dot(d(:,13:18),d(:,1:6))./(dot(d(:,1:6),d(:,1:6)));
                d(:,13:18) = d(:,13:18) - alpha_l_s .* d(:,1:6);
                
                d(:,1:6) = [];
                
                %d = bsxfun( @plus, -log(d), log(m) );
                
                data(i).data = d;
                iSrc = ones(12,1);
                iDet = repelem([1 2]', 6);
                wl = repmat([660 730 762 810 850 900]', 2, 1);
                link = table(iSrc,iDet, wl,'VariableNames',{'source',' detector','type'});
                data(i).probe.link = link;
                
                probe = nirs.core.Probe([-27 9 0], [-27 0 0;-8 -4 0], link );
                data(i).probe = probe;
            end
        end
    end
    
end

