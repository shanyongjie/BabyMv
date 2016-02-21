#import "log.h"

#ifdef DEBUG

void PrintHexData(NSData* data)
{
    OutputLogHex([data bytes], [data length]);
}

#endif // #ifdef DEBUG
