%%%% Wrapper function to read IQ Data %%%%%%%%%%%%%%%
%% Vasant A. Salgaonkar, Siemens ADCV, 10/12/2018 %%
%% Created for Dr. T. D. Mast at University of Cincinnati  %%
%% Created for non-diagnostic, non-clinical, non-human, investigational
%clear all
clc

%%% Replace paths with appropriate locations
% addpath('D:\Code\MATLAB');
% dirName = 'D:\Code\MATLAB\-09-2018-01-40 PM';
% cd(dirName)
% fileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
[fileName dirName]= uigetfile('*.pmcr');
tic
Dm = read_lbdump([dirName '/' fileName]);% Dm.data has IQ data
toc