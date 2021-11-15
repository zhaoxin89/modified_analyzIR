classdef OpticalDensity3 < nirs.modules.AbstractModule
%% OpticalDensity2 - Converts raw data to optical density (zhaoxin modified).
% 
% dOD = -log( raw/raw_0 )

    methods
        function obj = OpticalDensity3( prevJob )
           obj.name = 'Optical Density3';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
            for i = 1:numel(data)
                d = data(i).data;
                

                d0 = data(i).data_I0;
                
                d=-log(d./(ones(size(d,1),1)*d0));
                
                %d = bsxfun( @plus, -log(d), log(m) );
                
                if(~isreal(d))
                   % disp('Warning: negative intensities encountered');
                   % d= abs(d);
                   % d=max(d,eps(1));
                end
                
                data(i).data = real(d);
                
                data(i).data(isinf(data(i).data)|isnan(data(i).data)) = 0;
            end
        end
    end
    
end

