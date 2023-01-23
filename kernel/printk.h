#include <stdarg.h>
#include "font.h"
#include "linkage.h"

struct position
{
    int xResolution;
    int yResolution;

    int xPosition;
    int yPosition;

    int xCharSize;
    int yCharSize;

    unsigned int *FB_addr;
    unsigned long FB_length;
} Pos;
