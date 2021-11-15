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
                alpha_m_s(isnan(alpha_m_s)|isinf(alpha_m_s)) = 0;
                d_ms = d(:,7:12) - alpha_m_s .* d(:,1:6);
                
                alpha_l_s = dot(d(:,13:18),d(:,1:6))./(dot(d(:,1:6),d(:,1:6)));
                alpha_l_s(isnan(alpha_l_s)|isinf(alpha_l_s)) = 0;
                d_ls = d(:,13:18) - alpha_l_s .* d(:,1:6);
                
                alpha_l_m = dot(d(:,13:18),d(:,7:12))./(dot(d(:,7:12),d(:,7:12)));
                alpha_l_m(isnan(alpha_l_m)|isinf(alpha_l_m)) = 0;
                d_lm = d(:,13:18) - alpha_l_m .* d(:,7:12);
                
                %d = bsxfun( @plus, -log(d), log(m) );
                
                data(i).data = [d_ms d_ls d_lm];
            end
        end
    end
    
end

