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

#include "def_arm64.S"

#if defined(__arm64__)
//*************************************************************************************************
//void uavs3d_itrans_dct8_pb4_arm64(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *it);
//x0->coeff blk, 16 bit
//x1->resi blk, 16 bit
//x7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dct8_pb4_arm64
    neg w15, w2
    dup v28.8h, w5
    dup v29.8h, w6
    dup v30.4s, w15

    //load 变换系数(4x4)
    ld1 {v0.16b}, [x7]

    //扩展到16bit
    sxtl2 v2.8h, v0.16b
    sxtl  v0.8h, v0.8b
    ext   v1.16b, v0.16b, v0.16b, #8
    ext   v3.16b, v2.16b, v2.16b, #8

    lsl x3, x3, #1

    cmp x2, #5
    bne dct8_pb4_2nd

    mov x8, #0
loopi_1st:
    add x9, x8, x0
    ld1 {v4.4h}, [x9], x3
    ld1 {v5.4h}, [x9], x3
    ld1 {v6.4h}, [x9], x3
    ld1 {v7.4h}, [x9]

    smull v16.4s, v0.4h, v4.h[0]
    smull v17.4s, v0.4h, v4.h[1]
    smull v18.4s, v0.4h, v4.h[2]
    smull v19.4s, v0.4h, v4.h[3]
    smlal v16.4s, v1.4h, v5.h[0]
    smlal v17.4s, v1.4h, v5.h[1]
    smlal v18.4s, v1.4h, v5.h[2]
    smlal v19.4s, v1.4h, v5.h[3]
    smlal v16.4s, v2.4h, v6.h[0]
    smlal v17.4s, v2.4h, v6.h[1]
    smlal v18.4s, v2.4h, v6.h[2]
    smlal v19.4s, v2.4h, v6.h[3]
    smlal v16.4s, v3.4h, v7.h[0]
    smlal v17.4s, v3.4h, v7.h[1]
    smlal v18.4s, v3.4h, v7.h[2]
    smlal v19.4s, v3.4h, v7.h[3]

    sqrshrn  v16.4h, v16.4s, #5
    sqrshrn2 v16.8h, v17.4s, #5
    sqrshrn  v17.4h, v18.4s, #5
    sqrshrn2 v17.8h, v19.4s, #5

    add x8, x8, #8
    smin v16.8h, v16.8h, v28.8h
    smin v17.8h, v17.8h, v28.8h
    smax v16.8h, v16.8h, v29.8h
    smax v17.8h, v17.8h, v29.8h

    cmp x8, x3
    st1 {v16.8h, v17.8h}, [x1], #32
    blt loopi_1st
    b   dct8_pb4_end

dct8_pb4_2nd:
    mov x8, #0                  // i = 0
loopi_2nd:
    add x9, x8, x0
    ld1 {v4.4h}, [x9], x3
    ld1 {v5.4h}, [x9], x3
    ld1 {v6.4h}, [x9], x3
    ld1 {v7.4h}, [x9]

    smull v16.4s, v0.4h, v4.h[0]
    smull v17.4s, v0.4h, v4.h[1]
    smull v18.4s, v0.4h, v4.h[2]
    smull v19.4s, v0.4h, v4.h[3]
    smlal v16.4s, v1.4h, v5.h[0]
    smlal v17.4s, v1.4h, v5.h[1]
    smlal v18.4s, v1.4h, v5.h[2]
    smlal v19.4s, v1.4h, v5.h[3]
    smlal v16.4s, v2.4h, v6.h[0]
    smlal v17.4s, v2.4h, v6.h[1]
    smlal v18.4s, v2.4h, v6.h[2]
    smlal v19.4s, v2.4h, v6.h[3]
    smlal v16.4s, v3.4h, v7.h[0]
    smlal v17.4s, v3.4h, v7.h[1]
    smlal v18.4s, v3.4h, v7.h[2]
    smlal v19.4s, v3.4h, v7.h[3]

    srshl v16.4s, v16.4s, v30.4s
    srshl v17.4s, v17.4s, v30.4s
    srshl v18.4s, v18.4s, v30.4s
    srshl v19.4s, v19.4s, v30.4s

    sqxtn  v16.4h, v16.4s
    sqxtn2 v16.8h, v17.4s
    sqxtn  v17.4h, v18.4s
    sqxtn2 v17.8h, v19.4s

    add x8, x8, #8
    smin v16.8h, v16.8h, v28.8h
    smin v17.8h, v17.8h, v28.8h
    smax v16.8h, v16.8h, v29.8h
    smax v17.8h, v17.8h, v29.8h

    cmp x8, x3
    st1 {v16.8h, v17.8h}, [x1], #32

    blt loopi_2nd

dct8_pb4_end:
    ret

//*************************************************************************************************
//void uavs3d_itrans_dct8_pb8_arm64(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val,s8 *it);
//x0->coeff blk, 16 bit
//x1->resi blk, 16 bit
//x7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dct8_pb8_arm64
    sub sp, sp, #64
    ld1 {v12.2d, v13.2d, v14.2d, v15.2d}, [sp]

    neg w15, w2
    dup v28.8h, w5                  // max_tr_val
    dup v29.8h, w6                  // min_tr_val
    dup v31.4s, w15                 // shift

    ld1 {v0.8b, v1.8b, v2.8b, v3.8b}, [x7], #32
    ld1 {v4.8b, v5.8b, v6.8b, v7.8b}, [x7]
    sxtl v16.8h, v0.8b
    sxtl v17.8h, v1.8b
    sxtl v18.8h, v2.8b
    sxtl v19.8h, v3.8b
    sxtl v20.8h, v4.8b
    sxtl v21.8h, v5.8b
    sxtl v22.8h, v6.8b
    sxtl v23.8h, v7.8b

    lsl x3, x3, #1
    mov x8, #0                      // i = 0
dct8_pb8_loopi:
    add x9, x0, x8
    ld1 {v0.4h}, [x9], x3
    ld1 {v1.4h}, [x9], x3
    ld1 {v2.4h}, [x9], x3
    ld1 {v3.4h}, [x9], x3
    ld1 {v4.4h}, [x9], x3
    ld1 {v5.4h}, [x9], x3
    ld1 {v6.4h}, [x9], x3
    ld1 {v7.4h}, [x9]

    smull v24.4s, v16.4h, v0.h[0]
    smull v25.4s, v16.4h, v0.h[1]
    smull v26.4s, v16.4h, v0.h[2]
    smull v27.4s, v16.4h, v0.h[3]
    smlal v24.4s, v17.4h, v1.h[0]
    smlal v25.4s, v17.4h, v1.h[1]
    smlal v26.4s, v17.4h, v1.h[2]
    smlal v27.4s, v17.4h, v1.h[3]
    smlal v24.4s, v18.4h, v2.h[0]
    smlal v25.4s, v18.4h, v2.h[1]
    smlal v26.4s, v18.4h, v2.h[2]
    smlal v27.4s, v18.4h, v2.h[3]
    smlal v24.4s, v19.4h, v3.h[0]
    smlal v25.4s, v19.4h, v3.h[1]
    smlal v26.4s, v19.4h, v3.h[2]
    smlal v27.4s, v19.4h, v3.h[3]
    smlal v24.4s, v20.4h, v4.h[0]
    smlal v25.4s, v20.4h, v4.h[1]
    smlal v26.4s, v20.4h, v4.h[2]
    smlal v27.4s, v20.4h, v4.h[3]
    smlal v24.4s, v21.4h, v5.h[0]
    smlal v25.4s, v21.4h, v5.h[1]
    smlal v26.4s, v21.4h, v5.h[2]
    smlal v27.4s, v21.4h, v5.h[3]
    smlal v24.4s, v22.4h, v6.h[0]
    smlal v25.4s, v22.4h, v6.h[1]
    smlal v26.4s, v22.4h, v6.h[2]
    smlal v27.4s, v22.4h, v6.h[3]
    smlal v24.4s, v23.4h, v7.h[0]
    smlal v25.4s, v23.4h, v7.h[1]
    smlal v26.4s, v23.4h, v7.h[2]
    smlal v27.4s, v23.4h, v7.h[3]

    smull2 v12.4s, v16.8h, v0.h[0]
    smull2 v13.4s, v16.8h, v0.h[1]
    smull2 v14.4s, v16.8h, v0.h[2]
    smull2 v15.4s, v16.8h, v0.h[3]
    smlal2 v12.4s, v17.8h, v1.h[0]
    smlal2 v13.4s, v17.8h, v1.h[1]
    smlal2 v14.4s, v17.8h, v1.h[2]
    smlal2 v15.4s, v17.8h, v1.h[3]
    smlal2 v12.4s, v18.8h, v2.h[0]
    smlal2 v13.4s, v18.8h, v2.h[1]
    smlal2 v14.4s, v18.8h, v2.h[2]
    smlal2 v15.4s, v18.8h, v2.h[3]
    smlal2 v12.4s, v19.8h, v3.h[0]
    smlal2 v13.4s, v19.8h, v3.h[1]
    smlal2 v14.4s, v19.8h, v3.h[2]
    smlal2 v15.4s, v19.8h, v3.h[3]
    smlal2 v12.4s, v20.8h, v4.h[0]
    smlal2 v13.4s, v20.8h, v4.h[1]
    smlal2 v14.4s, v20.8h, v4.h[2]
    smlal2 v15.4s, v20.8h, v4.h[3]
    smlal2 v12.4s, v21.8h, v5.h[0]
    smlal2 v13.4s, v21.8h, v5.h[1]
    smlal2 v14.4s, v21.8h, v5.h[2]
    smlal2 v15.4s, v21.8h, v5.h[3]
    smlal2 v12.4s, v22.8h, v6.h[0]
    smlal2 v13.4s, v22.8h, v6.h[1]
    smlal2 v14.4s, v22.8h, v6.h[2]
    smlal2 v15.4s, v22.8h, v6.h[3]
    smlal2 v12.4s, v23.8h, v7.h[0]
    smlal2 v13.4s, v23.8h, v7.h[1]
    smlal2 v14.4s, v23.8h, v7.h[2]
    smlal2 v15.4s, v23.8h, v7.h[3]

    cmp x2, #5
    bne dct8_pb8_shift12

    sqrshrn  v24.4h, v24.4s, #5
    sqrshrn  v25.4h, v25.4s, #5
    sqrshrn  v26.4h, v26.4s, #5
    sqrshrn  v27.4h, v27.4s, #5
    sqrshrn2 v24.8h, v12.4s, #5
    sqrshrn2 v25.8h, v13.4s, #5
    sqrshrn2 v26.8h, v14.4s, #5
    sqrshrn2 v27.8h, v15.4s, #5

    b dct8_pb8_clip_store

dct8_pb8_shift12:
	srshl v24.4s, v24.4s, v31.4s
    srshl v25.4s, v25.4s, v31.4s
    srshl v26.4s, v26.4s, v31.4s
    srshl v27.4s, v27.4s, v31.4s
    srshl v12.4s, v12.4s, v31.4s
    srshl v13.4s, v13.4s, v31.4s
    srshl v14.4s, v14.4s, v31.4s
    srshl v15.4s, v15.4s, v31.4s

    sqxtn  v24.4h, v24.4s
    sqxtn  v25.4h, v25.4s
    sqxtn  v26.4h, v26.4s
    sqxtn  v27.4h, v27.4s
    sqxtn2 v24.8h, v12.4s
    sqxtn2 v25.8h, v13.4s
    sqxtn2 v26.8h, v14.4s
    sqxtn2 v27.8h, v15.4s

dct8_pb8_clip_store:
    add x8, x8, #8
    smin v24.8h, v24.8h, v28.8h
    smin v25.8h, v25.8h, v28.8h
    smin v26.8h, v26.8h, v28.8h
    smin v27.8h, v27.8h, v28.8h
    smax v24.8h, v24.8h, v29.8h
    smax v25.8h, v25.8h, v29.8h
    smax v26.8h, v26.8h, v29.8h
    smax v27.8h, v27.8h, v29.8h

    cmp x8, x3
    st1 {v24.8h, v25.8h, v26.8h, v27.8h}, [x1], #64
    blt dct8_pb8_loopi

    ld1 {v12.2d, v13.2d, v14.2d, v15.2d}, [sp], #64
    ret

//*************************************************************************************************
//void uavs3d_itrans_dct8_pb16_arm64(s16 *coeff, s16 *resi, int shift, int line, int limit_line, int max_tr_val, int min_tr_val,s8 *it)
//x0->coeff blk, 16 bit
//x1->resi blk, 16 bit
//x7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dct8_pb16_arm64
    sub sp, sp, #64
    st1 {v12.2d, v13.2d, v14.2d, v15.2d}, [sp]

    neg w15, w2
    dup v28.8h, w5                  // max_tr_val
    dup v29.8h, w6                  // min_tr_val
    dup v31.4s, w15                 // shift

    mov x10, #16                    // it_stride
    mov x14, #32                    // resi_stride
    mov x13, x3                     // line - i
    lsl x3, x3, #1                  // coeff_stride = line*sizeof(s16)
dct8_pb16_loopi:
    mov x12, #0                     // j
    mov x11, x1                     // resi + i*16
dct8_pb16_loopj:
    add x8, x7, x12                 // it + j
    mov x9, x0                      // coeff + i

    ld1 {v16.8b}, [x8], x10         // load it first 8 lines
    ld1 {v17.8b}, [x8], x10
    ld1 {v18.8b}, [x8], x10
    ld1 {v19.8b}, [x8], x10
    ld1 {v20.8b}, [x8], x10
    ld1 {v21.8b}, [x8], x10
    ld1 {v22.8b}, [x8], x10
    ld1 {v23.8b}, [x8], x10

    sxtl v16.8h, v16.8b
    sxtl v17.8h, v17.8b
    sxtl v18.8h, v18.8b
    sxtl v19.8h, v19.8b
    sxtl v20.8h, v20.8b
    sxtl v21.8h, v21.8b
    sxtl v22.8h, v22.8b
    sxtl v23.8h, v23.8b

    ld1 {v0.4h}, [x9], x3
    ld1 {v1.4h}, [x9], x3
    ld1 {v2.4h}, [x9], x3
    ld1 {v3.4h}, [x9], x3
    ld1 {v4.4h}, [x9], x3
    ld1 {v5.4h}, [x9], x3
    ld1 {v6.4h}, [x9], x3
    ld1 {v7.4h}, [x9], x3

    smull v24.4s, v16.4h, v0.h[0]
    smull v25.4s, v16.4h, v0.h[1]
    smull v26.4s, v16.4h, v0.h[2]
    smull v27.4s, v16.4h, v0.h[3]
    smlal v24.4s, v17.4h, v1.h[0]
    smlal v25.4s, v17.4h, v1.h[1]
    smlal v26.4s, v17.4h, v1.h[2]
    smlal v27.4s, v17.4h, v1.h[3]
    smlal v24.4s, v18.4h, v2.h[0]
    smlal v25.4s, v18.4h, v2.h[1]
    smlal v26.4s, v18.4h, v2.h[2]
    smlal v27.4s, v18.4h, v2.h[3]
    smlal v24.4s, v19.4h, v3.h[0]
    smlal v25.4s, v19.4h, v3.h[1]
    smlal v26.4s, v19.4h, v3.h[2]
    smlal v27.4s, v19.4h, v3.h[3]
    smlal v24.4s, v20.4h, v4.h[0]
    smlal v25.4s, v20.4h, v4.h[1]
    smlal v26.4s, v20.4h, v4.h[2]
    smlal v27.4s, v20.4h, v4.h[3]
    smlal v24.4s, v21.4h, v5.h[0]
    smlal v25.4s, v21.4h, v5.h[1]
    smlal v26.4s, v21.4h, v5.h[2]
    smlal v27.4s, v21.4h, v5.h[3]
    smlal v24.4s, v22.4h, v6.h[0]
    smlal v25.4s, v22.4h, v6.h[1]
    smlal v26.4s, v22.4h, v6.h[2]
    smlal v27.4s, v22.4h, v6.h[3]
    smlal v24.4s, v23.4h, v7.h[0]
    smlal v25.4s, v23.4h, v7.h[1]
    smlal v26.4s, v23.4h, v7.h[2]
    smlal v27.4s, v23.4h, v7.h[3]

    smull2 v12.4s, v16.8h, v0.h[0]
    smull2 v13.4s, v16.8h, v0.h[1]
    smull2 v14.4s, v16.8h, v0.h[2]
    smull2 v15.4s, v16.8h, v0.h[3]
    smlal2 v12.4s, v17.8h, v1.h[0]
    smlal2 v13.4s, v17.8h, v1.h[1]
    smlal2 v14.4s, v17.8h, v1.h[2]
    smlal2 v15.4s, v17.8h, v1.h[3]
    smlal2 v12.4s, v18.8h, v2.h[0]
    smlal2 v13.4s, v18.8h, v2.h[1]
    smlal2 v14.4s, v18.8h, v2.h[2]
    smlal2 v15.4s, v18.8h, v2.h[3]
    smlal2 v12.4s, v19.8h, v3.h[0]
    smlal2 v13.4s, v19.8h, v3.h[1]
    smlal2 v14.4s, v19.8h, v3.h[2]
    smlal2 v15.4s, v19.8h, v3.h[3]
    smlal2 v12.4s, v20.8h, v4.h[0]
    smlal2 v13.4s, v20.8h, v4.h[1]
    smlal2 v14.4s, v20.8h, v4.h[2]
    smlal2 v15.4s, v20.8h, v4.h[3]
    smlal2 v12.4s, v21.8h, v5.h[0]
    smlal2 v13.4s, v21.8h, v5.h[1]
    smlal2 v14.4s, v21.8h, v5.h[2]
    smlal2 v15.4s, v21.8h, v5.h[3]
    smlal2 v12.4s, v22.8h, v6.h[0]
    smlal2 v13.4s, v22.8h, v6.h[1]
    smlal2 v14.4s, v22.8h, v6.h[2]
    smlal2 v15.4s, v22.8h, v6.h[3]
    smlal2 v12.4s, v23.8h, v7.h[0]
    smlal2 v13.4s, v23.8h, v7.h[1]
    smlal2 v14.4s, v23.8h, v7.h[2]
    smlal2 v15.4s, v23.8h, v7.h[3]

    ld1 {v16.8b}, [x8], x10         // load it bottom 8 lines
    ld1 {v17.8b}, [x8], x10
    ld1 {v18.8b}, [x8], x10
    ld1 {v19.8b}, [x8], x10
    ld1 {v20.8b}, [x8], x10
    ld1 {v21.8b}, [x8], x10
    ld1 {v22.8b}, [x8], x10
    ld1 {v23.8b}, [x8], x10

    sxtl v16.8h, v16.8b
    sxtl v17.8h, v17.8b
    sxtl v18.8h, v18.8b
    sxtl v19.8h, v19.8b
    sxtl v20.8h, v20.8b
    sxtl v21.8h, v21.8b
    sxtl v22.8h, v22.8b
    sxtl v23.8h, v23.8b

    ld1 {v0.4h}, [x9], x3
    ld1 {v1.4h}, [x9], x3
    ld1 {v2.4h}, [x9], x3
    ld1 {v3.4h}, [x9], x3
    ld1 {v4.4h}, [x9], x3
    ld1 {v5.4h}, [x9], x3
    ld1 {v6.4h}, [x9], x3
    ld1 {v7.4h}, [x9], x3

    smlal v24.4s, v16.4h, v0.h[0]
    smlal v25.4s, v16.4h, v0.h[1]
    smlal v26.4s, v16.4h, v0.h[2]
    smlal v27.4s, v16.4h, v0.h[3]
    smlal v24.4s, v17.4h, v1.h[0]
    smlal v25.4s, v17.4h, v1.h[1]
    smlal v26.4s, v17.4h, v1.h[2]
    smlal v27.4s, v17.4h, v1.h[3]
    smlal v24.4s, v18.4h, v2.h[0]
    smlal v25.4s, v18.4h, v2.h[1]
    smlal v26.4s, v18.4h, v2.h[2]
    smlal v27.4s, v18.4h, v2.h[3]
    smlal v24.4s, v19.4h, v3.h[0]
    smlal v25.4s, v19.4h, v3.h[1]
    smlal v26.4s, v19.4h, v3.h[2]
    smlal v27.4s, v19.4h, v3.h[3]
    smlal v24.4s, v20.4h, v4.h[0]
    smlal v25.4s, v20.4h, v4.h[1]
    smlal v26.4s, v20.4h, v4.h[2]
    smlal v27.4s, v20.4h, v4.h[3]
    smlal v24.4s, v21.4h, v5.h[0]
    smlal v25.4s, v21.4h, v5.h[1]
    smlal v26.4s, v21.4h, v5.h[2]
    smlal v27.4s, v21.4h, v5.h[3]
    smlal v24.4s, v22.4h, v6.h[0]
    smlal v25.4s, v22.4h, v6.h[1]
    smlal v26.4s, v22.4h, v6.h[2]
    smlal v27.4s, v22.4h, v6.h[3]
    smlal v24.4s, v23.4h, v7.h[0]
    smlal v25.4s, v23.4h, v7.h[1]
    smlal v26.4s, v23.4h, v7.h[2]
    smlal v27.4s, v23.4h, v7.h[3]

    smlal2 v12.4s, v16.8h, v0.h[0]
    smlal2 v13.4s, v16.8h, v0.h[1]
    smlal2 v14.4s, v16.8h, v0.h[2]
    smlal2 v15.4s, v16.8h, v0.h[3]
    smlal2 v12.4s, v17.8h, v1.h[0]
    smlal2 v13.4s, v17.8h, v1.h[1]
    smlal2 v14.4s, v17.8h, v1.h[2]
    smlal2 v15.4s, v17.8h, v1.h[3]
    smlal2 v12.4s, v18.8h, v2.h[0]
    smlal2 v13.4s, v18.8h, v2.h[1]
    smlal2 v14.4s, v18.8h, v2.h[2]
    smlal2 v15.4s, v18.8h, v2.h[3]
    smlal2 v12.4s, v19.8h, v3.h[0]
    smlal2 v13.4s, v19.8h, v3.h[1]
    smlal2 v14.4s, v19.8h, v3.h[2]
    smlal2 v15.4s, v19.8h, v3.h[3]
    smlal2 v12.4s, v20.8h, v4.h[0]
    smlal2 v13.4s, v20.8h, v4.h[1]
    smlal2 v14.4s, v20.8h, v4.h[2]
    smlal2 v15.4s, v20.8h, v4.h[3]
    smlal2 v12.4s, v21.8h, v5.h[0]
    smlal2 v13.4s, v21.8h, v5.h[1]
    smlal2 v14.4s, v21.8h, v5.h[2]
    smlal2 v15.4s, v21.8h, v5.h[3]
    smlal2 v12.4s, v22.8h, v6.h[0]
    smlal2 v13.4s, v22.8h, v6.h[1]
    smlal2 v14.4s, v22.8h, v6.h[2]
    smlal2 v15.4s, v22.8h, v6.h[3]
    smlal2 v12.4s, v23.8h, v7.h[0]
    smlal2 v13.4s, v23.8h, v7.h[1]
    smlal2 v14.4s, v23.8h, v7.h[2]
    smlal2 v15.4s, v23.8h, v7.h[3]

    cmp x2, #5
    bne dct8_pb16_shift12

    sqrshrn  v24.4h, v24.4s, #5
    sqrshrn  v25.4h, v25.4s, #5
    sqrshrn  v26.4h, v26.4s, #5
    sqrshrn  v27.4h, v27.4s, #5
    sqrshrn2 v24.8h, v12.4s, #5
    sqrshrn2 v25.8h, v13.4s, #5
    sqrshrn2 v26.8h, v14.4s, #5
    sqrshrn2 v27.8h, v15.4s, #5

    b dct8_pb16_clip_store

dct8_pb16_shift12:
    srshl v24.4s, v24.4s, v31.4s
    srshl v25.4s, v25.4s, v31.4s
    srshl v26.4s, v26.4s, v31.4s
    srshl v27.4s, v27.4s, v31.4s
    srshl v12.4s, v12.4s, v31.4s
    srshl v13.4s, v13.4s, v31.4s
    srshl v14.4s, v14.4s, v31.4s
    srshl v15.4s, v15.4s, v31.4s

    sqxtn  v24.4h, v24.4s
    sqxtn  v25.4h, v25.4s
    sqxtn  v26.4h, v26.4s
    sqxtn  v27.4h, v27.4s
    sqxtn2 v24.8h, v12.4s
    sqxtn2 v25.8h, v13.4s
    sqxtn2 v26.8h, v14.4s
    sqxtn2 v27.8h, v15.4s

dct8_pb16_clip_store:
    add x11, x1, x12, lsl #1            // resi + i*16 + j
    add x12, x12, #8                    // j += 8

    smin v24.8h, v24.8h, v28.8h
    smin v25.8h, v25.8h, v28.8h
    smin v26.8h, v26.8h, v28.8h
    smin v27.8h, v27.8h, v28.8h
    smax v24.8h, v24.8h, v29.8h
    smax v25.8h, v25.8h, v29.8h
    smax v26.8h, v26.8h, v29.8h
    smax v27.8h, v27.8h, v29.8h

    cmp x12, #16
    st1 {v24.8h}, [x11], x14
    st1 {v25.8h}, [x11], x14
    st1 {v26.8h}, [x11], x14
    st1 {v27.8h}, [x11], x14

    blt dct8_pb16_loopj

    add  x0, x0, #8                     // coeff += 4
    add  x1, x1, #128                   // resi += resi_stride * 4
    subs x13, x13, #4                   // i += 4
    bgt dct8_pb16_loopi

    ld1 {v12.2d, v13.2d, v14.2d, v15.2d}, [sp], #64
    ret


#endif
