#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <complex.h>
#include <limits.h>
#include "ScannerMetadata.h"
#include "ScannerData.h"
/* Bitwise helpers */
static inline char charToHexNib(const char charIn){
    if(charIn >= 'A')
    {
        return charIn-ASCII_A_TO_INT;
    }
    else if(charIn >= '0')
    {
        return charIn-ASCII_0_TO_INT;
    }
    else
    {
        return (char) 0;
    }
}
static inline uint32_t hexStrToInt(const char * hexStrIn){
    // Take a hex string and convert to integer
    uint32_t ret=0;
    for(unsigned int i=0; i<HEXSTR_ASCII_SIZE-1; i++){
        ret=(ret | (uint32_t) charToHexNib(hexStrIn[i]))<<4;
    }
    return (ret | (uint32_t) charToHexNib(hexStrIn[HEXSTR_ASCII_SIZE-1]));
}
static inline float hex2Dec_SWFC(uint32_t num){
    if (num >> SWFC_BITLEN){ // check if signed bit is 1
        num = (((~num)+1) << SWFC_FRACBITLEN) ^ SIGNED_FLOAT_MASK;
        return ((*(float*)(&num)) + 64)/128; //+ floatCorrection; // dereference num, cast what the address points to as a float and add correction
    }
    else{
        num = (num<<SWFC_FRACBITLEN)^UNSIGNED_FLOAT_MASK; // same as above, but don't take two's compliment
        return *(float*)(&num) - FLOAT_CORRECTION; // .5 is here because mantissa in a float is of the form 1.b1b2b3..., with an exponent of -1, .5 must is left over
    }
}
static inline float hexStr2Float_SWFC(const char * hexStrIn){
    return hex2Dec_SWFC(hexStrToInt(hexStrIn));
}

static inline int parseDataFile(const char * restrict mappedFile, WComplex * data, const size_t numMapped, const size_t numElems){
    const char * workingStr = mappedFile + START_IND; //strstr(mappedFile, "Data"); //TODO: don't hard code this
    if(!workingStr){
        printf("Could not find start of data stream!");
        return -1;
    }
    for(int i=0; i < numElems; i++){
        while(workingStr[0] != DATA_DELIM){
            workingStr++;
        }
        data[i].real = (WFloat) hexStr2Float_SWFC(workingStr+REAL_OFFSET);
        data[i].imag = (WFloat) hexStr2Float_SWFC(workingStr+IMAG_OFFSET);
        workingStr+=LINE_OFFSET;
    }
    return 1;
}

/* Vectorized versions, TBD if this is better or not */
static inline void hex2Dec_SWFC_vectorized(void * nums, const int numElem){
/*
There is a sane reason for doing it this way. (passing as a void pointer, and defining two casted pointers to it)
Passing a second pointer for the converted output would require two mallocs of a fairly large array
this makes that unnecessary, even if it is ugly/unsafe looking
*/
    float * numsF=(float *) nums;
    int * numsI=(int *) nums;
#if defined(__AVX2__) && defined(__USE_INTRIN__)

#elseif defined(__ARM_NEON__) && defined(__USE_INTRIN__)
#else
    for(int i=0; i<numElem;i++){
        if (numsI[i] >> SWFC_BITLEN){
            numsI[i]=((TWOS_COMP(numsI[i]))<<SWFC_FRACBITLEN) ^ SIGNED_FLOAT_MASK;
            numsF[i]=((*(float *)(&nums[i]))+64)/128;
        }else{
            numsI[i]=((numsI[i])<<SWFC_FRACBITLEN) ^ UNSIGNED_FLOAT_MASK;
            numsF[i]=*(float*)(&numsI[i])-FLOAT_CORRECTION;
        }
    }
#endif
}
static inline unsigned int * hexStrToIntVec(const char ** hexStrList,const unsigned int numStrs, const unsigned int startInd, const unsigned int numChars ){
    unsigned int ret = 0;
    unsigned int * outArr = malloc(numStrs * sizeof(unsigned int));
    #if defined(__AVX2__) && defined(__USE_INTRIN__)

    #elseif defined(__ARM_NEON__) && defined(__USE_INTRIN__)
    #else
    for(int i=0;i<numStrs;i++){
        ret = 0;
        for(int j=0; j < numChars; j++){
            ret=(ret | (int) charToHexNib(hexStrList[i][startInd+j]))<<4;
        }
        ret=(ret | (int) charToHexNib(hexStrList[i][startInd+numChars-1]));
    }
    #endif
    return outArr;
}
static inline int parseDataFile_vec(const char * mappedFile, uint32_t * dataReal, uint32_t * dataImag, const size_t numMapped, const size_t numElems){
    const char delim_char = ':';
    const char * workingStr = mappedFile + START_IND; //strstr(mappedFile, "Data"); //TODO: don't hard code this
    size_t outputInd = 0;
    if(!workingStr){
        printf("Could not find start of data stream!");
        return -1;
    }
    //TODO
    return 1;
}
ScannerData initScannerData(const char *folderName, ScannerOutputType outputType){
    ScannerMetadata metadata = initMetadata(folderName, outputType);
    ScannerData out = {.metadata=metadata, .data=NULL};
    return out;
}
/* Interface */
int readScannerData(ScannerData * data, ScannerOutputType outputType){
    size_t size;
    if(readMetadata(&data->metadata, outputType) < 0){
        fprintf(stderr,"Metadata read failed!\n");
        printf("Metadata read failed!\n");
        return -1;
    }
    size_t alloc_size = sizeof(WComplex) * data->metadata.numElements;
    //printf("Allocating %lu bytes for %lu elements",sizeof(WComplex) * data->metadata.numElements,data->metadata.numElements);
    //data->data = malloc(alloc_size);
    data->data = WComplexMalloc1D(data->metadata.numElements);
    if(!data->data){
        fprintf(stderr, "Allocation failed \n");
        printf("Allocation failed \n");
        return -1;
    }
    char * dataFilePath = joinPath(data->metadata.folderPath, data->metadata.dataFileName);
    if(!file_exists(dataFilePath)){
        fprintf(stderr, "Could not open data file %s \n", dataFilePath);
        printf("Could not open data file %s \n", dataFilePath);
        return -1;
    }
    char * mappedFile = (char *) mmap_file(dataFilePath, &size);
    parseDataFile(mappedFile, data->data, size, data->metadata.numElements);
    /* Deallocate heap memory */
    munmap_file(mappedFile, size);
    free(dataFilePath);
    return 1;
}
int freeScannerData(ScannerData * data){
    free(data->data);
    //TODO
    return 1;
}
