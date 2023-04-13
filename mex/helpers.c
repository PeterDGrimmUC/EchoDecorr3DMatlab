#include "helpers.h"
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#ifdef _WIN32
    #include <Windows.h>
#elif defined(__linux__) || defined(__APPLE__)
    #include <fcntl.h>
    #include <sys/mman.h>
    #include <sys/stat.h>
    #include <unistd.h>
#endif

#ifdef _WIN32
#define PATH_DELIM "\\"
#else
#define PATH_DELIM "/"
#endif

/* Platform independent memory map for files */
void * mmap_file(const char* filename, size_t *size) {
    void *mapped = NULL;
#ifdef _WIN32
    HANDLE hFile = CreateFileA(filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) {
        perror("Error opening file");
        return NULL;
    }
    DWORD fileSize = GetFileSize(hFile, NULL);
    *size = fileSize;
    HANDLE hMapFile = CreateFileMapping(hFile, NULL, PAGE_READONLY, 0, 0, NULL);
    if (hMapFile == NULL) {
        perror("Error creating file mapping");
        CloseHandle(hFile);
        return NULL;
    }
    mapped = MapViewOfFile(hMapFile, FILE_MAP_READ, 0, 0, 0);
    if (mapped == NULL) {
        perror("Error mapping view of file");
    }
    CloseHandle(hMapFile);
    CloseHandle(hFile);

#elif defined(__linux__) || defined(__APPLE__)
    int fd = open(filename, O_RDONLY);
    if (fd == -1) {
        perror("Error opening file");
        return NULL;
    }
    struct stat st;
    if (fstat(fd, &st) == -1) {
        perror("Error getting file size");
        close(fd);
        return NULL;
    }
    *size = st.st_size;
    mapped = mmap(NULL, *size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (mapped == MAP_FAILED) {
        perror("Error memory mapping file");
        close(fd);
        return NULL;
    }
    close(fd);
#endif
    return mapped;
}
void munmap_file(void *mapped, size_t size) {
#ifdef _WIN32
    UnmapViewOfFile(mapped);
#elif defined(__linux__) || defined(__APPLE__)
    munmap(mapped, size);
#endif
}
/* helpers for strings */
static inline char * strCatVarg(const int numStrings,...){
    /* Join path of an arbitrary number of c strings */
    char * tmp, * outStr;
    int outStrLen=0;
    /* init variable args, one for determining the combined string length, one for combining them */
    va_list valist,valist_c;
    va_start(valist, numStrings);
    va_copy(valist_c,valist);
    /* Get string length of each argument */
    for(int i = 0; i < numStrings; i++){
        outStrLen+=strlen(va_arg(valist_c, char *)); // string length
    }
    /* allocate memory to the result string, total length + 1 for \0 */
    outStr = malloc(outStrLen+1);
    /* free arg copy */
    va_end(valist_c);
    /* start with next arg list */
    va_start(valist, numStrings);
    tmp = va_arg(valist, char *);
    /* Init newly allocated string with first string in args */
    strcpy(outStr,tmp);
    for(int i = 0; i<numStrings-1; i++){
        tmp = va_arg(valist, char *);
        strcat(outStr, tmp);
    }
    va_end(valist);
    return outStr;
}
char * joinPath(const char * dirbase,const char * dirhead){
    /* wrapper around variable arg sized strcat to join paths, given PATH_DELIM defined by the preprocessor */
    return strCatVarg(3, dirbase, PATH_DELIM, dirhead);
}

bool file_exists(const char *filename) {
    FILE *fp = fopen(filename, "r");
    if (fp)
    {
        return true;
        fclose(fp);
    }
    return false;
}

bool dir_exists(const char * dirname){
    DIR * dp = opendir(dirname);
    if (dp) {
        return true;
        closedir(dp);
    }
    return false;
}
