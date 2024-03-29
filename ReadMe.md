# Scripts for ultrasound echo decorrelation imaging
### Important: You must install a C++ compiler and run MexBuild.m before using the package
The script MexBuild compiles all mex functions and places the binaries in the 'Util' subpackage.

It should be platform independent, if necessary compiler flags can be altered by changing the string compilationFlags in MexBuild.m.

see [this matlab article for supported compilers](https://www.mathworks.com/support/requirements/supported-compilers.html).

## Installation instructions
1. Clone the repository with git 

      git clone --recurse-submodules https://github.com/PeterDGrimmUC/EchoDecorr3DMatlab.git

2. Run the script MexBuild.m (ensure you have a compiler installed beforehand)
3. Ensure that the folder containing +EchoDecorrPkg is in your MATLAB path (do not add the folder itself to the path, just the folder containing it, otherwise there might be [namespace conflicts](https://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html))

## Usage
1. The GUIs for 2D and 3D echo decorrelation are in the GUI folder, when they are executed the correct paths will be set up.
2. Example scripts can be found in the ExampleScripts directory, these include most of the relevant calls.

### Logging and debugging
The logger submodule outputs information at different levels of severity, selecting a level from the dropdown will show all logged items of the same or less severity. 
#### Log levels
Roughly speaking, the following list shows the type of info at each logging level (in order of increasing severity):

1. TRACE: Logs events for nearly all callbacks
2. DETAIL: More verbose logging of other events
3. DEBUG: UI state changes
4. MESSAGE: Object state changes, expected changes to mutable types
5. INFO: Important events, like starting the ablation, recording a volume and setting up the serial connections
6. WARNING: Error handling for events which do not effect the core functionality of the scripts. Things like not being able to display certain information.
7. ERROR: Error handling for events which will likely affect program behavior
8. CRITICAL: Errors that will result in components not working correctly
9. FATAL: Errors that will require you to restart the GUI. It will throw to the main MATLAB error handler and dump the log contents
