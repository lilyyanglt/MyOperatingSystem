#include "screen.h"
#include "../kernel/util.c"
#include "../kernel/low_level.c"

void print_char(char character, int col, int row, char attribute_byte) {
    
    unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;

    if (!attribute_byte) {
        attribute_byte = WHITE_ON_BLACK;
    }

    int offset;

    if (col >= 0 && row >= 0) {
        offset = get_screen_offset(col, row);
    } else {
        offset = get_cursor();
    }

    if (character == '\n') {
        int rows = offset / (2 * MAX_COLS);
        offset = get_screen_offset(79, rows);
    } else {
        vidmem[offset] = character;
        vidmem[offset+1] = attribute_byte;
    }

    offset += 2;

    offset = handle_scrolling(offset);

    set_cursor(offset);
}

int get_screen_offset(int row, int col) {
    // this is similar to get_cursor, only now we write
    // bytes to those internal device registers

    port_byte_out(REGISTER_SCREEN_CTRL, 14);
    port_byte_out(REGISTER_SCREEN_DATA, (unsigned char)(offset >> 8));
    port_byte_out(REGISTER_SCREEN_CTRL, 15);

    cursor_offset -= 2 * MAX_COLS;

    return cursor_offset;
}

/*
    the device uses its control register as an index 
    to select its internal registers, of which we are interested
    in:

    reg 14: which is the high byte of the cursor's offset
    reg 15: which is the low byte of the cursor's offset
    once the internal register has been selected, we may read or
    write a byte on the data register

*/
int get_cursor() {
    port_byte_out(REGISTER_SCREEN_CTRL, 14);
    
    int offset = port_byte_in(REGISTER_SCREEN_DATA) << 8;
    port_byte_out(REGISTER_SCREEN_CTRL, 15);
    offset += port_byte_in(REGISTER_SCREEN_DATA);

    /*
        Since the cursor offset reported by the VGA hardware is the
        number of characters, we multiply by two to convert it to
        a character cell offset
    */
}

/*
    this is similar to get_cursor, only now we write bytes to those
    internal device registers
*/

void set_cursor(int offset) {
    offset /= 2; // this convert from cell offset to char offset


}

void print_at(char* message, int col, int row) {
    if (col >= 0 && row >= 0) {
        set_cursor(get_screen_offset(col, row));
    }

    int i = 0;
    while(message[i] != 0) {
        print_char(message[i++], col, row, WHITE_ON_BLACK);
    }
}

void print(char* message) {
    print_at(message, -1, -1);
}

void clear_screen() {
    int row = 0;
    int col = 0;

    for (row = 0; row < MAX_ROWS; row++) {
        for (col = 0; col < MAX_COLS; col++) {
            print_char(' ', col, row, WHITE_ON_BLACK);
        }
    }

    set_cursor(get_screen_offset(0, 0));
}

/*
  this advances the text cursor, scrolling the video buffer
  if required
*/
int handle_scrolling(int cursor_offset) {

    int SCREEN_AREA = MAX_ROWS * MAX_COLS * 2;

    if(cursor_offset < SCREEN_AREA) {
        return cursor_offset;
    }

    // this shuffles the row back one if our 
    // cursor is outside of the screen area
    for (int i = 1; i < MAX_ROWS; i++) {
        memory_copy(get_screen_offset(0, i) + VIDEO_ADDRESS,
                    get_screen_offset(0, i-1) + VIDEO_ADDRESS,
                    MAX_COLS * 2);
    }

    char* last_line = get_screen_offset(0, MAX_ROWS-1) + VIDEO_ADDRESS;

    for (int i = 0; i < MAX_COLS * 2; i++) {
        last_line[i] = 0;
    }

    cursor_offset -= 2 * MAX_COLS;

    return cursor_offset;
}