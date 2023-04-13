#ifndef HELPERS_H_
#define HELPERS_H_
#include <stdio.h>
#include <stdbool.h>

void * mmap_file(const char * filename, size_t * size);
void munmap_file(void * mapped, size_t size);
char * joinPath(const char * dirBase, const char * dirhead);
bool file_exists(const char * filename);
bool dir_exists(const char * dirname);
#endif // HELPERS_H_
