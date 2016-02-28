//
//  device.h
//  KWPlayer
//
//  Created by Zhang Yuanqing on 12-6-19.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#ifndef _DEVICE_H__
#define _DEVICE_H__

/**
 * http://mobiledevelopertips.com/device/determine-mac-address.html
 * 
 * The MAC (Media Access Control) address is an identifier that is associated with 
 * a network adapter and uniquely identifies a device on a network. A MAC address 
 * consists of 12 hexadecimal numbers, typically formatted as follows
 * XX:XX:XX:YY:YY:YY
 * 
 * The XX values in a MAC address identify the manufacturer, the YY values are the 
 * serial number assigned to the network adapter.
 * 
 * The MAC address can be useful if you need a way to uniquely identify a device – 
 * this can be used as a substitute for the UDID value that is now deprecated in 
 * iOS 5 and greater.
 */

__BEGIN_DECLS

// Get the original MAC address as 6 bytes
// return nonzero value if succeed, 0 if any error occured.
int GetMacAddress(char szMacAddr[6]);

// return formatted MAC address, like: XX:XX:XX:YY:YY:YY, 17 charactors
const char* GetMacAddressString(char szMacAddr[18]);

// return formatted MAC address, like: xxxxxxyyyyyy, 12 charactors
const char* GetMacAddressHexString(char szMacAddr[16]);

__END_DECLS

#endif
