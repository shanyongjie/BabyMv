#ifndef _NS_AUTO_LOCK_H__
#define _NS_AUTO_LOCK_H__

#pragma once

#import <CoreFoundation/CoreFoundation.h>

class CNSAutoLock
{
public:
	inline CNSAutoLock(bool bRecursive = true)
	{
        m_nsLock = bRecursive ? [[NSRecursiveLock alloc] init] : [[NSLock alloc] init];
        [m_nsLock lock];
	}
	inline explicit CNSAutoLock(NSLock* lock)
	{
        assert(lock);
#if ! __has_feature(objc_arc)
        m_nsLock = [lock retain];
#else
        m_nsLock = lock;
#endif
        [m_nsLock lock];
	}
	inline explicit CNSAutoLock(NSConditionLock* lock)
	{
        assert(lock);
#if ! __has_feature(objc_arc)
        m_nsLock = [lock retain];
#else
        m_nsLock = lock;
#endif
        [m_nsLock lock];
	}
	inline explicit CNSAutoLock(NSRecursiveLock* lock)
	{
        assert(lock);
#if ! __has_feature(objc_arc)
        m_nsLock = [lock retain];
#else
        m_nsLock = lock;
#endif
        [m_nsLock lock];
	}

	inline ~CNSAutoLock()
	{
        [m_nsLock unlock];
#if ! __has_feature(objc_arc)
		[(id)m_nsLock release];
#else
        m_nsLock = nil;
#endif
	}

private:
	__strong id<NSLocking> m_nsLock;
};

#endif	// ifndef _NS_AUTO_LOCK_H__
