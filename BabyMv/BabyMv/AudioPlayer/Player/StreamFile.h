#ifndef _BUFF_FILE_H__
#define _BUFF_FILE_H__

#pragma once

#include <stdio.h>
#include <string>
#include <pthread.h>
#include "AutoLock.h"

// An AUTO_FILE_SIZE file will not not reach the end until the owner set the buffering to false, and the of file is reached.
#define AUTO_FILE_SIZE		((unsigned int)(-1))


class CStreamFile
{
public:
	CStreamFile();
	virtual ~CStreamFile();

public:
    // For a buffering file (online), cbFileSize is the final size of file after buffering completed, that means, the 
    // real size of file may be less than cbFileSize before buffering is completed.
    // For a local file, who's file size is determinated and should not be changed, the cbFileSize must be equal 
    // or less than the real size of file, or use AUTO_FILE_SIZE instead, this will use the real size of file automaticlly.
    //
    // For a buffering file, this file will not reach end if cbFileSize is AUTO_FILE_SIZE, until user set the buffering 
    // state to false, and feof() is reached, or file reading pointer is larger than cbFileSize if this value is changed
    // then change buffering state coinstantaneous.
	bool OpenFile(const char* strFilePath, unsigned int cbFileSize = AUTO_FILE_SIZE);
	bool CloseFile();

    unsigned int Seek(int cbOffset, int flag);  // use flag just like origin in fseek
    
	unsigned int Read(void* pbBuffer, unsigned int cbSize);

public:
    const char* GetFilePath() const;
    
    unsigned int GetFileSize() const;
    
    // Only a buffering file could change the file size dynamicly.
	unsigned int SetFileSize(unsigned int cbSize);
	
	unsigned int GetFilePos() const;
    
    bool SetBuffering(bool buffering, unsigned int cbDataAvailable = AUTO_FILE_SIZE);
    
    bool SetAvailableDataSize(unsigned int cbDataAvailable);
    unsigned int GetAvalilableDataSize() const;
    
    bool IsBufferingReady(unsigned int cbDataRequired) const;
    float GetBufferingRate(unsigned int cbDataRequired) const;
    
    float GetBufferingProgress() const;
    
public:
	virtual bool IsOpen() const;
    
	virtual bool IsEof() const;

	virtual bool IsBuffering() const;
    
    virtual bool IsBufferingFailed() const;

	virtual int GetError() const;
    
protected:
	// fp is the file opened for reading associated with that bfile.
    std::string     m_strFile;
	FILE*           m_fpFile;
	unsigned int	m_cbFileSize;
    unsigned int    m_cbDataAvailable;

    bool    m_bBuffering;
    bool    m_bFailed;
	int		m_error;

	mutable CLock	m_lock;
};

#endif // ifndef _BUFF_FILE_H__