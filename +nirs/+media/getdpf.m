function DPF_val = getdpf(dist_l)
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
        load([fileparts(which('nirs.media.getdpf')) filesep 'dpf1010.mat']);
        k = ismember(DPFnorm(1,:), dist_l);
        DPF_val = DPFnorm(:,k);
        DPF_val(1,:) = [];
    catch
        dist_g = load('dpf1010.mat');
    end
end