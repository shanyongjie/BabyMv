/*
 *  AutoPtr.h
 *  KWPlayer
 *
 *  Created by mistyzyq on 11-9-17.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#ifndef _AUTO_POINTER_H__
#define _AUTO_POINTER_H__

#include <libxml/parser.h>

class CAutoXmlCharPtr
{
public:	
	CAutoXmlCharPtr(xmlChar* ptr = NULL)
	: m_ptr(ptr)
	{}
	
	~CAutoXmlCharPtr()
	{
		Free();
	}
	
	CAutoXmlCharPtr& operator=(xmlChar* ptr)
	{
		if (m_ptr != ptr) 
		{				
			if (m_ptr)
				xmlFree(m_ptr);
			m_ptr = ptr;
		}
		return *this;
	}
	
	operator const char*()
	{
		return (const char*)m_ptr;
	}
	
	xmlChar* GetPtr() const
	{
		return m_ptr;
	}
	
	void Free()
	{
		if (m_ptr)
		{
			xmlFree(m_ptr);
			m_ptr = NULL;
		}
	}
	
private:
	xmlChar*  m_ptr;
};

#endif	// _AUTO_POINTER_H__