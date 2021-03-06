function scanConv_Frust_decode( qOut,p,sz )
% This script reads IQ data in the first section (SIEMENS Scripts), then
% does the 3D interpolation on spherical IQ data with function named
% "frustumInterp". In the last section the spherical and
% interpolated data in cartesian system are displayed.

% Writers: Elmira Ghahramani Z., Dr. Douglas Mast
% Image-guided Ultrasound Therapeutics Laboratories
% University of Cincinnati
% Contacts: ghahraea@mail.uc.edu
%           masttd@UCMAIL.UC.EDU
% Date last updated: 02/19/2019

%% Read IQ data

for volIndex = 1:size(obj.rawData,4)
  Icart = zeros(sz);
    for ip = 1:length(p)
        q = p(ip);
        
        % differences to be used below, trying to save a few flops
        
        Icart(q) = Isph(iR(q),imu(q),inu(q)) ...
            * qOut(q,1) + ...
            Isph(iR(q)+1,imu(q),inu(q)) ...
            * qOut(q,2) + ...
            Isph(iR(q),imu(q)+1,inu(q)) ...
            * qOut(q,3) + ...
            Isph(iR(q),imu(q),inu(q)+1) ...
            * qOut(q,4) + ...
            Isph(iR(q)+1,imu(q),inu(q)+1) ...
            * qOut(q,5) + ...
            Isph(iR(q),imu(q)+1,inu(q)+1) ...
            * qOut(q,6) + ...
            Isph(iR(q)+1,imu(q)+1,inu(q)) ...
            * qOut(q,7) + ...
            Isph(iR(q)+1,imu(q)+1,inu(q)) ...
            * qOut(q,8);
    end
    obj.rawData_cart(:,:,:,volIndex) = Icart/(obj.dr*dmu*dnu);
end
end

