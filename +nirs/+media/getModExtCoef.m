function out = getModExtCoef( lambda )
% % Hemoglobin
% http://omlc.ogi.edu/spectra/hemoglobin/
% scott prahl

% % Fat
% by R.L.P. van Veen and H.J.C.M. Sterenborg, A. Pifferi, A. Torricelli and R. Cubeddu
% http://omlc.ogi.edu/spectra/fat/

% % Water
% D. J. Segelstein, "The complex refractive index of water," University of
% Missouri-Kansas City, (1981).

    try
        load([fileparts(which('nirs.media.getModExtCoef')) filesep 'ModExtCoef.mat'])
    catch
        load('ModExtCoef.mat');
    end
    if(iscell(lambda))
        lambda=str2num(cell2mat(lambda));
    end
    ModExtCoef = table2array(ModExtCoef);
    out = [];
    for i = 1: length(lambda)
        out = [out; ModExtCoef(ModExtCoef(:,1) == lambda(i),2:end)];
    end
    
end