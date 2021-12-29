function data = loaIHMData(filenames, hemi, force )

if(nargin<3 || isempty(force))
    force=false;
end

if(nargin<2 || isempty(hemi))
    hemi = 1; % left hemisphere
end
    % if a single filename, put it in a cell
    if ischar( filenames )
        filenames = {filenames};
    end
    
    SrcPos = [-27  9; -27  -9;  0  0; 27  9; 27  -9];
    SrcPos(:,end+1)= 0;
    DetPos = [ -27  0;-19  9;-19  0;-19  -9;-8  4; -8  -4;0  9;0  -9; 8  4;8  -4;19  9;19  0;19  -9;27  0];
    DetPos(:,end+1)= 0;
    iSrc = [1,2,3,4,5]; iSrc = repelem(iSrc, 84); iSrc = iSrc';
    iDet = (1:14); iDet = repelem(iDet, 6); iDet = repmat(iDet, 1,5); iDet = iDet';
    wl = [660 730 762 810 850 900];
    wl = repmat(wl, 1, 70); wl = wl';
    link = table(iSrc,iDet, wl,'VariableNames',{'source','detector','type'});
    data = nirs.core.Data.empty;
    
    % iterate through cell array
    for iFile = 1:length(filenames)
        
        [p f]=fileparts(filenames{iFile});
        if(~isempty(dir(fullfile(p,[f '.wl1']))) & ~force)
            %disp(['Skipping ' filenames{iFile} ': NIRx data found in same folder']);
            continue;
        end
        disp(['Loading ' filenames{iFile}]);
        try
            d = load(filenames{iFile}); 
            
            d = d.DATA_NIRS(hemi,:);
            
            m = 1e9;
            for i = 1:7
               n = cellfun(@numel,d{i});
               m_t = min(n,[],'all');
               if m>m_t
                   m = m_t;
               end
            end
            
            for i = 1:7
                d{i} = cellfun(@(x) x(1:m), d{i}, 'UniformOutput', false);
            end
            
            d1 = [];
            % subtraction of 7th wl
            for z = 1:6
                for x = 1: 5
                    for g = 1:14
                        d{z}{x,g}(1,:) = d{z}{x,g} - d{7}{x,g}(1,:);
                    end
                end
            end
            d(7) = [];
            
            for z = 1:6
                d1 = [d1, reshape(d{z}', [70,1])];
            end
            d1 = reshape(d1',[420,1]);
            d1 = cell2mat(d1)';
            % put into data class
            thisFile = nirs.core.Data();
            thisFile.description = filenames{iFile};
            
            t = 0:0.1:length(d{1,1}{1,1})/10;
            t(end) = []; t = t';
            nTime = length(t);
            
            % data

            thisFile.data = d1;

            % time vector
            thisFile.time = t;

            % probe
            probe = nirs.core.Probe( SrcPos, DetPos, link);
            thisFile.probe = probe;
            %thisFile.probe = nirs.util.sd2probe( d.SD );

            %load demographics
            if(isfield(d,'demographics'))
                flds=fields(d.demographics);
                for i=1:length(flds)
                    thisFile.demographics(flds{i})=getfield(d.demographics,flds{i});
                end
            end
            
            % stimulus vector
            if isfield(d,'StimDesign')
                thisFile.stimulus = nirs.util.convertStimDesignStruct( d.StimDesign,d.t );
            else
                % This will handle the HOMER-2 nirs format
                stims = Dictionary();
                if(isfield(d,'s'))
                    for idx=1:size(d.s,2)
                        
                        if isfield(d,'CondNames')
                            stimname = d.CondNames{idx};
                        else
                            stimname = ['stim_channel' num2str(idx)];
                        end
                        
                        if(islogical(d.s)); d.s=d.s*1; end;
                        d.s(:,idx)=d.s(:,idx)./max(d.s(:,idx));
                        
                        s = nirs.design.vector2event( d.t , d.s(:,idx) , stimname );
                        
                        if(~isempty(s.onset))
                            stims(stimname)=s;
                        end
                        
                    end
                end
                thisFile.stimulus=stims;
            end

            % demographics for group level
            if isfield(d,'Demographics')
                for i = 1:length(d.Demographics)
                    name    = d.Demographics(i).name;
                    value   = d.Demographics(i).value;
                    thisFile.demographics(name) = value;
                end
            end
         
            if(isfield(d,'brainsight'))
                a=d.brainsight.acquisition.auxData;
                t=d.brainsight.acquisition.auxTime;
                 for i=1:size(a,2)
                    name{i,1}=['aux-' num2str(i)];
                end
                aux=nirs.core.GenericData(a,t,table(name,repmat({'aux'},length(name),1),'VariableNames',{'name','type'}));
                thisFile.auxillary('aux')=aux;
                thisFile.auxillary('brainsight')=d.brainsight;
            end
            
            if(isfield(d,'aux') || isfield(d,'aux10')) && (~isempty(d.aux))
                if(isfield(d,'aux'))
                    a=d.aux;
                else
                    a=d.aux10;
                end
                a=reshape(a,size(a,1),[]);
                for i=1:size(a,2)
                    name{i,1}=['aux-' num2str(i)];
                end
                aux=nirs.core.GenericData(a,d.t,table(name,repmat({'aux'},length(name),1),'VariableNames',{'name','type'}));
                aux.description=thisFile.description;
                thisFile.auxillary('aux')=aux;
            end
            
        % append to list of data
        data(end+1) = thisFile.sorted();
            
        catch err
            if(~exist('d') || ~isfield(d,'d') || isempty(d.d))
                 disp('Empty file found (skipping):');
                 disp(filenames{iFile});
            else
                warning(err.message)
            end
        end
    end
end
