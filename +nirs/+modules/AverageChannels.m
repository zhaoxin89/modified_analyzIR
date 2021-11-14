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
                
                %TODO optimize the following code
                v = find(dist_v <= 9); %short distance
				d_s = d(:,v);
                gp_id = repmat([1 2 3 4 5 6], 1, size(d_s,2)/6);
				d_s_mean = grpstats(d_s', gp_id, {'mean'})';
				d_s_round = round(dist_v(v));
                uv = unique(d_s_round); 
                n = histc( d_s_round,uv);
                if(data(i).is_first_epoch == true)
                    dpf = nirs.media.getdpf(uv);
                    dpf_s = zeros(6,1);
                    for j = 1:length(n)
                        dpf_s = dpf_s + dpf(:,j).*n(j);
                    end
                end
                dpf_s = dpf_s./sum(n);
                
                v = find((9 < dist_v) & (dist_v < 39)); %middle distance
				d_m = d(:,v);
                gp_id = repmat([1 2 3 4 5 6], 1, size(d_m,2)/6);
				d_m_mean = grpstats(d_m', gp_id, {'mean'})';
                d_m_round = round(dist_v(v));
                uv = unique(d_m_round);
                n = histc( d_m_round,uv);
                if(data(i).is_first_epoch == true)
                    dpf = nirs.media.getdpf(uv);
                    dpf_m = zeros(6,1);
                    for j = 1:length(n)
                        dpf_m = dpf_m + dpf(:,j).*n(j);
                    end
                end
                dpf_m = dpf_m./sum(n);
                
                v = find(dist_v() >= 39); %large distance
				d_l = d(:,v);
                gp_id = repmat([1 2 3 4 5 6], 1, size(d_l,2)/6);
				d_l_mean = grpstats(d_l', gp_id, {'mean'})';
                d_l_round = round(dist_v(v));
                uv = unique(d_l_round);
                n = histc( d_l_round,uv);
                if(data(i).is_first_epoch == true)
                    dpf = nirs.media.getdpf(uv);
                    dpf_l = zeros(6,1);
                    for j = 1:length(n)
                        dpf_l = dpf_l + dpf(:,j).*n(j);
                    end
                end
                dpf_l = dpf_l./sum(n);
                
                d_mean = [d_s_mean, d_m_mean, d_l_mean];
                
                %d = bsxfun( @plus, -log(d), log(m) );
               
                data(i).data = d_mean;
                
                if(data(i).is_first_epoch == true)
                    data(i).data_I0 = d_mean(1,:); % store the I0 data for calc. Log
                    % calc. DPF mean value
                    data(i).DPF_mean = [dpf_s, dpf_m, dpf_l];
                end
                
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

