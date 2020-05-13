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
/*****************************************************************************************************
*  void uavs3d_deblock_ver_luma_armv7(pel *SrcPtr, int stride, int Alpha, int Beta, int flt_flag)
*  SrcPtr->r0, stride->r1, Alpha->r2, Beta->r3, flt_flag->r4
******************************************************************************************************/
function uavs3d_deblock_ver_luma_armv7
    push {r4-r7, lr}
    vpush {q4-q7}
    ldr r4, [sp, #84]
    ldr r5, [sp, #88]

    // prepare data
    vdup.s16 q15, r2                // save Alpha
    vdup.s16 q14, r3                // save Beta
    sub r0, r0, #4                  // src-4
    mov r2, r0                      // src-4

    sub r5, r1, #4
	vld1.64 {d0} , [r0] , r1        // l3
	vld1.64 {d1} , [r0] , r1        // l2
	vld1.64 {d2} , [r0] , r1        // l1
	vld1.64 {d3} , [r0] , r1        // l0
	vld1.64 {d4} , [r0] , r1        // r0
	vld1.64 {d5} , [r0] , r1        // r1
	vld1.64 {d6} , [r0] , r1	    // r2
	vld1.64 {d7} , [r0]		  	    // r3

	// transform q0.....q7
	vtrn.32     q0, q2
	vtrn.32     q1, q3

	vtrn.16     q0, q1
	vtrn.16     q2, q3

	vtrn.8      d0, d1
	vtrn.8      d2, d3
	vtrn.8      d4, d5
	vtrn.8      d6, d7

    vmovl.u8 q7, d7                 // R3
    vmovl.u8 q6, d6                 // R2
    vmovl.u8 q5, d5                 // R1
    vmovl.u8 q4, d4                 // R0
    vmovl.u8 q3, d3                 // L0
    vmovl.u8 q2, d2                 // L1
    vmovl.u8 q1, d1                 // L2
    vmovl.u8 q0, d0                 // L3

    vmov.i16 q12, #2
    vabd.u16 q8, q2, q3             // COM_ABS(L1 - L0)
    vabd.u16 q9, q4, q5             // COM_ABS(R0 - R1)
    vcgt.u16 q8, q14, q8            // COM_ABS(L1 - L0) < Beta
    vcgt.u16 q9, q14, q9            // COM_ABS(R0 - R1) < Beta
    vand  q8, q8, q12               // FlatnessL
    vand  q9, q9, q12               // FlatnessR

    vabd.u16 q10, q1, q3            // COM_ABS(L2 - L0)
    vabd.u16 q11, q4, q6            // COM_ABS(R0 - R2)
    vmov.i16 q12, #1
    vcgt.u16 q10, q14, q10          // COM_ABS(L2 - L0) < Beta
    vcgt.u16 q11, q14, q11          // COM_ABS(R0 - R2) < Beta

    vand  q10, q10, q12
    vand  q11, q11, q12
    vadd.u16 q8, q8, q10            // FlatnessL++ (saved)
    vadd.u16 q9, q9, q11            // FlatnessR++

    vadd.u16 q9, q8, q9             // flt = FlatnessL + FlatnessR (saved)

    vabd.u16 q10, q2, q3            // COM_ABS(L1 - L0)
    vabd.u16 q11, q4, q5            // COM_ABS(R0 - R1)
    vshr.u16 q12, q14, #2           // Beta/4

    vcge.u16 q10, q12, q10          // COM_ABS(L1 - L0) <= Beta / 4
    vcge.u16 q11, q12, q11          // COM_ABS(R0 - R1) <= Beta / 4
    vabd.u16 q12, q4, q3            // ABS(R0 - L0)
    vand  q10, q10, q11             // (COM_ABS(L1 - L0) <= Beta / 4) && (COM_ABS(R1 - R0) <= Beta / 4)
    vcgt.u16 q12, q15, q12          // ABS(R0 - L0) < Alpha
    vand  q10, q10, q12

    // flt == 6
    vmov.i16 q15, #6
    vmov.i16 q11, #3
    vmov.i16 q12, #4
    vmov.i16 q13, #0                // fs = 0
    vceq.u16 q15, q9, q15           // flt == 6
    vbif  q12, q11, q10
    vbit  q13, q12, q15             // fs34 (save)

    // flt == 5
    vceq.u16 q11, q2, q3            // L0 == L1
    vceq.u16 q12, q4, q5            // R1 == R0
    vand  q11, q11, q12             // (R1 == R0) && (L0 == L1)

    vmov.i16 q10, #2                // q10 = 2
    vabd.u16 q12, q2, q5            // COM_ABS(L1 - R1)
    vceq.u16 q8, q8, q10            // FlatnessL == 2
    vcgt.u16 q14, q14, q12          // COM_ABS(L1 - R1) < Beta

    vmov.i16 q12, #5
    vmov.i16 q15, #3
    vceq.u16 q12, q9, q12           // flt == 5
    vbit  q10, q15, q11             // fs23
    vbit  q13, q10, q12             // fs234

    // flt == 4
    vmov.i16 q12, #4
    vmov.i16 q10, #1
    vmov.i16 q11, #2
    vceq.u16 q12, q9, q12           // flt == 4
    vbit  q10, q11, q8              // fs12
    vbit  q13, q10, q12             // fs1234

    // flt == 3
    vmov.i16 q12, #3
    vmov.i16 q10, #0
    vmov.i16 q11, #1
    vceq.u16 q12, q9, q12           // flt == 3
    vbit  q10, q11, q14             // fs01
    vbit  q13, q10, q12             // fs01234

    // prepare flt_flag[0] & flt_flag[1]
    and r6, r4, #1
    lsr r4, r4, #8
    neg r6, r6
    and r7, r4, #1
    neg r7, r7

    vdup.s32 d28, r6                // q14: flt_flag[0] flt_flag[0] flt_flag[1] flt_flag[1]
    vdup.s32 d29, r7

    vand  q15, q13, q14             // fs & flt_flag

    // fs == 1
    vadd.u16 q8, q3, q4             // L0 + R0 (saved)
    vshl.u16 q9, q3, #1             // L0 << 1
    vshl.u16 q10, q4, #1            // R0 << 1
    vadd.u16 q12, q9 , q8           // L0 + (L0 << 1) + R0
    vadd.u16 q13, q10, q8           // L0 + (R0 << 1) + R0

    vrshr.u16 q12, q12, #2
    vrshr.u16 q13, q13, #2
    vceq.u16 q14, q15, q11          // if fs == 1
    vbif   q12, q3, q14
    vbif   q13, q4, q14

    // fs == 2
    vshl.u16 q8, q8, #1             // (L0 + R0)<<1 (saved)
    vadd.u16 q9 , q2, q4            // L1 + R0
    vadd.u16 q10, q3, q5            // L0 + R1
    vshl.u16 q11, q2, #1            // L1<<1
    vshl.u16 q14, q5, #1            // R1<<1
    vadd.u16 q9 , q8, q9            // (L0+R0)<<1 + L1 + R0
    vadd.u16 q10, q8, q10           // (L0+R0)<<1 + L0 + R1
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1

    vshl.u16 q11, q3, #3            // L0<<3
    vshl.u16 q14, q4, #3            // R0<<3
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3)>>4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3)>>4
    vmov.i16  q11, #2
    vceq.u16 q11, q15, q11          // fs == 2
    vbit   q12, q9 , q11
    vbit   q13, q10, q11

    // fs == 3; update src[0] src[-1]
    vshl.u16 q8, q8, #1             // (L0+R0)<<2 --> V16
    vshl.u16 q9, q2, #2             // L1<<2
    vshl.u16 q10, q5, #2            // R1<<2
    vadd.u16 q11, q1, q5            // L2 + R1
    vadd.u16 q14, q2, q6            // L1 + R2
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2
    vadd.u16 q10, q14, q10
    vshl.u16 q11, q3, #1            // L0 << 1
    vshl.u16 q14, q4, #1            // R0 << 1
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2 + L0<<1
    vadd.u16 q10, q14, q10
    vadd.u16 q9, q9, q8             // (L0+R0)<<2 + L2+R1 + L1<<2 + L0<<1
    vadd.u16 q10, q10, q8           // (L0+R0)<<2 + L1+R2 + R1<<2 + R0<<1

    vmov.i16 q11, #3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<2 + (L2 + R1) + L0<<1+L1<<2) >> 4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<2 + (L1 + R2) + R0<<1+R1<<2) >> 4

    vceq.u16 q11, q15, q11          // fs == 3 (saved)
    vbit   q12, q9, q11             // update L0
    vbit   q13, q10, q11

    // fs == 3; calculate src[-2] src[1]
    vadd.u16 q14, q1, q4            // L2+R0
    vadd.u16 q8, q6, q3             // R2+L0
    vshl.u16 q10, q1, #1            // L2<<1
    vshl.u16 q9, q6, #1             // R2<<1
    vadd.u16 q14, q14, q10            // L2+R0+L2<<1
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1

    vshl.u16 q10, q2, #3            // L1<<3
    vshl.u16 q9, q5, #3             // R1<<3
    vadd.u16 q14, q14, q10          // L2+R0+L2<<1 + (L1<<3)
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1 + (R1<<3)

    vshl.u16 q10, q3, #2            // L0<<2
    vshl.u16 q9, q4, #2             // R0<<2
    vadd.u16 q14, q14, q10          // ((L2+R0+L2<<1) + (L1<<3)) + L0<<2
    vadd.u16 q8, q8, q9             //

    vrshr.u16 q14, q14, #4
    vrshr.u16 q8, q8, #4
    vbif   q14, q2, q11
    vbif   q8, q5, q11              // update L1_dst and R1_dst

    // fs == 4
    vmov.i16 q9, #4
    vceq.u16 q9, q15, q9
    vpadd.i32 d20, d18, d19
    vmov r6, r7, d20
    orr	 r6, r6, r7
    cmp  r6, #0
    beq  deblock_ver_filtered

    vpush {q14}
    // if fs == 4 exist
    // calculate L0 and R0
    vadd.u16 q10, q3, q4            // L0 + R0
    vshl.u16 q14, q2, #3            // L1<<3
    vshl.u16 q11, q10, #3           // (R0+L0)<<3
    vshl.u16 q15, q5, #3            //
    vadd.u16 q14, q14, q11          // (R0+L0)<<3 + L1*8
    vadd.u16 q15, q15, q11

    vadd.u16 q10, q1, q5            // L2 + R1
    vadd.u16 q11, q2, q6
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 +L2+R1
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q10, #1           // (L2 + R1)*2
    vshl.u16 q11, q11, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q3, #1
    vshl.u16 q11, q4, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vrshr.u16 q14, q14, #5          // ((L1*8 + L0*2) + ((R0+L0)*8) + (L2 + R1)*3)>>5
    vrshr.u16 q15, q15, #5

    vbit   q12, q14, q9             // update L0
    vbit   q13, q15, q9

    // calculate L1 and R1
    vadd.u16 q10, q1, q2            // L2 + L1
    vadd.u16 q11, q6, q5
    vadd.u16 q14, q2, q4            // L1 + R0
    vadd.u16 q15, q5, q3
    vadd.u16 q10, q10, q3           // L2+L1+L0
    vadd.u16 q11, q11, q4
    vshl.u16 q10, q10, #2           // (L0 + L1 + L2)*4
    vshl.u16 q11, q11, #2

    vadd.u16 q14, q14, q10          // L1+R0 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q11

    vshl.u16 q11, q4, #1
    vshl.u16 q10, q3, #1            // L0*2
    vadd.u16 q14, q14, q11          // L1+R0 + R0*2 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q10

    vrshr.s16 q10, q14, #4          //
    vrshr.s16 q11, q15, #4
    vpop {q14}
    vbit q14, q10, q9
    vbit q8, q11, q9

    // calculate L2 and R2
    vadd.u16 q10, q3, q4            // L0 + R0
    vadd.u16 q11, q1, q2            // L2 + L1
    vadd.u16 q15, q6, q5
    vadd.u16 q11, q11, q0           // L1 + L2 + L3
    vadd.u16 q15, q15, q7
    vshl.u16 q11, q11, #1           // (L1 + L2 + L3)*2
    vshl.u16 q15, q15, #1
    vadd.u16 q11, q11, q10
    vadd.u16 q15, q15, q10

    vrshr.u16 q11, q11, #3          // ((L1 + L2 + L3)*2 + L0 + R0 + 4)>>3
    vrshr.u16 q15, q15, #3          //

deblock_ver_filtered:
    vbif   q11, q1, q9
    vbif   q15, q6, q9

    vmovn.u16 d0, q0
    vmovn.u16 d1, q11
    vmovn.u16 d2, q14
    vmovn.u16 d3, q12
    vmovn.u16 d4, q13
    vmovn.u16 d5, q8
    vmovn.u16 d6, q15
    vmovn.u16 d7, q7

    vst4.8 {d0[0], d1[0], d2[0], d3[0]}, [r2]!
    vst4.8 {d4[0], d5[0], d6[0], d7[0]}, [r2], r5
    vst4.8 {d0[1], d1[1], d2[1], d3[1]}, [r2]!
    vst4.8 {d4[1], d5[1], d6[1], d7[1]}, [r2], r5
    vst4.8 {d0[2], d1[2], d2[2], d3[2]}, [r2]!
    vst4.8 {d4[2], d5[2], d6[2], d7[2]}, [r2], r5
    vst4.8 {d0[3], d1[3], d2[3], d3[3]}, [r2]!
    vst4.8 {d4[3], d5[3], d6[3], d7[3]}, [r2], r5
    vst4.8 {d0[4], d1[4], d2[4], d3[4]}, [r2]!
    vst4.8 {d4[4], d5[4], d6[4], d7[4]}, [r2], r5
    vst4.8 {d0[5], d1[5], d2[5], d3[5]}, [r2]!
    vst4.8 {d4[5], d5[5], d6[5], d7[5]}, [r2], r5
    vst4.8 {d0[6], d1[6], d2[6], d3[6]}, [r2]!
    vst4.8 {d4[6], d5[6], d6[6], d7[6]}, [r2], r5
    vst4.8 {d0[7], d1[7], d2[7], d3[7]}, [r2]!
    vst4.8 {d4[7], d5[7], d6[7], d7[7]}, [r2]

    vpop {q4-q7}
    pop {r4-r7, pc}


/*****************************************************************************************************
 *  void uavs3d_deblock_ver_chroma_armv7(pel *srcuv, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v, int flt_flag);
 *  SrcPtrU->r0, stride->r1, alpha_u->r2, beta_u->r3, alpha_v->r4, beta_v->r5, flt_flag->r6
 ******************************************************************************************************/
function uavs3d_deblock_ver_chroma_armv7
    push {r4-r9, lr}
    vpush {q4, q5, q6, q7}
    ldr r4, [sp, #92]
    ldr r5, [sp, #96]
    ldr r6, [sp, #100]

    add r2, r2, r4, lsl #16
    add r3, r3, r5, lsl #16

    vdup.s32 q15, r2                // q15: alphau alphau alphau alphau, alphav alphav alphav alphav
    vdup.s32 q14, r3                // q14: betau, betav

    lsr r8, r6, #1
    lsr r7, r6, #9
    and r8, r8, #1
    and r9, r7, #1
    neg r8, r8                      // flag0
    neg r9, r9                      // flag1

    vdup.32 d26, r8
    vdup.32 d27, r9                 // v26: flag0 flag0 flag1 flag1

    sub r0, r0, #6                  // srcuv -= 6
    sub r5, r1, #8
    mov r3, r0

    //src[-3]:src[4] --> l2, l1, l0, r0, r1, r2, r3, r4
    vld4.16 {d0[0], d1[0], d2[0], d3[0]}, [r0]!
    vld2.16 {d4[0], d5[0]}, [r0], r5
    vld4.16 {d0[1], d1[1], d2[1], d3[1]}, [r0]!
    vld2.16 {d4[1], d5[1]}, [r0], r5
    vld4.16 {d0[2], d1[2], d2[2], d3[2]}, [r0]!
    vld2.16 {d4[2], d5[2]}, [r0], r5
    vld4.16 {d0[3], d1[3], d2[3], d3[3]}, [r0]!
    vld2.16 {d4[3], d5[3]}, [r0]

    vmovl.u8 q5, d5                 // R2
    vmovl.u8 q4, d4                 // R1
    vmovl.u8 q3, d3                 // R0
    vmovl.u8 q2, d2                 // L0
    vmovl.u8 q1, d1                 // L1
    vmovl.u8 q0, d0                 // L2

    vabd.u16 q6, q2, q1             // abs(L0-L1)
    vabd.u16 q7, q3, q4             // abs(R0-R1)
    vshr.u16 q8, q14, #2            // beta/4
    vcgt.u16 q11, q14, q6           // abs(L0-L1) < beta
    vcgt.u16 q12, q14, q7           // abs(R0-R1) < beta
    vcge.u16 q6, q8, q6             // abs(L0-L1) <= beta/4
    vcge.u16 q7, q8, q7             // abs(R0-R1) <= beta/4

    vabd.u16 q8, q3, q2             // abs(R0-L0)
    vabd.u16 q9, q0, q2             // abs(L2-L0)
    vabd.u16 q10, q3, q5            // abs(R0-R2)
    vcgt.u16 q8, q15, q8            // abs(R0-L0) < alpha
    vcgt.u16 q9, q14, q9            // abs(L2-L0) < beta
    vcgt.u16 q10, q14, q10          // abs(R2-R0) < beta

    vand q11, q11, q12              // abs(L0-L1) < beta && abs(R0-R1) < beta
    vand q9, q9, q10                // abs(L2-L0) < beta && abs(R2-R0) < beta
    vand q6, q6, q7                 // abs(L0-L1) <= beta/4 && abs(R0-R1) <= beta/4

    vand  q15, q11, q13             // flt0: mask L0, R0
    vand  q14, q8, q9
    vand  q13, q6, q15
    vand  q14, q14, q13             // flt1: mask L1, R1

    // filter L0, R0
    vshl.u16 q6, q3, #1             // R0 * 2
    vshl.u16 q7, q2, #1
    vshl.u16 q8, q1, #3             // L1 * 8
    vshl.u16 q9, q4, #3
    vadd.u16 q10, q2, q0            // L0 + L2
    vadd.u16 q11, q3, q5
    vadd.u16 q8, q6, q8             // (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q7, q9
    vshl.u16 q12, q10, #1           // (L0 + L2)*2
    vshl.u16 q13, q11, #1
    vadd.u16 q8, q10, q8            // (L0 + L2) + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q11, q9
    vadd.u16 q8, q8, q12            // (L0 + L2)*3 + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q9, q13

    vrshr.u16 q8, q8, #4
    vrshr.u16 q9, q9, #4

    vshl.u16 q12, q2, #3            // L0 * 8
    vshl.u16 q13, q3, #3
    vadd.u16 q10, q1, q3            // L1 + R0
    vadd.u16 q11, q4, q2
    vadd.u16 q12, q12, q7           // L0 * 10
    vadd.u16 q13, q13, q6
    vshl.u16 q6, q10, #1            // (L1 + R0)*2
    vshl.u16 q7, q11, #1
    vadd.u16 q10, q10, q12          // (L1 + R0)*3
    vadd.u16 q11, q11, q13
    vadd.u16 q10, q6, q10           // (L1 + R0)*3 + L0*10
    vadd.u16 q11, q7, q11

    vrshr.u16 q10, q10, #4
    vrshr.u16 q11, q11, #4

    vbit q1, q8, q14                // L1
    vbit q2, q10, q15               // L0
    vbit q3, q11, q15               // R0
    vbit q4, q9, q14                // R1

    //store L1, L0, R0, R1
    vmovn.u16 d0, q0
    vmovn.u16 d1, q1
    vmovn.u16 d2, q2
    vmovn.u16 d3, q3
    vmovn.u16 d4, q4
    vmovn.u16 d5, q5

    vst4.16 {d0[0], d1[0], d2[0], d3[0]}, [r3]!
    vst2.16 {d4[0], d5[0]}, [r3], r5
    vst4.16 {d0[1], d1[1], d2[1], d3[1]}, [r3]!
    vst2.16 {d4[1], d5[1]}, [r3], r5
    vst4.16 {d0[2], d1[2], d2[2], d3[2]}, [r3]!
    vst2.16 {d4[2], d5[2]}, [r3], r5
    vst4.16 {d0[3], d1[3], d2[3], d3[3]}, [r3]!
    vst2.16 {d4[3], d5[3]}, [r3]

    vpop {q4, q5, q6, q7}
    pop {r4-r9, pc}


/*****************************************************************************************************
*  void uavs3d_deblock_hor_luma_armv7(pel *SrcPtr, int stride, int Alpha, int Beta, int flt_flag)
*  SrcPtr->r0, stride->r1, Alpha->r2, Beta->r3, flt_flag->r4
******************************************************************************************************/
function uavs3d_deblock_hor_luma_armv7
    push {r4-r7, lr}
    vpush {q4, q5, q6, q7}
    ldr r4, [sp, #84]
    ldr r5, [sp, #88]

    // prepare data
    vdup.s16 q15, r2                // save Alpha
    vdup.s16 q14, r3                // save Beta

    sub r0, r0, r1, lsl #2         // src - 4*stride
    add r2, r0, r1                 // src - 3*stride

	vld1.64 {d0}, [r0], r1          // l3
	vld1.64 {d1}, [r0], r1          // l2
	vld1.64 {d2}, [r0], r1          // l1
	vld1.64 {d3}, [r0], r1          // l0
	vld1.64 {d4}, [r0], r1          // r0
	vld1.64 {d5}, [r0], r1          // r1
	vld1.64 {d6}, [r0], r1	        // r2
	vld1.64 {d7}, [r0]	  	        // r3

    vmovl.u8 q7, d7                 // R3
    vmovl.u8 q6, d6                 // R2
    vmovl.u8 q5, d5                 // R1
    vmovl.u8 q4, d4                 // R0
    vmovl.u8 q3, d3                 // L0
    vmovl.u8 q2, d2                 // L1
    vmovl.u8 q1, d1                 // L2
    vmovl.u8 q0, d0                 // L3

    vmov.i16 q12, #2
    vabd.u16 q8, q2, q3             // COM_ABS(L1 - L0)
    vabd.u16 q9, q4, q5             // COM_ABS(R0 - R1)
    vcgt.u16 q8, q14, q8            // COM_ABS(L1 - L0) < Beta
    vcgt.u16 q9, q14, q9            // COM_ABS(R0 - R1) < Beta
    vand  q8, q8, q12               // FlatnessL
    vand  q9, q9, q12               // FlatnessR

    vabd.u16 q10, q1, q3            // COM_ABS(L2 - L0)
    vabd.u16 q11, q4, q6            // COM_ABS(R0 - R2)
    vmov.i16 q12, #1
    vcgt.u16 q10, q14, q10          // COM_ABS(L2 - L0) < Beta
    vcgt.u16 q11, q14, q11          // COM_ABS(R0 - R2) < Beta

    vand  q10, q10, q12
    vand  q11, q11, q12
    vadd.u16 q8, q8, q10            // FlatnessL++ (saved)
    vadd.u16 q9, q9, q11            // FlatnessR++

    vadd.u16 q9, q8, q9             // flt = FlatnessL + FlatnessR (saved)

    vabd.u16 q10, q2, q3            // COM_ABS(L1 - L0)
    vabd.u16 q11, q4, q5            // COM_ABS(R0 - R1)
    vshr.u16 q12, q14, #2           // Beta/4

    vcge.u16 q10, q12, q10          // COM_ABS(L1 - L0) <= Beta / 4
    vcge.u16 q11, q12, q11          // COM_ABS(R0 - R1) <= Beta / 4
    vabd.u16 q12, q4, q3            // ABS(R0 - L0)
    vand  q10, q10, q11             // (COM_ABS(L1 - L0) <= Beta / 4) && (COM_ABS(R1 - R0) <= Beta / 4)
    vcgt.u16 q12, q15, q12          // ABS(R0 - L0) < Alpha
    vand  q10, q10, q12

    // flt == 6
    vmov.i16 q15, #6
    vmov.i16 q11, #3
    vmov.i16 q12, #4
    vmov.i16 q13, #0                // fs = 0
    vceq.u16 q15, q9, q15           // flt == 6
    vbif  q12, q11, q10
    vbit  q13, q12, q15             // fs34 (save)

    // flt == 5
    vceq.u16 q11, q2, q3            // L0 == L1
    vceq.u16 q12, q4, q5            // R1 == R0
    vand  q11, q11, q12             // (R1 == R0) && (L0 == L1)

    vmov.i16 q10, #2                // q10 = 2
    vabd.u16 q12, q2, q5            // COM_ABS(L1 - R1)
    vceq.u16 q8, q8, q10            // FlatnessL == 2
    vcgt.u16 q14, q14, q12          // COM_ABS(L1 - R1) < Beta

    vmov.i16 q12, #5
    vmov.i16 q15, #3
    vceq.u16 q12, q9, q12           // flt == 5
    vbit  q10, q15, q11             // fs23
    vbit  q13, q10, q12             // fs234

    // flt == 4
    vmov.i16 q12, #4
    vmov.i16 q10, #1
    vmov.i16 q11, #2
    vceq.u16 q12, q9, q12           // flt == 4
    vbit  q10, q11, q8              // fs12
    vbit  q13, q10, q12             // fs1234

    // flt == 3
    vmov.i16 q12, #3
    vmov.i16 q10, #0
    vmov.i16 q11, #1
    vceq.u16 q12, q9, q12           // flt == 3
    vbit  q10, q11, q14             // fs01
    vbit  q13, q10, q12             // fs01234

    // prepare flt_flag[0] & flt_flag[1]
    and r6, r4, #1
    lsr r4, r4, #8
    neg r6, r6
    and r7, r4, #1
    neg r7, r7

    vdup.s32 d28, r6                // q14: flt_flag[0] flt_flag[0] flt_flag[1] flt_flag[1]
    vdup.s32 d29, r7

    vand  q15, q13, q14             // fs & flt_flag

    // fs == 1
    vadd.u16 q8, q3, q4             // L0 + R0 (saved)
    vshl.u16 q9, q3, #1             // L0 << 1
    vshl.u16 q10, q4, #1            // R0 << 1
    vadd.u16 q12, q9 , q8           // L0 + (L0 << 1) + R0
    vadd.u16 q13, q10, q8           // L0 + (R0 << 1) + R0

    vrshr.u16 q12, q12, #2
    vrshr.u16 q13, q13, #2
    vceq.u16 q14, q15, q11          // if fs == 1
    vbif   q12, q3, q14
    vbif   q13, q4, q14

    // fs == 2
    vshl.u16 q8, q8, #1             // (L0 + R0)<<1 (saved)
    vadd.u16 q9 , q2, q4            // L1 + R0
    vadd.u16 q10, q3, q5            // L0 + R1
    vshl.u16 q11, q2, #1            // L1<<1
    vshl.u16 q14, q5, #1            // R1<<1
    vadd.u16 q9 , q8, q9            // (L0+R0)<<1 + L1 + R0
    vadd.u16 q10, q8, q10           // (L0+R0)<<1 + L0 + R1
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1

    vshl.u16 q11, q3, #3            // L0<<3
    vshl.u16 q14, q4, #3            // R0<<3
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3)>>4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3)>>4
    vmov.i16  q11, #2
    vceq.u16 q11, q15, q11          // fs == 2
    vbit   q12, q9 , q11
    vbit   q13, q10, q11

    // fs == 3; update src[0] src[-1]
    vshl.u16 q8, q8, #1             // (L0+R0)<<2 --> V16
    vshl.u16 q9, q2, #2             // L1<<2
    vshl.u16 q10, q5, #2            // R1<<2
    vadd.u16 q11, q1, q5            // L2 + R1
    vadd.u16 q14, q2, q6            // L1 + R2
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2
    vadd.u16 q10, q14, q10
    vshl.u16 q11, q3, #1            // L0 << 1
    vshl.u16 q14, q4, #1            // R0 << 1
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2 + L0<<1
    vadd.u16 q10, q14, q10
    vadd.u16 q9, q9, q8             // (L0+R0)<<2 + L2+R1 + L1<<2 + L0<<1
    vadd.u16 q10, q10, q8           // (L0+R0)<<2 + L1+R2 + R1<<2 + R0<<1

    vmov.i16 q11, #3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<2 + (L2 + R1) + L0<<1+L1<<2) >> 4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<2 + (L1 + R2) + R0<<1+R1<<2) >> 4

    vceq.u16 q11, q15, q11          // fs == 3 (saved)
    vbit   q12, q9, q11             // update L0
    vbit   q13, q10, q11

    // fs == 3; calculate src[-2] src[1]
    vadd.u16 q14, q1, q4            // L2+R0
    vadd.u16 q8, q6, q3             // R2+L0
    vshl.u16 q10, q1, #1            // L2<<1
    vshl.u16 q9, q6, #1             // R2<<1
    vadd.u16 q14, q14, q10            // L2+R0+L2<<1
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1

    vshl.u16 q10, q2, #3            // L1<<3
    vshl.u16 q9, q5, #3             // R1<<3
    vadd.u16 q14, q14, q10          // L2+R0+L2<<1 + (L1<<3)
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1 + (R1<<3)

    vshl.u16 q10, q3, #2            // L0<<2
    vshl.u16 q9, q4, #2             // R0<<2
    vadd.u16 q14, q14, q10          // ((L2+R0+L2<<1) + (L1<<3)) + L0<<2
    vadd.u16 q8, q8, q9             //

    vrshr.u16 q14, q14, #4
    vrshr.u16 q8, q8, #4
    vbif   q14, q2, q11
    vbif   q8, q5, q11              // update L1_dst and R1_dst

    // fs == 4
    vmov.i16 q9, #4
    vceq.u16 q9, q15, q9
    vpadd.i32 d20, d18, d19
    vmov r6, r7, d20
    orr	 r6, r6, r7
    cmp  r6, #0
    beq  deblock_hor_filtered

    vpush {q14}
    // if fs == 4 exist
    // calculate L0 and R0
    vadd.u16 q10, q3, q4            // L0 + R0
    vshl.u16 q14, q2, #3            // L1<<3
    vshl.u16 q11, q10, #3           // (R0+L0)<<3
    vshl.u16 q15, q5, #3            //
    vadd.u16 q14, q14, q11          // (R0+L0)<<3 + L1*8
    vadd.u16 q15, q15, q11

    vadd.u16 q10, q1, q5            // L2 + R1
    vadd.u16 q11, q2, q6
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 +L2+R1
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q10, #1           // (L2 + R1)*2
    vshl.u16 q11, q11, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q3, #1
    vshl.u16 q11, q4, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vrshr.u16 q14, q14, #5          // ((L1*8 + L0*2) + ((R0+L0)*8) + (L2 + R1)*3)>>5
    vrshr.u16 q15, q15, #5

    vbit   q12, q14, q9             // update L0
    vbit   q13, q15, q9

    // calculate L1 and R1
    vadd.u16 q10, q1, q2            // L2 + L1
    vadd.u16 q11, q6, q5
    vadd.u16 q14, q2, q4            // L1 + R0
    vadd.u16 q15, q5, q3
    vadd.u16 q10, q10, q3           // L2+L1+L0
    vadd.u16 q11, q11, q4
    vshl.u16 q10, q10, #2           // (L0 + L1 + L2)*4
    vshl.u16 q11, q11, #2

    vadd.u16 q14, q14, q10          // L1+R0 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q11

    vshl.u16 q11, q4, #1
    vshl.u16 q10, q3, #1            // L0*2
    vadd.u16 q14, q14, q11          // L1+R0 + R0*2 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q10

    vrshr.s16 q10, q14, #4          //
    vrshr.s16 q11, q15, #4
    vpop {q14}
    vbit q14, q10, q9
    vbit q8, q11, q9

    // calculate L2 and R2
    vadd.u16 q10, q3, q4            // L0 + R0
    vadd.u16 q11, q1, q2            // L2 + L1
    vadd.u16 q15, q6, q5
    vadd.u16 q11, q11, q0           // L1 + L2 + L3
    vadd.u16 q15, q15, q7
    vshl.u16 q11, q11, #1           // (L1 + L2 + L3)*2
    vshl.u16 q15, q15, #1
    vadd.u16 q11, q11, q10
    vadd.u16 q15, q15, q10

    vrshr.u16 q11, q11, #3          // ((L1 + L2 + L3)*2 + L0 + R0 + 4)>>3
    vrshr.u16 q15, q15, #3          //

deblock_hor_filtered:
    vbif   q11, q1, q9
    vbif   q15, q6, q9

    vmovn.u16 d0, q11
    vmovn.u16 d1, q14
    vmovn.u16 d2, q12
    vmovn.u16 d3, q13
    vmovn.u16 d4, q8
    vmovn.u16 d5, q15

    vst1.16 {d0}, [r2], r1
    vst1.16 {d1}, [r2], r1
    vst1.16 {d2}, [r2], r1
    vst1.16 {d3}, [r2], r1
    vst1.16 {d4}, [r2], r1
    vst1.16 {d5}, [r2]

    vpop {q4, q5, q6, q7}
    pop {r4-r7, pc}


/*****************************************************************************************************
 *  void uavs3d_deblock_hor_chroma_armv7(pel *srcuv, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v, int flt_flag);
 *  SrcPtrU->r0, stride->r1, alpha_u->r2, beta_u->r3, alpha_v->r4, beta_v->r5, flt_flag->r6
 ******************************************************************************************************/
function uavs3d_deblock_hor_chroma_armv7
    push {r4-r9, lr}
    vpush {q4, q5, q6, q7}
    ldr r4, [sp, #92]
    ldr r5, [sp, #96]
    ldr r6, [sp, #100]

    add r2, r2, r4, lsl #16
    add r3, r3, r5, lsl #16
    
    vdup.s32 q15, r2                // q15: alphau alphau alphau alphau, alphav alphav alphav alphav
    vdup.s32 q14, r3                // q14: betau, betav

    lsr r8, r6, #1
    lsr r7, r6, #9
    and r8, r8, #1
    and r9, r7, #1
    neg r8, r8                      // flag0
    neg r9, r9                      // flag1

    vdup.32 d26, r8
    vdup.32 d27, r9                 // v26: flag0 flag0 flag1 flag1

    sub r0, r0, r1, lsl #1          // srcuv - 2*stride
    sub r2, r0, r1                  // srcuv - 3*stride

    vld1.16 {d0}, [r2], r1          // L2
    vld1.16 {d1}, [r2], r1          // L1
    vld1.16 {d2}, [r2], r1          // L0
    vld1.16 {d3}, [r2], r1          // R0
    vld1.16 {d4}, [r2], r1          // R1
    vld1.16 {d5}, [r2]              // R2

    vmovl.u8 q5, d5                 // R2
    vmovl.u8 q4, d4                 // R1
    vmovl.u8 q3, d3                 // R0
    vmovl.u8 q2, d2                 // L0
    vmovl.u8 q1, d1                 // L1
    vmovl.u8 q0, d0                 // L2

    vabd.u16 q6, q2, q1             // abs(L0-L1)
    vabd.u16 q7, q3, q4             // abs(R0-R1)
    vshr.u16 q8, q14, #2            // beta/4
    vcgt.u16 q11, q14, q6           // abs(L0-L1) < beta
    vcgt.u16 q12, q14, q7           // abs(R0-R1) < beta
    vcge.u16 q6, q8, q6             // abs(L0-L1) <= beta/4
    vcge.u16 q7, q8, q7             // abs(R0-R1) <= beta/4

    vabd.u16 q8, q3, q2             // abs(R0-L0)
    vabd.u16 q9, q0, q2             // abs(L2-L0)
    vabd.u16 q10, q3, q5            // abs(R0-R2)
    vcgt.u16 q8, q15, q8            // abs(R0-L0) < alpha
    vcgt.u16 q9, q14, q9            // abs(L2-L0) < beta
    vcgt.u16 q10, q14, q10          // abs(R2-R0) < beta

    vand q11, q11, q12              // abs(L0-L1) < beta && abs(R0-R1) < beta
    vand q9, q9, q10                // abs(L2-L0) < beta && abs(R2-R0) < beta
    vand q6, q6, q7                 // abs(L0-L1) <= beta/4 && abs(R0-R1) <= beta/4

    vand  q15, q11, q13             // flt0: mask L0, R0
    vand  q14, q8, q9
    vand  q13, q6, q15
    vand  q14, q14, q13             // flt1: mask L1, R1

    // filter L0, R0
    vshl.u16 q6, q3, #1             // R0 * 2
    vshl.u16 q7, q2, #1
    vshl.u16 q8, q1, #3             // L1 * 8
    vshl.u16 q9, q4, #3
    vadd.u16 q10, q2, q0            // L0 + L2
    vadd.u16 q11, q3, q5
    vadd.u16 q8, q6, q8             // (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q7, q9
    vshl.u16 q12, q10, #1           // (L0 + L2)*2
    vshl.u16 q13, q11, #1
    vadd.u16 q8, q10, q8            // (L0 + L2) + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q11, q9
    vadd.u16 q8, q8, q12            // (L0 + L2)*3 + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q9, q13

    vrshr.u16 q8, q8, #4
    vrshr.u16 q9, q9, #4

    vshl.u16 q12, q2, #3            // L0 * 8
    vshl.u16 q13, q3, #3
    vadd.u16 q10, q1, q3            // L1 + R0
    vadd.u16 q11, q4, q2
    vadd.u16 q12, q12, q7           // L0 * 10
    vadd.u16 q13, q13, q6
    vshl.u16 q6, q10, #1            // (L1 + R0)*2
    vshl.u16 q7, q11, #1
    vadd.u16 q10, q10, q12          // (L1 + R0)*3
    vadd.u16 q11, q11, q13
    vadd.u16 q10, q6, q10           // (L1 + R0)*3 + L0*10
    vadd.u16 q11, q7, q11

    vrshr.u16 q10, q10, #4
    vrshr.u16 q11, q11, #4

    vbit q1, q8, q14                // L1
    vbit q2, q10, q15               // L0
    vbit q3, q11, q15               // R0
    vbit q4, q9, q14                // R1

    //store L1, L0, R0, R1
    vmovn.u16 d1, q1
    vmovn.u16 d2, q2
    vmovn.u16 d3, q3
    vmovn.u16 d4, q4

    vst1.16 {d1}, [r0], r1
    vst1.16 {d2}, [r0], r1
    vst1.16 {d3}, [r0], r1
    vst1.16 {d4}, [r0]

    vpop {q4, q5, q6, q7}
    pop {r4-r9, pc}

#else
/*****************************************************************************************************
*  void uavs3d_deblock_ver_luma_armv7(pel *SrcPtr, int stride, int Alpha, int Beta, int flt_flag)
*  SrcPtr->r0, stride->r1, Alpha->r2, Beta->r3, flt_flag->r4
******************************************************************************************************/
function uavs3d_deblock_ver_luma_armv7
    push {r4-r7, lr}
    vpush {q4, q5, q6, q7}

    ldr r4, [sp, #84]
    lsl r1, r1, #1

    // prepare data
    vdup.s16 q15, r2                // save Alpha
    vdup.s16 q14, r3                // save Beta
    sub r0, r0, #8                  // src-4
    mov r2, r0                      // src-4

    sub r5, r1, #8
	vld1.64 {q0} , [r0] , r1        // l3
	vld1.64 {q1} , [r0] , r1        // l2
	vld1.64 {q2} , [r0] , r1        // l1
	vld1.64 {q3} , [r0] , r1        // l0
	vld1.64 {q4} , [r0] , r1        // r0
	vld1.64 {q5} , [r0] , r1        // r1
	vld1.64 {q6} , [r0] , r1	    // r2
	vld1.64 {q7} , [r0]		  	    // r3

	// transform q0.....q7
	//vtrn.64     q0, q4
	//vtrn.64     q1, q5
	//vtrn.64     q2, q6
    //vtrn.64     q3, q7
    vswp d1, d8
    vswp d3, d10
    vswp d5, d12
    vswp d7, d14

	vtrn.32     q0, q2
	vtrn.32     q1, q3
	vtrn.32     q4, q6
    vtrn.32     q5, q7

	vtrn.16     q0, q1
	vtrn.16     q2, q3
	vtrn.16     q4, q5
	vtrn.16     q6, q7

    // q7 : R3
    // q6 : R2
    // q5 : R1
    // q4 : R0
    // q3 : L0
    // q2 : L1
    // q1 : L2
    // q0 : L3

    vmov.i16 q12, #2
    vabd.u16 q8, q2, q3             // COM_ABS(L1 - L0)
    vabd.u16 q9, q4, q5             // COM_ABS(R0 - R1)
    vcgt.u16 q8, q14, q8            // COM_ABS(L1 - L0) < Beta
    vcgt.u16 q9, q14, q9            // COM_ABS(R0 - R1) < Beta
    vand  q8, q8, q12               // FlatnessL
    vand  q9, q9, q12               // FlatnessR

    vabd.u16 q10, q1, q3            // COM_ABS(L2 - L0)
    vabd.u16 q11, q4, q6            // COM_ABS(R0 - R2)
    vmov.i16 q12, #1
    vcgt.u16 q10, q14, q10          // COM_ABS(L2 - L0) < Beta
    vcgt.u16 q11, q14, q11          // COM_ABS(R0 - R2) < Beta

    vand  q10, q10, q12
    vand  q11, q11, q12
    vadd.u16 q8, q8, q10            // FlatnessL++ (saved)
    vadd.u16 q9, q9, q11            // FlatnessR++

    vadd.u16 q9, q8, q9             // flt = FlatnessL + FlatnessR (saved)

    vabd.u16 q10, q2, q3            // COM_ABS(L1 - L0)
    vabd.u16 q11, q4, q5            // COM_ABS(R0 - R1)
    vshr.u16 q12, q14, #2           // Beta/4

    vcge.u16 q10, q12, q10          // COM_ABS(L1 - L0) <= Beta / 4
    vcge.u16 q11, q12, q11          // COM_ABS(R0 - R1) <= Beta / 4
    vabd.u16 q12, q4, q3            // ABS(R0 - L0)
    vand  q10, q10, q11             // (COM_ABS(L1 - L0) <= Beta / 4) && (COM_ABS(R1 - R0) <= Beta / 4)
    vcgt.u16 q12, q15, q12          // ABS(R0 - L0) < Alpha
    vand  q10, q10, q12

    // flt == 6
    vmov.i16 q15, #6
    vmov.i16 q11, #3
    vmov.i16 q12, #4
    vmov.i16 q13, #0                // fs = 0
    vceq.u16 q15, q9, q15           // flt == 6
    vbif  q12, q11, q10
    vbit  q13, q12, q15             // fs34 (save)

    // flt == 5
    vceq.u16 q11, q2, q3            // L0 == L1
    vceq.u16 q12, q4, q5            // R1 == R0
    vand  q11, q11, q12             // (R1 == R0) && (L0 == L1)

    vmov.i16 q10, #2                // q10 = 2
    vabd.u16 q12, q2, q5            // COM_ABS(L1 - R1)
    vceq.u16 q8, q8, q10            // FlatnessL == 2
    vcgt.u16 q14, q14, q12          // COM_ABS(L1 - R1) < Beta

    vmov.i16 q12, #5
    vmov.i16 q15, #3
    vceq.u16 q12, q9, q12           // flt == 5
    vbit  q10, q15, q11             // fs23
    vbit  q13, q10, q12             // fs234

    // flt == 4
    vmov.i16 q12, #4
    vmov.i16 q10, #1
    vmov.i16 q11, #2
    vceq.u16 q12, q9, q12           // flt == 4
    vbit  q10, q11, q8              // fs12
    vbit  q13, q10, q12             // fs1234

    // flt == 3
    vmov.i16 q12, #3
    vmov.i16 q10, #0
    vmov.i16 q11, #1
    vceq.u16 q12, q9, q12           // flt == 3
    vbit  q10, q11, q14             // fs01
    vbit  q13, q10, q12             // fs01234

    // prepare flt_flag[0] & flt_flag[1]
    and r6, r4, #1
    lsr r4, r4, #8
    neg r6, r6
    and r7, r4, #1
    neg r7, r7

    vdup.s32 d28, r6                // q14: flt_flag[0] flt_flag[0] flt_flag[1] flt_flag[1]
    vdup.s32 d29, r7

    vand  q15, q13, q14             // fs & flt_flag

    // fs == 1
    vadd.u16 q8, q3, q4             // L0 + R0 (saved)
    vshl.u16 q9, q3, #1             // L0 << 1
    vshl.u16 q10, q4, #1            // R0 << 1
    vadd.u16 q12, q9 , q8           // L0 + (L0 << 1) + R0
    vadd.u16 q13, q10, q8           // L0 + (R0 << 1) + R0

    vrshr.u16 q12, q12, #2
    vrshr.u16 q13, q13, #2
    vceq.u16 q14, q15, q11          // if fs == 1
    vbif   q12, q3, q14
    vbif   q13, q4, q14

    // fs == 2
    vshl.u16 q8, q8, #1             // (L0 + R0)<<1 (saved)
    vadd.u16 q9 , q2, q4            // L1 + R0
    vadd.u16 q10, q3, q5            // L0 + R1
    vshl.u16 q11, q2, #1            // L1<<1
    vshl.u16 q14, q5, #1            // R1<<1
    vadd.u16 q9 , q8, q9            // (L0+R0)<<1 + L1 + R0
    vadd.u16 q10, q8, q10           // (L0+R0)<<1 + L0 + R1
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1

    vshl.u16 q11, q3, #3            // L0<<3
    vshl.u16 q14, q4, #3            // R0<<3
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3)>>4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3)>>4
    vmov.i16  q11, #2
    vceq.u16 q11, q15, q11          // fs == 2
    vbit   q12, q9 , q11
    vbit   q13, q10, q11

    // fs == 3; update src[0] src[-1]
    vshl.u16 q8, q8, #1             // (L0+R0)<<2 --> V16
    vshl.u16 q9, q2, #2             // L1<<2
    vshl.u16 q10, q5, #2            // R1<<2
    vadd.u16 q11, q1, q5            // L2 + R1
    vadd.u16 q14, q2, q6            // L1 + R2
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2
    vadd.u16 q10, q14, q10
    vshl.u16 q11, q3, #1            // L0 << 1
    vshl.u16 q14, q4, #1            // R0 << 1
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2 + L0<<1
    vadd.u16 q10, q14, q10
    vadd.u16 q9, q9, q8             // (L0+R0)<<2 + L2+R1 + L1<<2 + L0<<1
    vadd.u16 q10, q10, q8           // (L0+R0)<<2 + L1+R2 + R1<<2 + R0<<1

    vmov.i16 q11, #3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<2 + (L2 + R1) + L0<<1+L1<<2) >> 4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<2 + (L1 + R2) + R0<<1+R1<<2) >> 4

    vceq.u16 q11, q15, q11          // fs == 3 (saved)
    vbit   q12, q9, q11             // update L0
    vbit   q13, q10, q11

    // fs == 3; calculate src[-2] src[1]
    vadd.u16 q14, q1, q4            // L2+R0
    vadd.u16 q8, q6, q3             // R2+L0
    vshl.u16 q10, q1, #1            // L2<<1
    vshl.u16 q9, q6, #1             // R2<<1
    vadd.u16 q14, q14, q10            // L2+R0+L2<<1
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1

    vshl.u16 q10, q2, #3            // L1<<3
    vshl.u16 q9, q5, #3             // R1<<3
    vadd.u16 q14, q14, q10          // L2+R0+L2<<1 + (L1<<3)
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1 + (R1<<3)

    vshl.u16 q10, q3, #2            // L0<<2
    vshl.u16 q9, q4, #2             // R0<<2
    vadd.u16 q14, q14, q10          // ((L2+R0+L2<<1) + (L1<<3)) + L0<<2
    vadd.u16 q8, q8, q9             //

    vrshr.u16 q14, q14, #4
    vrshr.u16 q8, q8, #4
    vbif   q14, q2, q11
    vbif   q8, q5, q11              // update L1_dst and R1_dst

    // fs == 4
    vmov.i16 q9, #4
    vceq.u16 q9, q15, q9
    vpadd.i32 d20, d18, d19
    vmov r6, r7, d20
    orr	 r6, r6, r7
    cmp  r6, #0
    beq  deblock_ver_filtered

    vpush {q14}
    // if fs == 4 exist
    // calculate L0 and R0
    vadd.u16 q10, q3, q4            // L0 + R0
    vshl.u16 q14, q2, #3            // L1<<3
    vshl.u16 q11, q10, #3           // (R0+L0)<<3
    vshl.u16 q15, q5, #3            //
    vadd.u16 q14, q14, q11          // (R0+L0)<<3 + L1*8
    vadd.u16 q15, q15, q11

    vadd.u16 q10, q1, q5            // L2 + R1
    vadd.u16 q11, q2, q6
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 +L2+R1
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q10, #1           // (L2 + R1)*2
    vshl.u16 q11, q11, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q3, #1
    vshl.u16 q11, q4, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vrshr.u16 q14, q14, #5          // ((L1*8 + L0*2) + ((R0+L0)*8) + (L2 + R1)*3)>>5
    vrshr.u16 q15, q15, #5

    vbit   q12, q14, q9             // update L0
    vbit   q13, q15, q9

    // calculate L1 and R1
    vadd.u16 q10, q1, q2            // L2 + L1
    vadd.u16 q11, q6, q5
    vadd.u16 q14, q2, q4            // L1 + R0
    vadd.u16 q15, q5, q3
    vadd.u16 q10, q10, q3           // L2+L1+L0
    vadd.u16 q11, q11, q4
    vshl.u16 q10, q10, #2           // (L0 + L1 + L2)*4
    vshl.u16 q11, q11, #2

    vadd.u16 q14, q14, q10          // L1+R0 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q11

    vshl.u16 q11, q4, #1
    vshl.u16 q10, q3, #1            // L0*2
    vadd.u16 q14, q14, q11          // L1+R0 + R0*2 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q10

    vrshr.s16 q10, q14, #4          //
    vrshr.s16 q11, q15, #4
    vpop {q14}
    vbit q14, q10, q9
    vbit q8, q11, q9

    // calculate L2 and R2
    vadd.u16 q10, q3, q4            // L0 + R0
    vadd.u16 q11, q1, q2            // L2 + L1
    vadd.u16 q15, q6, q5
    vadd.u16 q11, q11, q0           // L1 + L2 + L3
    vadd.u16 q15, q15, q7
    vshl.u16 q11, q11, #1           // (L1 + L2 + L3)*2
    vshl.u16 q15, q15, #1
    vadd.u16 q11, q11, q10
    vadd.u16 q15, q15, q10

    vrshr.u16 q11, q11, #3          // ((L1 + L2 + L3)*2 + L0 + R0 + 4)>>3
    vrshr.u16 q15, q15, #3          //

deblock_ver_filtered:
    vbif   q11, q1, q9
    vbif   q15, q6, q9

    // q0
    vmov.u16 q1, q11
    vmov.u16 q2, q14
    vmov.u16 q3, q12
    vmov.u16 q4, q13
    vmov.u16 q5, q8
    vmov.u16 q6, q15
    // q7

    vst4.16 {d0[0], d2[0], d4[0], d6[0]}, [r2]!
    vst4.16 {d8[0], d10[0], d12[0], d14[0]}, [r2], r5
    vst4.16 {d0[1], d2[1], d4[1], d6[1]}, [r2]!
    vst4.16 {d8[1], d10[1], d12[1], d14[1]}, [r2], r5
    vst4.16 {d0[2], d2[2], d4[2], d6[2]}, [r2]!
    vst4.16 {d8[2], d10[2], d12[2], d14[2]}, [r2], r5
    vst4.16 {d0[3], d2[3], d4[3], d6[3]}, [r2]!
    vst4.16 {d8[3], d10[3], d12[3], d14[3]}, [r2], r5
    vst4.16 {d1[0], d3[0], d5[0], d7[0]}, [r2]!
    vst4.16 {d9[0], d11[0], d13[0], d15[0]}, [r2], r5
    vst4.16 {d1[1], d3[1], d5[1], d7[1]}, [r2]!
    vst4.16 {d9[1], d11[1], d13[1], d15[1]}, [r2], r5
    vst4.16 {d1[2], d3[2], d5[2], d7[2]}, [r2]!
    vst4.16 {d9[2], d11[2], d13[2], d15[2]}, [r2], r5
    vst4.16 {d1[3], d3[3], d5[3], d7[3]}, [r2]!
    vst4.16 {d9[3], d11[3], d13[3], d15[3]}, [r2]

    vpop {q4, q5, q6, q7}
    pop {r4-r7, pc}


/*****************************************************************************************************
 *  void uavs3d_deblock_ver_chroma_armv7(pel *srcuv, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v, int flt_flag);
 *  SrcPtrU->r0, stride->r1, alpha_u->r2, beta_u->r3, alpha_v->r4, beta_v->r5, flt_flag->r6
 ******************************************************************************************************/
function uavs3d_deblock_ver_chroma_armv7
    push {r4-r9, lr}
	add sp, sp, #28
	ldmia sp, {r4, r5, r6}
	sub sp, sp, #28
    vpush {q4, q5, q6, q7}

    lsl r1, r1, #1

    add r2, r2, r4, lsl #16
    add r3, r3, r5, lsl #16

    vdup.s32 q15, r2                // q15: alphau alphau alphau alphau, alphav alphav alphav alphav
    vdup.s32 q14, r3                // q14: betau, betav

    lsr r8, r6, #1
    lsr r7, r6, #9
    and r8, r8, #1
    and r9, r7, #1
    neg r8, r8                      // flag0
    neg r9, r9                      // flag1

    vdup.32 d26, r8
    vdup.32 d27, r9                 // v26: flag0 flag0 flag1 flag1

    sub r0, r0, #12                 // srcuv -= 6
    sub r5, r1, #16
    mov r3, r0

    //src[-3]:src[4] --> l2, l1, l0, r0, r1, r2, r3, r4
    vld4.32 {d0[0], d2[0], d4[0], d6[0]}, [r0]!
    vld2.32 {d8[0], d10[0]}, [r0], r5
    vld4.32 {d0[1], d2[1], d4[1], d6[1]}, [r0]!
    vld2.32 {d8[1], d10[1]}, [r0], r5
    vld4.32 {d1[0], d3[0], d5[0], d7[0]}, [r0]!
    vld2.32 {d9[0], d11[0]}, [r0], r5
    vld4.32 {d1[1], d3[1], d5[1], d7[1]}, [r0]!
    vld2.32 {d9[1], d11[1]}, [r0]

    // q5 : R2
    // q4 : R1
    // q3 : R0
    // q2 : L0
    // q1 : L1
    // q0 : L2

    vabd.u16 q6, q2, q1             // abs(L0-L1)
    vabd.u16 q7, q3, q4             // abs(R0-R1)
    vshr.u16 q8, q14, #2            // beta/4
    vcgt.u16 q11, q14, q6           // abs(L0-L1) < beta
    vcgt.u16 q12, q14, q7           // abs(R0-R1) < beta
    vcge.u16 q6, q8, q6             // abs(L0-L1) <= beta/4
    vcge.u16 q7, q8, q7             // abs(R0-R1) <= beta/4

    vabd.u16 q8, q3, q2             // abs(R0-L0)
    vabd.u16 q9, q0, q2             // abs(L2-L0)
    vabd.u16 q10, q3, q5            // abs(R0-R2)
    vcgt.u16 q8, q15, q8            // abs(R0-L0) < alpha
    vcgt.u16 q9, q14, q9            // abs(L2-L0) < beta
    vcgt.u16 q10, q14, q10          // abs(R2-R0) < beta

    vand q11, q11, q12              // abs(L0-L1) < beta && abs(R0-R1) < beta
    vand q9, q9, q10                // abs(L2-L0) < beta && abs(R2-R0) < beta
    vand q6, q6, q7                 // abs(L0-L1) <= beta/4 && abs(R0-R1) <= beta/4

    vand  q15, q11, q13             // flt0: mask L0, R0
    vand  q14, q8, q9
    vand  q13, q6, q15
    vand  q14, q14, q13             // flt1: mask L1, R1

    // filter L0, R0
    vshl.u16 q6, q3, #1             // R0 * 2
    vshl.u16 q7, q2, #1
    vshl.u16 q8, q1, #3             // L1 * 8
    vshl.u16 q9, q4, #3
    vadd.u16 q10, q2, q0            // L0 + L2
    vadd.u16 q11, q3, q5
    vadd.u16 q8, q6, q8             // (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q7, q9
    vshl.u16 q12, q10, #1           // (L0 + L2)*2
    vshl.u16 q13, q11, #1
    vadd.u16 q8, q10, q8            // (L0 + L2) + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q11, q9
    vadd.u16 q8, q8, q12            // (L0 + L2)*3 + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q9, q13

    vrshr.u16 q8, q8, #4
    vrshr.u16 q9, q9, #4

    vshl.u16 q12, q2, #3            // L0 * 8
    vshl.u16 q13, q3, #3
    vadd.u16 q10, q1, q3            // L1 + R0
    vadd.u16 q11, q4, q2
    vadd.u16 q12, q12, q7           // L0 * 10
    vadd.u16 q13, q13, q6
    vshl.u16 q6, q10, #1            // (L1 + R0)*2
    vshl.u16 q7, q11, #1
    vadd.u16 q10, q10, q12          // (L1 + R0)*3
    vadd.u16 q11, q11, q13
    vadd.u16 q10, q6, q10           // (L1 + R0)*3 + L0*10
    vadd.u16 q11, q7, q11

    vrshr.u16 q10, q10, #4
    vrshr.u16 q11, q11, #4

    vbit q1, q8, q14                // L1
    vbit q2, q10, q15               // L0
    vbit q3, q11, q15               // R0
    vbit q4, q9, q14                // R1

    //store L1, L0, R0, R1
    //vmovn.u16 d0, q0
    //vmovn.u16 d1, q1
    //vmovn.u16 d2, q2
    //vmovn.u16 d3, q3
    //vmovn.u16 d4, q4
    //vmovn.u16 d5, q5

    vst4.32 {d0[0], d2[0], d4[0], d6[0]}, [r3]!
    vst2.32 {d8[0], d10[0]}, [r3], r5
    vst4.32 {d0[1], d2[1], d4[1], d6[1]}, [r3]!
    vst2.32 {d8[1], d10[1]}, [r3], r5
    vst4.32 {d1[0], d3[0], d5[0], d7[0]}, [r3]!
    vst2.32 {d9[0], d11[0]}, [r3], r5
    vst4.32 {d1[1], d3[1], d5[1], d7[1]}, [r3]!
    vst2.32 {d9[1], d11[1]}, [r3]

    vpop {q4, q5, q6, q7}
    pop {r4-r9, pc}


/*****************************************************************************************************
*  void uavs3d_deblock_hor_luma_armv7(pel *SrcPtr, int stride, int Alpha, int Beta, int flt_flag)
*  SrcPtr->r0, stride->r1, Alpha->r2, Beta->r3, flt_flag->r4
******************************************************************************************************/
function uavs3d_deblock_hor_luma_armv7
    push {r4-r7, lr}
    vpush {q4, q5, q6, q7}
    ldr r4, [sp, #84]
    lsl r1, r1, #1

    // prepare data
    vdup.s16 q15, r2                // save Alpha
    vdup.s16 q14, r3                // save Beta

    sub r0, r0, r1, lsl #2         // src - 4*stride
    add r2, r0, r1                 // src - 3*stride

	vld1.64 {q0}, [r0], r1          // l3
	vld1.64 {q1}, [r0], r1          // l2
	vld1.64 {q2}, [r0], r1          // l1
	vld1.64 {q3}, [r0], r1          // l0
	vld1.64 {q4}, [r0], r1          // r0
	vld1.64 {q5}, [r0], r1          // r1
	vld1.64 {q6}, [r0], r1	        // r2
	vld1.64 {q7}, [r0]	  	        // r3

    // q7 : R3
    // q6 : R2
    // q5 : R1
    // q4 : R0
    // q3 : L0
    // q2 : L1
    // q1 : L2
    // q0 : L3

    vmov.i16 q12, #2
    vabd.u16 q8, q2, q3             // COM_ABS(L1 - L0)
    vabd.u16 q9, q4, q5             // COM_ABS(R0 - R1)
    vcgt.u16 q8, q14, q8            // COM_ABS(L1 - L0) < Beta
    vcgt.u16 q9, q14, q9            // COM_ABS(R0 - R1) < Beta
    vand  q8, q8, q12               // FlatnessL
    vand  q9, q9, q12               // FlatnessR

    vabd.u16 q10, q1, q3            // COM_ABS(L2 - L0)
    vabd.u16 q11, q4, q6            // COM_ABS(R0 - R2)
    vmov.i16 q12, #1
    vcgt.u16 q10, q14, q10          // COM_ABS(L2 - L0) < Beta
    vcgt.u16 q11, q14, q11          // COM_ABS(R0 - R2) < Beta

    vand  q10, q10, q12
    vand  q11, q11, q12
    vadd.u16 q8, q8, q10            // FlatnessL++ (saved)
    vadd.u16 q9, q9, q11            // FlatnessR++

    vadd.u16 q9, q8, q9             // flt = FlatnessL + FlatnessR (saved)

    vabd.u16 q10, q2, q3            // COM_ABS(L1 - L0)
    vabd.u16 q11, q4, q5            // COM_ABS(R0 - R1)
    vshr.u16 q12, q14, #2           // Beta/4

    vcge.u16 q10, q12, q10          // COM_ABS(L1 - L0) <= Beta / 4
    vcge.u16 q11, q12, q11          // COM_ABS(R0 - R1) <= Beta / 4
    vabd.u16 q12, q4, q3            // ABS(R0 - L0)
    vand  q10, q10, q11             // (COM_ABS(L1 - L0) <= Beta / 4) && (COM_ABS(R1 - R0) <= Beta / 4)
    vcgt.u16 q12, q15, q12          // ABS(R0 - L0) < Alpha
    vand  q10, q10, q12

    // flt == 6
    vmov.i16 q15, #6
    vmov.i16 q11, #3
    vmov.i16 q12, #4
    vmov.i16 q13, #0                // fs = 0
    vceq.u16 q15, q9, q15           // flt == 6
    vbif  q12, q11, q10
    vbit  q13, q12, q15             // fs34 (save)

    // flt == 5
    vceq.u16 q11, q2, q3            // L0 == L1
    vceq.u16 q12, q4, q5            // R1 == R0
    vand  q11, q11, q12             // (R1 == R0) && (L0 == L1)

    vmov.i16 q10, #2                // q10 = 2
    vabd.u16 q12, q2, q5            // COM_ABS(L1 - R1)
    vceq.u16 q8, q8, q10            // FlatnessL == 2
    vcgt.u16 q14, q14, q12          // COM_ABS(L1 - R1) < Beta

    vmov.i16 q12, #5
    vmov.i16 q15, #3
    vceq.u16 q12, q9, q12           // flt == 5
    vbit  q10, q15, q11             // fs23
    vbit  q13, q10, q12             // fs234

    // flt == 4
    vmov.i16 q12, #4
    vmov.i16 q10, #1
    vmov.i16 q11, #2
    vceq.u16 q12, q9, q12           // flt == 4
    vbit  q10, q11, q8              // fs12
    vbit  q13, q10, q12             // fs1234

    // flt == 3
    vmov.i16 q12, #3
    vmov.i16 q10, #0
    vmov.i16 q11, #1
    vceq.u16 q12, q9, q12           // flt == 3
    vbit  q10, q11, q14             // fs01
    vbit  q13, q10, q12             // fs01234

    // prepare flt_flag[0] & flt_flag[1]
    and r6, r4, #1
    lsr r4, r4, #8
    neg r6, r6
    and r7, r4, #1
    neg r7, r7

    vdup.s32 d28, r6                // q14: flt_flag[0] flt_flag[0] flt_flag[1] flt_flag[1]
    vdup.s32 d29, r7

    vand  q15, q13, q14             // fs & flt_flag

    // fs == 1
    vadd.u16 q8, q3, q4             // L0 + R0 (saved)
    vshl.u16 q9, q3, #1             // L0 << 1
    vshl.u16 q10, q4, #1            // R0 << 1
    vadd.u16 q12, q9 , q8           // L0 + (L0 << 1) + R0
    vadd.u16 q13, q10, q8           // L0 + (R0 << 1) + R0

    vrshr.u16 q12, q12, #2
    vrshr.u16 q13, q13, #2
    vceq.u16 q14, q15, q11          // if fs == 1
    vbif   q12, q3, q14
    vbif   q13, q4, q14

    // fs == 2
    vshl.u16 q8, q8, #1             // (L0 + R0)<<1 (saved)
    vadd.u16 q9 , q2, q4            // L1 + R0
    vadd.u16 q10, q3, q5            // L0 + R1
    vshl.u16 q11, q2, #1            // L1<<1
    vshl.u16 q14, q5, #1            // R1<<1
    vadd.u16 q9 , q8, q9            // (L0+R0)<<1 + L1 + R0
    vadd.u16 q10, q8, q10           // (L0+R0)<<1 + L0 + R1
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1

    vshl.u16 q11, q3, #3            // L0<<3
    vshl.u16 q14, q4, #3            // R0<<3
    vadd.u16 q9 , q11, q9           // (L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3
    vadd.u16 q10, q14, q10          // (L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<1 + L1 + R0 + L1<<1 + L0<<3)>>4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<1 + L0 + R1 + R1<<1 + R0<<3)>>4
    vmov.i16  q11, #2
    vceq.u16 q11, q15, q11          // fs == 2
    vbit   q12, q9 , q11
    vbit   q13, q10, q11

    // fs == 3; update src[0] src[-1]
    vshl.u16 q8, q8, #1             // (L0+R0)<<2 --> V16
    vshl.u16 q9, q2, #2             // L1<<2
    vshl.u16 q10, q5, #2            // R1<<2
    vadd.u16 q11, q1, q5            // L2 + R1
    vadd.u16 q14, q2, q6            // L1 + R2
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2
    vadd.u16 q10, q14, q10
    vshl.u16 q11, q3, #1            // L0 << 1
    vshl.u16 q14, q4, #1            // R0 << 1
    vadd.u16 q9 , q11, q9           // L2 + R1 + L1<<2 + L0<<1
    vadd.u16 q10, q14, q10
    vadd.u16 q9, q9, q8             // (L0+R0)<<2 + L2+R1 + L1<<2 + L0<<1
    vadd.u16 q10, q10, q8           // (L0+R0)<<2 + L1+R2 + R1<<2 + R0<<1

    vmov.i16 q11, #3
    vrshr.u16 q9, q9, #4            // ((L0+R0)<<2 + (L2 + R1) + L0<<1+L1<<2) >> 4
    vrshr.u16 q10, q10, #4          // ((L0+R0)<<2 + (L1 + R2) + R0<<1+R1<<2) >> 4

    vceq.u16 q11, q15, q11          // fs == 3 (saved)
    vbit   q12, q9, q11             // update L0
    vbit   q13, q10, q11

    // fs == 3; calculate src[-2] src[1]
    vadd.u16 q14, q1, q4            // L2+R0
    vadd.u16 q8, q6, q3             // R2+L0
    vshl.u16 q10, q1, #1            // L2<<1
    vshl.u16 q9, q6, #1             // R2<<1
    vadd.u16 q14, q14, q10            // L2+R0+L2<<1
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1

    vshl.u16 q10, q2, #3            // L1<<3
    vshl.u16 q9, q5, #3             // R1<<3
    vadd.u16 q14, q14, q10          // L2+R0+L2<<1 + (L1<<3)
    vadd.u16 q8, q8, q9             // R2+L0+R2<<1 + (R1<<3)

    vshl.u16 q10, q3, #2            // L0<<2
    vshl.u16 q9, q4, #2             // R0<<2
    vadd.u16 q14, q14, q10          // ((L2+R0+L2<<1) + (L1<<3)) + L0<<2
    vadd.u16 q8, q8, q9             //

    vrshr.u16 q14, q14, #4
    vrshr.u16 q8, q8, #4
    vbif   q14, q2, q11
    vbif   q8, q5, q11              // update L1_dst and R1_dst

    // fs == 4
    vmov.i16 q9, #4
    vceq.u16 q9, q15, q9
    vpadd.i32 d20, d18, d19
    vmov r6, r7, d20
    orr	 r6, r6, r7
    cmp  r6, #0
    beq  deblock_hor_filtered

    vpush {q14}
    // if fs == 4 exist
    // calculate L0 and R0
    vadd.u16 q10, q3, q4            // L0 + R0
    vshl.u16 q14, q2, #3            // L1<<3
    vshl.u16 q11, q10, #3           // (R0+L0)<<3
    vshl.u16 q15, q5, #3            //
    vadd.u16 q14, q14, q11          // (R0+L0)<<3 + L1*8
    vadd.u16 q15, q15, q11

    vadd.u16 q10, q1, q5            // L2 + R1
    vadd.u16 q11, q2, q6
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 +L2+R1
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q10, #1           // (L2 + R1)*2
    vshl.u16 q11, q11, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vshl.u16 q10, q3, #1
    vshl.u16 q11, q4, #1
    vadd.u16 q14, q14, q10          // (R0+L0)<<3 + L1*8 + (L2+R1)*3 + L0*2
    vadd.u16 q15, q15, q11

    vrshr.u16 q14, q14, #5          // ((L1*8 + L0*2) + ((R0+L0)*8) + (L2 + R1)*3)>>5
    vrshr.u16 q15, q15, #5

    vbit   q12, q14, q9             // update L0
    vbit   q13, q15, q9

    // calculate L1 and R1
    vadd.u16 q10, q1, q2            // L2 + L1
    vadd.u16 q11, q6, q5
    vadd.u16 q14, q2, q4            // L1 + R0
    vadd.u16 q15, q5, q3
    vadd.u16 q10, q10, q3           // L2+L1+L0
    vadd.u16 q11, q11, q4
    vshl.u16 q10, q10, #2           // (L0 + L1 + L2)*4
    vshl.u16 q11, q11, #2

    vadd.u16 q14, q14, q10          // L1+R0 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q11

    vshl.u16 q11, q4, #1
    vshl.u16 q10, q3, #1            // L0*2
    vadd.u16 q14, q14, q11          // L1+R0 + R0*2 + (L0 + L1 + L2)*4
    vadd.u16 q15, q15, q10

    vrshr.s16 q10, q14, #4          //
    vrshr.s16 q11, q15, #4
    vpop {q14}
    vbit q14, q10, q9
    vbit q8, q11, q9

    // calculate L2 and R2
    vadd.u16 q10, q3, q4            // L0 + R0
    vadd.u16 q11, q1, q2            // L2 + L1
    vadd.u16 q15, q6, q5
    vadd.u16 q11, q11, q0           // L1 + L2 + L3
    vadd.u16 q15, q15, q7
    vshl.u16 q11, q11, #1           // (L1 + L2 + L3)*2
    vshl.u16 q15, q15, #1
    vadd.u16 q11, q11, q10
    vadd.u16 q15, q15, q10

    vrshr.u16 q11, q11, #3          // ((L1 + L2 + L3)*2 + L0 + R0 + 4)>>3
    vrshr.u16 q15, q15, #3          //

deblock_hor_filtered:
    vbif   q11, q1, q9
    vbif   q15, q6, q9

    // vmovn.u16 d0, q11
    // vmovn.u16 d1, q14
    // vmovn.u16 d2, q12
    // vmovn.u16 d3, q13
    // vmovn.u16 d4, q8
    // vmovn.u16 d5, q15

    vst1.16 {q11}, [r2], r1
    vst1.16 {q14}, [r2], r1
    vst1.16 {q12}, [r2], r1
    vst1.16 {q13}, [r2], r1
    vst1.16 {q8}, [r2], r1
    vst1.16 {q15}, [r2]

    vpop {q4, q5, q6, q7}
    pop {r4-r7, pc}


/*****************************************************************************************************
 *  void uavs3d_deblock_hor_chroma_armv7(pel *srcuv, int stride, int alpha_u, int beta_u, int alpha_v, int beta_v, int flt_flag);
 *  SrcPtrU->r0, stride->r1, alpha_u->r2, beta_u->r3, alpha_v->r4, beta_v->r5, flt_flag->r6
 ******************************************************************************************************/
function uavs3d_deblock_hor_chroma_armv7
    push {r4-r9, lr}
	add sp, sp, #28
	ldmia sp, {r4, r5, r6}
	sub sp, sp, #28
    vpush {q4, q5, q6, q7}

    lsl r1, r1, #1

    add r2, r2, r4, lsl #16
    add r3, r3, r5, lsl #16

    vdup.s32 q15, r2                // q15: alphau alphau alphau alphau, alphav alphav alphav alphav
    vdup.s32 q14, r3                // q14: betau, betav

    lsr r8, r6, #1
    lsr r7, r6, #9
    and r8, r8, #1
    and r9, r7, #1
    neg r8, r8                      // flag0
    neg r9, r9                      // flag1

    vdup.32 d26, r8
    vdup.32 d27, r9                 // v26: flag0 flag0 flag1 flag1

    sub r0, r0, r1, lsl #1          // srcuv - 2*stride
    sub r2, r0, r1                  // srcuv - 3*stride

    vld1.16 {q0}, [r2], r1          // L2
    vld1.16 {q1}, [r2], r1          // L1
    vld1.16 {q2}, [r2], r1          // L0
    vld1.16 {q3}, [r2], r1          // R0
    vld1.16 {q4}, [r2], r1          // R1
    vld1.16 {q5}, [r2]              // R2

    vabd.u16 q6, q2, q1             // abs(L0-L1)
    vabd.u16 q7, q3, q4             // abs(R0-R1)
    vshr.u16 q8, q14, #2            // beta/4
    vcgt.u16 q11, q14, q6           // abs(L0-L1) < beta
    vcgt.u16 q12, q14, q7           // abs(R0-R1) < beta
    vcge.u16 q6, q8, q6             // abs(L0-L1) <= beta/4
    vcge.u16 q7, q8, q7             // abs(R0-R1) <= beta/4

    vabd.u16 q8, q3, q2             // abs(R0-L0)
    vabd.u16 q9, q0, q2             // abs(L2-L0)
    vabd.u16 q10, q3, q5            // abs(R0-R2)
    vcgt.u16 q8, q15, q8            // abs(R0-L0) < alpha
    vcgt.u16 q9, q14, q9            // abs(L2-L0) < beta
    vcgt.u16 q10, q14, q10          // abs(R2-R0) < beta

    vand q11, q11, q12              // abs(L0-L1) < beta && abs(R0-R1) < beta
    vand q9, q9, q10                // abs(L2-L0) < beta && abs(R2-R0) < beta
    vand q6, q6, q7                 // abs(L0-L1) <= beta/4 && abs(R0-R1) <= beta/4

    vand  q15, q11, q13             // flt0: mask L0, R0
    vand  q14, q8, q9
    vand  q13, q6, q15
    vand  q14, q14, q13             // flt1: mask L1, R1

    // filter L0, R0
    vshl.u16 q6, q3, #1             // R0 * 2
    vshl.u16 q7, q2, #1
    vshl.u16 q8, q1, #3             // L1 * 8
    vshl.u16 q9, q4, #3
    vadd.u16 q10, q2, q0            // L0 + L2
    vadd.u16 q11, q3, q5
    vadd.u16 q8, q6, q8             // (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q7, q9
    vshl.u16 q12, q10, #1           // (L0 + L2)*2
    vshl.u16 q13, q11, #1
    vadd.u16 q8, q10, q8            // (L0 + L2) + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q11, q9
    vadd.u16 q8, q8, q12            // (L0 + L2)*3 + (R0 * 2) + (L1 * 8)
    vadd.u16 q9, q9, q13

    vrshr.u16 q8, q8, #4
    vrshr.u16 q9, q9, #4

    vshl.u16 q12, q2, #3            // L0 * 8
    vshl.u16 q13, q3, #3
    vadd.u16 q10, q1, q3            // L1 + R0
    vadd.u16 q11, q4, q2
    vadd.u16 q12, q12, q7           // L0 * 10
    vadd.u16 q13, q13, q6
    vshl.u16 q6, q10, #1            // (L1 + R0)*2
    vshl.u16 q7, q11, #1
    vadd.u16 q10, q10, q12          // (L1 + R0)*3
    vadd.u16 q11, q11, q13
    vadd.u16 q10, q6, q10           // (L1 + R0)*3 + L0*10
    vadd.u16 q11, q7, q11

    vrshr.u16 q10, q10, #4
    vrshr.u16 q11, q11, #4

    vbit q1, q8, q14                // L1
    vbit q2, q10, q15               // L0
    vbit q3, q11, q15               // R0
    vbit q4, q9, q14                // R1

    //store L1, L0, R0, R1
    //vmovn.u16 d1, q1
    //vmovn.u16 d2, q2
    //vmovn.u16 d3, q3
    //vmovn.u16 d4, q4

    vst1.16 {q1}, [r0], r1
    vst1.16 {q2}, [r0], r1
    vst1.16 {q3}, [r0], r1
    vst1.16 {q4}, [r0]

    vpop {q4, q5, q6, q7}
    pop {r4-r9, pc}

#endif  // COMPILE_10BIT

#endif
