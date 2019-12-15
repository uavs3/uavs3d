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

#ifndef __BITSTREAM_H__
#define __BITSTREAM_H__

#include "com_type.h"

#define DEC_BS_IS_ALIGN(bs) (!((bs)->leftbits & 0x7))

void dec_bs_init           (com_bs_t * bs, u8 * buf, int size);
u32  dec_bs_read           (com_bs_t * bs, int size, u32 min, u32 max);
u32  dec_bs_next           (com_bs_t * bs, int size);
int  dec_bs_read1          (com_bs_t * bs, int val);
u32  dec_bs_read_ue        (com_bs_t * bs, u32 min, u32 max);
int  dec_bs_read_se        (com_bs_t * bs, int min, int max);
u8*  dec_bs_get_one_unit   (com_bs_t *bs);

u8*  dec_bs_demulate(u8 *start, u8 *end);

#endif /* __BITSTREAM_H__ */
