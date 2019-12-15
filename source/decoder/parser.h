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

#ifndef __PARSER_H__
#define __PARSER_H__

#include "dec_type.h"

void lbac_init        (com_lbac_t *lbac, u8 *cur, u8* end);
int  lbac_dec_bin_trm (com_lbac_t *lbac);

int  dec_parse_sqh              (com_bs_t * bs, com_seqh_t * seqhdr);
int  dec_parse_pic_header       (com_bs_t * bs, com_pic_header_t * pichdr, com_seqh_t * seqhdr, com_pic_manager_t *pm);
int  dec_parse_patch_header     (com_bs_t * bs, com_seqh_t *seqhdr, com_pic_header_t * ph, com_patch_header_t * pichdr);
int  dec_parse_patch_end        (com_bs_t * bs);
int  dec_parse_ext_and_usr_data (com_bs_t * bs, com_seqh_t *seqhdr, com_pic_header_t * pichdr, int i, int slicetype);

int  dec_parse_lcu_delta_qp (com_lbac_t * lbac, int last_dqp);
void dec_parse_sao_param    (com_core_t* core, int lcu_idx, com_sao_param_t *sao_cur_param);
u32  dec_parse_alf_enable   (com_lbac_t * lbac, int compIdx);

s8   dec_parse_split_mode             (com_core_t *core, com_lbac_t *lbac, int split_tab, int cu_width, int cu_height, int qt_depth, int bet_depth);
u8   dec_parse_cons_pred_mode_child   (com_lbac_t * lbac);

int  dec_parse_cu_header        (com_core_t * core);
int  dec_parse_cu_header_chroma (com_core_t * core);
int  dec_parse_run_length_cc    (com_core_t *core, s16 *coef, int log2_w, int log2_h, int ch_type);
void dec_parse_ipcm_start       (com_lbac_t *lbac);
int  dec_parse_ipcm             (com_lbac_t *lbac, int *bit_left, int bits);

#endif /* __PARSER_H__ */
