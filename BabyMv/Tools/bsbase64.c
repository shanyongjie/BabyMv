/*
 *  base64.c
 *  KWPlayer
 *
 *  Created by YeeLion on 11-2-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */


#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

#define BASE64_PAD64 '='

static char base64_alphabet[] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
    'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
    'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a',
    'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
    't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1',
    '2', '3', '4', '5', '6', '7', '8', '9', '+',
    '/'};

static char base64_suffix_map[256] = {
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255,  62, 255, 255, 255,  63,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61, 255, 255,
    255, 255, 255, 255, 255,  0,   1,    2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,
    15,   16,  17,  18,  19,  20,  21,  22,  23,  24,  25, 255, 255, 255, 255, 255, 255,  26,  27,  28,
    29,   30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,
    49,   50,  51, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};

static char cmove_bits(unsigned char src, unsigned lnum, unsigned rnum)
{
    src <<= lnum;
    src >>= rnum;
    return src;
}

int comm_base64_encode_length(int length)
{
    int size = 0, pad = 0;
    if(length <= 0)
        return 0;
    if((pad = length % 3) != 0)
        pad = 3 - pad;
    size = (length + pad) + ((length + pad) * 1/3);
    return size;
}

int comm_base64_encode(const char *data, int length, char* buffer, int size)
{
    char *pos = buffer;
    int padnum = 0, retsize = 0;
    int m = 0;
    
    if(!data || length <= 0)
        return 0;

    if((padnum = length % 3) != 0)
        padnum = 3 - padnum;
    retsize = (length + padnum) + ((length + padnum) * 1/3);
    if(!buffer || size < retsize)
        return 0;
    
    /* Starting to convert the originality characters to BASE64 chracaters. 
     Converting process keep to 4->6 principle. */
    for(m = 0; m < (length + padnum); m += 3)
    {
        /* When data is not suffice 24 bits then pad 0 and the empty place pad '='. */
        *(pos) = base64_alphabet[cmove_bits(*data, 0, 2)];
        if(m == length + padnum - 3 && padnum != 0)
        {  /* Whether the last bits-group suffice 24 bits. */
            if(padnum == 1)
            {   /* 16bit need pad one '='. */
                *(pos + 1) = base64_alphabet[cmove_bits(*data, 6, 2) + cmove_bits(*(data + 1), 0, 4)];
                *(pos + 2) = base64_alphabet[cmove_bits(*(data + 1), 4, 2)];
                *(pos + 3) = BASE64_PAD64;
            }
            else if(padnum == 2)
            { /* 8bit need pad two'='. */
                *(pos + 1) = base64_alphabet[cmove_bits(*data, 6, 2)];
                *(pos + 2) = BASE64_PAD64;
                *(pos + 3) = BASE64_PAD64;
            }
        }
        else
        {  /* 24bit normal. */
            *(pos + 1) = base64_alphabet[cmove_bits(*data, 6, 2) + cmove_bits(*(data + 1), 0, 4)];
            *(pos + 2) = base64_alphabet[cmove_bits(*(data + 1), 4, 2) + cmove_bits(*(data + 2), 0, 6)];
            *(pos + 3) = base64_alphabet[*(data + 2) & 0x3f];
        }
        
        pos += 4;
        data += 3;
    }
    
    if(retsize < size)
        buffer[retsize] = 0;
    
    return retsize;
}

int comm_base64_decode_length(int length)
{
    if(length <= 0)
        return 0;
    return (length - 4) - (length - 4) / 4 + 3;
}

int comm_base64_decode(const char *bdata, int length, char* buffer, int size)
{
    char *pos = buffer;
    int padnum = 0, retsize = 0;
    int m = 0;
    
    if(!bdata || length <= 0)
        return 0;
    if(length % 4 != 0)
        return 0;
    
    if(!buffer)
        return 0;
    
    /* Whether the data have invalid base-64 characters? */
    for(m = 0; m < length; ++m) {
        if(bdata[m] != BASE64_PAD64 && base64_suffix_map[bdata[m]] == (char)255)
            return 0;
    }
    
    /* Account the output size. */
    if(bdata[length - 1] ==  '=')  padnum = 1;
    if(bdata[length - 1] == '=' && bdata[length - 2] ==  '=') padnum = 2;
    retsize = (length - 4) - (length - 4) / 4 + (3 - padnum);
    assert(retsize <= comm_base64_decode_length(length));
    
    if(retsize > size)
        return 0;
    
    /* Begging to decode. */
    for(m = 0; m < length; m += 4) {
        *pos = cmove_bits(base64_suffix_map[*bdata], 2, 0) + cmove_bits(base64_suffix_map[*(bdata + 1)], 0, 4);
        if(m == length - 4 && padnum != 0) {  /* Only deal with last four bits. */
            if(padnum == 1)   /* Have one pad characters, only two availability characters. */
                *(pos + 1) = cmove_bits(base64_suffix_map[*(bdata + 1)], 4, 0) + cmove_bits(base64_suffix_map[*(bdata + 2)], 0, 2);
            /*
             Have two pad characters, only two availability characters.
             if(padnum == 2) { 
             }
             */
            pos += 3 - padnum;
        } else {
            *(pos + 1) = cmove_bits(base64_suffix_map[*(bdata + 1)], 4, 0) + cmove_bits(base64_suffix_map[*(bdata + 2)], 0, 2);
            *(pos + 2) = cmove_bits(base64_suffix_map[*(bdata + 2)], 6, 0) + base64_suffix_map[*(bdata + 3)];
            pos += 3;
        }
        bdata += 4;
    }
    
    if(retsize < size)
        buffer[retsize] = 0;
    
LEND:
    return retsize;
}