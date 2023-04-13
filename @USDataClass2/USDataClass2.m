%% USDataClass: Data class for computation of echo decorrelation
classdef USDataClass2 < handle 
    % USDataClass: Data class for computation of echo decorrelation 
    %   each set of data has is an object of type USDataClass
    %   contains the data parameters, raw spherical data, cartesian scan converted data, ibs,
    %   and decorrelation 
    % Author: Peter Grimm 12/21/2019
    % Last update: 01/18/2023, Elmira Ghahramani Z.
    properties
        % data properties
        rawData;           % raw spherical volume data for one data set export
        rawData_cart;      % scan converted cartesian data from spherical data
        beta2mean_inEcho;
        beta2_inEcho;        
        decorr_local;
        decorr_global;
        decorr_combined;
        ibs;
        B;
        autocorr01;

        dr;
        dz;
        dx;
        dy;
        x_range;
        y_range;
        z_range;
        
        % parameters
        %The following would ideally be part of InfoFile in the future
        InfoFile;          % Info file provided by siemens SC2000 scanner
        rmax,rmin,thetamax,thetamin,phimax,phimin; % bounds in cm of the spherical data 
        windowSigma;       % sigma of gaussian smoothing kernel
        interFrameTime;    % time between volume recordings (cm/pixel)
         
    end
    
    methods
        %% Constructor method
        function obj = USDataClass2(thisRawData,thisInfoFile,thisrmax,thisrmin,thisthetamin,thisthetamax,thisphimin,thisphimax,thiswindowSigma,thisinterFrameTime)
            
            if nargin == 10
                obj.rawData = thisRawData;
                obj.InfoFile = thisInfoFile;
                obj.rmax = thisrmax;
                obj.rmin = thisrmin;
                obj.thetamax = thisthetamax;
                obj.thetamin = thisthetamin;
                obj.phimax = thisphimax;
                obj.phimin = thisphimin;
                obj.windowSigma = thiswindowSigma;
                obj.interFrameTime = thisinterFrameTime;
            end
        end      
    end    
end

