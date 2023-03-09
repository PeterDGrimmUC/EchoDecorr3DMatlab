#include "mex.h"
#include <math.h>
void generatePyramidalCoordinates(double thetaMax, double phiMax,
                                  double phiSize, double thetaSize,
                                  double xSize, double ySize,
                                  double zSize, int * inputArray ){
    double muMax = sin(thetaMax);
    double muMin = -muMax;
    double nuMax = sin(phiMax);
    double nuMin = -muMax;
    double dnu = (abs(nuMin)+abs(nuMax))/(phiSize-1);
    double dmu = (abs(muMin)+abs(muMax))/(thetaSize-1);
    double Lmu,Lnu,LR,drmLR,dmumLmu,dnumLnu;
    int imu,inu,iR;
    int linearPoint;
    arrayWrap coeffArray;
    //need iR,imu,inu
    double k,R0,mu0,nu0,testVal;
    for(int curr_x = 0; curr_x < xSize; curr_x++){
        for(int curr_y = 0; curr_y < ySize; curr_y++){
            for(int curr_z = 0; curr_z < zSize; curr_z++){
                k = pow(yMat[curr_x][curr_y][curr_z],2)+pow(zMat[curr_x][curr_y][curr_z],2);
                R0 = sqrt(k+pow(xMat[curr_x][curr_y][curr_z],2));
                mu0 = yMat[curr_x][curr_y][curr_z]/sqrt(k);
                nu0 = xMat[curr_x][curr_y][curr_z]/sqrt(pow(R0,2)-pow(yMat[curr_x][curr_y][curr_z],2));
                linearPoint = curr_x + ySize * (curr_y + zSize * curr_z);
                if((R0 >= rMin) && (R0 <= (rMax-dr)) && (mu0 >= muMin) && (mu0 <= (muMax-dmu)) && (nu0 >= nuMin) && (nu0 <= (nuMax-dmu))){
                    imu = (int) floor((mu0 - muMin)/dmu);
                    testVal = ((imu*dmu)+muMin) - dmu;
                    Lmu = mu0 - testVal;
                    inu = (int) floor((nu0 - nuMin)/dnu) -dnu;
                    Lnu = nu0 - ((inu*dnu)+nuMin)+muMax;
                    iR = (int) floor((R0 - rMin)/dr) ;
                    LR = R0 - iR*dr;
                    drmLR = dr-LR;
                    dmumLmu = dmu-Lmu;
                    dnumLnu = dnu-Lnu;
                    coeffArray.thisArr[0] = (float) drmLR*dmumLmu*dnumLnu;
                    coeffArray.thisArr[1] = (float) LR*dmumLmu*dnumLnu;
                    coeffArray.thisArr[2] = (float) drmLR*Lmu*dnumLnu;
                    coeffArray.thisArr[3] = (float) drmLR*dmumLmu*Lnu;
                    coeffArray.thisArr[4] = (float) LR*dmumLmu*Lnu;
                    coeffArray.thisArr[5] = (float) drmLR*Lmu*Lnu;
                    coeffArray.thisArr[6] = (float) LR*Lmu*dnumLnu;
                    coeffArray.thisArr[7] = (float) LR*Lmu*Lnu;
                    validPyramidalCoords.push_back(dataMap(curr_x,curr_y,curr_z,iR,imu,inu,coeffArray,linearPoint));
                }
                else{
                    invalidCoords.push_back(coord_3d(curr_x,curr_y,curr_z));
                }

            }
        }
    }
}
/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* variable declarations here */
  if(nrhs != 1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                      "One input required.");
  }
  if(nlhs != 1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                      "One output required.");
  }
  /* make sure the first input argument is scalar */
  if ( mxIsChar(prhs[0]) != 1)
    mexErrMsgIdAndTxt( "MATLAB:revord:inputNotString",
                       "Input must be a string.");
  char *input_buf;     /* input scalar */
  size_t buflen;
  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
  input_buf = mxArrayToString(prhs[0]);
  plhs[0] = mxCreateDoubleScalar(hex2Dec_SWFC_c(input_buf));
}
