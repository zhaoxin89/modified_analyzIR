classdef ApplyMedFilt < nirs.modules.AbstractModule
%% OpticalDensity2 - Converts raw data to optical density (zhaoxin modified).
% 
    properties
        medfilt_order = 20;
    end
    methods
        function obj = ApplyMedFilt( prevJob )
           obj.name = 'Apply median filter with order predefined in properties';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
            for i = 1:numel(data)
                d = data(i).data;
                d = medfilt1(d, obj.medfilt_order);
                data(i).data = d;
            end
        end
    end
end

