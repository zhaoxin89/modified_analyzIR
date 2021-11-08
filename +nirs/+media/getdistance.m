function dist_g = getdistance()
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
        dist_g = load([fileparts(which('nirs.media.getdistance')) filesep 'Tab_distance2.mat']);
    catch
        dist_g = load('Tab_distance2.mat');
    end
end