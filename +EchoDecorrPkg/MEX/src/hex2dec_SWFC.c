float usDataFactory::hex2Dec_SWFC(std::string hexString){
   /* HEX2Dec_SWFC
        Convert hex string to decimal using SWFC convention with swfc = [1 0 17 1]
        this means the number is signed, and that all of the information bits come after the decimal place (e.g output = 0.b1b2b3...bn where n = 17)
   */
    //unsigned int twoCompMask = 131071; // When XOR'd with 17 bit data bit input (inside 32 bit unsigned int) flips bit for two's compliment
    unsigned int signedFloatMask = 3187671040;// Signed float mask: When XOR'd with the input 32 bit unsigned twos compliment int forms a float with exponent -1 and a 1 sign bit, also reverses shifted sign bit eg in decimal[1][126-8][bits][padded to end]
    unsigned int unsignedFloatMask = 1056964608; // Unsigned float mask: When XOR'd with the input forms a float with exponent -1 and a 1 sign bit, also reverses shifted sign bit eg in decimal[1][126-8][bits][padded to end]
    float floatCorrection = .5; // Mantissa is of the form 1.b1b2b3... so when exponent = -1 there is an additional 2^-1 (.5) term in the float, which must be subtracted/added depending on sign
    //get input int
    unsigned int num = std::stoi(hexString, nullptr,16); //convert hex string to int
    // Bitwise manipulation
    if (num >> 17){ // check if signed bit is 1
        //num = (twoCompMask^num)+1;// two's compliment
        num = (~num)+1;
        num = (num<<7)^signedFloatMask; // shift information bits to proper spot for exponent -1 (num <<7), then xor with the signedFloatMask
        return *(float*)(&num) + floatCorrection; // dereference num, cast what the address points to as a float and add correction
    }
    else{
        num = (num<<7)^unsignedFloatMask; // same as above, but don't take two's compliment
        return *(float*)(&num) - floatCorrection; // .5 is here because mantissa in a float is of the form 1.b1b2b3..., with an exponent of -1, .5 must is left over
    }
}
