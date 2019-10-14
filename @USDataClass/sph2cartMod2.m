function [res] = sph2cartMod2(az,el,r)
disp('sph2cartMod2 is applying')
alpha = atan(tan(el).*cos(az));
rcosalpha = r.*cos(alpha);
res.z      = rcosalpha.*cos(az);
res.y      = rcosalpha.*sin(az);
res.x      = r.*sin(alpha);
end
