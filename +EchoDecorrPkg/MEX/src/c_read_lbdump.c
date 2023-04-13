#include "c_read_lbdump.h"

#ifdef __AVX2__
inline unsigned int hexstr2int(const char * hexString, const int startInd, const int hexStrLen){

}
#else
inline unsigned int hexstr2int(const char * hexString, const int startInd, const int hexStrLen){
    const int asciiaToInt=86; // = 'a'(97)-11=86->'a'-86=11
    const int asciiAToInt=54; // = 'A'(65)-11=54->'A'-54=11
    const int ascii0ToInt=48; // = '0'(48)=48->'0'-48=0
    unsigned int res;
    char temp;
    for(int i=0; i<hexStrLen; i++)
    {
        if(hexString[i] >= 'A')
        {
            temp=hexString[i]-asciiAToInt;
        }
        else if(hexString[i] >= '0')
        {
            temp=hexString[i]-ascii0ToInt;
        }
        else
        {

        }
    res=(res|((int)temp))<<4; /* logical or between casted int (vals from 0-16(4 bits)) and shift*/
    }
    return res;
}
#endif
inline int convert_to_hex_vec(char * hexString){

}

inline unsigned int * check_sign_vec(unsigned int * swfc_float_vec ) {

}

inline unsigned int * twos_comp_vec(unsigned int * swfc_int_vec){

}

inline unsigned int * convert_int(unsigned int * swfc_comp){

}

void read_lbdump_h(){

}
