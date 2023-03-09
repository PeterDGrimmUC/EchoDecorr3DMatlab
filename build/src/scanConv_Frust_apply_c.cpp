#include "mex.h"
#include <math.h>
void generateData(const mxArray * pData, const mxArray * inputData, const mxArray * mapIn,
                  const mxArray * iRIn, const mxArray * inuIn, const mxArray * imuIn, int pSize,
                  int xSize, int ySize, int zSize, const mxArray * sphSize, mxArray * out){
  // MXArray pointers
  const double * inDataReal, * inDataImag, * iR, * inu, * imu;
  double * outDataReal, * outDataImag;
  double * mapArr;
  double * p;
  double * dimPtr;
  int rSize,thetaSize,phiSize;
  int q;
  int mapInd[8] = {0,0,0,0,0,0,0,0}; //index into map matrix
  double ptVal[8] = {0,0,0,0,0,0,0,0}; // corresponding value in map matrix
  int p1,p2,p3,p4,p5,p6,p7,p8; // data index, corresponds to mapInd values
  // get ptrs to matlab mem
  mapArr = mxGetPr(mapIn);
  outDataReal = mxGetPr(out);
  outDataImag = mxGetPi(out);
  inDataReal = mxGetPr(inputData);
  inDataImag = mxGetPi(inputData);
  imu = mxGetPr(imuIn);
  inu = mxGetPr(inuIn);
  iR = mxGetPr(iRIn);
  p = mxGetPr(pData);
  dimPtr = mxGetPr(sphSize);
  rSize = dimPtr[0];
  thetaSize = dimPtr[1];
  phiSize = dimPtr[2];
  double wtCoef = thetaSize*rSize;
  //loop through points
  for(int ip = 0; ip < pSize; ip++){
    // get current point
    q = (int)p[ip];
    // index into 1D array as 3D array
    // combined to save operations
    //p1 = iR[q-1] + thetaSize * (imu[q-1] + phiSize * inu[q-1]);
    p1 = iR[q-1]-1 + (imu[q-1]-1)*rSize + (inu[q-1]-1)*wtCoef;
    p2 = p1 + 1;
    p3 = p1 + rSize;
    p4 = p1 + wtCoef;
    p5 = p4 + 1;
    p6 = p4 + rSize;
    p7 = p3 + 1;
    p8 = p4 + 1;
    //get index into point*8 map matrix
    mapInd[0] = ip*8;
    ptVal[0] = mapArr[mapInd[0]];
    for(int j = 1; j < 8; j++){
      mapInd[j] = mapInd[j-1] + 1;
      ptVal[j] = mapArr[mapInd[j]];
    }
    outDataReal[q-1] = p7;
    outDataImag[q-1] = p8;
    outDataReal[q-1] = inDataReal[p1] * ptVal[0] + inDataReal[p2] * ptVal[1] +
      inDataReal[p3] * ptVal[2] + inDataReal[p4] * ptVal[3] +
      inDataReal[p5] * ptVal[4] + inDataReal[p6] * ptVal[5] +
      inDataReal[p7] * ptVal[6] + inDataReal[p8] * ptVal[7];
    outDataImag[q-1] = inDataImag[p1] * ptVal[0] + inDataImag[p2] * ptVal[1] +
      inDataImag[p3] * ptVal[2] + inDataImag[p4] * ptVal[3] +
      inDataImag[p5] * ptVal[4] + inDataImag[p6] * ptVal[5] +
      inDataImag[p7] * ptVal[6] + inDataImag[p8] * ptVal[7];
  }
}
/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* variable declarations here */
  if(nrhs != 11) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                      "One input required.");
  }
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                      "One output required.");
  }

  long int pSize = (int)mxGetScalar(prhs[6]);
  long int xSize = (int)mxGetScalar(prhs[7]);
  long int ySize = (int)mxGetScalar(prhs[8]);
  long int zSize = (int)mxGetScalar(prhs[9]);
  plhs[0] = mxCreateDoubleMatrix(1,xSize*ySize*zSize,mxCOMPLEX);
  generateData(prhs[0],prhs[1],prhs[2], prhs[3],prhs[4],prhs[5], pSize, xSize, ySize, zSize,prhs[10], plhs[0]);
  return;
}
