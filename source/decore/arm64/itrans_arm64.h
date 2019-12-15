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

#include "arm64.h"
#if defined(__arm64__)
#ifndef __ITRANS_ARM64_H__
#define __ITRANS_ARM64_H__

void dct2_butterfly_h4_arm64(s16* src, s16* dst, int width, int shift, int bit_depth);
void dct2_butterfly_h8_arm64(s16* src, int i_src, s16* dst, int width, int shift, int bit_depth);
void dct2_butterfly_h16_arm64(s16* src, int i_src, s16* dst, int width, int shift, int bit_depth);
void dct2_butterfly_h32_arm64(s16* src, int i_src, s16* dst, int width, int shift, int bit_depth);
void dct2_butterfly_h64_arm64(s16* src, int i_src, s16* dst, int width, int shift, int bit_depth);

#endif
#endif
