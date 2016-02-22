#include "ip_addr.h"
#include <stdlib.h>

ip_addr::ip_addr(
		unsigned char b1, 
		unsigned char b2, 
		unsigned char b3, 
		unsigned char b4, 
		unsigned short port)
{
	sockaddr_in& addr=*((sockaddr_in*)this);
	addr.sin_family=AF_INET;
	unsigned char* pb = (unsigned char*)&addr.sin_addr;
	*pb++ = b1;
	*pb++ = b2;
	*pb++ = b3;
	*pb++ = b4;
	addr.sin_port=htons(port);
}

ip_addr::ip_addr(const sockaddr_in& sain)
{
	sockaddr_in& addr=*((sockaddr_in*)this);
	addr.sin_family=AF_INET;
	addr = sain;
}

ip_addr::ip_addr(const char* ip, ushort port)
{
	sockaddr_in& addr = *((sockaddr_in*)this);
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr(ip);
	addr.sin_port = htons(port);
}

ip_addr::ip_addr(const std::string& _str_addr)
{
	std::string b[5];
	int bn=0;
	
	for(int i=0; i<_str_addr.size(); i++){
		if(_str_addr[i]=='.' || _str_addr[i]==':'){
			bn++;
			if(bn>4)break;
		}else{
			b[bn]+=_str_addr[i];
		}
	}

	sockaddr_in& addr=*((sockaddr_in*)this);
	addr.sin_family=AF_INET;
	unsigned char* pb = (unsigned char*)&addr.sin_addr;
	*pb++ = (u_char)atol(b[0].c_str());
	*pb++ = (u_char)atol(b[1].c_str());
	*pb++ = (u_char)atol(b[2].c_str());
	*pb++ = (u_char)atol(b[3].c_str());
	addr.sin_port = htons((u_short)atol(b[4].c_str()));
}

ip_addr::ip_addr(const char* szAddr)
{
	std::string strip;
	if(szAddr)
	{
		for(int i = 0; i < (int)strlen(szAddr); i++)
		{
			strip += szAddr[i];
		}

		*this = ip_addr(strip);
	}
}

const std::string ip_addr::ToStringIPv4() const
{
	sockaddr_in& addr=*((sockaddr_in*)this);
	
	char temp[256];
	const unsigned char* pb = (const unsigned char*)&addr.sin_addr;
	sprintf(temp, "%u.%u.%u.%u:%u",
			pb[0],
			pb[1],
			pb[2],
			pb[3],
			ntohs(addr.sin_port));

	return std::string(temp);
}
