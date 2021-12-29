classdef StepDetection < nirs.modules.AbstractModule
%% OpticalDensity2 - Converts raw data to optical density (zhaoxin modified).
% 
    properties
        step_th = 0.15;
    end
    
    methods
        function obj = StepDetection( prevJob )
           obj.name = 'Detect steps';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
            for i = 1:numel(data)
                d = data(i).data;
                step_idx = std(d)./mean(d);
                
            end
        end
    end
end

