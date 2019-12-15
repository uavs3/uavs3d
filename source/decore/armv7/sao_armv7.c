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

#if defined(__arm__)
#include "sao_kernel_armv7.h"
#include "armv7.h"


ALIGNED_32(pel uavs3d_sao_mask[16 * 16]) = {
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0
};
#if 0
void SAO_EO_0_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height, pel* mask, int bit_depth){
    int x, y;
    int diff, leftsign, rightsign, edgetype;
    int max_pel = (1 << bit_depth) - 1;

    for (y = 0; y < mb_height; y++) {
        diff = src[start_x] - src[start_x - 1];
        leftsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        for (x = start_x; x < end_x; x++) {
            diff = src[x] - src[x + 1];
            rightsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = leftsign + rightsign;
            leftsign = -rightsign;
            dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
        }
        dst += dst_stride;
        src += src_stride;
    }
}

void SAO_EO_0_chroma_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height, pel* mask, int bit_depth){
    int x, y;
    int diff, leftsign, rightsign, edgetype;
    int max_pel = (1 << bit_depth) - 1;

    for (y = 0; y < mb_height; y++) {
        diff = src[start_x] - src[start_x - 2];
        leftsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        for (x = start_x; x < end_x; x += 2) {
            diff = src[x] - src[x + 2];
            rightsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = leftsign + rightsign;
            leftsign = -rightsign;
            dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
        }
        dst += dst_stride;
        src += src_stride;
    }
}

void SAO_EO_90_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width, int bit_depth){
    int x, y;
    int diff, upsign, downsign, edgetype;
    pel *dst_base = dst;
    pel *src_base = src;
    int max_pel = (1 << bit_depth) - 1;

    for (x = 0; x < mb_width; x++) {
        src = src_base + start_y * src_stride;
        diff = src[0] - src[-src_stride];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        dst = dst_base + start_y * dst_stride;
        for (y = start_y; y < end_y; y++) {
            diff = src[0] - src[src_stride];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + upsign;
            upsign = -downsign;
            *dst = COM_CLIP3(0, max_pel, src[0] + offset[edgetype + 2]);
            dst += dst_stride;
            src += src_stride;
        }
        dst_base++;
        src_base++;
    }
}
void SAO_EO_90_chroma_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width, int bit_depth){
    int x, y;
    int diff, upsign, downsign, edgetype;
    pel *dst_base = dst;
    pel *src_base = src;
    int max_pel = (1 << bit_depth) - 1;

    for (x = 0; x < mb_width; x += 2) {
        src = src_base + start_y * src_stride;
        diff = src[0] - src[-src_stride];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        dst = dst_base + start_y * dst_stride;
        for (y = start_y; y < end_y; y++) {
            diff = src[0] - src[src_stride];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + upsign;
            upsign = -downsign;
            *dst = COM_CLIP3(0, max_pel, src[0] + offset[edgetype + 2]);
            dst += dst_stride;
            src += src_stride;
        }
        dst_base += 2;
        src_base += 2;
    }
}

void SAO_EO_135_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn){
    int diff, upsign, downsign, edgetype;
    int x, y;
    s8 signupline[144];
    int reg = 0;
    int max_pel = (1 << bit_depth) - 1;

    //init the line buffer
    for (x = start_x_r + 1; x < end_x_r + 1; x++) {
        diff = src[x + src_stride] - src[x - 1];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        signupline[x] = upsign;
    }
    //first row
    for (x = start_x_r0; x < end_x_r0; x++) {
        diff = src[x] - src[x - 1 - src_stride];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = upsign - signupline[x + 1];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
    dst += dst_stride;
    src += src_stride;

    //middle rows
    for (y = 1; y < mb_height - 1; y++) {
        for (x = start_x_r; x < end_x_r; x++) {
            if (x == start_x_r) {
                diff = src[x] - src[x - 1 - src_stride];
                upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
                signupline[x] = upsign;
            }
            diff = src[x] - src[x + 1 + src_stride];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + signupline[x];
            dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
            signupline[x] = reg;
            reg = -downsign;
        }
        dst += dst_stride;
        src += src_stride;
    }
    //last row
    for (x = start_x_rn; x < end_x_rn; x++) {
        if (x == start_x_r) {
            diff = src[x] - src[x - 1 - src_stride];
            upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            signupline[x] = upsign;
        }
        diff = src[x] - src[x + 1 + src_stride];
        downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = downsign + signupline[x];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
}
void SAO_EO_135_chroma_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn){
    int diff, upsign, downsign, edgetype;
    int x, y;
    s8 signupline[80];
    int reg = 0;
    int max_pel = (1 << bit_depth) - 1;

    //init the line buffer
    for (x = start_x_r + 2; x < end_x_r + 2; x += 2) {
        diff = src[x + src_stride] - src[x - 2];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        signupline[x >> 1] = upsign;
    }
    //first row
    for (x = start_x_r0; x < end_x_r0; x += 2) {
        diff = src[x] - src[x - 2 - src_stride];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = upsign - signupline[(x >> 1) + 1];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
    dst += dst_stride;
    src += src_stride;

    //middle rows
    for (y = 1; y < mb_height - 1; y++) {
        for (x = start_x_r; x < end_x_r; x += 2) {
            int x2 = x >> 1;
            if (x == start_x_r) {
                diff = src[x] - src[x - 2 - src_stride];
                upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
                signupline[x2] = upsign;
            }
            diff = src[x] - src[x + 2 + src_stride];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + signupline[x2];
            dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
            signupline[x2] = reg;
            reg = -downsign;
        }
        dst += dst_stride;
        src += src_stride;
    }
    //last row
    for (x = start_x_rn; x < end_x_rn; x += 2) {
        if (x == start_x_r) {
            diff = src[x] - src[x - 2 - src_stride];
            upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            signupline[x >> 1] = upsign;
        }
        diff = src[x] - src[x + 2 + src_stride];
        downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = downsign + signupline[x >> 1];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
}

void SAO_EO_45_c(pel* src, pel* dst, int i_src, int i_dst, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn){
    int diff, upsign, downsign, edgetype;
    int x, y;
    s8 signupline[144], *signupline1;
    int max_pel = (1 << bit_depth) - 1;

    signupline1 = signupline + 1;
    for (x = start_x_r - 1; x < end_x_r - 1; x++) {
        diff = src[x + i_src] - src[x + 1];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        signupline1[x] = upsign;
    }
    //first row
    for (x = start_x_r0; x < end_x_r0; x++) {
        diff = src[x] - src[x + 1 - i_src];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = upsign - signupline1[x - 1];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
    dst += i_dst;
    src += i_src;

    //middle rows
    for (y = 1; y < mb_height - 1; y++) {
        for (x = start_x_r; x < end_x_r; x++) {
            if (x == end_x_r - 1) {
                diff = src[x] - src[x + 1 - i_src];
                upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
                signupline1[x] = upsign;
            }
            diff = src[x] - src[x - 1 + i_src];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + signupline1[x];
            dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
            signupline1[x - 1] = -downsign;
        }
        dst += i_dst;
        src += i_src;
    }
    for (x = start_x_rn; x < end_x_rn; x++) {
        if (x == end_x_r - 1) {
            diff = src[x] - src[x + 1 - i_src];
            upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            signupline1[x] = upsign;
        }
        diff = src[x] - src[x - 1 + i_src];
        downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = downsign + signupline1[x];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
}
void SAO_EO_45_chroma_c(pel* src, pel* dst, int i_src, int i_dst, int* offset, pel* mask, int mb_height, int bit_depth, int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn){
    int diff, upsign, downsign, edgetype;
    int x, y;
    s8 signupline[80], *signupline1;
    int max_pel = (1 << bit_depth) - 1;

    signupline1 = signupline + 1;
    for (x = start_x_r - 2; x < end_x_r - 2; x += 2) {
        diff = src[x + i_src] - src[x + 2];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        signupline1[x >> 1] = upsign;
    }
    //first row
    for (x = start_x_r0; x < end_x_r0; x += 2) {
        diff = src[x] - src[x + 2 - i_src];
        upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = upsign - signupline1[(x >> 1) - 1];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
    dst += i_dst;
    src += i_src;

    //middle rows
    for (y = 1; y < mb_height - 1; y++) {
        for (x = start_x_r; x < end_x_r; x += 2) {
            int x2 = x >> 1;
            if (x == end_x_r - 2) {
                diff = src[x] - src[x + 2 - i_src];
                upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
                signupline1[x2] = upsign;
            }
            diff = src[x] - src[x - 2 + i_src];
            downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            edgetype = downsign + signupline1[x2];
            dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
            signupline1[x2 - 1] = -downsign;
        }
        dst += i_dst;
        src += i_src;
    }
    for (x = start_x_rn; x < end_x_rn; x += 2) {
        if (x == end_x_r - 2) {
            diff = src[x] - src[x + 2 - i_src];
            upsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
            signupline1[x >> 1] = upsign;
        }
        diff = src[x] - src[x - 2 + i_src];
        downsign = diff > 0 ? 1 : (diff < 0 ? -1 : 0);
        edgetype = downsign + signupline1[x >> 1];
        dst[x] = COM_CLIP3(0, max_pel, src[x] + offset[edgetype + 2]);
    }
}

void SAO_BO_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int *band_ids, int mb_width, int mb_height, int bit_depth){
    pel *dst_base = dst;
    pel *src_base = src;
    int x, y;
    int max_pel = (1 << bit_depth) - 1;

    for (x = 0; x < mb_width; x++) {
        dst = dst_base;
        src = src_base;
        for (y = 0; y < mb_height; y++) {
            int tmp = src[0] >> (bit_depth - NUM_SAO_BO_CLASSES_IN_BIT);
            if (tmp == band_ids[0]){
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[0]);
            }
            else if (tmp == band_ids[1])
            {
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[1]);
            }
            else if (tmp == band_ids[2])
            {
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[2]);
            }
            else if (tmp == band_ids[3])
            {
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[3]);
            }

            dst += dst_stride;
            src += src_stride;
        }
        dst_base++;
        src_base++;
    }
}
void SAO_BO_chroma_c(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, int *band_ids, int mb_width, int mb_height, int bit_depth){
    pel *dst_base = dst;
    pel *src_base = src;
    int x, y;
    int max_pel = (1 << bit_depth) - 1;

    for (x = 0; x < mb_width; x += 2) {
        dst = dst_base;
        src = src_base;
        for (y = 0; y < mb_height; y++) {
            int tmp = src[0] >> (bit_depth - NUM_SAO_BO_CLASSES_IN_BIT);
            if (tmp == band_ids[0]){
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[0]);
            }
            else if (tmp == band_ids[1])
            {
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[1]);
            }
            else if (tmp == band_ids[2])
            {
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[2]);
            }
            else if (tmp == band_ids[3])
            {
                *dst = COM_CLIP3(0, max_pel, src[0] + offset[3]);
            }

            dst += dst_stride;
            src += src_stride;
        }
        dst_base += 2;
        src_base += 2;
    }
}
#endif
void uavs3d_sao_on_lcu_armv7(pel *src, int i_src, pel *dst, int i_dst, com_sao_param_t *sao_params, int smb_pix_height, int smb_pix_width, int smb_available_left, int smb_available_right, int smb_available_up, int smb_available_down, int bit_depth)
{
    int type;
    int start_x, end_x, start_y, end_y;
    int start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn;

    type = sao_params->type;

    switch (type) {
        case SAO_TYPE_EO_0: {
            start_x = smb_available_left ? 0 : 1;
            end_x = smb_available_right ? smb_pix_width : (smb_pix_width - 1);
            //SAO_EO_0_c(src, dst, i_src, i_dst, sao_params->offset, start_x, end_x, smb_pix_height, uavs3d_sao_mask, bit_depth);
            uavs3d_sao_eo_0_armv7(src, dst, i_src, i_dst, sao_params->offset, start_x, end_x, smb_pix_height, uavs3d_sao_mask, bit_depth);
            break;
        }
        case SAO_TYPE_EO_90: {
            start_y = smb_available_up ? 0 : 1;
            end_y = smb_available_down ? smb_pix_height : (smb_pix_height - 1);
            //SAO_EO_90_c(src, dst, i_src, i_dst, sao_params->offset, start_y, end_y, smb_pix_width, bit_depth);
            uavs3d_sao_eo_90_armv7(src, dst, i_src, i_dst, sao_params->offset, start_y, end_y, smb_pix_width, bit_depth);
            break;
        }
        case SAO_TYPE_EO_135: {
            start_x_r0 = (smb_available_up && smb_available_left) ? 0 : 1;
            end_x_r0 = smb_available_up ? (smb_available_right ? smb_pix_width : (smb_pix_width - 1)) : 1;
            start_x_r = smb_available_left ? 0 : 1;
            end_x_r = smb_available_right ? smb_pix_width : (smb_pix_width - 1);
            start_x_rn = smb_available_down ? (smb_available_left ? 0 : 1) : (smb_pix_width - 1);
            end_x_rn = (smb_available_right && smb_available_down) ? smb_pix_width : (smb_pix_width - 1);

            //SAO_EO_135_c(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            uavs3d_sao_eo_135_armv7(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            break;
        }
        case SAO_TYPE_EO_45: {
            start_x_r0 = smb_available_up ? (smb_available_left ? 0 : 1) : (smb_pix_width - 1);
            end_x_r0 = (smb_available_up && smb_available_right) ? smb_pix_width : (smb_pix_width - 1);
            start_x_r = smb_available_left ? 0 : 1;
            end_x_r = smb_available_right ? smb_pix_width : (smb_pix_width - 1);
            start_x_rn = (smb_available_left && smb_available_down) ? 0 : 1;
            end_x_rn = smb_available_down ? (smb_available_right ? smb_pix_width : (smb_pix_width - 1)) : 1;
            //SAO_EO_45_c(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            uavs3d_sao_eo_45_armv7(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            break;
        }
        case SAO_TYPE_BO: {
            //SAO_BO_c(src, dst, i_src, i_dst, sao_params->offset, sao_params->bandIdx, smb_pix_width, smb_pix_height, bit_depth);
            uavs3d_sao_bo_armv7(src, dst, i_src, i_dst, sao_params->offset, sao_params->bandIdx, smb_pix_width, smb_pix_height, bit_depth);
            break;
        }
        default:{
            fprintf(stderr, "Not a supported SAO types\n");
            assert(0);
            exit(-1);
        }
    }
}

void uavs3d_sao_on_lcu_chroma_armv7(pel *src, int i_src, pel *dst, int i_dst, com_sao_param_t *sao_params, int smb_pix_height, int smb_pix_width, int smb_available_left, int smb_available_right, int smb_available_up, int smb_available_down, int bit_depth)
{
    int type;
    int start_x, end_x, start_y, end_y;
    int start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn;

    type = sao_params->type;

    smb_pix_width <<= 1;
    switch (type) {
        case SAO_TYPE_EO_0: {
            start_x = smb_available_left ? 0 : 2;
            end_x = smb_available_right ? smb_pix_width : (smb_pix_width - 2);
            //SAO_EO_0_chroma_c(src, dst, i_src, i_dst, sao_params->offset, start_x, end_x, smb_pix_height, uavs3d_sao_mask, bit_depth);
            uavs3d_sao_eo_0_chroma_armv7(src, dst, i_src, i_dst, sao_params->offset, start_x, end_x, smb_pix_height, uavs3d_sao_mask, bit_depth);
            break;
        }
        case SAO_TYPE_EO_90: {
            start_y = smb_available_up ? 0 : 1;
            end_y = smb_available_down ? smb_pix_height : (smb_pix_height - 1);
            //SAO_EO_90_chroma_c(src, dst, i_src, i_dst, sao_params->offset, start_y, end_y, smb_pix_width, bit_depth);
            uavs3d_sao_eo_90_chroma_armv7(src, dst, i_src, i_dst, sao_params->offset, start_y, end_y, smb_pix_width, bit_depth);
            break;
        }
        case SAO_TYPE_EO_135: {
            start_x_r0 = (smb_available_up && smb_available_left) ? 0 : 2;
            end_x_r0 = smb_available_up ? (smb_available_right ? smb_pix_width : (smb_pix_width - 2)) : 2;
            start_x_r = smb_available_left ? 0 : 2;
            end_x_r = smb_available_right ? smb_pix_width : (smb_pix_width - 2);
            start_x_rn = smb_available_down ? (smb_available_left ? 0 : 2) : (smb_pix_width - 2);
            end_x_rn = (smb_available_right && smb_available_down) ? smb_pix_width : (smb_pix_width - 2);
            //SAO_EO_135_chroma_c(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            uavs3d_sao_eo_135_chroma_armv7(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);

            break;
        }
        case SAO_TYPE_EO_45: {
            start_x_r0 = smb_available_up ? (smb_available_left ? 0 : 2) : (smb_pix_width - 2);
            end_x_r0 = (smb_available_up && smb_available_right) ? smb_pix_width : (smb_pix_width - 2);
            start_x_r = smb_available_left ? 0 : 2;
            end_x_r = smb_available_right ? smb_pix_width : (smb_pix_width - 2);
            start_x_rn = (smb_available_left && smb_available_down) ? 0 : 2;
            end_x_rn = smb_available_down ? (smb_available_right ? smb_pix_width : (smb_pix_width - 2)) : 2;
            //SAO_EO_45_chroma_c(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            uavs3d_sao_eo_45_chroma_armv7(src, dst, i_src, i_dst, sao_params->offset, uavs3d_sao_mask, smb_pix_height, bit_depth, start_x_r0, end_x_r0, start_x_r, end_x_r, start_x_rn, end_x_rn);
            break;
        }
        case SAO_TYPE_BO: {
            //SAO_BO_chroma_c(src, dst, i_src, i_dst, sao_params->offset, sao_params->bandIdx, smb_pix_width, smb_pix_height, bit_depth);
            uavs3d_sao_bo_chroma_armv7(src, dst, i_src, i_dst, sao_params->offset, sao_params->bandIdx, smb_pix_width, smb_pix_height, bit_depth);
            break;
        }
        default:{
            fprintf(stderr, "Not a supported SAO types\n");
            assert(0);
            exit(-1);
        }
    }
}

#endif
