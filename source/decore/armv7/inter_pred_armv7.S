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
 *    This product includes software developed by the <organization>.
 * 4. Neither the name of the <organization> nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
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

#if !COMPILE_10BIT
//void uavs3d_if_cpy_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w4_armv7
    push {r4-r8, lr}
    ldr r5, [sp, #28]

if_cpy_w4_loop_y:
    ldr r6, [r0], r1
    ldr r7, [r0], r1
    ldr r8, [r0], r1
    ldr r4, [r0], r1
    str r6, [r2], r3
    str r7, [r2], r3
    subs r5, r5, #4
    str r8, [r2], r3
    str r4, [r2], r3
    bgt if_cpy_w4_loop_y

    pop {r4-r8, pc}

//void uavs3d_if_cpy_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w8_armv7
    push {r5, lr}
    ldr r5, [sp, #12]
if_cpy_w8_loop_y:
    vld1.64 {d0}, [r0], r1
    vld1.64 {d1}, [r0], r1
    vld1.64 {d2}, [r0], r1
    vld1.64 {d3}, [r0], r1
    subs r5, r5, #4
    vst1.64 {d0}, [r2], r3
    vst1.64 {d1}, [r2], r3
    vst1.64 {d2}, [r2], r3
    vst1.64 {d3}, [r2], r3
    bgt if_cpy_w8_loop_y

    pop {r5, pc}


//void uavs3d_if_cpy_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w16_armv7
    push {r5, lr}
    ldr r5, [sp, #12]
if_cpy_w16_loop_y:
    vld1.64 {q0}, [r0], r1
    vld1.64 {q1}, [r0], r1
    vld1.64 {q2}, [r0], r1
    vld1.64 {q3}, [r0], r1

    subs r5, r5, #4
    vst1.64 {q0}, [r2], r3
    vst1.64 {q1}, [r2], r3
    vst1.64 {q2}, [r2], r3
    vst1.64 {q3}, [r2], r3
    bgt if_cpy_w16_loop_y

    pop {r5, pc}

//void uavs3d_if_cpy_w32_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w32_armv7
    push {r5, lr}
    ldr r5, [sp, #12]
if_cpy_w32_loop_y:
    vld1.64 {q0, q1}, [r0], r1
    vld1.64 {q2, q3}, [r0], r1
    vld1.64 {q10, q11}, [r0], r1
    vld1.64 {q12, q13}, [r0], r1

    subs r5, r5, #4
    vst1.64 {q0, q1}, [r2], r3
    vst1.64 {q2, q3}, [r2], r3
    vst1.64 {q10, q11}, [r2], r3
    vst1.64 {q12, q13}, [r2], r3
    bgt if_cpy_w32_loop_y

    pop {r5, pc}

//void uavs3d_if_cpy_w64_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w64_armv7
    push {r5, lr}
    vpush {q4-q7}
    ldr r5, [sp, #76]

    sub r1, #32
    sub r3, #32
if_cpy_w64_loop_y:
    vld1.64 {q0 , q1 }, [r0]!
    vld1.64 {q2 , q3 }, [r0], r1
    vld1.64 {q4 , q5 }, [r0]!
    vld1.64 {q6 , q7 }, [r0], r1
    vld1.64 {q8 , q9 }, [r0]!
    vld1.64 {q10, q11}, [r0], r1
    vld1.64 {q12, q13}, [r0]!
    vld1.64 {q14, q15}, [r0], r1

    subs r5, r5, #4
    vst1.64 {q0 , q1 }, [r2]!
    vst1.64 {q2 , q3 }, [r2], r3
    vst1.64 {q4 , q5 }, [r2]!
    vst1.64 {q6 , q7 }, [r2], r3
    vst1.64 {q8 , q9 }, [r2]!
    vst1.64 {q10, q11}, [r2], r3
    vst1.64 {q12, q13}, [r2]!
    vst1.64 {q14, q15}, [r2], r3

    bgt if_cpy_w64_loop_y

    vpop {q4-q7}
    pop {r5, pc}

//void uavs3d_if_cpy_w128_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w128_armv7
    push {r5, lr}
    vpush {q4-q7}
    ldr r5, [sp, #76]

    sub r1, #96
    sub r3, #96
if_cpy_w128_loop_y:
    vld1.64 {q0 , q1 }, [r0]!
    vld1.64 {q2 , q3 }, [r0]!
    vld1.64 {q4 , q5 }, [r0]!
    vld1.64 {q6 , q7 }, [r0], r1
    vld1.64 {q8 , q9 }, [r0]!
    vld1.64 {q10, q11}, [r0]!
    vld1.64 {q12, q13}, [r0]!
    vld1.64 {q14, q15}, [r0], r1

    subs r5, r5, #2
    vst1.64 {q0 , q1 }, [r2]!
    vst1.64 {q2 , q3 }, [r2]!
    vst1.64 {q4 , q5 }, [r2]!
    vst1.64 {q6 , q7 }, [r2], r3
    vst1.64 {q8 , q9 }, [r2]!
    vst1.64 {q10, q11}, [r2]!
    vst1.64 {q12, q13}, [r2]!
    vst1.64 {q14, q15}, [r2], r3

    bgt if_cpy_w128_loop_y

    vpop {q4-q7}
    pop {r5, pc}

//void uavs3d_if_hor_chroma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_chroma_w8_armv7
    push    {r5-r6, lr}
    ldr r5, [sp, #16]
    ldr r6, [sp, #20]

    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vdup.s8 d0, d4[0]
    vdup.s8 d1, d4[1]
    vdup.s8 d2, d4[2]
    vdup.s8 d3, d4[3]

    sub r0, r0, #2              // src - 2

if_hor_chroma_w8_loop_y:
    vld1.8 {q14}, [r0], r1      // src[x-2]
    vld1.8 {q15}, [r0], r1
    vext.i16 d16, d28, d29, #1  // src[x]
    vext.i16 d17, d28, d29, #2  // src[x+2]
    vext.i16 d18, d28, d29, #3  // src[x+4]
    vext.i16 d19, d30, d31, #1  // src[x]
    vext.i16 d20, d30, d31, #2  // src[x+2]
    vext.i16 d21, d30, d31, #3  // src[x+4]
    vmull.u8 q12, d16, d1
    vmlsl.u8 q12, d28, d0
    vmlal.u8 q12, d17, d2
    vmlsl.u8 q12, d18, d3

    vmull.u8 q13, d19, d1
    vmlsl.u8 q13, d30, d0
    vmlal.u8 q13, d20, d2
    vmlsl.u8 q13, d21, d3

    vqrshrun.s16 d24, q12, #6
    vqrshrun.s16 d26, q13, #6

    subs r5, r5, #2
    vst1.64 {d24}, [r2], r3
    vst1.64 {d26}, [r2], r3
    bgt if_hor_chroma_w8_loop_y

    pop {r5-r6, pc}


//void uavs3d_if_hor_chroma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_chroma_w16_armv7
    push    {r5-r6, lr}
    vpush   {q4, q5}
    ldr r5, [sp, #48]
    ldr r6, [sp, #52]

    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vdup.s8 d0, d8[0]
    vdup.s8 d1, d8[1]
    vdup.s8 d2, d8[2]
    vdup.s8 d3, d8[3]

    sub r0, r0, #2                // src - 2

if_hor_chroma_w16_loop_y:
    vld1.8 {q2, q3}, [r0], r1    // src[x-2]
    vld1.8 {q4, q5}, [r0], r1
    vext.i16 q10, q2, q3, #1   // src[x]
    vext.i16 q11, q2, q3, #2   // src[x+2]
    vext.i16 q12, q2, q3, #3   // src[x+4]
    vext.i16 q13, q4, q5, #1   // src[x]
    vext.i16 q14, q4, q5, #2   // src[x+2]
    vext.i16 q15, q4, q5, #3   // src[x+4]

    vmull.u8 q3, d20, d1
    vmull.u8 q5, d21, d1
    vmull.u8 q8, d26, d1
    vmull.u8 q9, d27, d1
    vmlsl.u8 q3, d4, d0
    vmlsl.u8 q5, d5, d0
    vmlsl.u8 q8, d8, d0
    vmlsl.u8 q9, d9, d0
    vmlal.u8 q3, d22, d2
    vmlal.u8 q5, d23, d2
    vmlal.u8 q8, d28, d2
    vmlal.u8 q9, d29, d2
    vmlsl.u8 q3, d24, d3
    vmlsl.u8 q5, d25, d3
    vmlsl.u8 q8, d30, d3
    vmlsl.u8 q9, d31, d3

    vqrshrun.s16 d20, q3, #6
    vqrshrun.s16 d21, q5, #6
    vqrshrun.s16 d22, q8, #6
    vqrshrun.s16 d23, q9, #6

    subs r5, r5, #2
    vst1.64 {q10}, [r2], r3
    vst1.64 {q11}, [r2], r3
    bgt if_hor_chroma_w16_loop_y

    vpop {q4, q5}
    pop {r5-r6, pc}


//void uavs3d_if_hor_chroma_w32_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_chroma_w32_armv7
    push    {r5-r6, lr}
    vpush   {q4, q5}
    ldr r5, [sp, #48]
    ldr r6, [sp, #52]

    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vdup.s8 d0, d8[0]
    vdup.s8 d1, d8[1]
    vdup.s8 d2, d8[2]
    vdup.s8 d3, d8[3]

    sub r0, r0, #2              // src - 2
    sub r1, r1, #32
if_hor_chroma_w32_loop_y:
    vld1.8 {q2, q3}, [r0]!      // src[x-2]
    vld1.8 {q4}, [r0], r1
    vext.i16 q10, q2, q3, #1    // src[x]
    vext.i16 q11, q2, q3, #2    // src[x+2]
    vext.i16 q12, q2, q3, #3    // src[x+4]
    vext.i16 q13, q3, q4, #1    // src[x]
    vext.i16 q14, q3, q4, #2    // src[x+2]
    vext.i16 q15, q3, q4, #3    // src[x+4]

    vmull.u8 q4, d20, d1
    vmull.u8 q5, d21, d1
    vmull.u8 q8, d26, d1
    vmull.u8 q9, d27, d1
    vmlsl.u8 q4, d4, d0
    vmlsl.u8 q5, d5, d0
    vmlsl.u8 q8, d6, d0
    vmlsl.u8 q9, d7, d0
    vmlal.u8 q4, d22, d2
    vmlal.u8 q5, d23, d2
    vmlal.u8 q8, d28, d2
    vmlal.u8 q9, d29, d2
    vmlsl.u8 q4, d24, d3
    vmlsl.u8 q5, d25, d3
    vmlsl.u8 q8, d30, d3
    vmlsl.u8 q9, d31, d3

    vqrshrun.s16 d20, q4, #6
    vqrshrun.s16 d21, q5, #6
    vqrshrun.s16 d22, q8, #6
    vqrshrun.s16 d23, q9, #6

    subs r5, r5, #1
    vst1.64 {q10, q11}, [r2], r3
    bgt if_hor_chroma_w32_loop_y

    vpop {q4, q5}
    pop {r5-r6, pc}

//void uavs3d_if_hor_chroma_w32x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_chroma_w32x_armv7
    push    {r4-r8, lr}
    vpush   {q4, q5}
    ldr r4, [sp, #56]
    ldr r5, [sp, #60]
    ldr r6, [sp, #64]

    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vdup.s8 d0, d8[0]
    vdup.s8 d1, d8[1]
    vdup.s8 d2, d8[2]
    vdup.s8 d3, d8[3]

    sub r0, r0, #2              // src - 2
if_hor_chroma_w32x_loop_y:
    mov r6, r4
    mov r7, r0
    mov r8, r2
if_hor_chroma_w32x_loop_x:
    vld1.8 {q2, q3}, [r7]!     // src[x-2]
    vld1.8 {q4}, [r7]
    vext.i16 q10, q2, q3, #1    // src[x]
    vext.i16 q11, q2, q3, #2    // src[x+2]
    vext.i16 q12, q2, q3, #3    // src[x+4]
    vext.i16 q13, q3, q4, #1    // src[x]
    vext.i16 q14, q3, q4, #2    // src[x+2]
    vext.i16 q15, q3, q4, #3    // src[x+4]

    vmull.u8 q4, d20, d1
    vmull.u8 q5, d21, d1
    vmull.u8 q8, d26, d1
    vmull.u8 q9, d27, d1
    vmlsl.u8 q4, d4, d0
    vmlsl.u8 q5, d5, d0
    vmlsl.u8 q8, d6, d0
    vmlsl.u8 q9, d7, d0
    vmlal.u8 q4, d22, d2
    vmlal.u8 q5, d23, d2
    vmlal.u8 q8, d28, d2
    vmlal.u8 q9, d29, d2
    vmlsl.u8 q4, d24, d3
    vmlsl.u8 q5, d25, d3
    vmlsl.u8 q8, d30, d3
    vmlsl.u8 q9, d31, d3

    vqrshrun.s16 d20, q4, #6
    vqrshrun.s16 d21, q5, #6
    vqrshrun.s16 d22, q8, #6
    vqrshrun.s16 d23, q9, #6

    subs r6, r6, #32
    vst1.64 {q10, q11}, [r8]!
    bgt if_hor_chroma_w32x_loop_x

    subs r5, r5, #1
    add r0, r0, r1
    add r2, r2, r3
    bgt if_hor_chroma_w32x_loop_y

    vpop {q4, q5}
    pop {r4-r8, pc}


//void uavs3d_if_hor_luma_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_luma_w4_armv7
    push    {r5-r6, lr}
    vpush   {q6, q7}
    ldr r5, [sp, #48]
    ldr r6, [sp, #52]

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                          // x-3
if_hor_luma_w4_loop_y:
    vld1.8 {q12}, [r0], r1                 // src[x-3]
    vld1.8 {q13}, [r0], r1
    vld1.8 {q14}, [r0], r1
    vld1.8 {q15}, [r0], r1
    vzip.8 q12, q13
    vzip.8 q14, q15

    vext.i16 d12, d24, d25, #1
    vext.i16 d13, d24, d25, #2
    vext.i16 d14, d24, d25, #3
    vext.i16 d15, d25, d26, #1
    vext.i16 d16, d25, d26, #2
    vext.i16 d17, d25, d26, #3

    vext.i16 d18, d28, d29, #1
    vext.i16 d19, d28, d29, #2
    vext.i16 d20, d28, d29, #3
    vext.i16 d21, d29, d30, #1
    vext.i16 d22, d29, d30, #2
    vext.i16 d23, d29, d30, #3

    // interpolation filter
    vmull.u8 q13, d12, d1
    vmull.u8 q15, d18, d1
    vmlsl.u8 q13, d24, d0
    vmlsl.u8 q15, d28, d0
    vmlsl.u8 q13, d13, d2
    vmlsl.u8 q15, d19, d2
    vmlal.u8 q13, d14, d3
    vmlal.u8 q15, d20, d3
    vmlal.u8 q13, d25, d4
    vmlal.u8 q15, d29, d4
    vmlsl.u8 q13, d15, d5
    vmlsl.u8 q15, d21, d5
    vmlal.u8 q13, d16, d6
    vmlal.u8 q15, d22, d6
    vmlsl.u8 q13, d17, d7
    vmlsl.u8 q15, d23, d7

    // round and clip
    vuzp.16 d26, d27
    vuzp.16 d30, d31
    vqrshrun.s16 d12, q13, #6
    vqrshrun.s16 d13, q15, #6

    subs r5, r5, #4
    // store results into &dst[x]
    vst1.32 {d12[0]}, [r2], r3
    vst1.32 {d12[1]}, [r2], r3
    vst1.32 {d13[0]}, [r2], r3
    vst1.32 {d13[1]}, [r2], r3
    bgt if_hor_luma_w4_loop_y

    vpop {q6, q7}
    pop {r5-r6, pc}


//void uavs3d_if_hor_luma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_luma_w8_armv7
    push    {r5-r6, lr}
    vpush   {q6, q7}
    ldr r5, [sp, #48]
    ldr r6, [sp, #52]

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                      // x-3
if_hor_luma_w8_loop_y:
    vld1.8 {q12}, [r0], r1              // src[x-3]
    vld1.8 {q13}, [r0], r1

    vext.i8 d12, d24, d25, #1
    vext.i8 d13, d24, d25, #2
    vext.i8 d14, d24, d25, #3
    vext.i8 d15, d24, d25, #4
    vext.i8 d16, d24, d25, #5
    vext.i8 d17, d24, d25, #6
    vext.i8 d18, d24, d25, #7

    vext.i8 d19, d26, d27, #1
    vext.i8 d20, d26, d27, #2
    vext.i8 d21, d26, d27, #3
    vext.i8 d22, d26, d27, #4
    vext.i8 d23, d26, d27, #5
    vext.i8 d25, d26, d27, #6
    vext.i8 d27, d26, d27, #7

    // interpolation filter
    vmull.u8 q14, d12, d1
    vmull.u8 q15, d19, d1
    vmlsl.u8 q14, d24, d0
    vmlsl.u8 q15, d26, d0
    vmlsl.u8 q14, d13, d2
    vmlsl.u8 q15, d20, d2
    vmlal.u8 q14, d14, d3
    vmlal.u8 q15, d21, d3
    vmlal.u8 q14, d15, d4
    vmlal.u8 q15, d22, d4
    vmlsl.u8 q14, d16, d5
    vmlsl.u8 q15, d23, d5
    vmlal.u8 q14, d17, d6
    vmlal.u8 q15, d25, d6
    vmlsl.u8 q14, d18, d7
    vmlsl.u8 q15, d27, d7

    // round and clip
    vqrshrun.s16 d12, q14, #6
    vqrshrun.s16 d13, q15, #6

    // store
    subs r5, r5, #2
    vst1.64 {d12}, [r2], r3
    vst1.64 {d13}, [r2], r3
    bgt if_hor_luma_w8_loop_y

    vpop {q6, q7}
    pop {r5-r6, pc}


//void uavs3d_if_hor_luma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_luma_w16_armv7
    push    {r5-r6, lr}
    vpush   {q6, q7}
    ldr r5, [sp, #48]
    ldr r6, [sp, #52]

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                      // x-3
if_hor_luma_w16_loop_y:
    vld1.8 {q14, q15}, [r0], r1         // src[x-3]

    vext.i8 q6 , q14, q15, #1           // src[x-2]
    vext.i8 q7 , q14, q15, #2
    vext.i8 q8 , q14, q15, #3
    vext.i8 q9 , q14, q15, #4
    vext.i8 q10, q14, q15, #5
    vext.i8 q11, q14, q15, #6
    vext.i8 q12, q14, q15, #7

    // interpolation filter
    vmull.u8 q13, d12, d1
    vmull.u8 q15, d13, d1
    vmlsl.u8 q13, d28, d0
    vmlsl.u8 q15, d29, d0
    vmlsl.u8 q13, d14, d2
    vmlsl.u8 q15, d15, d2
    vmlal.u8 q13, d16, d3
    vmlal.u8 q15, d17, d3
    vmlal.u8 q13, d18, d4
    vmlal.u8 q15, d19, d4
    vmlsl.u8 q13, d20, d5
    vmlsl.u8 q15, d21, d5
    vmlal.u8 q13, d22, d6
    vmlal.u8 q15, d23, d6
    vmlsl.u8 q13, d24, d7
    vmlsl.u8 q15, d25, d7

    // round and clip
    vqrshrun.s16 d12, q13, #6
    vqrshrun.s16 d13, q15, #6

    // store
    subs r5, r5, #1
    vst1.64 {q6}, [r2], r3
    bgt if_hor_luma_w16_loop_y

    vpop {q6, q7}
    pop {r5-r6, pc}

//void uavs3d_if_hor_luma_w16x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_luma_w16x_armv7
    push    {r4-r8, lr}
    vpush   {q6, q7}
    ldr r4, [sp, #56]
    ldr r5, [sp, #60]
    ldr r6, [sp, #64]

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                      // x-3
if_hor_luma_w16x_loop_y:
    mov r6, r4
    mov r7, r0
    mov r8, r2
if_hor_luma_w16x_loop_x:
    vld1.8 {q14, q15}, [r7]            // src[x-3]

    vext.i8 q6 , q14, q15, #1           // src[x-2]
    vext.i8 q7 , q14, q15, #2
    vext.i8 q8 , q14, q15, #3
    vext.i8 q9 , q14, q15, #4
    vext.i8 q10, q14, q15, #5
    vext.i8 q11, q14, q15, #6
    vext.i8 q12, q14, q15, #7

    add r7, #16

    // interpolation filter
    vmull.u8 q13, d12, d1
    vmull.u8 q15, d13, d1
    vmlsl.u8 q13, d28, d0
    vmlsl.u8 q15, d29, d0
    vmlsl.u8 q13, d14, d2
    vmlsl.u8 q15, d15, d2
    vmlal.u8 q13, d16, d3
    vmlal.u8 q15, d17, d3
    vmlal.u8 q13, d18, d4
    vmlal.u8 q15, d19, d4
    vmlsl.u8 q13, d20, d5
    vmlsl.u8 q15, d21, d5
    vmlal.u8 q13, d22, d6
    vmlal.u8 q15, d23, d6
    vmlsl.u8 q13, d24, d7
    vmlsl.u8 q15, d25, d7

    subs r6, #16

    // round and clip
    vqrshrun.s16 d12, q13, #6
    vqrshrun.s16 d13, q15, #6

    // store
    vst1.64 {q6}, [r8]!
    bgt if_hor_luma_w16x_loop_x
    subs r5, r5, #1
    add r0, r0, r1
    add r2, r2, r3
    bgt if_hor_luma_w16x_loop_y

    vpop {q6, q7}
    pop {r4-r8, pc}


//void uavs3d_if_ver_chroma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_chroma_w8_armv7
    push    {r5-r6, lr}
    ldr r5, [sp, #16]
    ldr r6, [sp, #20]

    // load coeff
    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vdup.s8 d0, d4[0]
    vdup.s8 d1, d4[1]
    vdup.s8 d2, d4[2]
    vdup.s8 d3, d4[3]

    sub r0, r0, r1              // src - i_src
if_ver_chroma_w8_loop_y:
    vld1.8 {d4}, [r0], r1       // src-i_src
    vld1.8 {d5}, [r0], r1       // src
    vld1.8 {d6}, [r0], r1       // src+i_src
    vld1.8 {d7}, [r0], r1       // src+2*i_src
    mov r6, r0
    vld1.8 {d16}, [r0], r1
    vld1.8 {d17}, [r0], r1
    vld1.8 {d18}, [r0], r1

    vmull.u8 q12, d5, d1
    vmull.u8 q13, d6, d1
    vmlsl.u8 q12, d4, d0
    vmlsl.u8 q13, d5, d0
    vmlal.u8 q12, d6, d2
    vmlal.u8 q13, d7, d2
    vmlsl.u8 q12, d7, d3
    vmlsl.u8 q13, d16, d3

    vmull.u8 q14, d7, d1
    vmull.u8 q15, d16, d1
    vmlsl.u8 q14, d6, d0
    vmlsl.u8 q15, d7, d0
    vmlal.u8 q14, d16, d2
    vmlal.u8 q15, d17, d2
    vmlsl.u8 q14, d17, d3
    vmlsl.u8 q15, d18, d3

    //(sum + 32) >> 6
    vqrshrun.s16 d24, q12, #6
    vqrshrun.s16 d25, q13, #6
    vqrshrun.s16 d26, q14, #6
    vqrshrun.s16 d27, q15, #6

    mov r0, r6
    vst1.32 {d24}, [r2], r3
    subs r5, r5, #4
    vst1.32 {d25}, [r2], r3
    vst1.32 {d26}, [r2], r3
    vst1.32 {d27}, [r2], r3
    bgt if_ver_chroma_w8_loop_y

    pop {r5-r6, pc}


//void uavs3d_if_ver_chroma_w16_armv7(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_chroma_w16_armv7
    push    {r5-r6, lr}
    vpush   {q4}
    ldr r5, [sp, #32]
    ldr r6, [sp, #36]

    // load coeff
    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vdup.s8 d0, d8[0]
    vdup.s8 d1, d8[1]
    vdup.s8 d2, d8[2]
    vdup.s8 d3, d8[3]

    sub r0, r0, r1

if_ver_chroma_w16_loop_y:
    vld1.8 {q2}, [r0], r1         // src-i_src
    vld1.8 {q3}, [r0], r1         // src
    vld1.8 {q4}, [r0], r1         // src+i_src
    vld1.8 {q8}, [r0], r1         // src+2*i_src
    mov r6, r0
    vld1.8 {q9}, [r0], r1
    vld1.8 {q10}, [r0], r1
    vld1.8 {q11}, [r0]

    vmull.u8 q12, d6, d1
    vmull.u8 q13, d7, d1
    vmull.u8 q14, d8, d1
    vmull.u8 q15, d9, d1
    vmlsl.u8 q12, d4, d0
    vmlsl.u8 q13, d5, d0
    vmlsl.u8 q14, d6, d0
    vmlsl.u8 q15, d7, d0
    vmlal.u8 q12, d8, d2
    vmlal.u8 q13, d9, d2
    vmlal.u8 q14, d16, d2
    vmlal.u8 q15, d17, d2
    vmlsl.u8 q12, d16, d3
    vmlsl.u8 q13, d17, d3
    vmlsl.u8 q14, d18, d3
    vmlsl.u8 q15, d19, d3

    vqrshrun.s16 d4, q12, #6
    vqrshrun.s16 d5, q13, #6
    vqrshrun.s16 d6, q14, #6
    vqrshrun.s16 d7, q15, #6

    vst1.32 {q2}, [r2], r3
    vst1.32 {q3}, [r2], r3

    vmull.u8 q12, d16, d1
    vmull.u8 q13, d17, d1
    vmull.u8 q14, d18, d1
    vmull.u8 q15, d19, d1
    vmlsl.u8 q12, d8, d0
    vmlsl.u8 q13, d9, d0
    vmlsl.u8 q14, d16, d0
    vmlsl.u8 q15, d17, d0
    vmlal.u8 q12, d18, d2
    vmlal.u8 q13, d19, d2
    vmlal.u8 q14, d20, d2
    vmlal.u8 q15, d21, d2
    vmlsl.u8 q12, d20, d3
    vmlsl.u8 q13, d21, d3
    vmlsl.u8 q14, d22, d3
    vmlsl.u8 q15, d23, d3

    vqrshrun.s16 d24, q12, #6
    vqrshrun.s16 d25, q13, #6
    vqrshrun.s16 d26, q14, #6
    vqrshrun.s16 d27, q15, #6

    subs r5, r5, #4
    mov r0, r6
    vst1.32 {q12}, [r2], r3
    vst1.32 {q13}, [r2], r3
    bgt if_ver_chroma_w16_loop_y

    vpop {q4}
    pop  {r5-r6, pc}


//void uavs3d_if_ver_chroma_w32_armv7(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_chroma_w32_armv7
    push    {r5-r6, lr}
    vpush   {q4, q5, q6, q7}
    ldr r5, [sp, #80]
    ldr r6, [sp, #84]

    // load coeff
    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vdup.s8 d0, d8[0]
    vdup.s8 d1, d8[1]
    vdup.s8 d2, d8[2]
    vdup.s8 d3, d8[3]

    sub r0, r0, r1
if_ver_chroma_w32_loop_y:
    vld1.8 {q2, q3}, [r0], r1        // src + x - i_src
    vld1.8 {q4, q5}, [r0], r1        // src + x
    mov r6, r0
    vld1.8 {q6, q7}, [r0], r1        // src + x + i_src
    vld1.8 {q8, q9}, [r0], r1        // src + x + 2*i_src
    vld1.8 {q10, q11}, [r0]

    vmull.u8 q12, d8 , d1
    vmull.u8 q13, d9 , d1
    vmull.u8 q14, d10, d1
    vmull.u8 q15, d11, d1
    vmlsl.u8 q12, d4 , d0
    vmlsl.u8 q13, d5 , d0
    vmlsl.u8 q14, d6 , d0
    vmlsl.u8 q15, d7 , d0
    vmlal.u8 q12, d12, d2
    vmlal.u8 q13, d13, d2
    vmlal.u8 q14, d14, d2
    vmlal.u8 q15, d15, d2
    vmlsl.u8 q12, d16, d3
    vmlsl.u8 q13, d17, d3
    vmlsl.u8 q14, d18, d3
    vmlsl.u8 q15, d19, d3

    vqrshrun.s16 d4, q12, #6
    vqrshrun.s16 d5, q13, #6
    vqrshrun.s16 d6, q14, #6
    vqrshrun.s16 d7, q15, #6

    vst1.32 {q2, q3}, [r2], r3

    vmull.u8 q12, d12, d1
    vmull.u8 q13, d13, d1
    vmull.u8 q14, d14, d1
    vmull.u8 q15, d15, d1
    vmlsl.u8 q12, d8 , d0
    vmlsl.u8 q13, d9 , d0
    vmlsl.u8 q14, d10, d0
    vmlsl.u8 q15, d11, d0
    vmlal.u8 q12, d16, d2
    vmlal.u8 q13, d17, d2
    vmlal.u8 q14, d18, d2
    vmlal.u8 q15, d19, d2
    vmlsl.u8 q12, d20, d3
    vmlsl.u8 q13, d21, d3
    vmlsl.u8 q14, d22, d3
    vmlsl.u8 q15, d23, d3

    vqrshrun.s16 d24, q12, #6
    vqrshrun.s16 d25, q13, #6
    vqrshrun.s16 d26, q14, #6
    vqrshrun.s16 d27, q15, #6

    subs r5, r5, #2
    mov r0, r6
    vst1.32 {q12, q13}, [r2], r3
    bgt if_ver_chroma_w32_loop_y

    vpop {q4, q5, q6, q7}
    pop  {r5-r6, pc}


//void uavs3d_if_ver_chroma_w32x_armv7(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_chroma_w32x_armv7
    push    {r4-r8, lr}
    vpush   {q4, q5}

    ldr r4, [sp, #56]
    ldr r5, [sp, #60]
    ldr r6, [sp, #64]

    // load coeff
    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vdup.s8 d0, d8[0]
    vdup.s8 d1, d8[1]
    vdup.s8 d2, d8[2]
    vdup.s8 d3, d8[3]

    sub r0, r0, r1
if_ver_chroma_w32x_loop_y:
    mov r6, #0
    mov r8, r2
if_ver_chroma_w32x_loop_x:
    add r7, r0, r6
    vld1.8 {q2, q3}, [r7], r1       // src + x - i_src
    vld1.8 {q4, q5}, [r7], r1       // src + x
    vld1.8 {q8, q9}, [r7], r1       // src + x + i_src
    vld1.8 {q10, q11}, [r7]         // src + x + 2*i_src

    vmull.u8 q12, d8 , d1
    vmull.u8 q13, d9 , d1
    vmull.u8 q14, d10, d1
    vmull.u8 q15, d11, d1
    vmlsl.u8 q12, d4 , d0
    vmlsl.u8 q13, d5 , d0
    vmlsl.u8 q14, d6 , d0
    vmlsl.u8 q15, d7 , d0
    vmlal.u8 q12, d16, d2
    vmlal.u8 q13, d17, d2
    vmlal.u8 q14, d18, d2
    vmlal.u8 q15, d19, d2
    vmlsl.u8 q12, d20, d3
    vmlsl.u8 q13, d21, d3
    vmlsl.u8 q14, d22, d3
    vmlsl.u8 q15, d23, d3

    vqrshrun.s16 d24, q12, #6
    vqrshrun.s16 d25, q13, #6
    vqrshrun.s16 d26, q14, #6
    vqrshrun.s16 d27, q15, #6

    add r6, r6, #32
    vst1.32 {q12, q13}, [r8]!

    //--------------------------------
    // loop control
    //--------------------------------
    cmp r6, r4
    blt if_ver_chroma_w32x_loop_x
    subs r5, r5, #1
    add r0, r0, r1
    add r2, r2, r3
    bgt if_ver_chroma_w32x_loop_y

    vpop {q4, q5}
    pop  {r4-r8, pc}


//void uavs3d_if_ver_luma_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_luma_w4_armv7
    push    {r4-r11, lr}
    ldr r5, [sp, #40]
    ldr r6, [sp, #44]

    // load coeffs
    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, r1, lsl #1
    sub r0, r0, r1                      // src - 3*i_src

if_ver_luma_w4_loop_y:
    ldr r6 , [r0], r1
    ldr r7 , [r0], r1
    ldr r9 , [r0], r1
    ldr r10, [r0], r1
    mov r4 , r0                        // src += 4 * i_src
    ldr r11, [r0], r1
    vmov d16, r6, r7
    vmov d17, r7, r9
    vmov d18, r9, r10
    vmov d19, r10, r11
    ldr r6 , [r0], r1
    ldr r7 , [r0], r1
    ldr r9 , [r0], r1
    ldr r10, [r0], r1
    vmov d20, r11, r6
    vmov d21, r6, r7
    ldr r11, [r0], r1
    vmov d22, r7, r9
    ldr r6, [r0]
    vmov d23, r9, r10
    vmov d24, r10, r11
    vmov d25, r11, r6

    vmull.u8 q14, d17, d1               // src[-2 * i_src] * coeff[1]
    vmull.u8 q15, d19, d1
    vmlsl.u8 q14, d16, d0
    vmlsl.u8 q15, d18, d0
    vmlsl.u8 q14, d18, d2
    vmlsl.u8 q15, d20, d2
    vmlal.u8 q14, d19, d3               // src[0] * coeff[3]
    vmlal.u8 q15, d21, d3
    vmlal.u8 q14, d20, d4               // src[i_src] * coeff[4]
    vmlal.u8 q15, d22, d4
    vmlsl.u8 q14, d21, d5
    vmlsl.u8 q15, d23, d5
    vmlal.u8 q14, d22, d6
    vmlal.u8 q15, d24, d6
    vmlsl.u8 q14, d23, d7
    vmlsl.u8 q15, d25, d7

    //(sum + 32) >> 6
    vqrshrun.s16 d28, q14, #6
    vqrshrun.s16 d29, q15, #6

    subs r5, r5, #4
    mov r0, r4
    vst1.32 {d28[0]}, [r2], r3
    vst1.32 {d28[1]}, [r2], r3
    vst1.32 {d29[0]}, [r2], r3
    vst1.32 {d29[1]}, [r2], r3
    bgt if_ver_luma_w4_loop_y

    pop  {r4-r11, pc}


//void uavs3d_if_ver_luma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_luma_w8_armv7
    push    {r5-r6, lr}
    ldr r5, [sp, #16]
    ldr r6, [sp, #20]

    // load coeffs
    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, r1, lsl #1
    sub r0, r0, r1                      // src - 3*i_src

if_ver_luma_w8_loop_y:
    vld1.8 {d16}, [r0], r1             // x-3*i_src
    vld1.8 {d17}, [r0], r1             // x-2*i_src
    vld1.8 {d18}, [r0], r1             // x-i_src
    vld1.8 {d19}, [r0], r1             // x
    mov r6, r0
    vld1.8 {d20}, [r0], r1             // x+i_src
    vld1.8 {d21}, [r0], r1             // x+2*i_src
    vld1.8 {d22}, [r0], r1             // x+3*i_src
    vld1.8 {d23}, [r0], r1             // x+4*i_src
    vld1.8 {d24}, [r0], r1
    vld1.8 {d25}, [r0], r1
    vld1.8 {d26}, [r0]

    vmull.u8 q14, d17, d1
    vmull.u8 q15, d18, d1
    vmlsl.u8 q14, d16, d0
    vmlsl.u8 q15, d17, d0
    vmlsl.u8 q14, d18, d2
    vmlsl.u8 q15, d19, d2
    vmlal.u8 q14, d19, d3
    vmlal.u8 q15, d20, d3
    vmlal.u8 q14, d20, d4
    vmlal.u8 q15, d21, d4
    vmlsl.u8 q14, d21, d5
    vmlsl.u8 q15, d22, d5
    vmlal.u8 q14, d22, d6
    vmlal.u8 q15, d23, d6
    vmlsl.u8 q14, d23, d7
    vmlsl.u8 q15, d24, d7

    vqrshrun.s16 d16, q14, #6
    vqrshrun.s16 d17, q15, #6

    vmull.u8 q14, d19, d1
    vmull.u8 q15, d20, d1
    vmlsl.u8 q14, d18, d0
    vmlsl.u8 q15, d19, d0
    vmlsl.u8 q14, d20, d2
    vmlsl.u8 q15, d21, d2
    vst1.32 {d16}, [r2], r3
    vmlal.u8 q14, d21, d3
    vmlal.u8 q15, d22, d3
    vmlal.u8 q14, d22, d4
    vmlal.u8 q15, d23, d4
    vst1.32 {d17}, [r2], r3
    vmlsl.u8 q14, d23, d5
    vmlsl.u8 q15, d24, d5
    vmlal.u8 q14, d24, d6
    vmlal.u8 q15, d25, d6
    vmlsl.u8 q14, d25, d7
    vmlsl.u8 q15, d26, d7

    //(sum + 32) >> 6
    vqrshrun.s16 d28, q14, #6
    vqrshrun.s16 d29, q15, #6

    subs r5, r5, #4
    mov r0, r6
    vst1.32 {d28}, [r2], r3
    vst1.32 {d29}, [r2], r3
    bgt if_ver_luma_w8_loop_y

    pop  {r5-r6, pc}


//void uavs3d_if_ver_luma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_luma_w16_armv7
    push    {r5-r6, lr}
    vpush   {q4, q5}
    ldr r5, [sp, #48]
    ldr r6, [sp, #52]

    // load coeffs
    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, r1, lsl #1
    sub r0, r0, r1                  // src - 3*i_src

if_ver_luma_w16_loop_y:
    vld1.8 {q8}, [r0], r1           // x-3*i_src
    vld1.8 {q9}, [r0], r1           // x-2*i_src
    vld1.8 {q10}, [r0], r1          // x-i_src
    vld1.8 {q11}, [r0], r1          // x
    mov r6, r0
    vld1.8 {q12}, [r0], r1          // x+i_src
    vld1.8 {q13}, [r0], r1          // x+2*i_src
    vld1.8 {q14}, [r0], r1          // x+3*i_src
    vld1.8 {q15}, [r0], r1          // x+4*i_src

    vmull.u8 q4, d18, d1
    vmull.u8 q5, d19, d1
    vmlsl.u8 q4, d16, d0
    vmlsl.u8 q5, d17, d0
    vmlsl.u8 q4, d20, d2
    vmlsl.u8 q5, d21, d2
    vmlal.u8 q4, d22, d3
    vmlal.u8 q5, d23, d3
    vmlal.u8 q4, d24, d4
    vmlal.u8 q5, d25, d4
    vmlsl.u8 q4, d26, d5
    vmlsl.u8 q5, d27, d5
    vmlal.u8 q4, d28, d6
    vmlal.u8 q5, d29, d6
    vmlsl.u8 q4, d30, d7
    vmlsl.u8 q5, d31, d7

    vqrshrun.s16 d8, q4, #6
    vqrshrun.s16 d9, q5, #6
    vst1.32 {q4}, [r2], r3

    vld1.8 {q8}, [r0], r1

    vmull.u8 q4, d20, d1
    vmull.u8 q5, d21, d1
    vmlsl.u8 q4, d18, d0
    vmlsl.u8 q5, d19, d0
    vmlsl.u8 q4, d22, d2
    vmlsl.u8 q5, d23, d2
    vmlal.u8 q4, d24, d3
    vmlal.u8 q5, d25, d3
    vmlal.u8 q4, d26, d4
    vmlal.u8 q5, d27, d4
    vmlsl.u8 q4, d28, d5
    vmlsl.u8 q5, d29, d5
    vmlal.u8 q4, d30, d6
    vmlal.u8 q5, d31, d6
    vmlsl.u8 q4, d16, d7
    vmlsl.u8 q5, d17, d7

    vqrshrun.s16 d8, q4, #6
    vqrshrun.s16 d9, q5, #6
    vst1.32 {q4}, [r2], r3

    vld1.8 {q9}, [r0], r1
    vmull.u8 q4, d22, d1
    vmull.u8 q5, d23, d1
    vmlsl.u8 q4, d20, d0
    vmlsl.u8 q5, d21, d0
    vmlsl.u8 q4, d24, d2
    vmlsl.u8 q5, d25, d2
    vmlal.u8 q4, d26, d3
    vmlal.u8 q5, d27, d3
    vmlal.u8 q4, d28, d4
    vmlal.u8 q5, d29, d4
    vmlsl.u8 q4, d30, d5
    vmlsl.u8 q5, d31, d5
    vmlal.u8 q4, d16, d6
    vmlal.u8 q5, d17, d6
    vmlsl.u8 q4, d18, d7
    vmlsl.u8 q5, d19, d7

    vqrshrun.s16 d8, q4, #6
    vqrshrun.s16 d9, q5, #6
    vst1.32 {q4}, [r2], r3

    vld1.8 {q10}, [r0]
    vmull.u8 q4, d24, d1
    vmull.u8 q5, d25, d1
    vmlsl.u8 q4, d22, d0
    vmlsl.u8 q5, d23, d0
    vmlsl.u8 q4, d26, d2
    vmlsl.u8 q5, d27, d2
    vmlal.u8 q4, d28, d3
    vmlal.u8 q5, d29, d3
    vmlal.u8 q4, d30, d4
    vmlal.u8 q5, d31, d4
    vmlsl.u8 q4, d16, d5
    vmlsl.u8 q5, d17, d5
    vmlal.u8 q4, d18, d6
    vmlal.u8 q5, d19, d6
    vmlsl.u8 q4, d20, d7
    vmlsl.u8 q5, d21, d7

    vqrshrun.s16 d8, q4, #6
    vqrshrun.s16 d9, q5, #6
    subs r5, r5, #4
    mov r0, r6                     // src += i_src*4

    vst1.32 {q4}, [r2], r3
    bgt if_ver_luma_w16_loop_y

    vpop {q4, q5}
    pop  {r5-r6, pc}


//void uavs3d_if_ver_luma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_luma_w16x_armv7
    push    {r4-r8, lr}
    vpush   {q4, q5}
    ldr r4, [sp, #56]
    ldr r5, [sp, #60]
    ldr r6, [sp, #64]

    // load coeffs
    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, r1, lsl #1
    sub r0, r0, r1                  // src - 3*i_src

if_ver_luma_w16x_loop_y:
    mov r7, #0
    mov r6, r2
if_ver_luma_w16x_loop_x:
    add r8, r0, r7

    vld1.8 {q8}, [r8], r1           // x-3*i_src
    vld1.8 {q9}, [r8], r1           // x-2*i_src
    vld1.8 {q10}, [r8], r1          // x-i_src
    vld1.8 {q11}, [r8], r1          // x
    vld1.8 {q12}, [r8], r1          // x+i_src
    vld1.8 {q13}, [r8], r1          // x+2*i_src
    vld1.8 {q14}, [r8], r1          // x+3*i_src
    vld1.8 {q15}, [r8], r1          // x+4*i_src

    vmull.u8 q4, d18, d1
    vmull.u8 q5, d19, d1
    vmlsl.u8 q4, d16, d0
    vmlsl.u8 q5, d17, d0
    vmlsl.u8 q4, d20, d2
    vmlsl.u8 q5, d21, d2
    vmlal.u8 q4, d22, d3
    vmlal.u8 q5, d23, d3
    vmlal.u8 q4, d24, d4
    vmlal.u8 q5, d25, d4
    vmlsl.u8 q4, d26, d5
    vmlsl.u8 q5, d27, d5
    vmlal.u8 q4, d28, d6
    vmlal.u8 q5, d29, d6
    vmlsl.u8 q4, d30, d7
    vmlsl.u8 q5, d31, d7

    vqrshrun.s16 d8, q4, #6
    vqrshrun.s16 d9, q5, #6
    add r7, r7, #16
    vst1.32 {q4}, [r6]!

    cmp r7, r4
    blt if_ver_luma_w16x_loop_x

    subs r5, r5, #1
    add r0, r0, r1                  // src += i_src
    add r2, r2, r3
    bgt if_ver_luma_w16x_loop_y

    vpop {q4, q5}
    pop  {r4-r8, pc}


//void uavs3d_if_hor_ver_chroma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_chroma_w8_armv7
    push    {r4-r10, lr}
    add     sp, sp, #36
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #36

    // r10-->tmp
    mov r8, #36
    lsl r8, r8, #4
    sub r10, sp, r8                 // (32 + 4)*8*sizeof(short)
    sub r0, r0, r1                  // src += -1 * i_src;
    mov sp, r10

//--------------------------------
// HOR
//--------------------------------
    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vdup.s8 d0, d4[0]
    vdup.s8 d1, d4[1]
    vdup.s8 d2, d4[2]
    vdup.s8 d3, d4[3]
    sub r0, r0, #2                  // x - 1 UV

    //the first three rows
    vld1.8 {q13}, [r0], r1          // src[x-1]
    vld1.8 {q14}, [r0], r1          // src[x-1]
    vld1.8 {q15}, [r0], r1

    vext.i16 d20, d26, d27, #1      // src[x]
    vext.i16 d21, d26, d27, #2      // src[x+1]
    vext.i16 d22, d26, d27, #3      // src[x+2]

    vext.i16 d23, d28, d29, #1      // src[x]
    vext.i16 d24, d28, d29, #2      // src[x+1]
    vext.i16 d25, d28, d29, #3      // src[x+2]

    vext.i16 d18, d30, d31, #1      // src[x]
    vext.i16 d19, d30, d31, #2      // src[x+1]
    vext.i16 d27, d30, d31, #3      // src[x+2]

    vmull.u8 q2, d20, d1
    vmull.u8 q3, d23, d1
    vmull.u8 q8, d18, d1
    vmlsl.u8 q2, d26, d0
    vmlsl.u8 q3, d28, d0
    vmlsl.u8 q8, d30, d0
    vmlal.u8 q2, d21, d2
    vmlal.u8 q3, d24, d2
    vmlal.u8 q8, d19, d2
    vmlsl.u8 q2, d22, d3
    vmlsl.u8 q3, d25, d3
    vmlsl.u8 q8, d27, d3

    vst1.32 {q2, q3}, [r10]!
    vst1.32 {q8}, [r10]!

    // the next height rows
    mov r9, r5
if_hor_ver_chroma_w8_hor_loop_y:
    vld1.8 {q13}, [r0], r1          // src[x-1]
    vld1.8 {q14}, [r0], r1
    vld1.8 {q15}, [r0], r1

    vext.i16 d20, d26, d27, #1      // src[x]
    vext.i16 d21, d26, d27, #2      // src[x+1]
    vext.i16 d22, d26, d27, #3      // src[x+2]
    vext.i16 d23, d28, d29, #1      // src[x]
    vext.i16 d24, d28, d29, #2      // src[x+1]
    vext.i16 d25, d28, d29, #3      // src[x+2]

    vld1.8 {q8}, [r0], r1           // src[x-1]

    vmull.u8 q2, d20, d1
    vmull.u8 q3, d23, d1
    vmlsl.u8 q2, d26, d0
    vmlsl.u8 q3, d28, d0
    vmlal.u8 q2, d21, d2
    vmlal.u8 q3, d24, d2
    vmlsl.u8 q2, d22, d3
    vmlsl.u8 q3, d25, d3

    vext.i16 d24, d30, d31, #1      // src[x]
    vext.i16 d25, d30, d31, #2      // src[x+1]
    vext.i16 d26, d30, d31, #3      // src[x+2]
    vext.i16 d27, d16, d17, #1      // src[x]
    vext.i16 d28, d16, d17, #2      // src[x+1]
    vext.i16 d29, d16, d17, #3      // src[x+2]

    vmull.u8 q10, d24, d1
    vmull.u8 q11, d27, d1
    vmlsl.u8 q10, d30, d0
    vmlsl.u8 q11, d16, d0
    vmlal.u8 q10, d25, d2
    vmlal.u8 q11, d28, d2
    vmlsl.u8 q10, d26, d3
    vmlsl.u8 q11, d29, d3

    subs r9, r9, #4
    vst1.64 {q2, q3}, [r10]!
    vst1.64 {q10, q11}, [r10]!
    bgt if_hor_ver_chroma_w8_hor_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r6, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_chroma_w8_ver_loop_y:
    vld1.32 {q8, q9}, [r6]!
    vld1.32 {q10, q11}, [r6]!
    mov r10, r6
    vld1.32 {q2, q3}, [r6]!
    vld1.32 {q1}, [r6]

    vmull.s16 q12, d16, d0[0]
    vmull.s16 q13, d17, d0[0]
    vmull.s16 q14, d18, d0[0]
    vmull.s16 q15, d19, d0[0]
    vmlal.s16 q12, d18, d0[1]
    vmlal.s16 q13, d19, d0[1]
    vmlal.s16 q14, d20, d0[1]
    vmlal.s16 q15, d21, d0[1]
    vmlal.s16 q12, d20, d0[2]
    vmlal.s16 q13, d21, d0[2]
    vmlal.s16 q14, d22, d0[2]
    vmlal.s16 q15, d23, d0[2]
    vmlal.s16 q12, d22, d0[3]
    vmlal.s16 q13, d23, d0[3]
    vmlal.s16 q14, d4, d0[3]
    vmlal.s16 q15, d5, d0[3]

    vrshrn.s32 d24, q12, #12
    vrshrn.s32 d25, q13, #12
    vrshrn.s32 d26, q14, #12
    vrshrn.s32 d27, q15, #12

    vmull.s16 q8 , d20, d0[0]
    vmull.s16 q9 , d21, d0[0]
    vmull.s16 q14, d22, d0[0]
    vmull.s16 q15, d23, d0[0]
    vmlal.s16 q8 , d22, d0[1]
    vmlal.s16 q9 , d23, d0[1]
    vmlal.s16 q14, d4, d0[1]
    vmlal.s16 q15, d5, d0[1]
    vmlal.s16 q8 , d4, d0[2]
    vmlal.s16 q9 , d5, d0[2]
    vmlal.s16 q14, d6, d0[2]
    vmlal.s16 q15, d7, d0[2]
    vmlal.s16 q8 , d6, d0[3]
    vmlal.s16 q9 , d7, d0[3]
    vmlal.s16 q14, d2, d0[3]
    vmlal.s16 q15, d3, d0[3]

    vrshrn.s32 d16, q8, #12
    vrshrn.s32 d17, q9, #12
    vrshrn.s32 d18, q14, #12
    vrshrn.s32 d19, q15, #12

    vqmovun.s16 d24, q12            // 16bit to 8bit
    vqmovun.s16 d25, q13
    vqmovun.s16 d26, q8             // 16bit to 8bit
    vqmovun.s16 d27, q9

    subs r5, r5, #4
    mov r6, r10
    vst1.32 {d24}, [r2], r3
    vst1.32 {d25}, [r2], r3
    vst1.32 {d26}, [r2], r3
    vst1.32 {d27}, [r2], r3
    bgt if_hor_ver_chroma_w8_ver_loop_y

    add sp, sp, r8                  // (32 + 4)*8*sizeof(short)

    pop  {r4-r10, pc}

//void uavs3d_if_hor_ver_chroma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8n 0- *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_chroma_w16_armv7
    push    {r5-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #28
    vpush   {q4, q5}

    // r9-->tmp
    mov r8, #68
    lsl r8, r8, #5
    sub r9, sp, r8                        // (64 + 4)*16*sizeof(short)
    mov sp, r9

    sub r0, r0, r1                          // src += -1 * i_src;
//--------------------------------
// HOR
//--------------------------------
    vld1.32  {d4[0]}, [r6]
    vabs.s8 d4, d4
    vdup.s8 d0, d4[0]
    vdup.s8 d1, d4[1]
    vdup.s8 d2, d4[2]
    vdup.s8 d3, d4[3]
    sub r0, r0, #2                          // x - 1 UV

    //the first three rows
    vld1.8 {q2, q3}, [r0], r1       // src[x-1]

    vext.i16 q13, q2, q3, #1       // src[x]
    vext.i16 q14, q2, q3, #2       // src[x+1]
    vext.i16 q15, q2, q3, #3       // src[x+2]

    vmull.u8 q8, d26, d1
    vmull.u8 q9, d27, d1
    vmlsl.u8 q8, d4 , d0
    vmlsl.u8 q9, d5 , d0
    vmlal.u8 q8, d28, d2
    vmlal.u8 q9, d29, d2
    vmlsl.u8 q8, d30, d3
    vmlsl.u8 q9, d31, d3

    vst1.32 {q8, q9}, [r9]!

    add r6, r5, #2
if_hor_ver_chroma_w16_hor_loop_y:
    vld1.8 {q10, q11}, [r0], r1     // src[x-1]
    vld1.8 {q12, q13}, [r0], r1

    vext.i16 q2, q10, q11, #1       // src[x]
    vext.i16 q3, q10, q11, #2       // src[x+1]
    vext.i16 q8, q10, q11, #3       // src[x+2]

    vmull.u8 q14, d4, d1
    vmull.u8 q15, d5, d1
    vmlsl.u8 q14, d20, d0
    vmlsl.u8 q15, d21, d0
    vmlal.u8 q14, d6, d2
    vmlal.u8 q15, d7, d2
    vmlsl.u8 q14, d16, d3
    vmlsl.u8 q15, d17, d3

    vext.i16 q2, q12, q13, #1       // src[x]
    vext.i16 q3, q12, q13, #2       // src[x+1]
    vext.i16 q8, q12, q13, #3       // src[x+2]

    vst1.64 {q14, q15}, [r9]!

    vmull.u8 q10, d4, d1
    vmull.u8 q11, d5, d1
    vmlsl.u8 q10, d24, d0
    vmlsl.u8 q11, d25, d0
    vmlal.u8 q10, d6, d2
    vmlal.u8 q11, d7, d2
    vmlsl.u8 q10, d16, d3
    vmlsl.u8 q11, d17, d3

    subs r6, r6, #2
    vst1.64 {q10, q11}, [r9]!
    bgt if_hor_ver_chroma_w16_hor_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r9, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_chroma_w16_ver_loop_y:
    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    mov r7, r9
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vld1.64 {q8, q9}, [r9]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d2, q2               // 16bit to 8bit
    vqmovun.s16 d3, q3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d24, d0[1]
    vmlal.s16 q3, d25, d0[1]
    vmlal.s16 q4, d26, d0[1]
    vmlal.s16 q5, d27, d0[1]
    vmlal.s16 q2, d28, d0[2]
    vmlal.s16 q3, d29, d0[2]
    vmlal.s16 q4, d30, d0[2]
    vmlal.s16 q5, d31, d0[2]
    vmlal.s16 q2, d16, d0[3]
    vmlal.s16 q3, d17, d0[3]
    vmlal.s16 q4, d18, d0[3]
    vmlal.s16 q5, d19, d0[3]

    vst1.32 {q1}, [r2], r3
    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d4, q2              // 16bit to 8bit
    vqmovun.s16 d5, q3

    subs r5, r5, #2
    mov r9, r7                    // tmp += 64;
    vst1.32 {q2}, [r2], r3
    bgt if_hor_ver_chroma_w16_ver_loop_y

    add sp, sp, r8                  // (64 + 4)*16*sizeof(short)

    vpop {q4, q5}
    pop  {r5-r9, pc}


//void uavs3d_if_hor_ver_chroma_w16x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8n 0- *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_chroma_w16x_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #36
    vpush   {q4, q5}

    // r11-->tmp
    mov r8, #68
    lsl r8, r8, #8
    sub r11, sp, r8                 // (64 + 4)*128*sizeof(short)
    mov sp, r11

    sub r0, r0, r1                  // src += -1 * i_src;
//--------------------------------
// HOR
//--------------------------------
    vld1.32  {d4[0]}, [r6]
    vabs.s8 d4, d4
    vdup.s8 d0, d4[0]
    vdup.s8 d1, d4[1]
    vdup.s8 d2, d4[2]
    vdup.s8 d3, d4[3]
    sub r0, r0, #2                  // x - 1 UV

    add r8, r5, #3                  // i
if_hor_ver_chroma_w16x_hor_loop_y:
    mov r10, r0
    mov r9, r4                      // j
if_hor_ver_chroma_w16x_hor_loop_x:
    vld1.8 {q10, q11}, [r10]         // src[x-1]

    vext.i16 q2, q10, q11, #1       // src[x]
    vext.i16 q3, q10, q11, #2       // src[x+1]
    vext.i16 q8, q10, q11, #3       // src[x+2]

    vmull.u8 q14, d4, d1
    vmull.u8 q15, d5, d1
    vmlsl.u8 q14, d20, d0
    vmlsl.u8 q15, d21, d0
    vmlal.u8 q14, d6, d2
    vmlal.u8 q15, d7, d2
    vmlsl.u8 q14, d16, d3
    vmlsl.u8 q15, d17, d3

    subs r9, r9, #16
    add  r10, r10, #16
    vst1.64 {q14, q15}, [r11]!
    bgt if_hor_ver_chroma_w16x_hor_loop_x
    subs r8, r8, #1
    add r0, r0, r1
    bgt if_hor_ver_chroma_w16x_hor_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r11, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    lsl r6, r4, #1                  // tmp_stride = width*2
if_hor_ver_chroma_w16x_ver_loop_y:
    mov r9, #0
if_hor_ver_chroma_w16x_ver_loop_x:
    add r10, r11, r9, lsl #1
    add r7, r2, r9
    vld1.64 {q8, q9}, [r10], r6
    vld1.64 {q10, q11}, [r10], r6
    vld1.64 {q12, q13}, [r10], r6
    vld1.64 {q14, q15}, [r10], r6

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vld1.64 {q8, q9}, [r10]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d2, q2               // 16bit to 8bit
    vqmovun.s16 d3, q3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d24, d0[1]
    vmlal.s16 q3, d25, d0[1]
    vmlal.s16 q4, d26, d0[1]
    vmlal.s16 q5, d27, d0[1]
    vmlal.s16 q2, d28, d0[2]
    vmlal.s16 q3, d29, d0[2]
    vmlal.s16 q4, d30, d0[2]
    vmlal.s16 q5, d31, d0[2]
    vmlal.s16 q2, d16, d0[3]
    vmlal.s16 q3, d17, d0[3]
    vmlal.s16 q4, d18, d0[3]
    vmlal.s16 q5, d19, d0[3]

    vst1.32 {q1}, [r7], r3
    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d4, q2              // 16bit to 8bit
    vqmovun.s16 d5, q3

    add r9, r9, #16
    vst1.32 {q2}, [r7]
    cmp r9, r4
    blt if_hor_ver_chroma_w16x_ver_loop_x

    subs r5, r5, #2
    add r11, r11, r6, lsl #1        // tmp += 64;
    add r2, r2, r3, lsl #1
    bgt if_hor_ver_chroma_w16x_ver_loop_y

    mov r7, #68
    lsl r7, r7, #8
    add sp, sp, r7                  // (64 + 4)*128*sizeof(short)

    vpop {q4, q5}
    pop  {r4-r11, pc}


//void uavs3d_if_hor_ver_luma_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w4_armv7
    push    {r5-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #28

    // r9-->tmp
    ldr r8, =320                        // (32 + 8) * 4 * sizeof(short)
    sub r9, sp, r8
    mov sp,  r9

    sub r0, r0, r1, lsl #1              // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                      // src -= 3
//--------------------------------
// HOR
//--------------------------------
    vld1.8 {q12}, [r0], r1              // src[x-3]
    vld1.8 {q13}, [r0], r1
    vld1.8 {q14}, [r0], r1

    // 00, 10, 01, 11 ...
    // 08, 18, 09, 19 ...
    // 20, 30, 21, 31 ...
    // 28, 38, 29, 39 ...
    vzip.8  q12, q13
    vzip.8  q14, q15

    // 00, 10, 20, 30, 01, 11, 21, 31 ...
    // 04, 14, 24, 34 ...
    // 08, 18, 28, 38 ...
    vzip.16 q12, q14
    vzip.16 q13, q15

    vext.i32 q6, q12, q14, #1
    vext.i32 q7, q12, q14, #2
    vext.i32 q8, q12, q14, #3

    vext.i32 q9 , q14, q13, #1
    vext.i32 q10, q14, q13, #2
    vext.i32 q11, q14, q13, #3

    vmull.u8 q13, d12, d1
    vmull.u8 q15, d13, d1
    vmlsl.u8 q13, d24, d0
    vmlsl.u8 q15, d25, d0
    vmlsl.u8 q13, d14, d2
    vmlsl.u8 q15, d15, d2
    vmlal.u8 q13, d16, d3
    vmlal.u8 q15, d17, d3
    vmlal.u8 q13, d28, d4
    vmlal.u8 q15, d29, d4
    vmlsl.u8 q13, d18, d5
    vmlsl.u8 q15, d19, d5
    vmlal.u8 q13, d20, d6
    vmlal.u8 q15, d21, d6
    vmlsl.u8 q13, d22, d7               // 00, 10, 20, 30, 01, 11, 21, 31
    vmlsl.u8 q15, d23, d7               // 02, 12, 22, 32, 03, 13, 23, 33

    vuzp.16 q13, q15
    vuzp.16 q13, q15

    vst1.32 {q13}, [r9]!
    vst1.32 {d30}, [r9]!

    add r6, r5, #4                      // loop height+6 times
if_hor_ver_luma_w4_hor_loop_y:
    vld1.8 {q12}, [r0], r1              // src[x-3]
    vld1.8 {q13}, [r0], r1
    vld1.8 {q14}, [r0], r1
    vld1.8 {q15}, [r0], r1

    // 00, 10, 01, 11 ...
    // 08, 18, 09, 19 ...
    // 20, 30, 21, 31 ...
    // 28, 38, 29, 39 ...
    vzip.8 q12, q13
    vzip.8 q14, q15

    // 00, 10, 20, 30, 01, 11, 21, 31 ...
    // 04, 14, 24, 34 ...
    // 08, 18, 28, 38 ...
    vzip.16 q12, q14
    vzip.16 q13, q15

    vext.i32 q6, q12, q14, #1
    vext.i32 q7, q12, q14, #2
    vext.i32 q8, q12, q14, #3

    vext.i32 q9 , q14, q13, #1
    vext.i32 q10, q14, q13, #2
    vext.i32 q11, q14, q13, #3

    vmull.u8 q13, d12, d1
    vmull.u8 q15, d13, d1
    vmlsl.u8 q13, d24, d0
    vmlsl.u8 q15, d25, d0
    vmlsl.u8 q13, d14, d2
    vmlsl.u8 q15, d15, d2
    vmlal.u8 q13, d16, d3
    vmlal.u8 q15, d17, d3
    vmlal.u8 q13, d28, d4
    vmlal.u8 q15, d29, d4
    vmlsl.u8 q13, d18, d5
    vmlsl.u8 q15, d19, d5
    vmlal.u8 q13, d20, d6
    vmlal.u8 q15, d21, d6
    vmlsl.u8 q13, d22, d7               // 00, 10, 20, 30, 01, 11, 21, 31
    vmlsl.u8 q15, d23, d7               // 02, 12, 22, 32, 03, 13, 23, 33

    vuzp.16 q13, q15
    vuzp.16 q13, q15

    subs r6, r6, #4
    vst1.32 {q13}, [r9]!
    vst1.32 {q15}, [r9]!
    bgt if_hor_ver_luma_w4_hor_loop_y

    mov r9, sp

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.32 {d0}, [r7]                 // load coeff
    vmovl.s8 q0, d0                   // 8bit to 16bit

if_hor_ver_luma_w4_ver_loop_y:
    vld1.64 {q10, q11}, [r9]!
    vmull.s16 q12, d20, d0[0]
    vmull.s16 q13, d21, d0[0]
    vmull.s16 q14, d22, d0[0]
    vmull.s16 q15, d23, d0[0]
    mov r7, r9
    vld1.64 {q2, q3}, [r9]!
    vmlal.s16 q12, d21, d0[1]
    vmlal.s16 q13, d22, d0[1]
    vmlal.s16 q14, d23, d0[1]
    vmlal.s16 q15, d4 , d0[1]

    vmlal.s16 q12, d22, d0[2]
    vmlal.s16 q13, d23, d0[2]
    vmlal.s16 q14, d4, d0[2]
    vmlal.s16 q15, d5, d0[2]

    vmlal.s16 q12, d23, d0[3]
    vmlal.s16 q13, d4, d0[3]
    vmlal.s16 q14, d5, d0[3]
    vmlal.s16 q15, d6, d0[3]

    vmlal.s16 q12, d4, d1[0]
    vmlal.s16 q13, d5, d1[0]
    vmlal.s16 q14, d6, d1[0]
    vmlal.s16 q15, d7, d1[0]

    vld1.64 {q1}, [r9]!
    vmlal.s16 q12, d5, d1[1]
    vmlal.s16 q13, d6, d1[1]
    vmlal.s16 q14, d7, d1[1]
    vmlal.s16 q15, d2, d1[1]

    vld1.64 {d16}, [r9]
    vmlal.s16 q12, d6, d1[2]
    vmlal.s16 q13, d7, d1[2]
    vmlal.s16 q14, d2, d1[2]
    vmlal.s16 q15, d3, d1[2]

    vmlal.s16 q12, d7, d1[3]
    vmlal.s16 q13, d2, d1[3]
    vmlal.s16 q14, d3, d1[3]
    vmlal.s16 q15, d16, d1[3]

    vrshrn.s32 d24, q12, #12
    vrshrn.s32 d25, q13, #12
    vrshrn.s32 d26, q14, #12
    vrshrn.s32 d27, q15, #12

    vqmovun.s16 d24, q12             //16bit to 8bit
    vqmovun.s16 d25, q13

    subs r5, r5, #4
    mov r9, r7
    vst1.32 {d24[0]}, [r2], r3
    vst1.32 {d24[1]}, [r2], r3
    vst1.32 {d25[0]}, [r2], r3
    vst1.32 {d25[1]}, [r2], r3
    bgt if_hor_ver_luma_w4_ver_loop_y

    add sp, sp, r8

    pop  {r5-r9, pc}


//void uavs3d_if_hor_ver_luma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w8_armv7
    push    {r5-r9, lr}
    vpush   {q4, q5}
    add     sp, sp, #60
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #60

    // 9-->tmp
    mov r8, #72                         // (64 + 8) * 8 * sizeof(short)
    lsl r8, r8, #4
    sub r9, sp, r8
    mov sp,  r9

    sub r0, r0, r1, lsl #1              // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                      // src -= 3
//--------------------------------
// HOR
//--------------------------------
    vld1.8 {q8}, [r0], r1
    vext.i8 d18, d16, d17, #1
    vext.i8 d19, d16, d17, #2
    vext.i8 d20, d16, d17, #3
    vext.i8 d21, d16, d17, #4
    vext.i8 d22, d16, d17, #5
    vext.i8 d23, d16, d17, #6
    vext.i8 d24, d16, d17, #7

    vmull.u8 q15, d18, d1
    vmlsl.u8 q15, d16, d0
    vmlsl.u8 q15, d19, d2
    vmlal.u8 q15, d20, d3
    vmlal.u8 q15, d21, d4
    vmlsl.u8 q15, d22, d5
    vmlal.u8 q15, d23, d6
    vmlsl.u8 q15, d24, d7

    vst1.64 {q15}, [r9]!

    add r6, r5, #6
if_hor_ver_luma_w8_hor_loop_y:
    vld1.8 {q8}, [r0], r1             // src[x-3]
    vld1.8 {q9}, [r0], r1
    vzip.8 q8, q9

    vext.i16 q10, q8, q9, #1
    vext.i16 q11, q8, q9, #2
    vext.i16 q12, q8, q9, #3
    vext.i16 q13, q8, q9, #4
    vext.i16 q14, q8, q9, #5
    vext.i16 q15, q8, q9, #6
    vext.i16 q9, q8, q9, #7

    vmull.u8 q4, d20, d1
    vmull.u8 q5, d21, d1
    vmlsl.u8 q4, d16, d0
    vmlsl.u8 q5, d17, d0
    vmlsl.u8 q4, d22, d2
    vmlsl.u8 q5, d23, d2
    vmlal.u8 q4, d24, d3
    vmlal.u8 q5, d25, d3
    vmlal.u8 q4, d26, d4
    vmlal.u8 q5, d27, d4
    vmlsl.u8 q4, d28, d5
    vmlsl.u8 q5, d29, d5
    vmlal.u8 q4, d30, d6
    vmlal.u8 q5, d31, d6
    vmlsl.u8 q4, d18, d7
    vmlsl.u8 q5, d19, d7

    vuzp.16 q4, q5

    subs r6, r6, #2
    vst1.64 {q4, q5}, [r9]!
    bgt if_hor_ver_luma_w8_hor_loop_y

    mov r9, sp

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8   {d0}, [r7]             // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_luma_w8_ver_loop_y:
    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    mov r7, r9
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!
    vld1.64 {q1}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d18, d0[1]
    vmlal.s16 q3, d19, d0[1]
    vmlal.s16 q4, d20, d0[1]
    vmlal.s16 q5, d21, d0[1]
    vmlal.s16 q2, d20, d0[2]
    vmlal.s16 q3, d21, d0[2]
    vmlal.s16 q4, d22, d0[2]
    vmlal.s16 q5, d23, d0[2]
    vmlal.s16 q2, d22, d0[3]
    vmlal.s16 q3, d23, d0[3]
    vmlal.s16 q4, d24, d0[3]
    vmlal.s16 q5, d25, d0[3]

    vld1.64 {q8, q9}, [r9]
    vmlal.s16 q2, d24, d1[0]
    vmlal.s16 q3, d25, d1[0]
    vmlal.s16 q4, d26, d1[0]
    vmlal.s16 q5, d27, d1[0]
    vmlal.s16 q2, d26, d1[1]
    vmlal.s16 q3, d27, d1[1]
    vmlal.s16 q4, d28, d1[1]
    vmlal.s16 q5, d29, d1[1]
    vmlal.s16 q2, d28, d1[2]
    vmlal.s16 q3, d29, d1[2]
    vmlal.s16 q4, d30, d1[2]
    vmlal.s16 q5, d31, d1[2]
    vmlal.s16 q2, d30, d1[3]
    vmlal.s16 q3, d31, d1[3]
    vmlal.s16 q4, d2, d1[3]
    vmlal.s16 q5, d3, d1[3]

    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d4, q2               // 16bit to 8bit
    vqmovun.s16 d5, q3

    vst1.32 {d4}, [r2], r3
    vst1.32 {d5}, [r2], r3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d22, d0[1]
    vmlal.s16 q3, d23, d0[1]
    vmlal.s16 q4, d24, d0[1]
    vmlal.s16 q5, d25, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d26, d0[3]
    vmlal.s16 q3, d27, d0[3]
    vmlal.s16 q4, d28, d0[3]
    vmlal.s16 q5, d29, d0[3]
    vmlal.s16 q2, d28, d1[0]
    vmlal.s16 q3, d29, d1[0]
    vmlal.s16 q4, d30, d1[0]
    vmlal.s16 q5, d31, d1[0]
    vmlal.s16 q2, d30, d1[1]
    vmlal.s16 q3, d31, d1[1]
    vmlal.s16 q4, d2 , d1[1]
    vmlal.s16 q5, d3 , d1[1]
    vmlal.s16 q2, d2 , d1[2]
    vmlal.s16 q3, d3 , d1[2]
    vmlal.s16 q4, d16, d1[2]
    vmlal.s16 q5, d17, d1[2]
    vmlal.s16 q2, d16, d1[3]
    vmlal.s16 q3, d17, d1[3]
    vmlal.s16 q4, d18, d1[3]
    vmlal.s16 q5, d19, d1[3]

    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d4, q2               // 16bit to 8bit
    vqmovun.s16 d5, q3

    subs r5, r5, #4
    mov r9, r7
    vst1.32 {d4}, [r2], r3
    vst1.32 {d5}, [r2], r3
    bgt if_hor_ver_luma_w8_ver_loop_y

    add sp, sp, r8

    vpop {q4, q5}
    pop  {r5-r9, pc}


//void uavs3d_if_hor_ver_luma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w16_armv7
    push    {r5-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #28
    vpush   {q4, q5}

    // r9-->tmp
    mov r8, #136                            // (128 + 8) * 16 * sizeof(short)
    lsl r8, r8, #5
    sub r9, sp, r8
    mov sp, r9

    sub r0, r0, r1, lsl #1                  // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                      // src -= 3
//--------------------------------
// HOR
//--------------------------------

    add r6, r5, #7
if_hor_ver_luma_w16_hor_loop_y:
    vld1.8 {q8, q9}, [r0], r1           // src[x-3]

    vext.i8 q10, q8, q9, #1
    vext.i8 q11, q8, q9, #2
    vext.i8 q12, q8, q9, #3
    vext.i8 q13, q8, q9, #4
    vext.i8 q14, q8, q9, #5
    vext.i8 q15, q8, q9, #6
    vext.i8 q9, q8, q9, #7

    vmull.u8 q4, d20, d1
    vmull.u8 q5, d21, d1
    vmlsl.u8 q4, d16, d0
    vmlsl.u8 q5, d17, d0
    vmlsl.u8 q4, d22, d2
    vmlsl.u8 q5, d23, d2
    vmlal.u8 q4, d24, d3
    vmlal.u8 q5, d25, d3
    vmlal.u8 q4, d26, d4
    vmlal.u8 q5, d27, d4
    vmlsl.u8 q4, d28, d5
    vmlsl.u8 q5, d29, d5
    vmlal.u8 q4, d30, d6
    vmlal.u8 q5, d31, d6
    vmlsl.u8 q4, d18, d7
    vmlsl.u8 q5, d19, d7

    subs r6, r6, #1
    vst1.64 {q4, q5}, [r9]!
    bgt if_hor_ver_luma_w16_hor_loop_y

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8 {d0}, [r7]               // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    mov r9, sp                      // tmp
if_hor_ver_luma_w16_ver_loop_y:
    vld1.64 {q8, q9}, [r9]!
    mov r7, r9
    vld1.64 {q10, q11}, [r9]!
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]

    vmlal.s16 q2, d16, d1[0]
    vmlal.s16 q3, d17, d1[0]
    vmlal.s16 q4, d18, d1[0]
    vmlal.s16 q5, d19, d1[0]
    vmlal.s16 q2, d20, d1[1]
    vmlal.s16 q3, d21, d1[1]
    vmlal.s16 q4, d22, d1[1]
    vmlal.s16 q5, d23, d1[1]
    vmlal.s16 q2, d24, d1[2]
    vmlal.s16 q3, d25, d1[2]
    vmlal.s16 q4, d26, d1[2]
    vmlal.s16 q5, d27, d1[2]
    vmlal.s16 q2, d28, d1[3]
    vmlal.s16 q3, d29, d1[3]
    vmlal.s16 q4, d30, d1[3]
    vmlal.s16 q5, d31, d1[3]

    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d4, q2
    vqmovun.s16 d5, q3

    subs r5, r5, #1
    mov r9, r7
    vst1.64 {q2}, [r2], r3
    bgt if_hor_ver_luma_w16_ver_loop_y

    add sp, sp, r8

    vpop {q4, q5}
    pop  {r5-r9, pc}


//void uavs3d_if_hor_ver_luma_w16x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w16x_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #36
    vpush   {q4, q5}

    // r9-->tmp
    mov r8, #136                        // (128 + 8) * 128 * sizeof(short)
    lsl r8, r8, #8
    sub r9, sp, r8
    mov sp, r9

    sub r0, r0, r1, lsl #1              // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.s8 d0, d7[0]
    vdup.s8 d1, d7[1]
    vdup.s8 d2, d7[2]
    vdup.s8 d3, d7[3]
    vdup.s8 d4, d7[4]
    vdup.s8 d5, d7[5]
    vdup.s8 d6, d7[6]
    vdup.s8 d7, d7[7]

    sub r0, r0, #3                      // src -= 3
//--------------------------------
// HOR
//--------------------------------

    add r11, r5, #7
if_hor_ver_luma_w16x_hor_loop_y:
    mov r6, r4
    mov r10, r0
if_hor_ver_luma_w16x_hor_loop_x:
    vld1.8 {q8, q9}, [r10]              // src[x-3]

    vext.i8 q10, q8, q9, #1
    vext.i8 q11, q8, q9, #2
    vext.i8 q12, q8, q9, #3
    vext.i8 q13, q8, q9, #4
    vext.i8 q14, q8, q9, #5
    vext.i8 q15, q8, q9, #6
    vext.i8 q9, q8, q9, #7

    vmull.u8 q4, d20, d1
    vmull.u8 q5, d21, d1
    vmlsl.u8 q4, d16, d0
    vmlsl.u8 q5, d17, d0
    vmlsl.u8 q4, d22, d2
    vmlsl.u8 q5, d23, d2
    vmlal.u8 q4, d24, d3
    vmlal.u8 q5, d25, d3
    vmlal.u8 q4, d26, d4
    vmlal.u8 q5, d27, d4
    vmlsl.u8 q4, d28, d5
    vmlsl.u8 q5, d29, d5
    vmlal.u8 q4, d30, d6
    vmlal.u8 q5, d31, d6
    vmlsl.u8 q4, d18, d7
    vmlsl.u8 q5, d19, d7

    subs r6, r6, #16
    add  r10, r10, #16
    vst1.64 {q4, q5}, [r9]!
    bgt if_hor_ver_luma_w16x_hor_loop_x

    subs r11, r11, #1
    add r0, r0, r1
    bgt if_hor_ver_luma_w16x_hor_loop_y

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8 {d0}, [r7]               // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    mov r9, sp                      // tmp
    lsl r11, r4, #1                 // tmpstride
if_hor_ver_luma_w16x_ver_loop_y:
    mov r6, #0
    mov r10, r2
if_hor_ver_luma_w16x_ver_loop_x:
    add r7, r9, r6, lsl #1
    vld1.64 {q8, q9}, [r7], r11
    vld1.64 {q10, q11}, [r7], r11
    vld1.64 {q12, q13}, [r7], r11
    vld1.64 {q14, q15}, [r7], r11

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vld1.64 {q8, q9}, [r7], r11
    vld1.64 {q10, q11}, [r7], r11
    vld1.64 {q12, q13}, [r7], r11
    vld1.64 {q14, q15}, [r7]

    vmlal.s16 q2, d16, d1[0]
    vmlal.s16 q3, d17, d1[0]
    vmlal.s16 q4, d18, d1[0]
    vmlal.s16 q5, d19, d1[0]
    vmlal.s16 q2, d20, d1[1]
    vmlal.s16 q3, d21, d1[1]
    vmlal.s16 q4, d22, d1[1]
    vmlal.s16 q5, d23, d1[1]
    vmlal.s16 q2, d24, d1[2]
    vmlal.s16 q3, d25, d1[2]
    vmlal.s16 q4, d26, d1[2]
    vmlal.s16 q5, d27, d1[2]
    vmlal.s16 q2, d28, d1[3]
    vmlal.s16 q3, d29, d1[3]
    vmlal.s16 q4, d30, d1[3]
    vmlal.s16 q5, d31, d1[3]

    vrshrn.s32 d4, q2, #12
    vrshrn.s32 d5, q3, #12
    vrshrn.s32 d6, q4, #12
    vrshrn.s32 d7, q5, #12

    vqmovun.s16 d4, q2
    vqmovun.s16 d5, q3
    add r6, r6, #16
    vst1.64 {q2}, [r10]!

    cmp r6, r4
    blt if_hor_ver_luma_w16x_ver_loop_x
    subs r5, r5, #1
    add r2, r2, r3
    add r9, r9, r11
    bgt if_hor_ver_luma_w16x_ver_loop_y

    add sp, sp, r8

    vpop {q4, q5}
    pop  {r4-r11, pc}

#else
//void uavs3d_if_cpy_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w4_armv7
    push {r4, r5, lr}
    ldr r4, [sp, #12]
    ldr r5, [sp, #16]

    lsl r1, r1, #1
    lsl r3, r3, #1
if_cpy_w4_loop_y:
    vld1.64 {d0}, [r0], r1
    vld1.64 {d1}, [r0], r1
    vld1.64 {d2}, [r0], r1
    vld1.64 {d3}, [r0], r1
    subs r5, r5, #4
    vst1.64 {d0}, [r2], r3
    vst1.64 {d1}, [r2], r3
    vst1.64 {d2}, [r2], r3
    vst1.64 {d3}, [r2], r3
    bgt if_cpy_w4_loop_y

    pop {r4, r5, pc}

//void uavs3d_if_cpy_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w8_armv7
    push {r4, r5, lr}
    ldr r4, [sp, #12]
    ldr r5, [sp, #16]

    lsl r1, r1, #1
    lsl r3, r3, #1
if_cpy_w8_loop_y:
    vld1.64 {q0}, [r0], r1
    vld1.64 {q1}, [r0], r1
    vld1.64 {q2}, [r0], r1
    vld1.64 {q3}, [r0], r1
    subs r5, r5, #4
    vst1.64 {q0}, [r2], r3
    vst1.64 {q1}, [r2], r3
    vst1.64 {q2}, [r2], r3
    vst1.64 {q3}, [r2], r3
    bgt if_cpy_w8_loop_y

    pop {r4, r5, pc}


//void uavs3d_if_cpy_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w16_armv7
    push {r4, r5, lr}
    ldr r4, [sp, #12]
    ldr r5, [sp, #16]
    lsl r1, r1, #1
    lsl r3, r3, #1
if_cpy_w16_loop_y:
    vld1.64 {q0, q1}, [r0], r1
    vld1.64 {q2, q3}, [r0], r1
    vld1.64 {q10, q11}, [r0], r1
    vld1.64 {q12, q13}, [r0], r1

    subs r5, r5, #4
    vst1.64 {q0, q1}, [r2], r3
    vst1.64 {q2, q3}, [r2], r3
    vst1.64 {q10, q11}, [r2], r3
    vst1.64 {q12, q13}, [r2], r3
    bgt if_cpy_w16_loop_y

    pop {r4, r5, pc}

//void uavs3d_if_cpy_w32_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w32_armv7
    push {r4, r5, lr}
    vpush {q4-q7}
    ldr r4, [sp, #76]
    ldr r5, [sp, #80]

    lsl r1, r1, #1
    lsl r3, r3, #1
    sub r1, #32
    sub r3, #32
if_cpy_w32_loop_y:
    vld1.64 {q0 , q1 }, [r0]!
    vld1.64 {q2 , q3 }, [r0], r1
    vld1.64 {q4 , q5 }, [r0]!
    vld1.64 {q6 , q7 }, [r0], r1
    vld1.64 {q8 , q9 }, [r0]!
    vld1.64 {q10, q11}, [r0], r1
    vld1.64 {q12, q13}, [r0]!
    vld1.64 {q14, q15}, [r0], r1

    subs r5, r5, #4
    vst1.64 {q0 , q1 }, [r2]!
    vst1.64 {q2 , q3 }, [r2], r3
    vst1.64 {q4 , q5 }, [r2]!
    vst1.64 {q6 , q7 }, [r2], r3
    vst1.64 {q8 , q9 }, [r2]!
    vst1.64 {q10, q11}, [r2], r3
    vst1.64 {q12, q13}, [r2]!
    vst1.64 {q14, q15}, [r2], r3
    bgt if_cpy_w32_loop_y

    vpop {q4-q7}
    pop {r4, r5, pc}

//void uavs3d_if_cpy_w64_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w64_armv7
    push {r4, r5, lr}
    vpush {q4-q7}
    ldr r4, [sp, #76]
    ldr r5, [sp, #80]

    lsl r1, r1, #1
    lsl r3, r3, #1
    sub r1, #96
    sub r3, #96
if_cpy_w64_loop_y:
    vld1.64 {q0 , q1 }, [r0]!
    vld1.64 {q2 , q3 }, [r0]!
    vld1.64 {q4 , q5 }, [r0]!
    vld1.64 {q6 , q7 }, [r0], r1
    vld1.64 {q8 , q9 }, [r0]!
    vld1.64 {q10, q11}, [r0]!
    vld1.64 {q12, q13}, [r0]!
    vld1.64 {q14, q15}, [r0], r1

    subs r5, r5, #2
    vst1.64 {q0 , q1 }, [r2]!
    vst1.64 {q2 , q3 }, [r2]!
    vst1.64 {q4 , q5 }, [r2]!
    vst1.64 {q6 , q7 }, [r2], r3
    vst1.64 {q8 , q9 }, [r2]!
    vst1.64 {q10, q11}, [r2]!
    vst1.64 {q12, q13}, [r2]!
    vst1.64 {q14, q15}, [r2], r3
    bgt if_cpy_w64_loop_y

    vpop {q4-q7}
    pop {r4, r5, pc}

//void uavs3d_if_cpy_w128_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5
function uavs3d_if_cpy_w128_armv7
    push {r4, r5, lr}
    vpush {q4-q7}
    ldr r4, [sp, #76]
    ldr r5, [sp, #80]

    lsl r1, r1, #1
    lsl r3, r3, #1
    sub r1, #224
    sub r3, #224
if_cpy_w128_loop_y:
    vld1.64 {q0 , q1 }, [r0]!
    vld1.64 {q2 , q3 }, [r0]!
    vld1.64 {q4 , q5 }, [r0]!
    vld1.64 {q6 , q7 }, [r0]!
    vld1.64 {q8 , q9 }, [r0]!
    vld1.64 {q10, q11}, [r0]!
    vld1.64 {q12, q13}, [r0]!
    vld1.64 {q14, q15}, [r0], r1

    subs r5, r5, #1
    vst1.64 {q0 , q1 }, [r2]!
    vst1.64 {q2 , q3 }, [r2]!
    vst1.64 {q4 , q5 }, [r2]!
    vst1.64 {q6 , q7 }, [r2]!
    vst1.64 {q8 , q9 }, [r2]!
    vst1.64 {q10, q11}, [r2]!
    vst1.64 {q12, q13}, [r2]!
    vst1.64 {q14, q15}, [r2], r3
    bgt if_cpy_w128_loop_y

    vpop {q4-q7}
    pop {r4, r5, pc}

//void uavs3d_if_hor_chroma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_chroma_w8_armv7
    push    {r4-r8, lr}
    add     sp, sp, #24
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #24

    vpush   {q4, q5, q6}

    vdup.u16 q6, r7

    lsl r1, r1, #1
    lsl r3, r3, #1

    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q2, d4
    vdup.u16 d0, d4[0]
    vdup.u16 d1, d4[1]
    vdup.u16 d2, d4[2]
    vdup.u16 d3, d4[3]

    sub r0, r0, #4              // src - 2

if_hor_chroma_w8_loop_y:
    vld1.8 {q2, q3}, [r0], r1   // src[x-2]
    vld1.8 {q4, q5}, [r0], r1
    vext.i16 q10, q2, q3, #2    // src[x]
    vext.i16 q11, q2, q3, #4    // src[x+2]
    vext.i16 q12, q2, q3, #6    // src[x+4]
    vext.i16 q13, q4, q5, #2    // src[x]
    vext.i16 q14, q4, q5, #4    // src[x+2]
    vext.i16 q15, q4, q5, #6    // src[x+4]

    vmull.u16 q3, d20, d1
    vmull.u16 q5, d21, d1
    vmull.u16 q8, d26, d1
    vmull.u16 q9, d27, d1
    vmlsl.u16 q3, d4, d0
    vmlsl.u16 q5, d5, d0
    vmlsl.u16 q8, d8, d0
    vmlsl.u16 q9, d9, d0
    vmlal.u16 q3, d22, d2
    vmlal.u16 q5, d23, d2
    vmlal.u16 q8, d28, d2
    vmlal.u16 q9, d29, d2
    vmlsl.u16 q3, d24, d3
    vmlsl.u16 q5, d25, d3
    vmlsl.u16 q8, d30, d3
    vmlsl.u16 q9, d31, d3

    vqrshrun.s32 d20, q3, #6
    vqrshrun.s32 d21, q5, #6
    vqrshrun.s32 d22, q8, #6
    vqrshrun.s32 d23, q9, #6

    vmin.u16 q10, q10, q6
    vmin.u16 q11, q11, q6

    subs r5, r5, #2
    vst1.64 {q10}, [r2], r3
    vst1.64 {q11}, [r2], r3
    bgt if_hor_chroma_w8_loop_y

    vpop {q4-q6}
    pop {r4-r8, pc}


//void uavs3d_if_hor_chroma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_chroma_w16_armv7
    push    {r4-r8, lr}
    add     sp, sp, #24
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #24
    vpush   {q4, q5, q6}

    vdup.u16 q6, r7             // max_val

    lsl     r1, r1, #1
    lsl     r3, r3, #1

    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vmovl.u8 q4, d8
    vdup.u16 d0, d8[0]
    vdup.u16 d1, d8[1]
    vdup.u16 d2, d8[2]
    vdup.u16 d3, d8[3]

    sub r0, r0, #4              // src - 2
    sub r1, r1, #32
if_hor_chroma_w16_loop_y:
    vld1.16 {q2, q3}, [r0]!     // src[x-2]
    vld1.16 {q4}, [r0], r1
    vext.i16 q10, q2, q3, #2    // src[x]
    vext.i16 q11, q2, q3, #4    // src[x+2]
    vext.i16 q12, q2, q3, #6    // src[x+4]
    vext.i16 q13, q3, q4, #2    // src[x]
    vext.i16 q14, q3, q4, #4    // src[x+2]
    vext.i16 q15, q3, q4, #6    // src[x+4]

    vmull.u16 q4, d20, d1
    vmull.u16 q5, d21, d1
    vmull.u16 q8, d26, d1
    vmull.u16 q9, d27, d1
    vmlsl.u16 q4, d4, d0
    vmlsl.u16 q5, d5, d0
    vmlsl.u16 q8, d6, d0
    vmlsl.u16 q9, d7, d0
    vmlal.u16 q4, d22, d2
    vmlal.u16 q5, d23, d2
    vmlal.u16 q8, d28, d2
    vmlal.u16 q9, d29, d2
    vmlsl.u16 q4, d24, d3
    vmlsl.u16 q5, d25, d3
    vmlsl.u16 q8, d30, d3
    vmlsl.u16 q9, d31, d3

    vqrshrun.s32 d20, q4, #6
    vqrshrun.s32 d21, q5, #6
    vqrshrun.s32 d22, q8, #6
    vqrshrun.s32 d23, q9, #6

    vmin.u16 q10, q10, q6
    vmin.u16 q11, q11, q6

    subs r5, r5, #1
    vst1.64 {q10, q11}, [r2], r3
    bgt if_hor_chroma_w16_loop_y

    vpop {q4, q5, q6}
    pop {r4-r8, pc}


//void uavs3d_if_hor_chroma_w16x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_chroma_w16x_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #36
    vpush   {q4, q5, q6}

    vdup.u16 q6, r7             // max_val

    lsl     r1, r1, #1
    lsl     r3, r3, #1

    vld1.32 {d8[0]}, [r6]
    vabs.s8 d8, d8
    vmovl.u8 q4, d8
    vdup.u16 d0, d8[0]
    vdup.u16 d1, d8[1]
    vdup.u16 d2, d8[2]
    vdup.u16 d3, d8[3]

    sub r0, r0, #4              // src - 2
if_hor_chroma_w16x_loop_y:
    mov r9, r4
    mov r10, r0
    mov r11, r2
if_hor_chroma_w16x_loop_x:
    vld1.16 {q2, q3}, [r10]!    // src[x-2]
    vld1.16 {q4}, [r10]
    vext.i16 q10, q2, q3, #2    // src[x]
    vext.i16 q11, q2, q3, #4    // src[x+2]
    vext.i16 q12, q2, q3, #6    // src[x+4]
    vext.i16 q13, q3, q4, #2    // src[x]
    vext.i16 q14, q3, q4, #4    // src[x+2]
    vext.i16 q15, q3, q4, #6    // src[x+4]

    vmull.u16 q4, d20, d1
    vmull.u16 q5, d21, d1
    vmull.u16 q8, d26, d1
    vmull.u16 q9, d27, d1
    vmlsl.u16 q4, d4, d0
    vmlsl.u16 q5, d5, d0
    vmlsl.u16 q8, d6, d0
    vmlsl.u16 q9, d7, d0
    vmlal.u16 q4, d22, d2
    vmlal.u16 q5, d23, d2
    vmlal.u16 q8, d28, d2
    vmlal.u16 q9, d29, d2
    vmlsl.u16 q4, d24, d3
    vmlsl.u16 q5, d25, d3
    vmlsl.u16 q8, d30, d3
    vmlsl.u16 q9, d31, d3

    vqrshrun.s32 d20, q4, #6
    vqrshrun.s32 d21, q5, #6
    vqrshrun.s32 d22, q8, #6
    vqrshrun.s32 d23, q9, #6

    vmin.u16 q10, q10, q6
    vmin.u16 q11, q11, q6

    subs r9, r9, #16
    vst1.64 {q10, q11}, [r11]!
    bgt if_hor_chroma_w16x_loop_x

    subs r5, r5, #1
    add r0, r0, r1
    add r2, r2, r3
    bgt if_hor_chroma_w16x_loop_y

    vpop {q4, q5, q6}
    pop {r4-r11, pc}


//void uavs3d_if_hor_luma_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_luma_w4_armv7
    push    {r4-r8, lr}
    add     sp, sp, #28
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #28
    vpush   {q5, q6, q7}

    vdup.u16 q5, r7             // max_val

    lsl     r1, r1, #1
    lsl     r3, r3, #1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q3, d7
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]
    vdup.u16 d4, d7[0]
    vdup.u16 d5, d7[1]
    vdup.u16 d6, d7[2]
    vdup.u16 d7, d7[3]

    sub r0, r0, #6              // x-3
if_hor_luma_w4_loop_y:
    vld1.16 {d24, d25, d26}, [r0], r1   // src[x-3]
    vld1.16 {d27, d28, d29}, [r0], r1

    vext.i16 d12, d24, d25, #1  // src[x-2]
    vext.i16 d13, d24, d25, #2  // src[x-1]
    vext.i16 d14, d24, d25, #3  // src[x]
    // d25: src[x+1]
    vext.i16 d16, d25, d26, #1
    vext.i16 d17, d25, d26, #2
    vext.i16 d18, d25, d26, #3

    vext.i16 d19, d27, d28, #1
    vext.i16 d20, d27, d28, #2
    vext.i16 d21, d27, d28, #3
    vmov.i16 d22, d28
    vext.i16 d23, d28, d29, #1
    vext.i16 d15, d28, d29, #2
    vext.i16 d26, d28, d29, #3

    // interpolation filter
    vmull.u16 q14, d12, d1
    vmull.u16 q15, d19, d1
    vmlsl.u16 q14, d24, d0
    vmlsl.u16 q15, d27, d0
    vmlsl.u16 q14, d13, d2
    vmlsl.u16 q15, d20, d2
    vmlal.u16 q14, d14, d3
    vmlal.u16 q15, d21, d3
    vmlal.u16 q14, d25, d4
    vmlal.u16 q15, d22, d4
    vmlsl.u16 q14, d16, d5
    vmlsl.u16 q15, d23, d5
    vmlal.u16 q14, d17, d6
    vmlal.u16 q15, d15, d6
    vmlsl.u16 q14, d18, d7
    vmlsl.u16 q15, d26, d7

    // round and clip
    vqrshrun.s32 d12, q14, #6
    vqrshrun.s32 d13, q15, #6

    vmin.u16 q6, q6, q5

    subs r5, r5, #2
    // store results into &dst[x]
    vst1.32 {d12}, [r2], r3
    vst1.32 {d13}, [r2], r3
    bgt if_hor_luma_w4_loop_y

    vpop {q5, q6, q7}
    pop {r4-r8, pc}


//void uavs3d_if_hor_luma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_luma_w8_armv7
    push    {r4-r8, lr}
    add     sp, sp, #28
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #28
    vpush   {q5, q6, q7}
    vdup.u16 q5, r7             // max_val

    lsl     r1, r1, #1
    lsl     r3, r3, #1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q3, d7
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]
    vdup.u16 d4, d7[0]
    vdup.u16 d5, d7[1]
    vdup.u16 d6, d7[2]
    vdup.u16 d7, d7[3]

    sub r0, r0, #6                      // x-3
if_hor_luma_w8_loop_y:
    vld1.8 {q14, q15}, [r0], r1         // src[x-3]

    vext.i16 q6 , q14, q15, #1          // src[x-2]
    vext.i16 q7 , q14, q15, #2
    vext.i16 q8 , q14, q15, #3
    vext.i16 q9 , q14, q15, #4
    vext.i16 q10, q14, q15, #5
    vext.i16 q11, q14, q15, #6
    vext.i16 q12, q14, q15, #7

    // interpolation filter
    vmull.u16 q13, d12, d1
    vmull.u16 q15, d13, d1
    vmlsl.u16 q13, d28, d0
    vmlsl.u16 q15, d29, d0
    vmlsl.u16 q13, d14, d2
    vmlsl.u16 q15, d15, d2
    vmlal.u16 q13, d16, d3
    vmlal.u16 q15, d17, d3
    vmlal.u16 q13, d18, d4
    vmlal.u16 q15, d19, d4
    vmlsl.u16 q13, d20, d5
    vmlsl.u16 q15, d21, d5
    vmlal.u16 q13, d22, d6
    vmlal.u16 q15, d23, d6
    vmlsl.u16 q13, d24, d7
    vmlsl.u16 q15, d25, d7

    // round and clip
    vqrshrun.s32 d12, q13, #6
    vqrshrun.s32 d13, q15, #6

    vmin.u16 q6, q6, q5
        // store
    subs r5, r5, #1
    vst1.64 {q6}, [r2], r3
    bgt if_hor_luma_w8_loop_y

    vpop {q5, q6, q7}
    pop {r4-r8, pc}


//void uavs3d_if_hor_luma_w8x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_hor_luma_w8x_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #36
    vpush   {q5, q6, q7}

    vdup.u16 q5, r7             // max_val

    lsl  r1, r1, #1
    lsl  r3, r3, #1
    lsl  r4, r4, #1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q3, d7
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]
    vdup.u16 d4, d7[0]
    vdup.u16 d5, d7[1]
    vdup.u16 d6, d7[2]
    vdup.u16 d7, d7[3]

    sub r0, r0, #6                      // x-3
if_hor_luma_w8x_loop_y:
    mov r9, r4
    mov r10, r0
    mov r11, r2
if_hor_luma_w8x_loop_x:
    vld1.16 {q14, q15}, [r10]            // src[x-3]

    vext.i16 q6 , q14, q15, #1           // src[x-2]
    vext.i16 q7 , q14, q15, #2
    vext.i16 q8 , q14, q15, #3
    vext.i16 q9 , q14, q15, #4
    vext.i16 q10, q14, q15, #5
    vext.i16 q11, q14, q15, #6
    vext.i16 q12, q14, q15, #7

    add r10, #16

    // interpolation filter
    vmull.u16 q13, d12, d1
    vmull.u16 q15, d13, d1
    vmlsl.u16 q13, d28, d0
    vmlsl.u16 q15, d29, d0
    vmlsl.u16 q13, d14, d2
    vmlsl.u16 q15, d15, d2
    vmlal.u16 q13, d16, d3
    vmlal.u16 q15, d17, d3
    vmlal.u16 q13, d18, d4
    vmlal.u16 q15, d19, d4
    vmlsl.u16 q13, d20, d5
    vmlsl.u16 q15, d21, d5
    vmlal.u16 q13, d22, d6
    vmlal.u16 q15, d23, d6
    vmlsl.u16 q13, d24, d7
    vmlsl.u16 q15, d25, d7

    subs r9, #16
    // round and clip
    vqrshrun.s32 d12, q13, #6
    vqrshrun.s32 d13, q15, #6

    vmin.u16 q6, q6, q5
    // store
    vst1.64 {q6}, [r11]!
    bgt if_hor_luma_w8x_loop_x

    subs r5, r5, #1
    add r0, r0, r1
    add r2, r2, r3
    bgt if_hor_luma_w8x_loop_y

    vpop {q5, q6, q7}
    pop {r4-r11, pc}


//void uavs3d_if_ver_chroma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_chroma_w8_armv7
    push    {r4-r8, lr}
    add     sp, sp, #28
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #28

    vpush {q4, q5}

    lsl r1, r1, #1
    lsl r3, r3, #1
    vdup.u16 q5, r7

    // load coeff
    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q3, d4
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]

    sub r0, r0, r1              // src - i_src
if_ver_chroma_w8_loop_y:
    vld1.16 {q2}, [r0], r1      // src-i_src
    vld1.16 {q3}, [r0], r1      // src
    vld1.16 {q4}, [r0], r1      // src+i_src
    vld1.16 {q8}, [r0], r1      // src+2*i_src
    mov r4, r0
    vld1.16 {q9}, [r0], r1
    vld1.16 {q10}, [r0], r1
    vld1.16 {q11}, [r0]

    vmull.u16 q12, d6, d1
    vmull.u16 q13, d7, d1
    vmull.u16 q14, d8, d1
    vmull.u16 q15, d9, d1
    vmlsl.u16 q12, d4, d0
    vmlsl.u16 q13, d5, d0
    vmlsl.u16 q14, d6, d0
    vmlsl.u16 q15, d7, d0
    vmlal.u16 q12, d8, d2
    vmlal.u16 q13, d9, d2
    vmlal.u16 q14, d16, d2
    vmlal.u16 q15, d17, d2
    vmlsl.u16 q12, d16, d3
    vmlsl.u16 q13, d17, d3
    vmlsl.u16 q14, d18, d3
    vmlsl.u16 q15, d19, d3

    vqrshrun.s32 d4, q12, #6
    vqrshrun.s32 d5, q13, #6
    vqrshrun.s32 d6, q14, #6
    vqrshrun.s32 d7, q15, #6

    vmin.u16 q2, q2, q5
    vmin.u16 q3, q3, q5

    vst1.32 {q2}, [r2], r3
    vst1.32 {q3}, [r2], r3

    vmull.u16 q12, d16, d1
    vmull.u16 q13, d17, d1
    vmull.u16 q14, d18, d1
    vmull.u16 q15, d19, d1
    vmlsl.u16 q12, d8, d0
    vmlsl.u16 q13, d9, d0
    vmlsl.u16 q14, d16, d0
    vmlsl.u16 q15, d17, d0
    vmlal.u16 q12, d18, d2
    vmlal.u16 q13, d19, d2
    vmlal.u16 q14, d20, d2
    vmlal.u16 q15, d21, d2
    vmlsl.u16 q12, d20, d3
    vmlsl.u16 q13, d21, d3
    vmlsl.u16 q14, d22, d3
    vmlsl.u16 q15, d23, d3

    vqrshrun.s32 d24, q12, #6
    vqrshrun.s32 d25, q13, #6
    vqrshrun.s32 d26, q14, #6
    vqrshrun.s32 d27, q15, #6

    vmin.u16 q12, q12, q5
    vmin.u16 q13, q13, q5

    subs r5, r5, #4
    mov r0, r4
    vst1.32 {q12}, [r2], r3
    vst1.32 {q13}, [r2], r3
    bgt if_ver_chroma_w8_loop_y

    vpop {q4, q5}
    pop {r4-r8, pc}


//void uavs3d_if_ver_chroma_w16_armv7(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_chroma_w16_armv7
    push    {r4-r8, lr}
    add     sp, sp, #28
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #28
    vpush   {q4-q7}

    lsl r1, r1, #1
    lsl r3, r3, #1

    // load coeff
    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q3, d4
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]

    sub r0, r0, r1

if_ver_chroma_w16_loop_y:
    vld1.8 {q2, q3}, [r0], r1        // src + x - i_src
    vld1.8 {q4, q5}, [r0], r1        // src + x
    mov r4, r0
    vld1.8 {q6, q7}, [r0], r1        // src + x + i_src
    vld1.8 {q8, q9}, [r0], r1        // src + x + 2*i_src
    vld1.8 {q10, q11}, [r0]

    vmull.u16 q12, d8 , d1
    vmull.u16 q13, d9 , d1
    vmull.u16 q14, d10, d1
    vmull.u16 q15, d11, d1
    vmlsl.u16 q12, d4 , d0
    vmlsl.u16 q13, d5 , d0
    vmlsl.u16 q14, d6 , d0
    vmlsl.u16 q15, d7 , d0
    vmlal.u16 q12, d12, d2
    vmlal.u16 q13, d13, d2
    vmlal.u16 q14, d14, d2
    vmlal.u16 q15, d15, d2
    vmlsl.u16 q12, d16, d3
    vmlsl.u16 q13, d17, d3
    vmlsl.u16 q14, d18, d3
    vmlsl.u16 q15, d19, d3

    vdup.u16 q2, r7

    vqrshrun.s32 d24, q12, #6
    vqrshrun.s32 d25, q13, #6
    vqrshrun.s32 d26, q14, #6
    vqrshrun.s32 d27, q15, #6

    vmin.u16 q12, q12, q2
    vmin.u16 q13, q13, q2

    vst1.32 {q12, q13}, [r2], r3

    vmull.u16 q12, d12, d1
    vmull.u16 q13, d13, d1
    vmull.u16 q14, d14, d1
    vmull.u16 q15, d15, d1
    vmlsl.u16 q12, d8 , d0
    vmlsl.u16 q13, d9 , d0
    vmlsl.u16 q14, d10, d0
    vmlsl.u16 q15, d11, d0
    vmlal.u16 q12, d16, d2
    vmlal.u16 q13, d17, d2
    vmlal.u16 q14, d18, d2
    vmlal.u16 q15, d19, d2
    vmlsl.u16 q12, d20, d3
    vmlsl.u16 q13, d21, d3
    vmlsl.u16 q14, d22, d3
    vmlsl.u16 q15, d23, d3

    vqrshrun.s32 d24, q12, #6
    vqrshrun.s32 d25, q13, #6
    vqrshrun.s32 d26, q14, #6
    vqrshrun.s32 d27, q15, #6

    vmin.u16 q12, q12, q2
    vmin.u16 q13, q13, q2

    subs r5, r5, #2
    mov r0, r4
    vst1.32 {q12, q13}, [r2], r3
    bgt if_ver_chroma_w16_loop_y

    vpop {q4-q7}
    pop  {r4-r8, pc}


//void uavs3d_if_ver_chroma_w16x_armv7(const pel_t *src, int i_src, pel_t *dst, int i_dst, int width, int height, char_t const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_chroma_w16x_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #36
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1
    lsl r4, r4, #1

    vdup.u16 q6, r7

    // load coeff
    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q3, d4
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]

    sub r0, r0, r1
if_ver_chroma_w32x_loop_y:
    mov r9, #0
    mov r11, r2
if_ver_chroma_w32x_loop_x:
    add r10, r0, r9
    vld1.16 {q2, q3}, [r10], r1        // src + x - i_src
    vld1.16 {q4, q5}, [r10], r1        // src + x
    vld1.16 {q8, q9}, [r10], r1        // src + x + i_src
    vld1.16 {q10, q11}, [r10], r1      // src + x + 2*i_src

    vmull.u16 q12, d8 , d1
    vmull.u16 q13, d9 , d1
    vmull.u16 q14, d10, d1
    vmull.u16 q15, d11, d1
    vmlsl.u16 q12, d4 , d0
    vmlsl.u16 q13, d5 , d0
    vmlsl.u16 q14, d6 , d0
    vmlsl.u16 q15, d7 , d0
    vmlal.u16 q12, d16, d2
    vmlal.u16 q13, d17, d2
    vmlal.u16 q14, d18, d2
    vmlal.u16 q15, d19, d2
    vmlsl.u16 q12, d20, d3
    vmlsl.u16 q13, d21, d3
    vmlsl.u16 q14, d22, d3
    vmlsl.u16 q15, d23, d3

    vqrshrun.s32 d24, q12, #6
    vqrshrun.s32 d25, q13, #6
    vqrshrun.s32 d26, q14, #6
    vqrshrun.s32 d27, q15, #6

    vmin.u16 q12, q12, q6
    vmin.u16 q13, q13, q6

    add r9, r9, #32
    vst1.32 {q12, q13}, [r11]!

    //--------------------------------
    // loop control
    //--------------------------------
    cmp r9, r4
    blt if_ver_chroma_w32x_loop_x
    subs r5, r5, #1
    add r0, r0, r1
    add r2, r2, r3
    bgt if_ver_chroma_w32x_loop_y

    vpop {q4, q5, q6}
    pop  {r4-r11, pc}


//void uavs3d_if_ver_luma_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_luma_w4_armv7
    push    {r4-r11, lr}
    add     sp, sp, #40
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #40

    vpush {q4}

    lsl r1, r1, #1
    lsl r3, r3, #1
    // load coeffs
    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vdup.u16 q4, r7                     // max_pel
    vmovl.u8 q3, d7
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]
    vdup.u16 d4, d7[0]
    vdup.u16 d5, d7[1]
    vdup.u16 d6, d7[2]
    vdup.u16 d7, d7[3]

    sub r0, r0, r1, lsl #1
    sub r0, r0, r1                      // src - 3*i_src

if_ver_luma_w4_loop_y:
    vld1.16 {d16}, [r0], r1             // x-3*i_src
    vld1.16 {d17}, [r0], r1             // x-2*i_src
    vld1.16 {d18}, [r0], r1             // x-i_src
    vld1.16 {d19}, [r0], r1             // x
    mov r4, r0
    vld1.16 {d20}, [r0], r1             // x+i_src
    vld1.16 {d21}, [r0], r1             // x+2*i_src
    vld1.16 {d22}, [r0], r1             // x+3*i_src
    vld1.16 {d23}, [r0], r1             // x+4*i_src
    vld1.16 {d24}, [r0], r1
    vld1.16 {d25}, [r0], r1
    vld1.16 {d26}, [r0]

    vmull.u16 q14, d17, d1
    vmull.u16 q15, d18, d1
    vmlsl.u16 q14, d16, d0
    vmlsl.u16 q15, d17, d0
    vmlsl.u16 q14, d18, d2
    vmlsl.u16 q15, d19, d2
    vmlal.u16 q14, d19, d3
    vmlal.u16 q15, d20, d3
    vmlal.u16 q14, d20, d4
    vmlal.u16 q15, d21, d4
    vmlsl.u16 q14, d21, d5
    vmlsl.u16 q15, d22, d5
    vmlal.u16 q14, d22, d6
    vmlal.u16 q15, d23, d6
    vmlsl.u16 q14, d23, d7
    vmlsl.u16 q15, d24, d7

    vqrshrun.s32 d16, q14, #6
    vqrshrun.s32 d17, q15, #6

    vmin.u16 q8, q8, q4

    vmull.u16 q14, d19, d1
    vmull.u16 q15, d20, d1
    vmlsl.u16 q14, d18, d0
    vmlsl.u16 q15, d19, d0
    vmlsl.u16 q14, d20, d2
    vmlsl.u16 q15, d21, d2
    vst1.32 {d16}, [r2], r3
    vmlal.u16 q14, d21, d3
    vmlal.u16 q15, d22, d3
    vmlal.u16 q14, d22, d4
    vmlal.u16 q15, d23, d4
    vst1.32 {d17}, [r2], r3
    vmlsl.u16 q14, d23, d5
    vmlsl.u16 q15, d24, d5
    vmlal.u16 q14, d24, d6
    vmlal.u16 q15, d25, d6
    vmlsl.u16 q14, d25, d7
    vmlsl.u16 q15, d26, d7

    //(sum + 32) >> 6
    vqrshrun.s32 d28, q14, #6
    vqrshrun.s32 d29, q15, #6

    vmin.u16 q14, q14, q4

    subs r5, r5, #4
    mov r0, r4
    vst1.32 {d28}, [r2], r3
    vst1.32 {d29}, [r2], r3
    bgt if_ver_luma_w4_loop_y

    vpop {q4}
    pop  {r4-r11, pc}


//void uavs3d_if_ver_luma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_luma_w8_armv7
    push    {r4-r7, lr}
    add     sp, sp, #24
    ldmia   sp, {r5, r6, r7}
    sub     sp, sp, #24
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1

    // load coeffs
    vld1.16 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q3, d7
    vdup.u16 q6, r7
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]
    vdup.u16 d4, d7[0]
    vdup.u16 d5, d7[1]
    vdup.u16 d6, d7[2]
    vdup.u16 d7, d7[3]

    sub r0, r0, r1, lsl #1
    sub r0, r0, r1                  // src - 3*i_src

if_ver_luma_w8_loop_y:
    vld1.16 {q8}, [r0], r1          // x-3*i_src
    vld1.16 {q9}, [r0], r1          // x-2*i_src
    vld1.16 {q10}, [r0], r1         // x-i_src
    vld1.16 {q11}, [r0], r1         // x
    mov r4, r0
    vld1.16 {q12}, [r0], r1         // x+i_src
    vld1.16 {q13}, [r0], r1         // x+2*i_src
    vld1.16 {q14}, [r0], r1         // x+3*i_src
    vld1.16 {q15}, [r0], r1         // x+4*i_src

    vmull.u16 q4, d18, d1
    vmull.u16 q5, d19, d1
    vmlsl.u16 q4, d16, d0
    vmlsl.u16 q5, d17, d0
    vmlsl.u16 q4, d20, d2
    vmlsl.u16 q5, d21, d2
    vmlal.u16 q4, d22, d3
    vmlal.u16 q5, d23, d3
    vmlal.u16 q4, d24, d4
    vmlal.u16 q5, d25, d4
    vmlsl.u16 q4, d26, d5
    vmlsl.u16 q5, d27, d5
    vmlal.u16 q4, d28, d6
    vmlal.u16 q5, d29, d6
    vmlsl.u16 q4, d30, d7
    vmlsl.u16 q5, d31, d7

    vqrshrun.s32 d8, q4, #6
    vqrshrun.s32 d9, q5, #6
    vmin.u16 q4, q4, q6

    vld1.16 {q8}, [r0], r1
    vst1.32 {q4}, [r2], r3

    vmull.u16 q4, d20, d1
    vmull.u16 q5, d21, d1
    vmlsl.u16 q4, d18, d0
    vmlsl.u16 q5, d19, d0
    vmlsl.u16 q4, d22, d2
    vmlsl.u16 q5, d23, d2
    vmlal.u16 q4, d24, d3
    vmlal.u16 q5, d25, d3
    vmlal.u16 q4, d26, d4
    vmlal.u16 q5, d27, d4
    vmlsl.u16 q4, d28, d5
    vmlsl.u16 q5, d29, d5
    vmlal.u16 q4, d30, d6
    vmlal.u16 q5, d31, d6
    vmlsl.u16 q4, d16, d7
    vmlsl.u16 q5, d17, d7

    vqrshrun.s32 d8, q4, #6
    vqrshrun.s32 d9, q5, #6
    vmin.u16 q4, q4, q6

    vld1.16 {q9}, [r0], r1
    vst1.32 {q4}, [r2], r3

    vmull.u16 q4, d22, d1
    vmull.u16 q5, d23, d1
    vmlsl.u16 q4, d20, d0
    vmlsl.u16 q5, d21, d0
    vmlsl.u16 q4, d24, d2
    vmlsl.u16 q5, d25, d2
    vmlal.u16 q4, d26, d3
    vmlal.u16 q5, d27, d3
    vmlal.u16 q4, d28, d4
    vmlal.u16 q5, d29, d4
    vmlsl.u16 q4, d30, d5
    vmlsl.u16 q5, d31, d5
    vmlal.u16 q4, d16, d6
    vmlal.u16 q5, d17, d6
    vmlsl.u16 q4, d18, d7
    vmlsl.u16 q5, d19, d7

    vqrshrun.s32 d8, q4, #6
    vqrshrun.s32 d9, q5, #6
    vmin.u16 q4, q4, q6

    vld1.16 {q10}, [r0]
    vst1.32 {q4}, [r2], r3

    vmull.u16 q4, d24, d1
    vmull.u16 q5, d25, d1
    vmlsl.u16 q4, d22, d0
    vmlsl.u16 q5, d23, d0
    vmlsl.u16 q4, d26, d2
    vmlsl.u16 q5, d27, d2
    vmlal.u16 q4, d28, d3
    vmlal.u16 q5, d29, d3
    vmlal.u16 q4, d30, d4
    vmlal.u16 q5, d31, d4
    vmlsl.u16 q4, d16, d5
    vmlsl.u16 q5, d17, d5
    vmlal.u16 q4, d18, d6
    vmlal.u16 q5, d19, d6
    vmlsl.u16 q4, d20, d7
    vmlsl.u16 q5, d21, d7

    vqrshrun.s32 d8, q4, #6
    vqrshrun.s32 d9, q5, #6
    vmin.u16 q4, q4, q6

    subs r5, r5, #4
    mov r0, r4
    vst1.32 {q4}, [r2], r3
    bgt if_ver_luma_w8_loop_y

    vpop {q4, q5, q6}
    pop  {r4-r7, pc}


//void uavs3d_if_ver_luma_w8x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, s8 const *coeff, int max_val);
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff->r6, max_val->r7
function uavs3d_if_ver_luma_w8x_armv7
    push    {r4-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r4, r5, r6, r7}
    sub     sp, sp, #28
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1
    lsl r4, r4, #1

    // load coeffs
    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q3, d7
    vdup.u16 q6, r7
    vdup.u16 d0, d6[0]
    vdup.u16 d1, d6[1]
    vdup.u16 d2, d6[2]
    vdup.u16 d3, d6[3]
    vdup.u16 d4, d7[0]
    vdup.u16 d5, d7[1]
    vdup.u16 d6, d7[2]
    vdup.u16 d7, d7[3]

    sub r0, r0, r1, lsl #1
    sub r0, r0, r1                  // src - 3*i_src

if_ver_luma_w8x_loop_y:
    mov r7, #0
    mov r9, r2
if_ver_luma_w8x_loop_x:
    add r8, r0, r7

    vld1.16 {q8}, [r8], r1           // x-3*i_src
    vld1.16 {q9}, [r8], r1           // x-2*i_src
    vld1.16 {q10}, [r8], r1          // x-i_src
    vld1.16 {q11}, [r8], r1          // x
    vld1.16 {q12}, [r8], r1          // x+i_src
    vld1.16 {q13}, [r8], r1          // x+2*i_src
    vld1.16 {q14}, [r8], r1          // x+3*i_src
    vld1.16 {q15}, [r8], r1          // x+4*i_src

    vmull.u16 q4, d18, d1
    vmull.u16 q5, d19, d1
    vmlsl.u16 q4, d16, d0
    vmlsl.u16 q5, d17, d0
    vmlsl.u16 q4, d20, d2
    vmlsl.u16 q5, d21, d2
    vmlal.u16 q4, d22, d3
    vmlal.u16 q5, d23, d3
    vmlal.u16 q4, d24, d4
    vmlal.u16 q5, d25, d4
    vmlsl.u16 q4, d26, d5
    vmlsl.u16 q5, d27, d5
    vmlal.u16 q4, d28, d6
    vmlal.u16 q5, d29, d6
    vmlsl.u16 q4, d30, d7
    vmlsl.u16 q5, d31, d7

    vqrshrun.s32 d8, q4, #6
    vqrshrun.s32 d9, q5, #6

    vmin.u16 q4, q4, q6

    add r7, r7, #16
    vst1.32 {q4}, [r9]!

    cmp r7, r4
    blt if_ver_luma_w8x_loop_x

    subs r5, r5, #1
    add r0, r0, r1                  // src += i_src
    add r2, r2, r3
    bgt if_ver_luma_w8x_loop_y

    vpop {q4, q5, q6}
    pop  {r4-r9, pc}


//void uavs3d_if_hor_ver_chroma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7
function uavs3d_if_hor_ver_chroma_w8_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7, r8}
    sub     sp, sp, #36

    vpush {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1
    vdup.u16 q6, r8                 // max_pel

    // r11-->tmp
    mov r9, #36
    lsl r9, r9, #4
    sub r11, sp, r9                 // (32 + 4)*8*sizeof(short)
    mov sp, r11
    sub r0, r0, r1                  // src += -1 * i_src;

    cmp r8, #255
    bgt if_hor_ver_chroma_w8_10bit

//--------------------------------
// HOR
//--------------------------------
    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q0, d4
    sub r0, r0, #4                  // x - 1 UV

    //the first rows
    vld1.8 {q2, q3}, [r0], r1       // src[x-1]

    vext.i32 q13, q2, q3, #1        // src[x]
    vext.i32 q14, q2, q3, #2        // src[x+1]
    vext.i32 q15, q2, q3, #3        // src[x+2]

    vmul.u16 q8, q13, d0[1]
    vmls.u16 q8, q2 , d0[0]
    vmla.u16 q8, q14, d0[2]
    vmls.u16 q8, q15, d0[3]

    vst1.32 {q8}, [r11]!

    // the next height + 2 rows
    add r8, r5, #2
if_hor_ver_chroma_w8_hor_loop_y:
    vld1.16 {q10, q11}, [r0], r1    // src[x-1]
    vld1.16 {q12, q13}, [r0], r1

    vext.i32 q2, q10, q11, #1       // src[x]
    vext.i32 q3, q10, q11, #2       // src[x+1]
    vext.i32 q8, q10, q11, #3       // src[x+2]

    vmul.u16 q14, q2, d0[1]
    vmls.u16 q14, q10, d0[0]
    vmla.u16 q14, q3, d0[2]
    vmls.u16 q14, q8, d0[3]

    vext.i32 q2, q12, q13, #1       // src[x]
    vext.i32 q3, q12, q13, #2       // src[x+1]
    vext.i32 q8, q12, q13, #3       // src[x+2]

    vst1.64 {q14}, [r11]!

    vmul.u16 q10, q2, d0[1]
    vmls.u16 q10, q12, d0[0]
    vmla.u16 q10, q3, d0[2]
    vmls.u16 q10, q8, d0[3]

    subs r8, r8, #2
    vst1.64 {q10}, [r11]!
    bgt if_hor_ver_chroma_w8_hor_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r11, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_chroma_w8_ver_loop_y:
    vld1.32 {q8, q9}, [r11]!
    vld1.32 {q10, q11}, [r11]!
    mov r10, r11
    vld1.32 {q2, q3}, [r11]!
    vld1.32 {q1}, [r11]

    vmull.s16 q12, d16, d0[0]
    vmull.s16 q13, d17, d0[0]
    vmull.s16 q14, d18, d0[0]
    vmull.s16 q15, d19, d0[0]
    vmlal.s16 q12, d18, d0[1]
    vmlal.s16 q13, d19, d0[1]
    vmlal.s16 q14, d20, d0[1]
    vmlal.s16 q15, d21, d0[1]
    vmlal.s16 q12, d20, d0[2]
    vmlal.s16 q13, d21, d0[2]
    vmlal.s16 q14, d22, d0[2]
    vmlal.s16 q15, d23, d0[2]
    vmlal.s16 q12, d22, d0[3]
    vmlal.s16 q13, d23, d0[3]
    vmlal.s16 q14, d4, d0[3]
    vmlal.s16 q15, d5, d0[3]

    vqrshrun.s32 d24, q12, #12
    vqrshrun.s32 d25, q13, #12
    vqrshrun.s32 d26, q14, #12
    vqrshrun.s32 d27, q15, #12

    vmull.s16 q8 , d20, d0[0]
    vmull.s16 q9 , d21, d0[0]
    vmull.s16 q14, d22, d0[0]
    vmull.s16 q15, d23, d0[0]
    vmlal.s16 q8 , d22, d0[1]
    vmlal.s16 q9 , d23, d0[1]
    vmlal.s16 q14, d4, d0[1]
    vmlal.s16 q15, d5, d0[1]
    vmlal.s16 q8 , d4, d0[2]
    vmlal.s16 q9 , d5, d0[2]
    vmlal.s16 q14, d6, d0[2]
    vmlal.s16 q15, d7, d0[2]
    vmlal.s16 q8 , d6, d0[3]
    vmlal.s16 q9 , d7, d0[3]
    vmlal.s16 q14, d2, d0[3]
    vmlal.s16 q15, d3, d0[3]

    vqrshrun.s32 d16, q8, #12
    vqrshrun.s32 d17, q9, #12
    vqrshrun.s32 d18, q14, #12
    vqrshrun.s32 d19, q15, #12

    vmin.u16 q12, q12, q6
    vmin.u16 q13, q13, q6
    vmin.u16 q8, q8, q6
    vmin.u16 q9, q9, q6

    subs r5, r5, #4
    mov r11, r10
    vst1.32 {q12}, [r2], r3
    vst1.32 {q13}, [r2], r3
    vst1.32 {q8}, [r2], r3
    vst1.32 {q9}, [r2], r3
    bgt if_hor_ver_chroma_w8_ver_loop_y
    b   if_hor_ver_chroma_w8_end

if_hor_ver_chroma_w8_10bit:
//--------------------------------
// HOR
//--------------------------------
    vld1.32 {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q0, d4
    sub r0, r0, #4                  // x - 1 UV

    //the first rows
    vld1.16 {q2, q3}, [r0], r1      // src[x-1]

    vext.i32 q13, q2, q3, #1        // src[x]
    vext.i32 q14, q2, q3, #2        // src[x+1]
    vext.i32 q15, q2, q3, #3        // src[x+2]

    vmull.u16 q8, d26, d0[1]
    vmull.u16 q9, d27, d0[1]
    vmlsl.u16 q8, d4 , d0[0]
    vmlsl.u16 q9, d5 , d0[0]
    vmlal.u16 q8, d28, d0[2]
    vmlal.u16 q9, d29, d0[2]
    vmlsl.u16 q8, d30, d0[3]
    vmlsl.u16 q9, d31, d0[3]

    vrshrn.s32 d16, q8, #2
    vrshrn.s32 d17, q9, #2
    vst1.32 {q8}, [r11]!

    // the next height + 2 rows
    add r8, r5, #2
if_hor_ver_chroma_w8_hor_10bit_loop_y:
    vld1.16 {q10, q11}, [r0], r1    // src[x-1]
    vld1.16 {q12, q13}, [r0], r1

    vext.i32 q2, q10, q11, #1       // src[x]
    vext.i32 q3, q10, q11, #2       // src[x+1]
    vext.i32 q8, q10, q11, #3       // src[x+2]

    vmull.u16 q14, d4, d0[1]
    vmull.u16 q15, d5, d0[1]
    vmlsl.u16 q14, d20, d0[0]
    vmlsl.u16 q15, d21, d0[0]
    vmlal.u16 q14, d6, d0[2]
    vmlal.u16 q15, d7, d0[2]
    vmlsl.u16 q14, d16, d0[3]
    vmlsl.u16 q15, d17, d0[3]

    vrshrn.s32 d28, q14, #2
    vrshrn.s32 d29, q15, #2

    vext.i32 q2, q12, q13, #1       // src[x]
    vext.i32 q3, q12, q13, #2       // src[x+1]
    vext.i32 q8, q12, q13, #3       // src[x+2]

    vst1.64 {q14}, [r11]!

    vmull.u16 q10, d4, d0[1]
    vmull.u16 q11, d5, d0[1]
    vmlsl.u16 q10, d24, d0[0]
    vmlsl.u16 q11, d25, d0[0]
    vmlal.u16 q10, d6, d0[2]
    vmlal.u16 q11, d7, d0[2]
    vmlsl.u16 q10, d16, d0[3]
    vmlsl.u16 q11, d17, d0[3]

    vrshrn.s32 d20, q10, #2
    vrshrn.s32 d21, q11, #2

    subs r8, r8, #2
    vst1.64 {q10}, [r11]!
    bgt if_hor_ver_chroma_w8_hor_10bit_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r11, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_chroma_w8_ver_10bit_loop_y:
    vld1.32 {q8, q9}, [r11]!
    vld1.32 {q10, q11}, [r11]!
    mov r10, r11
    vld1.32 {q2, q3}, [r11]!
    vld1.32 {q1}, [r11]

    vmull.s16 q12, d16, d0[0]
    vmull.s16 q13, d17, d0[0]
    vmull.s16 q14, d18, d0[0]
    vmull.s16 q15, d19, d0[0]
    vmlal.s16 q12, d18, d0[1]
    vmlal.s16 q13, d19, d0[1]
    vmlal.s16 q14, d20, d0[1]
    vmlal.s16 q15, d21, d0[1]
    vmlal.s16 q12, d20, d0[2]
    vmlal.s16 q13, d21, d0[2]
    vmlal.s16 q14, d22, d0[2]
    vmlal.s16 q15, d23, d0[2]
    vmlal.s16 q12, d22, d0[3]
    vmlal.s16 q13, d23, d0[3]
    vmlal.s16 q14, d4, d0[3]
    vmlal.s16 q15, d5, d0[3]

    vqrshrun.s32 d24, q12, #10
    vqrshrun.s32 d25, q13, #10
    vqrshrun.s32 d26, q14, #10
    vqrshrun.s32 d27, q15, #10

    vmull.s16 q8 , d20, d0[0]
    vmull.s16 q9 , d21, d0[0]
    vmull.s16 q14, d22, d0[0]
    vmull.s16 q15, d23, d0[0]
    vmlal.s16 q8 , d22, d0[1]
    vmlal.s16 q9 , d23, d0[1]
    vmlal.s16 q14, d4, d0[1]
    vmlal.s16 q15, d5, d0[1]
    vmlal.s16 q8 , d4, d0[2]
    vmlal.s16 q9 , d5, d0[2]
    vmlal.s16 q14, d6, d0[2]
    vmlal.s16 q15, d7, d0[2]
    vmlal.s16 q8 , d6, d0[3]
    vmlal.s16 q9 , d7, d0[3]
    vmlal.s16 q14, d2, d0[3]
    vmlal.s16 q15, d3, d0[3]

    vqrshrun.s32 d16, q8, #10
    vqrshrun.s32 d17, q9, #10
    vqrshrun.s32 d18, q14, #10
    vqrshrun.s32 d19, q15, #10

    vmin.u16 q12, q12, q6
    vmin.u16 q13, q13, q6
    vmin.u16 q8, q8, q6
    vmin.u16 q9, q9, q6

    subs r5, r5, #4
    mov r11, r10
    vst1.32 {q12}, [r2], r3
    vst1.32 {q13}, [r2], r3
    vst1.32 {q8}, [r2], r3
    vst1.32 {q9}, [r2], r3
    bgt if_hor_ver_chroma_w8_ver_10bit_loop_y

if_hor_ver_chroma_w8_end:
    add sp, sp, r9                     // (32 + 4)*8*sizeof(short)

    vpop {q4, q5, q6}
    pop  {r4-r11, pc}

//void uavs3d_if_hor_ver_chroma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8n 0- *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_chroma_w16_armv7
    push    {r4-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r4, r5, r6, r7, r8}
    sub     sp, sp, #28
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1

    vdup.u16 q6, r8

    // r9-->tmp
    mov r4, #68
    lsl r4, r4, #5
    sub r9, sp, r4                      // (64 + 4)*16*sizeof(short)
    mov sp, r9

    sub r0, r0, r1                      // src += -1 * i_src;

//--------------------------------
// HOR
//--------------------------------
    vld1.32  {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q0, d4
    sub r0, r0, #4                      // x - 1 UV
    sub r1, r1, #32

    cmp r8, #255
    bgt if_hor_ver_chroma_w16_10bit

    add r8, r5, #3
if_hor_ver_chroma_w16_hor_loop_y:
    vld1.8 {q10, q11}, [r0]!            // src[x-1]
    vld1.8 {q12}, [r0], r1

    vext.i32 q1, q10, q11, #1           // src[x]
    vext.i32 q2, q10, q11, #2           // src[x+1]
    vext.i32 q3, q10, q11, #3           // src[x+2]

    vext.i32 q13, q11, q12, #1          // src[x+8]
    vext.i32 q14, q11, q12, #2          // src[x+9]
    vext.i32 q15, q11, q12, #3          // src[x+10]

    vmul.u16 q4, q1 , d0[1]
    vmul.u16 q5, q13, d0[1]
    vmls.u16 q4, q10, d0[0]
    vmls.u16 q5, q11, d0[0]
    vmla.u16 q4, q2 , d0[2]
    vmla.u16 q5, q14, d0[2]
    vmls.u16 q4, q3 , d0[3]
    vmls.u16 q5, q15, d0[3]

    subs r8, r8, #1
    vst1.64 {q4, q5}, [r9]!
    bgt if_hor_ver_chroma_w16_hor_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r9, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_chroma_w16_ver_loop_y:
    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    mov r7, r9
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vld1.64 {q8, q9}, [r9]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    vst1.32 {q2, q3}, [r2], r3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d24, d0[1]
    vmlal.s16 q3, d25, d0[1]
    vmlal.s16 q4, d26, d0[1]
    vmlal.s16 q5, d27, d0[1]
    vmlal.s16 q2, d28, d0[2]
    vmlal.s16 q3, d29, d0[2]
    vmlal.s16 q4, d30, d0[2]
    vmlal.s16 q5, d31, d0[2]
    vmlal.s16 q2, d16, d0[3]
    vmlal.s16 q3, d17, d0[3]
    vmlal.s16 q4, d18, d0[3]
    vmlal.s16 q5, d19, d0[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    subs r5, r5, #2
    mov r9, r7                    // tmp += 64;
    vst1.32 {q2, q3}, [r2], r3
    bgt if_hor_ver_chroma_w16_ver_loop_y
    b   if_hor_ver_chroma_w16_end

if_hor_ver_chroma_w16_10bit:
    add r8, r5, #3
if_hor_ver_chroma_w16_hor_10bit_loop_y:
    vld1.8 {q10, q11}, [r0]!        // src[x-1]
    vld1.8 {q12}, [r0], r1

    vext.i32 q1, q10, q11, #1       // src[x]
    vext.i32 q2, q10, q11, #2       // src[x+1]
    vext.i32 q3, q10, q11, #3       // src[x+2]

    vmull.u16 q4, d2 , d0[1]
    vmull.u16 q5, d3 , d0[1]
    vmlsl.u16 q4, d20, d0[0]
    vmlsl.u16 q5, d21, d0[0]
    vmlal.u16 q4, d4 , d0[2]
    vmlal.u16 q5, d5 , d0[2]
    vmlsl.u16 q4, d6 , d0[3]
    vmlsl.u16 q5, d7 , d0[3]

    vext.i32 q1, q11, q12, #1       // src[x+8]
    vext.i32 q2, q11, q12, #2       // src[x+9]
    vext.i32 q3, q11, q12, #3       // src[x+10]

    vrshrn.s32 d26, q4, #2
    vrshrn.s32 d27, q5, #2

    vmull.u16 q4, d2 , d0[1]
    vmull.u16 q5, d3 , d0[1]
    vmlsl.u16 q4, d22, d0[0]
    vmlsl.u16 q5, d23, d0[0]
    vmlal.u16 q4, d4 , d0[2]
    vmlal.u16 q5, d5 , d0[2]
    vmlsl.u16 q4, d6 , d0[3]
    vmlsl.u16 q5, d7 , d0[3]

    vrshrn.s32 d28, q4, #2
    vrshrn.s32 d29, q5, #2

    subs r8, r8, #1
    vst1.64 {q13, q14}, [r9]!
    bgt if_hor_ver_chroma_w16_hor_10bit_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r9, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_chroma_w16_ver_10bit_loop_y:
    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    mov r7, r9
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vld1.64 {q8, q9}, [r9]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    vst1.32 {q2, q3}, [r2], r3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d24, d0[1]
    vmlal.s16 q3, d25, d0[1]
    vmlal.s16 q4, d26, d0[1]
    vmlal.s16 q5, d27, d0[1]
    vmlal.s16 q2, d28, d0[2]
    vmlal.s16 q3, d29, d0[2]
    vmlal.s16 q4, d30, d0[2]
    vmlal.s16 q5, d31, d0[2]
    vmlal.s16 q2, d16, d0[3]
    vmlal.s16 q3, d17, d0[3]
    vmlal.s16 q4, d18, d0[3]
    vmlal.s16 q5, d19, d0[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    subs r5, r5, #2
    mov r9, r7                    // tmp += 64;
    vst1.32 {q2, q3}, [r2], r3
    bgt if_hor_ver_chroma_w16_ver_10bit_loop_y

if_hor_ver_chroma_w16_end:
    add sp, sp, r4                  // (64 + 4)*16*sizeof(short)

    vpop {q4, q5, q6}
    pop  {r4-r9, pc}


//void uavs3d_if_hor_ver_chroma_w16x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8n 0- *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_chroma_w16x_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7, r8}
    sub     sp, sp, #36
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1

    vdup.u16 q6, r8

    // r11-->tmp
    mov r9, #68
    lsl r9, r9, #8
    sub r11, sp, r9                 // (64 + 4)*128*sizeof(short)
    mov sp, r11

    sub r0, r0, r1                  // src += -1 * i_src;

//--------------------------------
// HOR
//--------------------------------
    vld1.32  {d4[0]}, [r6]
    vabs.s8 d4, d4
    vmovl.u8 q0, d4

    sub r0, r0, #4                  // x - 1 UV

    cmp r8, #255
    bgt if_hor_ver_chroma_w16x_10bit

    add r8, r5, #3                  // i
if_hor_ver_chroma_w16x_hor_loop_y:
    mov r9, r4                      // j
    mov r10, r0
if_hor_ver_chroma_w16x_hor_loop_x:
    vld1.16 {q10, q11}, [r10]!      // src[x-1]
    vld1.16 {q12}, [r10]

    vext.i32 q1, q10, q11, #1       // src[x]
    vext.i32 q2, q10, q11, #2       // src[x+1]
    vext.i32 q3, q10, q11, #3       // src[x+2]

    vext.i32 q13, q11, q12, #1      // src[x+8]
    vext.i32 q14, q11, q12, #2      // src[x+9]
    vext.i32 q15, q11, q12, #3      // src[x+10]

    vmul.u16 q4, q1 , d0[1]
    vmul.u16 q5, q13, d0[1]
    vmls.u16 q4, q10, d0[0]
    vmls.u16 q5, q11, d0[0]
    vmla.u16 q4, q2 , d0[2]
    vmla.u16 q5, q14, d0[2]
    vmls.u16 q4, q3 , d0[3]
    vmls.u16 q5, q15, d0[3]

    subs r9, r9, #16
    vst1.64 {q4, q5}, [r11]!
    bgt if_hor_ver_chroma_w16x_hor_loop_x
    subs r8, r8, #1
    add r0, r0, r1
    bgt if_hor_ver_chroma_w16x_hor_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r11, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    lsl r6, r4, #1                  // tmp_stride = width*2
if_hor_ver_chroma_w16x_ver_loop_y:
    mov r9, #0
if_hor_ver_chroma_w16x_ver_loop_x:
    add r10, r11, r9, lsl #1
    add r7, r2, r9, lsl #1
    vld1.64 {q8, q9}, [r10], r6
    vld1.64 {q10, q11}, [r10], r6
    vld1.64 {q12, q13}, [r10], r6
    vld1.64 {q14, q15}, [r10], r6

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vld1.64 {q8, q9}, [r10]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    vst1.32 {q2, q3}, [r7], r3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d24, d0[1]
    vmlal.s16 q3, d25, d0[1]
    vmlal.s16 q4, d26, d0[1]
    vmlal.s16 q5, d27, d0[1]
    vmlal.s16 q2, d28, d0[2]
    vmlal.s16 q3, d29, d0[2]
    vmlal.s16 q4, d30, d0[2]
    vmlal.s16 q5, d31, d0[2]
    vmlal.s16 q2, d16, d0[3]
    vmlal.s16 q3, d17, d0[3]
    vmlal.s16 q4, d18, d0[3]
    vmlal.s16 q5, d19, d0[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    add r9, r9, #16
    vst1.32 {q2, q3}, [r7]

    //--------------------------------
    // loop control
    //--------------------------------
    cmp r9, r4
    blt if_hor_ver_chroma_w16x_ver_loop_x

    subs r5, r5, #2
    add r11, r11, r6, lsl #1        // tmp += 64;
    add r2, r2, r3, lsl #1
    bgt if_hor_ver_chroma_w16x_ver_loop_y
    b   if_hor_ver_chroma_w16x_end

if_hor_ver_chroma_w16x_10bit:
    add r8, r5, #3                  // i
if_hor_ver_chroma_w16x_hor_10bit_loop_y:
    mov r9, r4                      // j
    mov r10, r0
if_hor_ver_chroma_w16x_hor_10bit_loop_x:
    vld1.16 {q10, q11}, [r10]!      // src[x-1]
    vld1.16 {q12}, [r10]

    vext.i32 q1, q10, q11, #1       // src[x]
    vext.i32 q2, q10, q11, #2       // src[x+1]
    vext.i32 q3, q10, q11, #3       // src[x+2]

    vmull.u16 q4, d2 , d0[1]
    vmull.u16 q5, d3 , d0[1]
    vmlsl.u16 q4, d20, d0[0]
    vmlsl.u16 q5, d21, d0[0]
    vmlal.u16 q4, d4 , d0[2]
    vmlal.u16 q5, d5 , d0[2]
    vmlsl.u16 q4, d6 , d0[3]
    vmlsl.u16 q5, d7 , d0[3]

    vext.i32 q1, q11, q12, #1       // src[x+8]
    vext.i32 q2, q11, q12, #2       // src[x+9]
    vext.i32 q3, q11, q12, #3       // src[x+10]

    vrshrn.s32 d26, q4, #2
    vrshrn.s32 d27, q5, #2

    vmull.u16 q4, d2 , d0[1]
    vmull.u16 q5, d3 , d0[1]
    vmlsl.u16 q4, d22, d0[0]
    vmlsl.u16 q5, d23, d0[0]
    vmlal.u16 q4, d4 , d0[2]
    vmlal.u16 q5, d5 , d0[2]
    vmlsl.u16 q4, d6 , d0[3]
    vmlsl.u16 q5, d7 , d0[3]

    vrshrn.s32 d28, q4, #2
    vrshrn.s32 d29, q5, #2

    subs r9, r9, #16
    vst1.64 {q13, q14}, [r11]!
    bgt if_hor_ver_chroma_w16x_hor_10bit_loop_x

    subs r8, r8, #1
    add r0, r0, r1
    bgt if_hor_ver_chroma_w16x_hor_10bit_loop_y

//--------------------------------
// VER
//--------------------------------
    mov r11, sp

    vld1.32 {d0[0]}, [r7]           // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    lsl r6, r4, #1                  // tmp_stride = width*2
if_hor_ver_chroma_w16x_ver_10bit_loop_y:
    mov r9, #0
if_hor_ver_chroma_w16x_ver_10bit_loop_x:
    add r10, r11, r9, lsl #1
    add r7, r2, r9, lsl #1
    vld1.64 {q8, q9}, [r10], r6
    vld1.64 {q10, q11}, [r10], r6
    vld1.64 {q12, q13}, [r10], r6
    vld1.64 {q14, q15}, [r10], r6

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vld1.64 {q8, q9}, [r10]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    vst1.32 {q2, q3}, [r7], r3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d24, d0[1]
    vmlal.s16 q3, d25, d0[1]
    vmlal.s16 q4, d26, d0[1]
    vmlal.s16 q5, d27, d0[1]
    vmlal.s16 q2, d28, d0[2]
    vmlal.s16 q3, d29, d0[2]
    vmlal.s16 q4, d30, d0[2]
    vmlal.s16 q5, d31, d0[2]
    vmlal.s16 q2, d16, d0[3]
    vmlal.s16 q3, d17, d0[3]
    vmlal.s16 q4, d18, d0[3]
    vmlal.s16 q5, d19, d0[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    add r9, r9, #16
    vst1.32 {q2, q3}, [r7]

    //--------------------------------
    // loop control
    //--------------------------------
    cmp r9, r4
    blt if_hor_ver_chroma_w16x_ver_10bit_loop_x

    subs r5, r5, #2
    add r11, r11, r6, lsl #1        // tmp += 64;
    add r2, r2, r3, lsl #1
    bgt if_hor_ver_chroma_w16x_ver_10bit_loop_y

if_hor_ver_chroma_w16x_end:

    mov r7, #68
    lsl r7, r7, #8
    add sp, sp, r7                  // (64 + 4)*128*sizeof(short)

    vpop {q4, q5, q6}
    pop  {r4-r11, pc}


//void uavs3d_if_hor_ver_luma_w4_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w4_armv7
    push    {r4-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r4, r5, r6, r7, r8}
    sub     sp, sp, #28

    vpush {q4}

    lsl r1, r1, #1
    lsl r3, r3, #1

    vdup.u16 q4, r8

    // r9-->tmp
    ldr r4, =320                         // (32 + 8) * 4 * sizeof(short)
    sub r9, sp, r4
    mov sp,  r9

    sub r0, r0, r1, lsl #1              // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q0, d7

    sub r0, r0, #6                      // src -= 3

    cmp r8, #255
    bgt if_hor_ver_luma_w4_10bit

//--------------------------------
// HOR
//--------------------------------
    vld1.16 {q13, q14}, [r0], r1        // src[x-3]
    vext.i16 d18, d26, d27, #1          // src[x-2]
    vext.i16 d19, d26, d27, #2
    vext.i16 d20, d26, d27, #3
    // d27: src[x+1]
    vext.i16 d22, d27, d28, #1
    vext.i16 d23, d27, d28, #2
    vext.i16 d24, d27, d28, #3

    vmul.u16 d30, d18, d0[1]
    vmls.u16 d30, d26, d0[0]
    vmls.u16 d30, d19, d0[2]
    vmla.u16 d30, d20, d0[3]
    vmla.u16 d30, d27, d1[0]
    vmls.u16 d30, d22, d1[1]
    vmla.u16 d30, d23, d1[2]
    vmls.u16 d30, d24, d1[3]

    vst1.64 {d30}, [r9]!

    add r8, r5, #6                      // loop height+6 times
if_hor_ver_luma_w4_hor_loop_y:
    vld1.16 {q2, q3}, [r0], r1          // src[x-3]
    vld1.16 {q8, q9}, [r0], r1
    vzip.16 q2, q8
    vzip.16 q3, q9

    vext.i32 q10, q2, q8, #1
    vext.i32 q11, q2, q8, #2
    vext.i32 q12, q2, q8, #3
    // q8:
    vext.i32 q14, q8, q3, #1
    vext.i32 q15, q8, q3, #2
    vext.i32 q9 , q8, q3, #3

    vmul.u16 q1, q10, d0[1]
    vmls.u16 q1, q2 , d0[0]
    vmls.u16 q1, q11, d0[2]
    vmla.u16 q1, q12, d0[3]
    vmla.u16 q1, q8 , d1[0]
    vmls.u16 q1, q14, d1[1]
    vmla.u16 q1, q15, d1[2]
    vmls.u16 q1, q9 , d1[3]

    vuzp.16 d2, d3

    subs r8, r8, #2
    vst1.32 {q1}, [r9]!
    bgt if_hor_ver_luma_w4_hor_loop_y

    mov r9, sp

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.32 {d0}, [r7]                  // load coeff
    vmovl.s8 q0, d0                     // 8bit to 16bit

if_hor_ver_luma_w4_ver_loop_y:
    vld1.64 {q10, q11}, [r9]!
    vmull.s16 q12, d20, d0[0]
    vmull.s16 q13, d21, d0[0]
    vmull.s16 q14, d22, d0[0]
    vmull.s16 q15, d23, d0[0]
    mov r7, r9
    vld1.64 {q2, q3}, [r9]!
    vmlal.s16 q12, d21, d0[1]
    vmlal.s16 q13, d22, d0[1]
    vmlal.s16 q14, d23, d0[1]
    vmlal.s16 q15, d4 , d0[1]

    vmlal.s16 q12, d22, d0[2]
    vmlal.s16 q13, d23, d0[2]
    vmlal.s16 q14, d4, d0[2]
    vmlal.s16 q15, d5, d0[2]

    vmlal.s16 q12, d23, d0[3]
    vmlal.s16 q13, d4, d0[3]
    vmlal.s16 q14, d5, d0[3]
    vmlal.s16 q15, d6, d0[3]

    vmlal.s16 q12, d4, d1[0]
    vmlal.s16 q13, d5, d1[0]
    vmlal.s16 q14, d6, d1[0]
    vmlal.s16 q15, d7, d1[0]

    vld1.64 {q1}, [r9]!
    vmlal.s16 q12, d5, d1[1]
    vmlal.s16 q13, d6, d1[1]
    vmlal.s16 q14, d7, d1[1]
    vmlal.s16 q15, d2, d1[1]

    vld1.64 {d16}, [r9]
    vmlal.s16 q12, d6, d1[2]
    vmlal.s16 q13, d7, d1[2]
    vmlal.s16 q14, d2, d1[2]
    vmlal.s16 q15, d3, d1[2]

    vmlal.s16 q12, d7, d1[3]
    vmlal.s16 q13, d2, d1[3]
    vmlal.s16 q14, d3, d1[3]
    vmlal.s16 q15, d16, d1[3]

    vqrshrun.s32 d24, q12, #12
    vqrshrun.s32 d25, q13, #12
    vqrshrun.s32 d26, q14, #12
    vqrshrun.s32 d27, q15, #12

    vmin.u16 q12, q12, q4
    vmin.u16 q13, q13, q4

    subs r5, r5, #4
    mov r9, r7
    vst1.32 {d24}, [r2], r3
    vst1.32 {d25}, [r2], r3
    vst1.32 {d26}, [r2], r3
    vst1.32 {d27}, [r2], r3
    bgt if_hor_ver_luma_w4_ver_loop_y
    b   if_hor_ver_luma_w4_end

if_hor_ver_luma_w4_10bit:
//--------------------------------
// HOR
//--------------------------------
    // first row
    vld1.16 {q13, q14}, [r0], r1        // src[x-3]
    vext.i16 d18, d26, d27, #1          // src[x-2]
    vext.i16 d19, d26, d27, #2
    vext.i16 d20, d26, d27, #3
    // d27: src[x+1]
    vext.i16 d22, d27, d28, #1
    vext.i16 d23, d27, d28, #2
    vext.i16 d24, d27, d28, #3

    vmull.u16 q15, d18, d0[1]
    vmlsl.u16 q15, d26, d0[0]
    vmlsl.u16 q15, d19, d0[2]
    vmlal.u16 q15, d20, d0[3]
    vmlal.u16 q15, d27, d1[0]
    vmlsl.u16 q15, d22, d1[1]
    vmlal.u16 q15, d23, d1[2]
    vmlsl.u16 q15, d24, d1[3]

    vrshrn.s32 d30, q15, #2
    vst1.64 {d30}, [r9]!

    add r8, r5, #6                      // loop height+7 times
if_hor_ver_luma_w4_hor_10bit_loop_y:
    vld1.16 {q2, q3}, [r0], r1          // src[x-3]
    vld1.16 {q8, q9}, [r0], r1
    vzip.16 q2, q8
    vzip.16 q3, q9

    vext.i32 q10, q2, q8, #1
    vext.i32 q11, q2, q8, #2
    vext.i32 q12, q2, q8, #3
    // q8:
    vext.i32 q13, q8, q3, #1
    vext.i32 q14, q8, q3, #2
    vext.i32 q15, q8, q3, #3

    vmull.u16 q1, d20, d0[1]
    vmull.u16 q9, d21, d0[1]
    vmlsl.u16 q1, d4 , d0[0]
    vmlsl.u16 q9, d5 , d0[0]
    vmlsl.u16 q1, d22, d0[2]
    vmlsl.u16 q9, d23, d0[2]
    vmlal.u16 q1, d24, d0[3]
    vmlal.u16 q9, d25, d0[3]
    vmlal.u16 q1, d16, d1[0]
    vmlal.u16 q9, d17, d1[0]
    vmlsl.u16 q1, d26, d1[1]
    vmlsl.u16 q9, d27, d1[1]
    vmlal.u16 q1, d28, d1[2]
    vmlal.u16 q9, d29, d1[2]
    vmlsl.u16 q1, d30, d1[3]
    vmlsl.u16 q9, d31, d1[3]

    vrshrn.s32 d2, q1, #2
    vrshrn.s32 d3, q9, #2

    vuzp.16 d2, d3

    subs r8, r8, #2
    vst1.32 {q1}, [r9]!
    bgt if_hor_ver_luma_w4_hor_10bit_loop_y

    mov r9, sp

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.32 {d0}, [r7]                  // load coeff
    vmovl.s8 q0, d0                     // 8bit to 16bit

if_hor_ver_luma_w4_ver_10bit_loop_y:
    vld1.64 {q10, q11}, [r9]!
    vmull.s16 q12, d20, d0[0]
    vmull.s16 q13, d21, d0[0]
    vmull.s16 q14, d22, d0[0]
    vmull.s16 q15, d23, d0[0]
    mov r7, r9
    vld1.64 {q2, q3}, [r9]!
    vmlal.s16 q12, d21, d0[1]
    vmlal.s16 q13, d22, d0[1]
    vmlal.s16 q14, d23, d0[1]
    vmlal.s16 q15, d4 , d0[1]

    vmlal.s16 q12, d22, d0[2]
    vmlal.s16 q13, d23, d0[2]
    vmlal.s16 q14, d4, d0[2]
    vmlal.s16 q15, d5, d0[2]

    vmlal.s16 q12, d23, d0[3]
    vmlal.s16 q13, d4, d0[3]
    vmlal.s16 q14, d5, d0[3]
    vmlal.s16 q15, d6, d0[3]

    vmlal.s16 q12, d4, d1[0]
    vmlal.s16 q13, d5, d1[0]
    vmlal.s16 q14, d6, d1[0]
    vmlal.s16 q15, d7, d1[0]

    vld1.64 {q1}, [r9]!
    vmlal.s16 q12, d5, d1[1]
    vmlal.s16 q13, d6, d1[1]
    vmlal.s16 q14, d7, d1[1]
    vmlal.s16 q15, d2, d1[1]

    vld1.64 {d16}, [r9]
    vmlal.s16 q12, d6, d1[2]
    vmlal.s16 q13, d7, d1[2]
    vmlal.s16 q14, d2, d1[2]
    vmlal.s16 q15, d3, d1[2]

    vmlal.s16 q12, d7, d1[3]
    vmlal.s16 q13, d2, d1[3]
    vmlal.s16 q14, d3, d1[3]
    vmlal.s16 q15, d16, d1[3]

    vqrshrun.s32 d24, q12, #10
    vqrshrun.s32 d25, q13, #10
    vqrshrun.s32 d26, q14, #10
    vqrshrun.s32 d27, q15, #10

    vmin.u16 q12, q12, q4
    vmin.u16 q13, q13, q4

    subs r5, r5, #4
    mov r9, r7
    vst1.32 {d24}, [r2], r3
    vst1.32 {d25}, [r2], r3
    vst1.32 {d26}, [r2], r3
    vst1.32 {d27}, [r2], r3
    bgt if_hor_ver_luma_w4_ver_10bit_loop_y

if_hor_ver_luma_w4_end:
    add sp, sp, r4

    vpop {q4}
    pop  {r4-r9, pc}


//void uavs3d_if_hor_ver_luma_w8_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w8_armv7
    push    {r4-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r4, r5, r6, r7, r8}
    sub     sp, sp, #28
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1

    vdup.u16 q6, r8

    // 9-->tmp
    mov r4, #72                         // (64 + 8) * 8 * sizeof(short)
    lsl r4, r4, #4
    sub r9, sp, r4
    mov sp,  r9

    sub r0, r0, r1, lsl #1              // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q0, d7

    sub r0, r0, #6                      // src -= 3
    cmp r8, #255
    bgt if_hor_ver_luma_w8_10bit
//--------------------------------
// HOR
//--------------------------------
    add r8, r5, #7
if_hor_ver_luma_w8_hor_loop_y:
    vld1.16 {q1, q2}, [r0], r1          // src[x-3]

    vext.i16 q10, q1, q2, #1            // src[x-2]
    vext.i16 q11, q1, q2, #2
    vext.i16 q12, q1, q2, #3
    vext.i16 q13, q1, q2, #4
    vext.i16 q14, q1, q2, #5
    vext.i16 q15, q1, q2, #6
    vext.i16 q9 , q1, q2, #7

    vmul.u16 q3, q10, d0[1]
    vmls.u16 q3, q1 , d0[0]
    vmls.u16 q3, q11, d0[2]
    vmla.u16 q3, q12, d0[3]
    vmla.u16 q3, q13, d1[0]
    vmls.u16 q3, q14, d1[1]
    vmla.u16 q3, q15, d1[2]
    vmls.u16 q3, q9 , d1[3]

    subs r8, r8, #1
    vst1.64 {q3}, [r9]!
    bgt if_hor_ver_luma_w8_hor_loop_y

    mov r9, sp

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8   {d0}, [r7]             // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_luma_w8_ver_loop_y:
    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    mov r7, r9
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!
    vld1.64 {q1}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d18, d0[1]
    vmlal.s16 q3, d19, d0[1]
    vmlal.s16 q4, d20, d0[1]
    vmlal.s16 q5, d21, d0[1]
    vmlal.s16 q2, d20, d0[2]
    vmlal.s16 q3, d21, d0[2]
    vmlal.s16 q4, d22, d0[2]
    vmlal.s16 q5, d23, d0[2]
    vmlal.s16 q2, d22, d0[3]
    vmlal.s16 q3, d23, d0[3]
    vmlal.s16 q4, d24, d0[3]
    vmlal.s16 q5, d25, d0[3]

    vld1.64 {q8, q9}, [r9]
    vmlal.s16 q2, d24, d1[0]
    vmlal.s16 q3, d25, d1[0]
    vmlal.s16 q4, d26, d1[0]
    vmlal.s16 q5, d27, d1[0]
    vmlal.s16 q2, d26, d1[1]
    vmlal.s16 q3, d27, d1[1]
    vmlal.s16 q4, d28, d1[1]
    vmlal.s16 q5, d29, d1[1]
    vmlal.s16 q2, d28, d1[2]
    vmlal.s16 q3, d29, d1[2]
    vmlal.s16 q4, d30, d1[2]
    vmlal.s16 q5, d31, d1[2]
    vmlal.s16 q2, d30, d1[3]
    vmlal.s16 q3, d31, d1[3]
    vmlal.s16 q4, d2, d1[3]
    vmlal.s16 q5, d3, d1[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    vst1.32 {q2}, [r2], r3
    vst1.32 {q3}, [r2], r3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d22, d0[1]
    vmlal.s16 q3, d23, d0[1]
    vmlal.s16 q4, d24, d0[1]
    vmlal.s16 q5, d25, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d26, d0[3]
    vmlal.s16 q3, d27, d0[3]
    vmlal.s16 q4, d28, d0[3]
    vmlal.s16 q5, d29, d0[3]
    vmlal.s16 q2, d28, d1[0]
    vmlal.s16 q3, d29, d1[0]
    vmlal.s16 q4, d30, d1[0]
    vmlal.s16 q5, d31, d1[0]
    vmlal.s16 q2, d30, d1[1]
    vmlal.s16 q3, d31, d1[1]
    vmlal.s16 q4, d2 , d1[1]
    vmlal.s16 q5, d3 , d1[1]
    vmlal.s16 q2, d2 , d1[2]
    vmlal.s16 q3, d3 , d1[2]
    vmlal.s16 q4, d16, d1[2]
    vmlal.s16 q5, d17, d1[2]
    vmlal.s16 q2, d16, d1[3]
    vmlal.s16 q3, d17, d1[3]
    vmlal.s16 q4, d18, d1[3]
    vmlal.s16 q5, d19, d1[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    subs r5, r5, #4
    mov r9, r7
    vst1.32 {q2}, [r2], r3
    vst1.32 {q3}, [r2], r3
    bgt if_hor_ver_luma_w8_ver_loop_y
    b   if_hor_ver_luma_w8_end

if_hor_ver_luma_w8_10bit:
//--------------------------------
// HOR
//--------------------------------
    add r8, r5, #7
if_hor_ver_luma_w8_hor_10bit_loop_y:
    vld1.16 {q1, q2}, [r0], r1          // src[x-3]

    vext.i16 q10, q1, q2, #1            // src[x-2]
    vext.i16 q11, q1, q2, #2
    vext.i16 q12, q1, q2, #3
    vext.i16 q13, q1, q2, #4
    vext.i16 q14, q1, q2, #5
    vext.i16 q15, q1, q2, #6
    vext.i16 q9, q1, q2, #7

    vmull.u16 q4, d20, d0[1]
    vmull.u16 q5, d21, d0[1]
    vmlsl.u16 q4, d2 , d0[0]
    vmlsl.u16 q5, d3 , d0[0]
    vmlsl.u16 q4, d22, d0[2]
    vmlsl.u16 q5, d23, d0[2]
    vmlal.u16 q4, d24, d0[3]
    vmlal.u16 q5, d25, d0[3]
    vmlal.u16 q4, d26, d1[0]
    vmlal.u16 q5, d27, d1[0]
    vmlsl.u16 q4, d28, d1[1]
    vmlsl.u16 q5, d29, d1[1]
    vmlal.u16 q4, d30, d1[2]
    vmlal.u16 q5, d31, d1[2]
    vmlsl.u16 q4, d18, d1[3]
    vmlsl.u16 q5, d19, d1[3]

    vrshrn.s32 d8, q4, #2
    vrshrn.s32 d9, q5, #2

    subs r8, r8, #1
    vst1.64 {q4}, [r9]!
    bgt if_hor_ver_luma_w8_hor_10bit_loop_y

    mov r9, sp

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8   {d0}, [r7]             // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

if_hor_ver_luma_w8_ver_10bit_loop_y:
    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    mov r7, r9
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!
    vld1.64 {q1}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d18, d0[1]
    vmlal.s16 q3, d19, d0[1]
    vmlal.s16 q4, d20, d0[1]
    vmlal.s16 q5, d21, d0[1]
    vmlal.s16 q2, d20, d0[2]
    vmlal.s16 q3, d21, d0[2]
    vmlal.s16 q4, d22, d0[2]
    vmlal.s16 q5, d23, d0[2]
    vmlal.s16 q2, d22, d0[3]
    vmlal.s16 q3, d23, d0[3]
    vmlal.s16 q4, d24, d0[3]
    vmlal.s16 q5, d25, d0[3]

    vld1.64 {q8, q9}, [r9]
    vmlal.s16 q2, d24, d1[0]
    vmlal.s16 q3, d25, d1[0]
    vmlal.s16 q4, d26, d1[0]
    vmlal.s16 q5, d27, d1[0]
    vmlal.s16 q2, d26, d1[1]
    vmlal.s16 q3, d27, d1[1]
    vmlal.s16 q4, d28, d1[1]
    vmlal.s16 q5, d29, d1[1]
    vmlal.s16 q2, d28, d1[2]
    vmlal.s16 q3, d29, d1[2]
    vmlal.s16 q4, d30, d1[2]
    vmlal.s16 q5, d31, d1[2]
    vmlal.s16 q2, d30, d1[3]
    vmlal.s16 q3, d31, d1[3]
    vmlal.s16 q4, d2, d1[3]
    vmlal.s16 q5, d3, d1[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    vst1.32 {q2}, [r2], r3
    vst1.32 {q3}, [r2], r3

    vmull.s16 q2, d20, d0[0]
    vmull.s16 q3, d21, d0[0]
    vmull.s16 q4, d22, d0[0]
    vmull.s16 q5, d23, d0[0]
    vmlal.s16 q2, d22, d0[1]
    vmlal.s16 q3, d23, d0[1]
    vmlal.s16 q4, d24, d0[1]
    vmlal.s16 q5, d25, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d26, d0[3]
    vmlal.s16 q3, d27, d0[3]
    vmlal.s16 q4, d28, d0[3]
    vmlal.s16 q5, d29, d0[3]
    vmlal.s16 q2, d28, d1[0]
    vmlal.s16 q3, d29, d1[0]
    vmlal.s16 q4, d30, d1[0]
    vmlal.s16 q5, d31, d1[0]
    vmlal.s16 q2, d30, d1[1]
    vmlal.s16 q3, d31, d1[1]
    vmlal.s16 q4, d2 , d1[1]
    vmlal.s16 q5, d3 , d1[1]
    vmlal.s16 q2, d2 , d1[2]
    vmlal.s16 q3, d3 , d1[2]
    vmlal.s16 q4, d16, d1[2]
    vmlal.s16 q5, d17, d1[2]
    vmlal.s16 q2, d16, d1[3]
    vmlal.s16 q3, d17, d1[3]
    vmlal.s16 q4, d18, d1[3]
    vmlal.s16 q5, d19, d1[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    subs r5, r5, #4
    mov r9, r7
    vst1.32 {q2}, [r2], r3
    vst1.32 {q3}, [r2], r3
    bgt if_hor_ver_luma_w8_ver_10bit_loop_y

if_hor_ver_luma_w8_end:
    add sp, sp, r4

    vpop {q4, q5, q6}
    pop  {r4-r9, lr}
    mov  pc, lr


//void uavs3d_if_hor_ver_luma_w16_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w16_armv7
    push    {r4-r9, lr}
    add     sp, sp, #28
    ldmia   sp, {r4, r5, r6, r7, r8}
    sub     sp, sp, #28
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1

    vdup.u16 q6, r8

    // r9-->tmp
    mov r4, #136                        // (128 + 8) * 16 * sizeof(short)
    lsl r4, r4, #5
    sub r9, sp, r4
    mov sp, r9

    sub r0, r0, r1, lsl #1              // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q0, d7

    sub r0, r0, #6                      // src -= 3
    sub r1, r1, #32

    cmp r8, #255
    bgt if_hor_ver_luma_w16_10bit

//--------------------------------
// HOR
//--------------------------------
    add r8, r5, #7
if_hor_ver_luma_w16_hor_loop_y:
    vld1.16 {q8, q9}, [r0]!             // src[x-3]
    vld1.16 {q2}, [r0], r1

    vext.i16 q10, q8, q9, #1            // src[x-2]
    vext.i16 q11, q8, q9, #2
    vext.i16 q12, q8, q9, #3
    vext.i16 q13, q8, q9, #4
    vext.i16 q14, q8, q9, #5
    vext.i16 q15, q8, q9, #6
    vext.i16 q3 , q8, q9, #7

    vmul.u16 q4, q10, d0[1]
    vmls.u16 q4, q8 , d0[0]
    vmls.u16 q4, q11, d0[2]
    vmla.u16 q4, q12, d0[3]
    vmla.u16 q4, q13, d1[0]
    vmls.u16 q4, q14, d1[1]
    vmla.u16 q4, q15, d1[2]
    vmls.u16 q4, q3 , d1[3]

    vext.i16 q10, q9, q2, #1            // src[x-2]
    vext.i16 q11, q9, q2, #2
    vext.i16 q12, q9, q2, #3
    vext.i16 q13, q9, q2, #4
    vext.i16 q14, q9, q2, #5
    vext.i16 q15, q9, q2, #6
    vext.i16 q3 , q9, q2, #7

    vmul.u16 q5, q10, d0[1]
    vmls.u16 q5, q9 , d0[0]
    vmls.u16 q5, q11, d0[2]
    vmla.u16 q5, q12, d0[3]
    vmla.u16 q5, q13, d1[0]
    vmls.u16 q5, q14, d1[1]
    vmla.u16 q5, q15, d1[2]
    vmls.u16 q5, q3 , d1[3]

    subs r8, r8, #1
    vst1.64 {q4, q5}, [r9]!
    bgt if_hor_ver_luma_w16_hor_loop_y

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8 {d0}, [r7]               // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    mov r9, sp                      // tmp
if_hor_ver_luma_w16_ver_loop_y:
    vld1.64 {q8, q9}, [r9]!
    mov r7, r9
    vld1.64 {q10, q11}, [r9]!
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]

    vmlal.s16 q2, d16, d1[0]
    vmlal.s16 q3, d17, d1[0]
    vmlal.s16 q4, d18, d1[0]
    vmlal.s16 q5, d19, d1[0]
    vmlal.s16 q2, d20, d1[1]
    vmlal.s16 q3, d21, d1[1]
    vmlal.s16 q4, d22, d1[1]
    vmlal.s16 q5, d23, d1[1]
    vmlal.s16 q2, d24, d1[2]
    vmlal.s16 q3, d25, d1[2]
    vmlal.s16 q4, d26, d1[2]
    vmlal.s16 q5, d27, d1[2]
    vmlal.s16 q2, d28, d1[3]
    vmlal.s16 q3, d29, d1[3]
    vmlal.s16 q4, d30, d1[3]
    vmlal.s16 q5, d31, d1[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    subs r5, r5, #1
    mov r9, r7
    vst1.64 {q2, q3}, [r2], r3
    bgt if_hor_ver_luma_w16_ver_loop_y
    b   if_hor_ver_luma_w16_end

if_hor_ver_luma_w16_10bit:
//--------------------------------
// HOR
//--------------------------------
    add r8, r5, #7
if_hor_ver_luma_w16_hor_10bit_loop_y:
    vld1.16 {q8, q9}, [r0]!             // src[x-3]
    vld1.16 {q2}, [r0], r1

    vext.i16 q10, q8, q9, #1            // src[x-2]
    vext.i16 q11, q8, q9, #2
    vext.i16 q12, q8, q9, #3
    vext.i16 q13, q8, q9, #4
    vext.i16 q14, q8, q9, #5
    vext.i16 q15, q8, q9, #6
    vext.i16 q3 , q8, q9, #7

    vmull.u16 q4, d20, d0[1]
    vmull.u16 q5, d21, d0[1]
    vmlsl.u16 q4, d16, d0[0]
    vmlsl.u16 q5, d17, d0[0]
    vmlsl.u16 q4, d22, d0[2]
    vmlsl.u16 q5, d23, d0[2]
    vmlal.u16 q4, d24, d0[3]
    vmlal.u16 q5, d25, d0[3]
    vmlal.u16 q4, d26, d1[0]
    vmlal.u16 q5, d27, d1[0]
    vmlsl.u16 q4, d28, d1[1]
    vmlsl.u16 q5, d29, d1[1]
    vmlal.u16 q4, d30, d1[2]
    vmlal.u16 q5, d31, d1[2]
    vmlsl.u16 q4, d6 , d1[3]
    vmlsl.u16 q5, d7 , d1[3]

    vrshrn.s32 d8, q4, #2
    vrshrn.s32 d9, q5, #2

    vext.i16 q10, q9, q2, #1            // src[x-2]
    vext.i16 q11, q9, q2, #2
    vext.i16 q12, q9, q2, #3
    vext.i16 q13, q9, q2, #4
    vext.i16 q14, q9, q2, #5
    vext.i16 q15, q9, q2, #6
    vext.i16 q3 , q9, q2, #7

    vst1.64 {q4}, [r9]!

    vmull.u16 q4, d20, d0[1]
    vmull.u16 q5, d21, d0[1]
    vmlsl.u16 q4, d18, d0[0]
    vmlsl.u16 q5, d19, d0[0]
    vmlsl.u16 q4, d22, d0[2]
    vmlsl.u16 q5, d23, d0[2]
    vmlal.u16 q4, d24, d0[3]
    vmlal.u16 q5, d25, d0[3]
    vmlal.u16 q4, d26, d1[0]
    vmlal.u16 q5, d27, d1[0]
    vmlsl.u16 q4, d28, d1[1]
    vmlsl.u16 q5, d29, d1[1]
    vmlal.u16 q4, d30, d1[2]
    vmlal.u16 q5, d31, d1[2]
    vmlsl.u16 q4, d6 , d1[3]
    vmlsl.u16 q5, d7 , d1[3]

    vrshrn.s32 d8, q4, #2
    vrshrn.s32 d9, q5, #2

    subs r8, r8, #1
    vst1.64 {q4}, [r9]!
    bgt if_hor_ver_luma_w16_hor_10bit_loop_y

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8 {d0}, [r7]               // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    mov r9, sp                      // tmp

if_hor_ver_luma_w16_ver_10bit_loop_y:
    vld1.64 {q8, q9}, [r9]!
    mov r7, r9
    vld1.64 {q10, q11}, [r9]!
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]!

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vld1.64 {q8, q9}, [r9]!
    vld1.64 {q10, q11}, [r9]!
    vld1.64 {q12, q13}, [r9]!
    vld1.64 {q14, q15}, [r9]

    vmlal.s16 q2, d16, d1[0]
    vmlal.s16 q3, d17, d1[0]
    vmlal.s16 q4, d18, d1[0]
    vmlal.s16 q5, d19, d1[0]
    vmlal.s16 q2, d20, d1[1]
    vmlal.s16 q3, d21, d1[1]
    vmlal.s16 q4, d22, d1[1]
    vmlal.s16 q5, d23, d1[1]
    vmlal.s16 q2, d24, d1[2]
    vmlal.s16 q3, d25, d1[2]
    vmlal.s16 q4, d26, d1[2]
    vmlal.s16 q5, d27, d1[2]
    vmlal.s16 q2, d28, d1[3]
    vmlal.s16 q3, d29, d1[3]
    vmlal.s16 q4, d30, d1[3]
    vmlal.s16 q5, d31, d1[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    subs r5, r5, #1
    mov r9, r7
    vst1.64 {q2, q3}, [r2], r3
    bgt if_hor_ver_luma_w16_ver_10bit_loop_y

if_hor_ver_luma_w16_end:
    add sp, sp, r4

    vpop {q4, q5, q6}
    pop  {r4-r9, pc}


//void uavs3d_if_hor_ver_luma_w16x_armv7(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff_h, const s8 *coeff_v, int max_val)
//src->r0, i_src->r1, dst->r2, i_dst->r3, width->r4, height->r5, coeff_h->r6, coeff_v->r7, max_val = 255
function uavs3d_if_hor_ver_luma_w16x_armv7
    push    {r4-r11, lr}
    add     sp, sp, #36
    ldmia   sp, {r4, r5, r6, r7, r8}
    sub     sp, sp, #36
    vpush   {q4, q5, q6}

    lsl r1, r1, #1
    lsl r3, r3, #1

    vdup.u16 q6, r8

    // r9-->tmp
    mov r10, #136                       // (128 + 8) * 128 * sizeof(short)
    lsl r10, r10, #8
    sub r9, sp, r10
    mov sp, r9

    sub r0, r0, r1, lsl #1              // src += -3 * i_src;
    sub r0, r0, r1

    vld1.8 {d7}, [r6]
    vabs.s8 d7, d7
    vmovl.u8 q0, d7

    sub r0, r0, #6                      // src -= 3

    cmp r8, #255
    bgt if_hor_ver_luma_w16x_10bit

//--------------------------------
// HOR
//--------------------------------
    add r8, r5, #7
if_hor_ver_luma_w16x_hor_loop_y:
    mov r6, r4
    mov r10, r0
if_hor_ver_luma_w16x_hor_loop_x:
    vld1.16 {q8, q9}, [r10]!            // src[x-3]
    vld1.16 {q2}, [r10]

    vext.i16 q10, q8, q9, #1            // src[x-2]
    vext.i16 q11, q8, q9, #2
    vext.i16 q12, q8, q9, #3
    vext.i16 q13, q8, q9, #4
    vext.i16 q14, q8, q9, #5
    vext.i16 q15, q8, q9, #6
    vext.i16 q3 , q8, q9, #7

    vmul.u16 q4, q10, d0[1]
    vmls.u16 q4, q8 , d0[0]
    vmls.u16 q4, q11, d0[2]
    vmla.u16 q4, q12, d0[3]
    vmla.u16 q4, q13, d1[0]
    vmls.u16 q4, q14, d1[1]
    vmla.u16 q4, q15, d1[2]
    vmls.u16 q4, q3 , d1[3]

    vext.i16 q10, q9, q2, #1            // src[x-2]
    vext.i16 q11, q9, q2, #2
    vext.i16 q12, q9, q2, #3
    vext.i16 q13, q9, q2, #4
    vext.i16 q14, q9, q2, #5
    vext.i16 q15, q9, q2, #6
    vext.i16 q3 , q9, q2, #7

    vmul.u16 q5, q10, d0[1]
    vmls.u16 q5, q9 , d0[0]
    vmls.u16 q5, q11, d0[2]
    vmla.u16 q5, q12, d0[3]
    vmla.u16 q5, q13, d1[0]
    vmls.u16 q5, q14, d1[1]
    vmla.u16 q5, q15, d1[2]
    vmls.u16 q5, q3 , d1[3]

    subs r6, r6, #16
    vst1.64 {q4, q5}, [r9]!
    bgt if_hor_ver_luma_w16x_hor_loop_x

    subs r8, r8, #1
    add r0, r0, r1
    bgt if_hor_ver_luma_w16x_hor_loop_y

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8 {d0}, [r7]               // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    mov r9, sp                      // tmp
    lsl r11, r4, #1                 // tmpstride
if_hor_ver_luma_w16x_ver_loop_y:
    mov r6, #0
    mov r10, r2
if_hor_ver_luma_w16x_ver_loop_x:
    add r7, r9, r6, lsl #1
    vld1.64 {q8, q9}, [r7], r11
    vld1.64 {q10, q11}, [r7], r11
    vld1.64 {q12, q13}, [r7], r11
    vld1.64 {q14, q15}, [r7], r11

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vld1.64 {q8, q9}, [r7], r11
    vld1.64 {q10, q11}, [r7], r11
    vld1.64 {q12, q13}, [r7], r11
    vld1.64 {q14, q15}, [r7]

    vmlal.s16 q2, d16, d1[0]
    vmlal.s16 q3, d17, d1[0]
    vmlal.s16 q4, d18, d1[0]
    vmlal.s16 q5, d19, d1[0]
    vmlal.s16 q2, d20, d1[1]
    vmlal.s16 q3, d21, d1[1]
    vmlal.s16 q4, d22, d1[1]
    vmlal.s16 q5, d23, d1[1]
    vmlal.s16 q2, d24, d1[2]
    vmlal.s16 q3, d25, d1[2]
    vmlal.s16 q4, d26, d1[2]
    vmlal.s16 q5, d27, d1[2]
    vmlal.s16 q2, d28, d1[3]
    vmlal.s16 q3, d29, d1[3]
    vmlal.s16 q4, d30, d1[3]
    vmlal.s16 q5, d31, d1[3]

    vqrshrun.s32 d4, q2, #12
    vqrshrun.s32 d5, q3, #12
    vqrshrun.s32 d6, q4, #12
    vqrshrun.s32 d7, q5, #12

    add r6, r6, #16
    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    cmp r6, r4
    vst1.64 {q2, q3}, [r10]!

    blt if_hor_ver_luma_w16x_ver_loop_x

    subs r5, r5, #1
    add r2, r2, r3
    add r9, r9, r11
    bgt if_hor_ver_luma_w16x_ver_loop_y
    b   if_hor_ver_luma_w16x_end

if_hor_ver_luma_w16x_10bit:
//--------------------------------
// HOR
//--------------------------------
    add r8, r5, #7
if_hor_ver_luma_w16x_hor_10bit_loop_y:
    mov r6, r4
    mov r10, r0
if_hor_ver_luma_w16x_hor_10bit_loop_x:
    vld1.16 {q8, q9}, [r10]!            // src[x-3]
    vld1.16 {q2}, [r10]

    vext.i16 q10, q8, q9, #1            // src[x-2]
    vext.i16 q11, q8, q9, #2
    vext.i16 q12, q8, q9, #3
    vext.i16 q13, q8, q9, #4
    vext.i16 q14, q8, q9, #5
    vext.i16 q15, q8, q9, #6
    vext.i16 q3 , q8, q9, #7

    vmull.u16 q4, d20, d0[1]
    vmull.u16 q5, d21, d0[1]
    vmlsl.u16 q4, d16, d0[0]
    vmlsl.u16 q5, d17, d0[0]
    vmlsl.u16 q4, d22, d0[2]
    vmlsl.u16 q5, d23, d0[2]
    vmlal.u16 q4, d24, d0[3]
    vmlal.u16 q5, d25, d0[3]
    vmlal.u16 q4, d26, d1[0]
    vmlal.u16 q5, d27, d1[0]
    vmlsl.u16 q4, d28, d1[1]
    vmlsl.u16 q5, d29, d1[1]
    vmlal.u16 q4, d30, d1[2]
    vmlal.u16 q5, d31, d1[2]
    vmlsl.u16 q4, d6 , d1[3]
    vmlsl.u16 q5, d7 , d1[3]

    vrshrn.s32 d8, q4, #2
    vrshrn.s32 d9, q5, #2

    vext.i16 q10, q9, q2, #1            // src[x-2]
    vext.i16 q11, q9, q2, #2
    vext.i16 q12, q9, q2, #3
    vext.i16 q13, q9, q2, #4
    vext.i16 q14, q9, q2, #5
    vext.i16 q15, q9, q2, #6
    vext.i16 q3 , q9, q2, #7

    vst1.64 {q4}, [r9]!

    vmull.u16 q4, d20, d0[1]
    vmull.u16 q5, d21, d0[1]
    vmlsl.u16 q4, d18, d0[0]
    vmlsl.u16 q5, d19, d0[0]
    vmlsl.u16 q4, d22, d0[2]
    vmlsl.u16 q5, d23, d0[2]
    vmlal.u16 q4, d24, d0[3]
    vmlal.u16 q5, d25, d0[3]
    vmlal.u16 q4, d26, d1[0]
    vmlal.u16 q5, d27, d1[0]
    vmlsl.u16 q4, d28, d1[1]
    vmlsl.u16 q5, d29, d1[1]
    vmlal.u16 q4, d30, d1[2]
    vmlal.u16 q5, d31, d1[2]
    vmlsl.u16 q4, d6 , d1[3]
    vmlsl.u16 q5, d7 , d1[3]

    vrshrn.s32 d8, q4, #2
    vrshrn.s32 d9, q5, #2

    subs r6, r6, #16
    vst1.64 {q4}, [r9]!
    bgt if_hor_ver_luma_w16x_hor_10bit_loop_x

    subs r8, r8, #1
    add r0, r0, r1
    bgt if_hor_ver_luma_w16x_hor_10bit_loop_y

//--------------------------------
// VER
//--------------------------------

    // load coeffs
    vld1.8 {d0}, [r7]               // load coeff
    vmovl.s8 q0, d0                 // 8bit to 16bit

    mov r9, sp                      // tmp
    lsl r11, r4, #1                 // tmpstride
if_hor_ver_luma_w16x_ver_10bit_loop_y:
    mov r6, #0
    mov r10, r2
if_hor_ver_luma_w16x_ver_10bit_loop_x:
    add r7, r9, r6, lsl #1
    vld1.64 {q8, q9}, [r7], r11
    vld1.64 {q10, q11}, [r7], r11
    vld1.64 {q12, q13}, [r7], r11
    vld1.64 {q14, q15}, [r7], r11

    vmull.s16 q2, d16, d0[0]
    vmull.s16 q3, d17, d0[0]
    vmull.s16 q4, d18, d0[0]
    vmull.s16 q5, d19, d0[0]
    vmlal.s16 q2, d20, d0[1]
    vmlal.s16 q3, d21, d0[1]
    vmlal.s16 q4, d22, d0[1]
    vmlal.s16 q5, d23, d0[1]
    vmlal.s16 q2, d24, d0[2]
    vmlal.s16 q3, d25, d0[2]
    vmlal.s16 q4, d26, d0[2]
    vmlal.s16 q5, d27, d0[2]
    vmlal.s16 q2, d28, d0[3]
    vmlal.s16 q3, d29, d0[3]
    vmlal.s16 q4, d30, d0[3]
    vmlal.s16 q5, d31, d0[3]

    vld1.64 {q8, q9}, [r7], r11
    vld1.64 {q10, q11}, [r7], r11
    vld1.64 {q12, q13}, [r7], r11
    vld1.64 {q14, q15}, [r7]

    vmlal.s16 q2, d16, d1[0]
    vmlal.s16 q3, d17, d1[0]
    vmlal.s16 q4, d18, d1[0]
    vmlal.s16 q5, d19, d1[0]
    vmlal.s16 q2, d20, d1[1]
    vmlal.s16 q3, d21, d1[1]
    vmlal.s16 q4, d22, d1[1]
    vmlal.s16 q5, d23, d1[1]
    vmlal.s16 q2, d24, d1[2]
    vmlal.s16 q3, d25, d1[2]
    vmlal.s16 q4, d26, d1[2]
    vmlal.s16 q5, d27, d1[2]
    vmlal.s16 q2, d28, d1[3]
    vmlal.s16 q3, d29, d1[3]
    vmlal.s16 q4, d30, d1[3]
    vmlal.s16 q5, d31, d1[3]

    vqrshrun.s32 d4, q2, #10
    vqrshrun.s32 d5, q3, #10
    vqrshrun.s32 d6, q4, #10
    vqrshrun.s32 d7, q5, #10

    add r6, r6, #16
    vmin.u16 q2, q2, q6
    vmin.u16 q3, q3, q6

    cmp r6, r4
    vst1.64 {q2, q3}, [r10]!

    blt if_hor_ver_luma_w16x_ver_10bit_loop_x

    subs r5, r5, #1
    add r2, r2, r3
    add r9, r9, r11
    bgt if_hor_ver_luma_w16x_ver_10bit_loop_y

if_hor_ver_luma_w16x_end:
    mov r7, #136                    // (128 + 8) * 128 * sizeof(short)
    lsl r7, r7, #8
    add sp, sp, r7

    vpop {q4, q5, q6}
    pop  {r4-r11, pc}

#endif   // COMPILE_10BIT

#endif
