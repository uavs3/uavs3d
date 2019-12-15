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
#ifndef __SAO_ARM64_H__
#define __SAO_ARM64_H__


void uavs3d_sao_eo_0_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height, pel* mask, int bit_depth);
void uavs3d_sao_eo_90_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width, int bit_depth);
void uavs3d_sao_eo_135_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn);
void uavs3d_sao_eo_45_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn);
void uavs3d_sao_bo_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int *band_ids, int mb_width, int mb_height, int bit_depth);

void uavs3d_sao_eo_0_chroma_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height, pel* mask, int bit_depth);
void uavs3d_sao_eo_90_chroma_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width, int bit_depth);
void uavs3d_sao_eo_135_chroma_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn);
void uavs3d_sao_eo_45_chroma_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn);
void uavs3d_sao_bo_chroma_arm64(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int *band_ids, int mb_width, int mb_height, int bit_depth);

#endif
#endif
