

% Load the data
load('R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\ft_grandaverage_tepopt.mat');

elec = grandAverage.modified.elec;

cfg = [];
cfg.method = 'distance';
cfg.elec = elec;          % use your converted EEGLAB electrode structure
cfg.neighbourdist = 50; % in meters (tune for your cap; ~8 cm is typical)
neighbours = ft_prepare_neighbours(cfg);


cfg = [];
cfg.elec = elec;                % this is needed to show them in 3D
cfg.neighbours = neighbours;    % these are the initial neighbours
ft_neighbourplot(cfg);

save('R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\neighbours_tepopt.mat',"neighbours");