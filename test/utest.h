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
