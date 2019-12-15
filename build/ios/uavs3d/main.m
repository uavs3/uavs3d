/**************************************************************************************
* Copyright (C) 2018-2019 uavs3d project
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the Open-Intelligence Open Source License V1.1.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* Open-Intelligence Open Source License V1.1 for more details.
*
* You should have received a copy of the Open-Intelligence Open Source License V1.1
* along with this program; if not, you can download it on:
* http://www.aitisa.org.cn/uploadfile/2018/0910/20180910031548314.pdf
*
* For more information, contact us at rgwang@pkusz.edu.cn.
**************************************************************************************/

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "utest.h"

#define SPEED_TEST 0

#define INFILE_NUM 18

char infile[INFILE_NUM][128]={ // base dir: app/documents
    "abr_hpm4.0/PeopleOnStreet_2560x1600_30_7000kbps.avs3",
    "abr_hpm4.0/Traffic_2560x1600_30_7000kbps.avs3",
    "abr_hpm4.0/BasketballDrive_1920x1080_50_2000kbps.avs3",
    "abr_hpm4.0/BQTerrace_1920x1080_60_2000kbps.avs3",
    "abr_hpm4.0/Cactus_1920x1080_50_2000kbps.avs3",
    "abr_hpm4.0/Kimono_1920x1080_24_2000kbps.avs3",
    "abr_hpm4.0/ParkScene_1920x1080_24_2000kbps.avs3",
    "abr_hpm4.0/FourPeople_1280x720_60_1000kbps.avs3",
    "abr_hpm4.0/Johnny_1280x720_60_1000kbps.avs3",
    "abr_hpm4.0/KristenAndSara_1280x720_60_1000kbps.avs3",
    "abr_hpm4.0/BQMall_832x480_60_700kbps.avs3",
    "abr_hpm4.0/BasketballDrill_832x480_50_700kbps.avs3",
    "abr_hpm4.0/PartyScene_832x480_50_700kbps.avs3",
    "abr_hpm4.0/RaceHorses_832x480_30_700kbps.avs3",
    "abr_hpm4.0/BQSquare_416x240_60_300kbps.avs3",
    "abr_hpm4.0/BasketballPass_416x240_50_300kbps.avs3",
    "abr_hpm4.0/BlowingBubbles_416x240_50_300kbps.avs3",
    "abr_hpm4.0/RaceHorses_416x240_30_300kbps.avs3"
};

#define THREADS_NUM "1"
#if SPEED_TEST
#define LOG_LEVEL "1"
#define ENABLE_MD5_CHECK 0
#else
#define LOG_LEVEL "2"
#define ENABLE_MD5_CHECK 1
#endif

#define ENABLE_WRITE_YUV 0

#define BASE_ARGC 7
#if ENABLE_MD5_CHECK
#define MD5_ARGC 2
#else
#define MD5_ARGC 0
#endif

#if ENABLE_WRITE_YUV
#define OUTPUT_ARGC 2
#else
#define OUTPUT_ARGC 0
#endif

int main(int argc, char * argv[]) {
    NSString* NsInputFileName, *NsInputFileFullName, *NsOutputFileName, *NsOutputFileFullName;
    char InputFileName[256], DecFileName[256];
    int i;
    unsigned long strLen;
    
    NSString * NsDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    char* uavs3d_argv[BASE_ARGC + MD5_ARGC + OUTPUT_ARGC];
    char decfile[64] = "dec.yuv";
    int uavs3d_argc = BASE_ARGC + MD5_ARGC + OUTPUT_ARGC;
    int j = 0;
    
    for(i = 0; i < INFILE_NUM; i++)
    {
        j = 0;
        NsInputFileName = [[NSString alloc]initWithCString:(const char *) (infile[i]) encoding:NSUTF8StringEncoding];
        NsInputFileFullName = [NSString stringWithFormat:@"%@/%@", NsDocuments, NsInputFileName];
        strLen = [NsInputFileFullName length];
        [NsInputFileFullName getCString:InputFileName maxLength:strLen+1 encoding:NSUTF8StringEncoding];
        printf("stream: %s\n", infile[i]);
        
        NsOutputFileName = [[NSString alloc]initWithCString:(const char *) (decfile) encoding:NSUTF8StringEncoding];
        NsOutputFileFullName = [NSString stringWithFormat:@"%@/%@", NsDocuments, NsOutputFileName];
        strLen = [NsOutputFileFullName length];
        [NsOutputFileFullName getCString:DecFileName maxLength:strLen+1 encoding:NSUTF8StringEncoding];
        
        uavs3d_argv[j++] = "uavs3d";
        uavs3d_argv[j++] = "-i";
        uavs3d_argv[j++] = InputFileName;
        uavs3d_argv[j++] = "-t";
        uavs3d_argv[j++] = THREADS_NUM;
        uavs3d_argv[j++] = "-l";
        uavs3d_argv[j++] = LOG_LEVEL;
#if ENABLE_MD5_CHECK
        uavs3d_argv[j++] = "-s";
        uavs3d_argv[j++] = "1";
#endif
#if ENABLE_WRITE_YUV
        uavs3d_argv[j++] = "-o";
        uavs3d_argv[j++] = DecFileName;
#endif
        uavs3d_decode_sample(uavs3d_argc, uavs3d_argv);
    }
    return 0;
}
