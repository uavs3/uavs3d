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

#ifndef __COM_TABLE_H__
#define __COM_TABLE_H__

#define ITRANS_SIZE_TYPES 6
#define ITRANS_COEFFS_SIZE ((2 * 2 + 4 * 4 + 8 * 8 + 16 * 16 + 32 * 32 + 64 * 64) * NUM_TRANS_TYPE)

extern s8*      g_tbl_itrans[NUM_TRANS_TYPE][ITRANS_SIZE_TYPES];
extern s8       g_tbl_itrans_coeffs[ITRANS_COEFFS_SIZE];

extern tab_s8   g_tbl_itrans_c4[4][4];
extern tab_s8   g_tbl_itrans_c8[4][4];

extern tab_u8                g_tbl_part_num[8];
extern const com_part_size_t g_tbl_tb_part[8];

extern tab_s32  g_tbl_ai_tscpm_div[64];

extern tab_s8   g_tbl_log2[257];

extern tab_s8   g_tbl_mc_coeff_luma_hp[16][8];
extern tab_s8   g_tbl_mc_coeff_chroma_hp[32][4];
extern tab_s8   g_tbl_mc_coeff_luma[4][8];
extern tab_s8   g_tbl_mc_coeff_chroma[8][4];

extern tab_u8   g_tbl_qp_chroma_adjust[64];

extern tab_u32  g_tbl_wq_default_param[2][6];
extern tab_u8   g_tbl_wq_default_matrix_4x4[16];
extern tab_u8   g_tbl_wq_default_matrix_8x8[64];
extern tab_u8   g_tbl_wq_model_4x4[4][16];
extern tab_u8   g_tbl_wq_model_8x8[4][64];

extern tab_u16  g_tbl_scan[64516];
extern tab_u16  g_tbl_scan_blkpos[MAX_CU_LOG2][MAX_CU_LOG2];

#endif // __COM_TABLE_H__ 
