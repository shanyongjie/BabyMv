/*
 *  base64.h
 *  KWPlayer
 *
 *  Created by YeeLion on 11-2-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#ifndef _KUWO_BASE64_H__
#define _KUWO_BASE64_H__

#ifdef __cplusplus
extern "C" {
#endif

    // QQ Open API包含同名的base64_encode/decode函数，会导致连接错误程序崩溃，因而改名
int comm_base64_encode_length(int length);
int comm_base64_encode(const char *data, int length, char* buffer, int size);

int comm_base64_decode_length(int length);
int comm_base64_decode(const char *bdata, int length, char* buffer, int size);

#ifdef __cplusplus
}
#endif

#endif // _KUWO_BASE64_H__