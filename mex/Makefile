MKDIR_P = mkdir -p

MATLAB_ROOT=$(MWROOT)
MEX_LIBS = -L$(MATLAB_ROOT)/bin/maci64 -lmex -lmx -lmat
MEX_INCLUDES = -I$(MATLAB_ROOT)/extern/include
CC = clang
CFLAGS = -O3 -Wall -arch x86_64
LDFLAGS = -bundle -Wl,-flat_namespace -undefined suppress

#main: main.c SC2000_parse.c helpers.c
#	$(CC) $(CFLAGS) main.c SC2000_parse.c helpers.c -o main
main: main.c ScannerMetadata.c ScannerData.c helpers.c
	$(CC) $(CFLAGS) main.c ScannerMetadata.c helpers.c ScannerData.c -o main
mex: read_lbdump.mexmaci64
shared: SC2000_parse.so
SC2000_parse.so: SC2000_parse.h SC2000_parse.c helpers.h helpers.c
	$(CC) $(CFLAGS) -shared SC2000_parse.c helpers.c -o SC2000_parse.so
#read_lbdump.mexmaci64: read_lbdump.o
#	$(CC) $(CFLAGS) $(LDFLAGS) $(MEX_LIBS) -o $@ $<
#read_lbdump.o: read_lbdump.c SC2000_parse.o Makefile
#	$(CC) $(CFLAGS) -c read_lbdump.c SC2000_parse.o -o read_lbdump.o $(MEX_INCLUDES) $(INCLUDE)
#c_mexapi_version.o : extern/c_mexapi_version.c Makefile
#	$(CC) -c $< -o $@ $(MATLABMEX) $(DEFINES) $(CFLAGS) $(COPTIMFLAGS) $(INCLUDE)
clean:
	rm -f *.o *.mexa64 *.mexmaci64 *.so *.a main
