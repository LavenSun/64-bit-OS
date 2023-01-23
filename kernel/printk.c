#include <stdarg.h>
#include "printk.h"
#include "lib.h"
#include "linkage.h"

int color_printk(unsigned int FRcolor, unsigned int BKcolor, const char *fmt, ...)
{
    int count = 0;
    int line = 0;
    int i = 0;

    va_list args;
    va_start(args, fmt);
    i = vsprintf(buf, fmt, args);
    va_end(args);
}