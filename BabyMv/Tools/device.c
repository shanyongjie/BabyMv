//
//  device.cpp
//  KWPlayer
//
//  Created by Zhang Yuanqing on 12-6-19.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include <stdio.h>
#include <malloc/malloc.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "utility.h"
#include "device.h"

// Get the original MAC address as 6 bytes
// return 0 if succeed, nozero if any error occured.
int GetMacAddress(char szMacAddr[6])
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;              
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) 
    {
        fprintf(stderr, "Error: if_nametoindex failure\n");
        return 0;
    }
    
    // Get the size of the data available (store in len)
    if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) 
    {
        fprintf(stderr, "sysctl mgmtInfoBase failure\n");
        return 0;
    }
    
    // Alloc memory based on above call
    if ((msgBuffer = (char*)alloca(length)) == NULL)
    {
        fprintf(stderr, "buffer allocation failure\n");
        return 0;
    }
    
    // Get system information, store in buffer
    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        fprintf(stderr, "sysctl msgBuffer failure\n");
        return 0;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);

    memcpy(szMacAddr, macAddress, 6);
    
    return 1;
}

// return formatted MAC address, like: XX:XX:XX:YY:YY:YY, 17 charactors
const char* GetMacAddressString(char szMacAddr[18])
{
    char macAddress[6] = { 0 };
    GetMacAddress(macAddress);

    // Read from char array into a string object, into traditional Mac address format
    snprintf(szMacAddr, 18, "%02X:%02X:%02X:%02X:%02X:%02X", 
                                  (unsigned char)macAddress[0], (unsigned char)macAddress[1], (unsigned char)macAddress[2], 
                                  (unsigned char)macAddress[3], (unsigned char)macAddress[4], (unsigned char)macAddress[5]);
#if defined (DEBUG) || defined (_DEBUG)
    fprintf(stdout, "Mac Address: %s\n", szMacAddr);
#endif
    return szMacAddr;
}

// return formatted MAC address, like: XXXXXXYYYYYY, 12 charactors
const char* GetMacAddressHexString(char szMacAddr[16])
{
    char macAddress[6] = { 0 };
    GetMacAddress(macAddress);
    
    // Read from char array into a string object, into traditional Mac address format
    GetHexString(szMacAddr, macAddress, 6);
#if defined (DEBUG) || defined (_DEBUG)
    fprintf(stdout, "Mac Address Hex: %s\n", szMacAddr);
#endif
    return szMacAddr;
}
