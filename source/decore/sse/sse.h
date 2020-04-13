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

#ifndef __UAVS3D_SSE_H__
#define __UAVS3D_SSE_H__

#include <mmintrin.h>
#include <emmintrin.h>
#include <tmmintrin.h>
#include <smmintrin.h>

#include "modules.h"

#ifdef _WIN32

#ifndef _WIN64
#define _mm_extract_epi64(a, i) (a.m128i_i64[i])
#endif

#endif

ALIGNED_32(extern pel uavs3d_simd_mask[15][16]);

void uavs3d_if_cpy_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height);
void uavs3d_if_cpy_w4_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height);
void uavs3d_if_cpy_w8_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height);
void uavs3d_if_cpy_w16_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height);
void uavs3d_if_cpy_w16x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height);

void uavs3d_if_hor_chroma_w8_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_hor_chroma_w8x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_hor_luma_w4_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_hor_luma_w8_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_hor_luma_w8x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_chroma_w4_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_chroma_w8_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_chroma_w8x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_chroma_w16_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_chroma_w16x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_luma_w4_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_luma_w8_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_luma_w8x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_luma_w16_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_ver_luma_w16x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val);
void uavs3d_if_hor_ver_chroma_w8_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coef_x, const s8 *coef_y, int max_val);
void uavs3d_if_hor_ver_chroma_w8x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coef_x, const s8 *coef_y, int max_val);
void uavs3d_if_hor_ver_luma_w4_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coef_x, const s8 *coef_y, int max_val);
void uavs3d_if_hor_ver_luma_w8_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coef_x, const s8 *coef_y, int max_val);
void uavs3d_if_hor_ver_luma_w8x_sse(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coef_x, const s8 *coef_y, int max_val);

void uavs3d_deblock_ver_luma_sse(pel *src, int stride, int alpha, int beta, int flt_flag);
void uavs3d_deblock_hor_luma_sse(pel *src, int stride, int alpha, int beta, int flt_flag);
void uavs3d_deblock_ver_chroma_sse(pel *src, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v, int flt_flag);
void uavs3d_deblock_hor_chroma_sse(pel *src, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v, int flt_flag);
void uavs3d_sao_on_lcu_sse(pel *src, int i_src, pel *dst, int i_dst, com_sao_param_t *sao_params, int smb_pix_height,
    int smb_pix_width, int smb_available_left, int smb_available_right, int smb_available_up, int smb_available_down, int sample_bit_depth);
void uavs3d_sao_on_lcu_chroma_sse(pel *src, int i_src, pel *dst, int i_dst, com_sao_param_t *sao_params, int smb_pix_height,
    int smb_pix_width, int smb_available_left, int smb_available_right, int smb_available_up, int smb_available_down, int sample_bit_depth);
void uavs3d_alf_one_lcu_sse(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);

void uavs3d_avg_pel_w4_sse(pel *dst, int i_dst, pel *src1, pel *src2, int width, int height);
void uavs3d_avg_pel_w8_sse(pel *dst, int i_dst, pel *src1, pel *src2, int width, int height);
void uavs3d_avg_pel_w16_sse(pel *dst, int i_dst, pel *src1, pel *src2, int width, int height);
void uavs3d_avg_pel_w32_sse(pel *dst, int i_dst, pel *src1, pel *src2, int width, int height);
void uavs3d_avg_pel_w16x_sse(pel *dst, int i_dst, pel *src1, pel *src2, int width, int height);
void uavs3d_avg_pel_w32x_sse(pel *dst, int i_dst, pel *src1, pel *src2, int width, int height);

void uavs3d_padding_rows_luma_sse(pel *src, int i_src, int width, int height, int start, int rows, int padh, int padv);
void uavs3d_padding_rows_chroma_sse(pel *src, int i_src, int width, int height, int start, int rows, int padh, int padv);
void uavs3d_conv_fmt_8bit_sse(unsigned char* src_y, unsigned char* src_uv, unsigned char* dst[3], int width, int height, int src_stride, int src_stridec, int dst_stride[3], int uv_shift);
void uavs3d_conv_fmt_16bit_sse(unsigned char* src_y, unsigned char* src_uv, unsigned char* dst[3], int width, int height, int src_stride, int src_stridec, int dst_stride[3], int uv_shift);
void uavs3d_conv_fmt_16to8bit_sse(unsigned char* src_y, unsigned char* src_uv, unsigned char* dst[3], int width, int height, int src_stride, int src_stridec, int dst_stride[3], int uv_shift);

void uavs3d_ipred_dc_sse(pel *src, pel *dst, int i_dst, int width, int height, u16 avail_cu, int bit_depth);
void uavs3d_ipred_plane_sse(pel *src, pel *dst, int i_dst, int width, int height, int bit_depth);
void uavs3d_ipred_bi_sse(pel *src, pel *dst, int i_dst, int width, int height, int bit_depth);
void uavs3d_ipred_hor_sse(pel *src, pel *dst, int i_dst, int width, int height);
void uavs3d_ipred_ver_sse(pel *src, pel *dst, int i_dst, int width, int height);
void uavs3d_ipred_chroma_dc_sse(pel *src, pel *dst, int i_dst, int width, int height, u16 avail_cu, int bit_depth);
void uavs3d_ipred_chroma_plane_sse(pel *src, pel *dst, int i_dst, int width, int height, int bit_depth);
void uavs3d_ipred_chroma_bi_sse(pel *src, pel *dst, int i_dst, int width, int height, int bit_depth);
void uavs3d_ipred_chroma_hor_sse(pel *src, pel *dst, int i_dst, int width, int height);
void uavs3d_ipred_chroma_ver_sse(pel *src, pel *dst, int i_dst, int width, int height);
void uavs3d_ipred_ipf_sse(pel *src, pel *dst, int i_dst, int flt_range_hor, int flt_range_ver, const s8* flt_hor_coef, const s8* flt_ver_coef, int w, int h, int bit_depth);
void uavs3d_ipred_ipf_s16_sse(pel *src, pel *dst, int i_dst, s16* pred, int flt_range_hor, int flt_range_ver, const s8* flt_hor_coef, const s8* flt_ver_coef, int w, int h, int bit_depth);

void uavs3d_ipred_ang_x_3_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_4_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_5_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_6_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_7_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_8_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_9_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_10_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_x_11_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);

void uavs3d_ipred_ang_xy_14_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_xy_16_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_xy_18_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_xy_20_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_xy_22_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);

void uavs3d_ipred_ang_y_26_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_y_28_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_y_30_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);
void uavs3d_ipred_ang_y_32_sse(pel *src, pel *dst, int i_dst, int mode, int width, int height);

void uavs3d_recon_luma_w4_sse(s16 *resi, pel *pred, int i_pred, int width, int height, pel *rec, int i_rec, int cbf, int bit_depth);
void uavs3d_recon_luma_w8_sse(s16 *resi, pel *pred, int i_pred, int width, int height, pel *rec, int i_rec, int cbf, int bit_depth);
void uavs3d_recon_luma_w16_sse(s16 *resi, pel *pred, int i_pred, int width, int height, pel *rec, int i_rec, int cbf, int bit_depth);
void uavs3d_recon_luma_w32_sse(s16 *resi, pel *pred, int i_pred, int width, int height, pel *rec, int i_rec, int cbf, int bit_depth);
void uavs3d_recon_luma_w64_sse(s16 *resi, pel *pred, int i_pred, int width, int height, pel *rec, int i_rec, int cbf, int bit_depth);
void uavs3d_recon_chroma_w4_sse(s16 *resi_u, s16 *resi_v, pel *pred, int width, int height, pel *rec, int i_rec, u8 cbf[2], int bit_depth);
void uavs3d_recon_chroma_w8_sse(s16 *resi_u, s16 *resi_v, pel *pred, int width, int height, pel *rec, int i_rec, u8 cbf[2], int bit_depth);
void uavs3d_recon_chroma_w16_sse(s16 *resi_u, s16 *resi_v, pel *pred, int width, int height, pel *rec, int i_rec, u8 cbf[2], int bit_depth);
void uavs3d_recon_chroma_w16x_sse(s16 *resi_u, s16 *resi_v, pel *pred, int width, int height, pel *rec, int i_rec, u8 cbf[2], int bit_depth);

void dct2_butterfly_h8_sse(s16* src, int i_src, s16* dst, int line, int shift, int bit_depth);
void dct2_butterfly_h16_sse(s16* src, int i_src, s16* dst, int line, int shift, int bit_depth);
void dct2_butterfly_h32_sse(s16* src, int i_src, s16* dst, int line, int shift, int bit_depth);

void itrans_dct2_h4_w4_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h4_w8_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h4_w16_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h4_w32_sse(s16 *src, s16 *dst, int bit_depth);

void itrans_dct2_h8_w4_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h8_w8_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h8_w16_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h8_w32_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h8_w64_sse(s16 *src, s16 *dst, int bit_depth);

void itrans_dct2_h16_w4_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h16_w8_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h16_w16_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h16_w32_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h16_w64_sse(s16 *src, s16 *dst, int bit_depth);

void itrans_dct2_h32_w4_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h32_w8_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h32_w16_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h32_w32_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h32_w64_sse(s16 *src, s16 *dst, int bit_depth);

void itrans_dct2_h64_w8_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h64_w16_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h64_w32_sse(s16 *src, s16 *dst, int bit_depth);
void itrans_dct2_h64_w64_sse(s16 *src, s16 *dst, int bit_depth);

void itrans_dct8_pb4_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);
void itrans_dct8_pb8_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);
void itrans_dct8_pb16_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);
void itrans_dct8_pb32_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);

void itrans_dst7_pb4_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);
void itrans_dst7_pb8_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);
void itrans_dst7_pb16_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);
void itrans_dst7_pb32_sse(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *iT);


#endif // #ifndef __INTRINSIC_H__