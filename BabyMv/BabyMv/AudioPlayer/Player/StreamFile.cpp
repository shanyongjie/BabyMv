#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <algorithm>
#include "StreamFile.h"

#pragma warning (disable: 4996)

#define NOERROR         0

#define S_OK 0

#define E_OUTOFMEMORY   (-1)

#define SUCCEEDED(result) ((int)(result) >= 0)
#define FAILED(result) ((int)(result) < 0)

static unsigned int _get_file_size(FILE* fp)
{
    long size = -1;
    if (fp)
    {
        long cursor = ftell(fp);
        if (0 == fseek(fp, 0, SEEK_END))
            size = ftell(fp);
        fseek(fp, cursor, SEEK_SET);
    }
    return size;
}

////////////////////////////////////////////////////////////////////////////////
// CStreamFile class. buffered interface file only reader now

CStreamFile::CStreamFile()
	: m_fpFile(NULL)
    , m_cbFileSize(0)
    , m_cbDataAvailable(0)
    , m_bBuffering(false)
    , m_bFailed(false)
	, m_error(0)
{
}

CStreamFile::~CStreamFile()
{
	CloseFile();
}

// cbFileSize is the size of all available data, not the real file size.
// StreamFile will not reach to end if bBuffering is true, until user set bBuffering to false and feof() is reached.
bool CStreamFile::OpenFile(const char* strFilePath, unsigned int cbFileSize /*= AUTO_FILE_SIZE*/)
{
	CAutoLock lock(m_lock);
	if(m_fpFile)
		CloseFile();
	assert(strFilePath != NULL);
    
	m_fpFile = fopen(strFilePath, "rb");
	if(m_fpFile == NULL) {
		return false;
	}
    setvbuf(m_fpFile, NULL, _IONBF, 0);

	m_strFile = strFilePath;
    
	m_cbFileSize = (cbFileSize != AUTO_FILE_SIZE) ? cbFileSize : _get_file_size(m_fpFile);

    m_bBuffering = false;   // default is local file.
    m_bFailed = false;
    m_cbDataAvailable = std::min(m_cbFileSize, (unsigned int)_get_file_size(m_fpFile));
    assert(m_cbDataAvailable != -1);

	m_error = 0;
    
	return true;
}

bool CStreamFile::CloseFile()
{
	CAutoLock lock(m_lock);
	if(m_fpFile) {
		fclose(m_fpFile);
		m_fpFile = NULL;
	}

    m_cbDataAvailable = 0;
	m_cbFileSize = 0;
	m_strFile.clear();
    
    m_bBuffering = false;
    m_bFailed = false;
	m_error = 0;

	return true;
}

unsigned int CStreamFile::Seek(int cbOffset, int flag)
{
	CAutoLock lock(m_lock);

    unsigned int cur = ftell(m_fpFile);
    if (flag == SEEK_SET)
    {
        if (cbOffset > m_cbDataAvailable)
            return 1;
        if (0 != fseek(m_fpFile, cbOffset, SEEK_SET))
            return 1;
    }
    else if (flag == SEEK_CUR)
    {
        if (cur + cbOffset > m_cbDataAvailable)
            return 1;
        if (0 != fseek(m_fpFile, cbOffset, SEEK_CUR))
            return 1;
    }
    else if (flag == SEEK_END)
    {
        if (m_cbFileSize == AUTO_FILE_SIZE) {
            if (IsBuffering())  // unknow file size, can not seek from end
                return 1;
            else {
                if (0 != fseek(m_fpFile, cbOffset, SEEK_END))   // default operation as normal file
                    return 1;
            }

        } else {
            if (m_cbFileSize - cbOffset > m_cbDataAvailable)    // this will seek to any unuseable data, cancel it.
                return 1;
            else {
                if (0 != fseek(m_fpFile, m_cbFileSize - cbOffset, SEEK_SET))
                    return 1;
            }
        }
    }
    else
    {
        assert(false);
        return 1;
    }
    
    return 0;
}

// Read file data from the internal buffer, or from the file directly if there's not enough data in the internal buffer.
// The return value indicates the count of data in byte.
// If an error occured, it return (unsigned int)-1, and the GetError() could return the error number..
unsigned int CStreamFile::Read(void* pbBuffer, unsigned int cbSize)
{
	if(cbSize == 0)
		return 0;
	assert(pbBuffer != NULL);

	CAutoLock lock(m_lock);
    
	if(!IsOpen() || IsEof())
		return 0;

    unsigned int cursor = (unsigned int)ftell(m_fpFile);
    unsigned int cbToRead = std::min((int)cbSize, (int)(m_cbDataAvailable - cursor));
    fflush(m_fpFile);
    //printf("cbToRead : %u\n",cbToRead);
	unsigned int cbRead = (unsigned int)fread(pbBuffer, 1, cbToRead, m_fpFile);

	if(cbRead < cbToRead && !IsEof())
        m_error = ferror(m_fpFile);

	return cbRead;
}

const char* CStreamFile::GetFilePath() const
{
	CAutoLock lock(m_lock);
    return m_strFile.c_str();
}

// Only a buffering file could change the file size dynamicly.
unsigned int CStreamFile::SetFileSize(unsigned int cbSize)
{
	CAutoLock lock(m_lock);
    assert(m_bBuffering);
	return (m_cbFileSize = cbSize);
}

unsigned int CStreamFile::GetFileSize() const
{
	CAutoLock lock(m_lock);
    return m_cbFileSize;
}

unsigned int CStreamFile::GetFilePos() const
{
	CAutoLock lock(m_lock);
	return (unsigned int)ftell(m_fpFile);
}

bool CStreamFile::SetBuffering(bool buffering, unsigned int cbDataAvailable /*= AUTO_FILE_SIZE*/)
{
	CAutoLock lock(m_lock);
    if (buffering)
    {
        SetAvailableDataSize(cbDataAvailable);
        m_bFailed = false;
    }
    else
    {
        if (m_cbFileSize == AUTO_FILE_SIZE)
            m_cbFileSize = (unsigned int)_get_file_size(m_fpFile);
        
        if (cbDataAvailable == AUTO_FILE_SIZE)
            m_cbDataAvailable = m_cbFileSize;
        else
            m_cbDataAvailable = cbDataAvailable;
        
        if (m_bBuffering && m_cbDataAvailable < m_cbFileSize)
            m_bFailed = true;
        else
            m_bFailed = false;
    }
    m_bBuffering = buffering;
    return true;
}

bool CStreamFile::SetAvailableDataSize(unsigned int cbDataAvailable)
{
	CAutoLock lock(m_lock);
    assert(cbDataAvailable <= m_cbFileSize);
    m_cbDataAvailable = cbDataAvailable;
    return true;
}

unsigned int CStreamFile::GetAvalilableDataSize() const
{
    CAutoLock lock(m_lock);
    return m_cbDataAvailable;
}

bool CStreamFile::IsBufferingReady(unsigned int cbDataRequired) const
{
    CAutoLock lock(m_lock);
    if (!m_fpFile)
        return false;
    if (m_cbDataAvailable >= m_cbFileSize)
        return true;
    unsigned int cursor = (unsigned int)ftell(m_fpFile);
    return (bool)(m_cbDataAvailable - cursor >= cbDataRequired);
}

float CStreamFile::GetBufferingRate(unsigned int cbDataRequired) const
{
#if 1
    CAutoLock lock(m_lock);
    if (!m_cbDataAvailable || !m_cbFileSize)
        return 0.0;
    unsigned int cursor = 0;
    if (m_fpFile)
        cursor = (unsigned int)ftell(m_fpFile);
    float rate = (float)(m_cbDataAvailable - cursor) / cbDataRequired;
    if (rate > 1.0)
        rate = 1.0;
    return rate;
#else
    CAutoLock lock(m_lock);
    if (!m_cbDataAvailable || !m_cbFileSize)
        return 0.0;
    unsigned int cursor = 0;
    if (m_fpFile)
        cursor = (unsigned int)ftell(m_fpFile);
    float rate = (float)(m_cbDataAvailable - cursor) / cbDataRequired;
    if (cursor != 0 && rate < 1.0) {
        rate += 0.5;
    }
    if (rate > 1.0)
        rate = 1.0;
    return rate;
#endif
}

float CStreamFile::GetBufferingProgress() const
{
    if ((int)m_cbFileSize <= 0)
        return 0.f;
    return (double)m_cbDataAvailable / m_cbFileSize;
}

bool CStreamFile::IsOpen() const
{
	CAutoLock lock(m_lock);
	return (bool)(m_fpFile != NULL);
}

bool CStreamFile::IsEof() const
{
	CAutoLock lock(m_lock);

    if (!IsOpen()) {
        assert(false);
        return true;
    }

    unsigned int cursor = ftell(m_fpFile);
    bool eof = feof(m_fpFile);

    assert(m_cbDataAvailable <= m_cbFileSize);
    if (m_bBuffering)
    {
        return false;
    }
    else
    {
        assert(m_cbFileSize != AUTO_FILE_SIZE);
        if (eof && cursor < m_cbFileSize)
        {
            assert(false);  // user setted size is larger than the real file size!
        }
        return eof || cursor >= m_cbDataAvailable;
    }
}

bool CStreamFile::IsBuffering() const
{
	CAutoLock lock(m_lock);
	return m_bBuffering;
}

bool CStreamFile::IsBufferingFailed() const
{
	CAutoLock lock(m_lock);
	return m_bFailed;
}

int CStreamFile::GetError() const
{
	CAutoLock lock(m_lock);
	return m_error;
}