classdef OpticalDensity2 < nirs.modules.AbstractModule
%% OpticalDensity2 - Converts raw data to optical density (zhaoxin modified).
% 
% dOD = -log( raw/raw_0 )

    methods
        function obj = OpticalDensity2( prevJob )
           obj.name = 'Optical Density2';
           if nargin > 0
               obj.prevJob = prevJob;
           end
        end
        
        function data = runThis( obj, data )
            for i = 1:numel(data)
                d = data(i).data;
                

                d0 = d(1,:);
                
                d=-log(d./(ones(size(d,1),1)*d0));
                
                %d = bsxfun( @plus, -log(d), log(m) );
                
                if(~isreal(d))
                   % disp('Warning: negative intensities encountered');
                   % d= abs(d);
                   % d=max(d,eps(1));
                end
                
                data(i).data = real(d);
            end
        end
    end
    
end

