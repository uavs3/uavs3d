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

#include "def_armv7.S"

#if !COMPILE_10BIT

/*********************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_armv7(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->r0, i_dst->r1, src->r2, i_src->r3, lcu_width->r4, lcu_height->r5, coef->r6
 **********************************************************************************************************************************************/
function uavs3d_alf_one_lcu_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4}

    ldr r4, [sp, #56]
    ldr r5, [sp, #60]
    ldr r6, [sp, #64]

    vld1.32 {q0, q1}, [r6]!         // load coef[0-7]
    vld1.32 {q2}, [r6]              // load coef[8]
    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2

    mov r8, #0                      // i = startPos

alf_luma_loop_y:
    sub r9 , r2, r3                 // imgPad2 = src - i_src;
    add r10, r2, r3                 // imgPad1 = src + i_src;
    sub r11, r2, r3, lsl #1         // imgPad4 = src - 2*i_src;
    add r12, r2, r3, lsl #1         // imgPad3 = src + 2*i_src;
    sub r6, r11, r3                 // imgPad6 = src - 3*i_src;
    add r7, r12, r3                 // imgPad5 = src + 3*i_src;

    cmp r8, #3
    bge alf_luma_y_ge_3
    cmp r8, #1
    movlt r9, r2                    // i == 0
    movle r11, r9                   // i == 1
    mov   r6, r11                   // i == 2

    b alf_luma_y_lt_h_minus_3

alf_luma_y_ge_3:
    sub r5, #3
    cmp r8, r5
    add r5, #3
    blt alf_luma_y_lt_h_minus_3
    sub r5, #2
    cmp r8, r5
    movgt r10, r2                   // i == lcu_height - 1
    movge r12, r10                  // i == lcu_height - 2
    mov   r7, r12                   // i == lcu_height - 3
    add   r5, #2

alf_luma_y_lt_h_minus_3:

    vmov d3, r9, r10
    vmov d4, r6, r7
    vmov d5, r11, r12
    mov r6, #0                      // j = 0
alf_luma_loop_x:
    vdup.u32 q3, r6
    vadd.u32 q8, q2, q3

    vmov r9, r10, d16
    vmov r11, r12, d17

    vld1.64 {d20}, [r9]
    vld1.64 {d21}, [r10]
    vld1.64 {d22}, [r11]
    vld1.64 {d23}, [r12]

    vaddl.u8 q10, d20, d21
    vaddl.u8 q11, d22, d23
    vmull.s16 q4 , d20, d0[0]       // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    vmull.s16 q10, d21, d0[0]
    vmlal.s16 q4 , d22, d0[1]       // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);
    vmlal.s16 q10, d23, d0[1]

    vadd.u32 d16, d6, d3
    vmov r9, r10, d16
    sub r11, r9, #1
    sub r12, r10, #1
    vld1.64 {d22}, [r9]             // load imgPad2[j]
    vld1.64 {d23}, [r10]            // load imgPad1[j]
    add r9, r9, #1
    add r10, r10, #1
    vld1.64 {d24}, [r11]            // load imgPad2[j-1]
    vld1.64 {d25}, [r12]            // load imgPad1[j-1]
    vld1.64 {d26}, [r9]             // load imgPad2[j+1]
    vld1.64 {d27}, [r10]            // load imgPad1[j+1]

    vaddl.u8 q11, d22, d23          // imgPad2[j] + imgPad1[j]
    vaddl.u8 q14, d27, d24          // imgPad1[j+1] + imgPad2[j-1]
    vaddl.u8 q15, d26, d25          // imgPad2[j+1] + imgPad1[j-1]

    vmlal.s16 q4 , d28, d0[2]       // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    vmlal.s16 q10, d29, d0[2]
    vmlal.s16 q4 , d22, d0[3]       // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    vmlal.s16 q10, d23, d0[3]
    vmlal.s16 q4 , d30, d1[0]       // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])
    vmlal.s16 q10, d31, d1[0]

    add r11, r2, r6
    sub r11, r11, #3
    vld1.64 {q12}, [r11]            // load imgPad[j-3]

    vext.8 d26, d24, d25, #1        // imgPad[j-2]
    vext.8 d27, d24, d25, #2        // imgPad[j-1]
    vext.8 d28, d24, d25, #3        // imgPad[j]
    vext.8 d29, d24, d25, #4        // imgPad[j+1]
    vext.8 d30, d24, d25, #5        // imgPad[j+2]
    vext.8 d31, d24, d25, #6        // imgPad[j+3]

    vaddl.u8 q8, d24, d31           // imgPad[j+3] + imgPad[j-3]
    vaddl.u8 q9, d26, d30           // imgPad[j+2] + imgPad[j-2]
    vaddl.u8 q11, d27, d29          // imgPad[j+1] + imgPad[j-1]
    vmovl.u8 q12, d28               // imgPad[j]

    vmlal.s16 q4 , d16, d1[1]       // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    vmlal.s16 q10, d17, d1[1]
    vmlal.s16 q4 , d18, d1[2]       // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    vmlal.s16 q10, d19, d1[2]
    vmlal.s16 q4 , d22, d1[3]       // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    vmlal.s16 q10, d23, d1[3]
    vmlal.s16 q4 , d24, d2[0]       // pixelInt += coef[8] * (imgPad[j])
    vmlal.s16 q10, d25, d2[0]

    add   r9, r0, r6
    vrshrn.s32 d8, q4 , #6
    vrshrn.s32 d9, q10, #6
    vqmovun.s16 d20, q4

    add   r6, r6, #8
    vst1.64 {d20}, [r9]             // store imgRes[j]

    cmp   r6, r4
    blt   alf_luma_loop_x

    add   r8, r8, #1
    add   r0, r0, r1
    add   r2, r2, r3
    cmp   r8, r5
    blt   alf_luma_loop_y

    vpop  {q4}
    ldmia sp!, {r4-r12, pc}

/****************************************************************************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_chroma_armv7(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->r0, i_dst->r1, src->r2, i_src->r3, lcu_width->r4, lcu_height->r5, coef->r6
 *****************************************************************************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4}
    ldr r4, [sp, #56]
    ldr r5, [sp, #60]
    ldr r6, [sp, #64]

    vld1.32 {q0, q1}, [r6]!         // load coef[0-7]
    vld1.32 {q2, q3}, [r6]!
    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2
    vmovn.i32 d3, q3
    vld1.32 {q8}, [r6]              // load coef[8]
    vmovn.i32 d4, q8

    mov r8, #0                      // i = startPos
    lsl r4, #1                      // lcu_width *= 2
alf_chroma_loop_y:
    sub r9 , r2, r3                 // imgPad2 = src - i_src;
    add r10, r2, r3                 // imgPad1 = src + i_src;
    sub r11, r2, r3, lsl #1         // imgPad4 = src - 2*i_src;
    add r12, r2, r3, lsl #1         // imgPad3 = src + 2*i_src;
    sub r6, r11, r3                 // imgPad6 = src - 3*i_src;
    add r7, r12, r3                 // imgPad5 = src + 3*i_src;

    cmp r8, #3
    bge alf_chroma_y_ge_3
    cmp r8, #1
    movlt r9, r2                    // i == 0
    movle r11, r9                   // i == 1
    mov   r6, r11                   // i == 2

    b alf_chroma_y_lt_h_minus_3

alf_chroma_y_ge_3:
    sub r5, #3
    cmp r8, r5
    add r5, #3
    blt alf_chroma_y_lt_h_minus_3
    sub r5, #2
    cmp r8, r5
    movgt r10, r2                   // i == lcu_height - 1
    movge r12, r10                  // i == lcu_height - 2
    mov   r7, r12                   // i == lcu_height - 3
    add   r5, #2

alf_chroma_y_lt_h_minus_3:

    vmov d5, r9, r10
    vmov d6, r6, r7
    vmov d7, r11, r12
    mov r6, #0                      // j = 0
alf_chroma_loop_x:
    vdup.u32 q9, r6
    vadd.u32 q8, q3, q9

    vmov r9, r10, d16
    vmov r11, r12, d17

    vld1.64 {d20}, [r9]
    vld1.64 {d21}, [r10]
    vld1.64 {d22}, [r11]
    vld1.64 {d23}, [r12]

    vdup.32 q12, d0[0]
    vdup.32 q13, d0[1]

    vaddl.u8 q10, d20, d21
    vaddl.u8 q11, d22, d23
    vmull.s16 q4 , d20, d24         // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    vmull.s16 q10, d21, d25
    vmlal.s16 q4 , d22, d26         // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);
    vmlal.s16 q10, d23, d27

    vadd.u32 d16, d18, d5
    vmov r9, r10, d16
    sub r11, r9, #2
    sub r12, r10, #2
    vld1.64 {d22}, [r9]             // load imgPad2[j]
    vld1.64 {d23}, [r10]            // load imgPad1[j]
    add r9, r9, #2
    add r10, r10, #2
    vld1.64 {d24}, [r11]            // load imgPad2[j-1]
    vld1.64 {d25}, [r12]            // load imgPad1[j-1]
    vld1.64 {d26}, [r9]             // load imgPad2[j+1]
    vld1.64 {d27}, [r10]            // load imgPad1[j+1]

    vaddl.u8 q11, d22, d23          // imgPad2[j] + imgPad1[j]
    vaddl.u8 q14, d27, d24          // imgPad1[j+1] + imgPad2[j-1]
    vaddl.u8 q15, d26, d25          // imgPad2[j+1] + imgPad1[j-1]

    vdup.32 q8, d1[0]
    vdup.32 q9, d1[1]
    vdup.32 q12, d2[0]

    vmlal.s16 q4 , d28, d16         // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    vmlal.s16 q10, d29, d17
    vmlal.s16 q4 , d22, d18         // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    vmlal.s16 q10, d23, d19
    vmlal.s16 q4 , d30, d24         // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])
    vmlal.s16 q10, d31, d25

    add r11, r2, r6
    sub r11, r11, #6
    vld1.64 {q12, q13}, [r11]       // load imgPad[j-3]

    vext.16 d27, d24, d25, #1       // imgPad[j-2]
    vext.16 d28, d24, d25, #2       // imgPad[j-1]
    vext.16 d29, d24, d25, #3       // imgPad[j]
                                    // d25: imgPad[j+1]
    vext.16 d30, d25, d26, #1       // imgPad[j+2]
    vext.16 d31, d25, d26, #2       // imgPad[j+3]

    vaddl.u8 q8, d24, d31           // imgPad[j+3] + imgPad[j-3]
    vaddl.u8 q9, d27, d30           // imgPad[j+2] + imgPad[j-2]
    vaddl.u8 q11, d28, d25          // imgPad[j+1] + imgPad[j-1]
    vmovl.u8 q12, d29               // imgPad[j]

    vdup.32 q13, d2[1]
    vdup.32 q14, d3[0]
    vdup.32 q15, d3[1]

    vmlal.s16 q4 , d16, d26         // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    vmlal.s16 q10, d17, d27
    vmlal.s16 q4 , d18, d28         // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    vmlal.s16 q10, d19, d29
    vdup.32 q13, d4[0]
    vmlal.s16 q4 , d22, d30         // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    vmlal.s16 q10, d23, d31
    vmlal.s16 q4 , d24, d26         // pixelInt += coef[8] * (imgPad[j])
    vmlal.s16 q10, d25, d27
    add   r9, r0, r6
    vrshrn.s32 d8, q4 , #6
    vrshrn.s32 d9, q10, #6
    vqmovun.s16 d20, q4

    add   r6, r6, #8
    vst1.64 {d20}, [r9]             // store imgRes[j]

    cmp   r6, r4
    blt   alf_chroma_loop_x

    add   r8, r8, #1
    add   r0, r0, r1
    add   r2, r2, r3
    cmp   r8, r5
    blt   alf_chroma_loop_y

    vpop {q4}
    ldmia sp!, {r4-r12, pc}


/****************************************************************************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_one_chroma_armv7(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->r0, i_dst->r1, src->r2, i_src->r3, lcu_width->r4, lcu_height->r5, coef->r6
 *****************************************************************************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_one_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4}
    ldr r4, [sp, #56]
    ldr r5, [sp, #60]
    ldr r6, [sp, #64]

    vld1.32 {q0, q1}, [r6]!         // load coef[0-7]
    vld1.32 {q2, q3}, [r6]!
    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2
    vmovn.i32 d3, q3
    vld1.32 {q8}, [r6]              // load coef[8]
    vmovn.i32 d4, q8

    mov r10, #0x00ff
    vdup.s16 q3, r10                // mask_uv

    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2

    mov r8, #0                      // i = startPos
    lsl r4, #1                      // lcu_width *= 2
alf_one_chroma_loop_y:
    sub r9 , r2, r3                 // imgPad2 = src - i_src;
    add r10, r2, r3                 // imgPad1 = src + i_src;
    sub r11, r2, r3, lsl #1         // imgPad4 = src - 2*i_src;
    add r12, r2, r3, lsl #1         // imgPad3 = src + 2*i_src;
    sub r6, r11, r3                 // imgPad6 = src - 3*i_src;
    add r7, r12, r3                 // imgPad5 = src + 3*i_src;

    cmp r8, #3
    bge alf_one_chroma_y_ge_3
    cmp r8, #1
    movlt r9, r2                    // i == 0
    movle r11, r9                   // i == 1
    mov   r6, r11                   // i == 2

    b alf_one_chroma_y_lt_h_minus_3

alf_one_chroma_y_ge_3:
    sub r5, #3
    cmp r8, r5
    add r5, #3
    blt alf_one_chroma_y_lt_h_minus_3
    sub r5, #2
    cmp r8, r5
    movgt r10, r2                   // i == lcu_height - 1
    movge r12, r10                  // i == lcu_height - 2
    mov   r7, r12                   // i == lcu_height - 3
    add   r5, #2

alf_one_chroma_y_lt_h_minus_3:

    vmov d3, r9, r10
    vmov d4, r6, r7
    vmov d5, r11, r12
    mov r6, #0                      // j = 0
alf_one_chroma_loop_x:
    vdup.u32 q9, r6
    vadd.u32 q8, q2, q9

    vmov r9, r10, d16
    vmov r11, r12, d17

    vld1.64 {q10}, [r9]
    vld1.64 {q11}, [r10]
    vld1.64 {q12}, [r11]
    vld1.64 {q13}, [r12]
    vmovn.i16 d20, q10
    vmovn.i16 d21, q11
    vmovn.i16 d22, q12
    vmovn.i16 d23, q13

    vaddl.u8 q10, d20, d21
    vaddl.u8 q11, d22, d23
    vmull.s16 q4 , d20, d0[0]       // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    vmull.s16 q10, d21, d0[0]
    vmlal.s16 q4 , d22, d0[1]       // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);
    vmlal.s16 q10, d23, d0[1]

    vadd.u32 d16, d18, d3
    vmov r9, r10, d16
    sub r11, r9, #2
    sub r12, r10, #2
    vld1.64 {q12}, [r9]             // load imgPad2[j]
    vld1.64 {q13}, [r10]            // load imgPad1[j]
    add r9, r9, #2
    add r10, r10, #2
    vld1.64 {q14}, [r11]            // load imgPad2[j-1]
    vld1.64 {q15}, [r12]            // load imgPad1[j-1]
    vmovn.i16 d22, q12
    vmovn.i16 d23, q13
    vmovn.i16 d24, q14
    vmovn.i16 d25, q15

    vld1.64 {q14}, [r9]             // load imgPad2[j+1]
    vld1.64 {q15}, [r10]            // load imgPad1[j+1]
    vmovn.i16 d26, q14
    vmovn.i16 d27, q15

    add r11, r2, r6
    sub r11, r11, #6

    vaddl.u8 q11, d22, d23          // imgPad2[j] + imgPad1[j]
    vaddl.u8 q14, d27, d24          // imgPad1[j+1] + imgPad2[j-1]
    vaddl.u8 q15, d26, d25          // imgPad2[j+1] + imgPad1[j-1]

    vld1.64 {q12, q13}, [r11]       // load imgPad[j-3]

    vmlal.s16 q4 , d28, d0[2]       // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    vmlal.s16 q10, d29, d0[2]
    vmlal.s16 q4 , d22, d0[3]       // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    vmlal.s16 q10, d23, d0[3]
    vmlal.s16 q4 , d30, d1[0]       // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])
    vmlal.s16 q10, d31, d1[0]

    vmovn.i16 d24, q12
    vmovn.i16 d25, q13

    vext.8 d26, d24, d25, #1        // imgPad[j-2]
    vext.8 d27, d24, d25, #2        // imgPad[j-1]
    vext.8 d28, d24, d25, #3        // imgPad[j]
    vext.8 d29, d24, d25, #4        // imgPad[j+1]
    vext.8 d30, d24, d25, #5        // imgPad[j+2]
    vext.8 d31, d24, d25, #6        // imgPad[j+3]

    vaddl.u8 q8, d24, d31           // imgPad[j+3] + imgPad[j-3]
    vaddl.u8 q9, d26, d30           // imgPad[j+2] + imgPad[j-2]
    vaddl.u8 q11, d27, d29          // imgPad[j+1] + imgPad[j-1]
    vmovl.u8 q12, d28               // imgPad[j]

    vmlal.s16 q4 , d16, d1[1]       // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    vmlal.s16 q10, d17, d1[1]
    vmlal.s16 q4 , d18, d1[2]       // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    vmlal.s16 q10, d19, d1[2]
    vmlal.s16 q4 , d22, d1[3]       // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    vmlal.s16 q10, d23, d1[3]
    vmlal.s16 q4 , d24, d2[0]       // pixelInt += coef[8] * (imgPad[j])
    vmlal.s16 q10, d25, d2[0]

    add   r9, r0, r6

    vrshrn.s32 d8, q4 , #6
    vrshrn.s32 d9, q10, #6
    vqmovun.s16 d20, q4

    vld1.8 {q11}, [r9]
    vmovl.u8 q10, d20
    vbif  q10, q11, q3

    add   r6, r6, #16
    vst1.8 {q10}, [r9]             // store imgRes[j]

    cmp   r6, r4
    blt   alf_one_chroma_loop_x

    add   r8, r8, #1
    add   r0, r0, r1
    add   r2, r2, r3
    cmp   r8, r5
    blt   alf_one_chroma_loop_y

    vpop {q4}
    ldmia sp!, {r4-r12, pc}

#else // 10BIT

/*********************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_armv7(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->r0, i_dst->r1, src->r2, i_src->r3, lcu_width->r4, lcu_height->r5, coef->r6, bit_depth->r7
 **********************************************************************************************************************************************/
function uavs3d_alf_one_lcu_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4-q7}

    add sp, sp, #104
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #104

    lsl r1, r1, #1
    lsl r3, r3, #1
    lsl r4, r4, #1

    mov r9, #1
    vld1.32 {q0, q1}, [r6]!         // load coef[0-7]
    vld1.32 {q2}, [r6]              // load coef[8]

    lsl r9, r9, r7
    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2
    sub r9, r9, #1

    mov r8, #0                      // i = startPos
    vdup.u16 q7, r9                 // max_pel

alf_luma_loop_y:
    sub r9 , r2, r3                 // imgPad2 = src - i_src;
    add r10, r2, r3                 // imgPad1 = src + i_src;
    sub r11, r2, r3, lsl #1         // imgPad4 = src - 2*i_src;
    add r12, r2, r3, lsl #1         // imgPad3 = src + 2*i_src;
    sub r6, r11, r3                 // imgPad6 = src - 3*i_src;
    add r7, r12, r3                 // imgPad5 = src + 3*i_src;

    cmp r8, #3
    bge alf_luma_y_ge_3
    cmp r8, #1
    movlt r9, r2                    // i == 0
    movle r11, r9                   // i == 1
    mov   r6, r11                   // i == 2

    b alf_luma_y_lt_h_minus_3

alf_luma_y_ge_3:
    sub r5, #3
    cmp r8, r5
    add r5, #3
    blt alf_luma_y_lt_h_minus_3
    sub r5, #2
    cmp r8, r5
    add r5, #2
    movgt r10, r2                   // i == lcu_height - 1
    movge r12, r10                  // i == lcu_height - 2
    mov   r7, r12                   // i == lcu_height - 3

alf_luma_y_lt_h_minus_3:

    vmov d3, r9, r10
    vmov d4, r6, r7
    vmov d5, r11, r12
    mov r6, #0                      // j = 0
alf_luma_loop_x:
    vdup.u32 q3, r6
    vadd.u32 q8, q2, q3

    vmov r9, r10, d16
    vmov r11, r12, d17

    vld1.64 {q10}, [r9]
    vld1.64 {q11}, [r10]
    vld1.64 {q12}, [r11]
    vld1.64 {q13}, [r12]

    vadd.u16 q10, q10, q11
    vadd.u16 q11, q12, q13
    vmull.s16 q4 , d20, d0[0]       // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    vmull.s16 q10, d21, d0[0]
    vmlal.s16 q4 , d22, d0[1]       // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);
    vmlal.s16 q10, d23, d0[1]

    vadd.u32 d16, d6, d3
    vmov r9, r10, d16
    sub r11, r9, #2
    sub r12, r10, #2
    vld1.64 {q5}, [r9]              // load imgPad2[j]
    vld1.64 {q6}, [r10]             // load imgPad1[j]
    add r9, r9, #2
    add r10, r10, #2
    vld1.64 {q8}, [r11]             // load imgPad2[j-1]
    vld1.64 {q9}, [r12]             // load imgPad1[j-1]
    vld1.64 {q11}, [r9]             // load imgPad2[j+1]
    vld1.64 {q12}, [r10]            // load imgPad1[j+1]

    vadd.u16 q5, q5, q6             // imgPad2[j] + imgPad1[j]
    vadd.u16 q8, q12, q8            // imgPad1[j+1] + imgPad2[j-1]
    vadd.u16 q9, q11, q9            // imgPad2[j+1] + imgPad1[j-1]

    vmlal.s16 q4 , d16, d0[2]       // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    vmlal.s16 q10, d17, d0[2]
    vmlal.s16 q4 , d10, d0[3]       // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    vmlal.s16 q10, d11, d0[3]
    vmlal.s16 q4 , d18, d1[0]       // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])
    vmlal.s16 q10, d19, d1[0]

    add r11, r2, r6
    sub r11, r11, #6
    vld1.64 {q12, q13}, [r11]       // load imgPad[j-3]

    vext.16 q5, q12, q13, #1        // imgPad[j-2]
    vext.16 q6, q12, q13, #2        // imgPad[j-1]
    vext.16 q8, q12, q13, #3        // imgPad[j]
    vext.16 q9, q12, q13, #4        // imgPad[j+1]
    vext.16 q14, q12, q13, #5       // imgPad[j+2]
    vext.16 q15, q12, q13, #6       // imgPad[j+3]

    vadd.u16 q6, q6, q9             // imgPad[j+1] + imgPad[j-1]
    vadd.u16 q5, q14, q5            // imgPad[j+2] + imgPad[j-2]
    vadd.u16 q9, q12, q15           // imgPad[j+3] + imgPad[j-3]
    // q8: imgPad[j]

    vmlal.s16 q4 , d16, d2[0]       // pixelInt += coef[8] * (imgPad[j])
    vmlal.s16 q10, d17, d2[0]
    vmlal.s16 q4 , d18, d1[1]       // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    vmlal.s16 q10, d19, d1[1]
    vmlal.s16 q4 , d10, d1[2]       // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    vmlal.s16 q10, d11, d1[2]
    vmlal.s16 q4 , d12, d1[3]       // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    vmlal.s16 q10, d13, d1[3]

    add   r9, r0, r6
    vqrshrun.s32 d8, q4 , #6
    vqrshrun.s32 d9, q10, #6
    vmin.u16 q4, q4, q7

    add   r6, r6, #16
    vst1.64 {q4}, [r9]             // store imgRes[j]

    cmp   r6, r4
    blt   alf_luma_loop_x

    add   r8, r8, #1
    add   r0, r0, r1
    add   r2, r2, r3
    cmp   r8, r5
    blt   alf_luma_loop_y

    vpop  {q4-q7}
    ldmia sp!, {r4-r12, lr}
    mov pc, lr

/****************************************************************************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_chroma_armv7(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->r0, i_dst->r1, src->r2, i_src->r3, lcu_width->r4, lcu_height->r5, coef->r6, bit_depth->r7
 *****************************************************************************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4-q7}
    add sp, sp, #104
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #104

    mov r9, #1
    lsl r1, #1
    lsl r3, #1
    lsl r9, r7

    vld1.32 {q0, q1}, [r6]!         // load coef[0-7]
    vld1.32 {q2, q3}, [r6]!
    vld1.32 {q8}, [r6]              // load coef[8]

    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2
    vmovn.i32 d3, q3
    vmovn.i32 d4, q8

    sub r9, #1
    mov r8, #0                      // i = startPos
    lsl r4, #2                      // lcu_width *= 2
    vdup.u16 q7, r9

alf_chroma_loop_y:
    sub r9 , r2, r3                 // imgPad2 = src - i_src;
    add r10, r2, r3                 // imgPad1 = src + i_src;
    sub r11, r2, r3, lsl #1         // imgPad4 = src - 2*i_src;
    add r12, r2, r3, lsl #1         // imgPad3 = src + 2*i_src;
    sub r6, r11, r3                 // imgPad6 = src - 3*i_src;
    add r7, r12, r3                 // imgPad5 = src + 3*i_src;

    cmp r8, #3
    bge alf_chroma_y_ge_3
    cmp r8, #1
    movlt r9, r2                    // i == 0
    movle r11, r9                   // i == 1
    mov   r6, r11                   // i == 2

    b alf_chroma_y_lt_h_minus_3

alf_chroma_y_ge_3:
    sub r5, #3
    cmp r8, r5
    add r5, #3
    blt alf_chroma_y_lt_h_minus_3
    sub r5, #2
    cmp r8, r5
    add r5, #2
    movgt r10, r2                   // i == lcu_height - 1
    movge r12, r10                  // i == lcu_height - 2
    mov   r7, r12                   // i == lcu_height - 3

alf_chroma_y_lt_h_minus_3:

    vmov d5, r9, r10
    vmov d6, r6, r7
    vmov d7, r11, r12
    mov r6, #0                      // j = 0
alf_chroma_loop_x:
    vdup.u32 q9, r6
    vadd.u32 q8, q3, q9

    vmov r9, r10, d16
    vmov r11, r12, d17

    vld1.64 {q10}, [r9]
    vld1.64 {q11}, [r10]
    vld1.64 {q14}, [r11]
    vld1.64 {q15}, [r12]

    vdup.32 q12, d0[0]
    vdup.32 q13, d0[1]

    vadd.u16 q10, q10, q11
    vadd.u16 q11, q14, q15
    vmull.s16 q4 , d20, d24         // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    vmull.s16 q10, d21, d25
    vmlal.s16 q4 , d22, d26         // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);
    vmlal.s16 q10, d23, d27

    vadd.u32 d16, d18, d5
    vmov r9, r10, d16
    sub r11, r9, #4
    sub r12, r10, #4
    vld1.64 {q5}, [r9]              // load imgPad2[j]
    vld1.64 {q6}, [r10]             // load imgPad1[j]
    add r9, r9, #4
    add r10, r10, #4
    vld1.64 {q8}, [r11]             // load imgPad2[j-1]
    vld1.64 {q9}, [r12]             // load imgPad1[j-1]
    vld1.64 {q14}, [r9]             // load imgPad2[j+1]
    vld1.64 {q15}, [r10]            // load imgPad1[j+1]

    vadd.u16 q11, q5, q6            // imgPad2[j] + imgPad1[j]
    vadd.u16 q15, q15, q8           // imgPad1[j+1] + imgPad2[j-1]
    vadd.u16 q14, q14, q9           // imgPad2[j+1] + imgPad1[j-1]

    vdup.32 q8, d1[0]
    vdup.32 q9, d1[1]
    vdup.32 q12, d2[0]

    vmlal.s16 q4 , d30, d16         // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    vmlal.s16 q10, d31, d17
    vmlal.s16 q4 , d22, d18         // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    vmlal.s16 q10, d23, d19
    vmlal.s16 q4 , d28, d24         // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])
    vmlal.s16 q10, d29, d25

    add r11, r2, r6
    sub r11, r11, #12
    vld1.64 {q12, q13}, [r11]!      // load imgPad[j-3]
    vld1.64 {q14}, [r11]

    vext.32 q5, q12, q13, #1        // imgPad[j-2]
    vext.32 q6, q12, q13, #2        // imgPad[j-1]
    vext.32 q8, q12, q13, #3        // imgPad[j]
                                    // q13: imgPad[j+1]
    vext.32 q9, q13, q14, #1        // imgPad[j+2]
    vext.32 q15, q13, q14, #2       // imgPad[j+3]

    vadd.u16 q12, q12, q15          // imgPad[j+3] + imgPad[j-3]
    vadd.u16 q5, q5, q9             // imgPad[j+2] + imgPad[j-2]
    vadd.u16 q6, q6, q13            // imgPad[j+1] + imgPad[j-1]
                                    // q8: imgPad[j]

    vdup.32 q13, d2[1]
    vdup.32 q14, d3[0]
    vdup.32 q15, d3[1]

    vmlal.s16 q4 , d24, d26         // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    vmlal.s16 q10, d25, d27
    vmlal.s16 q4 , d10, d28         // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    vmlal.s16 q10, d11, d29
    vdup.32 q13, d4[0]
    vmlal.s16 q4 , d12, d30         // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    vmlal.s16 q10, d13, d31
    vmlal.s16 q4 , d16, d26         // pixelInt += coef[8] * (imgPad[j])
    vmlal.s16 q10, d17, d27
    add   r9, r0, r6
    vqrshrun.s32 d8, q4 , #6
    vqrshrun.s32 d9, q10, #6
    vmin.u16 q4, q4, q7

    add   r6, r6, #16
    vst1.64 {q4}, [r9]             // store imgRes[j]

    cmp   r6, r4
    blt   alf_chroma_loop_x

    add   r8, r8, #1
    add   r0, r0, r1
    add   r2, r2, r3
    cmp   r8, r5
    blt   alf_chroma_loop_y

    vpop {q4-q7}
    ldmia sp!, {r4-r12, lr}
    mov pc, lr


/****************************************************************************************************************************************************************************************************************
 *  void uavs3d_alf_one_lcu_one_chroma_armv7(pel *dst, int i_dst, pel *src, int i_src, int lcu_width, int lcu_height, int *coef, int sample_bit_depth);
 *  dst->r0, i_dst->r1, src->r2, i_src->r3, lcu_width->r4, lcu_height->r5, coef->r6, bit_depth->r7
 *****************************************************************************************************************************************************************************************************************/
function uavs3d_alf_one_lcu_one_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4, q5}
    add sp, sp, #72
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #72

    mov r9, #1
    lsl r1, #1
    lsl r3, #1
    lsl r9, r7

    vld1.32 {q0, q1}, [r6]!         // load coef[0-7]
    vld1.32 {q2, q3}, [r6]!
    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2
    vmovn.i32 d3, q3
    vld1.32 {q8}, [r6]              // load coef[8]
    vmovn.i32 d4, q8

    sub r9, #1

    ldr r10, =0x0000ffff
    vdup.s32 q3, r10                // mask_uv
    vdup.u16 q5, r9

    vmovn.i32 d0, q0
    vmovn.i32 d1, q1
    vmovn.i32 d2, q2

    mov r8, #0                      // i = startPos
    lsl r4, #2                      // lcu_width *= 2
alf_one_chroma_loop_y:
    sub r9 , r2, r3                 // imgPad2 = src - i_src;
    add r10, r2, r3                 // imgPad1 = src + i_src;
    sub r11, r2, r3, lsl #1         // imgPad4 = src - 2*i_src;
    add r12, r2, r3, lsl #1         // imgPad3 = src + 2*i_src;
    sub r6, r11, r3                 // imgPad6 = src - 3*i_src;
    add r7, r12, r3                 // imgPad5 = src + 3*i_src;

    cmp r8, #3
    bge alf_one_chroma_y_ge_3
    cmp r8, #1
    movlt r9, r2                    // i == 0
    movle r11, r9                   // i == 1
    mov   r6, r11                   // i == 2

    b alf_one_chroma_y_lt_h_minus_3

alf_one_chroma_y_ge_3:
    sub r5, #3
    cmp r8, r5
    add r5, #3
    blt alf_one_chroma_y_lt_h_minus_3
    sub r5, #2
    cmp r8, r5
    add r5, #2
    movgt r10, r2                   // i == lcu_height - 1
    movge r12, r10                  // i == lcu_height - 2
    mov   r7, r12                   // i == lcu_height - 3

alf_one_chroma_y_lt_h_minus_3:

    vmov d3, r9, r10
    vmov d4, r6, r7
    vmov d5, r11, r12
    mov r6, #0                      // j = 0
alf_one_chroma_loop_x:
    vdup.u32 q9, r6
    vadd.u32 q8, q2, q9

    vmov r9, r10, d16
    vmov r11, r12, d17

    vld1.64 {q10}, [r9]
    vld1.64 {q11}, [r10]
    vld1.64 {q12}, [r11]
    vld1.64 {q13}, [r12]
    vmovn.i32 d20, q10
    vmovn.i32 d21, q11
    vmovn.i32 d22, q12
    vmovn.i32 d23, q13

    vadd.u16 d20, d20, d21
    vadd.u16 d22, d22, d23
    vmull.s16 q4 , d20, d0[0]       // pixelInt  = coef[0] * (imgPad5[j] + imgPad6[j]);
    vmlal.s16 q4 , d22, d0[1]       // pixelInt += coef[1] * (imgPad3[j] + imgPad4[j]);

    vadd.u32 d16, d18, d3
    vmov r9, r10, d16
    sub r11, r9, #4
    sub r12, r10, #4
    vld1.64 {q12}, [r9]             // load imgPad2[j]
    vld1.64 {q13}, [r10]            // load imgPad1[j]
    add r9, r9, #4
    add r10, r10, #4
    vld1.64 {q14}, [r11]            // load imgPad2[j-1]
    vld1.64 {q15}, [r12]            // load imgPad1[j-1]
    vmovn.i32 d22, q12
    vmovn.i32 d23, q13
    vmovn.i32 d24, q14
    vmovn.i32 d25, q15

    vld1.64 {q14}, [r9]             // load imgPad2[j+1]
    vld1.64 {q15}, [r10]            // load imgPad1[j+1]
    vmovn.i32 d26, q14
    vmovn.i32 d27, q15

    add r11, r2, r6
    sub r11, r11, #12

    vadd.u16 d22, d22, d23          // imgPad2[j] + imgPad1[j]
    vadd.u16 d24, d27, d24          // imgPad1[j+1] + imgPad2[j-1]
    vadd.u16 d25, d26, d25          // imgPad2[j+1] + imgPad1[j-1]

    vld1.64 {q13, q14}, [r11]!      // load imgPad[j-3]
    vld1.64 {q15}, [r11]

    vmlal.s16 q4, d24, d0[2]        // pixelInt += coef[2] * (imgPad1[j + 1] + imgPad2[j - 1])
    vmlal.s16 q4, d22, d0[3]        // pixelInt += coef[3] * (imgPad1[j] + imgPad2[j])
    vmlal.s16 q4, d25, d1[0]        // pixelInt += coef[4] * (imgPad1[j - 1] + imgPad2[j + 1])

    vmovn.i32 d26, q13
    vmovn.i32 d27, q14
    vmovn.i32 d28, q15

    vext.16 d18, d26, d27, #1       // imgPad[j-2]
    vext.16 d19, d26, d27, #2       // imgPad[j-1]
    vext.16 d20, d26, d27, #3       // imgPad[j]
    // d27: imgPad[j+1]
    vext.16 d21, d27, d28, #1       // imgPad[j+2]
    vext.16 d22, d27, d28, #2       // imgPad[j+3]

    vadd.u16 d22, d26, d22           // imgPad[j+3] + imgPad[j-3]
    vadd.u16 d18, d21, d18           // imgPad[j+2] + imgPad[j-2]
    vadd.u16 d19, d27, d19          // imgPad[j+1] + imgPad[j-1]

    vmlal.s16 q4 , d22, d1[1]       // pixelInt += coef[5] * (imgPad[j + 3] + imgPad[j - 3])
    vmlal.s16 q4 , d18, d1[2]       // pixelInt += coef[6] * (imgPad[j + 2] + imgPad[j - 2])
    vmlal.s16 q4 , d19, d1[3]       // pixelInt += coef[7] * (imgPad[j + 1] + imgPad[j - 1])
    vmlal.s16 q4 , d20, d2[0]       // pixelInt += coef[8] * (imgPad[j])

    add   r9, r0, r6

    vqrshrun.s32 d8, q4 , #6
    vmin.u16 d8, d8, d10

    vld1.16 {q11}, [r9]
    vmovl.u16 q10, d8
    vbif  q10, q11, q3

    add   r6, r6, #16
    vst1.16 {q10}, [r9]             // store imgRes[j]

    cmp   r6, r4
    blt   alf_one_chroma_loop_x

    add   r8, r8, #1
    add   r0, r0, r1
    add   r2, r2, r3
    cmp   r8, r5
    blt   alf_one_chroma_loop_y

    vpop {q4, q5}
    ldmia sp!, {r4-r12, lr}
    mov pc, lr

#endif  // COMPILE_10BIT

#endif
