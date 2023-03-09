#include "mex.h"
#include <math.h>
void generatePyramidalCoordinates(const mxArray * p,const mxArray * Lmu, const mxArray * Lnu, const mxArray * LR, double dmu, double dnu, double dr, long int pSize, mxArray * out){
  const double * pArr, * LmuArr, * LnuArr, * LRArr;
  double * outArr;
  pArr = mxGetPr(p);
  LmuArr = mxGetPr(Lmu);
  LnuArr = mxGetPr(Lnu);
  LRArr = mxGetPr(LR);
  outArr = mxGetPr(out);
  int q = 0;
  double dmumLmu = 0;
  double dnumLnu = 0;
  double drmLR = 0;
  for(int ip = 0; ip < pSize; ip++){
    q = pArr[ip];
    drmLR = dr - LRArr[q-1];
    dmumLmu = dmu - LmuArr[q-1];
    dnumLnu = dnu - LnuArr[q-1];
    outArr[ip*8] = drmLR * dmumLmu * dnumLnu;
   // outArr[ip*8] = 8*q;
    //outArr[8*q] = drmLR * dmumLmu * dnumLnu; 
    //outArr[ip*8] = drmLR;
    //outArr[ip*8 + 1] = q;
    outArr[ip*8 + 1] = LRArr[q-1] * dmumLmu * dnumLnu;
    outArr[ip*8 + 2] = drmLR * LmuArr[q-1] * dnumLnu;
    outArr[ip*8 + 3] = drmLR * dmumLmu * LnuArr[q-1];
    outArr[ip*8 + 4] = LRArr[q-1] * dmumLmu * LnuArr[q-1];
    outArr[ip*8 + 5] = drmLR * LmuArr[q-1] * LnuArr[q-1];
    outArr[ip*8 + 6] = LRArr[q-1] * LmuArr[q-1] * dnumLnu;
    outArr[ip*8 + 7] = LRArr[q-1] * LmuArr[q-1] * LnuArr[q-1];
  }
}
/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* variable declarations here */
  if(nrhs != 8) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                      "One input required.");
  }
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                      "One output required.");
  }
  //mxArray * p,mxArray * Lmu, mxArray * Lnu, mxArray * LR, double dmu, double dnu, double dr, double pSize,
  double dmu = mxGetScalar(prhs[4]);
  double dnu = mxGetScalar(prhs[5]);
  double dr = mxGetScalar(prhs[6]);
  long int pSize = (int)mxGetScalar(prhs[7]);
  plhs[0] = mxCreateDoubleMatrix(1,pSize * 8,mxREAL);
  generatePyramidalCoordinates(prhs[0],prhs[1],prhs[2], prhs[3], dmu, dnu, dr, pSize, plhs[0]);
  return;
}
