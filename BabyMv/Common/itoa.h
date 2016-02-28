//
//  itoa.h
//  common
//
//  Created by Zhang Yuanqing on 12-7-8.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#ifndef common_itoa_h
#define common_itoa_h

__BEGIN_DECLS

char * itoa(int value, char *string, int radix);
char * ltoa(long value, char *string, int radix);
char * ultoa(unsigned long value, char *string, int radix);

__END_DECLS

#endif
