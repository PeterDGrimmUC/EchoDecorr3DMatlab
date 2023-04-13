#ifndef SCANNERMETADATA_H_
#define SCANNERMETADATA_H_
#include <limits.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>
#include "helpers.h"

#define isHexParam true
#define isIntegerValued true

#define DEFAULT_3D_PARAMS                                               \
    {                                                                   \
    {.name="BufSizeInLines",      .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumLinesPerPGroup",   .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumLinesPerSlice",    .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumRangeSamples",     .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumSlices",           .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumSlicesPerSubFrame",.isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumSlicesPerSweep",   .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumFramesPerBuf",     .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="BufWritePtrFrames",   .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="feStreamId",          .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumLinesPerFrame",    .isHex= isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="NumSamplesPerMm",     .isHex=!isHexParam,  .isInt=!isIntegerValued, .value={-1.0}}, \
    {.name="phiRange",            .isHex=!isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="thetaRange",          .isHex=!isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="frameRate",           .isHex=!isHexParam,  .isInt= isIntegerValued, .value={-1}}, \
    {.name="depth",               .isHex=!isHexParam,  .isInt= isIntegerValued, .value={-1}} \
    }
#define DEFAULT_3D_DATA_FILENAME    "bufApl0Out_0x0_0x0.data.dm.pmcr"
#define DEFAULT_3D_INFO_FILENAMES   {"bufApl0Out_0x0_0x0.info.txt","addParamFile.txt"}
#define DEFAULT_3D_NUM_PARAMS       16
#define DEFAULT_3D_NUM_INFOFILES    2
#define DEFAULT_3D_INFOFILE_STRSIZE 50

typedef union {
/* Union for metadata parameters parsed from info files */
    float float_val;
    int int_val;
} param_val;

typedef struct ScannerParam{
/* Stores a parameter pulled from info file, with its name, value and info about its type */
    const bool isHex;
    const bool isInt;
    param_val value;
    const char * name;
} ScannerParam;

#define GEN_META_NAME(_NAME) ScannerMetadata_##_NAME
#define GEN_META_IFACE_NAME(_NAME) ScannerMetadata_##_NAME##_IFACE
#define GEN_META_DEF_NAME(_NAME) ScannerMetadata_##_NAME##_default
#define GEN_DEF_VAL_NAME(_NAME) val_##_NAME
#define DEF_TYPE(_NAME) typedef struct GEN_META_IFACE_NAME(_NAME) GEN_META_NAME(_NAME)

//#define DECL_METADATA_ALL(_NUM_PARAMS,_NUM_INFOFILES)         \
//    typedef struct ScannerMetadata {                                    \
//        const char infoFileNames[_NUM_INFOFILES][PATH_MAX];             \
//        const char dataFileName[PATH_MAX];                              \
//        const unsigned int numInfoFiles;                                  \
//        const unsigned int numParams;                                     \
//        const struct tm timeStamp;                                      \
//        size_t numElements;                                             \
//        char folderPath[PATH_MAX];                                \
//        ScannerParam scannerParams[_NUM_PARAMS];                        \
//    } ScannerMetadata;

//#define DECL_METADATA_STRUCT(_NAME, _PARAMS,_NUM_PARAMS,                \
//                             _INFO_FILES, _NUM_INFOFILES,_DATAFILE)     \
//    typedef struct GEN_META_IFACE_NAME(_NAME) {                         \
//        const char infoFileNames[_NUM_INFOFILES][PATH_MAX];             \
//        const char dataFileName[PATH_MAX];                              \
//        const unsigned int numInfoFiles;                                  \
//        const unsigned int numParams;                                     \
//        const struct tm timeStamp;                                      \
//        size_t numElements;                                             \
//        const char folderPath[PATH_MAX];                                \
//        ScannerParam scannerParams[_NUM_PARAMS];\
//    } GEN_META_NAME(_NAME);

#define GEN_METADATA_DEFAULT_NAMED(_NAME, _PARAMS,_NUM_PARAMS,                \
                             _INFO_FILES, _NUM_INFOFILES,_DATAFILE)     \
    ScannerMetadata GEN_META_DEF_NAME(_NAME) =                     \
    {                                                                   \
        .infoFileNames  = _INFO_FILES,                                  \
        .dataFileName   = _DATAFILE,                                    \
        .numInfoFiles   = _NUM_INFOFILES,                               \
        .numParams      = _NUM_PARAMS,                                  \
        .scannerParams  = _PARAMS,                                      \
        .numElements    = -1                                            \
    };

#define GEN_METADATA_DEFAULT(_PARAMS,_NUM_PARAMS,                \
                             _INFO_FILES, _NUM_INFOFILES,_DATAFILE)     \
    {                                                                   \
        .infoFileNames  = _INFO_FILES,                                  \
        .dataFileName   = _DATAFILE,                                    \
        .numInfoFiles   = _NUM_INFOFILES,                               \
        .numParams      = _NUM_PARAMS,                                  \
        .scannerParams  = _PARAMS,                                      \
        .numElements    = -1                                            \
    };



//#define GEN_METADATA_TYPE(_NAME, _PARAMS,_NUM_PARAMS,                   \
//                          _INFO_FILES, _NUM_INFOFILES,_DATAFILE)        \
//    typedef struct GEN_META_IFACE_NAME(_NAME) {                         \
//        const char infoFileNames[_NUM_INFOFILES][PATH_MAX];             \
//        const char dataFileName[PATH_MAX];                              \
//        const unsigned int numInfoFiles;                                  \
//        const unsigned int numParams;                                     \
//        const struct tm timeStamp;                                      \
//        size_t numElements;                                             \
//        const char folderPath[PATH_MAX];                                \
//        ScannerParam scannerParams[_NUM_PARAMS];\
//    } GEN_META_NAME(_NAME);                                             \
//    GEN_META_NAME(_NAME) GEN_META_DEF_NAME(_NAME) =                     \
//    {                                                                   \
//        .infoFileNames  = _INFO_FILES,                                  \
//        .dataFileName   = _DATAFILE,                                    \
//        .numInfoFiles   = _NUM_INFOFILES,                               \
//        .numParams      = _NUM_PARAMS,                                  \
//        .scannerParams  = _PARAMS,                                      \
//        .numElements    = -1                                            \
//    };

typedef enum ScannerOutputType{IQ3D, IQ2D, IQBIPLANE} ScannerOutputType;

typedef struct ScannerMetadata {
  const char infoFileNames[2][PATH_MAX];
  const char dataFileName[PATH_MAX];
  const unsigned int numInfoFiles;
  const unsigned int numParams;
  struct tm timeStamp;
  size_t numElements;
  char folderPath[PATH_MAX];
  ScannerParam scannerParams[16];
} ScannerMetadata;


//GEN_METADATA_DEFAULT_NAMED(3D, DEFAULT_3D_PARAMS,DEFAULT_3D_NUM_PARAMS,
//                     DEFAULT_3D_INFO_FILENAMES, DEFAULT_3D_NUM_INFOFILES,DEFAULT_3D_DATA_FILENAME);
//TODO:
//GEN_METADATA_DEFAULT_NAMED(2D, DEFAULT_3D_PARAMS,DEFAULT_3D_NUM_PARAMS,
//                     DEFAULT_3D_INFO_FILENAMES, DEFAULT_3D_NUM_INFOFILES,DEFAULT_3D_DATA_FILENAME);

//GEN_METADATA_DEFAULT_NAMED(BP, DEFAULT_3D_PARAMS,DEFAULT_3D_NUM_PARAMS,
//                     DEFAULT_3D_INFO_FILENAMES, DEFAULT_3D_NUM_INFOFILES,DEFAULT_3D_DATA_FILENAME);

ScannerMetadata initMetadata(const char *folderName, ScannerOutputType outputType);
int getMetadataFromScannerFolder(ScannerMetadata *metadata, const char *folderName, ScannerOutputType outputType);

ScannerParam * getParamPtr(ScannerParam * scannerParams,const int numParams, const char * paramName);
ScannerParam * getParam(ScannerMetadata * metadata, const char * name);
int readMetadata(ScannerMetadata * metadata, ScannerOutputType outputType);
void printScannerParams(ScannerParam * scannerParams,const int numParams);
void printMetadata(ScannerMetadata * datIn);
#endif // SCANNERMETADATA_H_
