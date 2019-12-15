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

#ifndef __MODULES_H__
#define __MODULES_H__

#include "com_util.h"

/*** deblock ***/
void com_deblock_set_edge(com_core_t *core);
void com_deblock_lcu_row(com_core_t *core, int lcu_y);

/*** sao ***/
void com_sao_lcu_row(com_core_t *core, int lcu_y);

/*** alf ***/
void com_alf_init_map(com_seqh_t *seqhdr, u8 *alf_idx_map);
void com_alf_lcu_row(com_core_t *core, int lcu_y);

/*** inter mc ***/
void com_mc       (com_core_t *core, pel *pred);
void com_mc_affine(com_core_t *core, pel *pred);

/*** intra pred ***/
void com_get_nbr_l(pel *dst, int ipm, int ipf, int x, int y, int width, int height, pel *srcT, pel *srcL, int s_src, u16 avail_cu, int scup, com_scu_t *map_scu, int i_scu, int bit_depth);
void com_get_nbr_c(pel *dst, int ipm_c, int ipm, int x, int y, int width, int height, pel *srcT, pel *srcL, int s_src, u16 avail_cu, int scup, com_scu_t * map_scu, int i_scu, int bit_depth);
void com_ipred_l(pel *src, pel *dst, int i_dst, pel *tmp_buf, int ipm, int w, int h, int bit_depth, u16 avail_cu, u8 ipf_flag);
void com_ipred_c(pel *dst, int i_dst, pel *src, pel *luma, s16 *tmp_dst, int ipm_c, int ipm, int w, int h, int bit_depth, u16 avail_cu, pel *piRecoY, int uiStrideY);

/*** itrans ***/
void com_itrans(com_core_t *core, int plane, int blk_idx, s16 *coef, s16 *resi, int log2_w, int log2_h, int bit_depth, int sec_t_vh, int alt_4x4);

/*** recon ***/
void com_recon_l(s16 *resi, pel *pred, int i_pred, int width, int height, pel *rec, int i_rec, int cbf, int bit_depth);
void com_recon_c(s16 *resi_u, s16 *resi_v, pel *pred, int width, int height, pel *rec, int i_rec, u8 cbf[2], int bit_depth);

/*** picture manager ***/
com_pic_t * com_picman_get_empty_pic(com_pic_manager_t *pm, int *err);
com_pic_t * com_picman_out_pic(com_pic_manager_t *pm, int *err, u8 cur_pic_doi, int state);
int com_picman_init(com_pic_manager_t *pm, com_seqh_t *seqhdr, int ext_nodes);
int com_picman_free(com_pic_manager_t *pm);
int com_picman_get_active_refp(com_frm_t *frm, com_pic_manager_t *pm);
int com_picman_mark_refp(com_pic_manager_t *pm, com_pic_header_t *sh);

#endif // #ifndef __MODULES_H__
