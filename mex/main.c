#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <stdarg.h>
#include <dirent.h>
#include "ScannerMetadata.h"
#include "ScannerData.h"

int main(int argc, const char **argv){
    if(argc < 2){
        return 0;
    }
    ScannerData data = initScannerData(argv[1], IQ3D);
    readScannerData(&data, IQ3D);
//    for(int i=0; i < 100; i++){
//        printf("Data[%i]= %f + i * %f\n", i, data.data[i].real, data.data[i].imag);
//    }
    freeScannerData(&data);
//    ScannerMetadata metadata = initMetadata(argv[1], IQ3D);
//    readMetadata(&metadata, IQ3D);
//    printMetadata(&metadata);
//    int succ = parseFolder(&data, argv[1], IQ3D);
//    if(succ != -1){
//        printMetadata(&data.metadata);
//    }
};
