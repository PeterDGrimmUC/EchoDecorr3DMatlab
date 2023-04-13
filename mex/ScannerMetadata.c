#include "ScannerMetadata.h"
#include "helpers.h"
#include <limits.h>


/* helpers for parameters */
ScannerParam * getParamPtr(ScannerParam * scannerParams,const int numParams, const char * paramName){
    // TODO: a hash table would be more elegant, but there's typically only 16 parameters and it runs very few times, so it's not a big deal
    for(int i = 0; i < numParams; i++){
        if(strcmp(paramName, scannerParams[i].name)==0){
            return &scannerParams[i];
        }
    }
    return NULL;
}
ScannerParam * getParam(ScannerMetadata * metadata, const char * name){
    ScannerParam * datPtr = getParamPtr(metadata->scannerParams, metadata->numParams, name);
    if(datPtr){
        return datPtr;
    }
    return NULL;
}

int parseTimeStamp(struct tm * timeStamp,const char * folderName){
    if(strptime(folderName,"IQDATA_Date_%m-%d-%Y_Time_%H-%M-%S", timeStamp)){
        return 1;
    }else{
        fprintf(stderr, "Could not parse timestamp");
        return -1;
    }

}

/* Process metadata from header files */
int processHeader(ScannerParam * dataSetInfo, const char *fileName,  const int numParams) {
    /* Process header file 'fileName', search for parameters defined in ScannerParam, numParams is the length of the ScannerParam array
     * return an int equal to the number of parameters found */
    size_t size;
    char * tmp;
    if(!file_exists(fileName)){
        return -1;
    }
    char * mappedFile = (char *) mmap_file(fileName, &size);
    int succCount=0;
    for(int i=0; i < numParams; i++){
        tmp=strstr(mappedFile,dataSetInfo[i].name);
        if(tmp != NULL){
            succCount++;
            if(dataSetInfo[i].isHex){
                sscanf(tmp+strlen(dataSetInfo[i].name)," = 0x%x",&dataSetInfo[i].value.int_val);
            }else{
                if(dataSetInfo[i].isInt){
                    sscanf(tmp+strlen(dataSetInfo[i].name)," = %x",&dataSetInfo[i].value.int_val);
                }else{
                    sscanf(tmp+strlen(dataSetInfo[i].name)," = %f",&dataSetInfo[i].value.float_val);
                }
            }
        }
    }
    munmap_file(mappedFile, size);
    return succCount;
}

static inline int getMetadataFromScannerFolder3D(ScannerMetadata * metadata){
    int numSucc =0;
    char * tmpFname;
    for(int i = 0; i < metadata->numInfoFiles;i++){
        tmpFname = joinPath(metadata->folderPath, metadata->infoFileNames[i]);
        numSucc+=processHeader(metadata->scannerParams,
                      joinPath(metadata->folderPath, metadata->infoFileNames[i]),
                      metadata->numParams);
        free(tmpFname);
    }
    if(numSucc != metadata->numParams){
        fprintf(stderr,"Could not find all parameters in info file\n");
        return -1;
    }
    /* This check shouldn't be needed if it found everything */
    ScannerParam  * numRangeSamples = getParam(metadata,"NumRangeSamples");
    ScannerParam  * numLines        = getParam(metadata, "BufSizeInLines");
    if(numLines && numRangeSamples){
        metadata->numElements=numLines->value.int_val * numRangeSamples->value.int_val;
    }else{
        fprintf(stderr, "Memory allocation failed at %i\n", __LINE__);
    }
    return numSucc;
}
static inline int getMetadataFromScannerFolder2D(ScannerMetadata * metadata, const char * folderName){
    //TODO:
    return -1;
}
static inline int getMetadataFromScannerFolderBiplane(ScannerMetadata * metadata, const char * folderName){
    //TODO:
    return -1;
}

int readMetadata(ScannerMetadata * metadata, ScannerOutputType outputType){
    switch(outputType){
        case IQ3D:
            if(getMetadataFromScannerFolder3D(metadata) == metadata->numParams){
                return 1;
            }else{
                fprintf(stderr, "Missing parameters! \n");
                return -1;
            }
            break;
        case IQ2D:
            fprintf(stderr,"Not implemented for 2D \n");
            return -1;
            break;
        case IQBIPLANE:
            fprintf(stderr,"Not implemented for Biplane \n");
            return -1;
            break;
    }
}
/* interface for metadata */
static inline ScannerMetadata get3DMetaDataDefault(const char * folderName){
    ScannerMetadata metadata = GEN_METADATA_DEFAULT(DEFAULT_3D_PARAMS,DEFAULT_3D_NUM_PARAMS,
                                             DEFAULT_3D_INFO_FILENAMES, DEFAULT_3D_NUM_INFOFILES,DEFAULT_3D_DATA_FILENAME);
    strcpy(metadata.folderPath, folderName);
    parseTimeStamp(&metadata.timeStamp, folderName);
    return metadata;
}
static inline ScannerMetadata getMetadataDefault(const char * folderName, ScannerOutputType outputType){
    switch(outputType){
        case IQ3D:
            return get3DMetaDataDefault(folderName);
            break;
        case IQ2D:
            return get3DMetaDataDefault(folderName);
            //return GEN_META_DEF_NAME(3D);
            break;
        case IQBIPLANE:
            return get3DMetaDataDefault(folderName);
            //return GEN_META_DEF_NAME(3D);
            break;
    }
}

ScannerMetadata initMetadata(const char * folderName, ScannerOutputType outputType){
    ScannerMetadata metadata = getMetadataDefault(folderName, outputType);
    if(strlen(folderName) > PATH_MAX){
        fprintf(stderr, "Path exceeds system maximum \n");
    }
    strcpy(metadata.folderPath, folderName);
    if(!dir_exists(metadata.folderPath)){
        fprintf(stderr, "Could not open directory: %s \n", metadata.folderPath);
    }
    return metadata;
}

void printScannerParams(ScannerParam * scannerParams,const int numParams){
    for(int i = 0; i < numParams;i++){
        printf("Parameter: %s ->  ",scannerParams[i].name);
        if(scannerParams[i].isInt){
           printf("%i \n\t",scannerParams[i].value.int_val);
        }else{
           printf("%f \n\t",scannerParams[i].value.float_val);
     }
    }
}
void printMetadata(ScannerMetadata * datIn){
    printf("Folder: %s\n\tData filename:%s \n\t",datIn->folderPath, datIn->dataFileName);
    for(int i = 0; i < datIn->numInfoFiles; i++){
        printf("Info filename # %i: %s \n\t", i, datIn->infoFileNames[i]);
    }
    printf("Parsed timestamp: %i-%i-%i @ %i:%i:%i \n\t", datIn->timeStamp.tm_mon, datIn->timeStamp.tm_mday
           ,datIn->timeStamp.tm_year, datIn->timeStamp.tm_hour, datIn->timeStamp.tm_min, datIn->timeStamp.tm_sec);
    printScannerParams(datIn->scannerParams, datIn->numParams);
    printf("Computed number of complex numbers in file : %li",datIn->numElements);//number of strings in the file is 2x this, 1 for the real component, 1 for imaginary
}
