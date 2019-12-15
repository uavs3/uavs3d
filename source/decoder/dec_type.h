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

#ifndef __DEC_TYPE_H__
#define __DEC_TYPE_H__

#include "modules.h"
#include "uavs3d.h"
#include "bitstream.h"

#define SPLIT_MAX_PART_COUNT 4

typedef struct uavs3d_dec_split_info_t {
    int       part_count;
    int       width[SPLIT_MAX_PART_COUNT];
    int       height[SPLIT_MAX_PART_COUNT];
    int       log_cuw[SPLIT_MAX_PART_COUNT];
    int       log_cuh[SPLIT_MAX_PART_COUNT];
    int       x_pos[SPLIT_MAX_PART_COUNT];
    int       y_pos[SPLIT_MAX_PART_COUNT];
} dec_split_info_t;

typedef struct uavs3d_dec_t {
    u8                    init_flag;

    /* Senquence Level Shared Data */
    com_seqh_t            seqhdr;
    u8                   *alf_idx_map;

    uavs3d_cfg_t          dec_cfg;

    /* CORE data for pic decode, only used in single thread */
    com_core_t           *core;

    int                   frm_nodes;
    int                   frm_node_start;
    int                   frm_node_end;
    com_frm_t            *frm_nodes_list;

    /* current decoding bitstream */
    com_bs_t              bs;

    /* Reference Frame Management */
    com_pic_manager_t     pic_manager;
    int                   cur_decoded_dtr;
    int                   output;

    /* Frame Level Parallel */
    threadpool_t         *frm_threads_pool;
    int                   frm_threads_nodes;

    void                 *callback;
} uavs3d_dec_t;


#include "dec_util.h"
#include "parser.h"

#endif /* __DEC_DEF_H__ */
