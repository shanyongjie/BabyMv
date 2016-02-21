#ifndef _AUTO_LOCK_H__
#define _AUTO_LOCK_H__

#pragma once

#include <assert.h>
#include <pthread.h>

class CLock
{
public:	
	CLock( bool bRecursive = true )
	{
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, bRecursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_NORMAL);
		pthread_mutex_init( &m_mutex, &attr );
	}
    
	~CLock()
	{
		pthread_mutex_destroy( &m_mutex );
	}
    
	void Lock()
	{
		pthread_mutex_lock( &m_mutex );
	}
    
	bool TryLock()
	{
		return !pthread_mutex_trylock( &m_mutex );
	}
    
	void Unlock()
	{
		pthread_mutex_unlock( &m_mutex );
	}

#if defined (DEBUG) || defined (_DEBUG)
    void Lock(int line)
	{
        printf("Lock: %p, line %d\n", this, line);
		pthread_mutex_lock( &m_mutex );
        printf("Locked: %p, line %d\n", this, line);
	}
    
	void Unlock(int line)
	{
		pthread_mutex_unlock( &m_mutex );
        printf("Unlock: %p, line %d\n", this, line);
	}
#endif
    
private:
	pthread_mutex_t m_mutex;
};

class CAutoLock
{
public:
	CAutoLock( CLock* pLock )
	{
		assert( NULL != pLock );
#if defined (DEBUG) || defined (_DEBUG)
        m_line = 0;
#endif
		pLock->Lock();  // if Lock() is blocked, and user canceled this operation, our destroctor should not Unlock().
        m_pLock = pLock;
	}

	CAutoLock( CLock& lock )
	{
#if defined (DEBUG) || defined (_DEBUG)
        m_line = 0;
#endif
		lock.Lock();
        m_pLock = &lock;
	}

	~CAutoLock()
	{
		if( NULL != m_pLock )
            m_pLock->Unlock();
#if defined (DEBUG) || defined (_DEBUG)
        if (m_line)
            printf("Line %d, AutoLock Unlock: %p\n", m_line, m_pLock);
#endif
	}
    
#if defined (DEBUG) || defined (_DEBUG)
	CAutoLock( CLock* pLock, int line ) : m_line(line)
    {
        printf("Line %d, AutoLock: %p\n", line, pLock);
		pLock->Lock();  // if Lock() is blocked, and user canceled this operation, our destroctor should not Unlock().
        m_pLock = pLock;
    }
    
	CAutoLock( CLock& lock, int line ) : m_line(line)
    {
        printf("Line %d, AutoLock: %p\n", line, &lock);
		lock.Lock();  // if Lock() is blocked, and user canceled this operation, our destroctor should not Unlock().
        m_pLock = &lock;
    }
#endif
    
private:
	CLock* m_pLock;
#if defined (DEBUG) || defined (_DEBUG)
    int m_line;
#endif
};

#ifdef __OBJC__
#import "NSAutoLock.h"
#endif

// Uncomment this macro to track lock and autolock and lock action.
// To enable this property only in your own files, you should not uncomment this macro, 
// but noly define this macro in your implement files before this header file is included first time
//#define DEBUG_TRACK_LOCK

#if (defined (DEBUG) || defined (_DEBUG)) && defined(DEBUG_TRACK_LOCK)
#   define AutoLock(lock) CAutoLock _tmpLock(lock, __LINE__)
#   define Lock()   Lock(__LINE__)
#   define Unlock() Unlock(__LINE__)
#else
#   define AutoLock(lock) CAutoLock _tmpLock(lock)
#endif

#endif	// ifndef _AUTO_LOCK_H__
