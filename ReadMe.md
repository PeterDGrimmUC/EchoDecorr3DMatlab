# Scripts for ultrasound echo decorrelation imaging
## Temporary branch for motion correction fixes and api overhaul
### Important: You must install a C++ compiler and run MexBuild.m before using the package
The script MexBuild compiles all mex functions and places the binaries in the 'Util' subpackage.

It should be platform independent, if necessary compiler flags can be altered by changing the string compilationFlags in MexBuild.m.

see [this matlab article for supported compilers](https://www.mathworks.com/support/requirements/supported-compilers.html).

## Installation instructions
1. Clone the repository with git 

      git clone --recurse-submodules --branch MotionCorrectionFixes https://github.com/PeterDGrimmUC/EchoDecorr3DMatlab.git

2. Run the script MexBuild.m (ensure you have a compiler installed beforehand)
3. Ensure that the folder containing +EchoDecorrPkg is in your MATLAB path (do not add the folder itself to the path, just the folder containing it, otherwise there might be some namespace conflicts)

## Usage
1. The GUI's for 2D and 3D echo decorrelation are in the GUI folder, when they are executed the correct paths will be set up
2. Example scripts can be found in the ExampleScripts directory, these include most of the relevant calls 
