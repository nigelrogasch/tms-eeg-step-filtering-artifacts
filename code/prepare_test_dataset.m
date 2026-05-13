% Prepare test data set

% Load data
EEG = pop_loadbv('R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Merrick_temp\TMSEEG_DS\outputs\sub-001\ses-tmseeg1\', 'sub-001_ses-tmseeg1_restingtmspfc_run-1_eeg.vhdr');

% Remove unused channels
EEG = pop_select( EEG, 'rmchannel',{'31','32'});

% Add electrode locations
eeglabPath = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0\';
EEG = pop_chanedit(EEG, 'lookup',fullfile(eeglabPath,'plugins','dipfit5.2','standard_BESA','standard-10-5-cap385.elp'));

% Epoch data
EEG = pop_epoch( EEG, {  'S127'  }, [-1  1], 'epochinfo', 'yes');

% Remove baseline
EEG = pop_rmbase( EEG, [-500 -10] ,[]);

% Remove artifact
EEG = pop_tesa_removedata( EEG, [-2 12] );

% Interpolate artifact
EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

% Downsample to 1000 Hz
EEG = pop_resample( EEG, 1000);

% Save data set
EEG = pop_saveset( EEG, 'filename','test_dataset.set','filepath','R:\\Low_Cost_Storage\\healthsciences\\SPRH\\NeuroPAD\\projects\\2025-tms-eeg-step-artifact\\data\\');
