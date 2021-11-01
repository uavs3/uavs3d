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
 *    This product includes the software uAVS3d developed by
 *    Peking University Shenzhen Graduate School, Peng Cheng Laboratory
 *    and Guangdong Bohua UHD Innovation Corporation.
 * 4. Neither the name of the organizations (Peking University Shenzhen Graduate School,
 *    Peng Cheng Laboratory and Guangdong Bohua UHD Innovation Corporation) nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * For more information, contact us at rgwang@pkusz.edu.cn.
 **************************************************************************************/

#include "def_arm64.S"

#if defined(__arm64__)

#if !COMPILE_10BIT

/******************************************************************************************************
*  void uavs3d_padding_rows_lr_arm64(pel_t *src, int i_src, int width, int height, int start, int rows,int pad)
*  src->x0, i_src->x1, width->x2, rows->x3, pad->x4
******************************************************************************************************/
function uavs3d_padding_rows_lr_arm64

    sub x7, x2, #1    // width - 1

padding_rows_lr_y:
    mov x8, #0
    add x5, x0, x7   // p[width - 1]

    ld1r {v0.16b}, [x0]
    ld1r {v1.16b}, [x5]        // right reference pointer

    sub x5, x0, x4
    add x6, x0, x2

    sub x9, x4, #15

padding_rows_lr_x:

    add x8, x8,#16
    st1 {v0.16b}, [x5], #16    // store 16 byte to [x10]
    st1 {v1.16b}, [x6],  #16    // store 16 byte to [x8]

    cmp x8, x9
    blt padding_rows_lr_x

    cmp x8, x4
    beq padding_rows_lr_loop
    st1 {v0.8b}, [x5]
    st1 {v1.8b}, [x6]

padding_rows_lr_loop:
    subs x3, x3, #1
    add x0, x0, x1
    bgt padding_rows_lr_y

    ret

/******************************************************************************************************
 *  void uavs3d_padding_rows_chroma_lr_arm64(pel_t *src, int i_src, int width, int height, int start, int rows,int pad)
 *  src->x0, i_src->x1, width->x2, rows->x3, padh->x4
 ******************************************************************************************************/
function uavs3d_padding_rows_chroma_lr_arm64

    sub x7, x2, #2          // width - 2

padding_rows_chroma_lr_y:
    mov x8, #0

    ld1r {v0.8h}, [x0]     // src[0] src[1]

    add x5, x0, x7         // src[width - 2]
    ld1r {v1.8h}, [x5]     // right reference pointer

    sub x5, x0, x4
    add x6, x0, x2

    sub x9, x4, #15

padding_rows_chroma_lr_x:

    add x8, x8, #16
    st1 {v0.16b}, [x5], #16    // store 16 byte to [x10]
    st1 {v1.16b}, [x6], #16    // store 16 byte to [x8]

    cmp x8, x9
    blt padding_rows_chroma_lr_x

    cmp x8, x4
    beq padding_rows_chroma_lr_loop
    st1 {v0.8b}, [x5]
    st1 {v1.8b}, [x6]

padding_rows_chroma_lr_loop:
    subs x3, x3, #1
    add x0, x0, x1
    bgt padding_rows_chroma_lr_y

    ret

//void uavs3d_avg_pel_w4_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w4_arm64

avg_pel_w4_y:
    ld1 {v0.2d}, [x2], #16
    ld1 {v1.2d}, [x3], #16
    urhadd v2.16b, v0.16b, v1.16b

    subs w5, w5, #4
    st1  {v2.s}[0], [x0], x1
    st1  {v2.s}[1], [x0], x1
    st1  {v2.s}[2], [x0], x1
    st1  {v2.s}[3], [x0], x1
    bgt avg_pel_w4_y

    ret

//void uavs3d_avg_pel_w8_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w8_arm64

avg_pel_w8_y:
    ld1 {v0.2d, v1.2d}, [x2], #32
    ld1 {v2.2d, v3.2d}, [x3], #32
    urhadd v0.16b, v0.16b, v2.16b
    urhadd v1.16b, v1.16b, v3.16b

    subs w5, w5, #4
    st1  {v0.d}[0], [x0], x1
    st1  {v0.d}[1], [x0], x1
    st1  {v1.d}[0], [x0], x1
    st1  {v1.d}[1], [x0], x1
    bgt avg_pel_w8_y

    ret

//void uavs3d_avg_pel_w16_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w16_arm64

avg_pel_w16_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x3], #64
    urhadd v0.16b, v0.16b, v4.16b
    urhadd v1.16b, v1.16b, v5.16b
    urhadd v2.16b, v2.16b, v6.16b
    urhadd v3.16b, v3.16b, v7.16b

    subs w5, w5, #4
    st1  {v0.2d}, [x0], x1
    st1  {v1.2d}, [x0], x1
    st1  {v2.2d}, [x0], x1
    st1  {v3.2d}, [x0], x1
    bgt avg_pel_w16_y

    ret

//void uavs3d_avg_pel_w32_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w32_arm64

avg_pel_w32_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    urhadd v0.16b, v0.16b, v20.16b
    urhadd v1.16b, v1.16b, v21.16b
    urhadd v2.16b, v2.16b, v22.16b
    urhadd v3.16b, v3.16b, v23.16b
    urhadd v4.16b, v4.16b, v24.16b
    urhadd v5.16b, v5.16b, v25.16b
    urhadd v6.16b, v6.16b, v26.16b
    urhadd v7.16b, v7.16b, v27.16b

    subs w5, w5, #4
    st1  {v0.2d, v1.2d}, [x0], x1
    st1  {v2.2d, v3.2d}, [x0], x1
    st1  {v4.2d, v5.2d}, [x0], x1
    st1  {v6.2d, v7.2d}, [x0], x1
    bgt avg_pel_w32_y

    ret

//void uavs3d_avg_pel_w64_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w64_arm64

avg_pel_w64_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    urhadd v0.16b, v0.16b, v20.16b
    urhadd v1.16b, v1.16b, v21.16b
    urhadd v2.16b, v2.16b, v22.16b
    urhadd v3.16b, v3.16b, v23.16b
    urhadd v4.16b, v4.16b, v24.16b
    urhadd v5.16b, v5.16b, v25.16b
    urhadd v6.16b, v6.16b, v26.16b
    urhadd v7.16b, v7.16b, v27.16b

    subs w5, w5, #2
    st1  {v0.2d, v1.2d, v2.2d, v3.2d}, [x0], x1
    st1  {v4.2d, v5.2d, v6.2d, v7.2d}, [x0], x1

    bgt avg_pel_w64_y

    ret

//void uavs3d_avg_pel_w128_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w128_arm64
    sub x1, x1, #64
avg_pel_w128_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    urhadd v0.16b, v0.16b, v20.16b
    urhadd v1.16b, v1.16b, v21.16b
    urhadd v2.16b, v2.16b, v22.16b
    urhadd v3.16b, v3.16b, v23.16b
    urhadd v4.16b, v4.16b, v24.16b
    urhadd v5.16b, v5.16b, v25.16b
    urhadd v6.16b, v6.16b, v26.16b
    urhadd v7.16b, v7.16b, v27.16b

    subs w5, w5, #1
    st1  {v0.2d, v1.2d, v2.2d, v3.2d}, [x0], #64
    st1  {v4.2d, v5.2d, v6.2d, v7.2d}, [x0], x1
    bgt avg_pel_w128_y

    ret

#else

/******************************************************************************************************
*  void uavs3d_padding_rows_lr_arm64(pel_t *src, int i_src, int width, int height, int start, int rows,int pad)
*  src->x0, i_src->x1, width->x2, rows->x3, pad->x4
******************************************************************************************************/
function uavs3d_padding_rows_lr_arm64

    lsl x2, x2, #1
    lsl x1, x1, #1
    lsl x4, x4, #1
    sub x7, x2, #2                  // width - 1

padding_rows_lr_y:
    mov x8, #0
    add x5, x0, x7                  // p[width - 1]

    ld1r {v0.8h}, [x0]
    ld1r {v2.8h}, [x5]              // right reference pointer
    mov v1.8h, v0.8h
    mov v3.8h, v2.8h

    sub x5, x0, x4
    add x6, x0, x2

    sub x9, x4, #30

padding_rows_lr_x:

    add x8, x8, #32
    st1 {v0.8h, v1.8h}, [x5], #32   // store 16 byte to [x10]
    st1 {v2.8h, v3.8h}, [x6], #32   // store 16 byte to [x8]

    cmp x8, x9
    blt padding_rows_lr_x

    cmp x8, x4
    beq padding_rows_lr_loop
    st1 {v0.8h}, [x5]
    st1 {v2.8h}, [x6]

padding_rows_lr_loop:
    subs x3, x3, #1
    add  x0, x0, x1
    bgt padding_rows_lr_y

    ret

/******************************************************************************************************
 *  void uavs3d_padding_rows_chroma_lr_arm64(pel_t *src, int i_src, int width, int height, int start, int rows,int pad)
 *  src->x0, i_src->x1, width->x2, rows->x3, padh->x4
 ******************************************************************************************************/
function uavs3d_padding_rows_chroma_lr_arm64

    lsl x2, x2, #1
    lsl x1, x1, #1
    lsl x4, x4, #1
    sub x7, x2, #4                  // width - 2

padding_rows_chroma_lr_y:
    mov x8, #0
    add x5, x0, x7                  // src[width - 2]

    ld1r {v0.4s}, [x0]              // src[0] src[1]
    ld1r {v2.4s}, [x5]              // right reference pointer

    mov v1.4s, v0.4s
    mov v3.4s, v2.4s

    sub x5, x0, x4
    add x6, x0, x2

    sub x9, x4, #30

padding_rows_chroma_lr_x:

    add x8, x8, #32
    st1 {v0.4s, v1.4s}, [x5], #32    // store 16 byte to [x10]
    st1 {v2.4s, v3.4s}, [x6], #32    // store 16 byte to [x8]

    cmp x8, x9
    blt padding_rows_chroma_lr_x

    cmp x8, x4
    beq padding_rows_chroma_lr_loop
    st1 {v0.8h}, [x5]
    st1 {v2.8h}, [x6]

padding_rows_chroma_lr_loop:
    subs x3, x3, #1
    add  x0, x0, x1
    bgt padding_rows_chroma_lr_y

    ret

//void uavs3d_avg_pel_w4_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w4_arm64

    lsl x1, x1, #1

    add x10, x1, x1     // i_dst*2
    lsl x12, x1, #2     // i_dst*4
    add x11, x10, x1    // i_dst*3
avg_pel_w4_y:
    ld1 {v0.2d, v1.2d}, [x2], #32
    ld1 {v2.2d, v3.2d}, [x3], #32
    urhadd v0.8h, v0.8h, v2.8h
    urhadd v1.8h, v1.8h, v3.8h

    add  x13, x0, x1
    add  x14, x0, x10
    add  x15, x0, x11
    st1  {v0.d}[0], [x0]
    st1  {v0.d}[1], [x13]
    st1  {v1.d}[0], [x14]
    st1  {v1.d}[1], [x15]

    subs w5, w5, #4
    add x0, x0, x12     // dst += i_dst*4
    bgt avg_pel_w4_y

    ret

//void uavs3d_avg_pel_w8_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w8_arm64

    lsl x1, x1, #1

avg_pel_w8_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x3], #64

    urhadd v0.8h, v0.8h, v4.8h
    urhadd v1.8h, v1.8h, v5.8h
    urhadd v2.8h, v2.8h, v6.8h
    urhadd v3.8h, v3.8h, v7.8h

    subs w5, w5, #4
    st1  {v0.2d}, [x0], x1
    st1  {v1.2d}, [x0], x1
    st1  {v2.2d}, [x0], x1
    st1  {v3.2d}, [x0], x1

    bgt avg_pel_w8_y

    ret

//void uavs3d_avg_pel_w16_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w16_arm64
    lsl x1, x1, #1
avg_pel_w16_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    urhadd v0.8h, v0.8h, v20.8h
    urhadd v1.8h, v1.8h, v21.8h
    urhadd v2.8h, v2.8h, v22.8h
    urhadd v3.8h, v3.8h, v23.8h
    urhadd v4.8h, v4.8h, v24.8h
    urhadd v5.8h, v5.8h, v25.8h
    urhadd v6.8h, v6.8h, v26.8h
    urhadd v7.8h, v7.8h, v27.8h

    subs w5, w5, #4
    st1  {v0.2d, v1.2d}, [x0], x1
    st1  {v2.2d, v3.2d}, [x0], x1
    st1  {v4.2d, v5.2d}, [x0], x1
    st1  {v6.2d, v7.2d}, [x0], x1

    bgt avg_pel_w16_y

    ret

//void uavs3d_avg_pel_w32_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w32_arm64
    lsl x1, x1, #1
avg_pel_w32_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    urhadd v0.8h, v0.8h, v20.8h
    urhadd v1.8h, v1.8h, v21.8h
    urhadd v2.8h, v2.8h, v22.8h
    urhadd v3.8h, v3.8h, v23.8h
    urhadd v4.8h, v4.8h, v24.8h
    urhadd v5.8h, v5.8h, v25.8h
    urhadd v6.8h, v6.8h, v26.8h
    urhadd v7.8h, v7.8h, v27.8h

    subs w5, w5, #2
    st1  {v0.2d, v1.2d, v2.2d, v3.2d}, [x0], x1
    st1  {v4.2d, v5.2d, v6.2d, v7.2d}, [x0], x1
    bgt avg_pel_w32_y

    ret

//void uavs3d_avg_pel_w64_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w64_arm64
    lsl x1, x1, #1
    sub x1, x1, #64
avg_pel_w64_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    urhadd v0.8h, v0.8h, v20.8h
    urhadd v1.8h, v1.8h, v21.8h
    urhadd v2.8h, v2.8h, v22.8h
    urhadd v3.8h, v3.8h, v23.8h
    urhadd v4.8h, v4.8h, v24.8h
    urhadd v5.8h, v5.8h, v25.8h
    urhadd v6.8h, v6.8h, v26.8h
    urhadd v7.8h, v7.8h, v27.8h

    subs w5, w5, #1
    st1  {v0.2d, v1.2d, v2.2d, v3.2d}, [x0], #64
    st1  {v4.2d, v5.2d, v6.2d, v7.2d}, [x0], x1
    bgt avg_pel_w64_y

    ret

//void uavs3d_avg_pel_w128_arm64(pel_t *dst, int i_dst, pel_t *src1, pel_t *src2, int width, int height);
//dst->x0, i_dst->x1, src1->x2, src2->x3, width->x4, height->x5
function uavs3d_avg_pel_w128_arm64
    lsl x1, x1, #1
    sub x1, x1, #192
avg_pel_w128_y:
    ld1 {v0.2d, v1.2d, v2.2d, v3.2d}, [x2], #64
    ld1 {v4.2d, v5.2d, v6.2d, v7.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    urhadd v0.8h, v0.8h, v20.8h
    urhadd v1.8h, v1.8h, v21.8h
    urhadd v2.8h, v2.8h, v22.8h
    urhadd v3.8h, v3.8h, v23.8h
    urhadd v4.8h, v4.8h, v24.8h
    urhadd v5.8h, v5.8h, v25.8h
    urhadd v6.8h, v6.8h, v26.8h
    urhadd v7.8h, v7.8h, v27.8h

    ld1 {v16.2d, v17.2d, v18.2d, v19.2d}, [x2], #64
    ld1 {v28.2d, v29.2d, v30.2d, v31.2d}, [x2], #64

    ld1 {v20.2d, v21.2d, v22.2d, v23.2d}, [x3], #64
    ld1 {v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64

    subs w5, w5, #1
    st1  {v0.2d, v1.2d, v2.2d, v3.2d}, [x0], #64
    st1  {v4.2d, v5.2d, v6.2d, v7.2d}, [x0], #64

    urhadd v16.8h, v16.8h, v20.8h
    urhadd v17.8h, v17.8h, v21.8h
    urhadd v18.8h, v18.8h, v22.8h
    urhadd v19.8h, v19.8h, v23.8h
    urhadd v28.8h, v28.8h, v24.8h
    urhadd v29.8h, v29.8h, v25.8h
    urhadd v30.8h, v30.8h, v26.8h
    urhadd v31.8h, v31.8h, v27.8h

    st1  {v16.2d, v17.2d, v18.2d, v19.2d}, [x0], #64
    st1  {v28.2d, v29.2d, v30.2d, v31.2d}, [x0], x1
    bgt avg_pel_w128_y

    ret

#endif

//void uavs3d_conv_fmt_8bit_arm64(u8* src_y, u8* src_uv, u8* dst[3], int width, int height, int stride, int stridec, int dst_stride[3], int uv_shift)
//src_y->x0, src_uv->x1, dst->x2, width->x3, height->x4, stride->x5, stridec->x6, dst_stride->x7, uv_shift->x20
function uavs3d_conv_fmt_8bit_arm64

    stp x20, x21, [sp, #-16]
    stp x22, x23, [sp, #-32]
    ldr w20, [sp]
    sub sp, sp, #32

    and x11, x3, #63            // width % 64
    and x13, x3, #15            // width % 16
    sub x10, x3, x11            // width64 = width - (width % 64)
    sub x12, x3, x13            // width16 = width - (width % 16)

    mov w8, #0                  // i = 0
    mov x23, #0
    ldr x22, [x2]               // pdst = dst[0]
    ldr w23, [x7]               // dst_stride[0]
copy_y_height_loop:
    mov x9, #0                  // j = 0
    mov x14, #0
    mov x15, x0
    mov x21, x22                //
copy_y_width_loop64:
    add x14, x9, #64
    cmp x14, x10
    bgt copy_y_width_loop16
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x15], #64
    mov x9, x14
    st1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x21], #64
    b copy_y_width_loop64

copy_y_width_loop16:
    add x14, x9, #16
    cmp x14, x12
    bgt copy_y_width_loop1
    ld1 {v0.16b}, [x15], #16
    mov x9, x14
    st1 {v0.16b}, [x21], #16
    b copy_y_width_loop16

copy_y_width_loop1:
    cmp x9, x3
    bge copy_y_width_end
    ldrb w11, [x15], #1
    add x9, x9, #1
    strb w11, [x21], #1
    b copy_y_width_loop1

copy_y_width_end:
    add w8, w8, #1
    add x0, x0, x5
    add x22, x22, x23
    cmp w8, w4
    blt copy_y_height_loop

    lsr w3, w3, w20             // width >>= uv_shift
    lsr w4, w4, w20             // height >>= uv_shift

    and w11, w3, #31            // width % 32
    and w13, w3, #7             // width % 8
    sub w10, w3, w11            // width32 = width - (width % 32)
    sub w12, w3, w13            // width8  = width - (width % 8)

    mov x23, #0
    mov x0, x1                  // src = src_uv
    ldr x22, [x2, #8]           // pdst = dst[1]
    ldr w23, [x7, #4]           // dst_stride[1]
    mov w8, #0                  // i = 0
copy_u_height_loop:
    mov w9, #0                  // j = 0
    mov w14, #0
    mov x15, x0
    mov x21, x22
copy_u_width_loop32:
    add w14, w9, #32
    cmp w14, w10
    bgt copy_u_width_loop8
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x15], #64
    mov w9, w14                 // j += 32
    xtn v0.8b, v0.8h
    xtn v1.8b, v1.8h
    xtn v2.8b, v2.8h
    xtn v3.8b, v3.8h
    st1 {v0.8b, v1.8b, v2.8b, v3.8b}, [x21], #32
    b copy_u_width_loop32

copy_u_width_loop8:
    add w14, w9, #8
    cmp w14, w12
    bgt copy_u_width_loop1
    ld1 {v0.16b}, [x15], #16
    mov w9, w14                 // j += 8
    xtn v0.8b, v0.8h
    st1 {v0.8b}, [x21], #8
    b copy_u_width_loop8

copy_u_width_loop1:
    cmp w9, w3
    bge copy_u_width_end
    ldrb w11, [x15], #2
    add w9, w9, #1
    strb w11, [x21], #1
    b copy_u_width_loop1

copy_u_width_end:
    add w8, w8, #1              // i++
    add x0, x0, x6              // src += stridec
    add x22, x22, x23
    cmp w8, w4
    blt copy_u_height_loop

    add x0, x1, #1              // src = src_uv + 1
    mov x23, #0
    ldr x22, [x2, #16]          // pdst = dst[2]
    ldr w23, [x7, #8]           // dst_stride[2]
    mov w8, #0                  // i = 0
copy_v_height_loop:
    mov w9, #0                  // j = 0
    mov w14, #0
    mov x15, x0
    mov x21, x22
copy_v_width_loop32:
    add w14, w9, #32
    cmp w14, w10
    bgt copy_v_width_loop8
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x15], #64
    mov w9, w14                 // j += 32
    xtn v0.8b, v0.8h
    xtn v1.8b, v1.8h
    xtn v2.8b, v2.8h
    xtn v3.8b, v3.8h
    st1 {v0.8b, v1.8b, v2.8b, v3.8b}, [x21], #32
    b copy_v_width_loop32

copy_v_width_loop8:
    add w14, w9, #8
    cmp w14, w12
bgt copy_v_width_loop1
    ld1 {v0.16b}, [x15], #16
    mov w9, w14                 // j += 8
    xtn v0.8b, v0.8h
    st1 {v0.8b}, [x21], #8
    b copy_v_width_loop8

copy_v_width_loop1:
    cmp w9, w3
    bge copy_v_width_end
    ldrb w11, [x15], #2
    add w9, w9, #1
    strb w11, [x21], #1
    b copy_v_width_loop1

copy_v_width_end:
    add w8, w8, #1              // i++
    add x0, x0, x6              // src += stridec
    add x22, x22, x23
    cmp w8, w4
    blt copy_v_height_loop

    ldp x22, x23, [sp]
    ldp x20, x21, [sp, #16]
    add sp, sp, #32

    ret

//void uavs3d_conv_fmt_16bit_arm64(u8* src_y, u8* src_uv, u8* dst[3], int width, int height, int stride, int stridec, int dst_stride[3], int uv_shift)
//src_y->x0, src_uv->x1, dst->x2, width->x3, height->x4, stride->x5, stridec->x6, dst_stride->x7, uv_shift->x20
function uavs3d_conv_fmt_16bit_arm64

    stp x20, x21, [sp, #-16]
    stp x22, x23, [sp, #-32]
    ldr w20, [sp]
    sub sp, sp, #32

    and x11, x3, #31            // width % 32
    and x13, x3, #7             // width % 8
    sub x10, x3, x11            // width32 = width - (width % 32)
    sub x12, x3, x13            // width8  = width - (width % 8)

    mov w8, #0                  // i = 0
    mov x23, #0
    ldr x22, [x2]               // pdst = dst[0]
    ldr w23, [x7]               // dst_stride[0]

conv_fmt_16bit_y_height_loop:
    mov x9, #0                  // j = 0
    mov x14, #0
    mov x15, x0
    mov x21, x22
conv_fmt_16bit_y_width_loop32:
    add x14, x9, #32
    cmp x14, x10
    bgt conv_fmt_16bit_y_width_loop8
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x15], #64
    mov x9, x14
    st1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x21], #64
    b conv_fmt_16bit_y_width_loop32

conv_fmt_16bit_y_width_loop8:
    add x14, x9, #8
    cmp x14, x12
    bgt conv_fmt_16bit_y_width_loop1
    ld1 {v0.16b}, [x15], #16
    mov x9, x14
    st1 {v0.16b}, [x21], #16
    b conv_fmt_16bit_y_width_loop8

conv_fmt_16bit_y_width_loop1:
    cmp x9, x3
    bge conv_fmt_16bit_y_width_end
    ldrh w11, [x15], #2
    add x9, x9, #1
    strh w11, [x21], #2
    b conv_fmt_16bit_y_width_loop1

conv_fmt_16bit_y_width_end:
    add w8, w8, #1
    add x0, x0, x5
    add x22, x22, x23
    cmp w8, w4
    blt conv_fmt_16bit_y_height_loop

    lsr w3, w3, w20             // width >>= uv_shift
    lsr w4, w4, w20             // height >>= uv_shift

    and x11, x3, #15            // width % 16
    and x13, x3, #3             // width % 4
    sub x10, x3, x11            // width16 = width - (width % 16)
    sub x12, x3, x13            // width4  = width - (width % 4)

    mov x0, x1                  // src = src_uv
    mov w8, #0                  // i = 0
    mov x23, #0
    ldr x22, [x2, #8]           // pdst = dst[0]
    ldr w23, [x7, #4]           // dst_stride[0]

conv_fmt_16bit_u_height_loop:
    mov w9, #0                  // j = 0
    mov w14, #0
    mov x15, x0
    mov x21, x22
conv_fmt_16bit_u_width_loop16:
    add w14, w9, #16
    cmp w14, w10
    bgt conv_fmt_16bit_u_width_loop4
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x15], #64
    mov w9, w14                 // j += 16
    xtn v0.4h, v0.4s
    xtn v1.4h, v1.4s
    xtn v2.4h, v2.4s
    xtn v3.4h, v3.4s
    st1 {v0.4h, v1.4h, v2.4h, v3.4h}, [x21], #32
    b conv_fmt_16bit_u_width_loop16

conv_fmt_16bit_u_width_loop4:
    add w14, w9, #4
    cmp w14, w12
    bgt conv_fmt_16bit_u_width_loop1
    ld1 {v0.8h}, [x15], #16
    mov w9, w14                 // j += 4
    xtn v0.4h, v0.4s
    st1 {v0.4h}, [x21], #8
    b conv_fmt_16bit_u_width_loop4

conv_fmt_16bit_u_width_loop1:
    cmp w9, w3
    bge conv_fmt_16bit_u_width_end
    ldrh w11, [x15], #4
    add w9, w9, #1
    strh w11, [x21], #2
    b conv_fmt_16bit_u_width_loop1

conv_fmt_16bit_u_width_end:
    add w8, w8, #1              // i++
    add x0, x0, x6              // src += stridec
    add x22, x22, x23
    cmp w8, w4
    blt conv_fmt_16bit_u_height_loop

    add x0, x1, #2              // src = src_uv + 2
    mov w8, #0                  // i = 0
    ldr x22, [x2, #16]          // pdst = dst[2]
    ldr w23, [x7, #8]           // dst_stride[2]
conv_fmt_16bit_v_height_loop:
    mov w9, #0                  // j = 0
    mov w14, #0
    mov x15, x0
conv_fmt_16bit_v_width_loop16:
    add w14, w9, #16
    cmp w14, w10
    bgt conv_fmt_16bit_v_width_loop4
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x15], #64
    mov w9, w14                 // j += 16
    xtn v0.4h, v0.4s
    xtn v1.4h, v1.4s
    xtn v2.4h, v2.4s
    xtn v3.4h, v3.4s
    st1 {v0.4h, v1.4h, v2.4h, v3.4h}, [x21], #32
    b conv_fmt_16bit_v_width_loop16

conv_fmt_16bit_v_width_loop4:
    add w14, w9, #4
    cmp w14, w12
    bgt conv_fmt_16bit_v_width_loop1
    ld1 {v0.8h}, [x15], #16
    mov w9, w14                 // j += 4
    xtn v0.4h, v0.4s
    st1 {v0.4h}, [x21], #8
    b conv_fmt_16bit_v_width_loop4

conv_fmt_16bit_v_width_loop1:
    cmp w9, w3
    bge conv_fmt_16bit_v_width_end
    ldrh w11, [x15], #4
    add w9, w9, #1
    strh w11, [x21], #2
    b conv_fmt_16bit_v_width_loop1

conv_fmt_16bit_v_width_end:
    add w8, w8, #1              // i++
    add x0, x0, x6              // src += stridec
    add x22, x22, x23
    cmp w8, w4
    blt conv_fmt_16bit_v_height_loop

    ret

#endif
