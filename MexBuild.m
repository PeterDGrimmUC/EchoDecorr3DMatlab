%% builds mex functions for echo decorr package
% because matlab doesn't support makefiles
CC=mex.getCompilerConfigurations('C','Selected');
CXX=mex.getCompilerConfigurations('C++','Selected');
compilationFlags='';
if strcmp(CC.ShortName,'Clang') || strcmp(CC.ShortName,'cc')
    compilationFlags=strcat(compilationFlags,' COPTIMFLAGS="-O3"');
elseif strfind(CC.ShortName,'msvc')

end
if strcmp(CXX.ShortName,'Clang++') || strcmp(CXX.ShortName,'g++')
    compilationFlags=strcat(compilationFlags,' CXXOPTIMFLAGS="-O3"');
elseif strfind(CXX.ShortName,'msvc')

end
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
    fprintf('build str:\n\t %s', buildStr);
    eval(buildStr);
end
%%
pkgBin=fullfile('+EchoDecorrPkg','+Utils','+bin');
copyfile(fullfile(buildBinDir,'*'), pkgBin);