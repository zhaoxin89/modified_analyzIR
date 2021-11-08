
# usage: 

# add nirs-toolbox to Matlab paths 
toolbox_path = 'C:\fNIRS\nirs-toolbox';

addpath(genpath(toolbox_path));

# load IHM data
raw = nirs.io.loadIHMData('DATA_NIRSOP4.mat'); 
raw.draw;
close;
raw.gui;

# perform OD and BLL calculation. Note that we can add jobs sequentially and call jobs.run to execute jobs while passing the outcome of one job to another
jobs = nirs.modules.OpticalDensity();
jobs = nirs.modules.BeerLambertLaw(jobs);
Hb = jobs.run(raw);

# visualize results
nirs.viz.nirsviewer

# call homer2 functions
cd 'C:\fNIRS\homer2'
setpaths;

Hb(isnan(Hb)) = 0;

# apply lowpass filter to hemoglobin concentrations 
jobs = nirs.modules.Run_HOMER2();
jobs.fcn = 'hmrBandpassFilt';
jobs.vars.lpf = 0.1;
jobs.vars.hpf = 0;
Hb_filtered = jobs.run(Hb);
