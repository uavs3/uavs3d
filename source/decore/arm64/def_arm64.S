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

#if defined(__ANDROID__)
.macro function name
    .text
    .align 4
    .global \name
    .type   \name, %function
    \name:
.endm

#if defined(__aarch64__) && !defined(__arm64__)
#define __arm64__ 1
#endif
#elif defined(__APPLE__)
.macro function name
    .text
    .align 4
    .global _\name
    _\name:
.endm
#endif

#define COMPILE_10BIT 0
