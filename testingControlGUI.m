set(0,'DefaultAxesFontSize', 15)
set(0,'DefaultAxesLabelFontSize', 15)

file_name         = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
intervalTime      = 22;
rmin              = 0;
azangle           = 90;
elangle           = 90;
azimuth_angle     = 2*pi*azangle/360;
elevation_angle   = 2*pi*elangle/360;
thetamin          = -azimuth_angle/2;
thetamax          = azimuth_angle/2;
phimin            = -elevation_angle/2;
phimax            = elevation_angle/2;
frame_rate        = 20;
interframe_time   = 1/frame_rate;
sigma             = 3;
max_decorr        = .1;
max_IBS           = .1;
dyn_range         = 3;
max_Bmode         = 0.02;
db_range          = 70;
rho_scale_fact    = 2;

input_path = '/Users/petergrimm/Downloads/';
input_path2 = '2023-4-3_experiment_8';
output_path = input_path;
output_path2 = '_testing_control_GUI_IQcart_decorr_IBS_xyz_notflipped.mat';
video_figure_output_path = output_path;

%%
clear usData

full_dir = [input_path,input_path2];

if ispc
    data_dir    = dir([full_dir,'\IQDATA*']);
    full_path =strcat(full_dir,'\',{data_dir(1).name},'\',file_name);
elseif ismac
    data_dir    = dir([full_dir,'/IQDATA*']);
    full_path =strcat(full_dir,'/',{data_dir(1).name},'/',file_name);
end
%%

rawData_cart = [];

IBS = [];
cum_IBS = [];

local_decorr = [];
local_cum_decorr = [];

global_decorr = [];
global_cum_decorr = [];

combined_decorr = [];
combined_cum_decorr = [];

B=[];

BASE.base = true;
BASE.interDataSetTime = intervalTime;
DmBase = EchoDecorrPkg.Utils.read_lbdump(full_path{1})
%which EchoDecorrPkg.Utils.read_lbdump
rmax = (DmBase.H.rsz-1)*DmBase.H.dr;
preablation_frames = 3;
n_range = length(data_dir);

for n = 1:n_range
    disp(['IQ data file: ', num2str(n)]);
    
    if ispc
        full_path =strcat(full_dir,'\',{data_dir(n).name},'\',file_name);
    elseif ismac
        full_path =strcat(full_dir,'/',{data_dir(n).name},'/',file_name);
    end
    
    Dm = EchoDecorrPkg.Utils.read_lbdump(full_path{1});
    
    usData(n) = USDataClass2(Dm.data,Dm.Info,rmax,rmin,thetamin,thetamax,...
        phimin,phimax,sigma,interframe_time);
    
    usData(n).scanConv_Frust();
    usData(n).compute3DDecorrTemp();
    
    if n == 1
        IBS_firstframe = sqrt(usData(n).beta2_inEcho);
    end
    B(:,:,:,n) = usData(n).B;
    rawData_cart(:,:,:,:,n) = usData(n).rawData_cart;
    local_decorr(:,:,:,n) = usData(n).decorr_local;
    global_decorr(:,:,:,n) = usData(n).decorr_global;
    combined_decorr(:,:,:,n) = usData(n).decorr_combined;
end

outside_echo_ind_1frame = find(squeeze(rawData_cart(:,:,:,2,1))==0);
outside_echo_ind_allframes = find(squeeze(rawData_cart(:,:,:,2,:))==0);

% Cumulative decorrelation and cumulative IBS
for i = 1:n_range
    local_cum_decorr(:,:,:,i) = squeeze(max(local_decorr(:,:,:,1:i),[],4));
    global_cum_decorr(:,:,:,i) = squeeze(max(global_decorr(:,:,:,1:i),[],4));
    combined_cum_decorr(:,:,:,i) = squeeze(max(combined_decorr(:,:,:,1:i),[],4));
end

local_cum_decorr(outside_echo_ind_allframes) = NaN;
local_cum_decorr(local_cum_decorr < 0) = 0;

global_cum_decorr(outside_echo_ind_allframes) = NaN;
global_cum_decorr(global_cum_decorr < 0) = 0;

combined_cum_decorr(outside_echo_ind_allframes) = NaN;
combined_cum_decorr(combined_cum_decorr < 0) = 0;

% Motion correction
cumdec_preabl = max(local_decorr(:,:,:,1:preablation_frames),[],4);
local_decorr_motcorr = local_decorr - cumdec_preabl;
local_decorr_motcorr(local_decorr_motcorr<0) = 0;
combined_decorr_motcorr = local_decorr_motcorr ./ B;
combined_decorr_motcorr(combined_decorr_motcorr<0) = 0;
combined_cumdecorr_motcorr = max(combined_decorr_motcorr,[],4);

% Axes and other geometric parameters
x_range = usData(1).x_range;
y_range = usData(1).y_range;
z_range = usData(1).z_range;

disp('Saving data ...');
save(strcat(output_path,'20230403_trial2_testing_control_GUI', output_path2),...
    'rawData_cart', 'combined_cumdecorr_motcorr', ...
    'local_decorr', 'local_cum_decorr', ...
    'global_decorr', 'global_cum_decorr', ...
    'combined_decorr', 'combined_cum_decorr', ...
    'x_range','y_range','z_range','-v7.3')
disp('Data is saved.');
%%
roi=outDat.ROIMap;
decroi=roi.* outDat.decorr;
log10(sum(decroi(:))/sum(roi(:)))

roimine = b(1:75,1:106,1:106);
decroimine=roimine .* flip(combined_cumdecorr_motcorr,2);
decroimine(isnan(decroimine))=0;
log10(sum(decroimine(:))/sum(roimine(:)))
