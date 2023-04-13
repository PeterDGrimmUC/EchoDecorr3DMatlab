#ifndef SCANNERDATA_H_
#define SCANNERDATA_H_
#include "ScannerMetadata.h"

#define TWOS_COMP(z) (~z)+1
#define printHexSubStr(thisstr,offset,name) printf("%s: %c%c%c%c%c ",name,thisstr[0+offset],thisstr[1+offset],thisstr[2+offset],thisstr[3+offset],thisstr[4+offset]);
#define printConvertHex(datr, dati, i) printf("float -> %f + %f i", hex2Dec_SWFC(datr[i]), hex2Dec_SWFC(dati[i]));

/* Variables which shouldn't change */
#define ASCII_A_TO_INT 55 /* Number to subtract to go from ASCII 'A' to its decimal value */
#define ASCII_0_TO_INT 48 /* Number to subtract to go from ASCII '0' to its decimal value */
#define SIGNED_FLOAT_MASK 0b00111100100000000000000000000000 /* When XOR'd with 17-bit SWFC returns properly formatted single precision float -.5, signed case */
#define UNSIGNED_FLOAT_MASK 0b00111111000000000000000000000000 /* When XOR'd with 17-bit SWFC returns properly formatted single precision float +.5, unsigned case */
#define HEXSTR_ASCII_SIZE 5 /* Size of ASCII hex string in datasets */
#define FLOAT_CORRECTION 0.5 /* Amount to add/subtract from bit manipulated SWFC value */
#define SWFC_BITLEN 17 /* Size of SWFC data bits */
#define SWFC_FRACBITLEN 7 /* Offset for shift when converting from SWFC */

#define REAL_OFFSET 5
#define IMAG_OFFSET 14
#define LINE_OFFSET 19
#define START_IND 208
#define DATA_DELIM ':'



#ifdef __USE_MEX__
#include "mex.h"
#define WComplex mxComplexDouble
#else
typedef struct {
    double real;
    double imag;
} WComplex;
#endif

typedef struct {
    ScannerMetadata metadata;
    WComplex * data;
} ScannerData;

ScannerData initScannerData(const char * folderName, ScannerOutputType outputType);

int readScannerData(ScannerData * data, ScannerOutputType outputType);

int freeScannerData(ScannerData * data);
#endif // SCANNERDATA_H_
