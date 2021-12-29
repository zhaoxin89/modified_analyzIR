classdef SelectChans < nirs.modules.AbstractModule
%% SelectChans - this function select LEDs and PDs with good signal quality
% ZHAO Xin 2021
% this function will evaluate SCI for vectors with distance = 8, 9 and
% 12mm.
% If all the above-mentiioned vectors connected to one LED is HS, the LED
% is HS. Otherwise the corresponding PD is HS
% Note: This should be run only once (at system initialization).
    properties
        win_size = 10; % 10 seconds 
        SCI_th = 0.8;
    end

    methods
        function obj = SelectChans( prevJob )
           obj.name = 'Select channels regarding SQI';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )

            for i = 1:numel(data)
                
                if size(data(i).data,1) < data(i).Fs * obj.win_size % 20 second 
                    warning(['Window length too short for SCI, exit']);
                    return;
                end 
                
                % we take the first window for SCI analysis
                d = data(i);
                d.data = d.data(1:data(i).Fs * obj.win_size,:);  

                wl_n = length(data(i).probe.types);
                dist = data(i).probe.distances;
                link = data(i).probe.link;
                dist_u = dist(1:wl_n:end);
                dist_u_short = find(dist_u<=12);
                sci = nirs.util.scalp_coupling_index(d);
                sci_short = sci(dist_u_short,:);
                bad_idx = find(table2array(sci_short(:,ismember(sci_short.Properties.VariableNames,'sci')))<obj.SCI_th);
                
                %TODO: also check fpower
                
                sci_short_bad = sci_short(bad_idx,:);
                % now determine if bad channels come from LED or PD
                source_bad = table2array(sci_short_bad(:,ismember(sci_short.Properties.VariableNames,'source')));
                det_bad_all = table2array(sci_short_bad(:,ismember(sci_short_bad.Properties.VariableNames,'detector')));
                source_bad_l = unique(source_bad);
                for j = 1: length(source_bad_l)
                    if source_bad_l(j) == 3 % the 3th LED (middle) 
                       if length(find(source_bad == 3)) == 6 % all the 6 channels do not work, so LED is broken
                           % the LED is broken
                           data(i).is_selected(table2array(link(:,ismember(link.Properties.VariableNames,'source')))==3)=0;
                       else
                           % the PD is broken
                           % find which PD is broken 
                           %line_number for source = 3
                           line_idx_source3 = table2array(sci_short_bad(:,ismember(sci_short_bad.Properties.VariableNames,'source')))==3;
                           det_bad_3 = det_bad_all(line_idx_source3);
                           % set is_selected for det_bad_3 and source = 3 to 0
                           data(i).is_selected(bitand(table2array(link(:,ismember(link.Properties.VariableNames,'source'))) == 3, ...
                               ismember(table2array(link(:,ismember(link.Properties.VariableNames,'detector'))), det_bad_3))) = 0;
                       end
                    else % the 1, 2, 4 and 5th LED
                        led_n = source_bad_l(j);
                        if length(find(source_bad == led_n)) == 3 % all the 3 channels do not work, so LED is broken
                            % the led is broken
                            data(i).is_selected(table2array(link(:,ismember(link.Properties.VariableNames,'source')))==led_n)=0;
                        else
                            % the PD is broken
                            line_idx_sourcen = table2array(sci_short_bad(:,ismember(sci_short_bad.Properties.VariableNames,'source')))==led_n;
                           det_bad_n = det_bad_all(line_idx_sourcen);
                           % set is_selected for det_bad_n and source = led_n to 0
                           data(i).is_selected(bitand(table2array(link(:,ismember(link.Properties.VariableNames,'source'))) == led_n, ...
                               ismember(table2array(link(:,ismember(link.Properties.VariableNames,'detector'))), det_bad_n))) = 0;
                        end
                    end
                end
            end
        end
    end
end

