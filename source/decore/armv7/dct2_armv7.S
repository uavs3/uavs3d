/**************************************************************************************
 * Copyright (c) 2018-2022 ["Peking University Shenzhen Graduate School",
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
 * 3. Neither the name of the organizations (Peking University Shenzhen Graduate School,
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

#if defined(__arm__)

#include "def_armv7.S"

//*************************************************************************************************
//void dct_butterfly_h4_armv7(s16* src, int i_src, s16* dst, int line, int shift, int bit_depth);
//r0: coeff blk, 16 bit
//r1: i_src
//r2: resi blk, 16 bit
//r3: blk width
//r4: shift
//r5: bit_depth
//*************************************************************************************************
function uavs3d_itrans_dct_butterfly_h4_armv7
    push {r4-r8, lr}
    ldr r4, [sp, #24]
    ldr r5, [sp, #28]

    mov r8, #1
    lsl r8, r8, r5
    sub r6, r5, #20                 // -shift = bit_depth - 20
    sub r7, r8, #1                  // max_pel = (1<<bit_depth) - 1
    neg r8, r8                      // min_pel = -(1<<bit_depth)
    vdup.32 q15, r6                 // for left shift
    vdup.16 d28, r8                 // min_pel
    vdup.16 d29, r7                 // max_pel

    mov r6, #32
    mov r7, #42
    mov r8, #17
    vmov.s16 d0[0], r6
    vmov.s16 d0[2], r7
    vmov.s16 d0[3], r8

    mov r6, #0  //i=0
    lsl r1, r1, #1                  // width * sizeof(s16)
    lsl r3, r3, #1
dct2_h4_loopi:
    add r7, r0, r6
    vld1.16 d2, [r7], r1
    vld1.16 d3, [r7], r1
    vld1.16 d4, [r7], r1
    vld1.16 d5, [r7], r1

    vmull.s16 q3 , d3, d0[2]         // O[0]
    vmull.s16 q8 , d3, d0[3]         // O[1]
    vmull.s16 q9 , d2, d0[0]         // E[0]
    vmull.s16 q10, d2, d0[0]         // E[1]

    vmlal.s16 q3 , d5, d0[3]
    vmlsl.s16 q8 , d5, d0[2]
    vmlal.s16 q9 , d4, d0[0]
    vmlsl.s16 q10, d4, d0[0]

    vqadd.s32 q11, q3 , q9
    vqadd.s32 q12, q10, q8
    vqsub.s32 q13, q10, q8
    vqsub.s32 q10, q9 , q3

    cmp r5, #15
    bne dct2_h4_2nd_shift_clip

    vqrshrn.s32 d2, q11, #5
    vqrshrn.s32 d4, q12, #5
    vqrshrn.s32 d6, q13, #5
    vqrshrn.s32 d8, q10, #5
    b dct2_h4_store

dct2_h4_2nd_shift_clip:   // second transform
    vrshl.s32 q1, q11, q15
    vrshl.s32 q2, q12, q15
    vrshl.s32 q3, q13, q15
    vrshl.s32 q4, q10, q15

    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4

    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28
    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28

dct2_h4_store:
    //transpose
    vtrn.s32 d2, d6
    vtrn.s32 d4, d8
    vtrn.s16 d2, d4
    vtrn.s16 d6, d8

    add r6, r6, #8
    mov r7, #8
    vst1.64  {d2}, [r2], r7
    vst1.64  {d4}, [r2], r7
    vst1.64  {d6}, [r2], r7
    vst1.64  {d8}, [r2], r7

    cmp r6, r3
    blt dct2_h4_loopi
    pop {r4-r8, pc}


//************************************************************************
//void uavs3d_itrans_dct_butterfly_h8_armv7(s16 *src, int i_src, s16 *dst, int width, int shift, int bit_depth);
//r0: coeff blk, 16 bit
//r1: i_src
//r2: resi blk, 16 bit
//r3: blk width
//r4: shift
//r5: bit_depth
//************************************************************************
function uavs3d_itrans_dct_butterfly_h8_armv7
    push {r4-r9, lr}
    vpush {q4-q7}
    ldr r4, [sp, #92]
    ldr r5, [sp, #96]

    mov r8, #1
    lsl r8, r8, r5
    sub r6, r5, #20                // -shift = bit_depth - 20
    sub r9, r8, #1                 // max_pel = (1<<bit_depth) - 1
    neg r8, r8                     // min_pel = -(1<<bit_depth)
    vdup.32 q15, r6               // for left shift
    vdup.16 d28, r8               // min_pel
    vdup.16 d29, r9               // max_pel
    vpush {q14, q15}

    // set transform coeffs
    mov r6, #32
    mov r7, #17
    mov r8, #42
    vmov.s16 d0[0], r6
    vmov.s16 d0[1], r6
    vmov.s16 d0[2], r7
    vmov.s16 d0[3], r8

    mov r6, #9
    mov r7, #25
    mov r8, #38
    mov r9, #44
    vmov.s16 d1[0], r6
    vmov.s16 d1[1], r7
    vmov.s16 d1[2], r8
    vmov.s16 d1[3], r9

    mov r6, #0
    mvn r7, r6
    lsl r7, r7, #8
    mvn r6, r7

    mov r8, #0              // i=0
    lsl r1, r1, #1          // width * sizeof(s16)
    lsl r3, r3, #1
dct2_h8_loopi:
    add r9, r0, r8
    vld1.16 d2, [r9], r1
    vld1.16 d3, [r9], r1
    vld1.16 d4, [r9], r1
    vld1.16 d5, [r9], r1
    vld1.16 d6, [r9], r1
    vld1.16 d7, [r9], r1
    vld1.16 d8, [r9], r1
    vld1.16 d9, [r9], r1

    //E[0]
    vmull.s16 q9, d2, d0[0]
    vmlal.s16 q9, d4, d0[3]
    vmlal.s16 q9, d6, d0[0]
    vmlal.s16 q9, d8, d0[2]
    //E[1]
    vmull.s16 q10, d2, d0[0]
    vmlal.s16 q10, d4, d0[2]
    vmlsl.s16 q10, d6, d0[0]
    vmlsl.s16 q10, d8, d0[3]
    //E[2]
    vmull.s16 q11, d2, d0[0]
    vmlsl.s16 q11, d4, d0[2]
    vmlsl.s16 q11, d6, d0[0]
    vmlal.s16 q11, d8, d0[3]
    //E[3]
    vmull.s16 q12, d2, d0[0]
    vmlsl.s16 q12, d4, d0[3]
    vmlal.s16 q12, d6, d0[0]
    vmlsl.s16 q12, d8, d0[2]

    //O[0]
    vmull.s16 q13, d3, d1[3]
    vmlal.s16 q13, d5, d1[2]
    vmlal.s16 q13, d7, d1[1]
    vmlal.s16 q13, d9, d1[0]
    //O[1]
    vmull.s16 q14, d3, d1[2]
    vmlsl.s16 q14, d5, d1[0]
    vmlsl.s16 q14, d7, d1[3]
    vmlsl.s16 q14, d9, d1[1]
    //O[2]
    vmull.s16 q6, d3, d1[1]
    vmlsl.s16 q6, d5, d1[3]
    vmlal.s16 q6, d7, d1[0]
    vmlal.s16 q6, d9, d1[2]
    //O[3]
    vmull.s16 q5, d3, d1[0]
    vmlsl.s16 q5, d5, d1[1]
    vmlal.s16 q5, d7, d1[2]
    vmlsl.s16 q5, d9, d1[3]

    vadd.s32 q1, q9 , q13
    vadd.s32 q2, q10, q14
    vadd.s32 q3, q11, q6
    vadd.s32 q4, q12, q5

    vsub.s32 q5, q12, q5
    vsub.s32 q6, q11, q6
    vsub.s32 q7, q10, q14
    vsub.s32 q8, q9 , q13

    cmp r5, #15
    bne dct2_h8_2nd_shift_clip

    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d3, q5, #5
    vqrshrn.s32 d5, q6, #5
    vqrshrn.s32 d7, q7, #5
    vqrshrn.s32 d9, q8, #5

    //转置
    vtrn.s32 d2, d6
    vtrn.s32 d4, d8
    vtrn.s16 d2, d4
    vtrn.s16 d6, d8

    vtrn.s32 d3, d7
    vtrn.s32 d5, d9
    vtrn.s16 d3, d5
    vtrn.s16 d7, d9

    b dct2_h8_store

dct2_h8_2nd_shift_clip:
    vldmia sp, {q14-q15}

    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15
    vrshl.s32 q8, q8, q15

    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d3, q5
    vqmovn.s32 d5, q6
    vqmovn.s32 d7, q7
    vqmovn.s32 d9, q8

    vtrn.s32 d2, d6
    vtrn.s32 d4, d8
    vtrn.s16 d2, d4
    vtrn.s16 d6, d8

    vtrn.s32 d3, d7
    vtrn.s32 d5, d9
    vtrn.s16 d3, d5
    vtrn.s16 d7, d9

    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28
    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28

    vmin.s16 d3, d3, d29
    vmax.s16 d3, d3, d28
    vmin.s16 d5, d5, d29
    vmax.s16 d5, d5, d28
    vmin.s16 d7, d7, d29
    vmax.s16 d7, d7, d28
    vmin.s16 d9, d9, d29
    vmax.s16 d9, d9, d28

dct2_h8_store:
    add r8, r8, #8
    vst1.16 {q1, q2}, [r2]!
    vst1.16 {q3, q4}, [r2]!

    cmp r8, r3
    blt dct2_h8_loopi

    add sp, #32
    vpop {q4-q7}
    pop {r4-r9, pc}

//************************************************************************
//void uavs3d_itrans_dct_butterfly_h16_armv7(s16 *src, int i_src, s16 *dst, int width, int shift, int bit_depth);
//r0: coeff blk, 16 bit
//r1: i_src
//r2: resi blk, 16 bit
//r3: blk width
//r4: shift
//r5: bit_depth
//************************************************************************
function uavs3d_itrans_dct_butterfly_h16_armv7
    push {r4-r12, lr}
    vpush {q4-q7}
    ldr r4, [sp, #104]
    ldr r5, [sp, #108]

    mov r8, #1
    lsl r8, r8, r5
    sub r6, r5, #20                // -shift = bit_depth - 20
    sub r9, r8, #1                 // max_pel = (1<<bit_depth) - 1
    neg r8, r8                     // min_pel = -(1<<bit_depth)
    vdup.32 q15, r6               // for left shift
    vdup.16 d28, r8               // min_pel
    vdup.16 d29, r9               // max_pel
    vpush {q14-q15}

    mov r6, #9
    mov r7, #25
    mov r8, #38
    mov r9, #44
    mov r10, #32
    mov r11, #17
    vmov.s16 d0[0], r6
    vmov.s16 d0[1], r7
    vmov.s16 d0[2], r8
    vmov.s16 d0[3], r9
    vmov.s16 d1[0], r10
    vmov.s16 d1[1], r10
    vmov.s16 d1[2], r11
    mov r11, #42
    vmov.s16 d1[3], r11

    mov r6, #4
    mov r7, #13
    mov r8, #21
    mov r9, #29
    mov r10, #35
    mov r11, #40
    vmov.s16 d2[0], r6
    vmov.s16 d2[1], r7
    vmov.s16 d2[2], r8
    vmov.s16 d2[3], r9
    vmov.s16 d3[0], r10
    vmov.s16 d3[1], r11
    mov r11, #43
    vmov.s16 d3[2], r11
    mov r11, #45
    vmov.s16 d3[3], r11
    vpush {q0, q1}

    cmp r5, #15
    bne dct2_h16_2nd_transform

    lsl r9, r1, #2  // width * 2 * sizeof(s16)
    mov r8, #0  // i = 0
    lsl r1, r1, #1  // width * sizeof(s16)
    lsl r3, r3, #1

dct2_h16_1st_loopx:
    vldmia sp, {q0, q1}
    add r10, r0, r8
    vld1.16 d4, [r10], r9   //SRC[0*LINE]
    vld1.16 d6, [r10], r9   //SRC[2*LINE]
    vld1.16 d8, [r10], r9   //SRC[4*LINE]
    vld1.16 d10, [r10], r9   //SRC[6*LINE]
    vld1.16 d12, [r10], r9   //SRC[8*LINE]
    vld1.16 d14, [r10], r9   //SRC[10*LINE]
    vld1.16 d16, [r10], r9   //SRC[12*LINE]
    vld1.16 d18, [r10], r9   //SRC[14*LINE]

    vmull.s16 q10, d6, d0[3]
    vmlal.s16 q10, d10, d0[2]
    vmlal.s16 q10, d14, d0[1]
    vmlal.s16 q10, d18, d0[0]   //EO[0]

    vmull.s16 q11, d6, d0[2]
    vmlsl.s16 q11, d10, d0[0]
    vmlsl.s16 q11, d14, d0[3]
    vmlsl.s16 q11, d18, d0[1]   //EO[1]

    vmull.s16 q12, d6, d0[1]
    vmlsl.s16 q12, d10, d0[3]
    vmlal.s16 q12, d14, d0[0]
    vmlal.s16 q12, d18, d0[2]   //EO[2]

    vmull.s16 q13, d6, d0[0]
    vmlsl.s16 q13, d10, d0[1]
    vmlal.s16 q13, d14, d0[2]
    vmlsl.s16 q13, d18, d0[3]   //EO[3]

    vpush {q10, q11, q12, q13}

    vmull.s16 q10, d8, d1[3]    //EEO[0]
    vmlal.s16 q10, d16, d1[2]
    vmull.s16 q11, d4, d1[0]    //EEE[0]
    vmlal.s16 q11, d12, d1[0]
    vmull.s16 q12, d8, d1[2]    //EEO[1]
    vmlsl.s16 q12, d16, d1[3]
    vmull.s16 q13, d4, d1[0]    //EEE[1]
    vmlsl.s16 q13, d12, d1[0]

    vpush {q10, q11, q12, q13}

    vldmia sp, {q12, q13, q14, q15}

    vadd.s32 q2, q13, q12      //EE[0]
    vadd.s32 q3, q15, q14      //EE[1]
    vsub.s32 q4, q15, q14      //EE[2]
    vsub.s32 q5, q13, q12      //EE[3]

    add sp, sp, #64
    vldmia sp, {q6, q7, q8, q9}     //load EO[0-3]
    add sp, sp, #64

    vadd.s32 q10, q2, q6
    vadd.s32 q11, q3, q7
    vadd.s32 q12, q4, q8
    vadd.s32 q13, q5, q9
    vpush {q10, q11, q12, q13}  //E[0-3]
    vsub.s32 q10, q5, q9
    vsub.s32 q11, q4, q8
    vsub.s32 q12, q3, q7
    vsub.s32 q13, q2, q6
    vpush {q10, q11, q12, q13}  //E[4-7]

    add r10, r0, r8
    add r10, r10, r1
    vld1.16 d4, [r10], r9   //SRC[1*LINE]
    vld1.16 d6, [r10], r9   //SRC[3*LINE]
    vld1.16 d8, [r10], r9   //SRC[5*LINE]
    vld1.16 d10, [r10], r9   //SRC[7*LINE]
    vld1.16 d12, [r10], r9   //SRC[9*LINE]
    vld1.16 d14, [r10], r9   //SRC[11*LINE]
    vld1.16 d16, [r10], r9   //SRC[13*LINE]
    vld1.16 d18, [r10], r9   //SRC[15*LINE]

    //O[0]
    vmull.s16 q10, d4, d3[3]
    vmlal.s16 q10, d6, d3[2]
    vmlal.s16 q10, d8, d3[1]
    vmlal.s16 q10, d10, d3[0]
    vmlal.s16 q10, d12, d2[3]
    vmlal.s16 q10, d14, d2[2]
    vmlal.s16 q10, d16, d2[1]
    vmlal.s16 q10, d18, d2[0]

    //O[1]
    vmull.s16 q11, d4, d3[2]
    vmlal.s16 q11, d6, d2[3]
    vmlal.s16 q11, d8, d2[0]
    vmlsl.s16 q11, d10, d2[2]
    vmlsl.s16 q11, d12, d3[1]
    vmlsl.s16 q11, d14, d3[3]
    vmlsl.s16 q11, d16, d3[0]
    vmlsl.s16 q11, d18, d2[1]

    //O[2]
    vmull.s16 q12, d4, d3[1]
    vmlal.s16 q12, d6, d2[0]
    vmlsl.s16 q12, d8, d3[0]
    vmlsl.s16 q12, d10, d3[2]
    vmlsl.s16 q12, d12, d2[1]
    vmlal.s16 q12, d14, d2[3]
    vmlal.s16 q12, d16, d3[3]
    vmlal.s16 q12, d18, d2[2]

    //O[3]
    vmull.s16 q13, d4, d3[0]
    vmlsl.s16 q13, d6, d2[2]
    vmlsl.s16 q13, d8, d3[2]
    vmlal.s16 q13, d10, d2[0]
    vmlal.s16 q13, d12, d3[3]
    vmlal.s16 q13, d14, d2[1]
    vmlsl.s16 q13, d16, d3[1]
    vmlsl.s16 q13, d18, d2[3]
    vpush {q10, q11, q12, q13}  //O[0-3]

    //O[4]
    vmull.s16 q10, d4, d2[3]
    vmlsl.s16 q10, d6, d3[1]
    vmlsl.s16 q10, d8, d2[1]
    vmlal.s16 q10, d10, d3[3]
    vmlsl.s16 q10, d12, d2[0]
    vmlsl.s16 q10, d14, d3[2]
    vmlal.s16 q10, d16, d2[2]
    vmlal.s16 q10, d18, d3[0]

    //O[5]
    vmull.s16 q11, d4, d2[2]
    vmlsl.s16 q11, d6, d3[3]
    vmlal.s16 q11, d8, d2[3]
    vmlal.s16 q11, d10, d2[1]
    vmlsl.s16 q11, d12, d3[2]
    vmlal.s16 q11, d14, d3[0]
    vmlal.s16 q11, d16, d2[0]
    vmlsl.s16 q11, d18, d3[1]

    //O[6]
    vmull.s16 q12, d4, d2[1]
    vmlsl.s16 q12, d6, d3[0]
    vmlal.s16 q12, d8, d3[3]
    vmlsl.s16 q12, d10, d3[1]
    vmlal.s16 q12, d12, d2[2]
    vmlal.s16 q12, d14, d2[0]
    vmlsl.s16 q12, d16, d2[3]
    vmlal.s16 q12, d18, d3[2]

    //O[7]
    vmull.s16 q13, d4, d2[0]
    vmlsl.s16 q13, d6, d2[1]
    vmlal.s16 q13, d8, d2[2]
    vmlsl.s16 q13, d10, d2[3]
    vmlal.s16 q13, d12, d3[0]
    vmlsl.s16 q13, d14, d3[1]
    vmlal.s16 q13, d16, d3[2]
    vmlsl.s16 q13, d18, d3[3]
    vpush {q10-q13} //O[4-7]

    add sp, sp, #64
    vldmia sp, {q8, q9, q10, q11}
    add sp, sp, #128
    vldmia sp, {q12, q13, q14, q15}
    sub sp, sp, #192

    vadd.s32 q0, q8, q12    //DST[0]
    vadd.s32 q1, q9, q13    //DST[1]
    vadd.s32 q2, q10, q14    //DST[2]
    vadd.s32 q3, q11, q15    //DST[3]
    vsub.s32 q7, q12, q8    //DST[15]
    vsub.s32 q6, q13, q9    //DST[14]
    vsub.s32 q5, q14, q10    //DST[13]
    vsub.s32 q4, q15, q11    //DST[12]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    mov r6, r2
    add r7, r2, #24
    mov r10, #32

    vst1.64 {d0}, [r6], r10
    vst1.64 {d8}, [r7], r10
    vst1.64 {d2}, [r6], r10
    vst1.64 {d10}, [r7], r10
    vst1.64 {d4}, [r6], r10
    vst1.64 {d12}, [r7], r10
    vst1.64 {d6}, [r6]
    vst1.64 {d14}, [r7]


    vldmia sp, {q8, q9, q10, q11}
    add sp, sp, #128
    vldmia sp, {q12, q13, q14, q15}
    add sp, sp, #128

    vadd.s32 q0, q12, q8    //DST[4]
    vadd.s32 q1, q13, q9    //DST[5]
    vadd.s32 q2, q14, q10    //DST[6]
    vadd.s32 q3, q15, q11    //DST[7]
    vsub.s32 q7, q12, q8    //DST[11]
    vsub.s32 q6, q13, q9    //DST[10]
    vsub.s32 q5, q14, q10    //DST[9]
    vsub.s32 q4, q15, q11    //DST[8]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    add r6, r2, #8
    mov r7, #8
    mov r10, #24
    vst1.64 {d0}, [r6], r7
    vst1.64 {d8}, [r6], r10
    vst1.64 {d2}, [r6], r7
    vst1.64 {d10}, [r6], r10
    vst1.64 {d4}, [r6], r7
    vst1.64 {d12}, [r6], r10
    vst1.64 {d6}, [r6], r7
    vst1.64 {d14}, [r6]


    add r8, r8, #8
    add r2, r2, #128    // next 4*16*sizeof(s16)
    cmp r8, r3
    blt dct2_h16_1st_loopx

    b dct2_h16_end

dct2_h16_2nd_transform:


    lsl r9, r1, #2  // width * 2 * sizeof(s16)
    mov r8, #0  // i = 0
    lsl r1, r1, #1  // width * sizeof(s16)
    lsl r3, r3, #1
dct2_h16_2nd_loopx:
    vldmia sp, {q0, q1}
    add r10, r0, r8
    vld1.16 d4, [r10], r9   //SRC[0*LINE]
    vld1.16 d6, [r10], r9   //SRC[2*LINE]
    vld1.16 d8, [r10], r9   //SRC[4*LINE]
    vld1.16 d10, [r10], r9   //SRC[6*LINE]
    vld1.16 d12, [r10], r9   //SRC[8*LINE]
    vld1.16 d14, [r10], r9   //SRC[10*LINE]
    vld1.16 d16, [r10], r9   //SRC[12*LINE]
    vld1.16 d18, [r10], r9   //SRC[14*LINE]

    vmull.s16 q10, d6, d0[3]
    vmlal.s16 q10, d10, d0[2]
    vmlal.s16 q10, d14, d0[1]
    vmlal.s16 q10, d18, d0[0]   //EO[0]

    vmull.s16 q11, d6, d0[2]
    vmlsl.s16 q11, d10, d0[0]
    vmlsl.s16 q11, d14, d0[3]
    vmlsl.s16 q11, d18, d0[1]   //EO[1]

    vmull.s16 q12, d6, d0[1]
    vmlsl.s16 q12, d10, d0[3]
    vmlal.s16 q12, d14, d0[0]
    vmlal.s16 q12, d18, d0[2]   //EO[2]

    vmull.s16 q13, d6, d0[0]
    vmlsl.s16 q13, d10, d0[1]
    vmlal.s16 q13, d14, d0[2]
    vmlsl.s16 q13, d18, d0[3]   //EO[3]
    vpush {q10, q11, q12, q13}

    vmull.s16 q10, d8, d1[3]    //EEO[0]
    vmlal.s16 q10, d16, d1[2]
    vmull.s16 q11, d4, d1[0]    //EEE[0]
    vmlal.s16 q11, d12, d1[0]
    vmull.s16 q12, d8, d1[2]    //EEO[1]
    vmlsl.s16 q12, d16, d1[3]
    vmull.s16 q13, d4, d1[0]    //EEE[1]
    vmlsl.s16 q13, d12, d1[0]
    vpush {q10, q11, q12, q13}

    vldmia sp, {q12, q13, q14, q15}

    vadd.s32 q2, q13, q12      //EE[0]
    vadd.s32 q3, q15, q14      //EE[1]
    vsub.s32 q4, q15, q14      //EE[2]
    vsub.s32 q5, q13, q12      //EE[3]

    add sp, sp, #64
    vldmia sp, {q6, q7, q8, q9}     //load EO[0-3]
    add sp, sp, #64

    vadd.s32 q10, q2, q6
    vadd.s32 q11, q3, q7
    vadd.s32 q12, q4, q8
    vadd.s32 q13, q5, q9
    vpush {q10, q11, q12, q13}
    vsub.s32 q10, q5, q9
    vsub.s32 q11, q4, q8
    vsub.s32 q12, q3, q7
    vsub.s32 q13, q2, q6
    vpush {q10, q11, q12, q13}

    add r10, r0, r8
    add r10, r10, r1
    vld1.16 d4, [r10], r9   //SRC[1*LINE]
    vld1.16 d6, [r10], r9   //SRC[3*LINE]
    vld1.16 d8, [r10], r9   //SRC[5*LINE]
    vld1.16 d10, [r10], r9   //SRC[7*LINE]
    vld1.16 d12, [r10], r9   //SRC[9*LINE]
    vld1.16 d14, [r10], r9   //SRC[11*LINE]
    vld1.16 d16, [r10], r9   //SRC[13*LINE]
    vld1.16 d18, [r10], r9   //SRC[15*LINE]

    //O[0]
    vmull.s16 q10, d4, d3[3]
    vmlal.s16 q10, d6, d3[2]
    vmlal.s16 q10, d8, d3[1]
    vmlal.s16 q10, d10, d3[0]
    vmlal.s16 q10, d12, d2[3]
    vmlal.s16 q10, d14, d2[2]
    vmlal.s16 q10, d16, d2[1]
    vmlal.s16 q10, d18, d2[0]

    //O[1]
    vmull.s16 q11, d4, d3[2]
    vmlal.s16 q11, d6, d2[3]
    vmlal.s16 q11, d8, d2[0]
    vmlsl.s16 q11, d10, d2[2]
    vmlsl.s16 q11, d12, d3[1]
    vmlsl.s16 q11, d14, d3[3]
    vmlsl.s16 q11, d16, d3[0]
    vmlsl.s16 q11, d18, d2[1]

    //O[2]
    vmull.s16 q12, d4, d3[1]
    vmlal.s16 q12, d6, d2[0]
    vmlsl.s16 q12, d8, d3[0]
    vmlsl.s16 q12, d10, d3[2]
    vmlsl.s16 q12, d12, d2[1]
    vmlal.s16 q12, d14, d2[3]
    vmlal.s16 q12, d16, d3[3]
    vmlal.s16 q12, d18, d2[2]

    //O[3]
    vmull.s16 q13, d4, d3[0]
    vmlsl.s16 q13, d6, d2[2]
    vmlsl.s16 q13, d8, d3[2]
    vmlal.s16 q13, d10, d2[0]
    vmlal.s16 q13, d12, d3[3]
    vmlal.s16 q13, d14, d2[1]
    vmlsl.s16 q13, d16, d3[1]
    vmlsl.s16 q13, d18, d2[3]
    vpush {q10, q11, q12, q13}

    //O[4]
    vmull.s16 q10, d4, d2[3]
    vmlsl.s16 q10, d6, d3[1]
    vmlsl.s16 q10, d8, d2[1]
    vmlal.s16 q10, d10, d3[3]
    vmlsl.s16 q10, d12, d2[0]
    vmlsl.s16 q10, d14, d3[2]
    vmlal.s16 q10, d16, d2[2]
    vmlal.s16 q10, d18, d3[0]

    //O[5]
    vmull.s16 q11, d4, d2[2]
    vmlsl.s16 q11, d6, d3[3]
    vmlal.s16 q11, d8, d2[3]
    vmlal.s16 q11, d10, d2[1]
    vmlsl.s16 q11, d12, d3[2]
    vmlal.s16 q11, d14, d3[0]
    vmlal.s16 q11, d16, d2[0]
    vmlsl.s16 q11, d18, d3[1]

    //O[6]
    vmull.s16 q12, d4, d2[1]
    vmlsl.s16 q12, d6, d3[0]
    vmlal.s16 q12, d8, d3[3]
    vmlsl.s16 q12, d10, d3[1]
    vmlal.s16 q12, d12, d2[2]
    vmlal.s16 q12, d14, d2[0]
    vmlsl.s16 q12, d16, d2[3]
    vmlal.s16 q12, d18, d3[2]

    //O[7]
    vmull.s16 q13, d4, d2[0]
    vmlsl.s16 q13, d6, d2[1]
    vmlal.s16 q13, d8, d2[2]
    vmlsl.s16 q13, d10, d2[3]
    vmlal.s16 q13, d12, d3[0]
    vmlsl.s16 q13, d14, d3[1]
    vmlal.s16 q13, d16, d3[2]
    vmlsl.s16 q13, d18, d3[3]
    vpush {q10-q13}

    add sp, sp, #64
    vldmia sp, {q8, q9, q10, q11}
    add sp, sp, #128
    vldmia sp, {q12, q13, q14, q15}
    sub sp, sp, #192

    vadd.s32 q0, q8, q12    //DST[0]
    vadd.s32 q1, q9, q13    //DST[1]
    vadd.s32 q2, q10, q14    //DST[2]
    vadd.s32 q3, q11, q15    //DST[3]
    vsub.s32 q7, q12, q8    //DST[15]
    vsub.s32 q6, q13, q9    //DST[14]
    vsub.s32 q5, q14, q10    //DST[13]
    vsub.s32 q4, q15, q11    //DST[12]

    add sp, sp, #288
    vldmia sp, {q14, q15}
    sub sp, sp, #288

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    mov r6, r2
    add r7, r2, #24
    mov r10, #32
    vst1.64 {d0}, [r6], r10
    vst1.64 {d8}, [r7], r10
    vst1.64 {d2}, [r6], r10
    vst1.64 {d10}, [r7], r10
    vst1.64 {d4}, [r6], r10
    vst1.64 {d12}, [r7], r10
    vst1.64 {d6}, [r6]
    vst1.64 {d14}, [r7]


    vldmia sp, {q8, q9, q10, q11}
    add sp, sp, #128
    vldmia sp, {q12, q13, q14, q15}
    add sp, sp, #128

    vadd.s32 q0, q12, q8    //DST[4]
    vadd.s32 q1, q13, q9    //DST[5]
    vadd.s32 q2, q14, q10    //DST[6]
    vadd.s32 q3, q15, q11    //DST[7]
    vsub.s32 q7, q12, q8    //DST[11]
    vsub.s32 q6, q13, q9    //DST[10]
    vsub.s32 q5, q14, q10    //DST[9]
    vsub.s32 q4, q15, q11    //DST[8]

    add sp, sp, #32
    vldmia sp, {q14-q15}
    sub sp, sp, #32

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    add r6, r2, #8
    mov r7, #8
    mov r10, #24
    vst1.64 {d0}, [r6], r7
    vst1.64 {d8}, [r6], r10
    vst1.64 {d2}, [r6], r7
    vst1.64 {d10}, [r6], r10
    vst1.64 {d4}, [r6], r7
    vst1.64 {d12}, [r6], r10
    vst1.64 {d6}, [r6], r7
    vst1.64 {d14}, [r6]

    add r8, #8
    add r2, r2, #128
    cmp r8, r3
    blt dct2_h16_2nd_loopx

dct2_h16_end:
    add sp, #64
    vpop {q4-q7}
    pop {r4-r12, pc}

//**********************************************************
// input:
//   r10: src
//   r6: i_src*8
//   r7: i_src*4
//   r9: i_src*2
//   r1: i_src
//   q0, q1, q2, q3: dct2 coeffs
// output:
//   sp[0-256]: EE[0]-EE[7] EO[0]-EO[7]
//   sp[256-512]: O[0]-O[15]
//   sp[512-768]: E[0]-E[15]
//**********************************************************
.macro dct2_h32_w4_calcu_E_O_armv7

    vld1.16 d8, [r10], r6   // src[0]
    vld1.16 d9, [r10], r6   // src[8*i_src]
    vld1.16 d10, [r10], r6   // src[16*i_src]
    vld1.16 d11, [r10], r6   // src[24*i_src]

    vmull.s16 q6, d9, d4[3]
    vmull.s16 q7, d9, d4[2]
    vmull.s16 q8, d8, d4[0]
    vmull.s16 q9, d8, d4[0]
    vmlal.s16 q6, d11, d4[2]    // EEEO[0]
    vmlsl.s16 q7, d11, d4[3]    // EEEO[1]
    vmlal.s16 q8, d10, d4[0]    // EEEE[0]
    vmlsl.s16 q9, d10, d4[0]    // EEEE[1]

    vadd.s32 q10, q8, q6        // EEE[0]
    vadd.s32 q11, q9, q7        // EEE[1]
    vsub.s32 q12, q9, q7        // EEE[2]
    vsub.s32 q13, q8, q6        // EEE[3]

    // CALCULATE EEO
    add r10, r0, r8
    add r10, r10, r7
    vld1.16 d8, [r10], r6          // src[ 4*line  ]
    vld1.16 d9, [r10], r6          // src[ 12*line  ]
    vld1.16 d10, [r10], r6          // src[ 20*line ]
    vld1.16 d11, [r10], r6          // src[ 28*line ]

    vmull.s16 q6, d8, d5[3]
    vmull.s16 q7, d8, d5[2]
    vmull.s16 q8, d8, d5[1]
    vmull.s16 q9, d8, d5[0]

    vmlal.s16 q6, d9, d5[2]
    vmlsl.s16 q7, d9, d5[0]
    vmlsl.s16 q8, d9, d5[3]
    vmlsl.s16 q9, d9, d5[1]

    vmlal.s16 q6, d10, d5[1]
    vmlsl.s16 q7, d10, d5[3]
    vmlal.s16 q8, d10, d5[0]
    vmlal.s16 q9, d10, d5[2]

    vmlal.s16 q6, d11, d5[0]   // EEO[0]
    vmlsl.s16 q7, d11, d5[1]   // EEO[1]
    vmlal.s16 q8, d11, d5[2]   // EEO[2]
    vmlsl.s16 q9, d11, d5[3]   // EEO[3]

    // CALCULATE EE
    vadd.s32 q14, q10, q6      // EE[0]
    vadd.s32 q15, q11, q7      // EE[1]
    vpush {q14, q15}
    vadd.s32 q14, q12, q8      // EE[2]
    vadd.s32 q15, q13, q9      // EE[3]
    vpush {q14, q15}
    vsub.s32 q14, q13, q9      // EE[4]
    vsub.s32 q15, q12, q8      // EE[5]
    vpush {q14, q15}
    vsub.s32 q14, q11, q7      // EE[6]
    vsub.s32 q15, q10, q6      // EE[7]
    vpush {q14, q15}

    //CALCULATE EO
    add r10, r0, r8
    add r10, r10, r9           // src + 2*i_src

    vld1.16 d8, [r10], r7          // src[ 2*line ]
    vld1.16 d9, [r10], r7          // src[ 6*line ]
    vld1.16 d10, [r10], r7          // src[ 10*line ]
    vld1.16 d11, [r10], r7          // src[ 14*line ]
    vld1.16 d12, [r10], r7          // src[ 18*line ]
    vld1.16 d13, [r10], r7          // src[ 22*line ]
    vld1.16 d14, [r10], r7          // src[ 26*line ]
    vld1.16 d15, [r10], r7          // src[ 30*line ]

    vmull.s16 q8, d8, d6[0]
    vmull.s16 q9, d8, d6[1]
    vmull.s16 q10, d8, d6[2]
    vmull.s16 q11, d8, d6[3]

    vmlsl.s16 q8, d9, d6[1]
    vmlsl.s16 q9, d9, d7[0]
    vmlsl.s16 q10, d9, d7[3]
    vmlsl.s16 q11, d9, d7[1]

    vmlal.s16 q8, d10, d6[2]
    vmlal.s16 q9, d10, d7[3]
    vmlal.s16 q10, d10, d6[3]
    vmlsl.s16 q11, d10, d6[1]

    vmlsl.s16 q8, d11, d6[3]
    vmlsl.s16 q9, d11, d7[1]
    vmlal.s16 q10, d11, d6[1]
    vmlal.s16 q11, d11, d7[3]

    vmlal.s16 q8, d12, d7[0]
    vmlal.s16 q9, d12, d6[2]
    vmlsl.s16 q10, d12, d7[2]
    vmlsl.s16 q11, d12, d6[0]

    vmlsl.s16 q8, d13, d7[1]
    vmlal.s16 q9, d13, d6[0]
    vmlal.s16 q10, d13, d7[0]
    vmlsl.s16 q11, d13, d7[2]

    vmlal.s16 q8, d14, d7[2]
    vmlsl.s16 q9, d14, d6[3]
    vmlal.s16 q10, d14, d6[0]
    vmlal.s16 q11, d14, d6[2]

    vmlsl.s16 q8, d15, d7[3]   // EO[7]
    vmlal.s16 q9, d15, d7[2]   // EO[6]
    vmlsl.s16 q10, d15, d7[1]   // EO[5]
    vmlal.s16 q11, d15, d7[0]   // EO[4]
    vpush {q8-q11}

    vmull.s16 q12, d8, d7[0]
    vmull.s16 q13, d8, d7[1]
    vmull.s16 q14, d8, d7[2]
    vmull.s16 q15, d8, d7[3]

    vmlsl.s16 q12, d9, d6[2]
    vmlal.s16 q13, d9, d6[0]
    vmlal.s16 q14, d9, d6[3]
    vmlal.s16 q15, d9, d7[2]

    vmlsl.s16 q12, d10, d7[2]
    vmlsl.s16 q13, d10, d7[0]
    vmlal.s16 q14, d10, d6[0]
    vmlal.s16 q15, d10, d7[1]

    vmlal.s16 q12, d11, d6[0]
    vmlsl.s16 q13, d11, d7[2]
    vmlsl.s16 q14, d11, d6[2]
    vmlal.s16 q15, d11, d7[0]

    vmlal.s16 q12, d12, d7[3]
    vmlsl.s16 q13, d12, d6[1]
    vmlsl.s16 q14, d12, d7[1]
    vmlal.s16 q15, d12, d6[3]

    vmlal.s16 q12, d13, d6[1]
    vmlal.s16 q13, d13, d6[3]
    vmlsl.s16 q14, d13, d7[3]
    vmlal.s16 q15, d13, d6[2]

    vmlsl.s16 q12, d14, d7[1]
    vmlal.s16 q13, d14, d7[3]
    vmlsl.s16 q14, d14, d7[0]
    vmlal.s16 q15, d14, d6[1]

    vmlsl.s16 q12, d15, d6[3]   // EO[3]
    vmlal.s16 q13, d15, d6[2]   // EO[2]
    vmlsl.s16 q14, d15, d6[1]   // EO[1]
    vmlal.s16 q15, d15, d6[0]   // EO[0]

    vpush {q12-q15}
    add sp, sp, #224
    vldmia sp, {q8, q9}
    sub sp, sp, #32
    vldmia sp, {q10, q11}
    sub sp, sp, #192
    vadd.s32 q4, q8, q15       // E[0]
    vadd.s32 q5, q9, q14       // E[1]
    vadd.s32 q6, q10, q13       // E[2]
    vadd.s32 q7, q11, q12       // E[3]
    vpush {q4-q7}

    add sp, sp, #224
    vldmia sp, {q8, q9}
    sub sp, sp, #32
    vldmia sp, {q10, q11}
    sub sp, sp, #64
    vldmia sp, {q12-q15}
    sub sp, sp, #128
    vadd.s32 q4, q8, q15       // E[4]
    vadd.s32 q5, q9, q14       // E[5]
    vadd.s32 q6, q10, q13       // E[6]
    vadd.s32 q7, q11, q12       // E[7]
    vpush {q4-q7}

    vsub.s32 q4, q11, q12       // E[8]
    vsub.s32 q5, q10, q13       // E[9]
    vsub.s32 q6, q9, q14       // E[10]
    vsub.s32 q7, q8, q15       // E[11]
    vpush {q4-q7}
    add sp, sp, #192
    vldmia sp, {q12-q15}
    add sp, sp, #224
    vldmia sp, {q8, q9}
    sub sp, sp, #32
    vldmia sp, {q10, q11}
    sub sp, sp, #384
    vsub.s32 q4, q11, q12       // E[12]
    vsub.s32 q5, q10, q13       // E[13]
    vsub.s32 q6, q9, q14       // E[14]
    vsub.s32 q7, q8, q15       // E[15]
    vpush {q4-q7}

  //CALCULATE O
    add r10, r0, r8
    add r10, r10, r1                // src + i_src

    vld1.16 d8, [r10], r9         //src[ 1*line ]
    vld1.16 d9, [r10], r9         //src[ 3*line ]
    vld1.16 d10, [r10], r9         //src[ 5*line ]
    vld1.16 d11, [r10], r9         //src[ 7*line ]
    vld1.16 d12, [r10], r9         //src[ 9*line ]
    vld1.16 d13, [r10], r9         //src[ 11*line ]
    vld1.16 d14, [r10], r9         //src[ 13*line ]
    vld1.16 d15, [r10], r9         //src[ 15*line ]
    vld1.16 d16, [r10], r9         //src[ 17*line ]
    vld1.16 d17, [r10], r9         //src[ 19*line ]
    vld1.16 d18, [r10], r9         //src[ 21*line ]
    vld1.16 d19, [r10], r9         //src[ 23*line ]
    vld1.16 d20, [r10], r9         //src[ 25*line ]
    vld1.16 d21, [r10], r9         //src[ 27*line ]
    vld1.16 d22, [r10], r9         //src[ 29*line ]
    vld1.16 d23, [r10], r9         //src[ 31*line ]

    //O[15]
    vmull.s16 q15, d8, d0[0]
    vmlsl.s16 q15, d9, d0[1]
    vmlal.s16 q15, d10, d0[2]
    vmlsl.s16 q15, d11, d0[3]

    vmlal.s16 q15, d12, d1[0]
    vmlsl.s16 q15, d13, d1[1]
    vmlal.s16 q15, d14, d1[2]
    vmlsl.s16 q15, d15, d1[3]

    vmlal.s16 q15, d16, d2[0]
    vmlsl.s16 q15, d17, d2[1]
    vmlal.s16 q15, d18, d2[2]
    vmlsl.s16 q15, d19, d2[3]

    vmlal.s16 q15, d20, d3[0]
    vmlsl.s16 q15, d21, d3[1]
    vmlal.s16 q15, d22, d3[2]
    vmlsl.s16 q15, d23, d3[3]

    //O[14]
    vmull.s16 q14, d8, d0[1]
    vmlsl.s16 q14, d9, d1[0]
    vmlal.s16 q14, d10, d1[3]
    vmlsl.s16 q14, d11, d2[2]

    vmlal.s16 q14, d12, d3[1]
    vmlsl.s16 q14, d13, d3[3]
    vmlal.s16 q14, d14, d3[0]
    vmlsl.s16 q14, d15, d2[1]

    vmlal.s16 q14, d16, d1[2]
    vmlsl.s16 q14, d17, d0[3]
    vmlal.s16 q14, d18, d0[0]
    vmlal.s16 q14, d19, d0[2]

    vmlsl.s16 q14, d20, d1[1]
    vmlal.s16 q14, d21, d2[0]
    vmlsl.s16 q14, d22, d2[3]
    vmlal.s16 q14, d23, d3[3]

    //O[13]
    vmull.s16 q13, d8, d0[2]
    vmlsl.s16 q13, d9, d1[3]
    vmlal.s16 q13, d10, d3[0]
    vmlsl.s16 q13, d11, d3[3]

    vmlal.s16 q13, d12, d2[1]
    vmlsl.s16 q13, d13, d1[0]
    vmlsl.s16 q13, d14, d0[0]
    vmlal.s16 q13, d15, d1[1]

    vmlsl.s16 q13, d16, d2[2]
    vmlal.s16 q13, d17, d3[2]
    vmlsl.s16 q13, d18, d2[3]
    vmlal.s16 q13, d19, d1[2]

    vmlsl.s16 q13, d20, d0[1]
    vmlsl.s16 q13, d21, d0[3]
    vmlal.s16 q13, d22, d2[0]
    vmlsl.s16 q13, d23, d3[1]

    //O[12]
    vmull.s16 q12, d8, d0[3]
    vmlsl.s16 q12, d9, d2[2]
    vmlal.s16 q12, d10, d3[3]
    vmlsl.s16 q12, d11, d1[3]

    vmlal.s16 q12, d12, d0[0]
    vmlal.s16 q12, d13, d1[2]
    vmlsl.s16 q12, d14, d3[1]
    vmlal.s16 q12, d15, d2[3]

    vmlsl.s16 q12, d16, d1[0]
    vmlsl.s16 q12, d17, d0[2]
    vmlal.s16 q12, d18, d2[1]
    vmlsl.s16 q12, d19, d3[3]

    vmlal.s16 q12, d20, d2[0]
    vmlsl.s16 q12, d21, d0[1]
    vmlsl.s16 q12, d22, d1[1]
    vmlal.s16 q12, d23, d3[0]

    sub sp, sp, #192
    vpush {q12-q15}

    //O[11]
    vmull.s16 q15, d8, d1[0]
    vmlsl.s16 q15, d9, d3[1]
    vmlal.s16 q15, d10, d2[1]
    vmlsl.s16 q15, d11, d0[0]

    vmlsl.s16 q15, d12, d2[0]
    vmlal.s16 q15, d13, d3[3]
    vmlsl.s16 q15, d14, d1[1]
    vmlsl.s16 q15, d15, d0[3]

    vmlal.s16 q15, d16, d3[0]
    vmlsl.s16 q15, d17, d2[2]
    vmlal.s16 q15, d18, d0[1]
    vmlal.s16 q15, d19, d1[3]

    vmlsl.s16 q15, d20, d3[3]
    vmlal.s16 q15, d21, d1[2]
    vmlal.s16 q15, d22, d0[2]
    vmlsl.s16 q15, d23, d2[3]

    //O[10]
    vmull.s16 q14, d8, d1[1]
    vmlsl.s16 q14, d9, d3[3]
    vmlal.s16 q14, d10, d1[0]
    vmlal.s16 q14, d11, d1[2]

    vmlsl.s16 q14, d12, d3[3]
    vmlal.s16 q14, d13, d0[3]
    vmlal.s16 q14, d14, d1[3]
    vmlsl.s16 q14, d15, d3[1]

    vmlal.s16 q14, d16, d0[2]
    vmlal.s16 q14, d17, d2[0]
    vmlsl.s16 q14, d18, d3[0]
    vmlal.s16 q14, d19, d0[1]

    vmlal.s16 q14, d20, d2[1]
    vmlsl.s16 q14, d21, d2[3]
    vmlal.s16 q14, d22, d0[0]
    vmlal.s16 q14, d23, d2[2]

    //O[9]
    vmull.s16 q13, d8, d1[2]
    vmlsl.s16 q13, d9, d3[0]
    vmlsl.s16 q13, d10, d0[0]
    vmlal.s16 q13, d11, d3[1]

    vmlsl.s16 q13, d12, d1[1]
    vmlsl.s16 q13, d13, d1[3]
    vmlal.s16 q13, d14, d2[3]
    vmlal.s16 q13, d15, d0[1]

    vmlsl.s16 q13, d16, d3[3]
    vmlal.s16 q13, d17, d1[0]
    vmlal.s16 q13, d18, d2[0]
    vmlsl.s16 q13, d19, d2[2]

    vmlsl.s16 q13, d20, d0[2]
    vmlal.s16 q13, d21, d3[3]
    vmlsl.s16 q13, d22, d0[3]
    vmlsl.s16 q13, d23, d2[1]

    //O[8]
    vmull.s16 q12, d8, d1[3]
    vmlsl.s16 q12, d9, d2[1]
    vmlsl.s16 q12, d10, d1[1]
    vmlal.s16 q12, d11, d2[3]

    vmlal.s16 q12, d12, d0[3]
    vmlsl.s16 q12, d13, d3[1]
    vmlsl.s16 q12, d14, d0[1]
    vmlal.s16 q12, d15, d3[3]

    vmlsl.s16 q12, d16, d0[0]
    vmlsl.s16 q12, d17, d3[3]
    vmlal.s16 q12, d18, d0[2]
    vmlal.s16 q12, d19, d3[0]

    vmlsl.s16 q12, d20, d1[0]
    vmlsl.s16 q12, d21, d2[2]
    vmlal.s16 q12, d22, d1[2]
    vmlal.s16 q12, d23, d2[0]
    add sp, sp, #128
    vpush {q12-q15}

    //O[7]
    vmull.s16 q15, d8, d2[0]
    vmlsl.s16 q15, d9, d1[2]
    vmlsl.s16 q15, d10, d2[2]
    vmlal.s16 q15, d11, d1[0]

    vmlal.s16 q15, d12, d3[0]
    vmlsl.s16 q15, d13, d0[2]
    vmlsl.s16 q15, d14, d3[3]
    vmlal.s16 q15, d15, d0[0]

    vmlal.s16 q15, d16, d3[3]
    vmlal.s16 q15, d17, d0[1]
    vmlsl.s16 q15, d18, d3[1]
    vmlsl.s16 q15, d19, d0[3]

    vmlal.s16 q15, d20, d2[3]
    vmlal.s16 q15, d21, d1[1]
    vmlsl.s16 q15, d22, d2[1]
    vmlsl.s16 q15, d23, d1[3]

    //O[6]
    vmull.s16 q14, d8, d2[1]
    vmlsl.s16 q14, d9, d0[3]
    vmlsl.s16 q14, d10, d3[3]
    vmlsl.s16 q14, d11, d0[2]

    vmlal.s16 q14, d12, d2[2]
    vmlal.s16 q14, d13, d2[0]
    vmlsl.s16 q14, d14, d1[0]
    vmlsl.s16 q14, d15, d3[3]

    vmlsl.s16 q14, d16, d0[1]
    vmlal.s16 q14, d17, d2[3]
    vmlal.s16 q14, d18, d1[3]
    vmlsl.s16 q14, d19, d1[1]

    vmlsl.s16 q14, d20, d3[1]
    vmlsl.s16 q14, d21, d0[0]
    vmlal.s16 q14, d22, d3[0]
    vmlal.s16 q14, d23, d1[2]

    //O[5]
    vmull.s16 q13, d8, d2[2]
    vmlsl.s16 q13, d9, d0[0]
    vmlsl.s16 q13, d10, d2[3]
    vmlsl.s16 q13, d11, d2[1]

    vmlal.s16 q13, d12, d0[1]
    vmlal.s16 q13, d13, d3[0]
    vmlal.s16 q13, d14, d2[0]
    vmlsl.s16 q13, d15, d0[2]

    vmlsl.s16 q13, d16, d3[1]
    vmlsl.s16 q13, d17, d1[3]
    vmlal.s16 q13, d18, d0[3]
    vmlal.s16 q13, d19, d3[3]

    vmlal.s16 q13, d20, d1[2]
    vmlsl.s16 q13, d21, d1[0]
    vmlsl.s16 q13, d22, d3[3]
    vmlsl.s16 q13, d23, d1[1]

    //O[4]
    vmull.s16 q12, d8, d2[3]
    vmlal.s16 q12, d9, d0[2]
    vmlsl.s16 q12, d10, d1[2]
    vmlsl.s16 q12, d11, d3[2]

    vmlsl.s16 q12, d12, d1[3]
    vmlal.s16 q12, d13, d0[1]
    vmlal.s16 q12, d14, d2[2]
    vmlal.s16 q12, d15, d3[0]

    vmlal.s16 q12, d16, d0[3]
    vmlsl.s16 q12, d17, d1[1]
    vmlsl.s16 q12, d18, d3[3]
    vmlsl.s16 q12, d19, d2[0]

    vmlal.s16 q12, d20, d0[0]
    vmlal.s16 q12, d21, d2[1]
    vmlal.s16 q12, d22, d3[1]
    vmlal.s16 q12, d23, d1[0]
    add sp, sp, #128
    vpush {q12-q15}

    //O[3]
    vmull.s16 q15, d8, d3[0]
    vmlal.s16 q15, d9, d1[1]
    vmlsl.s16 q15, d10, d0[1]
    vmlsl.s16 q15, d11, d2[0]

    vmlsl.s16 q15, d12, d3[3]
    vmlsl.s16 q15, d13, d2[1]
    vmlsl.s16 q15, d14, d0[2]
    vmlal.s16 q15, d15, d1[0]

    vmlal.s16 q15, d16, d2[3]
    vmlal.s16 q15, d17, d3[1]
    vmlal.s16 q15, d18, d1[2]
    vmlsl.s16 q15, d19, d0[0]

    vmlsl.s16 q15, d20, d1[3]
    vmlsl.s16 q15, d21, d3[3]
    vmlsl.s16 q15, d22, d2[2]
    vmlsl.s16 q15, d23, d0[3]

    //O[2]
    vmull.s16 q14, d8, d3[1]
    vmlal.s16 q14, d9, d2[0]
    vmlal.s16 q14, d10, d0[3]
    vmlsl.s16 q14, d11, d0[1]

    vmlsl.s16 q14, d12, d1[2]
    vmlsl.s16 q14, d13, d2[3]
    vmlsl.s16 q14, d14, d3[3]
    vmlsl.s16 q14, d15, d2[2]

    vmlsl.s16 q14, d16, d1[1]
    vmlsl.s16 q14, d17, d0[0]
    vmlal.s16 q14, d18, d1[0]
    vmlal.s16 q14, d19, d2[1]

    vmlal.s16 q14, d20, d3[3]
    vmlal.s16 q14, d21, d3[0]
    vmlal.s16 q14, d22, d1[3]
    vmlal.s16 q14, d23, d0[2]

    //O[1]
    vmull.s16 q13, d8, d3[3]
    vmlal.s16 q13, d9, d2[3]
    vmlal.s16 q13, d10, d2[0]
    vmlal.s16 q13, d11, d1[1]

    vmlal.s16 q13, d12, d0[2]
    vmlsl.s16 q13, d13, d0[0]
    vmlsl.s16 q13, d14, d0[3]
    vmlsl.s16 q13, d15, d1[2]

    vmlsl.s16 q13, d16, d2[1]
    vmlsl.s16 q13, d17, d3[0]
    vmlsl.s16 q13, d18, d3[3]
    vmlsl.s16 q13, d19, d3[1]

    vmlsl.s16 q13, d20, d2[2]
    vmlsl.s16 q13, d21, d1[3]
    vmlsl.s16 q13, d22, d1[0]
    vmlsl.s16 q13, d23, d0[1]

    //O[0]
    vmull.s16 q12, d8, d3[3]
    vmlal.s16 q12, d9, d3[2]
    vmlal.s16 q12, d10, d3[1]
    vmlal.s16 q12, d11, d3[0]

    vmlal.s16 q12, d12, d2[3]
    vmlal.s16 q12, d13, d2[2]
    vmlal.s16 q12, d14, d2[1]
    vmlal.s16 q12, d15, d2[0]

    vmlal.s16 q12, d16, d1[3]
    vmlal.s16 q12, d17, d1[2]
    vmlal.s16 q12, d18, d1[1]
    vmlal.s16 q12, d19, d1[0]

    vmlal.s16 q12, d20, d0[3]
    vmlal.s16 q12, d21, d0[2]
    vmlal.s16 q12, d22, d0[1]
    vmlal.s16 q12, d23, d0[0]
    add sp, sp, #128
    vpush {q12-q15}
    sub sp, sp, #192

.endm
//************************************************************************
//void uavs3d_itrans_dct_butterfly_h32_armv7(s16* src, int i_src, s16* dst, int line, int shift, int bit_depth);
//r0: coeff blk, 16 bit
//r1: i_src
//r2: resi blk, 16 bit
//r3: blk width
//r4: shift
//r5: bit_depth
//************************************************************************
function uavs3d_itrans_dct_butterfly_h32_armv7
    push {r4-r12, lr}
    vpush {q4-q7}
    ldr r4, [sp, #104]
    ldr r5, [sp, #108]

    mov r8, #1
    lsl r8, r8, r5
    sub r6, r5, #20                // -shift = bit_depth - 20
    sub r9, r8, #1                 // max_pel = (1<<bit_depth) - 1
    neg r8, r8                     // min_pel = -(1<<bit_depth)
    vdup.32 q15, r6               // for left shift
    vdup.16 d28, r8               // min_pel
    vdup.16 d29, r9               // max_pel
    vpush {q14-q15}

    mov r6, #32
    mov r7, #17
    mov r8, #42
    mov r9, #9
    mov r10, #25
    mov r11, #38
    vmov.s16 d4[0], r6
    vmov.s16 d4[1], r6
    vmov.s16 d4[2], r7
    vmov.s16 d4[3], r8
    vmov.s16 d5[0], r9
    vmov.s16 d5[1], r10
    vmov.s16 d5[2], r11
    mov r6, #44
    vmov.s16 d5[3], r6

    mov r6, #4
    mov r7, #13
    mov r8, #21
    mov r9, #29
    mov r10, #35
    mov r11, #40
    vmov.s16 d6[0], r6
    vmov.s16 d6[1], r7
    vmov.s16 d6[2], r8
    vmov.s16 d6[3], r9
    vmov.s16 d7[0], r10
    vmov.s16 d7[1], r11
    mov r6, #43
    vmov.s16 d7[2], r6
    mov r6, #45
    vmov.s16 d7[3], r6

    mov r6, #2
    mov r7, #7
    mov r8, #11
    mov r9, #15
    mov r10, #19
    mov r11, #23
    vmov.s16 d0[0], r6
    vmov.s16 d0[1], r7
    vmov.s16 d0[2], r8
    vmov.s16 d0[3], r9
    vmov.s16 d1[0], r10
    vmov.s16 d1[1], r11
    mov r6, #27
    vmov.s16 d1[2], r6
    mov r6, #30
    vmov.s16 d1[3], r6

    mov r6, #34
    mov r7, #36
    mov r8, #39
    mov r9, #41
    mov r10, #43
    mov r11, #44
    vmov.s16 d2[0], r6
    vmov.s16 d2[1], r7
    vmov.s16 d2[2], r8
    vmov.s16 d2[3], r9
    vmov.s16 d3[0], r10
    vmov.s16 d3[1], r11
    mov r6, #45
    vmov.s16 d3[2], r6
    vmov.s16 d3[3], r6

    mov r11, #64                    // i_dst = 64
    lsl r3, r3, #1                  // line
    lsl r1, r1, #1                  // i_src = width * sizeof(s16)
    lsl r6, r1, #3                  // 8*i_src
    lsl r7, r1, #2                  // 4*i_src
    lsl r9, r1, #1                  // 2*i_src
    mov r8, #0      // i = 0
    cmp r5, #15
    bne dct2_h32_2nd_loopx

dct2_h32_1st_loopx:
    add r10, r0, r8
    dct2_h32_w4_calcu_E_O_armv7
    // dst[0-7]
    add sp, sp, #192
    vldmia sp, {q4-q7} //O[0]-O[3]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[0]-E[3]
    sub sp, sp, #448

    vadd.s32 q12, q8, q4       // DST[0]
    vadd.s32 q13, q9, q5       // DST[1]
    vadd.s32 q14, q10, q6       // DST[2]
    vadd.s32 q15, q11, q7       // DST[3]
    vpush {q12-q15}

    add sp, sp, #192
    vldmia sp, {q4-q7} //O[4]-O[7]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[4]-E[7]
    sub sp, sp, #448
    vadd.s32 q12, q8, q4       // DST[4]
    vadd.s32 q13, q9, q5       // DST[5]
    vadd.s32 q14, q10, q6       // DST[6]
    vadd.s32 q15, q11, q7       // DST[7]
    vpush {q12-q15}

    vpop {q8-q11}
    vpop {q4-q7}

    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5
    vqrshrn.s32 d16, q8, #5
    vqrshrn.s32 d18, q9, #5
    vqrshrn.s32 d20, q10, #5
    vqrshrn.s32 d22, q11, #5

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    push {r5,r6}
    mov r5, r2
    add r6, r2, #8
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5], r11
    vst1.64 {d22}, [r6], r11
    pop {r5, r6}

    // dst[24-31]
    add sp, sp, #192
    vldmia sp, {q4-q7} //O[0]-O[3]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[0]-E[3]
    sub sp, sp, #448

    vsub.s32 q15, q8, q4       // DST[31]
    vsub.s32 q14, q9, q5       // DST[30]
    vsub.s32 q13, q10, q6       // DST[29]
    vsub.s32 q12, q11, q7       // DST[28]
    sub sp, sp, #64
    vpush {q12-q15}

    add sp, sp, #256
    vldmia sp, {q4-q7} //O[4]-O[7]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[4]-E[7]
    sub sp, sp, #384
    vsub.s32 q15, q8, q4       // DST[27]
    vsub.s32 q14, q9, q5       // DST[26]
    vsub.s32 q13, q10, q6       // DST[25]
    vsub.s32 q12, q11, q7       // DST[24]
    vpush {q12-q15}
    sub sp, sp, #64

    vpop {q8-q11}
    vpop {q4-q7}

    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5
    vqrshrn.s32 d16, q8, #5
    vqrshrn.s32 d18, q9, #5
    vqrshrn.s32 d20, q10, #5
    vqrshrn.s32 d22, q11, #5

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    push {r5, r6}
    add r5, r2, #48
    add r6, r2, #56
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5], r11
    vst1.64 {d22}, [r6], r11
    pop {r5, r6}

//  dst[8-15]
    add sp, sp, #64
    vldmia sp, {q4-q7}  // O[8]-O[11]
    add sp, sp, #256
    vldmia sp, {q8-q11}  // E[8]-E[11]
    sub sp, sp, #320

    vadd.s32 q12, q8, q4       // DST[8]
    vadd.s32 q13, q9, q5       // DST[9]
    vadd.s32 q14, q10, q6       // DST[10]
    vadd.s32 q15, q11, q7       // DST[11]
    vpush {q12-q15}

    add sp, sp, #64
    vldmia sp, {q4-q7} //O[12]-O[15]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[12]-E[15]
    sub sp, sp, #320
    vadd.s32 q12, q8, q4       // DST[12]
    vadd.s32 q13, q9, q5       // DST[13]
    vadd.s32 q14, q10, q6       // DST[14]
    vadd.s32 q15, q11, q7       // DST[15]
    vpush {q12-q15}

    vpop {q8-q11}
    vpop {q4-q7}

    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5
    vqrshrn.s32 d16, q8, #5
    vqrshrn.s32 d18, q9, #5
    vqrshrn.s32 d20, q10, #5
    vqrshrn.s32 d22, q11, #5

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    push {r5,r6}
    add r5, r2, #16
    add r6, r2, #24
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5], r11
    vst1.64 {d22}, [r6], r11
    pop {r5,r6}

// dst[16-23]
    add sp, sp, #64
    vldmia sp, {q4-q7} //O[8]-O[11]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[8]-E[11]
    sub sp, sp, #320

    vsub.s32 q15, q8, q4       // DST[23]
    vsub.s32 q14, q9, q5       // DST[22]
    vsub.s32 q13, q10, q6       // DST[21]
    vsub.s32 q12, q11, q7       // DST[20]
    sub sp, sp, #64
    vpush {q12-q15}

    add sp, sp, #128
    vldmia sp, {q4-q7} //O[12-15]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[12-15]
    sub sp, sp, #256
    vsub.s32 q15, q8, q4       // DST[19]
    vsub.s32 q14, q9, q5       // DST[18]
    vsub.s32 q13, q10, q6       // DST[17]
    vsub.s32 q12, q11, q7       // DST[16]
    vpush {q12-q15}
    sub sp, sp, #64

    vpop {q8-q11}
    vpop {q4-q7}

    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5
    vqrshrn.s32 d16, q8, #5
    vqrshrn.s32 d18, q9, #5
    vqrshrn.s32 d20, q10, #5
    vqrshrn.s32 d22, q11, #5

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    push {r5, r6}
    add r5, r2, #32
    add r6, r2, #40
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5]
    vst1.64 {d22}, [r6]
    pop {r5, r6}

    add r8, r8, #8
    add sp, sp, #768
    add r2, r2, #256
    cmp r8, r3
    blt dct2_h32_1st_loopx
    b dct2_h32_end

dct2_h32_2nd_loopx:
    add r10, r0, r8
    dct2_h32_w4_calcu_E_O_armv7
    // dst[0-7]
    add sp, sp, #192
    vldmia sp, {q4-q7} //O[0]-O[3]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[0]-E[3]
    sub sp, sp, #448

    vadd.s32 q12, q8, q4       // DST[0]
    vadd.s32 q13, q9, q5       // DST[1]
    vadd.s32 q14, q10, q6       // DST[2]
    vadd.s32 q15, q11, q7       // DST[3]
    vpush {q12-q15}

    add sp, sp, #192
    vldmia sp, {q4-q7} //O[4]-O[7]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[4]-E[7]
    sub sp, sp, #448
    vadd.s32 q12, q8, q4       // DST[4]
    vadd.s32 q13, q9, q5       // DST[5]
    vadd.s32 q14, q10, q6       // DST[6]
    vadd.s32 q15, q11, q7       // DST[7]
    vpush {q12-q15}

    vpop {q8-q11}
    vpop {q4-q7}

    add sp, sp, #768
    vldmia sp, {q14, q15}
    sub sp, sp, #768


    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15
    vrshl.s32 q8, q8, q15
    vrshl.s32 q9, q9, q15
    vrshl.s32 q10, q10, q15
    vrshl.s32 q11, q11, q15

    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7
    vqmovn.s32 d16, q8
    vqmovn.s32 d18, q9
    vqmovn.s32 d20, q10
    vqmovn.s32 d22, q11

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28
    vmin.s16 d18, d18, d29
    vmax.s16 d18, d18, d28
    vmin.s16 d20, d20, d29
    vmax.s16 d20, d20, d28
    vmin.s16 d22, d22, d29
    vmax.s16 d22, d22, d28

    push {r5,r6}
    mov r5, r2
    add r6, r2, #8
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5], r11
    vst1.64 {d22}, [r6], r11
    pop {r5, r6}

    // dst[24-31]
    add sp, sp, #192
    vldmia sp, {q4-q7} //O[0]-O[3]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[0]-E[3]
    sub sp, sp, #448

    vsub.s32 q15, q8, q4       // DST[31]
    vsub.s32 q14, q9, q5       // DST[30]
    vsub.s32 q13, q10, q6       // DST[29]
    vsub.s32 q12, q11, q7       // DST[28]
    sub sp, sp, #64
    vpush {q12-q15}

    add sp, sp, #256
    vldmia sp, {q4-q7} //O[4]-O[7]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[4]-E[7]
    sub sp, sp, #384
    vsub.s32 q15, q8, q4       // DST[27]
    vsub.s32 q14, q9, q5       // DST[26]
    vsub.s32 q13, q10, q6       // DST[25]
    vsub.s32 q12, q11, q7       // DST[24]
    vpush {q12-q15}
    sub sp, sp, #64

    vpop {q8-q11}
    vpop {q4-q7}

    add sp, sp, #768
    vldmia sp, {q14, q15}
    sub sp, sp, #768


    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15
    vrshl.s32 q8, q8, q15
    vrshl.s32 q9, q9, q15
    vrshl.s32 q10, q10, q15
    vrshl.s32 q11, q11, q15

    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7
    vqmovn.s32 d16, q8
    vqmovn.s32 d18, q9
    vqmovn.s32 d20, q10
    vqmovn.s32 d22, q11

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28
    vmin.s16 d18, d18, d29
    vmax.s16 d18, d18, d28
    vmin.s16 d20, d20, d29
    vmax.s16 d20, d20, d28
    vmin.s16 d22, d22, d29
    vmax.s16 d22, d22, d28

    push {r5, r6}
    add r5, r2, #48
    add r6, r2, #56
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5], r11
    vst1.64 {d22}, [r6], r11
    pop {r5, r6}

//  dst[8-15]
    add sp, sp, #64
    vldmia sp, {q4-q7}  // O[8]-O[11]
    add sp, sp, #256
    vldmia sp, {q8-q11}  // E[8]-E[11]
    sub sp, sp, #320

    vadd.s32 q12, q8, q4       // DST[8]
    vadd.s32 q13, q9, q5       // DST[9]
    vadd.s32 q14, q10, q6       // DST[10]
    vadd.s32 q15, q11, q7       // DST[11]
    vpush {q12-q15}

    add sp, sp, #64
    vldmia sp, {q4-q7} //O[12]-O[15]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[12]-E[15]
    sub sp, sp, #320
    vadd.s32 q12, q8, q4       // DST[12]
    vadd.s32 q13, q9, q5       // DST[13]
    vadd.s32 q14, q10, q6       // DST[14]
    vadd.s32 q15, q11, q7       // DST[15]
    vpush {q12-q15}

    vpop {q8-q11}
    vpop {q4-q7}

    add sp, sp, #768
    vldmia sp, {q14, q15}
    sub sp, sp, #768


    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15
    vrshl.s32 q8, q8, q15
    vrshl.s32 q9, q9, q15
    vrshl.s32 q10, q10, q15
    vrshl.s32 q11, q11, q15

    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7
    vqmovn.s32 d16, q8
    vqmovn.s32 d18, q9
    vqmovn.s32 d20, q10
    vqmovn.s32 d22, q11

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28
    vmin.s16 d18, d18, d29
    vmax.s16 d18, d18, d28
    vmin.s16 d20, d20, d29
    vmax.s16 d20, d20, d28
    vmin.s16 d22, d22, d29
    vmax.s16 d22, d22, d28

    push {r5,r6}
    add r5, r2, #16
    add r6, r2, #24
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5], r11
    vst1.64 {d22}, [r6], r11
    pop {r5,r6}

// dst[16-23]
    add sp, sp, #64
    vldmia sp, {q4-q7} //O[8]-O[11]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[8]-E[11]
    sub sp, sp, #320

    vsub.s32 q15, q8, q4       // DST[23]
    vsub.s32 q14, q9, q5       // DST[22]
    vsub.s32 q13, q10, q6       // DST[21]
    vsub.s32 q12, q11, q7       // DST[20]
    sub sp, sp, #64
    vpush {q12-q15}

    add sp, sp, #128
    vldmia sp, {q4-q7} //O[12]-O[15]
    add sp, sp, #256
    vldmia sp, {q8-q11} //E[12]-E[15]
    sub sp, sp, #256
    vsub.s32 q15, q8, q4       // DST[19]
    vsub.s32 q14, q9, q5       // DST[18]
    vsub.s32 q13, q10, q6       // DST[17]
    vsub.s32 q12, q11, q7       // DST[16]
    vpush {q12-q15}
    sub sp, sp, #64

    vpop {q8-q11}
    vpop {q4-q7}

    add sp, sp, #768
    vldmia sp, {q14, q15}
    sub sp, sp, #768


    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15
    vrshl.s32 q8, q8, q15
    vrshl.s32 q9, q9, q15
    vrshl.s32 q10, q10, q15
    vrshl.s32 q11, q11, q15

    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7
    vqmovn.s32 d16, q8
    vqmovn.s32 d18, q9
    vqmovn.s32 d20, q10
    vqmovn.s32 d22, q11

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vtrn.s32 d16, d20
    vtrn.s32 d18, d22
    vtrn.s16 d16, d18
    vtrn.s16 d20, d22

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28
    vmin.s16 d18, d18, d29
    vmax.s16 d18, d18, d28
    vmin.s16 d20, d20, d29
    vmax.s16 d20, d20, d28
    vmin.s16 d22, d22, d29
    vmax.s16 d22, d22, d28

    push {r5 ,r6}
    add r5, r2, #32
    add r6, r2, #40
    vst1.64 {d8}, [r5], r11
    vst1.64 {d16}, [r6], r11
    vst1.64 {d10}, [r5], r11
    vst1.64 {d18}, [r6], r11
    vst1.64 {d12}, [r5], r11
    vst1.64 {d20}, [r6], r11
    vst1.64 {d14}, [r5]
    vst1.64 {d22}, [r6]
    pop {r5 ,r6}

    add r8, r8, #8
    add sp, sp, #768
    add r2, r2, #256
    cmp r8, r3
    blt dct2_h32_2nd_loopx

dct2_h32_end:
    add sp, #32
    vpop {q4-q7}
    pop {r4-r12, pc}


//**********************************************************
// calculate E[0-31] and O[0-31] for 4 lines resi
// input:
//   r0: src
//   r7: i_src*8
//   r8: i_src*4
//   r9: i_src*2
//   r1: i_src
//   q0-q5: dct2 coeffs
// output:
//   sp[0-512]: E[0]-E[31]
//   sp[512-896]: O[0]-O[23]
//   v0-v7: O[24]-O[31]
//**********************************************************
.macro dct2_h64_w4_calcu_E_O_arm64
    mov r10, r0
    vldmia sp, {q0-q3}
    vld1.64 d8, [r10], r7           // src[0]
    vld1.64 d9, [r10], r7           // src[8*i_src]
    vld1.64 d10, [r10], r7          // src[16*i_src]
    vld1.64 d11, [r10], r7          // src[24*i_src]

    vmull.s16 q6, d8, d3[3]        // src[0]*tm[0] == src[0]*tm[1]
    vmull.s16 q7, d10, d1[1]       // src[16*i_src]*tm[16*64]
    vmull.s16 q8, d10, d7[2]
    vadd.s32 q9, q6, q7          // EEEE[0]
    vadd.s32 q10, q6, q8         // EEEE[1]
    vsub.s32 q11, q6, q8         // EEEE[2]
    vsub.s32 q12, q6, q7         // EEEE[3]
    vpush {q9-q12}

    add sp, sp, #128
    vldmia sp, {q3}
    sub sp, sp, #128
    vmull.s16 q6, d9, d0[3]
    vmull.s16 q7, d9, d2[1]
    vmull.s16 q8, d9, d5[2]
    vmull.s16 q9, d9, d7[2]
    vmlal.s16 q6, d11, d2[1]       // EEEO[0]
    vmlsl.s16 q7, d11, d7[2]       // EEEO[1]
    vmlsl.s16 q8, d11, d0[3]       // EEEO[2]
    vmlsl.s16 q9, d11, d5[2]       // EEEO[3]

    vpop {q10-q13}
    vadd.s32 q14, q10, q6        // EEE[0]
    vadd.s32 q15, q11, q7        // EEE[1]
    vpush {q14-q15}
    vadd.s32 q14, q12, q8        // EEE[2]
    vadd.s32 q15, q13, q9        // EEE[3]
    vpush {q14-q15}
    vsub.s32 q14, q13, q9        // EEE[4]
    vsub.s32 q15, q12, q8        // EEE[5]
    vpush {q14-q15}
    vsub.s32 q14, q11, q7        // EEE[6]
    vsub.s32 q15, q10, q6        // EEE[7]
    vpush {q14-q15}

    //EEO
    add r10, r0, r8
    vld1.64 d8, [r10], r7         // [4*i_src]
    vld1.64 d9, [r10], r7         // [12*i_src]
    vld1.64 d10, [r10], r7         // [20*i_src]
    vld1.64 d11, [r10], r7         // [28*i_src]

    vmull.s16 q8, d8, d0[2]
    vmlal.s16 q8, d9, d1[0]
    vmlal.s16 q8, d10, d1[3]
    vmlal.s16 q8, d11, d3[0]        //EEO[0]

    vmull.s16 q9, d8, d1[0]
    vmlal.s16 q9, d9, d4[2]
    add sp, sp, #208
    vldmia sp, {q3}
    vmlal.s16 q9, d10, d6[3]
    sub sp, sp, #32
    vldmia sp, {q3}
    vmlsl.s16 q9, d11, d6[2]        //EEO[1]
    sub sp, sp, #176

    vmull.s16 q10, d8, d1[3]
    add sp, sp, #208
    vldmia sp, {q3}
    vmlal.s16 q10, d9, d6[3]
    vmlsl.s16 q10, d10, d3[0]
    vmlsl.s16 q10, d11, d1[0]       //EEO[2]

    vmull.s16 q11, d8, d3[0]
    sub sp, sp, #32
    vldmia sp, {q3}
    vmlsl.s16 q11, d9, d6[2]
    vmlsl.s16 q11, d10, d1[0]
    add sp, sp, #32
    vldmia sp, {q3}
    vmlal.s16 q11, d11, d6[3]       //EEO[3]

    vmull.s16 q12, d8, d4[2]
    vmlsl.s16 q12, d9, d1[3]
    sub sp, sp, #16
    vldmia sp, {q3}
    vmlsl.s16 q12, d10, d6[2]
    vmlal.s16 q12, d11, d0[2]      //EEO[4]

    sub sp, sp, #16
    vldmia sp, {q3}
    vmull.s16 q13, d8, d6[2]
    vmlsl.s16 q13, d9, d0[2]
    vmlal.s16 q13, d10, d4[2]
    add sp, sp, #16
    vldmia sp, {q3}
    vmlal.s16 q13, d11, d6[2]      //EEO[5]

    vmull.s16 q14, d8, d6[2]
    vmlsl.s16 q14, d9, d3[0]
    vmlal.s16 q14, d10, d0[2]
    vmlsl.s16 q14, d11, d1[3]      //EEO[6]

    sub sp, sp, #32
    vldmia sp, {q0-q3}
    vmull.s16 q15, d8, d6[3]
    vmlsl.s16 q15, d9, d4[2]
    vmlal.s16 q15, d10, d2[2]
    vmlsl.s16 q15, d11, d0[2]      //EEO[7]
    sub sp, sp, #160

    //EE
    add sp, sp, #96
    vldmia sp, {q4, q5}
    sub sp, sp, #32
    vldmia sp, {q6, q7}
    vadd.s32 q0, q8, q4
    vadd.s32 q1, q9, q5
    vadd.s32 q2, q10, q6
    vadd.s32 q3, q11, q7
    sub sp, sp, #64
    vpush {q0-q3}      // EE[0-3]
    add sp, sp, #96
    vldmia sp, {q4, q5}
    sub sp, sp, #32
    vldmia sp, {q6, q7}
    vadd.s32 q0, q12, q4
    vadd.s32 q1, q13, q5
    vadd.s32 q2, q14, q6
    vadd.s32 q3, q15, q7
    sub sp, sp, #64
    vpush {q0-q3}      // EE[5-8]


    add sp, sp, #128
    vldmia sp, {q6, q7}
    add sp, sp, #32
    vldmia sp, {q4, q5}
    sub sp, sp, #160
    vsub.s32 q0, q7, q15
    vsub.s32 q1, q6, q14
    vsub.s32 q2, q5, q13
    vsub.s32 q3, q4, q12
    vpush {q0-q3}      // EE[8-11]
    add sp, sp, #256
    vldmia sp, {q6, q7}
    add sp, sp, #32
    vldmia sp, {q4, q5}
    sub sp, sp, #288
    vsub.s32 q0, q7, q11
    vsub.s32 q1, q6, q10
    vsub.s32 q2, q5, q9
    vsub.s32 q3, q4, q8
    vpush {q0-q3}      // EE[12-15]

    //EO
    push {r5-r10}
    mov r5, #23
    mov r6, #19
    mov r7, #15
    mov r8, #11
    mov r9, #7
    mov r10, #2
    vmov.s16 d6[0], r5  //v13-0
    vmov.s16 d6[1], r6  //v13-4
    vmov.s16 d6[2], r7  //v14-0
    vmov.s16 d6[3], r8  //v14-4
    vmov.s16 d7[0], r9  //v15-0
    vmov.s16 d7[1], r10 //v15-5
    pop {r5-r10}

    add r10, r0, r9
    vld1.64 d8, [r10], r8        // [2*i_src]
    vld1.64 d9, [r10], r8        // [6*i_src]
    vld1.64 d10, [r10], r8        // [10*i_src]
    vld1.64 d11, [r10], r8        // [14*i_src]
    vld1.64 d12, [r10], r8        // [18*i_src]
    vld1.64 d13, [r10], r8        // [22*i_src]
    vld1.64 d14, [r10], r8        // [26*i_src]
    vld1.64 d15, [r10], r8        // [30*i_src]

    add sp, sp, #384
    vldmia sp, {q0-q2}
    sub sp, sp, #384
    vmull.s16 q8, d8, d0[2]
    vmlal.s16 q8, d9, d0[2]
    vmlal.s16 q8, d10, d0[3]
    vmlal.s16 q8, d11, d1[0]
    vmlal.s16 q8, d12, d1[2]
    vmlal.s16 q8, d13, d2[0]
    vmlal.s16 q8, d14, d2[3]
    vmlal.s16 q8, d15, d3[1]        //EO[0]

    vmull.s16 q9, d8, d0[2]
    vmlal.s16 q9, d9, d1[2]
    vmlal.s16 q9, d10, d3[1]
    vmlal.s16 q9, d11, d6[0]
    vmlal.s16 q9, d12, d6[3]
    vmlsl.s16 q9, d13, d7[1]
    vmlsl.s16 q9, d14, d6[2]
    vmlsl.s16 q9, d15, d5[0]        //EO[1]

    vmull.s16 q10, d8, d0[3]
    vmlal.s16 q10, d9, d3[1]
    vmlal.s16 q10, d10, d6[2]
    vmlsl.s16 q10, d11, d7[0]
    vmlsl.s16 q10, d12, d5[0]
    vmlsl.s16 q10, d13, d1[2]
    vmlsl.s16 q10, d14, d0[2]
    vmlsl.s16 q10, d15, d2[0]        //EO[2]

    vmull.s16 q11, d8, d1[0]
    vmlal.s16 q11, d9, d6[0]
    vmlsl.s16 q11, d10, d7[0]
    vmlsl.s16 q11, d11, d3[1]
    vmlsl.s16 q11, d12, d0[2]
    vmlsl.s16 q11, d13, d2[3]
    vmlsl.s16 q11, d14, d6[3]
    vmlal.s16 q11, d15, d6[1]        //EO[3]

    vmull.s16 q12, d8, d1[2]
    vmlal.s16 q12, d9, d6[3]
    vmlsl.s16 q12, d10, d5[0]
    vmlsl.s16 q12, d11, d0[2]
    vmlsl.s16 q12, d12, d4[1]
    vmlal.s16 q12, d13, d7[0]
    vmlal.s16 q12, d14, d2[0]
    vmlal.s16 q12, d15, d1[0]        //EO[4]

    vmull.s16 q13, d8, d2[0]
    vmlsl.s16 q13, d9, d7[1]
    vmlsl.s16 q13, d10, d1[2]
    vmlsl.s16 q13, d11, d2[3]
    vmlal.s16 q13, d12, d7[0]
    vmlal.s16 q13, d13, d1[0]
    vmlal.s16 q13, d14, d3[1]
    vmlsl.s16 q13, d15, d6[3]        //EO[5]

    vmull.s16 q14, d8, d2[3]
    vmlsl.s16 q14, d9, d6[2]
    vmlsl.s16 q14, d10, d0[2]
    vmlsl.s16 q14, d11, d6[3]
    vmlal.s16 q14, d12, d2[0]
    vmlal.s16 q14, d13, d3[1]
    vmlsl.s16 q14, d14, d6[1]
    vmlsl.s16 q14, d15, d0[2]        //EO[6]

    vmull.s16 q15, d8, d3[1]
    vmlsl.s16 q15, d9, d5[0]
    vmlsl.s16 q15, d10, d2[0]
    vmlal.s16 q15, d11, d6[1]
    vmlal.s16 q15, d12, d1[0]
    vmlsl.s16 q15, d13, d6[3]
    vmlsl.s16 q15, d14, d0[2]
    vmlal.s16 q15, d15, d7[1]        //EO[7]
    vpush {q8-q15}

    vmull.s16 q8, d8, d4[1]
    vmlsl.s16 q8, d9, d2[3]
    vmlsl.s16 q8, d10, d6[0]
    vmlal.s16 q8, d11, d1[2]
    vmlal.s16 q8, d12, d6[2]
    vmlsl.s16 q8, d13, d0[3]
    vmlsl.s16 q8, d14, d7[0]
    vmlal.s16 q8, d15, d0[2]        //EO[8]

    vmull.s16 q9, d8, d5[0]
    vmlsl.s16 q9, d9, d1[0]
    vmlsl.s16 q9, d10, d7[1]
    vmlal.s16 q9, d11, d0[3]
    vmlsl.s16 q9, d12, d6[0]
    vmlsl.s16 q9, d13, d4[1]
    vmlal.s16 q9, d14, d1[2]
    vmlal.s16 q9, d15, d7[0]        //EO[9]

    vmull.s16 q10, d8, d6[0]
    vmlsl.s16 q10, d9, d0[2]
    vmlal.s16 q10, d10, d6[1]
    vmlal.s16 q10, d11, d5[0]
    vmlsl.s16 q10, d12, d0[2]
    vmlal.s16 q10, d13, d6[2]
    vmlal.s16 q10, d14, d4[1]
    vmlsl.s16 q10, d15, d0[3]        //EO[10]

    vmull.s16 q11, d8, d6[1]
    vmlsl.s16 q11, d9, d0[3]
    vmlal.s16 q11, d10, d2[3]
    vmlsl.s16 q11, d11, d7[1]
    vmlsl.s16 q11, d12, d3[1]
    vmlal.s16 q11, d13, d0[2]
    vmlsl.s16 q11, d14, d6[0]
    vmlsl.s16 q11, d15, d6[2]        //EO[11]

    vmull.s16 q12, d8, d6[2]
    vmlsl.s16 q12, d9, d2[0]
    vmlal.s16 q12, d10, d0[2]
    vmlsl.s16 q12, d11, d4[1]
    vmlal.s16 q12, d12, d7[1]
    vmlal.s16 q12, d13, d5[0]
    vmlsl.s16 q12, d14, d0[3]
    vmlal.s16 q12, d15, d1[2]        //EO[12]

    vmull.s16 q13, d8, d6[3]
    vmlsl.s16 q13, d9, d4[1]
    vmlal.s16 q13, d10, d1[0]
    vmlsl.s16 q13, d11, d0[2]
    vmlal.s16 q13, d12, d2[3]
    vmlsl.s16 q13, d13, d6[1]
    vmlsl.s16 q13, d14, d7[1]
    vmlal.s16 q13, d15, d6[0]        //EO[13]

    vmull.s16 q14, d8, d7[0]
    vmlsl.s16 q14, d9, d6[1]
    vmlal.s16 q14, d10, d4[1]
    vmlsl.s16 q14, d11, d2[0]
    vmlal.s16 q14, d12, d0[3]
    vmlsl.s16 q14, d13, d0[2]
    vmlal.s16 q14, d14, d1[0]
    vmlsl.s16 q14, d15, d2[3]        //EO[14]

    vmull.s16 q15, d8, d7[1]
    vmlsl.s16 q15, d9, d7[0]
    vmlal.s16 q15, d10, d6[3]
    vmlsl.s16 q15, d11, d6[2]
    vmlal.s16 q15, d12, d6[1]
    vmlsl.s16 q15, d13, d6[0]
    vmlal.s16 q15, d14, d5[0]
    vmlsl.s16 q15, d15, d4[1]        //EO[15]
    vpush {q8-q15}

    //load EE[8-11]
    add sp, sp, #320
    vldmia sp, {q4-q7}
    sub sp, sp, #640
    vadd.s32 q0, q4, q8     //E[8]
    vadd.s32 q1, q5, q9     //E[9]
    vadd.s32 q2, q6, q10     //E[10]
    vadd.s32 q3, q7, q11     //E[11]
    vpush {q0-q3}

    vsub.s32 q3, q4, q8     //E[23]
    vsub.s32 q2, q5, q9     //E[22]
    vsub.s32 q1, q6, q10     //E[21]
    vsub.s32 q0, q7, q11     //E[20]
    add sp, sp, #256
    vpush {q0-q3}

    //load EE[12-15]
    add sp, sp, #448
    vldmia sp, {q4-q7}
    vadd.s32 q0, q4, q12       // E[12]
    vadd.s32 q1, q5, q13       // E[13]
    vadd.s32 q2, q6, q14       // E[14]
    vadd.s32 q3, q7, q15       // E[15]
    sub sp, sp, #512
    vpush {q0-q3}

    vsub.s32 q3, q4, q12     //E[19]
    vsub.s32 q2, q5, q13     //E[18]
    vsub.s32 q1, q6, q14     //E[17]
    vsub.s32 q0, q7, q15     //E[16]
    add sp, sp, #128
    vpush {q0-q3}

    //load EE[0-3]
    add sp, sp, #704
    vldmia sp, {q4-q7}
    //load EO[0-7]
    sub sp, sp, #320
    vldmia sp, {q8-q15}
    vadd.s32 q0, q4, q8     //E[0]
    vadd.s32 q1, q5, q9     //E[1]
    vadd.s32 q2, q6, q10     //E[2]
    vadd.s32 q3, q7, q11     //E[3]
    sub sp, sp, #576
    vpush {q0-q3}

    vsub.s32 q3, q4, q8     //E[31]
    vsub.s32 q2, q5, q9     //E[30]
    vsub.s32 q1, q6, q10     //E[29]
    vsub.s32 q0, q7, q11     //E[28]
    add sp, sp, #512
    vpush {q0-q3}

    //load EE[4-7]
    add sp, sp, #448
    vldmia sp, {q4-q7}
    vadd.s32 q0, q4, q12     //E[4]
    vadd.s32 q1, q5, q13     //E[5]
    vadd.s32 q2, q6, q14     //E[6]
    vadd.s32 q3, q7, q15     //E[7]
    sub sp, sp, #768
    vpush {q0-q3}

    vsub.s32 q3, q4, q12     //E[27]
    vsub.s32 q2, q5, q13     //E[26]
    vsub.s32 q1, q6, q14     //E[25]
    vsub.s32 q0, q7, q15     //E[24]
    add sp, sp, #384
    vpush {q0-q3}
    sub sp, sp, #384    //栈顶

    // calculate O[0-31]
    add r10, r0, r1                // src + i_src
    vld1.64 d8, [r10], r9        //src[ 1*line ]
    vld1.64 d9, [r10], r9        //src[ 3*line ]
    vld1.64 d10, [r10], r9        //src[ 5*line ]
    vld1.64 d11, [r10], r9        //src[ 7*line ]
    vld1.64 d12, [r10], r9        //src[ 9*line ]
    vld1.64 d13, [r10], r9        //src[ 11*line ]
    vld1.64 d14, [r10], r9        //src[ 13*line ]
    vld1.64 d15, [r10], r9        //src[ 15*line ]
    vld1.64 d16, [r10], r9        //src[ 17*line ]
    vld1.64 d17, [r10], r9        //src[ 19*line ]
    vld1.64 d18, [r10], r9        //src[ 21*line ]
    vld1.64 d19, [r10], r9        //src[ 23*line ]
    vld1.64 d20, [r10], r9        //src[ 25*line ]
    vld1.64 d21, [r10], r9        //src[ 27*line ]
    vld1.64 d22, [r10], r9        //src[ 29*line ]
    vld1.64 d23, [r10], r9        //src[ 31*line ]

    add sp, sp, #1152
    vldmia sp, {q0-q2}
    sub sp, sp, #1152

    push {r5-r8}
    mov r5, #6
    mov r6, #3
    mov r7, #1
    vmov.s16 d4[2], r5
    vmov.s16 d5[0], r6
    vmov.s16 d5[2], r7
    mov r5, #22
    mov r6, #20
    mov r7, #18
    mov r8, #16
    vmov.s16 d6[0], r5
    vmov.s16 d6[1], r6
    vmov.s16 d6[2], r7
    vmov.s16 d6[3], r8
    mov r5, #14
    mov r6, #12
    mov r7, #10
    mov r8, #8
    vmov.s16 d7[0], r5
    vmov.s16 d7[1], r6
    vmov.s16 d7[2], r7
    vmov.s16 d7[3], r8
    pop {r5-r8}

    vmull.s16 q12, d8, d0[2]
    vmlal.s16 q12, d9, d0[2]
    vmlal.s16 q12, d10, d0[2]
    vmlal.s16 q12, d11, d0[2]
    vmlal.s16 q12, d12, d0[3]
    vmlal.s16 q12, d13, d0[3]
    vmlal.s16 q12, d14, d1[0]
    vmlal.s16 q12, d15, d1[1]
    vmlal.s16 q12, d16, d1[2]
    vmlal.s16 q12, d17, d1[3]
    vmlal.s16 q12, d18, d2[0]
    vmlal.s16 q12, d19, d2[1]
    vmlal.s16 q12, d20, d2[2]
    vmlal.s16 q12, d21, d2[3]
    vmlal.s16 q12, d22, d3[1]
    vmlal.s16 q12, d23, d3[2]   //O[0]

    vmull.s16 q13, d8, d0[2]
    vmlal.s16 q13, d9, d0[3]
    vmlal.s16 q13, d10, d1[1]
    vmlal.s16 q13, d11, d2[0]
    vmlal.s16 q13, d12, d2[3]
    vmlal.s16 q13, d13, d4[0]
    vmlal.s16 q13, d14, d5[1]
    vmlal.s16 q13, d15, d6[1]
    vmlal.s16 q13, d16, d7[0]
    vmlal.s16 q13, d17, d7[3]
    vmlal.s16 q13, d18, d5[2]
    vmlsl.s16 q13, d19, d4[2]
    vmlsl.s16 q13, d20, d7[1]
    vmlsl.s16 q13, d21, d6[2]
    vmlsl.s16 q13, d22, d5[3]
    vmlsl.s16 q13, d23, d4[1]   //O[1]

    vmull.s16 q14, d8, d0[2]
    vmlal.s16 q14, d9, d1[1]
    vmlal.s16 q14, d10, d2[2]
    vmlal.s16 q14, d11, d4[1]
    vmlal.s16 q14, d12, d6[1]
    vmlal.s16 q14, d13, d7[2]
    vmlsl.s16 q14, d14, d5[2]
    vmlsl.s16 q14, d15, d7[1]
    vmlsl.s16 q14, d16, d6[0]
    vmlsl.s16 q14, d17, d4[0]
    vmlsl.s16 q14, d18, d2[1]
    vmlsl.s16 q14, d19, d1[0]
    vmlsl.s16 q14, d20, d0[2]
    vmlsl.s16 q14, d21, d0[2]
    vmlsl.s16 q14, d22, d1[2]
    vmlsl.s16 q14, d23, d2[3]   //O[2]

    vmull.s16 q15, d8, d0[2]
    vmlal.s16 q15, d9, d2[0]
    vmlal.s16 q15, d10, d4[1]
    vmlal.s16 q15, d11, d6[3]
    vmlal.s16 q15, d12, d5[2]
    vmlsl.s16 q15, d13, d7[0]
    vmlsl.s16 q15, d14, d4[3]
    vmlsl.s16 q15, d15, d2[1]
    vmlsl.s16 q15, d16, d0[3]
    vmlsl.s16 q15, d17, d0[2]
    vmlsl.s16 q15, d18, d1[3]
    vmlsl.s16 q15, d19, d4[0]
    vmlsl.s16 q15, d20, d6[2]
    vmlsl.s16 q15, d21, d5[0]
    vmlal.s16 q15, d22, d7[1]
    vmlal.s16 q15, d23, d5[1]   //O[3]
    vpush {q12-q15}

    vmull.s16 q12, d8, d0[3]
    vmlal.s16 q12, d9, d2[3]
    vmlal.s16 q12, d10, d6[1]
    vmlal.s16 q12, d11, d5[2]
    vmlsl.s16 q12, d12, d6[2]
    vmlsl.s16 q12, d13, d3[1]
    vmlsl.s16 q12, d14, d0[3]
    vmlsl.s16 q12, d15, d0[2]
    vmlsl.s16 q12, d16, d2[2]
    vmlsl.s16 q12, d17, d6[0]
    vmlsl.s16 q12, d18, d5[0]
    vmlal.s16 q12, d19, d6[3]
    vmlal.s16 q12, d20, d3[2]
    vmlal.s16 q12, d21, d1[0]
    vmlal.s16 q12, d22, d0[2]
    vmlal.s16 q12, d23, d2[1]   //O[4]

    vmull.s16 q13, d8, d0[3]
    vmlal.s16 q13, d9, d4[0]
    vmlal.s16 q13, d10, d7[2]
    vmlsl.s16 q13, d11, d7[0]
    vmlsl.s16 q13, d12, d3[1]
    vmlsl.s16 q13, d13, d0[2]
    vmlsl.s16 q13, d14, d1[1]
    vmlsl.s16 q13, d15, d4[3]
    vmlsl.s16 q13, d16, d4[2]
    vmlal.s16 q13, d17, d6[2]
    vmlal.s16 q13, d18, d2[2]
    vmlal.s16 q13, d19, d0[2]
    vmlal.s16 q13, d20, d1[3]
    vmlal.s16 q13, d21, d5[3]
    vmlal.s16 q13, d22, d5[2]
    vmlsl.s16 q13, d23, d6[0]   //O[5]

    vmull.s16 q14, d8, d1[0]
    vmlal.s16 q14, d9, d5[1]
    vmlsl.s16 q14, d10, d5[2]
    vmlsl.s16 q14, d11, d4[3]
    vmlsl.s16 q14, d12, d0[3]
    vmlsl.s16 q14, d13, d1[1]
    vmlsl.s16 q14, d14, d5[3]
    vmlal.s16 q14, d15, d5[0]
    vmlal.s16 q14, d16, d4[1]
    vmlal.s16 q14, d17, d0[3]
    vmlal.s16 q14, d18, d1[2]
    vmlal.s16 q14, d19, d6[0]
    vmlsl.s16 q14, d20, d4[2]
    vmlsl.s16 q14, d21, d4[0]
    vmlsl.s16 q14, d22, d0[2]
    vmlsl.s16 q14, d23, d1[3]   //O[6]

    vmull.s16 q15, d8, d1[1]
    vmlal.s16 q15, d9, d6[1]
    vmlsl.s16 q15, d10, d7[1]
    vmlsl.s16 q15, d11, d2[1]
    vmlsl.s16 q15, d12, d0[2]
    vmlsl.s16 q15, d13, d4[3]
    vmlal.s16 q15, d14, d5[0]
    vmlal.s16 q15, d15, d3[2]
    vmlal.s16 q15, d16, d0[2]
    vmlal.s16 q15, d17, d3[1]
    vmlal.s16 q15, d18, d4[2]
    vmlsl.s16 q15, d19, d5[1]
    vmlsl.s16 q15, d20, d0[3]
    vmlsl.s16 q15, d21, d2[0]
    vmlsl.s16 q15, d22, d7[0]
    vmlal.s16 q15, d23, d6[2]   //O[7]
    vpush {q12-q15}

    vmull.s16 q12, d8, d1[2]
    vmlal.s16 q12, d9, d7[0]
    vmlsl.s16 q12, d10, d6[0]
    vmlsl.s16 q12, d11, d0[3]
    vmlsl.s16 q12, d12, d2[2]
    vmlsl.s16 q12, d13, d4[2]
    vmlal.s16 q12, d14, d4[1]
    vmlal.s16 q12, d15, d0[2]
    vmlal.s16 q12, d16, d4[0]
    vmlsl.s16 q12, d17, d5[0]
    vmlsl.s16 q12, d18, d2[3]
    vmlsl.s16 q12, d19, d0[2]
    vmlsl.s16 q12, d20, d5[3]
    vmlal.s16 q12, d21, d7[1]
    vmlal.s16 q12, d22, d1[3]
    vmlal.s16 q12, d23, d1[1]   //O[8]

    vmull.s16 q13, d8, d1[3]
    vmlal.s16 q13, d9, d7[3]
    vmlsl.s16 q13, d10, d4[0]
    vmlsl.s16 q13, d11, d0[2]
    vmlsl.s16 q13, d12, d6[0]
    vmlal.s16 q13, d13, d6[2]
    vmlal.s16 q13, d14, d0[3]
    vmlal.s16 q13, d15, d3[1]
    vmlsl.s16 q13, d16, d5[0]
    vmlsl.s16 q13, d17, d2[1]
    vmlsl.s16 q13, d18, d1[1]
    vmlsl.s16 q13, d19, d7[1]
    vmlal.s16 q13, d20, d4[3]
    vmlal.s16 q13, d21, d0[2]
    vmlal.s16 q13, d22, d5[1]
    vmlsl.s16 q13, d23, d7[0]   //O[9]

    vmull.s16 q14, d8, d2[0]
    vmlal.s16 q14, d9, d5[2]
    vmlsl.s16 q14, d10, d2[1]
    vmlsl.s16 q14, d11, d1[3]
    vmlsl.s16 q14, d12, d5[0]
    vmlal.s16 q14, d13, d2[2]
    vmlal.s16 q14, d14, d1[2]
    vmlal.s16 q14, d15, d4[2]
    vmlsl.s16 q14, d16, d2[3]
    vmlsl.s16 q14, d17, d1[1]
    vmlsl.s16 q14, d18, d7[3]
    vmlal.s16 q14, d19, d3[1]
    vmlal.s16 q14, d20, d1[0]
    vmlal.s16 q14, d21, d7[2]
    vmlsl.s16 q14, d22, d3[2]
    vmlsl.s16 q14, d23, d0[3]   //O[10]

    vmull.s16 q15, d8, d2[1]
    vmlsl.s16 q15, d9, d4[2]
    vmlsl.s16 q15, d10, d1[0]
    vmlsl.s16 q15, d11, d4[0]
    vmlal.s16 q15, d12, d6[3]
    vmlal.s16 q15, d13, d0[2]
    vmlal.s16 q15, d14, d6[0]
    vmlsl.s16 q15, d15, d5[1]
    vmlsl.s16 q15, d16, d0[2]
    vmlsl.s16 q15, d17, d7[1]
    vmlal.s16 q15, d18, d3[1]
    vmlal.s16 q15, d19, d1[2]
    vmlal.s16 q15, d20, d5[2]
    vmlsl.s16 q15, d21, d1[3]
    vmlsl.s16 q15, d22, d2[3]
    vmlal.s16 q15, d23, d7[2]   //O[11]
    vpush {q12-q15}

    vmull.s16 q12, d8, d2[2]
    vmlsl.s16 q12, d9, d7[1]
    vmlsl.s16 q12, d10, d0[2]
    vmlsl.s16 q12, d11, d6[2]
    vmlal.s16 q12, d12, d3[2]
    vmlal.s16 q12, d13, d1[3]
    vmlsl.s16 q12, d14, d4[2]
    vmlsl.s16 q12, d15, d0[3]
    vmlsl.s16 q12, d16, d5[3]
    vmlal.s16 q12, d17, d4[3]
    vmlal.s16 q12, d18, d1[0]
    vmlal.s16 q12, d19, d5[2]
    vmlsl.s16 q12, d20, d1[1]
    vmlsl.s16 q12, d21, d4[1]
    vmlal.s16 q12, d22, d6[0]
    vmlal.s16 q12, d23, d0[2]   //O[12]

    vmull.s16 q13, d8, d2[3]
    vmlsl.s16 q13, d9, d6[2]
    vmlsl.s16 q13, d10, d0[2]
    vmlsl.s16 q13, d11, d5[0]
    vmlal.s16 q13, d12, d1[0]
    vmlal.s16 q13, d13, d5[3]
    vmlsl.s16 q13, d14, d4[0]
    vmlsl.s16 q13, d15, d2[0]
    vmlal.s16 q13, d16, d7[1]
    vmlal.s16 q13, d17, d0[2]
    vmlal.s16 q13, d18, d7[2]
    vmlsl.s16 q13, d19, d1[3]
    vmlsl.s16 q13, d20, d4[1]
    vmlal.s16 q13, d21, d5[1]
    vmlal.s16 q13, d22, d1[1]
    vmlsl.s16 q13, d23, d4[2]   //O[13]

    vmull.s16 q14, d8, d3[1]
    vmlsl.s16 q14, d9, d5[3]
    vmlsl.s16 q14, d10, d1[2]
    vmlal.s16 q14, d11, d7[1]
    vmlal.s16 q14, d12, d0[2]
    vmlal.s16 q14, d13, d5[2]
    vmlsl.s16 q14, d14, d0[2]
    vmlsl.s16 q14, d15, d7[0]
    vmlal.s16 q14, d16, d1[3]
    vmlal.s16 q14, d17, d5[1]
    vmlsl.s16 q14, d18, d3[2]
    vmlsl.s16 q14, d19, d2[3]
    vmlal.s16 q14, d20, d6[0]
    vmlal.s16 q14, d21, d1[1]
    vmlsl.s16 q14, d22, d7[2]
    vmlsl.s16 q14, d23, d0[2]   //O[14]

    vmull.s16 q15, d8, d3[2]
    vmlsl.s16 q15, d9, d4[1]
    vmlsl.s16 q15, d10, d2[3]
    vmlal.s16 q15, d11, d5[1]
    vmlal.s16 q15, d12, d2[1]
    vmlsl.s16 q15, d13, d6[0]
    vmlsl.s16 q15, d14, d1[3]
    vmlal.s16 q15, d15, d6[2]
    vmlal.s16 q15, d16, d1[1]
    vmlsl.s16 q15, d17, d7[0]
    vmlsl.s16 q15, d18, d0[3]
    vmlal.s16 q15, d19, d7[2]
    vmlal.s16 q15, d20, d0[2]
    vmlsl.s16 q15, d21, d4[2]
    vmlsl.s16 q15, d22, d0[2]
    vmlal.s16 q15, d23, d5[2]   //O[15]
    vpush {q12-q15}

    vmull.s16 q12, d8, d4[0]
    vmlsl.s16 q12, d9, d3[1]
    vmlsl.s16 q12, d10, d4[3]
    vmlal.s16 q12, d11, d2[2]
    vmlal.s16 q12, d12, d5[3]
    vmlsl.s16 q12, d13, d2[0]
    vmlsl.s16 q12, d14, d6[1]
    vmlal.s16 q12, d15, d1[2]
    vmlal.s16 q12, d16, d6[3]
    vmlsl.s16 q12, d17, d1[0]
    vmlsl.s16 q12, d18, d7[1]
    vmlal.s16 q12, d19, d0[3]
    vmlal.s16 q12, d20, d7[3]
    vmlsl.s16 q12, d21, d0[2]
    vmlsl.s16 q12, d22, d5[0]
    vmlal.s16 q12, d23, d0[2]   //O[16]

    vmull.s16 q13, d8, d4[1]
    vmlsl.s16 q13, d9, d2[1]
    vmlsl.s16 q13, d10, d6[2]
    vmlal.s16 q13, d11, d0[3]
    vmlal.s16 q13, d12, d4[2]
    vmlsl.s16 q13, d13, d0[2]
    vmlal.s16 q13, d14, d7[3]
    vmlal.s16 q13, d15, d1[0]
    vmlsl.s16 q13, d16, d6[1]
    vmlsl.s16 q13, d17, d2[2]
    vmlal.s16 q13, d18, d4[0]
    vmlal.s16 q13, d19, d4[3]
    vmlsl.s16 q13, d20, d2[0]
    vmlsl.s16 q13, d21, d6[3]
    vmlal.s16 q13, d22, d0[3]
    vmlal.s16 q13, d23, d5[0]   //O[17]

    vmull.s16 q14, d8, d4[3]
    vmlsl.s16 q14, d9, d1[2]
    vmlsl.s16 q14, d10, d7[3]
    vmlal.s16 q14, d11, d0[2]
    vmlsl.s16 q14, d12, d7[0]
    vmlsl.s16 q14, d13, d2[1]
    vmlal.s16 q14, d14, d3[2]
    vmlal.s16 q14, d15, d6[0]
    vmlsl.s16 q14, d16, d0[3]
    vmlsl.s16 q14, d17, d5[2]
    vmlal.s16 q14, d18, d0[3]
    vmlsl.s16 q14, d19, d6[1]
    vmlsl.s16 q14, d20, d3[1]
    vmlal.s16 q14, d21, d2[2]
    vmlal.s16 q14, d22, d6[3]
    vmlsl.s16 q14, d23, d0[2]   //O[18]

    vmull.s16 q15, d8, d5[1]
    vmlsl.s16 q15, d9, d0[3]
    vmlal.s16 q15, d10, d5[0]
    vmlal.s16 q15, d11, d1[2]
    vmlsl.s16 q15, d12, d4[0]
    vmlsl.s16 q15, d13, d6[1]
    vmlal.s16 q15, d14, d0[2]
    vmlsl.s16 q15, d15, d7[2]
    vmlsl.s16 q15, d16, d2[1]
    vmlal.s16 q15, d17, d2[3]
    vmlal.s16 q15, d18, d7[0]
    vmlsl.s16 q15, d19, d0[2]
    vmlal.s16 q15, d20, d6[3]
    vmlal.s16 q15, d21, d3[1]
    vmlsl.s16 q15, d22, d2[0]
    vmlsl.s16 q15, d23, d7[3]   //O[19]
    vpush {q12-q15}

    vmull.s16 q12, d8, d5[3]
    vmlsl.s16 q12, d9, d0[2]
    vmlal.s16 q12, d10, d7[0]
    vmlal.s16 q12, d11, d3[2]
    vmlsl.s16 q12, d12, d1[1]
    vmlal.s16 q12, d13, d5[0]
    vmlal.s16 q12, d14, d2[0]
    vmlsl.s16 q12, d15, d2[2]
    vmlsl.s16 q12, d16, d7[3]
    vmlal.s16 q12, d17, d0[3]
    vmlsl.s16 q12, d18, d4[1]
    vmlsl.s16 q12, d19, d6[2]
    vmlal.s16 q12, d20, d0[2]
    vmlsl.s16 q12, d21, d6[1]
    vmlsl.s16 q12, d22, d4[3]
    vmlal.s16 q12, d23, d0[3]   //O[20]

    vmull.s16 q13, d8, d6[0]
    vmlsl.s16 q13, d9, d0[2]
    vmlal.s16 q13, d10, d5[3]
    vmlal.s16 q13, d11, d6[1]
    vmlsl.s16 q13, d12, d0[2]
    vmlal.s16 q13, d13, d5[1]
    vmlal.s16 q13, d14, d6[2]
    vmlsl.s16 q13, d15, d0[2]
    vmlal.s16 q13, d16, d4[3]
    vmlal.s16 q13, d17, d6[3]
    vmlsl.s16 q13, d18, d0[2]
    vmlal.s16 q13, d19, d4[1]
    vmlal.s16 q13, d20, d7[0]
    vmlsl.s16 q13, d21, d0[3]
    vmlal.s16 q13, d22, d4[0]
    vmlal.s16 q13, d23, d7[1]   //O[21]

    vmull.s16 q14, d8, d6[1]
    vmlsl.s16 q14, d9, d0[2]
    vmlal.s16 q14, d10, d3[2]
    vmlal.s16 q14, d11, d4[2]
    vmlsl.s16 q14, d12, d2[0]
    vmlal.s16 q14, d13, d1[2]
    vmlsl.s16 q14, d14, d7[2]
    vmlsl.s16 q14, d15, d4[1]
    vmlal.s16 q14, d16, d0[2]
    vmlsl.s16 q14, d17, d5[3]
    vmlsl.s16 q14, d18, d6[3]
    vmlal.s16 q14, d19, d0[3]
    vmlsl.s16 q14, d20, d2[3]
    vmlsl.s16 q14, d21, d5[2]
    vmlal.s16 q14, d22, d2[2]
    vmlsl.s16 q14, d23, d1[0]   //O[22]

    vmull.s16 q15, d8, d6[2]
    vmlsl.s16 q15, d9, d1[0]
    vmlal.s16 q15, d10, d2[0]
    vmlsl.s16 q15, d11, d7[2]
    vmlsl.s16 q15, d12, d5[1]
    vmlal.s16 q15, d13, d0[2]
    vmlsl.s16 q15, d14, d3[1]
    vmlal.s16 q15, d15, d5[2]
    vmlal.s16 q15, d16, d3[2]
    vmlsl.s16 q15, d17, d0[2]
    vmlal.s16 q15, d18, d4[3]
    vmlal.s16 q15, d19, d7[3]
    vmlsl.s16 q15, d20, d2[1]
    vmlal.s16 q15, d21, d0[3]
    vmlsl.s16 q15, d22, d6[1]
    vmlsl.s16 q15, d23, d6[3]   //O[23]
    vpush {q12-q15}

    vmull.s16 q12, d8, d6[3]
    vmlsl.s16 q12, d9, d1[3]
    vmlal.s16 q12, d10, d0[3]
    vmlsl.s16 q12, d11, d5[3]
    vmlsl.s16 q12, d12, d7[3]
    vmlal.s16 q12, d13, d2[3]
    vmlsl.s16 q12, d14, d0[2]
    vmlal.s16 q12, d15, d4[0]
    vmlsl.s16 q12, d16, d5[2]
    vmlsl.s16 q12, d17, d4[1]
    vmlal.s16 q12, d18, d0[2]
    vmlsl.s16 q12, d19, d2[2]
    vmlal.s16 q12, d20, d7[2]
    vmlal.s16 q12, d21, d6[0]
    vmlsl.s16 q12, d22, d1[0]
    vmlal.s16 q12, d23, d1[2]   //O[24]

    vmull.s16 q13, d8, d7[0]
    vmlsl.s16 q13, d9, d2[2]
    vmlal.s16 q13, d10, d0[2]
    vmlsl.s16 q13, d11, d2[3]
    vmlal.s16 q13, d12, d7[1]
    vmlal.s16 q13, d13, d6[3]
    vmlsl.s16 q13, d14, d2[1]
    vmlal.s16 q13, d15, d0[2]
    vmlsl.s16 q13, d16, d3[1]
    vmlal.s16 q13, d17, d7[2]
    vmlal.s16 q13, d18, d6[2]
    vmlsl.s16 q13, d19, d2[0]
    vmlal.s16 q13, d20, d0[2]
    vmlsl.s16 q13, d21, d3[2]
    vmlal.s16 q13, d22, d7[3]
    vmlal.s16 q13, d23, d6[1]   //O[25]

    vmull.s16 q14, d8, d7[1]
    vmlsl.s16 q14, d9, d3[2]
    vmlal.s16 q14, d10, d0[3]
    vmlsl.s16 q14, d11, d1[0]
    vmlal.s16 q14, d12, d4[1]
    vmlsl.s16 q14, d13, d7[3]
    vmlsl.s16 q14, d14, d6[3]
    vmlal.s16 q14, d15, d2[3]
    vmlsl.s16 q14, d16, d0[2]
    vmlal.s16 q14, d17, d1[2]
    vmlsl.s16 q14, d18, d5[1]
    vmlal.s16 q14, d19, d5[0]
    vmlal.s16 q14, d20, d6[1]
    vmlsl.s16 q14, d21, d2[1]
    vmlal.s16 q14, d22, d0[2]
    vmlsl.s16 q14, d23, d2[0]   //O[26]

    vmull.s16 q15, d8, d7[2]
    vmlsl.s16 q15, d9, d4[3]
    vmlal.s16 q15, d10, d1[3]
    vmlsl.s16 q15, d11, d0[2]
    vmlal.s16 q15, d12, d1[2]
    vmlsl.s16 q15, d13, d4[1]
    vmlal.s16 q15, d14, d7[1]
    vmlal.s16 q15, d15, d7[3]
    vmlsl.s16 q15, d16, d5[1]
    vmlal.s16 q15, d17, d2[0]
    vmlsl.s16 q15, d18, d0[2]
    vmlal.s16 q15, d19, d1[1]
    vmlsl.s16 q15, d20, d4[0]
    vmlal.s16 q15, d21, d7[0]
    vmlal.s16 q15, d22, d4[2]
    vmlsl.s16 q15, d23, d5[3]   //O[27]
    vpush {q12-q15}

    vmull.s16 q12, d8, d7[3]
    vmlsl.s16 q12, d9, d6[0]
    vmlal.s16 q12, d10, d3[1]
    vmlsl.s16 q12, d11, d1[1]
    vmlal.s16 q12, d12, d0[2]
    vmlsl.s16 q12, d13, d1[0]
    vmlal.s16 q12, d14, d2[3]
    vmlsl.s16 q12, d15, d5[3]
    vmlal.s16 q12, d16, d7[2]
    vmlal.s16 q12, d17, d4[2]
    vmlsl.s16 q12, d18, d6[1]
    vmlal.s16 q12, d19, d3[2]
    vmlsl.s16 q12, d20, d1[2]
    vmlal.s16 q12, d21, d0[2]
    vmlsl.s16 q12, d22, d0[3]
    vmlal.s16 q12, d23, d2[2]   //O[28]

    vmull.s16 q13, d8, d4[2]
    vmlsl.s16 q13, d9, d6[3]
    vmlal.s16 q13, d10, d5[1]
    vmlsl.s16 q13, d11, d3[1]
    vmlal.s16 q13, d12, d1[3]
    vmlsl.s16 q13, d13, d0[3]
    vmlal.s16 q13, d14, d0[2]
    vmlsl.s16 q13, d15, d0[3]
    vmlal.s16 q13, d16, d2[0]
    vmlsl.s16 q13, d17, d3[2]
    vmlal.s16 q13, d18, d5[3]
    vmlsl.s16 q13, d19, d7[0]
    vmlal.s16 q13, d20, d5[0]
    vmlal.s16 q13, d21, d7[3]
    vmlsl.s16 q13, d22, d6[2]
    vmlal.s16 q13, d23, d4[3]   //O[29]

    vmull.s16 q14, d8, d5[0]
    vmlsl.s16 q14, d9, d7[2]
    vmlal.s16 q14, d10, d6[3]
    vmlsl.s16 q14, d11, d6[0]
    vmlal.s16 q14, d12, d4[3]
    vmlsl.s16 q14, d13, d3[2]
    vmlal.s16 q14, d14, d2[2]
    vmlsl.s16 q14, d15, d1[3]
    vmlal.s16 q14, d16, d1[0]
    vmlsl.s16 q14, d17, d0[2]
    vmlal.s16 q14, d18, d0[2]
    vmlsl.s16 q14, d19, d0[2]
    vmlal.s16 q14, d20, d0[3]
    vmlsl.s16 q14, d21, d1[2]
    vmlal.s16 q14, d22, d2[1]
    vmlsl.s16 q14, d23, d3[1]   //O[30]

    vmull.s16 q15, d8, d5[2]
    vmlsl.s16 q15, d9, d5[0]
    vmlal.s16 q15, d10, d4[2]
    vmlsl.s16 q15, d11, d7[3]
    vmlal.s16 q15, d12, d7[2]
    vmlsl.s16 q15, d13, d7[1]
    vmlal.s16 q15, d14, d7[0]
    vmlsl.s16 q15, d15, d6[3]
    vmlal.s16 q15, d16, d6[2]
    vmlsl.s16 q15, d17, d6[1]
    vmlal.s16 q15, d18, d6[0]
    vmlsl.s16 q15, d19, d5[3]
    vmlal.s16 q15, d20, d5[1]
    vmlsl.s16 q15, d21, d4[3]
    vmlal.s16 q15, d22, d4[1]
    vmlsl.s16 q15, d23, d4[0]   //O[31]
    vpush {q12-q15}
.endm

//************************************************************************
//void uavs3d_itrans_dct_butterfly_h64_armv7(s16* src, int i_src, s16* dst, int line, int shift, int bit_depth);
//r0: coeff blk, 16 bit
//r1: i_src
//r2: resi blk, 16 bit
//r3: blk width
//r4: shift
//r5: bit_depth
//************************************************************************
function uavs3d_itrans_dct_butterfly_h64_armv7
    push {r4-r12, lr}
    vpush {q4-q7}
    ldr r4, [sp, #104]
    ldr r5, [sp, #108]

    mov r8, #1
    lsl r8, r8, r5
    sub r6, r5, #20                // -shift = bit_depth - 20
    sub r9, r8, #1                 // max_pel = (1<<bit_depth) - 1
    neg r8, r8                     // min_pel = -(1<<bit_depth)
    vdup.32 q15, r6               // for left shift
    vdup.16 d28, r8               // min_pel
    vdup.16 d29, r9               // max_pel
    vpush {q14, q15}

    mov r6, #47
    mov r7, #46
    mov r8, #45
    mov r9, #44
    mov r10, #43
    mov r11, #42
    vmov.s16 d0[0], r6
    vmov.s16 d0[1], r7
    vmov.s16 d0[2], r8
    vmov.s16 d0[3], r9
    vmov.s16 d1[0], r10
    vmov.s16 d1[1], r11
    mov r6, #41
    mov r7, #40
    vmov.s16 d1[2], r6
    vmov.s16 d1[3], r7

    vmov.s16 q6, #8
    vmov.s16 q7, #16
    vmov.s16 q8, #24
    vmov.s16 q9, #32
    vmov.s16 q10, #40
    vsub.s16 q1, q0, q6
    vsub.s16 q2, q0, q7
    vsub.s16 q3, q0, q8
    vsub.s16 q4, q0, q9
    vsub.s16 q5, q0, q10
    vpush {q0-q5}

    lsl r1, r1, #1  // i_src = width * sizeof(s16)
    lsl r3, r3, #1  // line
    mov r6, #0  // i=0
    lsl r7, r1, #3                 // 8*i_src
    lsl r8, r1, #2                 // 4*i_src
    lsl r9, r1, #1                 // 2*i_src
    mov r11, #128       // i_dst = 64 * sizeof(s16)
    cmp r5, #15
    bne dct2_h64_2nd_loopx

dct2_h64_1st_loopx:
    dct2_h64_w4_calcu_E_O_arm64
    push {r6, r7}
    add sp, sp, #8
    //load E[28-31]
    add sp, sp, #960
    vldmia sp, {q8-q11}
    vadd.s32 q4, q8, q12    //dst[28]
    vadd.s32 q5, q9, q13    //dst[29]
    vadd.s32 q6, q10, q14    //dst[30]
    vadd.s32 q7, q11, q15    //dst[31]
    //load E[24-27]
    sub sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[24-27]
    sub sp, sp, #832
    vldmia sp, {q12-q15}
    vadd.s32 q0, q8, q12    //dst[24]
    vadd.s32 q1, q9, q13    //dst[25]
    vadd.s32 q2, q10, q14    //dst[26]
    vadd.s32 q3, q11, q15    //dst[27]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[24-31]
    add r6, r2, #48
    add r7, r2, #56
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[28-31]
    sub sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[28-31]
    add sp, sp, #960
    vldmia sp, {q8-q11}
    vsub.s32 q0, q11, q15      // dst[32]
    vsub.s32 q1, q10, q14      // dst[33]
    vsub.s32 q2, q9, q13      // dst[34]
    vsub.s32 q3, q8, q12      // dst[35]
    //load E[24-27]
    sub sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[24-27]
    sub sp, sp, #832
    vldmia sp, {q12-q15}
    vsub.s32 q4, q11, q15      // dst[36]
    vsub.s32 q5, q10, q14      // dst[37]
    vsub.s32 q6, q9, q13      // dst[38]
    vsub.s32 q7, q8, q12      // dst[39]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[32-39]
    add r6, r2, #64
    add r7, r2, #72
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[0-3]
    add sp, sp, #384
    vldmia sp, {q12-q15}
    //load E[0-3]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    vadd.s32 q0, q8, q12    //dst[0]
    vadd.s32 q1, q9, q13    //dst[1]
    vadd.s32 q2, q10, q14    //dst[2]
    vadd.s32 q3, q11, q15    //dst[3]
    //load E[4-7]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[4-7]
    sub sp, sp, #192
    vldmia sp, {q12-q15}

    vadd.s32 q4, q8, q12    //dst[4]
    vadd.s32 q5, q9, q13    //dst[5]
    vadd.s32 q6, q10, q14    //dst[6]
    vadd.s32 q7, q11, q15    //dst[7]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[0-7]
    add r6, r2, #0
    add r7, r2, #8
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    vsub.s32 q0, q11, q15      // dst[56]
    vsub.s32 q1, q10, q14      // dst[57]
    vsub.s32 q2, q9, q13      // dst[58]
    vsub.s32 q3, q8, q12      // dst[59]
    //load O[0-3]
    add sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[0-3]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    vsub.s32 q4, q11, q15      // dst[60]
    vsub.s32 q5, q10, q14      // dst[61]
    vsub.s32 q6, q9, q13      // dst[62]
    vsub.s32 q7, q8, q12      // dst[63]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[56-63]
    add r6, r2, #112
    add r7, r2, #120
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load E[8-11]
    add sp, sp, #128
    vldmia sp, {q8-q11}
    //load O[8-11]
    sub sp, sp, #320
    vldmia sp, {q12-q15}
    vadd.s32 q0, q8, q12    //dst[8]
    vadd.s32 q1, q9, q13    //dst[9]
    vadd.s32 q2, q10, q14    //dst[10]
    vadd.s32 q3, q11, q15    //dst[11]
    //load O[12-15]
    sub sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[12-15]
    add sp, sp, #448
    vldmia sp, {q8-q11}
    vadd.s32 q4, q8, q12    //dst[12]
    vadd.s32 q5, q9, q13    //dst[13]
    vadd.s32 q6, q10, q14    //dst[14]
    vadd.s32 q7, q11, q15    //dst[15]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[8-15]
    add r6, r2, #16
    add r7, r2, #24
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    vsub.s32 q0, q11, q15      // dst[48]
    vsub.s32 q1, q10, q14      // dst[49]
    vsub.s32 q2, q9, q13      // dst[50]
    vsub.s32 q3, q8, q12      // dst[51]
    //load E[8-11]
    sub sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[8-11]
    sub sp, sp, #320
    vldmia sp, {q12-q15}
    vsub.s32 q4, q11, q15      // dst[52]
    vsub.s32 q5, q10, q14      // dst[53]
    vsub.s32 q6, q9, q13      // dst[54]
    vsub.s32 q7, q8, q12      // dst[55]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[48-55]
    add r6, r2, #96
    add r7, r2, #104
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[16-19]
    sub sp, sp, #128
    vldmia sp, {q12-q15}
    //load E[16-19]
    add sp, sp, #576
    vldmia sp, {q8-q11}
    vadd.s32 q0, q8, q12    //dst[16]
    vadd.s32 q1, q9, q13    //dst[17]
    vadd.s32 q2, q10, q14    //dst[18]
    vadd.s32 q3, q11, q15    //dst[19]
    //load E[20-23]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[20-23]
    sub sp, sp, #704
    vldmia sp, {q12-q15}
    vadd.s32 q4, q8, q12    //dst[20]
    vadd.s32 q5, q9, q13    //dst[21]
    vadd.s32 q6, q10, q14    //dst[22]
    vadd.s32 q7, q11, q15    //dst[23]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[8-15]
    add r6, r2, #32
    add r7, r2, #40
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    vsub.s32 q0, q11, q15      // dst[40]
    vsub.s32 q1, q10, q14      // dst[41]
    vsub.s32 q2, q9, q13      // dst[42]
    vsub.s32 q3, q8, q12      // dst[43]
    //load O[16-19]
    add sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[16-19]
    add sp, sp, #576
    vldmia sp, {q8-q11}
    vsub.s32 q4, q11, q15      // dst[44]
    vsub.s32 q5, q10, q14      // dst[45]
    vsub.s32 q6, q9, q13      // dst[46]
    vsub.s32 q7, q8, q12      // dst[47]

    vqrshrn.s32 d0, q0, #5
    vqrshrn.s32 d2, q1, #5
    vqrshrn.s32 d4, q2, #5
    vqrshrn.s32 d6, q3, #5
    vqrshrn.s32 d8, q4, #5
    vqrshrn.s32 d10, q5, #5
    vqrshrn.s32 d12, q6, #5
    vqrshrn.s32 d14, q7, #5

    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    //store dst[48-55]
    add r6, r2, #80
    add r7, r2, #88
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    sub sp, sp, #776
    pop {r6, r7}
    add sp, sp, #1664
    add r6, r6, #8
    add r0, r0, #8      // src += 4
    add r2, r2, #512        // dst += i_dst*4
    cmp r6, r3
    blt dct2_h64_1st_loopx
    b dct2_h64_end

dct2_h64_2nd_loopx:
    dct2_h64_w4_calcu_E_O_arm64
    push {r6, r7}
    add sp, sp, #8
    //load E[28-31]
    add sp, sp, #960
    vldmia sp, {q8-q11}
    vadd.s32 q4, q8, q12    //dst[28]
    vadd.s32 q5, q9, q13    //dst[29]
    vadd.s32 q6, q10, q14    //dst[30]
    vadd.s32 q7, q11, q15    //dst[31]
    //load E[24-27]
    sub sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[24-27]
    sub sp, sp, #832
    vldmia sp, {q12-q15}
    vadd.s32 q0, q8, q12    //dst[24]
    vadd.s32 q1, q9, q13    //dst[25]
    vadd.s32 q2, q10, q14    //dst[26]
    vadd.s32 q3, q11, q15    //dst[27]

    add sp, sp, #1696
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #1696

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    //store dst[24-31]
    add r6, r2, #48
    add r7, r2, #56
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[28-31]
    sub sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[28-31]
    add sp, sp, #960
    vldmia sp, {q8-q11}
    vsub.s32 q0, q11, q15      // dst[32]
    vsub.s32 q1, q10, q14      // dst[33]
    vsub.s32 q2, q9, q13      // dst[34]
    vsub.s32 q3, q8, q12      // dst[35]
    //load E[24-27]
    sub sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[24-27]
    sub sp, sp, #832
    vldmia sp, {q12-q15}
    vsub.s32 q4, q11, q15      // dst[36]
    vsub.s32 q5, q10, q14      // dst[37]
    vsub.s32 q6, q9, q13      // dst[38]
    vsub.s32 q7, q8, q12      // dst[39]

    add sp, sp, #1696
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #1696

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    //store dst[32-39]
    add r6, r2, #64
    add r7, r2, #72
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[0-3]
    add sp, sp, #384
    vldmia sp, {q12-q15}
    //load E[0-3]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    vadd.s32 q0, q8, q12    //dst[0]
    vadd.s32 q1, q9, q13    //dst[1]
    vadd.s32 q2, q10, q14    //dst[2]
    vadd.s32 q3, q11, q15    //dst[3]
    //load E[4-7]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[4-7]
    sub sp, sp, #192
    vldmia sp, {q12-q15}

    vadd.s32 q4, q8, q12    //dst[4]
    vadd.s32 q5, q9, q13    //dst[5]
    vadd.s32 q6, q10, q14    //dst[6]
    vadd.s32 q7, q11, q15    //dst[7]

    add sp, sp, #1376
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #1376

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    //store dst[0-7]
    add r6, r2, #0
    add r7, r2, #8
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[4-7]
    vldmia sp, {q12-q15}
    vsub.s32 q0, q11, q15      // dst[56]
    vsub.s32 q1, q10, q14      // dst[57]
    vsub.s32 q2, q9, q13      // dst[58]
    vsub.s32 q3, q8, q12      // dst[59]
    //load O[0-3]
    add sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[0-3]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    vsub.s32 q4, q11, q15      // dst[60]
    vsub.s32 q5, q10, q14      // dst[61]
    vsub.s32 q6, q9, q13      // dst[62]
    vsub.s32 q7, q8, q12      // dst[63]

    add sp, sp, #1248
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #1248

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    //store dst[56-63]
    add r6, r2, #112
    add r7, r2, #120
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load E[8-11]
    add sp, sp, #128
    vldmia sp, {q8-q11}
    //load O[8-11]
    sub sp, sp, #320
    vldmia sp, {q12-q15}
    vadd.s32 q0, q8, q12    //dst[8]
    vadd.s32 q1, q9, q13    //dst[9]
    vadd.s32 q2, q10, q14    //dst[10]
    vadd.s32 q3, q11, q15    //dst[11]
    //load O[12-15]
    sub sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[12-15]
    add sp, sp, #448
    vldmia sp, {q8-q11}
    vadd.s32 q4, q8, q12    //dst[12]
    vadd.s32 q5, q9, q13    //dst[13]
    vadd.s32 q6, q10, q14    //dst[14]
    vadd.s32 q7, q11, q15    //dst[15]

    add sp, sp, #1056
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #1056

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    //store dst[8-15]
    add r6, r2, #16
    add r7, r2, #24
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[12-15]
    sub sp, sp, #448
    vldmia sp, {q12-q15}
    add sp, sp, #448
    vsub.s32 q0, q11, q15      // dst[48]
    vsub.s32 q1, q10, q14      // dst[49]
    vsub.s32 q2, q9, q13      // dst[50]
    vsub.s32 q3, q8, q12      // dst[51]
    //load E[8-11]
    sub sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[8-11]
    sub sp, sp, #320
    vldmia sp, {q12-q15}
    vsub.s32 q4, q11, q15      // dst[52]
    vsub.s32 q5, q10, q14      // dst[53]
    vsub.s32 q6, q9, q13      // dst[54]
    vsub.s32 q7, q8, q12      // dst[55]

    add sp, sp, #1440
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #1440

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28


    //store dst[48-55]
    add r6, r2, #96
    add r7, r2, #104
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[16-19]
    sub sp, sp, #128
    vldmia sp, {q12-q15}
    //load E[16-19]
    add sp, sp, #576
    vldmia sp, {q8-q11}
    vadd.s32 q0, q8, q12    //dst[16]
    vadd.s32 q1, q9, q13    //dst[17]
    vadd.s32 q2, q10, q14    //dst[18]
    vadd.s32 q3, q11, q15    //dst[19]
    //load E[20-23]
    add sp, sp, #64
    vldmia sp, {q8-q11}
    //load O[20-23]
    sub sp, sp, #704
    vldmia sp, {q12-q15}
    vadd.s32 q4, q8, q12    //dst[20]
    vadd.s32 q5, q9, q13    //dst[21]
    vadd.s32 q6, q10, q14    //dst[22]
    vadd.s32 q7, q11, q15    //dst[23]

    add sp, sp, #1632
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #1632

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    //store dst[8-15]
    add r6, r2, #32
    add r7, r2, #40
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    //load O[20-23]
    vldmia sp, {q12-q15}
    vsub.s32 q0, q11, q15      // dst[40]
    vsub.s32 q1, q10, q14      // dst[41]
    vsub.s32 q2, q9, q13      // dst[42]
    vsub.s32 q3, q8, q12      // dst[43]
    //load O[16-19]
    add sp, sp, #64
    vldmia sp, {q12-q15}
    //load E[16-19]
    add sp, sp, #576
    vldmia sp, {q8-q11}
    vsub.s32 q4, q11, q15      // dst[44]
    vsub.s32 q5, q10, q14      // dst[45]
    vsub.s32 q6, q9, q13      // dst[46]
    vsub.s32 q7, q8, q12      // dst[47]

    add sp, sp, #992
    vldmia sp, {q14, q15}   //load minval, maxval, shift
    sub sp, sp, #992

    vrshl.s32 q0, q0, q15
    vrshl.s32 q1, q1, q15
    vrshl.s32 q2, q2, q15
    vrshl.s32 q3, q3, q15
    vrshl.s32 q4, q4, q15
    vrshl.s32 q5, q5, q15
    vrshl.s32 q6, q6, q15
    vrshl.s32 q7, q7, q15

    vqmovn.s32 d0, q0
    vqmovn.s32 d2, q1
    vqmovn.s32 d4, q2
    vqmovn.s32 d6, q3
    vqmovn.s32 d8, q4
    vqmovn.s32 d10, q5
    vqmovn.s32 d12, q6
    vqmovn.s32 d14, q7

    //转置
    vtrn.s32 d0, d4
    vtrn.s32 d2, d6
    vtrn.s16 d0, d2
    vtrn.s16 d4, d6

    vtrn.s32 d8, d12
    vtrn.s32 d10, d14
    vtrn.s16 d8, d10
    vtrn.s16 d12, d14

    vmin.s16 d0, d0, d29
    vmax.s16 d0, d0, d28
    vmin.s16 d2, d2, d29
    vmax.s16 d2, d2, d28
    vmin.s16 d4, d4, d29
    vmax.s16 d4, d4, d28
    vmin.s16 d6, d6, d29
    vmax.s16 d6, d6, d28

    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28
    vmin.s16 d10, d10, d29
    vmax.s16 d10, d10, d28
    vmin.s16 d12, d12, d29
    vmax.s16 d12, d12, d28
    vmin.s16 d14, d14, d29
    vmax.s16 d14, d14, d28

    //store dst[48-55]
    add r6, r2, #80
    add r7, r2, #88
    vst1.64 d0, [r6], r11
    vst1.64 d8, [r7], r11
    vst1.64 d2, [r6], r11
    vst1.64 d10, [r7], r11
    vst1.64 d4, [r6], r11
    vst1.64 d12, [r7], r11
    vst1.64 d6, [r6], r11
    vst1.64 d14, [r7], r11

    sub sp, sp, #776
    pop {r6, r7}
    add sp, sp, #1664
    add r6, r6, #8
    add r0, r0, #8      // src += 4
    add r2, r2, #512        // dst += i_dst*4
    cmp r6, r3
    blt dct2_h64_2nd_loopx

dct2_h64_end:
    add sp, sp, #128
    vpop {q4-q7}
    pop {r4-r12, pc}

    #endif
