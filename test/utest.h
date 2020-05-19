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
 *    This product includes the software uAVS3d developed by
 *    Peking University Shenzhen Graduate School, Peng Cheng Laboratory
 *    and Guangdong Bohua UHD Innovation Corporation.
 * 4. Neither the name of the organizations (Peking University Shenzhen Graduate School,
 *    Peng Cheng Laboratory and Guangdong Bohua UHD Innovation Corporation) nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * For more information, contact us at rgwang@pkusz.edu.cn.
 **************************************************************************************/

#ifndef __UTEST_H__
#define __UTEST_H__

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "../source/decoder/uavs3d.h"

/* print function ************************************************************/
//#if defined(__ANDROID__)
//#include <android/log.h>
//#define LOGE(format, ...)  __android_log_print(ANDROID_LOG_ERROR, "(>_<)", format, ##__VA_ARGS__)
//#define LOGI(format, ...)  __android_log_print(ANDROID_LOG_INFO,  "(=_=)", format, ##__VA_ARGS__)

//#define print(args...) LOGI(args)
//#elif defined(__GNUC__)
#if defined(__GNUC__)
#define print(args...) printf(args)
#else
#define print(args, ...) printf(args, __VA_ARGS__)
#endif

#define LOG_LVL_0                  0
#define LOG_LVL_1                  1
#define LOG_LVL_2                  2

static int cfg_log_level = 2;

#if defined(__GNUC__)
#define log_level_0(args...) {if(cfg_log_level >= LOG_LVL_0) {print(args);}}
#define log_level_1(args...) {if(cfg_log_level >= LOG_LVL_1) {print(args);}}
#define log_level_2(args...) {if(cfg_log_level >= LOG_LVL_2) {print(args);}}
#else
#define log_level_0(args,...) {if(cfg_log_level >= LOG_LVL_0){print(args,__VA_ARGS__);}}
#define log_level_1(args,...) {if(cfg_log_level >= LOG_LVL_1){print(args,__VA_ARGS__);}}
#define log_level_2(args,...) {if(cfg_log_level >= LOG_LVL_2){print(args,__VA_ARGS__);}}
#endif
/****************************************************************************/
#if defined(WIN32) || defined(WIN64)
#include <windows.h>

#define TIME_SCALE    1
#define get_time() GetTickCount()

/****************************************************************************/
#elif defined(__GNUC__) || defined(ANDROID)
#include <time.h>
#include <sys/time.h>

#define TIME_SCALE   10

static long long get_time(void)
{
    struct timeval t;
    gettimeofday(&t, NULL);
    return t.tv_sec*10000L + t.tv_usec/100L;
}
#endif


static long long app_get_time_dur(long long start) 
{
    return get_time() - start;
}

#define SCALE_TIME(clk) ((int)((clk + (TIME_SCALE/2))/TIME_SCALE))

#if defined(__APPLE__) && (defined(__arm64__) || defined(__ARM_NEON__))
int uavs3d_decode_sample(int argc, const char **argv);
#endif

#endif /* __APP_UTIL_H__ */
