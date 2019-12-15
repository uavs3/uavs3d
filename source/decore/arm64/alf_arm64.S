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

#if !COMPILE_10BIT

/********************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_arm64(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->x0, i_dst->x1, src->x2, i_src->x3, lcu_width->x4, lcu_height->x5, coef->x6
 ********************************************************************************************************************************************/
function uavs3d_alf_one_lcu_arm64

    //x19-x28 are callee-saved registers
    stp x19, x20, [sp, #-16]
    stp x21, x22, [sp, #-32]
    stp x23, x24, [sp, #-48]
    sub sp, sp, #48

    ld1 {v2.4s, v3.4s}, [x6]        // load coef[0-7]
    xtn v0.4h, v2.4s
    xtn v1.4h, v3.4s
    add x6, x6, #32
    ld1 {v4.2s}, [x6]               // load coef[8]
    xtn v2.4h, v4.4s

    mov w8, #0                      // w8 : i = startPos
    sub w15, w5, #1                 // w15: lcu_height - 1
    sub w19, w5, #3                 // lcu_height - 3

alf_arm64_loop_y:
    sub x9 , x2, x3                 // imgPad2 = src - i_src;
    add x10, x2, x3                 // imgPad1 = src + i_src;
    sub x11, x2, x3, lsl #1         // imgPad4 = src - 2*i_src;
    add x12, x2, x3, lsl #1         // imgPad3 = src + 2*i_src;
    sub x13, x11, x3                // imgPad6 = src - 3*i_src;
    add x14, x12, x3                // imgPad5 = src + 3*i_src;

    cmp w8, #3
    bge alf_arm64_y_ge_3
    cmp w8, #1
    beq alf_arm64_y_eq_1
    bgt alf_arm64_y_eq_2
    mov x9, x2                      // i == 0
alf_arm64_y_eq_1:
    mov x11, x9                     // i == 1
alf_arm64_y_eq_2:
    mov x13, x11                    // i == 2

    b alf_arm64_y_lt_h_minus_3

alf_arm64_y_ge_3:
    cmp w8, w19
    blt alf_arm64_y_lt_h_minus_3
    beq alf_arm64_y_eq_h_minus_3
    cmp w8, w15
    blt alf_arm64_y_eq_h_minus_2
    mov x10, x2                     // i == lcu_height - 1
alf_arm64_y_eq_h_minus_2:
    mov x12, x10                    // i == lcu_height - 2
alf_arm64_y_eq_h_minus_3:
    mov x14, x12                    // i == lcu_height - 3

alf_arm64_y_lt_h_minus_3:

    mov x20, #0                     // j = 0
alf_arm64_loop_x:
    add x21, x13, x20
    add x22, x14, x20
    add x23, x11, x20
    add x24, x12, x20

    ld1 {v3.8b}, [x21]
    ld1 {v4.8b}, [x22]
    ld1 {v5.8b}, [x23]
    ld1 {v6.8b}, [x24]

    add x21, x9 , x20
    add x22, x10, x20
    sub x21, x21, #1
    sub x22, x22, #1

    uaddl  v3.8h, v3.8b, v4.8b
    uaddl  v5.8h, v5.8b, v6.8b
    smull  v16.4s, v3.4h, v0.h[0]   // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    smull2 v17.4s, v3.8h, v0.h[0]
    smlal  v16.4s, v5.4h, v0.h[1]   // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);
    smlal2 v17.4s, v5.8h, v0.h[1]

    ld1 {v3.8b, v4.8b}, [x21]       // load imgPad2[j-1]
    ld1 {v5.8b, v6.8b}, [x22]       // load imgPad1[j-1]

    ext v18.8b, v3.8b, v4.8b, #2    // imgPad2[j+1]
    ext v19.8b, v5.8b, v6.8b, #2    // imgPad1[j+1]
    ext v4.8b, v3.8b, v4.8b, #1     // imgPad2[j]
    ext v6.8b, v5.8b, v6.8b, #1     // imgPad1[j]

    uaddl v20.8h, v19.8b, v3.8b
    uaddl v21.8h, v4.8b, v6.8b
    uaddl v22.8h, v5.8b, v18.8b

    add x21, x2, x20
    sub x22, x21, #3

    smlal  v16.4s, v20.4h, v0.h[2]  // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    smlal2 v17.4s, v20.8h, v0.h[2]
    smlal  v16.4s, v21.4h, v0.h[3]  // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    smlal2 v17.4s, v21.8h, v0.h[3]
    smlal  v16.4s, v22.4h, v1.h[0]  // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])
    smlal2 v17.4s, v22.8h, v1.h[0]

    ld1 {v3.8b, v4.8b}, [x22]       // load imgPad[j-3]

    ext v5.8b, v3.8b, v4.8b, #1     // imgPad[j-2]
    ext v6.8b, v3.8b, v4.8b, #2     // imgPad[j-1]
    ext v7.8b, v3.8b, v4.8b, #3     // imgPad[j]
    ext v22.8b, v3.8b, v4.8b, #4    // imgPad[j+1]
    ext v18.8b, v3.8b, v4.8b, #5    // imgPad[j+2]
    ext v19.8b, v3.8b, v4.8b, #6    // imgPad[j+3]

    uaddl v20.8h, v19.8b, v3.8b
    uaddl v21.8h, v18.8b, v5.8b

    smlal  v16.4s, v20.4h, v1.h[1]  // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    smlal2 v17.4s, v20.8h, v1.h[1]
    smlal  v16.4s, v21.4h, v1.h[2]  // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    smlal2 v17.4s, v21.8h, v1.h[2]

    uaddl v20.8h, v22.8b, v6.8b
    uxtl  v21.8h, v7.8b
    smlal v16.4s, v20.4h, v1.h[3]   // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    smlal2 v17.4s, v20.8h, v1.h[3]
    smlal v16.4s, v21.4h, v2.h[0]   // pixelInt += coef[8] * (imgPad[j])
    smlal2 v17.4s, v21.8h, v2.h[0]

    add   x21, x0, x20
    rshrn  v16.4h, v16.4s, #6
    rshrn2 v16.8h, v17.4s, #6
    sqxtun v16.8b, v16.8h

    add   x20, x20, #8
    st1   {v16.8b}, [x21]           // store imgRes[j]

    cmp   x20, x4
    blt   alf_arm64_loop_x

    add   w8, w8, #1
    add   x0, x0, x1
    add   x2, x2, x3
    cmp   w8, w5
    blt   alf_arm64_loop_y

    add sp, sp, #48
    ldp x19, x20, [sp, #-16]
    ldp x21, x22, [sp, #-32]
    ldp x23, x24, [sp, #-48]

    ret

/***************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_chroma_arm64(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->x0, i_dst->x1, src->x2, i_src->x3, lcu_width->x4, lcu_height->x5, coef->x6
 ***************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_chroma_arm64
    sub sp, sp, #48
    sub x9, sp, #16
    stp x19, x20, [sp]
    stp x21, x22, [sp, #16]
    st1 {v8.2d}, [x9]

    ld1 {v2.4s, v3.4s, v4.4s, v5.4s}, [x6], #64
    ld1 {v6.4s}, [x6]
    xtn  v0.4h, v2.4s
    xtn2 v0.8h, v3.4s
    xtn  v1.4h, v4.4s
    xtn2 v1.8h, v5.4s
    xtn  v2.4h, v6.4s

    lsl w4, w4, #1                      // lcu_width *= 2
    mov w8, #0                          // i = 0
    sub w6, w5, #1                      // w6: lcu_height - 1
    sub w7, w5, #3                      // lcu_height - 3

    dup v3.4s, v0.s[0]                  // coef[0] for U, coef[1] for V
    dup v4.4s, v0.s[1]
    dup v5.4s, v0.s[2]
    dup v6.4s, v0.s[3]
    dup v7.4s, v1.s[0]
    dup v8.4s, v1.s[1]
    dup v0.4s, v1.s[2]
    dup v1.4s, v1.s[3]
    dup v2.4s, v2.s[0]
alf_chroma_arm64_loop_y:
    sub x14, x2, x3                     // imgPad2 = src - i_src;
    add x15, x2, x3                     // imgPad1 = src + i_src;
    sub x19, x2, x3, lsl #1             // imgPad4 = src - 2*i_src;
    add x20, x2, x3, lsl #1             // imgPad3 = src + 2*i_src;
    sub x21, x19, x3                    // imgPad6 = src - 3*i_src;
    add x22, x20, x3                    // imgPad5 = src + 3*i_src;

    cmp w8, #3
    bge alf_chroma_arm64_y_ge_3
    cmp w8, #1
    beq alf_chroma_arm64_y_eq_1
    bgt alf_chroma_arm64_y_eq_2
    mov x14, x2                         // i == 0: imgPad2 = src
alf_chroma_arm64_y_eq_1:
    mov x19, x14                        // i == 1
alf_chroma_arm64_y_eq_2:
    mov x21, x19                        // i == 2

b alf_chroma_arm64_y_lt_h_minus_3

alf_chroma_arm64_y_ge_3:
    cmp w8, w7
    blt alf_chroma_arm64_y_lt_h_minus_3
    beq alf_chroma_arm64_y_eq_h_minus_3
    cmp w8, w6                          // cmp i and lcu_height - 1
    blt alf_chroma_arm64_y_eq_h_minus_2
    mov x15, x2                         // i == lcu_height - 1
alf_chroma_arm64_y_eq_h_minus_2:
    mov x20, x15                        // i == lcu_height - 2
alf_chroma_arm64_y_eq_h_minus_3:
    mov x22, x20                        // i == lcu_height - 3

alf_chroma_arm64_y_lt_h_minus_3:

    mov x9, #0                          // j = xPos
alf_chroma_arm64_loop_x:
    add x10, x21, x9                    // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    add x11, x22, x9
    add x12, x20, x9                    // pixelInt += coef[2] * (imgPad3[j] + imgPad4[j])
    add x13, x19, x9
    ld1 {v21.8h}, [x10]
    ld1 {v22.8h}, [x11]
    ld1 {v23.8h}, [x12]
    ld1 {v24.8h}, [x13]
    uaddl  v16.8h, v22.8b , v21.8b
    uaddl2 v17.8h, v22.16b, v21.16b
    uaddl  v27.8h, v23.8b , v24.8b
    uaddl2 v28.8h, v23.16b, v24.16b
    smull  v19.4s, v16.4h, v3.4h
    smull  v20.4s, v17.4h, v3.4h
    smull2 v30.4s, v16.8h, v3.8h
    smull2 v31.4s, v17.8h, v3.8h
    smlal  v19.4s, v27.4h, v4.4h
    smlal  v20.4s, v28.4h, v4.4h
    smlal2 v30.4s, v27.8h, v4.8h
    smlal2 v31.4s, v28.8h, v4.8h

    add x10, x15, x9
    add x12, x14, x9
    sub x10, x10, #2
    sub x12, x12, #2
    ld1 {v22.8h, v23.8h}, [x10]         // imgPad1[j - 2] (left)
    ld1 {v28.8h, v29.8h}, [x12]         // imgPad2[j - 2] (left)
    ext v24.16b, v22.16b, v23.16b, #2   // imgPad1[j]
    ext v25.16b, v28.16b, v29.16b, #2   // imgPad2[j]
    ext v26.16b, v28.16b, v29.16b, #4   // imgPad2[j + 2]
    ext v27.16b, v22.16b, v23.16b, #4   // imgPad1[j + 2]

    uaddl  v16.8h, v22.8b , v26.8b      // pixelInt += coef[8] * (imgPad1[j - 2] + imgPad2[j + 2])
    uaddl2 v17.8h, v22.16b, v26.16b
    uaddl  v18.8h, v24.8b , v25.8b      // pixelInt += coef[6] * (imgPad1[j] + imgPad2[j])
    uaddl2 v21.8h, v24.16b, v25.16b
    uaddl  v23.8h, v27.8b , v28.8b      // pixelInt += coef[4] * (imgPad1[j + 2] + imgPad2[j - 2])
    uaddl2 v29.8h, v27.16b, v28.16b

    add x10, x2, x9                     // get imgPad[j - 6] - imgPad[j + 6]
    sub x10, x10, #6

    smlal  v19.4s, v16.4h, v7.4h
    smlal  v20.4s, v17.4h, v7.4h
    smlal2 v30.4s, v16.8h, v7.8h
    smlal2 v31.4s, v17.8h, v7.8h
    smlal  v19.4s, v18.4h, v6.4h
    smlal  v20.4s, v21.4h, v6.4h
    smlal2 v30.4s, v18.8h, v6.8h
    smlal2 v31.4s, v21.8h, v6.8h

    ld1 {v21.8h, v22.8h}, [x10]         // v21: imgPad[j - 6]
    smlal  v19.4s, v23.4h, v5.4h
    smlal  v20.4s, v29.4h, v5.4h
    smlal2 v30.4s, v23.8h, v5.8h
    smlal2 v31.4s, v29.8h, v5.8h

    ext v23.16b, v21.16b, v22.16b, #12  // imgPad[j + 6]
    ext v24.16b, v21.16b, v22.16b, #6   // imgPad[j]

    uaddl  v25.8h, v21.8b, v23.8b       // pixelInt += coef[10] * (imgPad[j + 6] + imgPad[j - 6])
    uaddl2 v26.8h, v21.16b, v23.16b
    uxtl   v16.8h, v24.8b
    uxtl2  v17.8h, v24.16b

    smlal  v19.4s, v25.4h, v8.4h
    smlal  v20.4s, v26.4h, v8.4h
    smlal2 v30.4s, v25.8h, v8.8h
    smlal2 v31.4s, v26.8h, v8.8h

    smlal  v19.4s, v16.4h, v2.4h       // pixelInt += coef[16] * (imgPad[j])
    smlal  v20.4s, v17.4h, v2.4h
    smlal2 v30.4s, v16.8h, v2.8h
    smlal2 v31.4s, v17.8h, v2.8h

    ext v23.16b, v21.16b, v22.16b, #2   // imgPad[j - 4]
    ext v24.16b, v21.16b, v22.16b, #4   // imgPad[j - 2]
    ext v25.16b, v21.16b, v22.16b, #8   // imgPad[j + 2]
    ext v26.16b, v21.16b, v22.16b, #10  // imgPad[j + 4]

    uaddl  v16.8h, v26.8b , v23.8b      // pixelInt += coef[12] * (imgPad[j + 4] + imgPad[j - 4])
    uaddl2 v17.8h, v26.16b, v23.16b
    uaddl  v18.8h, v25.8b , v24.8b      // pixelInt += coef[14] * (imgPad[j + 2] + imgPad[j - 2])
    uaddl2 v26.8h, v25.16b, v24.16b

    smlal  v19.4s, v16.4h, v0.4h
    smlal  v20.4s, v17.4h, v0.4h
    smlal2 v30.4s, v16.8h, v0.8h
    smlal2 v31.4s, v17.8h, v0.8h
    smlal  v19.4s, v18.4h, v1.4h
    smlal  v20.4s, v26.4h, v1.4h
    smlal2 v30.4s, v18.8h, v1.8h
    smlal2 v31.4s, v26.8h, v1.8h

    add x10, x0, x9
    rshrn  v19.4h, v19.4s, #6
    rshrn  v20.4h, v20.4s, #6
    rshrn2 v19.8h, v30.4s, #6
    rshrn2 v20.8h, v31.4s, #6
    sqxtun v19.8b, v19.8h
    sqxtun v20.8b, v20.8h

    add x9, x9, #16
    st1 {v19.8b, v20.8b}, [x10]

    cmp x9, x4
    blt alf_chroma_arm64_loop_x

    add w8, w8, #1
    add x0, x0, x1
    add x2, x2, x3
    cmp w8, w5
    blt alf_chroma_arm64_loop_y

    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ld1 {v8.2d}, [sp], #16

    ret

/*******************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_one_chroma_arm64(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->x0, i_dst->x1, src->x2, i_src->x3, lcu_width->x4, lcu_height->x5, coef->x6
 *******************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_one_chroma_arm64
    stp x19, x20, [sp, #-16]
    stp x21, x22, [sp, #-32]
    sub sp, sp, #32

    mov w10, #0x00ff
    dup v27.8h, w10                     // mask_uv

    ld1 {v2.4s, v3.4s, v4.4s, v5.4s}, [x6], #64
    ld1 {v6.4s}, [x6]
    xtn  v0.4h, v2.4s
    xtn2 v0.8h, v3.4s
    xtn  v1.4h, v4.4s
    xtn2 v1.8h, v5.4s
    xtn  v2.4h, v6.4s

    lsl w4, w4, #1                      // lcu_width *= 2
    mov w8, #0                          // i = 0
    sub w6, w5, #1                      // w6: lcu_height - 1
    sub w7, w5, #3                      // lcu_height - 3

    xtn  v0.4h, v0.4s
    xtn2 v0.8h, v1.4s
    xtn  v1.4h, v2.4s

alf_one_chroma_arm64_loop_y:
    sub x14, x2, x3                     // imgPad2 = src - i_src;
    add x15, x2, x3                     // imgPad1 = src + i_src;
    sub x19, x2, x3, lsl #1             // imgPad4 = src - 2*i_src;
    add x20, x2, x3, lsl #1             // imgPad3 = src + 2*i_src;
    sub x21, x19, x3                    // imgPad6 = src - 3*i_src;
    add x22, x20, x3                    // imgPad5 = src + 3*i_src;

    cmp w8, #3
    bge alf_one_chroma_arm64_y_ge_3
    cmp w8, #1
    beq alf_one_chroma_arm64_y_eq_1
    bgt alf_one_chroma_arm64_y_eq_2
    mov x14, x2                         // i == 0: imgPad2 = src
alf_one_chroma_arm64_y_eq_1:
    mov x19, x14                        // i == 1
alf_one_chroma_arm64_y_eq_2:
    mov x21, x19                        // i == 2

    b alf_one_chroma_arm64_y_lt_h_minus_3

alf_one_chroma_arm64_y_ge_3:
    cmp w8, w7
    blt alf_one_chroma_arm64_y_lt_h_minus_3
    beq alf_one_chroma_arm64_y_eq_h_minus_3
    cmp w8, w6                          // cmp i and lcu_height - 1
    blt alf_one_chroma_arm64_y_eq_h_minus_2
    mov x15, x2                         // i == lcu_height - 1
alf_one_chroma_arm64_y_eq_h_minus_2:
    mov x20, x15                        // i == lcu_height - 2
alf_one_chroma_arm64_y_eq_h_minus_3:
    mov x22, x20                        // i == lcu_height - 3

alf_one_chroma_arm64_y_lt_h_minus_3:

    mov x9, #0                          // j = xPos
alf_one_chroma_arm64_loop_x:
    add x10, x21, x9                    // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    add x11, x22, x9
    add x12, x19, x9                    // pixelInt += coef[2] * (imgPad3[j] + imgPad4[j])
    add x13, x20, x9
    ld1 {v22.8h}, [x10]
    ld1 {v23.8h}, [x11]
    ld1 {v24.8h}, [x12]
    ld1 {v25.8h}, [x13]
    xtn v2.8b, v22.8h                   // delete one chroma
    xtn v3.8b, v23.8h
    xtn v4.8b, v24.8h
    xtn v5.8b, v25.8h
    uaddl v2.8h, v2.8b, v3.8b
    uaddl v4.8h, v4.8b, v5.8b
    smull  v30.4s, v2.4h, v0.h[0]       // coef[0]
    smull2 v31.4s, v2.8h, v0.h[0]
    smlal  v30.4s, v4.4h, v0.h[1]
    smlal2 v31.4s, v4.8h, v0.h[1]

    add x10, x15, x9                    // get imgPad1[j - 2], imgPad1[j], imgPad1[j + 2], imgPad2[j - 2], imgPad2[j], imgPad2[j + 2]
    add x12, x14, x9
    sub x10, x10, #2
    sub x12, x12, #2
    ld1 {v22.8h, v23.8h}, [x10]         // imgPad1[j - 2] (left)
    ld1 {v3.8h , v4.8h }, [x12]         // imgPad2[j - 2] (left)
    xtn v22.8b, v22.8h
    xtn v23.8b, v23.8h
    xtn v3.8b, v3.8h
    xtn v4.8b, v4.8h

    ext v18.8b, v22.8b, v23.8b, #1      // imgPad1[j]
    ext v19.8b, v3.8b, v4.8b, #1        // imgPad2[j]
    ext v20.8b, v22.8b, v23.8b, #2      // imgPad1[j + 2]
    ext v21.8b, v3.8b, v4.8b, #2        // imgPad2[j + 2]

    uaddl v6.8h, v22.8b, v21.8b
    uaddl v7.8h, v18.8b, v19.8b
    uaddl v28.8h, v20.8b, v3.8b

    smlal  v30.4s, v6.4h, v0.h[4]       // pixelInt += coef[8] * (imgPad1[j - 2] + imgPad2[j + 2])
    smlal2 v31.4s, v6.8h, v0.h[4]
    smlal  v30.4s, v7.4h, v0.h[3]       // pixelInt += coef[6] * (imgPad1[j] + imgPad2[j])
    smlal2 v31.4s, v7.8h, v0.h[3]
    smlal  v30.4s, v28.4h, v0.h[2]      // pixelInt += coef[4] * (imgPad1[j + 2] + imgPad2[j - 2])
    smlal2 v31.4s, v28.8h, v0.h[2]

    add x10, x2, x9                     // get imgPad[j - 6] - imgPad[j + 6]
    sub x10, x10, #6
    ld1 {v6.8h, v7.8h}, [x10]
    xtn v6.8b, v6.8h                    // imgPad[j - 6]
    xtn v7.8b, v7.8h
    ext v16.8b, v6.8b, v7.8b, #1        // imgPad[j - 4]
    ext v17.8b, v6.8b, v7.8b, #2        // imgPad[j - 2]
    ext v18.8b, v6.8b, v7.8b, #3        // imgPad[j]
    ext v19.8b, v6.8b, v7.8b, #4        // imgPad[j + 2]
    ext v20.8b, v6.8b, v7.8b, #5        // imgPad[j + 4]
    ext v21.8b, v6.8b, v7.8b, #6        // imgPad[j + 6]

    uaddl v29.8h, v6.8b, v21.8b         // imgPad[j + 6] + imgPad[j - 6]
    uaddl v28.8h, v16.8b, v20.8b        // imgPad[j + 4] + imgPad[j - 4]
    uaddl v7.8h, v17.8b, v19.8b         // imgPad[j + 2] + imgPad[j - 2]
    uxtl  v6.8h, v18.8b                 // imgPad[j]

    smlal  v30.4s, v29.4h, v0.h[5]      // pixelInt += coef[10] * (imgPad[j + 6] + imgPad[j - 6])
    smlal2 v31.4s, v29.8h, v0.h[5]
    smlal  v30.4s, v28.4h, v0.h[6]      // pixelInt += coef[12] * (imgPad[j + 4] + imgPad[j - 4])
    smlal2 v31.4s, v28.8h, v0.h[6]
    smlal  v30.4s, v7.4h, v0.h[7]       // pixelInt += coef[14] * (imgPad[j + 2] + imgPad[j - 2])
    smlal2 v31.4s, v7.8h, v0.h[7]
    smlal  v30.4s, v6.4h, v1.h[0]       // pixelInt += coef[16] * (imgPad[j])
    smlal2 v31.4s, v6.8h, v1.h[0]

    add x10, x0, x9

    rshrn  v30.4h, v30.4s, #6
    rshrn2 v30.8h, v31.4s, #6
    sqxtun v30.8b, v30.8h

    ld1 {v2.8h}, [x10]
    uxtl v30.8h, v30.8b
    add x9, x9, #16
    bif  v30.16b, v2.16b, v27.16b

    st1 {v30.8h}, [x10]

    cmp x9, x4
    blt alf_one_chroma_arm64_loop_x

    add w8, w8, #1
    add x0, x0, x1
    add x2, x2, x3
    cmp w8, w5
    blt alf_one_chroma_arm64_loop_y

    add sp, sp, #32
    ldp x19, x20, [sp, #-16]
    ldp x21, x22, [sp, #-32]

    ret

#else

/********************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_arm64(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int bit_depth);
 *  dst->x0, i_dst->x1, src->x2, i_src->x3, lcu_width->x4, lcu_height->x5, coef->x6, bit_depth->x7
 ********************************************************************************************************************************************/
function uavs3d_alf_one_lcu_arm64

    //x19-x28 are callee-saved registers
    stp x19, x20, [sp, #-16]
    stp x21, x22, [sp, #-32]
    stp x23, x24, [sp, #-48]
    sub sp, sp, #48

    ld1 {v2.4s, v3.4s}, [x6], #32   // load coef[0-7]

    lsl x1, x1, #1                  // i_dst *= sizeof(pel)
    lsl x3, x3, #1
    lsl x4, x4, #1                  // lcu_width *= sizeof(pel)

    ld1 {v4.2s}, [x6]               // load coef[8]

    mov w9, #1

    xtn v0.4h, v2.4s
    xtn v1.4h, v3.4s
    xtn v2.4h, v4.4s

    lsl w9, w9, w7
    sub w9, w9, #1
    dup v31.8h, w9

    mov w8, #0                      // w8 : i = startPos
    sub w15, w5, #1                 // w15: lcu_height - 1
    sub w19, w5, #3                 // lcu_height - 3

alf_arm64_loop_y:
    sub x9 , x2, x3                 // imgPad2 = src - i_src;
    add x10, x2, x3                 // imgPad1 = src + i_src;
    sub x11, x2, x3, lsl #1         // imgPad4 = src - 2*i_src;
    add x12, x2, x3, lsl #1         // imgPad3 = src + 2*i_src;
    sub x13, x11, x3                // imgPad6 = src - 3*i_src;
    add x14, x12, x3                // imgPad5 = src + 3*i_src;

    cmp w8, #3
    bge alf_arm64_y_ge_3
    cmp w8, #1
    beq alf_arm64_y_eq_1
    bgt alf_arm64_y_eq_2
    mov x9, x2                      // i == 0
alf_arm64_y_eq_1:
    mov x11, x9                     // i == 1
alf_arm64_y_eq_2:
    mov x13, x11                    // i == 2

    b alf_arm64_y_lt_h_minus_3

alf_arm64_y_ge_3:
    cmp w8, w19
    blt alf_arm64_y_lt_h_minus_3
    beq alf_arm64_y_eq_h_minus_3
    cmp w8, w15
    blt alf_arm64_y_eq_h_minus_2
    mov x10, x2                     // i == lcu_height - 1
alf_arm64_y_eq_h_minus_2:
    mov x12, x10                    // i == lcu_height - 2
alf_arm64_y_eq_h_minus_3:
    mov x14, x12                    // i == lcu_height - 3

alf_arm64_y_lt_h_minus_3:

    mov x20, #0                     // j = 0
alf_arm64_loop_x:
    add x21, x13, x20
    add x22, x14, x20
    add x23, x11, x20
    add x24, x12, x20

    ld1 {v3.8h}, [x21]
    ld1 {v4.8h}, [x22]
    ld1 {v5.8h}, [x23]
    ld1 {v6.8h}, [x24]

    add v3.8h, v3.8h, v4.8h
    add v5.8h, v5.8h, v6.8h
    smull  v16.4s, v3.4h, v0.h[0]   // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    smull2 v17.4s, v3.8h, v0.h[0]
    smlal  v16.4s, v5.4h, v0.h[1]   // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);
    smlal2 v17.4s, v5.8h, v0.h[1]

    add x21, x9 , x20
    add x22, x10, x20
    sub x23, x21, #2
    sub x24, x22, #2
    ld1 {v5.8h}, [x21]              // load imgPad2[j]
    ld1 {v6.8h}, [x22]              // load imgPad1[j]
    ld1 {v3.8h}, [x23]              // load imgPad2[j-1]
    ld1 {v4.8h}, [x24]              // load imgPad1[j-1]

    add x24, x22, #2
    add x23, x21, #2
    ld1 {v19.8h}, [x24]             // load imgPad1[j+1]
    ld1 {v18.8h}, [x23]             // load imgPad2[j+1]

    add v20.8h, v19.8h, v3.8h
    add v21.8h, v5.8h, v6.8h
    add v22.8h, v4.8h, v18.8h

    smlal  v16.4s, v20.4h, v0.h[2]  // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    smlal2 v17.4s, v20.8h, v0.h[2]
    smlal  v16.4s, v21.4h, v0.h[3]  // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    smlal2 v17.4s, v21.8h, v0.h[3]
    smlal  v16.4s, v22.4h, v1.h[0]  // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])
    smlal2 v17.4s, v22.8h, v1.h[0]

    add x21, x2, x20
    sub x22, x21, #6
    add x23, x21, #10
    ld1 {v3.8h}, [x22]              // load imgPad[j-3]
    ld1 {v4.8h}, [x23]

    ext v5.16b, v3.16b, v4.16b, #2      // imgPad[j-2]
    ext v6.16b, v3.16b, v4.16b, #4      // imgPad[j-1]
    ext v7.16b, v3.16b, v4.16b, #6      // imgPad[j]
    ext v22.16b, v3.16b, v4.16b, #8     // imgPad[j+1]
    ext v18.16b, v3.16b, v4.16b, #10    // imgPad[j+2]
    ext v19.16b, v3.16b, v4.16b, #12    // imgPad[j+3]

    add v20.8h, v19.8h, v3.8h
    add v21.8h, v18.8h, v5.8h

    smlal  v16.4s, v20.4h, v1.h[1]      // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    smlal2 v17.4s, v20.8h, v1.h[1]
    smlal  v16.4s, v21.4h, v1.h[2]      // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    smlal2 v17.4s, v21.8h, v1.h[2]

    add    v20.8h, v22.8h, v6.8h

    smlal  v16.4s, v20.4h, v1.h[3]      // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    smlal2 v17.4s, v20.8h, v1.h[3]
    smlal  v16.4s, v7.4h, v2.h[0]      // pixelInt += coef[8] * (imgPad[j])
    smlal2 v17.4s, v7.8h, v2.h[0]

    add   x21, x0, x20
    sqrshrun  v16.4h, v16.4s, #6
    sqrshrun2 v16.8h, v17.4s, #6
    
    umin v16.8h, v16.8h, v31.8h

    add   x20, x20, #16
    st1   {v16.8h}, [x21]               // store imgRes[j]

    cmp   x20, x4
    blt   alf_arm64_loop_x

    add   w8, w8, #1
    add   x0, x0, x1
    add   x2, x2, x3
    cmp   w8, w5
    blt   alf_arm64_loop_y

    add sp, sp, #48
    ldp x19, x20, [sp, #-16]
    ldp x21, x22, [sp, #-32]
    ldp x23, x24, [sp, #-48]

    ret

/***************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_chroma_arm64(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int bit_depth);
 *  dst->x0, i_dst->x1, src->x2, i_src->x3, lcu_width->x4, lcu_height->x5, coef->x6, bit_depth->x7
 ***************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_chroma_arm64
    sub sp, sp, #64
    sub x9, sp, #32
    stp x19, x20, [sp]
    stp x21, x22, [sp, #16]
    st1 {v8.2d, v9.2d}, [x9]

    ld1 {v2.4s, v3.4s, v4.4s, v5.4s}, [x6], #64
    ld1 {v6.4s}, [x6]

    lsl x1, x1, #1                  // i_dst *= sizeof(pel)
    lsl x3, x3, #1
    lsl x4, x4, #2                  // lcu_width *= 2*sizeof(pel)

    mov w9, #1
    xtn  v0.4h, v2.4s
    xtn2 v0.8h, v3.4s
    xtn  v1.4h, v4.4s
    xtn2 v1.8h, v5.4s
    xtn  v2.4h, v6.4s

    lsl w9, w9, w7
    sub w9, w9, #1

    mov w8, #0                          // i = 0
    sub w6, w5, #1                      // w6: lcu_height - 1
    sub w7, w5, #3                      // lcu_height - 3

    dup v9.8h, w9                       // max_pel

    dup v3.4s, v0.s[0]                  // coef[0] for U, coef[1] for V
    dup v4.4s, v0.s[1]
    dup v5.4s, v0.s[2]
    dup v6.4s, v0.s[3]
    dup v7.4s, v1.s[0]
    dup v8.4s, v1.s[1]
    dup v0.4s, v1.s[2]
    dup v1.4s, v1.s[3]
    dup v2.4s, v2.s[0]

alf_chroma_arm64_loop_y:
    sub x14, x2, x3                     // imgPad2 = src - i_src;
    add x15, x2, x3                     // imgPad1 = src + i_src;
    sub x19, x2, x3, lsl #1             // imgPad4 = src - 2*i_src;
    add x20, x2, x3, lsl #1             // imgPad3 = src + 2*i_src;
    sub x21, x19, x3                    // imgPad6 = src - 3*i_src;
    add x22, x20, x3                    // imgPad5 = src + 3*i_src;

    cmp w8, #3
    bge alf_chroma_arm64_y_ge_3
    cmp w8, #1
    beq alf_chroma_arm64_y_eq_1
    bgt alf_chroma_arm64_y_eq_2
    mov x14, x2                         // i == 0: imgPad2 = src
alf_chroma_arm64_y_eq_1:
    mov x19, x14                        // i == 1
alf_chroma_arm64_y_eq_2:
    mov x21, x19                        // i == 2

b alf_chroma_arm64_y_lt_h_minus_3

alf_chroma_arm64_y_ge_3:
    cmp w8, w7
    blt alf_chroma_arm64_y_lt_h_minus_3
    beq alf_chroma_arm64_y_eq_h_minus_3
    cmp w8, w6                          // cmp i and lcu_height - 1
    blt alf_chroma_arm64_y_eq_h_minus_2
    mov x15, x2                         // i == lcu_height - 1
alf_chroma_arm64_y_eq_h_minus_2:
    mov x20, x15                        // i == lcu_height - 2
alf_chroma_arm64_y_eq_h_minus_3:
    mov x22, x20                        // i == lcu_height - 3

alf_chroma_arm64_y_lt_h_minus_3:

    mov x9, #0                          // j = xPos
alf_chroma_arm64_loop_x:
    add x10, x21, x9
    add x11, x22, x9
    add x12, x20, x9
    add x13, x19, x9
    ld1 {v16.8h, v17.8h}, [x10]         // imgPad6[j]
    ld1 {v18.8h, v19.8h}, [x11]         // imgPad5[j]
    ld1 {v20.8h, v21.8h}, [x12]         // imgPad3[j]
    ld1 {v22.8h, v23.8h}, [x13]         // imgPad4[j]

    add v18.8h, v18.8h, v16.8h
    add v19.8h, v19.8h, v17.8h
    add v20.8h, v20.8h, v22.8h
    add v21.8h, v21.8h, v23.8h

    smull  v28.4s, v18.4h, v3.4h        // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    smull  v29.4s, v19.4h, v3.4h
    smull2 v30.4s, v18.8h, v3.8h
    smull2 v31.4s, v19.8h, v3.8h
    smlal  v28.4s, v20.4h, v4.4h        // pixelInt += coef[2] * (imgPad3[j] + imgPad4[j])
    smlal  v29.4s, v21.4h, v4.4h
    smlal2 v30.4s, v20.8h, v4.8h
    smlal2 v31.4s, v21.8h, v4.8h

    add x10, x15, x9                    // imgPad1 + j
    add x12, x14, x9                    // imgPad2 + j
    sub x10, x10, #4
    sub x12, x12, #4
    ld1 {v16.8h, v17.8h}, [x10], #32    // imgPad1[j - 2] (left)
    ld1 {v19.8h, v20.8h}, [x12], #32    // imgPad2[j - 2] (left)
    ld1 {v18.8h}, [x10]
    ld1 {v21.8h}, [x12]

    ext v22.16b, v16.16b, v17.16b, #4   // imgPad1[j]
    ext v23.16b, v17.16b, v18.16b, #4
    ext v24.16b, v19.16b, v20.16b, #4   // imgPad2[j]
    ext v25.16b, v20.16b, v21.16b, #4
    ext v26.16b, v16.16b, v17.16b, #8   // imgPad1[j + 2]
    ext v27.16b, v17.16b, v18.16b, #8
    ext v18.16b, v19.16b, v20.16b, #8   // imgPad2[j + 2]
    ext v21.16b, v20.16b, v21.16b, #8

    add v16.8h, v16.8h, v18.8h          // pixelInt += coef[8] * (imgPad1[j - 2] + imgPad2[j + 2])
    add v17.8h, v17.8h, v21.8h
    add v18.8h, v22.8h, v24.8h          // pixelInt += coef[6] * (imgPad1[j] + imgPad2[j])
    add v21.8h, v23.8h, v25.8h
    add v22.8h, v26.8h, v19.8h          // pixelInt += coef[4] * (imgPad1[j + 2] + imgPad2[j - 2])
    add v23.8h, v27.8h, v20.8h

    add x10, x2, x9                     // get imgPad[j - 6] - imgPad[j + 6]
    sub x10, x10, #12

    smlal  v28.4s, v16.4h, v7.4h
    smlal  v29.4s, v17.4h, v7.4h
    smlal2 v30.4s, v16.8h, v7.8h
    smlal2 v31.4s, v17.8h, v7.8h
    smlal  v28.4s, v18.4h, v6.4h
    smlal  v29.4s, v21.4h, v6.4h
    smlal2 v30.4s, v18.8h, v6.8h
    smlal2 v31.4s, v21.8h, v6.8h
    smlal  v28.4s, v22.4h, v5.4h
    smlal  v29.4s, v23.4h, v5.4h
    smlal2 v30.4s, v22.8h, v5.8h
    smlal2 v31.4s, v23.8h, v5.8h

    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x10]    // imgPad[j - 6]

    ext v20.16b, v17.16b, v18.16b, #8   // imgPad[j + 6]
    ext v21.16b, v18.16b, v19.16b, #8
    ext v22.16b, v16.16b, v17.16b, #12  // imgPad[j]
    ext v23.16b, v17.16b, v18.16b, #12

    add v24.8h, v20.8h, v16.8h          // pixelInt += coef[10] * (imgPad[j + 6] + imgPad[j - 6])
    add v25.8h, v21.8h, v17.8h

    smlal  v28.4s, v24.4h, v8.4h
    smlal  v29.4s, v25.4h, v8.4h
    smlal2 v30.4s, v24.8h, v8.8h
    smlal2 v31.4s, v25.8h, v8.8h

    smlal  v28.4s, v22.4h, v2.4h        // pixelInt += coef[16] * (imgPad[j])
    smlal  v29.4s, v23.4h, v2.4h
    smlal2 v30.4s, v22.8h, v2.8h
    smlal2 v31.4s, v23.8h, v2.8h

    ext v21.16b, v16.16b, v17.16b, #4   // imgPad[j - 4]
    ext v22.16b, v17.16b, v18.16b, #4
    ext v23.16b, v16.16b, v17.16b, #8   // imgPad[j - 2]
    // v20: imgPad[j + 6]
    // v17: imgPad[j + 2]
    // v18: imgPad[j + 10]
    // v22: imgPad[j + 4]
    ext v24.16b, v18.16b, v19.16b, #4

    add v21.8h, v21.8h, v22.8h          // pixelInt += coef[12] * (imgPad[j + 4] + imgPad[j - 4])
    add v22.8h, v22.8h, v24.8h
    add v25.8h, v23.8h, v17.8h          // pixelInt += coef[14] * (imgPad[j + 2] + imgPad[j - 2])
    add v26.8h, v20.8h, v18.8h

    smlal  v28.4s, v21.4h, v0.4h
    smlal  v29.4s, v22.4h, v0.4h
    smlal2 v30.4s, v21.8h, v0.8h
    smlal2 v31.4s, v22.8h, v0.8h
    smlal  v28.4s, v25.4h, v1.4h
    smlal  v29.4s, v26.4h, v1.4h
    smlal2 v30.4s, v25.8h, v1.8h
    smlal2 v31.4s, v26.8h, v1.8h

    add x10, x0, x9
    sqrshrun  v28.4h, v28.4s, #6
    sqrshrun  v29.4h, v29.4s, #6
    sqrshrun2 v28.8h, v30.4s, #6
    sqrshrun2 v29.8h, v31.4s, #6

    umin v28.8h, v28.8h, v9.8h
    umin v29.8h, v29.8h, v9.8h

    add x9, x9, #32
    st1 {v28.8h, v29.8h}, [x10]

    cmp x9, x4
    blt alf_chroma_arm64_loop_x

    add w8, w8, #1
    add x0, x0, x1
    add x2, x2, x3
    cmp w8, w5
    blt alf_chroma_arm64_loop_y

    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ld1 {v8.2d, v9.2d}, [sp], #32

    ret

/*******************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_one_chroma_arm64(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int bit_depth);
 *  dst->x0, i_dst->x1, src->x2, i_src->x3, lcu_width->x4, lcu_height->x5, coef->x6, bit_depth->x7
 *******************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_one_chroma_arm64
    stp x19, x20, [sp, #-16]
    stp x21, x22, [sp, #-32]
    sub sp, sp, #32

    mov w10, #0x0000ffff
    dup v28.4s, w10                     // mask_uv

    ld1 {v2.4s, v3.4s, v4.4s, v5.4s}, [x6], #64
    ld1 {v6.4s}, [x6]
    xtn  v0.4h, v2.4s
    xtn2 v0.8h, v3.4s
    xtn  v1.4h, v4.4s
    xtn2 v1.8h, v5.4s
    xtn  v2.4h, v6.4s

    mov w9, #1
    lsl x1, x1, #1                      // i_dst *= sizeof(pel)
    lsl x3, x3, #1
    lsl x4, x4, #2                      // lcu_width *= 2*sizeof(pel)
    lsl w9, w9, w7                      // (1<<bit_depth)

    mov w8, #0                          // i = 0
    sub w6, w5, #1                      // w6: lcu_height - 1
    sub w7, w5, #3                      // lcu_height - 3
    sub w9, w9, #1                      // max_pel = (1<<bit_depth) - 1

    xtn  v0.4h, v0.4s
    xtn2 v0.8h, v1.4s
    xtn  v1.4h, v2.4s

    dup v29.8h, w9

alf_one_chroma_arm64_loop_y:
    sub x14, x2, x3                     // imgPad2 = src - i_src;
    add x15, x2, x3                     // imgPad1 = src + i_src;
    sub x19, x2, x3, lsl #1             // imgPad4 = src - 2*i_src;
    add x20, x2, x3, lsl #1             // imgPad3 = src + 2*i_src;
    sub x21, x19, x3                    // imgPad6 = src - 3*i_src;
    add x22, x20, x3                    // imgPad5 = src + 3*i_src;

    cmp w8, #3
    bge alf_one_chroma_arm64_y_ge_3
    cmp w8, #1
    beq alf_one_chroma_arm64_y_eq_1
    bgt alf_one_chroma_arm64_y_eq_2
    mov x14, x2                         // i == 0: imgPad2 = src
alf_one_chroma_arm64_y_eq_1:
    mov x19, x14                        // i == 1
alf_one_chroma_arm64_y_eq_2:
    mov x21, x19                        // i == 2

    b alf_one_chroma_arm64_y_lt_h_minus_3

alf_one_chroma_arm64_y_ge_3:
    cmp w8, w7
    blt alf_one_chroma_arm64_y_lt_h_minus_3
    beq alf_one_chroma_arm64_y_eq_h_minus_3
    cmp w8, w6                          // cmp i and lcu_height - 1
    blt alf_one_chroma_arm64_y_eq_h_minus_2
    mov x15, x2                         // i == lcu_height - 1
alf_one_chroma_arm64_y_eq_h_minus_2:
    mov x20, x15                        // i == lcu_height - 2
alf_one_chroma_arm64_y_eq_h_minus_3:
    mov x22, x20                        // i == lcu_height - 3

alf_one_chroma_arm64_y_lt_h_minus_3:

    mov x9, #0                          // j = xPos
alf_one_chroma_arm64_loop_x:
    add x10, x21, x9
    add x11, x22, x9
    add x12, x19, x9
    add x13, x20, x9
    ld1 {v16.4s, v17.4s}, [x10]
    ld1 {v18.4s, v19.4s}, [x11]
    ld1 {v20.4s, v21.4s}, [x12]
    ld1 {v22.4s, v23.4s}, [x13]
    xtn  v16.4h, v16.4s                 // delete one chroma
    xtn2 v16.8h, v17.4s
    xtn  v18.4h, v18.4s
    xtn2 v18.8h, v19.4s
    xtn  v20.4h, v20.4s
    xtn2 v20.8h, v21.4s
    xtn  v22.4h, v22.4s
    xtn2 v22.8h, v23.4s
    add v16.8h, v16.8h, v18.8h
    add v20.8h, v20.8h, v22.8h
    smull  v30.4s, v16.4h, v0.h[0]      // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    smull2 v31.4s, v16.8h, v0.h[0]
    smlal  v30.4s, v20.4h, v0.h[1]      // pixelInt += coef[2] * (imgPad3[j] + imgPad4[j])
    smlal2 v31.4s, v20.8h, v0.h[1]

    add x10, x15, x9
    add x12, x14, x9
    sub x10, x10, #4
    sub x12, x12, #4
    ld1 {v16.8h, v17.8h}, [x10], #32    // imgPad1[j - 2] (left)
    ld1 {v19.8h, v20.8h}, [x12], #32    // imgPad2[j - 2] (left)
    ld1 {v18.8h}, [x10]
    ld1 {v21.8h}, [x12]
    xtn  v16.4h, v16.4s
    xtn2 v16.8h, v17.4s
    xtn  v17.4h, v18.4s
    xtn  v19.4h, v19.4s
    xtn2 v19.8h, v20.4s
    xtn  v20.4h, v21.4s

    ext v24.16b, v16.16b, v17.16b, #4   // imgPad1[j + 2]
    ext v25.16b, v19.16b, v20.16b, #4   // imgPad2[j + 2]
    ext v22.16b, v16.16b, v17.16b, #2   // imgPad1[j]
    ext v23.16b, v19.16b, v20.16b, #2   // imgPad2[j]

    add v16.8h, v16.8h, v25.8h
    add v17.8h, v22.8h, v23.8h
    add v18.8h, v19.8h, v24.8h

    smlal  v30.4s, v16.4h, v0.h[4]      // pixelInt += coef[8] * (imgPad1[j - 2] + imgPad2[j + 2])
    smlal2 v31.4s, v16.8h, v0.h[4]
    smlal  v30.4s, v17.4h, v0.h[3]      // pixelInt += coef[6] * (imgPad1[j] + imgPad2[j])
    smlal2 v31.4s, v17.8h, v0.h[3]
    smlal  v30.4s, v18.4h, v0.h[2]      // pixelInt += coef[4] * (imgPad1[j + 2] + imgPad2[j - 2])
    smlal2 v31.4s, v18.8h, v0.h[2]

    add x10, x2, x9                     // get imgPad[j - 6] - imgPad[j + 6]
    sub x10, x10, #12
    ld1 {v16.8h, v17.8h, v18.8h, v19.8h}, [x10]
    xtn  v16.4h, v16.4s                 // imgPad[j - 6]
    xtn2 v16.8h, v17.4s
    xtn  v17.4h, v18.4s
    xtn2 v17.8h, v19.4s

    ext v22.16b, v16.16b, v17.16b, #2   // imgPad[j - 4]
    ext v23.16b, v16.16b, v17.16b, #4   // imgPad[j - 2]
    ext v18.16b, v16.16b, v17.16b, #6   // imgPad[j]
    ext v19.16b, v16.16b, v17.16b, #8   // imgPad[j + 2]
    ext v20.16b, v16.16b, v17.16b, #10  // imgPad[j + 4]
    ext v21.16b, v16.16b, v17.16b, #12  // imgPad[j + 6]

    add v16.8h, v16.8h, v21.8h          // imgPad[j + 6] + imgPad[j - 6]
    add v22.8h, v22.8h, v20.8h          // imgPad[j + 4] + imgPad[j - 4]
    add v23.8h, v23.8h, v19.8h          // imgPad[j + 2] + imgPad[j - 2]

    smlal  v30.4s, v16.4h, v0.h[5]      // pixelInt += coef[10] * (imgPad[j + 6] + imgPad[j - 6])
    smlal2 v31.4s, v16.8h, v0.h[5]
    smlal  v30.4s, v22.4h, v0.h[6]      // pixelInt += coef[12] * (imgPad[j + 4] + imgPad[j - 4])
    smlal2 v31.4s, v22.8h, v0.h[6]
    smlal  v30.4s, v23.4h, v0.h[7]      // pixelInt += coef[14] * (imgPad[j + 2] + imgPad[j - 2])
    smlal2 v31.4s, v23.8h, v0.h[7]
    smlal  v30.4s, v18.4h, v1.h[0]      // pixelInt += coef[16] * (imgPad[j])
    smlal2 v31.4s, v18.8h, v1.h[0]

    add x10, x0, x9

    sqrshrun  v30.4h, v30.4s, #6
    sqrshrun2 v30.8h, v31.4s, #6
    
    umin v30.8h, v30.8h, v29.8h

    ld1 {v2.8h, v3.8h}, [x10]
    uxtl2 v31.4s, v30.8h
    uxtl  v30.4s, v30.4h
    add x9, x9, #32
    bif  v30.16b, v2.16b, v28.16b
    bif  v31.16b, v3.16b, v28.16b

    st1 {v30.8h, v31.8h}, [x10]

    cmp x9, x4
    blt alf_one_chroma_arm64_loop_x

    add w8, w8, #1
    add x0, x0, x1
    add x2, x2, x3
    cmp w8, w5
    blt alf_one_chroma_arm64_loop_y

    add sp, sp, #32
    ldp x19, x20, [sp, #-16]
    ldp x21, x22, [sp, #-32]

    ret


#endif      // COMPILE_10BIT

#endif      // defined(__arm64__)
