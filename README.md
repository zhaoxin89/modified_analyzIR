
![workflow](https://user-images.githubusercontent.com/20672666/141788056-6bd2ed09-f615-4eb2-b530-e7a707af38bd.jpg)
![image](https://user-images.githubusercontent.com/20672666/146216969-44b59430-537d-44f8-ba7e-3aa4e643150e.png)

# usage: 

# add nirs-toolbox to Matlab paths 
toolbox_path = 'C:\fNIRS\nirs-toolbox';
addpath(genpath(toolbox_path));
#note: you may need to change the path based on where the files are stored.

# load IHM data
raw = nirs.io.loadIHMData('DATA_NIRSOP4.mat'); 
#note: you can use raw.draw or raw.gui for visualization.

# build pipeline and perform OD and BLL calculation. 
#Note that we can add jobs sequentially and call jobs.run to execute jobs while passing the outcome of one job to another

jobs = nirs.modules.AverageChannels()

jobs = nirs.modules.OpticalDensity3(jobs);

jobs = nirs.modules.ShortChannelRegression(jobs);

jobs = nirs.modules.BeerLambertLaw2(jobs);

# split raw data into spochs (as if the signals are processed in real time) and apply pipeline
#example:

    WIN_LEN = 5; % window width is set to 5 seconds 
    step_cnt = WIN_LEN * raw.Fs;
    t = 0:1/raw.Fs: WIN_LEN - 1/raw.Fs;
    for i = 1:floor(length(raw.time)/length(t))

        % prepare data epoch
        raw_w = raw;
        raw_w.data = raw.data((i-1)*step_cnt+1:i*step_cnt,:);
        raw_w.time = t;

        if(i == 1)
            raw_w.is_first_epoch = true;
        else 
            raw_w.is_first_epoch = false;
        end

        % apply pipeline to data epoch
        Hb = jobs.run(raw_w);

        % obtain global information (mean dpf etc.) from results 
        if i == 1
            Hb_total = Hb;
            raw.DPF_mean = Hb.DPF_mean;
            raw.data_I0 = Hb.data_I0;
            raw.probe.avr_distances = Hb.probe.avr_distances;
        else
            Hb_total.data = [Hb_total.data; Hb.data];
        end
    end

    % update time
    Hb_total.time = 0:1/raw.Fs:size(Hb_total.data,1)/raw.Fs-1/raw.Fs;


# visualize results
nirs.viz.nirsviewer

# for filters we should call homer2 functions
cd 'C:\fNIRS\homer2'
setpaths;

# check and correct data if necessary
Hb_total(isnan(Hb_total)) = 0;

# apply lowpass filter to hemoglobin concentrations 
jobs = nirs.modules.Run_HOMER2();

jobs.fcn = 'hmrBandpassFilt';

jobs.vars.lpf = 0.1;

jobs.vars.hpf = 0;

Hb_filtered = jobs.run(Hb_total);
