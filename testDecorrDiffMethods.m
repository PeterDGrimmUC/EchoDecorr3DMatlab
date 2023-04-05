%% testDecorrDiffMethods.m
%%% checking for compatability between multiple scripts and the GUI
%% Load some functions that are handy for debugging
EchoDecorrPkg.Utils.lambdas;
%% Get data from files, they have different names so I'm reassigning them to a struct with identical names
numSham = 3; 
%%
decorr_nomotcorrect_GUI=load('FullExp_03-Apr-2023_2_recomp_nomotcorr.mat');
decorr_nomotcorrect_GUI=decorr_nomotcorrect_GUI.outDat;
decorr_motcorrect_GUI=load('FullExp_03-Apr-2023_2_recomp_motcorr.mat');
decorr_motcorrect_GUI=decorr_motcorrect_GUI.outDat;

decorr_motcorrect_GUI_saved=load('FullExp_03-Apr-2023_2.mat');
decorr_motcorrect_GUI_saved=struct('cumDecorrNoMotCorr',decorr_motcorrect_GUI_saved.outDat.decorr,'cumShamDecorr',false,'cumDecorrMotCorr',false);


decorr_elmirascript_in=load('20230403_trial2_testing_control_GUI_testing_control_GUI_IQcart_decorr_IBS_xyz_notflipped.mat');
decorr_elmirascript_mod=load('20230403_trial3_testing_control_GUI_testing_control_GUI_IQcart_decorr_IBS_xyz_notflipped_no1stvol.mat');

decorr_elmirascript_in.combined_cum_decorr=padarray(decorr_elmirascript_in.combined_cum_decorr,[1,1,1],'post');
decorr_elmirascript_in.combined_cumdecorr_motcorr=padarray(decorr_elmirascript_in.combined_cumdecorr_motcorr,[1,1,1],'post');
decorr_elmirascript_in.local_cum_decorr=padarray(decorr_elmirascript_in.local_cum_decorr,[1,1,1],'post');

decorr_elmirascript_in.combined_cum_decorr(isnan(decorr_elmirascript_in.combined_cum_decorr))=realmin('double');
decorr_elmirascript_in.combined_cumdecorr_motcorr(isnan(decorr_elmirascript_in.combined_cumdecorr_motcorr))=realmin('double');
decorr_elmirascript_in.local_cum_decorr(isnan(decorr_elmirascript_in.local_cum_decorr))=realmin('double');

decorr_elmirascript_mod.combined_cum_decorr=padarray(decorr_elmirascript_mod.combined_cum_decorr,[1,1,1],'post');
decorr_elmirascript_mod.combined_cumdecorr_motcorr=padarray(decorr_elmirascript_mod.combined_cumdecorr_motcorr,[1,1,1],'post');
decorr_elmirascript_mod.local_cum_decorr=padarray(decorr_elmirascript_mod.local_cum_decorr,[1,1,1],'post');

decorr_elmirascript_mod.combined_cum_decorr(isnan(decorr_elmirascript_mod.combined_cum_decorr))=realmin('double');
decorr_elmirascript_mod.combined_cumdecorr_motcorr(isnan(decorr_elmirascript_mod.combined_cumdecorr_motcorr))=realmin('double');
decorr_elmirascript_mod.local_cum_decorr(isnan(decorr_elmirascript_mod.local_cum_decorr))=realmin('double');
%%
%combined_cumdecorr_motcorr=padarray(combined_cumdecorr_motcorr,[1,1,1],'post');
%combined_cumdecorr_motcorr(isnan(combined_cumdecorr_motcorr))=realmin('double');
decorr_elmirascript=struct('cumDecorr_nomotcor',decorr_elmirascript_in.combined_cum_decorr(:,:,:,end),...
                      'cumDecorr_motcor',decorr_elmirascript_in.combined_cumdecorr_motcorr, ...
                      'cumShamDecorr',decorr_elmirascript_in.local_cum_decorr(:,:,:,numSham));
decorr_elmirascript_no1=struct('cumDecorr_nomotcor',decorr_elmirascript_mod.combined_cum_decorr(:,:,:,end),...
                      'cumDecorr_motcor',decorr_elmirascript_mod.combined_cumdecorr_motcorr, ...
                      'cumShamDecorr',decorr_elmirascript_mod.local_cum_decorr(:,:,:,numSham));
decorr_GUI_recomp_nomc=load('FullExp_03-Apr-2023_2_recomp_nomotcorr.mat');
decorr_GUI_recomp_mc=load('FullExp_03-Apr-2023_2_recomp_motcorr.mat');
decorr_GUI_recomp=struct('cumDecorr_nomotcor',decorr_GUI_recomp_nomc.outDat.cumDecorr,...
                         'cumDecorr_motcor',decorr_GUI_recomp_mc.outDat.cumDecorr, ...
                         'cumShamDecorr',decorr_GUI_recomp_mc.outDat.cumShamDecorr);
%% Compute using class functions 
%% with motion correction
experiment = EchoDecorrPkg.ExperimentClass(); 
experiment.initDataFolder('/Users/petergrimm/Downloads/2023-4-3_experiment_8');
sigma = 3; cartScalingFactor = 1;
% Info gathered from scanner
infoOut = experiment.getInitInfo();
    frameRate = infoOut(1);
    elevationRange = infoOut(3);
    azimuthRange = infoOut(4);
elevMax = deg2rad(elevationRange/2); elevMin = -elevMax;
azimMax = deg2rad(azimuthRange/2); azimMin = -azimMax;
experiment.setImagingParams(azimMin,azimMax,elevMin,elevMax,cartScalingFactor,frameRate,sigma)
% get init dataset
experiment.getInitDataSet_c();
% set remaining parameters
elevLoc = 0; azimLoc = 0; depthLoc = 30; 
elevR = 10; azimR = 10; depthR = 10; 
betaAng = 0; alphaAng = 0; gammaAng = 0; 
elevR_in = 0; azimR_in = 0; depthR_in = 0; 
experiment.setIBSparam(-1000, 1000, -1000,1000,-1000,1000)
experiment.setROIParams(elevLoc,azimLoc,depthLoc,elevR,azimR,depthR,elevR_in,azimR_in,depthR_in,alphaAng,gammaAng,betaAng);
for i = 1:numSham
    if ~isempty(experiment.getWaitingDataSets)
        experiment.nextShamDataSet
    end
end
%experiment.initMotionCorrection(3)
while experiment.newDataSetReady()
    experiment.nextDataSet()
end
decorr_motcorrect_extclass=struct('cumDecorr',experiment.cumulativeDecorr,'cumShamDecorr',experiment.cumulativeShamDecorr);
% Without motion correction
%%
experiment_nomot = EchoDecorrPkg.ExperimentClass(); 
experiment_nomot.initDataFolder('/Users/petergrimm/Downloads/2023-4-3_experiment_2');
infoOut = experiment_nomot.getInitInfo();
experiment_nomot.setImagingParams(azimMin,azimMax,elevMin,elevMax,cartScalingFactor,frameRate,sigma);
experiment_nomot.getInitDataSet_c();
experiment_nomot.setIBSparam(-1000, 1000, -1000,1000,-1000,1000)
experiment_nomot.setROIParams(elevLoc,azimLoc,depthLoc,elevR,azimR,depthR,elevR_in,azimR_in,depthR_in,alphaAng,gammaAng,betaAng);
while experiment_nomot.newDataSetReady()
    experiment_nomot.nextDataSet()
end
decorr_nomotcorrect_extclass=struct('cumDecorr',experiment_nomot.cumulativeDecorr,'cumShamDecorr',experiment_nomot.cumulativeDecorr);
decorr_extclass=struct('cumDecorr_nomotcor',decorr_nomotcorrect_extclass.cumDecorr,...
                       'cumDecorr_motcor',decorr_motcorrect_extclass.cumDecorr, ...
                       'cumShamDecorr',decorr_motcorrect_extclass.cumShamDecorr);
%% Compute decorrelation values
tau=experiment.interFrameTime*1000;
instDecLocal=map(@(x) x.getFormattedDec(struct('local',true,'global',false)), ...
                        experiment.ultrasoundDataSeries);
instDecGlobal=map(@(x) x.getFormattedDec(struct('local',true,'global',true))/x.tau, ...
                        experiment.ultrasoundDataSeries);
cumDecSham=mapreduce(@(x,y) max(x,y), instDecLocal(1:numSham))/tau;
motionCorrDecorr=map(@(x) x.getMotionCorrectedDecorr(cumDecSham)/x.tau, ...
                          experiment.ultrasoundDataSeries);

cumMoCorDec=mapreduce(@(x,y) max(x,y), motionCorrDecorr(numSham:end));
cumNoMotDec=mapreduce(@(x,y) max(x,y), instDecGlobal(numSham:end));
cumNoMotDec=circshift(cumNoMotDec,[0,0,0,0]);
cumMoCorDec=circshift(cumMoCorDec,[0,0,0,0]);
%cumNoMotDec=flip(cumNoMotDec,2);
%cumNoMotDec=flip(cumNoMotDec,3);
%cumMoCorDec=flip(cumMoCorDec,2);
%cumMoCorDec=flip(cumMoCorDec,3);
decorr_nomotcorrect_otherscript=struct('cumDecorr',cumNoMotDec,'cumShamDecorr',cumDecSham);
decorr_motcorrect_otherscript=struct('cumDecorr',cumMoCorDec,'cumShamDecorr',cumDecSham);
decorr_peterscript=struct('cumDecorr_nomotcor',decorr_nomotcorrect_otherscript.cumDecorr,...
                          'cumDecorr_motcor',decorr_motcorrect_otherscript.cumDecorr, ...
                          'cumShamDecorr',cumDecSham);
%% plot
nRow=4;
fig=figure(1); ax=subplot(nRow,3,1);
outCells={decorr_GUI_recomp, ...
            decorr_extclass, ...
            decorr_elmirascript, ...
            decorr_peterscript};
nameOut={"GUI recomputed", ...
        "Class methods, outside GUI", ...
        "Elmira script", ...
        "New script"};

show_row_h(outCells,nameOut,experiment.ROIMap, 1)
%%
function show_row_h(outCells, nameCells,ROIMap,figNum)
    assert(length(nameCells)==length(outCells));
    figure(figNum);
    clf;
    nRow = length(nameCells);
    nCol=3;    
    for ind = 1:length(outCells)
        shamROIAvg= mean(outCells{ind}.cumShamDecorr(ROIMap));
        cumDecROIAvg= mean(outCells{ind}.cumDecorr_nomotcor(ROIMap));
        cumDecMotCorROIAvg= mean(outCells{ind}.cumDecorr_motcor(ROIMap));
        test=zeros(size(outCells{ind}.cumShamDecorr));
        test(ROIMap)=1;
        subplot(nRow,nCol,(nCol*(ind-1))+1),imagesc(log10(outCells{ind}.cumShamDecorr(:,:,floor(end/2))),[-4.5,-1]);axis image;axis tight;colormap("hot"); title({'Sham dec, ',nameCells{ind},strcat('Avg in ROI:',num2str(log10(shamROIAvg)))});
        subplot(nRow,nCol,(nCol*(ind-1))+2),imagesc(log10(outCells{ind}.cumDecorr_nomotcor(:,:,floor(end/2))),[-4.5,-1]);axis image;axis tight;colormap("hot"); title({'Cumu dec w/o mot corr, ',nameCells{ind},strcat('Avg in ROI:',num2str(log10(cumDecROIAvg)))});
        subplot(nRow,nCol,(nCol*(ind-1))+3),imagesc(log10(outCells{ind}.cumDecorr_motcor(:,:,floor(end/2))),[-4.5,-1]);axis image;axis tight;colormap("hot"); title({'Cumu dec w/mot corr, ',nameCells{ind}},strcat('Avg in ROI:',num2str(log10(cumDecMotCorROIAvg))));
        %subplot(nRow,nCol,(nCol*(ind-1))+3),imagesc(test(:,:,floor(end/2)));axis image;axis tight;colormap("hot"); title({'Cumu dec w/mot corr, ',nameCells{ind}},strcat('Avg in ROI:',num2str(log10(cumDecMotCorROIAvg))));
    end
end