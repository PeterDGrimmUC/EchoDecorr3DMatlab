#include "mex.h"
#include <string.h>
#include <math.h>
#include <stdlib.h>
#define asciiAToInt 54 // = 'A'(65)-11=54->'A'-54=11
#define ascii0ToInt 48 // = '0'(48)=48->'0'-48=0
/*inline float hex2Dec_SWFC_c(unsigned int num){
    HEX2Dec_SWFC
        Convert hex string to decimal using SWFC convention with swfc = [1 0 17 1]
        this means the number is signed, and that all of the information bits come after the decimal place (e.g output = 0.b1b2b3...bn where n = 17)
   
    //unsigned int twoCompMask = 131071; // When XOR'd with 17 bit data bit input (inside 32 bit unsigned int) flips bit for two's compliment
    const unsigned int signedFloatMask = 0b11000010000000000000000000000000; //0xC2800000;//0xBE000000;// Signed float mask: When XOR'd with the input 32 bit unsigned twos compliment int forms a float with exponent -1 and a 1 sign bit, also reverses shifted sign bit eg in decimal[1][126-8][bits][padded to end]
    const unsigned int unsignedFloatMask = 1056964608; // Unsigned float mask: When XOR'd with the input forms a float with exponent -1 and a 1 sign bit, also reverses shifted sign bit eg in decimal[1][126-8][bits][padded to end]
    const float floatCorrection = .5; // Mantissa is of the form 1.b1b2b3... so when exponent = -1 there is an additional 2^-1 (.5) term in the float, which must be subtracted/added depending on sign
    //get input int
    //unsigned int num = std::stoi(hexString, nullptr,16); //convert hex string to int
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
} */
/*inline unsigned int hexstr2int(const char * hexString, const unsigned long int startInd, const unsigned int hexStrLen){
    const int asciiaToInt=86; // = 'a'(97)-11=86->'a'-86=11
    const int asciiAToInt=54; // = 'A'(65)-11=54->'A'-54=11
    const int ascii0ToInt=48; // = '0'(48)=48->'0'-48=0
    unsigned int res=0;
    char temp;
    for(int i=0; i<hexStrLen; i++)
    {  
        if(hexString[i+startInd] <= '9')
        {
            temp=hexString[i+startInd]-ascii0ToInt;
        }
        else if(hexString[i+startInd] <= 'F')
        {
            temp=hexString[i+startInd]-asciiAToInt;
        }
    res=(res|((unsigned int)temp))<<4;  logical or between casted int (vals from 0-16(4 bits)) and shift
    }
    return res;
} */
inline char asciiToHexChar(const char charIn){
    if(charIn >= 'A')
        {
            return charIn-ascii0ToInt;
        }
        else if(charIn >= '0')
        {
            return charIn-asciiAToInt;
        }else{
            return (char) 0;
        }

}
/* The gateway function */
/*void read_file_wrap(const mxArray * inArray, mxArray * outArray, size_t n, unsigned long int maxNum){
    const unsigned int intRealStart = 208;
    const unsigned int offsetFromTargCharReal=5;
    const unsigned int offsetFromTargCharImag=14;
    const unsigned int hexStrLen=5;
    const unsigned int iJump=offsetFromTargCharImag+hexStrLen;
    const unsigned int numChars=maxNum/2;
    
    char * charArr;
    double *outReal, *outImag;
    outReal = mxGetPr(outArray);
    outImag = mxGetPi(outArray);
    charArr = (char *) mxGetChars(inArray);

    unsigned long int iOut = 0;
    unsigned long int i = intRealStart;
    while(iOut < numChars){
      if(charArr[i] == 58){
        outReal[iOut] = (double) hex2Dec_SWFC_c(hexstr2int(charArr, i+offsetFromTargCharReal,hexStrLen));
        outImag[iOut] = (double) hex2Dec_SWFC_c(hexstr2int(charArr, i+offsetFromTargCharImag,hexStrLen));
        iOut++;
        i+=iJump;
      }
      i++;
    }
}
void read_file_toarr(const mxArray * inArray, mxArray * outArray, size_t n, unsigned long int maxNum){
    const int intRealStart = 208;
    const int offsetFromTargCharReal=5;
    const int offsetFromTargCharImag=14;
    const int hexStrLen=5;
    const int iJump=offsetFromTargCharImag+hexStrLen;
    const int numChars=maxNum/2;
    
    char * charArr;
    int * outReal, *outImag;
    outReal = (int *) mxGetData(outArray);
    outImag = (int *) mxGetImagData(outArray);
    charArr = (char *) mxGetChars(inArray);

    int iOut = 0;
    long int i = intRealStart;
    while(iOut < numChars){
      if(charArr[i] == 58){
        outReal[iOut] = hexstr2int(charArr, i+offsetFromTargCharReal,hexStrLen);
        outImag[iOut] = hexstr2int(charArr, i+offsetFromTargCharImag,hexStrLen);
        iOut++;
        //i+=iJump;
      }
      i++;
    }
    //mexPrintf("%d",hexstr2int());
}
*/
inline void parse_file(const mxArray * mappedFile, int * realArr, int * imagArr, const size_t numElms){
    const int intRealStart = 208;
    const int offsetFromTargCharReal=5;
    const int offsetFromTargCharImag=14;
    const int hexStrLen=5;
    const int iJump=offsetFromTargCharImag+hexStrLen;
    //const int numChars=maxNum/2;
}
void testFnc(){
    int numTests = 4;
    unsigned int tempOut;
    char * testVals[] = {
        "0000A",
        "000A8",
        "3FFC1",
        "3FFEA"
    };
    for(int i=0; i<numTests;i++){
        //tempOut=hexstr2int();
    }
}
void testHexCharConversion(){
    char testChars[16] = {'0','1','2','3','4','5','6','7','8','9',
                        'A','B','C','D','E','F'}; 
    size_t numTest = 16; 
    unsigned int temp;
    for(int i=0; i < numTest; i++){
        temp=(unsigned int)asciiToHexChar(testChars[i]);
        mexPrintf('Input character: %c, output digit: %i', testChars[i],temp );
    }
}
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
/* variable declarations here */
    /* check for the proper number of arguments */
    if(nrhs != 2)
      mexErrMsgIdAndTxt( "MATLAB:convec:invalidNumInputs",
              "Two inputs required.");
    if(nlhs > 2)
      mexErrMsgIdAndTxt( "MATLAB:convec:maxlhs",
              "Too many output arguments.");
    /* Check that both inputs are complex*/

    /* get the length of each input vector */
    //maxNum = (unsigned long int) mxGetScalar(prhs[1]);
    const int numValues = (int) mxGetScalar(prhs[1]);
    int realInts[numValues],imagInts[numValues];
    testHexCharConversion();
    //plhs[0] = mxCreateNumericMatrix(1,maxNum/2,mxUINT32_CLASS,mxCOMPLEX);
    //plhs[1] = mxCreateDoubleMatrix(1,maxNum/2,mxCOMPLEX);
    //read_file_toarr(prhs[0],plhs[0],n,maxNum);
    //read_file_wrap(prhs[0],plhs[1],n,maxNum);
    return;
}
