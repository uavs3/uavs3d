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

#include "arm64.h"
#if defined(__arm64__)

static void uavs3d_padding_rows_luma_arm64(pel *src, int i_src, int width, int height, int start, int rows, int padh, int padv)
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
    
    uavs3d_padding_rows_lr_arm64(p, i_src, width, rows, padh);
    
}

static void uavs3d_padding_rows_chroma_arm64(pel *src, int i_src, int width, int height, int start, int rows, int padh, int padv)
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
    
    uavs3d_padding_rows_chroma_lr_arm64(p, i_src, width, rows, padh);
    
}

void uavs3d_funs_init_arm64()
{
#if (BIT_DEPTH == 8)
    uavs3d_funs_handle.sao[ Y_C] = uavs3d_sao_on_lcu_arm64;
    uavs3d_funs_handle.sao[UV_C] = uavs3d_sao_on_lcu_chroma_arm64;
    uavs3d_funs_handle.alf[ Y_C] = uavs3d_alf_one_lcu_arm64;
    uavs3d_funs_handle.alf[UV_C] = uavs3d_alf_one_lcu_chroma_arm64;
    uavs3d_funs_handle.alf[ 2  ] = uavs3d_alf_one_lcu_one_chroma_arm64;
    uavs3d_funs_handle.deblock_luma[0] = uavs3d_deblock_ver_luma_arm64;
    uavs3d_funs_handle.deblock_luma[1] = uavs3d_deblock_hor_luma_arm64;
    uavs3d_funs_handle.deblock_chroma[0] = uavs3d_deblock_ver_chroma_arm64;
    uavs3d_funs_handle.deblock_chroma[1] = uavs3d_deblock_hor_chroma_arm64;

    uavs3d_funs_handle.ipcpy[0] = uavs3d_if_cpy_w4_arm64;
    uavs3d_funs_handle.ipcpy[1] = uavs3d_if_cpy_w8_arm64;
    uavs3d_funs_handle.ipcpy[2] = uavs3d_if_cpy_w16_arm64;
    uavs3d_funs_handle.ipcpy[3] = uavs3d_if_cpy_w32_arm64;
    uavs3d_funs_handle.ipcpy[4] = uavs3d_if_cpy_w64_arm64;
    uavs3d_funs_handle.ipcpy[5] = uavs3d_if_cpy_w128_arm64;

    uavs3d_funs_handle.ipflt[IPFILTER_H_8][0] = uavs3d_if_hor_luma_w4_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][1] = uavs3d_if_hor_luma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][2] = uavs3d_if_hor_luma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][3] = uavs3d_if_hor_luma_w32_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][4] = uavs3d_if_hor_luma_w32x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][5] = uavs3d_if_hor_luma_w32x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][1] = uavs3d_if_hor_chroma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][2] = uavs3d_if_hor_chroma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][3] = uavs3d_if_hor_chroma_w32_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][4] = uavs3d_if_hor_chroma_w32x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][5] = uavs3d_if_hor_chroma_w32x_arm64;
    
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][0] = uavs3d_if_ver_luma_w4_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][1] = uavs3d_if_ver_luma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][2] = uavs3d_if_ver_luma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][3] = uavs3d_if_ver_luma_w32_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][4] = uavs3d_if_ver_luma_w32x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][5] = uavs3d_if_ver_luma_w32x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][1] = uavs3d_if_ver_chroma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][2] = uavs3d_if_ver_chroma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][3] = uavs3d_if_ver_chroma_w32_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][4] = uavs3d_if_ver_chroma_w64_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][5] = uavs3d_if_ver_chroma_w128_arm64;

    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][0] = uavs3d_if_hor_ver_luma_w4_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][1] = uavs3d_if_hor_ver_luma_w8_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][2] = uavs3d_if_hor_ver_luma_w16_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][3] = uavs3d_if_hor_ver_luma_w32_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][4] = uavs3d_if_hor_ver_luma_w32x_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][5] = uavs3d_if_hor_ver_luma_w32x_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][1] = uavs3d_if_hor_ver_chroma_w8_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][2] = uavs3d_if_hor_ver_chroma_w16_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][3] = uavs3d_if_hor_ver_chroma_w32_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][4] = uavs3d_if_hor_ver_chroma_w32x_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][5] = uavs3d_if_hor_ver_chroma_w32x_arm64;

    uavs3d_funs_handle.itrans_dct2[1][1] = uavs3d_itrans_dct2_h4_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[1][2] = uavs3d_itrans_dct2_h4_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[1][3] = uavs3d_itrans_dct2_h4_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[1][4] = uavs3d_itrans_dct2_h4_w32_arm64;

    uavs3d_funs_handle.itrans_dct2[2][1] = uavs3d_itrans_dct2_h8_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[2][2] = uavs3d_itrans_dct2_h8_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[2][3] = uavs3d_itrans_dct2_h8_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[2][4] = uavs3d_itrans_dct2_h8_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[2][5] = uavs3d_itrans_dct2_h8_w64_arm64;

    uavs3d_funs_handle.itrans_dct2[3][1] = uavs3d_itrans_dct2_h16_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[3][2] = uavs3d_itrans_dct2_h16_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[3][3] = uavs3d_itrans_dct2_h16_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[3][4] = uavs3d_itrans_dct2_h16_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[3][5] = uavs3d_itrans_dct2_h16_w64_arm64;
    
    uavs3d_funs_handle.itrans_dct2[4][1] = uavs3d_itrans_dct2_h32_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[4][2] = uavs3d_itrans_dct2_h32_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[4][3] = uavs3d_itrans_dct2_h32_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[4][4] = uavs3d_itrans_dct2_h32_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[4][5] = uavs3d_itrans_dct2_h32_w64_arm64;
    
    uavs3d_funs_handle.itrans_dct2[5][2] = uavs3d_itrans_dct2_h64_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[5][3] = uavs3d_itrans_dct2_h64_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[5][4] = uavs3d_itrans_dct2_h64_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[5][5] = uavs3d_itrans_dct2_h64_w64_arm64;

    uavs3d_funs_handle.itrans_dct8[0] = uavs3d_itrans_dct8_pb4_arm64;
    uavs3d_funs_handle.itrans_dct8[1] = uavs3d_itrans_dct8_pb8_arm64;
    uavs3d_funs_handle.itrans_dct8[2] = uavs3d_itrans_dct8_pb16_arm64;
    
    uavs3d_funs_handle.itrans_dst7[0] = uavs3d_itrans_dct8_pb4_arm64;
    uavs3d_funs_handle.itrans_dst7[1] = uavs3d_itrans_dct8_pb8_arm64;
    uavs3d_funs_handle.itrans_dst7[2] = uavs3d_itrans_dct8_pb16_arm64;

    uavs3d_funs_handle.avg_pel[0] = uavs3d_avg_pel_w4_arm64;
    uavs3d_funs_handle.avg_pel[1] = uavs3d_avg_pel_w8_arm64;
    uavs3d_funs_handle.avg_pel[2] = uavs3d_avg_pel_w16_arm64;
    uavs3d_funs_handle.avg_pel[3] = uavs3d_avg_pel_w32_arm64;
    uavs3d_funs_handle.avg_pel[4] = uavs3d_avg_pel_w64_arm64;
    uavs3d_funs_handle.avg_pel[5] = uavs3d_avg_pel_w128_arm64;
    
    uavs3d_funs_handle.conv_fmt_8bit = uavs3d_conv_fmt_8bit_arm64;
    uavs3d_funs_handle.padding_rows_luma = uavs3d_padding_rows_luma_arm64;
    uavs3d_funs_handle.padding_rows_chroma = uavs3d_padding_rows_chroma_arm64;
    
    uavs3d_funs_handle.intra_pred_ver  [ Y_C] = uavs3d_intra_pred_ver_arm64;
    uavs3d_funs_handle.intra_pred_ver  [UV_C] = uavs3d_intra_pred_ver_arm64;
    uavs3d_funs_handle.intra_pred_hor  [ Y_C] = uavs3d_intra_pred_hor_arm64;
    uavs3d_funs_handle.intra_pred_hor  [UV_C] = uavs3d_intra_pred_hor_uv_arm64;
    uavs3d_funs_handle.intra_pred_dc   [ Y_C] = uavs3d_intra_pred_dc_arm64;
    uavs3d_funs_handle.intra_pred_dc   [UV_C] = uavs3d_intra_pred_dc_uv_arm64;
    uavs3d_funs_handle.intra_pred_plane[ Y_C] = uavs3d_intra_pred_plane_arm64;
    uavs3d_funs_handle.intra_pred_plane[UV_C] = uavs3d_intra_pred_plane_uv_arm64;
    uavs3d_funs_handle.intra_pred_plane_ipf   = uavs3d_intra_pred_plane_ipf_arm64;
    uavs3d_funs_handle.intra_pred_bi   [ Y_C] = uavs3d_intra_pred_bi_arm64;
    uavs3d_funs_handle.intra_pred_bi_ipf      = uavs3d_intra_pred_bi_ipf_arm64;
    uavs3d_funs_handle.intra_pred_ipf         = uavs3d_intra_pred_ipf_arm64;
    
#else
    uavs3d_funs_handle.ipcpy[0] = uavs3d_if_cpy_w4_arm64;
    uavs3d_funs_handle.ipcpy[1] = uavs3d_if_cpy_w8_arm64;
    uavs3d_funs_handle.ipcpy[2] = uavs3d_if_cpy_w16_arm64;
    uavs3d_funs_handle.ipcpy[3] = uavs3d_if_cpy_w32_arm64;
    uavs3d_funs_handle.ipcpy[4] = uavs3d_if_cpy_w64_arm64;
    uavs3d_funs_handle.ipcpy[5] = uavs3d_if_cpy_w128_arm64;

    uavs3d_funs_handle.ipflt[IPFILTER_H_8][0] = uavs3d_if_hor_luma_w4_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][1] = uavs3d_if_hor_luma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][2] = uavs3d_if_hor_luma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][3] = uavs3d_if_hor_luma_w16x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][4] = uavs3d_if_hor_luma_w16x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_8][5] = uavs3d_if_hor_luma_w16x_arm64;
    
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][1] = uavs3d_if_hor_chroma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][2] = uavs3d_if_hor_chroma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][3] = uavs3d_if_hor_chroma_w16x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][4] = uavs3d_if_hor_chroma_w16x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_H_4][5] = uavs3d_if_hor_chroma_w16x_arm64;
    
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][0] = uavs3d_if_ver_luma_w4_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][1] = uavs3d_if_ver_luma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][2] = uavs3d_if_ver_luma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][3] = uavs3d_if_ver_luma_w16x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][4] = uavs3d_if_ver_luma_w16x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_8][5] = uavs3d_if_ver_luma_w16x_arm64;
    
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][1] = uavs3d_if_ver_chroma_w8_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][2] = uavs3d_if_ver_chroma_w16_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][3] = uavs3d_if_ver_chroma_w32_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][4] = uavs3d_if_ver_chroma_w32x_arm64;
    uavs3d_funs_handle.ipflt[IPFILTER_V_4][5] = uavs3d_if_ver_chroma_w32x_arm64;
    
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][0] = uavs3d_if_hor_ver_luma_w4_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][1] = uavs3d_if_hor_ver_luma_w8_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][2] = uavs3d_if_hor_ver_luma_w16_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][3] = uavs3d_if_hor_ver_luma_w32_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][4] = uavs3d_if_hor_ver_luma_w32x_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_8][5] = uavs3d_if_hor_ver_luma_w32x_arm64;
    
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][1] = uavs3d_if_hor_ver_chroma_w8_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][2] = uavs3d_if_hor_ver_chroma_w16_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][3] = uavs3d_if_hor_ver_chroma_w32_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][4] = uavs3d_if_hor_ver_chroma_w32x_arm64;
    uavs3d_funs_handle.ipflt_ext[IPFILTER_EXT_4][5] = uavs3d_if_hor_ver_chroma_w32x_arm64;

    uavs3d_funs_handle.alf[ Y_C] = uavs3d_alf_one_lcu_arm64;
    uavs3d_funs_handle.alf[UV_C] = uavs3d_alf_one_lcu_chroma_arm64;
    uavs3d_funs_handle.alf[ 2  ] = uavs3d_alf_one_lcu_one_chroma_arm64;
    
    uavs3d_funs_handle.deblock_luma[0] = uavs3d_deblock_ver_luma_arm64;
    uavs3d_funs_handle.deblock_luma[1] = uavs3d_deblock_hor_luma_arm64;
    uavs3d_funs_handle.deblock_chroma[0] = uavs3d_deblock_ver_chroma_arm64;
    uavs3d_funs_handle.deblock_chroma[1] = uavs3d_deblock_hor_chroma_arm64;

    uavs3d_funs_handle.sao[ Y_C] = uavs3d_sao_on_lcu_arm64;
    uavs3d_funs_handle.sao[UV_C] = uavs3d_sao_on_lcu_chroma_arm64;

    uavs3d_funs_handle.itrans_dct2[1][1] = uavs3d_itrans_dct2_h4_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[1][2] = uavs3d_itrans_dct2_h4_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[1][3] = uavs3d_itrans_dct2_h4_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[1][4] = uavs3d_itrans_dct2_h4_w32_arm64;

    uavs3d_funs_handle.itrans_dct2[2][1] = uavs3d_itrans_dct2_h8_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[2][2] = uavs3d_itrans_dct2_h8_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[2][3] = uavs3d_itrans_dct2_h8_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[2][4] = uavs3d_itrans_dct2_h8_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[2][5] = uavs3d_itrans_dct2_h8_w64_arm64;

    uavs3d_funs_handle.itrans_dct2[3][1] = uavs3d_itrans_dct2_h16_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[3][2] = uavs3d_itrans_dct2_h16_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[3][3] = uavs3d_itrans_dct2_h16_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[3][4] = uavs3d_itrans_dct2_h16_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[3][5] = uavs3d_itrans_dct2_h16_w64_arm64;
    
    uavs3d_funs_handle.itrans_dct2[4][1] = uavs3d_itrans_dct2_h32_w4_arm64;
    uavs3d_funs_handle.itrans_dct2[4][2] = uavs3d_itrans_dct2_h32_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[4][3] = uavs3d_itrans_dct2_h32_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[4][4] = uavs3d_itrans_dct2_h32_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[4][5] = uavs3d_itrans_dct2_h32_w64_arm64;
    
    uavs3d_funs_handle.itrans_dct2[5][2] = uavs3d_itrans_dct2_h64_w8_arm64;
    uavs3d_funs_handle.itrans_dct2[5][3] = uavs3d_itrans_dct2_h64_w16_arm64;
    uavs3d_funs_handle.itrans_dct2[5][4] = uavs3d_itrans_dct2_h64_w32_arm64;
    uavs3d_funs_handle.itrans_dct2[5][5] = uavs3d_itrans_dct2_h64_w64_arm64;

    uavs3d_funs_handle.itrans_dct8[0] = uavs3d_itrans_dct8_pb4_arm64;
    uavs3d_funs_handle.itrans_dct8[1] = uavs3d_itrans_dct8_pb8_arm64;
    uavs3d_funs_handle.itrans_dct8[2] = uavs3d_itrans_dct8_pb16_arm64;

    uavs3d_funs_handle.itrans_dst7[0] = uavs3d_itrans_dct8_pb4_arm64;
    uavs3d_funs_handle.itrans_dst7[1] = uavs3d_itrans_dct8_pb8_arm64;
    uavs3d_funs_handle.itrans_dst7[2] = uavs3d_itrans_dct8_pb16_arm64;

    uavs3d_funs_handle.conv_fmt_16bit = uavs3d_conv_fmt_16bit_arm64;
    uavs3d_funs_handle.padding_rows_luma = uavs3d_padding_rows_luma_arm64;
    uavs3d_funs_handle.padding_rows_chroma = uavs3d_padding_rows_chroma_arm64;
    
    uavs3d_funs_handle.avg_pel[0] = uavs3d_avg_pel_w4_arm64;
    uavs3d_funs_handle.avg_pel[1] = uavs3d_avg_pel_w8_arm64;
    uavs3d_funs_handle.avg_pel[2] = uavs3d_avg_pel_w16_arm64;
    uavs3d_funs_handle.avg_pel[3] = uavs3d_avg_pel_w32_arm64;
    uavs3d_funs_handle.avg_pel[4] = uavs3d_avg_pel_w64_arm64;
    uavs3d_funs_handle.avg_pel[5] = uavs3d_avg_pel_w128_arm64;
    
#endif
}
#endif
