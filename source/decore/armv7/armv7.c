/**************************************************************************************
 * Copyright (c) 2018-2022 ["Peking University Shenzhen Graduate School",
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
 * 3. Neither the name of the organizations (Peking University Shenzhen Graduate School,
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

#if defined(__arm__)
#include "armv7.h"
void uavs3d_padding_rows_luma_armv7(pel *src, int i_src, int width, int height, int start, int rows, int padh, int padv)
{
    int i;
    pel *p;
    
    start = max(start, 0);
    rows = min(rows, height - start);
    
    if (start + rows == height) {
        rows += padv;
        p = src + i_src * (height - 1);
        for (i = 1; i <= padv; i++) {
            memcpy(p + i_src * i, p, width * sizeof(pel));
        }
    }
    
    if (start == 0) {
        start = -padv;
        rows += padv;
        p = src;
        for (i = 1; i <= padv; i++) {
            memcpy(p - i_src * i, p, width * sizeof(pel));
        }
    }
    
    p = src + start * i_src;
    
    uavs3d_padding_rows_lr_armv7(p, i_src, width, rows, padh);
    
}
void uavs3d_padding_rows_chroma_armv7(pel *src, int i_src, int width, int height, int start, int rows, int padh, int padv)
{
    int i;
    pel *p;
    
    start = max(start, 0);
    rows = min(rows, height - start);
    
    if (start + rows == height) {
        rows += padv;
        p = src + i_src * (height - 1);
        for (i = 1; i <= padv; i++) {
            memcpy(p + i_src * i, p, width * sizeof(pel));
        }
    }
    
    if (start == 0) {
        start = -padv;
        rows += padv;
        p = src;
        for (i = 1; i <= padv; i++) {
            memcpy(p - i_src * i, p, width * sizeof(pel));
        }
    }
    
    p = src + start * i_src;
    
    uavs3d_padding_rows_chroma_lr_armv7(p, i_src, width, rows, padh);
    
}
void uavs3d_itrans_dct2_h4_w4_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[4 * 4];
    uavs3d_itrans_dct_butterfly_h4_armv7(src, 4, tmp, 4, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h4_armv7(tmp, 4, dst, 4, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h4_w8_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[4 * 8];
    uavs3d_itrans_dct_butterfly_h4_armv7(src, 8, tmp, 8, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h8_armv7(tmp, 4, dst, 4, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h4_w16_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[4 * 16];
    uavs3d_itrans_dct_butterfly_h4_armv7(src, 16, tmp, 16, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h16_armv7(tmp, 4, dst, 4, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h4_w32_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[4 * 32];
    uavs3d_itrans_dct_butterfly_h4_armv7(src, 32, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h32_armv7(tmp, 4, dst, 4, 20 - bit_depth, bit_depth);
}

void uavs3d_itrans_dct2_h8_w4_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[8 * 4];
    uavs3d_itrans_dct_butterfly_h8_armv7(src, 4, tmp, 4, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h4_armv7(tmp, 8, dst, 8, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h8_w8_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[8 * 8];
    uavs3d_itrans_dct_butterfly_h8_armv7(src, 8, tmp, 8, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h8_armv7(tmp, 8, dst, 8, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h8_w16_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[8 * 16];
    uavs3d_itrans_dct_butterfly_h8_armv7(src, 16, tmp, 16, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h16_armv7(tmp, 8, dst, 8, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h8_w32_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[8 * 32];
    uavs3d_itrans_dct_butterfly_h8_armv7(src, 32, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h32_armv7(tmp, 8, dst, 8, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h8_w64_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[8 * 64];
    uavs3d_itrans_dct_butterfly_h8_armv7(src, 64, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h64_armv7(tmp, 8, dst, 8, 20 - bit_depth, bit_depth);
}

void uavs3d_itrans_dct2_h16_w4_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[16 * 4];
    uavs3d_itrans_dct_butterfly_h16_armv7(src, 4, tmp, 4, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h4_armv7(tmp, 16, dst, 16, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h16_w8_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[16 * 8];
    uavs3d_itrans_dct_butterfly_h16_armv7(src, 8, tmp, 8, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h8_armv7(tmp, 16, dst, 16, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h16_w16_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[16 * 16];
    uavs3d_itrans_dct_butterfly_h16_armv7(src, 16, tmp, 16, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h16_armv7(tmp, 16, dst, 16, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h16_w32_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[16 * 32];
    uavs3d_itrans_dct_butterfly_h16_armv7(src, 32, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h32_armv7(tmp, 16, dst, 16, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h16_w64_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[16 * 64];
    uavs3d_itrans_dct_butterfly_h16_armv7(src, 64, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h64_armv7(tmp, 16, dst, 16, 20 - bit_depth, bit_depth);
}

void uavs3d_itrans_dct2_h32_w4_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[32 * 4];
    uavs3d_itrans_dct_butterfly_h32_armv7(src, 4, tmp, 4, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h4_armv7(tmp, 32, dst, 32, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h32_w8_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[32 * 8];
    uavs3d_itrans_dct_butterfly_h32_armv7(src, 8, tmp, 8, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h8_armv7(tmp, 32, dst, 32, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h32_w16_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[32 * 16];
    uavs3d_itrans_dct_butterfly_h32_armv7(src, 16, tmp, 16, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h16_armv7(tmp, 32, dst, 32, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h32_w32_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[32 * 32];
    uavs3d_itrans_dct_butterfly_h32_armv7(src, 32, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h32_armv7(tmp, 32, dst, 32, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h32_w64_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[32 * 64];
    uavs3d_itrans_dct_butterfly_h32_armv7(src, 64, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h64_armv7(tmp, 32, dst, 32, 20 - bit_depth, bit_depth);
}

void uavs3d_itrans_dct2_h64_w8_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[64 * 8];
    uavs3d_itrans_dct_butterfly_h64_armv7(src, 8, tmp, 8, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h8_armv7(tmp, 64, dst, 64, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h64_w16_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[64 * 16];
    uavs3d_itrans_dct_butterfly_h64_armv7(src, 16, tmp, 16, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h16_armv7(tmp, 64, dst, 64, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h64_w32_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[64 * 32];
    uavs3d_itrans_dct_butterfly_h64_armv7(src, 32, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h32_armv7(tmp, 64, dst, 64, 20 - bit_depth, bit_depth);
}
void uavs3d_itrans_dct2_h64_w64_armv7(s16 *src, s16 *dst, int bit_depth)
{
    s16 tmp[64 * 64];
    uavs3d_itrans_dct_butterfly_h64_armv7(src, 64, tmp, 32, 5, MAX_TX_DYNAMIC_RANGE);
    uavs3d_itrans_dct_butterfly_h64_armv7(tmp, 64, dst, 64, 20 - bit_depth, bit_depth);
}

void uavs3d_funs_init_armv7()
{
#if BIT_DEPTH == 8
    uavs3d_funs_handle.sao[ Y_C] = uavs3d_sao_on_lcu_armv7;
    uavs3d_funs_handle.sao[UV_C] = uavs3d_sao_on_lcu_chroma_armv7;
    uavs3d_funs_handle.alf[ Y_C] = uavs3d_alf_one_lcu_armv7;
    uavs3d_funs_handle.alf[UV_C] = uavs3d_alf_one_lcu_chroma_armv7;
    uavs3d_funs_handle.alf[ 2  ] = uavs3d_alf_one_lcu_one_chroma_armv7;
    uavs3d_funs_handle.deblock_luma[0] = uavs3d_deblock_ver_luma_armv7;
    uavs3d_funs_handle.deblock_luma[1] = uavs3d_deblock_hor_luma_armv7;
    uavs3d_funs_handle.deblock_chroma[0] = uavs3d_deblock_ver_chroma_armv7;
    uavs3d_funs_handle.deblock_chroma[1] = uavs3d_deblock_hor_chroma_armv7;

    uavs3d_funs_handle.ipcpy[0] = uavs3d_if_cpy_w4_armv7;
    uavs3d_funs_handle.ipcpy[1] = uavs3d_if_cpy_w8_armv7;
    uavs3d_funs_handle.ipcpy[2] = uavs3d_if_cpy_w16_armv7;
    uavs3d_funs_handle.ipcpy[3] = uavs3d_if_cpy_w32_armv7;
    uavs3d_funs_handle.ipcpy[4] = uavs3d_if_cpy_w64_armv7;
    uavs3d_funs_handle.ipcpy[5] = uavs3d_if_cpy_w128_armv7;

    uavs3d_funs_handle.ipflt[IPFILTER_H_8][0] = uavs3d_if_hor_luma_w4_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][1] = uavs3d_if_hor_luma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][2] = uavs3d_if_hor_luma_w16_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][3] = uavs3d_if_hor_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][4] = uavs3d_if_hor_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][5] = uavs3d_if_hor_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][1] = uavs3d_if_hor_chroma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][2] = uavs3d_if_hor_chroma_w16_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][3] = uavs3d_if_hor_chroma_w32_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][4] = uavs3d_if_hor_chroma_w32x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][5] = uavs3d_if_hor_chroma_w32x_armv7;

    uavs3d_funs_handle.ipflt[IPFILTER_V_8][0] = uavs3d_if_ver_luma_w4_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][1] = uavs3d_if_ver_luma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][2] = uavs3d_if_ver_luma_w16_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][3] = uavs3d_if_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][4] = uavs3d_if_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][5] = uavs3d_if_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][1] = uavs3d_if_ver_chroma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][2] = uavs3d_if_ver_chroma_w16_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][3] = uavs3d_if_ver_chroma_w32_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][4] = uavs3d_if_ver_chroma_w32x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][5] = uavs3d_if_ver_chroma_w32x_armv7;

    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][0] = uavs3d_if_hor_ver_luma_w4_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][1] = uavs3d_if_hor_ver_luma_w8_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][2] = uavs3d_if_hor_ver_luma_w16_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][3] = uavs3d_if_hor_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][4] = uavs3d_if_hor_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][5] = uavs3d_if_hor_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][1] = uavs3d_if_hor_ver_chroma_w8_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][2] = uavs3d_if_hor_ver_chroma_w16_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][3] = uavs3d_if_hor_ver_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][4] = uavs3d_if_hor_ver_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][5] = uavs3d_if_hor_ver_chroma_w16x_armv7;

    uavs3d_funs_handle.itrans_dct2[1][1] = uavs3d_itrans_dct2_h4_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[1][2] = uavs3d_itrans_dct2_h4_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[1][3] = uavs3d_itrans_dct2_h4_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[1][4] = uavs3d_itrans_dct2_h4_w32_armv7;

    uavs3d_funs_handle.itrans_dct2[2][1] = uavs3d_itrans_dct2_h8_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[2][2] = uavs3d_itrans_dct2_h8_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[2][3] = uavs3d_itrans_dct2_h8_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[2][4] = uavs3d_itrans_dct2_h8_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[2][5] = uavs3d_itrans_dct2_h8_w64_armv7;

    uavs3d_funs_handle.itrans_dct2[3][1] = uavs3d_itrans_dct2_h16_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[3][2] = uavs3d_itrans_dct2_h16_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[3][3] = uavs3d_itrans_dct2_h16_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[3][4] = uavs3d_itrans_dct2_h16_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[3][5] = uavs3d_itrans_dct2_h16_w64_armv7;

    uavs3d_funs_handle.itrans_dct2[4][1] = uavs3d_itrans_dct2_h32_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[4][2] = uavs3d_itrans_dct2_h32_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[4][3] = uavs3d_itrans_dct2_h32_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[4][4] = uavs3d_itrans_dct2_h32_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[4][5] = uavs3d_itrans_dct2_h32_w64_armv7;

    uavs3d_funs_handle.itrans_dct2[5][2] = uavs3d_itrans_dct2_h64_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[5][3] = uavs3d_itrans_dct2_h64_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[5][4] = uavs3d_itrans_dct2_h64_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[5][5] = uavs3d_itrans_dct2_h64_w64_armv7;

    uavs3d_funs_handle.itrans_dct8[0] = uavs3d_itrans_dct8_pb4_armv7;
    uavs3d_funs_handle.itrans_dct8[1] = uavs3d_itrans_dct8_pb8_armv7;
    uavs3d_funs_handle.itrans_dct8[2] = uavs3d_itrans_dct8_pb16_armv7;

    uavs3d_funs_handle.itrans_dst7[0] = uavs3d_itrans_dst7_pb4_armv7;
    uavs3d_funs_handle.itrans_dst7[1] = uavs3d_itrans_dst7_pb8_armv7;
    uavs3d_funs_handle.itrans_dst7[2] = uavs3d_itrans_dst7_pb16_armv7;

    uavs3d_funs_handle.avg_pel[0] = uavs3d_avg_pel_w4_armv7;
    uavs3d_funs_handle.avg_pel[1] = uavs3d_avg_pel_w8_armv7;
    uavs3d_funs_handle.avg_pel[2] = uavs3d_avg_pel_w16_armv7;
    uavs3d_funs_handle.avg_pel[3] = uavs3d_avg_pel_w32_armv7;
    uavs3d_funs_handle.avg_pel[4] = uavs3d_avg_pel_w64_armv7;
    uavs3d_funs_handle.avg_pel[5] = uavs3d_avg_pel_w128_armv7;

    uavs3d_funs_handle.conv_fmt_8bit = uavs3d_conv_fmt_8bit_armv7;
    uavs3d_funs_handle.padding_rows_luma = uavs3d_padding_rows_luma_armv7;
    uavs3d_funs_handle.padding_rows_chroma = uavs3d_padding_rows_chroma_armv7;
	
    uavs3d_funs_handle.intra_pred_ver  [ Y_C] = uavs3d_intra_pred_ver_armv7;
    uavs3d_funs_handle.intra_pred_hor  [ Y_C] = uavs3d_intra_pred_hor_armv7;
    uavs3d_funs_handle.intra_pred_dc   [ Y_C] = uavs3d_intra_pred_dc_armv7;
    uavs3d_funs_handle.intra_pred_plane[ Y_C] = uavs3d_intra_pred_plane_armv7;
    uavs3d_funs_handle.intra_pred_plane_ipf   = uavs3d_intra_pred_plane_ipf_armv7;
    uavs3d_funs_handle.intra_pred_bi   [ Y_C] = uavs3d_intra_pred_bi_armv7;
    uavs3d_funs_handle.intra_pred_bi_ipf      = uavs3d_intra_pred_bi_ipf_armv7;
#else
    uavs3d_funs_handle.ipcpy[0] = uavs3d_if_cpy_w4_armv7;
    uavs3d_funs_handle.ipcpy[1] = uavs3d_if_cpy_w8_armv7;
    uavs3d_funs_handle.ipcpy[2] = uavs3d_if_cpy_w16_armv7;
    uavs3d_funs_handle.ipcpy[3] = uavs3d_if_cpy_w32_armv7;
    uavs3d_funs_handle.ipcpy[4] = uavs3d_if_cpy_w64_armv7;
    uavs3d_funs_handle.ipcpy[5] = uavs3d_if_cpy_w128_armv7;

    uavs3d_funs_handle.ipflt[IPFILTER_H_8][0] = uavs3d_if_hor_luma_w4_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][1] = uavs3d_if_hor_luma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][2] = uavs3d_if_hor_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][3] = uavs3d_if_hor_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][4] = uavs3d_if_hor_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][5] = uavs3d_if_hor_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][1] = uavs3d_if_hor_chroma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][2] = uavs3d_if_hor_chroma_w16_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][3] = uavs3d_if_hor_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][4] = uavs3d_if_hor_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][5] = uavs3d_if_hor_chroma_w16x_armv7;

    uavs3d_funs_handle.ipflt[IPFILTER_V_8][0] = uavs3d_if_ver_luma_w4_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][1] = uavs3d_if_ver_luma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][2] = uavs3d_if_ver_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][3] = uavs3d_if_ver_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][4] = uavs3d_if_ver_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][5] = uavs3d_if_ver_luma_w8x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][1] = uavs3d_if_ver_chroma_w8_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][2] = uavs3d_if_ver_chroma_w16_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][3] = uavs3d_if_ver_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][4] = uavs3d_if_ver_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][5] = uavs3d_if_ver_chroma_w16x_armv7;

    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][0] = uavs3d_if_hor_ver_luma_w4_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][1] = uavs3d_if_hor_ver_luma_w8_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][2] = uavs3d_if_hor_ver_luma_w16_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][3] = uavs3d_if_hor_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][4] = uavs3d_if_hor_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][5] = uavs3d_if_hor_ver_luma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][1] = uavs3d_if_hor_ver_chroma_w8_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][2] = uavs3d_if_hor_ver_chroma_w16_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][3] = uavs3d_if_hor_ver_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][4] = uavs3d_if_hor_ver_chroma_w16x_armv7;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][5] = uavs3d_if_hor_ver_chroma_w16x_armv7;

    uavs3d_funs_handle.deblock_luma[0] = uavs3d_deblock_ver_luma_armv7;
    uavs3d_funs_handle.deblock_luma[1] = uavs3d_deblock_hor_luma_armv7;
    uavs3d_funs_handle.deblock_chroma[0] = uavs3d_deblock_ver_chroma_armv7;
    uavs3d_funs_handle.deblock_chroma[1] = uavs3d_deblock_hor_chroma_armv7;

    uavs3d_funs_handle.alf[ Y_C] = uavs3d_alf_one_lcu_armv7;
    uavs3d_funs_handle.alf[UV_C] = uavs3d_alf_one_lcu_chroma_armv7;
    uavs3d_funs_handle.alf[ 2  ] = uavs3d_alf_one_lcu_one_chroma_armv7;

    uavs3d_funs_handle.sao[ Y_C] = uavs3d_sao_on_lcu_armv7;
    uavs3d_funs_handle.sao[UV_C] = uavs3d_sao_on_lcu_chroma_armv7;

    uavs3d_funs_handle.itrans_dct2[1][1] = uavs3d_itrans_dct2_h4_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[1][2] = uavs3d_itrans_dct2_h4_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[1][3] = uavs3d_itrans_dct2_h4_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[1][4] = uavs3d_itrans_dct2_h4_w32_armv7;

    uavs3d_funs_handle.itrans_dct2[2][1] = uavs3d_itrans_dct2_h8_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[2][2] = uavs3d_itrans_dct2_h8_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[2][3] = uavs3d_itrans_dct2_h8_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[2][4] = uavs3d_itrans_dct2_h8_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[2][5] = uavs3d_itrans_dct2_h8_w64_armv7;

    uavs3d_funs_handle.itrans_dct2[3][1] = uavs3d_itrans_dct2_h16_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[3][2] = uavs3d_itrans_dct2_h16_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[3][3] = uavs3d_itrans_dct2_h16_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[3][4] = uavs3d_itrans_dct2_h16_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[3][5] = uavs3d_itrans_dct2_h16_w64_armv7;

    uavs3d_funs_handle.itrans_dct2[4][1] = uavs3d_itrans_dct2_h32_w4_armv7;
    uavs3d_funs_handle.itrans_dct2[4][2] = uavs3d_itrans_dct2_h32_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[4][3] = uavs3d_itrans_dct2_h32_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[4][4] = uavs3d_itrans_dct2_h32_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[4][5] = uavs3d_itrans_dct2_h32_w64_armv7;

    uavs3d_funs_handle.itrans_dct2[5][2] = uavs3d_itrans_dct2_h64_w8_armv7;
    uavs3d_funs_handle.itrans_dct2[5][3] = uavs3d_itrans_dct2_h64_w16_armv7;
    uavs3d_funs_handle.itrans_dct2[5][4] = uavs3d_itrans_dct2_h64_w32_armv7;
    uavs3d_funs_handle.itrans_dct2[5][5] = uavs3d_itrans_dct2_h64_w64_armv7;

    uavs3d_funs_handle.itrans_dct8[0] = uavs3d_itrans_dct8_pb4_armv7;
    uavs3d_funs_handle.itrans_dct8[1] = uavs3d_itrans_dct8_pb8_armv7;
    uavs3d_funs_handle.itrans_dct8[2] = uavs3d_itrans_dct8_pb16_armv7;

    uavs3d_funs_handle.itrans_dst7[0] = uavs3d_itrans_dst7_pb4_armv7;
    uavs3d_funs_handle.itrans_dst7[1] = uavs3d_itrans_dst7_pb8_armv7;
    uavs3d_funs_handle.itrans_dst7[2] = uavs3d_itrans_dst7_pb16_armv7;

    uavs3d_funs_handle.avg_pel[0] = uavs3d_avg_pel_w4_armv7;
    uavs3d_funs_handle.avg_pel[1] = uavs3d_avg_pel_w8_armv7;
    uavs3d_funs_handle.avg_pel[2] = uavs3d_avg_pel_w16_armv7;
    uavs3d_funs_handle.avg_pel[3] = uavs3d_avg_pel_w32_armv7;
    uavs3d_funs_handle.avg_pel[4] = uavs3d_avg_pel_w64_armv7;
    uavs3d_funs_handle.avg_pel[5] = uavs3d_avg_pel_w128_armv7;

    uavs3d_funs_handle.conv_fmt_16bit = uavs3d_conv_fmt_16bit_armv7;
    uavs3d_funs_handle.padding_rows_luma = uavs3d_padding_rows_luma_armv7;
    uavs3d_funs_handle.padding_rows_chroma = uavs3d_padding_rows_chroma_armv7;
#endif
}
#endif
