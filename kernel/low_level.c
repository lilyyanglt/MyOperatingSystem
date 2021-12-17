// demonostrating inline assembly by writing low level port i/o functions
// these functions will be used by most hardware drivers in our kernel

/**

handy function c wrapper function that reads a byte from the 
specified port

"=a" (result) -> this means put AL register in variable RESULT when finished
"d" (port) -> this means load EDX with port
%%dx -> this is escape the escape character, so it will appear literally in string

*/
unsigned char port_byte_in(unsigned short port) {
    unsigned char result;
    __asm__("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

/**

"a" (data) -> means load EAX with data
"d" (port) -> means to load EDX with port

*/
void port_byte_out(unsigned short port, unsigned char data) {

    __asm__("out %%al, %%dx" : :"a" (data), "d" (port));
}

unsigned short port_word_in(unsigned short port) {
    unsigned short result;
    __asm__("in %%dx, %%ax" : "=a" (result) : "d" (port));
}

void port_word_out(unsigned short port, unsigned short data) {
    __asm__("out %%ax, %%dx" : :"a" (data), "d" (port));
}