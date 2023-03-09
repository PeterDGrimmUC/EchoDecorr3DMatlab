%% builds mex functions for echo decorr package
% because matlab doesn't support makefiles
compilationFlags=""; % change if needed
% Create build dir
fprintf('Starting mex build...\n');
buildSrcDir=fullfile('build','src');
buildBinDir=fullfile('build','bin');
mkdir(buildSrcDir);
mkdir(buildBinDir);
fprintf('Copying source...\n');
sourceLoc=fullfile('+EchoDecorrPkg','MEX','src');
copyfile(fullfile(sourceLoc,'*'), buildSrcDir);
%%
sourceTargets = ["scanConv_Frust_c.cpp","scanConv_Frust_apply_c.cpp" ...
                 "read_lbdump_c.cpp", "hex2dec_SWFC.cpp"];
for currTarg = sourceTargets
    fprintf('Compiling %s \n',currTarg);
    currSrc = fullfile('build','src',currTarg);
    buildStr=sprintf('mex %s %s -outdir %s',compilationFlags,currSrc,buildBinDir);
    eval(buildStr);
end
%%
pkgBin=fullfile('+EchoDecorrelation','+Utils','+bin');
copyfile(fullfile(buildBinDir,'*'), pkgBin);