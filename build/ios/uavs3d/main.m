/**************************************************************************************
 * Copyright (c) 2018-2020 ["Peking University Shenzhen Graduate School",
 *   "Peng Cheng Laboratory", and "Guangdong Bohua UHD Innovation Corporation"]
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *    This product includes software developed by the <organization>.
 * 4. Neither the name of the <organization> nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
