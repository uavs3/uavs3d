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

#include "modules.h"

void com_recon_l(s16 *resi, pel *pred, int i_pred, int width, int height, pel *rec, int i_rec, int cbf, int bit_depth)
{
    int i, j;

    if (cbf == 0) {
        for (i = 0; i < height; i++) {
            memcpy(rec, pred, width * sizeof(pel));
            rec += i_rec;
            pred += i_pred;
        }
    } else {
        int max_val = (1 << bit_depth) - 1;

        for (i = 0; i < height; i++) {
            for (j = 0; j < width; j++) {
                int t0 = *resi++ + pred[j];
                rec[j] = COM_CLIP3(0, max_val, t0);
            }
            pred += i_pred;
            rec += i_rec;
        }
    }
}

void com_recon_c(s16 *resi_u, s16 *resi_v, pel *pred, int width, int height, pel *rec, int i_rec, u8 cbf[2], int bit_depth)
{
    int i, j;
    int width2 = width << 1;
    pel *p = pred;
    pel *r = rec;
    int max_val = (1 << bit_depth) - 1;

    if (cbf[0] && cbf[1]) {
        for (i = 0; i < height; i++) {
            for (j = 0; j < width; j++) {
                int j2 = j << 1;
                int t0 = resi_u[j] + p[j2    ];
                int t1 = resi_v[j] + p[j2 + 1];
                r[j2    ] = COM_CLIP3(0, max_val, t0);
                r[j2 + 1] = COM_CLIP3(0, max_val, t1);
            }
            r += i_rec;
            resi_u += width;
            resi_v += width;
            p += width2;
        }
    } else {
        if (cbf[0] == 0) {
            for (i = 0; i < height; i++) {
                for (j = 0; j < width; j++) {
                    int j2 = j << 1;
                    int t0 = resi_v[j] + p[j2 + 1];
                    r[j2    ] = p[j2];
                    r[j2 + 1] = COM_CLIP3(0, max_val, t0);
                }
                r += i_rec;
                resi_v += width;
                p += width2;
            }
        }
        else {
            for (i = 0; i < height; i++) {
                for (j = 0; j < width; j++) {
                    int j2 = j << 1;
                    int t0 = resi_u[j] + p[j2];
                    r[j2    ] = COM_CLIP3(0, max_val, t0);
                    r[j2 + 1] = p[j2 + 1];
                }
                r += i_rec;
                resi_u += width;
                p += width2;
            }
        }
    }
}

void uavs3d_funs_init_recon_c() {
    int i;
    for (i = 0; i < BLOCK_WIDTH_TYPES_NUM; i++) {
        uavs3d_funs_handle.recon_luma[i] = com_recon_l;
        uavs3d_funs_handle.recon_chroma[i] = com_recon_c;
    }
}