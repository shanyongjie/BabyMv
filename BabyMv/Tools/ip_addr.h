#if !defined(_IP_ADDR_H_INCLUDED_)
#define _IP_ADDR_H_INCLUDED_

#include <string>
#include <arpa/inet.h>
#include <sys/socket.h>

class ip_addr : public sockaddr
{
public:
	ip_addr(unsigned char b1 = 0, unsigned char b2 = 0, unsigned char b3 = 0, unsigned char b4 = 0, unsigned short port = 0);
	ip_addr(const sockaddr_in& sain);
	ip_addr(const char* ip, ushort port);
	ip_addr(const char* szAddr);  /* ip:port */
	ip_addr(const std::string& _str_addr); /* ip:port */

	~ip_addr(){}

	operator sockaddr*(){return this;}
	operator sockaddr_in*(){return (sockaddr_in*)this;}

	const std::string ToStringIPv4() const;
};


#endif //_IP_ADDR_H_INCLUDED_
