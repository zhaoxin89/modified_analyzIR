classdef MedFiltChannels < nirs.modules.AbstractModule
%% AverageChannels - average raw channel data based on 3 distance groups (created by zhaoxin).
% 
% input - data_length * total_selected_channels * n_wl (max: 420)
% output - data_length * 15 * n_wl (90)

    methods
        function obj = MedFiltChannels( prevJob )
           obj.name = 'Median-filter channel data from the same distance';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
			
            for i = 1:numel(data)
                d = data(i).data;
				wl_n = length(data(i).probe.types);
				
                dist = data(i).probe.distances;
                [dist_u, pos_idx] = unique(dist);
                
                d_med = zeros(size(d,1),length(dist_u)*wl_n);
                
                [~,need_exclude] = find(data(i).is_selected == 0);
                
                for j = 1:length(dist_u)
                    v = find (dist == dist_u(j));
                    
                    v = setdiff(v, need_exclude); % exclude bad channels
                    
                    d_s = d(:,v); % select data with given distance
                    rep_elem = linspace(1,wl_n,wl_n);
                    gp_id = repmat(rep_elem, 1, size(d_s,2)/wl_n);
                    
                    data_med = zeros(size(d_s,1),1);
                    for l = 1:wl_n
                        [~,vv] = find(gp_id == l);
                        d_s_cur_wl = d_s(:,vv);
                        for k = 1:size(d_s,1)
                           mid_val = sort(d_s_cur_wl(k,:));
                           mid_val = mid_val(length(mid_val)/2);
                           data_med(k) = mid_val;
                        end
                    d_med(:,(j-1)*wl_n+l) = data_med;
                    end
                end
                
                %d = bsxfun( @plus, -log(d), log(m) );
                % TODO optimize later
                data(i).data = d_med;
                new_link_idx = zeros(wl_n*length(dist_u),1);
                for k = 1:length(pos_idx)
                    new_link_idx((k-1)*wl_n+1) = pos_idx(k);
                    new_link_idx((k-1)*wl_n+2) = pos_idx(k)+1;
                    new_link_idx((k-1)*wl_n+3) = pos_idx(k)+2;
                    new_link_idx((k-1)*wl_n+4) = pos_idx(k)+3;
                    new_link_idx((k-1)*wl_n+5) = pos_idx(k)+4;
                    new_link_idx((k-1)*wl_n+6) = pos_idx(k)+5;
                end
                link = data(i).probe.link;
                new_link = link(new_link_idx,:);
                data(i).probe.link = new_link;
            end
        end
    end
    
end

