classdef CalculateRSO2 < nirs.modules.AbstractModule
    %% CalculateCMRO2 - This function will add CMRO2 and Flow
    %  The input must have the hbo/hbr data types.
    %

    methods
        
        function obj = CalculateRSO2( prevJob )
            obj.name = 'calculate RSO2';
            if nargin > 0
                obj.prevJob = prevJob;
            end
        end
        
        function data = runThis( obj, data )
            if(~all(ismember({'hbo','hbr'},data(1).probe.link.type)))
                warning('data does not contain oxy/deoxy-Hb.  Use the MBLL first');
                return
            end
 
            for i = 1:numel(data)
                disp([num2str(i) ' of ' num2str(length(data))]);
                %Time series models
                link=data(i).probe.link;

                HbO2=data(i).data(:,1:2:end);
                HbR=data(i).data(:,2:2:end);
          
                RSO2 = 100*HbO2./(HbO2+HbR);
                RSO2(isnan(RSO2)) = 0;
                fprintf(1,'  Done \r')
                linkRSO2 = data(i).probe.link;
                linkRSO2(2:2:end,:) = [];
                linkRSO2.type = {'rso2','rso2','rso2'}';
                data(i).probe.link=linkRSO2;  
                data(i).data = RSO2;
            end
        end
    end
    
end

