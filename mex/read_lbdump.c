#include "mex.h"
#include "matrix.h"
#include "SC2000_parse.h"

void exportToMex(ScannerData * data, mxArray *outputArray)
{
    mxComplexDouble * mxData = mxGetComplexDoubles(outputArray);
    // Copy the data from the input C arrays to the mxArray
    for (mwSize i = 0; i < data->metadata.numElements; i++)
    {
        mxData[i].imag = data->datImag[i];
        mxData[i].real = data->datReal[i];
    }
    free(data->datImag);
    free(data->datReal);
}
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    const char * fileName=mxArrayToString(prhs[0]);

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
    printf("%s\n", fileName);
    ScannerData data;
    ScannerMetadata metadata;
    int res = getMetadataFromScannerFolder(&metadata, fileName, IQ3D);
    printf("res: %i\n",res);
    //printf("Numelems: "metadata);
    //int succ = parseFolder(&data, fileName, IQ3D);
    //if(succ > 0){
    //    mxArray * complexArray = mxCreateNumericMatrix(1, data.metadata.numElements, mxDOUBLE_CLASS, mxCOMPLEX);
    //    exportToMex(&data,complexArray);
    //    plhs[0] = complexArray;
    //}
    //mxFree(fileName);
}
