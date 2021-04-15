//
//  amrFileCodecEM.h
//  amrDemoForiOS
//
//  Created by Tang Xiaoping on 9/27/11.
//  Copyright 2011 test. All rights reserved.
//
#ifndef amrFileCodecEM_h
#define amrFileCodecEM_h
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define AMR_MAGIC_NUMBER "#!AMR\n"
#define MP3_MAGIC_NUMBER "ID3"

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160  ； 44100.0*0.02=
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

typedef struct
{
	char chChunkID[4];
	int nChunkSize;
}EM_XCHUNKHEADER;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
}EM_WAVEFORMAT;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
	short nExSize;
}EM_WAVEFORMATX;

typedef struct
{
	char chRiffID[4];
	int nRiffSize;
	char chRiffFormat[4];
}EM_RIFFHEADER;

typedef struct
{
	char chFmtID[4];
	int nFmtSize;
	EM_WAVEFORMAT wf;
}EM_FMTBLOCK;

//是否是 MP3文件
int isMP3File(const char *filePath);

//是否是AMR 文件
int isAMRFile(const char *filePath);
#endif
