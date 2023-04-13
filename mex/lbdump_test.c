#include "mex.h"
#include "matrix.h"
#include "ScannerMetadata.h"
#include "ScannerData.h"
#include "helpers.h"


void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{

    /* Check for proper number of input and output arguments */
    if (nrhs != 1) {
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs",
                "One input argument required.");
    }
    if(nlhs > 1){
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:maxrhs",
                "Too many output arguments.");
    }
    if (!(mxIsChar(prhs[0]))){
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidInput",
                "Input must be of type string.\n.");
    }
    const char * fileName=mxArrayToString(prhs[0]);
    ScannerData data = initScannerData(fileName, IQ3D);
    if(readScannerData(&data, IQ3D)>0){
        plhs[0] = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxCOMPLEX);
        mxSetComplexDoubles(plhs[0], data.data);
        mxSetM(plhs[0], 1);
        mxSetN(plhs[0], data.metadata.numElements);
    }
    mxFree(fileName);
    return;
}
