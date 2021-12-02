classdef SQIStage1 < nirs.modules.AbstractModule
%% SQI stage1 - exclude bad quality channels 
% the input data is windowed segments

    methods
        function obj = SQIStage1( prevJob )
           obj.name = 'SQI Stage 1';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
            for i = 1:numel(data)
                d = data(i).data;
                link = data(i).probe.link;
                %baseline change detection
                cov = std(d)./mean(d); % coefficient of variation
                
                [~, vv] = find(cov > 0.15);
                

                %cardiac pulsation detection
                %f = designfilt('bandpassfir','FilterOrder',30, ...
                %     'CutoffFrequency1',0.5,'CutoffFrequency2',1.5, ...
                %     'SampleRate',10);
                %d_f = filtfilt(f,d);
                no_cardiac_idx = [];
                %for j = 1: size(d_f,2)
                %    [pk,~] = findpeaks(d_f(:,j));
                %    if(length(pk)<7)|| (length(pk)>12)
                %        no_cardiac_idx(end+1) = j;
                %    end
                %end
                to_exclude = union (vv, no_cardiac_idx);
                
                %if one wavelength is excluded, all the other five should
                %be excluded also
                for k = 1:420/6
                    k_t = ((k-1)*6 +1:(k-1)*6 +6);
                    if(~isempty(intersect(k_t, to_exclude)))
                        to_exclude = union(to_exclude, k_t);
                    end
                end

                d(:,to_exclude) = [];
                link(to_exclude,:) = [];
                data(i).is_excluded(to_exclude) = 1;
                data(i).data = d;
                data(i).probe.link = link;
            end
        end
    end
    
end

