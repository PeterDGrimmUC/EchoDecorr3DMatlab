testDir = '/Volumes/Data/USData/trial_10/2019-7-22_experiment_2_trial10/Complete/IQDATA_Date_07-22-2019_Time_16-53-10-40';
filename = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
read_lbdump(fullfile(testDir,filename));
mappedfile = memmapfile(fullfile(testDir,filename));
