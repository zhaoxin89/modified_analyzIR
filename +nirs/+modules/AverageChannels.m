classdef AverageChannels < nirs.modules.AbstractModule
%% AverageChannels - average raw channel data based on 3 distance groups (created by zhaoxin).
% 
% dOD = -log( raw/raw_0 )

    methods
        function obj = AverageChannels( prevJob )
           obj.name = 'Average Channels';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
			
            for i = 1:numel(data)
                d = data(i).data;
				wl_n = length(data(i).probe.types);
				
                dist_v = data(i).probe.distances;
 
                v = find(dist_v() <= 9); %short distance
				d_s = d(:,v);
                gp_id = repmat([1 2 3 4 5 6], 1, size(d_s,2)/6);
				d_s_mean = grpstats(d_s', gp_id, {'mean'})';
				dist_s_mean = mean(dist_v(v));
                
                v = find(9 < dist_v() < 39); %middle distance
				d_m = d(:,v);
                gp_id = repmat([1 2 3 4 5 6], 1, size(d_m,2)/6);
				d_m_mean = grpstats(d_m', gp_id, {'mean'})';
                dist_m_mean = mean(dist_v(v));
                
                v = find(dist_v() >= 39); %middle distance
				d_l = d(:,v);
                gp_id = repmat([1 2 3 4 5 6], 1, size(d_l,2)/6);
				d_l_mean = grpstats(d_l', gp_id, {'mean'})';
                dist_l_mean = mean(dist_v(v));
                
                d_mean = [d_s_mean, d_m_mean, d_l_mean];
                
                %d = bsxfun( @plus, -log(d), log(m) );
               
                data(i).data = d_mean;
                iSrc = ones(18,1);
                iDet = repelem([1 2 3]', 6);
                wl = repmat([660 730 762 810 850 900]', 3, 1);
                link = table(iSrc,iDet, wl,'VariableNames',{'source',' detector','type'});
                data(i).probe.link = link;
                
                probe = nirs.core.Probe([-27 9 0], [-27 0 0;-8 -4 0; 27 0 0], link );
                data(i).probe = probe;
            end
        end
    end
    
end

