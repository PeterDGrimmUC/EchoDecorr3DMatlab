#include "mex.h"
#include <string>
#include <math.h>
float hex2Dec_SWFC_c(std::string hexString){
   /* HEX2Dec_SWFC
        Convert hex string to decimal using SWFC convention with swfc = [1 0 17 1]
        this means the number is signed, and that all of the information bits come after the decimal place (e.g output = 0.b1b2b3...bn where n = 17)
   */
    //unsigned int twoCompMask = 131071; // When XOR'd with 17 bit data bit input (inside 32 bit unsigned int) flips bit for two's compliment
    unsigned int signedFloatMask = 0b11000010000000000000000000000000; //0xC2800000;//0xBE000000;// Signed float mask: When XOR'd with the input 32 bit unsigned twos compliment int forms a float with exponent -1 and a 1 sign bit, also reverses shifted sign bit eg in decimal[1][126-8][bits][padded to end]
    unsigned int unsignedFloatMask = 1056964608; // Unsigned float mask: When XOR'd with the input forms a float with exponent -1 and a 1 sign bit, also reverses shifted sign bit eg in decimal[1][126-8][bits][padded to end]
    float floatCorrection = .5; // Mantissa is of the form 1.b1b2b3... so when exponent = -1 there is an additional 2^-1 (.5) term in the float, which must be subtracted/added depending on sign
    //get input int
    unsigned int num = std::stoi(hexString, nullptr,16); //convert hex string to int
    // Bitwise manipulation
    if (num >> 17){ // check if signed bit is 1
        num = (((~num)+1) << 7) ^ 0b00111100100000000000000000000000;
        //num = num | signedFloatMask; // shift information bits to proper spot for exponent -1 (num <<7), then xor with the signedFloatMask
        return ((*(float*)(&num)) + 64)/128; //+ floatCorrection; // dereference num, cast what the address points to as a float and add correction
        //return (float)(num);
    }
    else{
        num = (num<<7)^unsignedFloatMask; // same as above, but don't take two's compliment
        return *(float*)(&num) - floatCorrection; // .5 is here because mantissa in a float is of the form 1.b1b2b3..., with an exponent of -1, .5 must is left over
    }
}
void read_file(const mxArray * inArray, mxArray * outArray, size_t n, unsigned long int maxNum){
    int maxDigits = (int) ceil(log((long double) maxNum)/log(16));
    unsigned long int maxInDig;
    int intRealStart = 213;//189;//213; //237 next
    int intImagStart = 222;//198;//222; //246
    char * charArr;
    double *outReal, *outImag;
    int testArr[5] = {0,2,2,3,4};
    int testArr2[5] = {0,1,2,3,4};
    std::string subStrReal = "00000";
    std::string subStrImag = "00000";
    outReal = mxGetPr(outArray);
    outImag = mxGetPi(outArray);
    charArr = (char *) mxGetChars(inArray);

    int iOut = 0;
    for(int currDig = 0; currDig <= maxDigits-3;currDig++){
      maxInDig = powl(16,currDig+2)/2;
      intRealStart = intRealStart +testArr[currDig];
      intImagStart = intImagStart +testArr[currDig];
      for(int currVal = 0; currVal < maxInDig; currVal++){

        for(int i = 0; i < 5; i++){
          subStrReal[i] = charArr[i+intRealStart];
          subStrImag[i] = charArr[i+intImagStart];
        }
          outReal[iOut] = (double) hex2Dec_SWFC_c("00001");
          outImag[iOut] = (double) hex2Dec_SWFC_c("00001");
        intRealStart = intRealStart + 24 + testArr2[currDig];
        intImagStart = intImagStart + 24 + currDig;
        iOut = iOut + 1;

      }

    }
    for(int iIn = iOut; iIn < maxNum/2; iIn++){
      outReal[iIn] = (double) hex2Dec_SWFC_c("00001");
      outImag[iIn] = (double) hex2Dec_SWFC_c("00001");
    }
}
/* The gateway function */
void read_file_2(const mxArray * inArray, mxArray * outArray, size_t n, unsigned long int maxNum){
    int maxDigits = (int) ceil(log((long double) maxNum)/log(16));
    unsigned long int maxInDig;
    int intRealStart = 208;//189;//213; //237 next
    //int intImagStart = 222;//198;//222; //246
    char * charArr;
    double *outReal, *outImag;
    std::string subStrReal = "00000";
    std::string subStrImag = "00000";
    outReal = mxGetPr(outArray);
    outImag = mxGetPi(outArray);
    charArr = (char *) mxGetChars(inArray);

    int iOut = 0;
    long int i = intRealStart;
    while(iOut < maxNum/2){
      if(charArr[i] == 58){
        for(int k = 0; k < 5; k++){
          subStrReal[k] = charArr[k+i+5];
          subStrImag[k] = charArr[k+i+14];
        }
        outReal[iOut] = hex2Dec_SWFC_c(subStrReal);
        outImag[iOut] = hex2Dec_SWFC_c(subStrImag);
        //outImag[iOut] = subStrImag[0];
        iOut++;
      }
      i = i + 1;
    }


}
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
/* variable declarations here */
    size_t rows, cols;
    size_t n;
    unsigned long int maxNum;
    /* check for the proper number of arguments */
    if(nrhs != 2)
      mexErrMsgIdAndTxt( "MATLAB:convec:invalidNumInputs",
              "Two inputs required.");
    if(nlhs > 2)
      mexErrMsgIdAndTxt( "MATLAB:convec:maxlhs",
              "Too many output arguments.");
    /* Check that both inputs are complex*/

    /* get the length of each input vector */
    n = mxGetN(prhs[0]);
    maxNum = (unsigned long int) mxGetScalar(prhs[1]);
    plhs[0] = mxCreateDoubleMatrix(1,maxNum/2,mxCOMPLEX);
    read_file_2(prhs[0],plhs[0],n,maxNum);
    plhs[1] = mxCreateDoubleScalar((double)maxNum);
    return;
}
