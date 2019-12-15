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

//void uavs3d_intra_pred_ver_armv7(pel *src, pel *dst, int i_dst, int width, int height)
//src->r0, dst->r1, i_dst->r2, width->r3, height->r4
function uavs3d_intra_pred_ver_armv7
    //branch
    push {r4-r5, lr}
    ldr r4, [sp, #12]

    //branch
    cmp r3, #16
    beq intra_pred_ver_w16
    bgt intra_pred_ver_w32x

    cmp r3, #8
    beq intra_pred_ver_w8

    //intra_pred_ver_w4:

    ldr r5, [r0]  //load src[x]
    intra_pred_ver_w4_y:
    str r5, [r1], r2
    str r5, [r1], r2
    str r5, [r1], r2
    str r5, [r1], r2
    subs r4, r4, #4
    bgt intra_pred_ver_w4_y

    b intra_pred_ver_end

intra_pred_ver_w8:
    vld1.64 d0, [r0]
intra_pred_ver_w8_y:
    vst1.32 {d0}, [r1], r2
    vst1.32 {d0}, [r1], r2
    subs r4, r4, #4
    vst1.32 {d0}, [r1], r2
    vst1.32 {d0}, [r1], r2
    bgt intra_pred_ver_w8_y

    b intra_pred_ver_end

intra_pred_ver_w16:
    vld1.64 {d0, d1}, [r0]
intra_pred_ver_w16_y:
    vst1.64 {d0, d1}, [r1], r2
    vst1.64 {d0, d1}, [r1], r2
    subs r4, r4, #4
    vst1.64 {d0, d1}, [r1], r2
    vst1.64 {d0, d1}, [r1], r2
    bgt intra_pred_ver_w16_y

    b intra_pred_ver_end

intra_pred_ver_w32x:
    cmp r3, #64
    beq intra_pred_ver_w64
    bgt intra_pred_ver_w128

intra_pred_ver_w32:
    vld1.64 {q0, q1}, [r0]
intra_pred_ver_w32_y:
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1], r2
    subs r4, r4, #4
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1], r2
    bgt intra_pred_ver_w32_y

    b intra_pred_ver_end

intra_pred_ver_w64:
    sub r2, r2, #32
    vld1.64 {q0, q1}, [r0]!
    vld1.64 {q2, q3}, [r0]
intra_pred_ver_w64_y:
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1], r2
    subs r4, r4, #4
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1], r2
    bgt intra_pred_ver_w64_y
    b intra_pred_ver_end

intra_pred_ver_w128:
    sub r2, r2, #96
    vld1.64 {q0, q1}, [r0]!
    vld1.64 {q2, q3}, [r0]!
    vld1.64 {q12, q13}, [r0]!
    vld1.64 {q14, q15}, [r0]
intra_pred_ver_w128_y:
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1]!
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q14, q15}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1]!
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q14, q15}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1]!
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q14, q15}, [r1], r2
    subs r4, r4, #8
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q2, q3}, [r1]!
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q14, q15}, [r1], r2
    bgt intra_pred_ver_w128_y

intra_pred_ver_end:
    pop {r4-r5, pc}


//void uavs3d_intra_pred_hor_armv7(pel *src, pel *dst, int i_dst, int width, int height)
//src->r0, dst->r1, i_dst->r2, width->r3, height->r4
function uavs3d_intra_pred_hor_armv7
    push {r4, lr}
    ldr r4, [sp, #8]

    //branch
    cmp r3, #16
    beq intra_pred_hor_w16
    bgt intra_pred_hor_w32x

    cmp r3, #8
    beq intra_pred_hor_w8
//intra_pred_hor_w4:
    sub r0, r0, #3
intra_pred_hor_w4_y:
    vld1.32 {d0[0]}, [r0]      // load src[-y]
    vdup.8 d1, d0[3]
    vdup.8 d2, d0[2]
    vdup.8 d3, d0[1]
    vdup.8 d4, d0[0]
    vst1.32 {d1[0]}, [r1], r2
    vst1.32 {d2[0]}, [r1], r2
    vst1.32 {d3[0]}, [r1], r2
    vst1.32 {d4[0]}, [r1], r2
    subs r4, r4, #4
    sub r0, r0, #4
    bgt intra_pred_hor_w4_y

    b intra_pred_hor_end

intra_pred_hor_w8:
    sub r0, r0, #3
intra_pred_hor_w8_y:
    vld1.64 {d0}, [r0]          // load src[-y]
    vdup.8 d1, d0[3]
    vdup.8 d2, d0[2]
    vdup.8 d3, d0[1]
    vdup.8 d4, d0[0]
    vst1.64 {d1}, [r1], r2
    vst1.64 {d2}, [r1], r2
    vst1.64 {d3}, [r1], r2
    vst1.64 {d4}, [r1], r2
    subs r4, r4, #4
    sub r0, r0, #4
    bgt intra_pred_hor_w8_y

    b intra_pred_hor_end

intra_pred_hor_w16:
    sub r0, r0, #3
intra_pred_hor_w16_y:
    vld1.64 {d0}, [r0]          // load src[-y]
    vdup.8 q1, d0[3]
    vdup.8 q2, d0[2]
    vdup.8 q3, d0[1]
    vdup.8 q0, d0[0]
    vst1.64 {q1}, [r1], r2
    vst1.64 {q2}, [r1], r2
    vst1.64 {q3}, [r1], r2
    vst1.64 {q0}, [r1], r2
    subs r4, r4, #4
    sub r0, r0, #4
    bgt intra_pred_hor_w16_y

    b intra_pred_hor_end

intra_pred_hor_w32x:
    cmp r3, #64
    beq intra_pred_hor_w64
    bgt intra_pred_hor_w128

intra_pred_hor_w32:
    sub r0, r0, #3
intra_pred_hor_w32_y:
    vld1.64 {d0}, [r0]
    vdup.8 q8 , d0[3]
    vdup.8 q10, d0[2]
    vdup.8 q12, d0[1]
    vdup.8 q14, d0[0]
    vmov q9 , q8
    vmov q11, q10
    vmov q13, q12
    vmov q15, q14
    vst1.64 {q8 , q9 }, [r1], r2
    vst1.64 {q10, q11}, [r1], r2
    vst1.64 {q12, q13}, [r1], r2
    vst1.64 {q14, q15}, [r1], r2
    subs r4, r4, #4
    sub r0, r0, #4
    bgt intra_pred_hor_w32_y

    b intra_pred_hor_end

intra_pred_hor_w64:
    sub r2, r2, #32
    sub r0, r0, #3
intra_pred_hor_w64_y:
    vld1.64 {d0}, [r0]
    vdup.8 q8 , d0[3]
    vdup.8 q10, d0[2]
    vdup.8 q12, d0[1]
    vdup.8 q14, d0[0]
    vmov q9 , q8
    vmov q11, q10
    vmov q13, q12
    vmov q15, q14
    vst1.64 {q8, q9}, [r1]!
    vst1.64 {q8, q9}, [r1], r2
    vst1.64 {q10, q11}, [r1]!
    vst1.64 {q10, q11}, [r1], r2
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q12, q13}, [r1], r2
    vst1.64 {q14, q15}, [r1]!
    vst1.64 {q14, q15}, [r1], r2
    subs r4, r4, #4
    sub r0, r0, #4
    bgt intra_pred_hor_w64_y

    b intra_pred_hor_end

intra_pred_hor_w128:
    sub r2, r2, #96
    sub r0, r0, #3
intra_pred_hor_w128_y:
    vld1.64 {d0}, [r0]
    vdup.8 q8 , d0[3]
    vdup.8 q10, d0[2]
    vdup.8 q12, d0[1]
    vdup.8 q14, d0[0]
    vmov q9 , q8
    vmov q11, q10
    vmov q13, q12
    vmov q15, q14
    vst1.64 {q8, q9}, [r1]!
    vst1.64 {q8, q9}, [r1]!
    vst1.64 {q8, q9}, [r1]!
    vst1.64 {q8, q9}, [r1], r2
    vst1.64 {q10, q11}, [r1]!
    vst1.64 {q10, q11}, [r1]!
    vst1.64 {q10, q11}, [r1]!
    vst1.64 {q10, q11}, [r1], r2
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q12, q13}, [r1]!
    vst1.64 {q12, q13}, [r1], r2
    vst1.64 {q14, q15}, [r1]!
    vst1.64 {q14, q15}, [r1]!
    vst1.64 {q14, q15}, [r1]!
    vst1.64 {q14, q15}, [r1], r2
    subs r4, r4, #4
    sub r0, r0, #4
    bgt intra_pred_hor_w128_y

    b intra_pred_hor_end

intra_pred_hor_end:
    pop {r4, pc}

.global DC_tab_div
DC_tab_div:
.byte 204, 170, 146, 128, 113, 102, 93, 85, 78, 73, 68, 64, 60, 56, 53, 51, 48, 46, 44, 42, 32, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 4
//void uavs3d_intra_pred_dc_armv7(pel *src, pel *dst, int i_dst, int width, int height, int avail, int sample_bit_depth)
//src->r0, dst->r1, i_dst->r2, width->r3, height->r4, avail->r5, sample_bit_depth->r6
function uavs3d_intra_pred_dc_armv7
    push {r4-r12, lr}
    ldr r4, [sp, #40]
    ldr r5, [sp, #44]

    and r7, r5, #2          // left avail
    and r8, r5, #1          // up avail
    lsr r7, r7, #1

    and r9, r7, r8
    cmp r9, #0
    bne intra_pred_dc_above_left

    cmp r8, #0
    bne intra_pred_dc_above

    cmp r7, #0
    beq intra_pred_dc_none

intra_pred_dc_left:
    sub r10, r0, r4
    mov r7, r4
    b intra_pred_dc_single_line
intra_pred_dc_above:
    add r10, r0, #1
    mov r7, r3

intra_pred_dc_single_line:
    cmp r7, #16
    beq intra_pred_dc_1ref_w16
    bgt intra_pred_dc_1ref_w32x

    cmp r7, #8
    beq intra_pred_dc_1ref_w8

//intra_pred_dc_1ref_w4:
    vmov.u16 q0, #0
    vld1.32 {d0[0]}, [r10]
    vpaddl.u8 d0, d0
    vpadd.u16 d0, d0, d0

    vmov.u16 r8, d0[0]
    add r8, r8, #2
    lsr r8, r8, #2          // dc /= height;
    vdup.8 q0, r8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w8:
    vmov.u16 q0, #0
    vld1.64 {d0}, [r10]
    vpaddl.u8 d0, d0
    vpadd.u16 d0, d0, d0
    vpadd.u16 d0, d0, d0

    vmov.u16 r8, d0[0]
    add r8, r8, #4
    lsr r8, r8, #3
    vdup.8 q0, r8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w16:
    vld1.64 {d0, d1}, [r10]
    vaddl.u8 q0, d0, d1
    vadd.u16 d0, d0, d1
    vpadd.u16 d0, d0, d0
    vpadd.u16 d0, d0, d0

    vmov.u16 r8, d0[0]
    add r8, r8, #8
    lsr r8, r8, #4
    vdup.8 q0, r8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w32x:
    cmp r7, #64
    beq intra_pred_dc_1ref_w64
    bgt intra_pred_dc_1ref_w128

//intra_pred_dc_1ref_w32:
    vld1.64 {d0, d1, d2, d3}, [r10]
    vaddl.u8 q0, d0, d1
    vaddl.u8 q1, d2, d3
    vadd.u16 q0, q0, q1
    vadd.u16 d0, d0, d1
    vpadd.u16 d0, d0, d0
    vpadd.u16 d0, d0, d0

    vmov.u16 r8, d0[0]
    add r8, r8, #16
    lsr r8, r8, #5
    vdup.8 q0, r8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w64:
    vld1.64 {d0, d1, d2, d3}, [r10]!
    vld1.64 {d4, d5, d6, d7}, [r10]
    vaddl.u8 q0, d0, d1
    vaddl.u8 q1, d2, d3
    vaddl.u8 q2, d4, d5
    vaddl.u8 q3, d6, d7
    vadd.u16 q0, q0, q1
    vadd.u16 q2, q2, q3
    vadd.u16 q0, q0, q2
    vadd.u16 d0, d0, d1
    vpadd.u16 d0, d0, d0
    vpadd.u16 d0, d0, d0

    vmov.u16 r8, d0[0]
    add r8, r8, #32
    lsr r8, r8, #6
    vdup.8 q0, r8

    b intra_pred_dc_fillblock

intra_pred_dc_1ref_w128:


intra_pred_dc_none:
    vmov.u8 q0, #128
    b intra_pred_dc_fillblock

intra_pred_dc_above_left:
    add r10, r0, #1         // rpSrc = pSrc + 1;

    //branch
    cmp r3, #16
    beq intra_pred_dc_above_left_w16
    bgt intra_pred_dc_above_left_w32x

    cmp r3, #8
    beq intra_pred_dc_above_left_w8

//intra_pred_dc_above_left_w4:
    vmov.u16 q0, #0
    vld1.32 {d0[0]}, [r10]
    vmovl.u8 q0, d0
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w8:
    vmov.u16 q0, #0
    vld1.64 {d0}, [r10]
    vmovl.u8 q0, d0
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w16:
    vmov.u16 q0, #0
    vld1.64 {d0, d1}, [r10]
    vaddl.u8 q0, d0, d1
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w32x:
    cmp r3, #64
    beq intra_pred_dc_above_left_w64
//  bgt intra_pred_dc_above_left_w128

//intra_pred_dc_above_left_w32:
    vld1.64 {q0, q1}, [r10]
    vaddl.u8 q2, d0, d2
    vaddl.u8 q3, d1, d3
    vadd.s16 q0, q2, q3
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_w64:
    vld1.64 {d0, d1, d2, d3}, [r10]!
    vld1.64 {d4, d5, d6, d7}, [r10]
    vaddl.u8 q0, d0, d1
    vaddl.u8 q1, d2, d3
    vaddl.u8 q2, d4, d5
    vaddl.u8 q3, d6, d7
    vadd.u16 q0, q0, q1
    vadd.u16 q2, q2, q3
    vadd.u16 q0, q0, q2
    b intra_pred_dc_above_left_h

intra_pred_dc_above_left_h:

    //branch
    cmp r4, #16
    beq intra_pred_dc_above_left_h16
    bgt intra_pred_dc_above_left_h32x

    cmp r4, #8
    beq intra_pred_dc_above_left_h8

//intra_pred_dc_above_left_h4:
    vmov.s16 q1, #0
    sub r10, r0, #4
    vld1.32 {d2[0]}, [r10]
    vaddw.u8 q0, q0, d2
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h8:
    sub r10, r0, #8
    vld1.64 {d2}, [r10]
    vaddw.u8 q0, q0, d2
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h16:
    sub r10, r0, #16
    vld1.64 {d2, d3}, [r10]
    vaddl.u8 q1, d2, d3
    vadd.u16 q0, q0, q1
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h32x:
    cmp r4, #64
    beq intra_pred_dc_above_left_h64
//    bgt intra_pred_dc_above_left_h128

    sub r10, r0, #32
    vld1.64 {d2, d3, d4, d5}, [r10]
    vaddl.u8 q1, d2, d3
    vaddl.u8 q2, d4, d5
    vadd.u16 q1, q1, q2
    vadd.u16 q0, q0, q1
    b intra_pred_dc_above_left_dcvalue

intra_pred_dc_above_left_h64:
    sub r10, r0, #64
    vld1.64 {d2, d3, d4, d5}, [r10]!
    vld1.64 {d6, d7, d8, d9}, [r10]
    vaddl.u8 q1, d2, d3
    vaddl.u8 q2, d4, d5
    vaddl.u8 q3, d6, d7
    vaddl.u8 q4, d8, d9
    vadd.u16 q1, q1, q2
    vadd.u16 q3, q3, q4
    vadd.u16 q1, q1, q3
    vadd.u16 q0, q0, q1

intra_pred_dc_above_left_dcvalue:
    vadd.u16 d0, d0, d1
    vpadd.u16 d0, d0, d0
    vpadd.u16 d0, d0, d0

    // (dc + ((w + h) >> 1)) * (4096 / (w + h)) >> 12;
    add r10, r3, r4

    cmp r10, #17
    blt va255x

    lsr r8, r10, #1
    vmov.u16 r9, d0[0]
    add r8, r8, r9
    adr r12, DC_tab_div
    add r11, r3, r4
    lsr r11, r11, #2
    sub r11, r11, #5
    add r12, r12, r11
    ldrb r12, [r12]
    mul r8, r8, r12
    lsr r8, r8, #12
    vdup.8 q0, r8
    b intra_pred_dc_fillblock

va255x:
    cmp r10, #12
    bgt va256
    blt va512

//va341:
    lsr r8, r10, #1
    vmov.u16 r9, d0[0]
    mov r12, #256
    add r8, r8, r9
    add r12, #85
    mul r8, r8, r12
    lsr r8, r8, #12
    vdup.8 q0, r8
    b intra_pred_dc_fillblock

va512:
    lsr r8, r10, #1
    vmov.u16 r9, d0[0]
    add r8, r8, r9
    mov r12, #512
    mul r8, r8, r12
    lsr r8, r8, #12
    vdup.8 q0, r8
    b intra_pred_dc_fillblock

va256:
    lsr r8, r10, #1
    vmov.u16 r9, d0[0]
    add r8, r8, r9
    mov r12, #256
    mul r8, r8, r12
    lsr r8, r8, #12
    vdup.8 q0, r8
    b intra_pred_dc_fillblock

intra_pred_dc_fillblock:
    cmp r3, #16
    beq intra_pred_dc_fillblock_w16
    bgt intra_pred_dc_fillblock_w32x

    cmp r3, #8
    beq intra_pred_dc_fillblock_w8

// intra_pred_dc_fillblock_w4:

intra_pred_dc_fillblock_w4_y:
    vst1.32 {d0[0]}, [r1], r2
    vst1.32 {d0[0]}, [r1], r2
    subs r4, r4, #4
    vst1.32 {d0[0]}, [r1], r2
    vst1.32 {d0[0]}, [r1], r2
    bgt intra_pred_dc_fillblock_w4_y
    b   intra_pred_dc_end

intra_pred_dc_fillblock_w8:
    vst1.64 {d0}, [r1], r2
    vst1.64 {d0}, [r1], r2
    subs r4, r4, #4
    vst1.64 {d0}, [r1], r2
    vst1.64 {d0}, [r1], r2
    bgt intra_pred_dc_fillblock_w8

    b intra_pred_dc_end

intra_pred_dc_fillblock_w16:
    vst1.64 {d0, d1}, [r1], r2
    vst1.64 {d0, d1}, [r1], r2
    subs r4, r4, #4
    vst1.64 {d0, d1}, [r1], r2
    vst1.64 {d0, d1}, [r1], r2
    bgt intra_pred_dc_fillblock_w16

    b intra_pred_dc_end

intra_pred_dc_fillblock_w32x:
    cmp r3, #64
    beq intra_pred_dc_fillblock_w64
    bgt intra_pred_dc_fillblock_w128

//intra_pred_dc_fillblock_w32:
    mov r5, #0
    vmov.u8 q1, q0
intra_pred_dc_fillblock_w32_y:
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1], r2
    subs r4, r4, #4
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1], r2
    bgt intra_pred_dc_fillblock_w32_y

    b intra_pred_dc_end

intra_pred_dc_fillblock_w64:
    sub r2, r2, #32
    vmov.u8 q1, q0
intra_pred_dc_fillblock_w64_y:
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    subs r4, r4, #4
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    bgt intra_pred_dc_fillblock_w64_y
    b intra_pred_dc_end

intra_pred_dc_fillblock_w128:
    sub r2, r2, #96
    vmov.u8 q1, q0
intra_pred_dc_fillblock_w128_y:
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    subs r4, r4, #8
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1]!
    vst1.64 {q0, q1}, [r1], r2
    bgt intra_pred_dc_fillblock_w128_y

intra_pred_dc_end:
    pop {r4-r12, pc}


Plane_tab_mul_shift:
.byte 13, 17, 5, 11, 23, 7, 10, 11, 15, 19, 0, 0, 0, 0, 0, 0

//void uavs3d_intra_pred_plane_armv7(pel *src, pel *dst, int i_dst, int width, int height, int bit_depth)
//src->r0, dst->r1, i_dst->r2, width->r3, height->r4, bit_depth->r5
function uavs3d_intra_pred_plane_armv7
    push {r4-r12, lr}
    ldr r4, [sp, #40]

    clz r8, r3
    clz r9, r4
    rsb r8, r8, #29                     //log2[width] - 2
    rsb r9, r9, #29                     //log2[height] - 2

    adr r12, Plane_tab_mul_shift
    add r10, r8, r12                    // im_h = ib_mult[log2[width] - 2]
    ldrb r6, [r10]

    add r10, #5                         // is_h = ib_shift[log2[width] - 2]
    ldrb r7, [r10]

    add r10, r9, r12                    // im_v = ib_mult[log2[height] - 2]
    ldrb r8, [r10]

    add r10, #5                         // is_v = ib_shift[log2[height] - 2]
    ldrb r9, [r10]

    vmov d30, r6, r8                    // im_h, im_v
    vmov d31, r7, r9                    // is_h, is_v

    lsr r9, r3, #1                      // iW2 = width >> 1;
    lsr r10, r4, #1                     // iH2 = height >> 1;

    add r12, r0, r9                     // rpSrc = pSrc + 1;  rpSrc += (iW2 - 1);
    cmp r9, #4

    beq intra_pred_plane_coef_h_loop4
    bgt intra_pred_plane_coef_h_loop8

// intra_pred_plane_coef_h_loop2
    ldrb r6, [r12, #1]
    ldrb r7, [r12, #-1]
    sub r8, r6, r7
    ldrb r6, [r12, #2]
    ldrb r7, [r12, #-2]
    sub r11, r6, r7
    lsl r11, r11, #1
    add r8, r8, r11
    mov r11, #0
    vmov d0, r8, r11

    b  intra_pred_plane_coef_h_end

intra_pred_plane_coef_h_loop4:
    mov r6, #0x0304
    movt r6, #0x0102
    vmov.i32 d28[0], r6                 // d28[0]: 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // d26: 4, 3, 2, 1(short)

    add r6, r0, r9                      // rpSrc = pSrc + iW2
    sub r7, r6, #4

    vld1.8 d0, [r6]
    vld1.8 d1, [r7]

    vtbl.8 d0, {d0}, d28                // lookup

    vsubl.u8 q0, d0, d1                 // x * (rpSrc[x] - rpSrc[-x])
    vmull.s16 q0, d0, d26

    vadd.s32 d0, d0, d1

    b  intra_pred_plane_coef_h_end

intra_pred_plane_coef_h_loop8:
    ldr r6, =0x0304
    movt r6, #0x0102
    mov r7, #0x08
    add r7, #0x0700
    movt r7, #0x0506
    vmov d28, r7, r6                    // d28[0]: 8, 7, 6, 5, 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // q13: 8, 7, 6, 5, 4, 3, 2, 1(short)
    vmov.i16 q12, #8
    vmov.i32 q0, #0

    add r11, r0, r9                     // rpSrc = pSrc + iW2
    mov r8, #0
    sub r6, r11, #8
    add r11, #1

intra_pred_plane_coef_h_loop8_x:

    vld1.8 {d2}, [r11]
    vld1.8 d4, [r6]
    vrev64.8 d2, d2

    vsubl.u8 q1, d2, d4                 // x * (rpSrc[x] - rpSrc[-x])
    vmull.s16 q2, d2, d26
    vmull.s16 q3, d3, d27
    vadd.s32 q2, q2, q3
    vadd.s32 q0, q0, q2

    add r8, #8
    vadd.u16 q13, q13, q12
    add r11, #8
    sub r6, #8
    cmp r8, r9
    blt intra_pred_plane_coef_h_loop8_x

    vadd.s32 d0, d0, d1

intra_pred_plane_coef_h_end:

    cmp r10, #4
    beq intra_pred_plane_coef_v_loop4
    bgt intra_pred_plane_coef_v_loop8


// intra_pred_plane_coef_v_loop2
    sub r12, r0, r10                    // rpSrc = pSrc - iH2
    ldrb r6, [r12, #1]
    ldrb r7, [r12, #-1]
    sub r8, r7, r6
    ldrb r6, [r12, #2]
    ldrb r7, [r12, #-2]
    sub r11, r7, r6
    lsl r11, #1
    add r8, r8, r11
    mov r11, #0
    vmov d1, r8, r11

    b intra_pred_plane_coef_v_end

intra_pred_plane_coef_v_loop4:

    ldr r6, =0x0304
    movt r6, #0x0102
    vmov.i32 d28[0], r6                 // d28[0]: 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // d26: 4, 3, 2, 1(short)

    sub r12, r0, r10                    // rpSrc = pSrc - iH2
    sub r6, r12, #4

    vld1.8 d2, [r12]
    vld1.8 d3, [r6]

    vtbl.8 d2, {d2}, d28

    vsubl.u8 q1, d3, d2                 // x * (rpSrc[x] - rpSrc[-x])
    vmull.s16 q1, d2, d26

    vadd.s32 d1, d2, d3
    b intra_pred_plane_coef_v_end

intra_pred_plane_coef_v_loop8:

    ldr r6, =0x0304
    movt r6, #0x0102
    mov r7, #0x08
    add r7, #0x0700
    movt r7, #0x0506
    vmov d28, r7, r6                    // d28[0]: 8, 7, 6, 5, 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // q13: 8, 7, 6, 5, 4, 3, 2, 1(short)
    vmov.i16 q12, #8
    vmov.i32 q8, #0

    sub r11, r0, r10                    // rpSrc = pSrc - iH2
    mov r8, #0
    sub r6, r11, #8
intra_pred_plane_coef_v_loop8_x:

    vld1.8 {q1}, [r11]
    vld1.8 d4, [r6]
    vtbl.8 d2, {q1}, d28

    vsubl.u8 q1, d4, d2                 // y * (rpSrc[-y] - rpSrc[y])
    vmull.s16 q2, d2, d26
    vmull.s16 q3, d3, d27
    vadd.s32 q2, q2, q3
    vadd.s32 q8, q8, q2

    add r8, #8
    vadd.u16 q13, q13, q12
    add r11, #8
    sub r6, #8
    cmp r8, r10
    blt intra_pred_plane_coef_v_loop8_x

    vadd.s32 d1, d16, d17

intra_pred_plane_coef_v_end:
    vpadd.s32 d0, d0, d1                // d0[0]->coef_h and d0[1]->coef_v

    // iA = (pSrc[-1 - (height - 1)] + pSrc[1 + width - 1]) << 4
    sub r6, r0, r4
    ldrb r7, [r6]
    add r6, r0, r3
    ldrb r8, [r6]
    add r6, r7, r8
    lsl r6, r6, #4

    // iB = ((coef_h << 5) * im_h + (1 << (is_h - 1))) >> is_h;
    // iC = ((coef_v << 5) * im_v + (1 << (is_v - 1))) >> is_v;
    vshl.s32 d0, #5
    vmul.s32 d0, d0, d30
    vmov.i32 d2, #1
    vsub.s32 d1, d31, d2
    vshl.s32 d1, d2, d1                 // iB
    vadd.s32 d0, d1
    vneg.s32 d31, d31
    vshl.s32 d0, d31
    vmov r8, r12, d0                    // iB, iC
    vdup.16 q15, r12
    vdup.16 q14, r8

    // iTmp = iA - (iH2 - 1) * iC - (iW2 - 1) * iB + 16
    vmov d1, r9, r10
    vsub.s32 d1, d2
    vmul.s32 d0, d0, d1
    vmov r7, r8, d0
    sub r6, r7
    sub r6, r8
    vdup.16 q13, r6

    mov r6, #0x0100
    movt r6, #0x0302
    mov r7, #0x04
    add r7, #0x0500
    movt r7, #0x0706
    vmov d24, r6, r7
    vmovl.u8 q12, d24                   // q12: 0, 1, 2, 3, 4, 5, 6, 7(short)

    cmp r3, #8
    vmul.s16 q0, q14, q12
    vadd.s16 q0, q0, q13

    beq Plane_w8
    blt Plane_w4

Plane_gt8:
    cmp r3, #16
    beq Plane_w16

    cmp r3, #32
    beq Plane_w32

    mov r5, #0
    sub r2, r3
    vshl.s16 q14, #3
    vmov q3, q0
Plane_gt8_y:
    mov r6, r3
    vmov q0, q3
Plane_gt8_x:

    vqrshrun.s16 d4, q0, #5
    vadd.s16 q0, q14
    vqrshrun.s16 d5, q0, #5
    vadd.s16 q0, q14

    subs r6, #16
    vst1.8 {q2}, [r1]!
    bgt Plane_gt8_x

    subs r4, #1
    vadd.s16 q3, q3, q15
    add r1, r2
    bgt Plane_gt8_y

    b Plane_end

Plane_w32:
    vshl.s16 q14, #3
Plane_w32_y:
    vadd.s16 q3, q0, q14
    vqrshrun.s16 d16, q0, #5
    vadd.s16 q2, q3, q14
    vqrshrun.s16 d17, q3, #5
    vadd.s16 q3, q2, q14
    vqrshrun.s16 d18, q2, #5
    vqrshrun.s16 d19, q3, #5

    vadd.s16 q0, q0, q15

    subs r4, #1
    vst1.8 {q8, q9}, [r1], r2

    bgt Plane_w32_y

    b Plane_end

Plane_w16:
    vshl.s16 q14, #3
Plane_w16_y:

    vadd.s16 q3, q0, q14
    vqrshrun.s16 d4, q0, #5
    vqrshrun.s16 d5, q3, #5
    vadd.s16 q0, q0, q15
    vst1.8 {q2}, [r1], r2

    subs r4, #2
    vadd.s16 q3, q0, q14
    vqrshrun.s16 d4, q0, #5
    vqrshrun.s16 d5, q3, #5
    vadd.s16 q0, q0, q15
    vst1.8 {q2}, [r1], r2

    bgt Plane_w16_y

    b Plane_end

Plane_w8:
    vadd.s16 q2, q0, q15
    vqrshrun.s16 d2, q0, #5
    vadd.s16 q0, q2, q15
    vqrshrun.s16 d3, q2, #5
    subs r4, #2
    vst1.32 {d2}, [r1], r2
    vst1.32 {d3}, [r1], r2
    bgt Plane_w8
    b Plane_end

Plane_w4:
    vadd.s16 d4, d0, d30
    vqrshrun.s16 d2, q0, #5
    vadd.s16 d0, d4, d30
    vst1.32 {d2[0]}, [r1], r2
    vqrshrun.s16 d3, q2, #5
    vadd.s16 d4, d0, d30
    vst1.32 {d3[0]}, [r1], r2
    vqrshrun.s16 d2, q0, #5
    vqrshrun.s16 d3, q2, #5
    subs r4, #4
    vst1.32 {d2[0]}, [r1], r2
    vadd.s16 d0, d4, d30
    vst1.32 {d3[0]}, [r1], r2

    bgt Plane_w4

Plane_end:
    pop {r4-r12, pc}

Plane_ipf_tab_mul_shift:
.byte 13, 17, 5, 11, 23, 7, 10, 11, 15, 19, 0, 0, 0, 0, 0, 0

//void uavs3d_intra_pred_plane_ipf_armv7(pel *src, s16 *dst, int w, int h);
//src->r0, dst->r1, width->r2, height->r3
function uavs3d_intra_pred_plane_ipf_armv7
    push {r4-r12, lr}

    mov r4, r3
    mov r3, r2
    lsl r2, r2, #1

    clz r8, r3
    clz r9, r4
    rsb r8, r8, #29                     // log2[width] - 2
    rsb r9, r9, #29                     // log2[height] - 2

    adr r12, Plane_ipf_tab_mul_shift
    add r10, r8, r12                    // im_h = ib_mult[log2[width] - 2]
    ldrb r6, [r10]

    add r10, #5                         // is_h = ib_shift[log2[width] - 2]
    ldrb r7, [r10]

    add r10, r9, r12                    // im_v = ib_mult[log2[height] - 2]
    ldrb r8, [r10]

    add r10, #5                         // is_v = ib_shift[log2[height] - 2]
    ldrb r9, [r10]

    vmov d30, r6, r8                    // im_h, im_v
    vmov d31, r7, r9                    // is_h, is_v

    lsr r9, r3, #1                      // iW2 = width >> 1;
    lsr r10, r4, #1                     // iH2 = height >> 1;

    add r12, r0, r9                     // rpSrc = pSrc + 1;  rpSrc += (iW2 - 1);
    cmp r9, #4

    beq intra_pred_plane_ipf_coef_h_loop4
    bgt intra_pred_plane_ipf_coef_h_loop8

// intra_pred_plane_coef_h_loop2
    ldrb r6, [r12, #1]
    ldrb r7, [r12, #-1]
    sub r8, r6, r7
    ldrb r6, [r12, #2]
    ldrb r7, [r12, #-2]
    sub r11, r6, r7
    lsl r11, r11, #1
    add r8, r8, r11
    mov r11, #0
    vmov d0, r8, r11

    b  intra_pred_plane_ipf_coef_h_end

intra_pred_plane_ipf_coef_h_loop4:
    ldr r6, =0x0304
    movt r6, #0x0102
    vmov.i32 d28[0], r6                 // d28[0]: 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // d26: 4, 3, 2, 1(short)

    add r6, r0, r9                      // rpSrc = pSrc + iW2
    sub r7, r6, #4

    vld1.8 d0, [r6]
    vld1.8 d1, [r7]

    vtbl.8 d0, {d0}, d28                // lookup

    vsubl.u8 q0, d0, d1                 // x * (rpSrc[x] - rpSrc[-x])
    vmull.s16 q0, d0, d26

    vadd.s32 d0, d0, d1

    b  intra_pred_plane_ipf_coef_h_end

intra_pred_plane_ipf_coef_h_loop8:
    ldr r6, =0x0304
    movt r6, #0x0102
    mov r7, #0x08
    add r7, #0x0700
    movt r7, #0x0506
    vmov d28, r7, r6                    // d28[0]: 8, 7, 6, 5, 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // q13: 8, 7, 6, 5, 4, 3, 2, 1(short)
    vmov.i16 q12, #8
    vmov.i32 q0, #0

    add r11, r0, r9                     // rpSrc = pSrc + iW2
    mov r8, #0
    sub r6, r11, #8
    add r11, #1

intra_pred_plane_ipf_coef_h_loop8_x:

    vld1.8 {d2}, [r11]
    vld1.8 d4, [r6]
    vrev64.8 d2, d2

    vsubl.u8 q1, d2, d4                 // x * (rpSrc[x] - rpSrc[-x])
    vmull.s16 q2, d2, d26
    vmull.s16 q3, d3, d27
    vadd.s32 q2, q2, q3
    vadd.s32 q0, q0, q2

    add r8, #8
    vadd.u16 q13, q13, q12
    add r11, #8
    sub r6, #8
    cmp r8, r9
    blt intra_pred_plane_ipf_coef_h_loop8_x

    vadd.s32 d0, d0, d1

intra_pred_plane_ipf_coef_h_end:

    cmp r10, #4
    beq intra_pred_plane_ipf_coef_v_loop4
    bgt intra_pred_plane_ipf_coef_v_loop8


// intra_pred_plane_ipf_coef_v_loop2
    sub r12, r0, r10                    // rpSrc = pSrc - iH2
    ldrb r6, [r12, #1]
    ldrb r7, [r12, #-1]
    sub r8, r7, r6
    ldrb r6, [r12, #2]
    ldrb r7, [r12, #-2]
    sub r11, r7, r6
    lsl r11, #1
    add r8, r8, r11
    mov r11, #0
    vmov d1, r8, r11

    b intra_pred_plane_ipf_coef_v_end

intra_pred_plane_ipf_coef_v_loop4:

    ldr r6, =0x0304
    movt r6, #0x0102
    vmov.i32 d28[0], r6                 // d28[0]: 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // d26: 4, 3, 2, 1(short)

    sub r12, r0, r10                    // rpSrc = pSrc - iH2
    sub r6, r12, #4

    vld1.8 d2, [r12]
    vld1.8 d3, [r6]

    vtbl.8 d2, {d2}, d28

    vsubl.u8 q1, d3, d2                 // x * (rpSrc[x] - rpSrc[-x])
    vmull.s16 q1, d2, d26

    vadd.s32 d1, d2, d3
    b intra_pred_plane_ipf_coef_v_end

intra_pred_plane_ipf_coef_v_loop8:

    ldr r6, =0x0304
    movt r6, #0x0102
    mov r7, #0x08
    add r7, #0x0700
    movt r7, #0x0506
    vmov d28, r7, r6                    // d28[0]: 8, 7, 6, 5, 4, 3, 2, 1(char)
    vmovl.u8 q13, d28                   // q13: 8, 7, 6, 5, 4, 3, 2, 1(short)
    vmov.i16 q12, #8
    vmov.i32 q8, #0

    sub r11, r0, r10                    // rpSrc = pSrc - iH2
    mov r8, #0
    sub r6, r11, #8
intra_pred_plane_ipf_coef_v_loop8_x:

    vld1.8 {q1}, [r11]
    vld1.8 d4, [r6]
    vtbl.8 d2, {q1}, d28

    vsubl.u8 q1, d4, d2                 // y * (rpSrc[-y] - rpSrc[y])
    vmull.s16 q2, d2, d26
    vmull.s16 q3, d3, d27
    vadd.s32 q2, q2, q3
    vadd.s32 q8, q8, q2

    add r8, #8
    vadd.u16 q13, q13, q12
    add r11, #8
    sub r6, #8
    cmp r8, r10
    blt intra_pred_plane_ipf_coef_v_loop8_x

    vadd.s32 d1, d16, d17

intra_pred_plane_ipf_coef_v_end:
    vpadd.s32 d0, d0, d1                // d0[0]->coef_h and d0[1]->coef_v

    // iA = (pSrc[-1 - (height - 1)] + pSrc[1 + width - 1]) << 4
    sub r6, r0, r4
    ldrb r7, [r6]
    add r6, r0, r3
    ldrb r8, [r6]
    add r6, r7, r8
    lsl r6, r6, #4

    // iB = ((coef_h << 5) * im_h + (1 << (is_h - 1))) >> is_h;
    // iC = ((coef_v << 5) * im_v + (1 << (is_v - 1))) >> is_v;
    vshl.s32 d0, #5
    vmul.s32 d0, d0, d30
    vmov.i32 d2, #1
    vsub.s32 d1, d31, d2
    vshl.s32 d1, d2, d1
    vadd.s32 d0, d1
    vneg.s32 d31, d31
    vshl.s32 d0, d31
    vmov r8, r12, d0                    // iB, iC
    vdup.16 q15, r12
    vdup.16 q14, r8

    // iTmp = iA - (iH2 - 1) * iC - (iW2 - 1) * iB + 16
    vmov d1, r9, r10
    vsub.s32 d1, d2
    vmul.s32 d0, d0, d1
    vmov r7, r8, d0
    sub r6, r7
    sub r6, r8
    vdup.16 q13, r6

    mov r6, #0x0100
    movt r6, #0x0302
    mov r7, #0x04
    add r7, #0x0500
    movt r7, #0x0706
    vmov d24, r6, r7
    vmovl.u8 q12, d24                   // q12: 0, 1, 2, 3, 4, 5, 6, 7(short)

    vmul.s16 q0, q14, q12
    vadd.s16 q0, q0, q13

    cmp r3, #8
    beq Plane_ipf_w8
    blt Plane_ipf_w4

Plane_ipf_gt8:
    cmp r3, #16
    beq Plane_ipf_w16

    cmp r3, #32
    beq Plane_ipf_w32
    bgt Plane_ipf_w64

    sub r2, r3
    vshl.s16 q14, #3
    vmov q3, q0
Plane_ipf_gt8_y:
    mov r6, r3
    vmov q0, q3
Plane_ipf_gt8_x:

    vqrshrun.s16 d4, q0, #5
    vadd.s16 q0, q14
    vqrshrun.s16 d5, q0, #5
    vadd.s16 q0, q14

    subs r6, #16
    vst1.8 {q2}, [r1]!
    bgt Plane_ipf_gt8_x

    subs r4, #1
    vadd.s16 q3, q3, q15
    add r1, r2
    bgt Plane_ipf_gt8_y

    b Plane_ipf_end

Plane_ipf_w64:
    vpush {q4-q7}
    sub r2, r2, #96
    vshl.s16 q14, #3
Plane_ipf_w64_y:
    vadd.s16 q3, q0, q14
    vrshr.s16 q4, q0, #5
    vadd.s16 q2, q3, q14
    vrshr.s16 q5, q3, #5
    vadd.s16 q3, q2, q14
    vrshr.s16 q6, q2, #5
    vadd.s16 q2, q3, q14
    vrshr.s16 q7, q3, #5
    vadd.s16 q3, q2, q14
    vrshr.s16 q8, q2, #5
    vadd.s16 q2, q3, q14
    vrshr.s16 q9, q3, #5
    vadd.s16 q3, q2, q14
    vrshr.s16 q10, q2, #5
    vrshr.s16 q11, q3, #5

    vadd.s16 q0, q0, q15

    subs r4, #1
    vst1.64 {q4, q5}, [r1]!
    vst1.64 {q6, q7}, [r1]!
    vst1.64 {q8, q9}, [r1]!
    vst1.64 {q10, q11}, [r1], r2
    bgt Plane_ipf_w64_y

    vpop {q4-q7}
    b Plane_ipf_end

Plane_ipf_w32:
    sub r2, r2, #32
    vshl.s16 q14, #3
Plane_ipf_w32_y:
    vadd.s16 q3, q0, q14
    vrshr.s16 q8, q0, #5
    vadd.s16 q2, q3, q14
    vrshr.s16 q9, q3, #5
    vadd.s16 q3, q2, q14
    vrshr.s16 q10, q2, #5
    vrshr.s16 q11, q3, #5

    vadd.s16 q0, q0, q15

    subs r4, #1
    vst1.64 {q8, q9}, [r1]!
    vst1.64 {q10, q11}, [r1], r2
    bgt Plane_ipf_w32_y

    b Plane_ipf_end

Plane_ipf_w16:
    vshl.s16 q14, #3
Plane_ipf_w16_y:

    vadd.s16 q3, q0, q14
    vrshr.s16 q4, q0, #5
    vrshr.s16 q5, q3, #5
    vadd.s16 q0, q0, q15
    vst1.8 {q4, q5}, [r1], r2

    subs r4, #2
    vadd.s16 q3, q0, q14
    vrshr.s16 q4, q0, #5
    vrshr.s16 q5, q3, #5
    vadd.s16 q0, q0, q15
    vst1.8 {q4, q5}, [r1], r2
    bgt Plane_ipf_w16_y

    b Plane_ipf_end

Plane_ipf_w8:
    vadd.s16 q2, q0, q15
    vrshr.s16 q3, q0, #5
    vadd.s16 q0, q2, q15
    vrshr.s16 q4, q2, #5
    subs r4, #2
    vst1.64 {q3}, [r1], r2
    vst1.64 {q4}, [r1], r2
    bgt Plane_ipf_w8
    b Plane_ipf_end

Plane_ipf_w4:
    vrshr.s16 q1, q0, #5
    vst1.64 {d2}, [r1], r2
    vadd.s16 q2, q0, q15
    vrshr.s16 q3, q2, #5
    vst1.32 {d6}, [r1], r2
    vadd.s16 q0, q2, q15
    vrshr.s16 q1, q0, #5
    vst1.64 {d2}, [r1], r2

    subs r4, #4
    vadd.s16 q1, q0, q15
    vrshr.s16 q3, q1, #5
    vst1.32 {d6}, [r1], r2
    vadd.s16 q0, q1, q15

    bgt Plane_ipf_w4

Plane_ipf_end:
    pop {r4-r12, pc}

function uavs3d_intra_pred_bi_armv7
//pSrc->r0, dst->r1, i_dst->r2, width->r3, height->r4, sample_bit_depth->r5
    push {r4-r12, lr}
    ldr r4, [sp, #40]
    vpush {q4-q7}

    mov r6, #-1
    mov r7, #21
    mov r8, #13
    mov r9, #7
    mov r10, #4
    mov r11, #2
    vmov.s32 d0[0], r6
    vmov.s32 d0[1], r7
    vmov.s32 d1[0], r8
    vmov.s32 d1[1], r9
    vmov.s32 d2[0], r10
    vmov.s32 d2[1], r11
    vpush {q0, q1}

    clz r5, r3
    clz r6, r4
    rsb r5, r5, #31                     // log2[width]
    rsb r6, r6, #31                     // log2[height]

    vdup.16 q13, r5                     // ishift = min(ishift_x, ishift_y);
    vdup.16 q14, r6
    vmin.u16 q15, q13, q14

    add r12, r0, r3                     // a = pTop[width - 1] = pSrc[width]
    ldrb r5, [r12]
    sub r12, r0, r4                     // b = pLeft[height - 1] = pSrc[-height]
    ldrb r6, [r12]

    vdup.16 q0, r5
    vdup.16 q1, r6

    cmp r3, r4
    bne intra_pred_bi_width_ne_height

//intra_pred_bi_width_eq_height:
    vadd.u16 q3, q0, q1                 // c = (a + b + 1) >> 1
    vrshr.u16 q2, q3, #1
    vshl.u16 q2, q2, #1
    vsub.u16 q2, q2, q3                 // w = (c << 1) - a - b

    add sp, sp, #32
    b intra_pred_bi_pT_pTop_pLeft_pL

intra_pred_bi_width_ne_height:

    // c = (((a << ishift_x) + (b << ishift_y)) * wc + (1 << (ishift + 5))) >> (ishift + 6)
    vshl.u16 q2, q0, q13
    vshl.u16 q3, q1, q14
    vadd.u16 q2, q2, q3

    vsub.s16 q12, q13, q14
    vabs.s16 q12, q12
    vmov.u16 r7, d24[0]
    lsl r7, r7, #2
    add sp, sp, r7
    vldmia sp, {d24}
    sub sp, sp, r7
    vmov.s32 r7, d24[0]
    vdup.16 d16, r7
    vmull.u16 q2, d4, d16
    vmov.u16 d16, #6
    vaddl.u16 q8, d16, d30
    vneg.s32 q8, q8
    vrshl.s32 q2, q2, q8
    vmovn.s32 d4, q2
    vmov d5, d4

    add sp, sp, #32
    //w = (c << 1) - a - b
    vshl.u16 q2, q2, #1
    vsub.u16 q2, q2, q0
    vsub.u16 q2, q2, q1

intra_pred_bi_pT_pTop_pLeft_pL:
    mov r12, sp
    sub sp, sp, #3072

    sub r11, r12, #1024             // pTop
    sub r10, r12, #1536             // pT
    sub r9, r12, #2048              // pLeft
    sub r8, r12, #2560              // pL
    sub r7, r12, #3072              // wy

    add r5, r0, #1

    cmp r3, #8
    blt intra_pred_bi_pT_pTop_loop4
    bgt intra_pred_bi_pT_pTop_loop16x

//intra_pred_bi_pT_pTop_loop8:
    vld1.8 {d16}, [r5]
    vsubw.u8 q9, q1, d16            // pT[x] = b - pTop[x];
    vst1.8 {q9}, [r10]
    vmovl.u8 q8, d16
    vshl.u16 q8, q8, q14            // pTop[x] <<= ishift_y;
    vst1.8 {q8}, [r11]

    b intra_pred_bi_pT_pTop_end

intra_pred_bi_pT_pTop_loop4:
    vld1.32 d16[0], [r5]
    vsubw.u8 q9, q1, d16            // pT[x] = b - pTop[x];
    vst1.8 {d18}, [r10]
    vmovl.u8 q8, d16
    vshl.u16 q8, q8, q14            // pTop[x] <<= ishift_y;
    vst1.8 {d16}, [r11]

    b intra_pred_bi_pT_pTop_end

intra_pred_bi_pT_pTop_loop16x:

    cmp r3, #32
    blt intra_pred_bi_pT_pTop_loop16
    bgt intra_pred_bi_pT_pTop_loop64

//intra_pred_bi_pT_pTop_loop32:
    vld1.8 {q8, q9}, [r5]
    vsubw.u8 q4, q1, d16            // pT[x] = b - pTop[x];
    vsubw.u8 q5, q1, d17
    vsubw.u8 q6, q1, d18
    vsubw.u8 q7, q1, d19
    vst1.8 {q4, q5}, [r10]!
    vst1.8 {q6, q7}, [r10]
    vmovl.u8 q4, d16
    vmovl.u8 q5, d17
    vmovl.u8 q6, d18
    vmovl.u8 q7, d19
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vshl.u16 q6, q6, q14
    vshl.u16 q7, q7, q14
    vst1.8 {q4, q5}, [r11]!
    vst1.8 {q6, q7}, [r11]
    sub r10, #32
    sub r11, #32

    b intra_pred_bi_pT_pTop_end

intra_pred_bi_pT_pTop_loop16:
    vld1.8 {q8}, [r5]
    vsubw.u8 q4, q1, d16            // pT[x] = b - pTop[x];
    vsubw.u8 q5, q1, d17
    vst1.8 {q4, q5}, [r10]
    vmovl.u8 q4, d16
    vmovl.u8 q5, d17
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vst1.8 {q4, q5}, [r11]

    b intra_pred_bi_pT_pTop_end

intra_pred_bi_pT_pTop_loop64:
    vld1.8 {q8, q9}, [r5]!
    vld1.8 {q10, q11}, [r5]
    vsubw.u8 q4, q1, d16            // pT[x] = b - pTop[x];
    vsubw.u8 q5, q1, d17
    vsubw.u8 q6, q1, d18
    vsubw.u8 q7, q1, d19
    vst1.8 {q4, q5}, [r10]!
    vst1.8 {q6, q7}, [r10]!
    vsubw.u8 q4, q1, d20
    vsubw.u8 q5, q1, d21
    vsubw.u8 q6, q1, d22
    vsubw.u8 q7, q1, d23
    vst1.8 {q4, q5}, [r10]!
    vst1.8 {q6, q7}, [r10]

    vmovl.u8 q4, d16
    vmovl.u8 q5, d17
    vmovl.u8 q6, d18
    vmovl.u8 q7, d19
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vshl.u16 q6, q6, q14
    vshl.u16 q7, q7, q14
    vst1.8 {q4, q5}, [r11]!
    vst1.8 {q6, q7}, [r11]!
    vmovl.u8 q4, d20
    vmovl.u8 q5, d21
    vmovl.u8 q6, d22
    vmovl.u8 q7, d23
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vshl.u16 q6, q6, q14
    vshl.u16 q7, q7, q14
    vst1.8 {q4, q5}, [r11]!
    vst1.8 {q6, q7}, [r11]

    sub r10, r10, #96
    sub r11, r11, #96

intra_pred_bi_pT_pTop_end:

// pLeft and pL and wy

    cmp r4, #8
    blt intra_pred_bi_pL_pLeft_wy_loop4
    bgt intra_pred_bi_pL_pLeft_wy_loop16x

// intra_pred_bi_pL_pLeft_wy_loop8:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d24, r6, r5                // d24: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vtbl.8 d22, {d24}, d24          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #8
    vld1.8 d16, [r5]
    vtbl.8 d16, {d16}, d24
    vsubw.u8 q4, q0, d16            // pL[y] = a - pLeft[y]
    vst1.8 {q4}, [r8]
    vmovl.u8 q8, d16
    vshl.u16 q4, q8, q13            // pLeft[y] <<= ishift_x
    vst1.8 {q4}, [r9]
    vmul.u16 q4, q3, q2             // wy[y] = tmp
    vst1.8 {q4}, [r7]

    b intra_pred_bi_pL_pLeft_wy_end

intra_pred_bi_pL_pLeft_wy_loop4:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    vmov d24, r5, r5                // d24: 3, 2, 1, 0, 3, 2, 1, 0(char)
    vtbl.8 d22, {d24}, d24          // d22: 0, 1, 2, 3, 0, 1, 2, 3(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 0, 1, 2, 3(short)

    sub r5, r0, #4
    vld1.8 d16, [r5]
    vtbl.8 d16, {d16}, d24
    vsubw.u8 q4, q0, d16            // pL[y] = a - pLeft[y]
    vst1.8 {d8}, [r8]
    vmovl.u8 q8, d16
    vshl.u16 d8, d16, d26           // pLeft[y] <<= ishift_x
    vst1.8 {d8}, [r9]
    vmul.u16 d8, d6, d4             // wy[y] = tmp
    vst1.8 {d8}, [r7]

    b intra_pred_bi_pL_pLeft_wy_end

intra_pred_bi_pL_pLeft_wy_loop16x:

    cmp r4, #32
    blt intra_pred_bi_pL_pLeft_wy_loop16
    bgt intra_pred_bi_pL_pLeft_wy_loop64

//intra_pred_bi_pL_pLeft_wy_loop32:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d25, r6, r5                // d25: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vmov.u8 d24, #8
    vadd.u8 d24, d25, d24           // d24: 15, 14, 13, 12, 11, 10, 9, 8(char)
    vtbl.8 d22, {d25}, d25          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #32
    vld1.8 {q8, q9}, [r5]
    vrev64.8 q8, q8
    vrev64.8 q9, q9
    vsubw.u8 q4, q0, d19            // pL[y] = a - pLeft[y]
    vsubw.u8 q5, q0, d18
    vsubw.u8 q6, q0, d17
    vsubw.u8 q7, q0, d16
    vst1.8 {q4, q5}, [r8]!
    vst1.8 {q6, q7}, [r8]
    vmovl.u8 q4, d19
    vmovl.u8 q5, d18
    vmovl.u8 q6, d17
    vmovl.u8 q7, d16
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vshl.u16 q6, q6, q13
    vshl.u16 q7, q7, q13
    vst1.8 {q4, q5}, [r9]!
    vst1.8 {q6, q7}, [r9]
    vmov.u16 q7, #8
    vmul.u16 q7, q7, q2             // 8 * w
    vmul.u16 q4, q2, q3             // wy[y] = tmp
    vadd.u16 q5, q4, q7
    vadd.u16 q6, q5, q7
    vadd.u16 q7, q6, q7
    vst1.8 {q4, q5}, [r7]!
    vst1.8 {q6, q7}, [r7]
    sub r8, #32
    sub r9, #32
    sub r7, #32

    b intra_pred_bi_pL_pLeft_wy_end

intra_pred_bi_pL_pLeft_wy_loop16:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d25, r6, r5                // d25: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vmov.u8 d24, #8
    vadd.u8 d24, d25, d24           // d24: 15, 14, 13, 12, 11, 10, 9, 8(char)
    vtbl.8 d22, {d25}, d25          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #16
    vld1.8 {q8}, [r5]
    vrev64.8 q8, q8
    vsubw.u8 q4, q0, d17            // pL[y] = a - pLeft[y]
    vsubw.u8 q5, q0, d16
    vst1.8 {q4, q5}, [r8]
    vmovl.u8 q4, d17
    vmovl.u8 q5, d16
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vst1.8 {q4, q5}, [r9]
    vmov.u16 q7, #8
    vmul.u16 q7, q7, q2             // 8 * w
    vmul.u16 q4, q2, q3             // wy[y] = tmp
    vadd.u16 q5, q4, q7
    vst1.8 {q4, q5}, [r7]

    b intra_pred_bi_pL_pLeft_wy_end

intra_pred_bi_pL_pLeft_wy_loop64:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d25, r6, r5                // d25: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vmov.u8 d24, #8
    vadd.u8 d24, d25, d24           // d24: 15, 14, 13, 12, 11, 10, 9, 8(char)
    vtbl.8 d22, {d25}, d25          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #64
    vld1.8 {q8, q9}, [r5]!
    vld1.8 {q10, q11}, [r5]
    vrev64.8 q8, q8
    vrev64.8 q9, q9
    vrev64.8 q10, q10
    vrev64.8 q11, q11
    vsubw.u8 q4, q0, d23            // pL[y] = a - pLeft[y]
    vsubw.u8 q5, q0, d22
    vsubw.u8 q6, q0, d21
    vsubw.u8 q7, q0, d20
    vst1.8 {q4, q5}, [r8]!
    vst1.8 {q6, q7}, [r8]!
    vsubw.u8 q4, q0, d19
    vsubw.u8 q5, q0, d18
    vsubw.u8 q6, q0, d17
    vsubw.u8 q7, q0, d16
    vst1.8 {q4, q5}, [r8]!
    vst1.8 {q6, q7}, [r8]
    vmovl.u8 q4, d23
    vmovl.u8 q5, d22
    vmovl.u8 q6, d21
    vmovl.u8 q7, d20
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vshl.u16 q6, q6, q13
    vshl.u16 q7, q7, q13
    vst1.8 {q4, q5}, [r9]!
    vst1.8 {q6, q7}, [r9]!
    vmovl.u8 q4, d19
    vmovl.u8 q5, d18
    vmovl.u8 q6, d17
    vmovl.u8 q7, d16
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vshl.u16 q6, q6, q13
    vshl.u16 q7, q7, q13
    vst1.8 {q4, q5}, [r9]!
    vst1.8 {q6, q7}, [r9]
    vmov.u16 q7, #8
    vmul.u16 q12, q7, q2            // 8 * w
    vmul.u16 q4, q2, q3             // wy[y] = tmp
    vadd.u16 q5, q4, q12
    vadd.u16 q6, q5, q12
    vadd.u16 q7, q6, q12
    vst1.8 {q4, q5}, [r7]!
    vst1.8 {q6, q7}, [r7]!
    vadd.u16 q4, q7, q12
    vadd.u16 q5, q4, q12
    vadd.u16 q6, q5, q12
    vadd.u16 q7, q6, q12
    vst1.8 {q4, q5}, [r7]!
    vst1.8 {q6, q7}, [r7]

    sub r7, r7, #96
    sub r9, r9, #96
    sub r8, r8, #96

intra_pred_bi_pL_pLeft_wy_end:

    cmp r3, #8
    blt intra_pred_bi_fill_block_loop4
    bgt intra_pred_bi_fill_block_loop16x

//intra_pred_bi_fill_block_loop8:

    vld1.8 {q4}, [r11]              // pTop
    vld1.8 {q5}, [r10]              // pT

    vmovl.u16 q3, d6                // [0, 1, 2, 3]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q12, q12

intra_pred_bi_fill_block_loop8_y:

    vadd.u16 q4, q4, q5             // pTop[x] += pT[x];
    vshll.u16 q6, d8, #3            // pTop[x] << ishift_x (ishift_x = 3)
    vshll.u16 q7, d9, #3

    ldrsh r5, [r9], #2              // pLeft[y];
    ldrsh r6, [r8], #2              // pL[y];

    vmov.u16 r12, d28[0]            // (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vmul.u32 q10, q9, q3            // [0, 1, 2 ..., 7] * add
    vshl.u32 q11, q9, #2
    vadd.u32 q11, q11, q10

    vadd.u32 q10, q10, q8           // (predx << ishift_y) + (pTop[x] << ishift_x) + wxy
    vadd.u32 q11, q11, q8

    vadd.u32 q10, q10, q6
    vadd.u32 q11, q11, q7

    vshl.s32 q10, q10, q12         // right shift ishift_x + ishift_y
    vshl.s32 q11, q11, q12

    vrshrn.u32 d20, q10, #1        // right shift 1
    vrshrn.u32 d21, q11, #1

    subs r4, r4, #1
    vqmovn.u16 d20, q10

    vst1.32 {d20}, [r1], r2
    bgt intra_pred_bi_fill_block_loop8_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_loop4:

    vld1.8 {d8}, [r11]              // pTop
    vld1.8 {d10}, [r10]             // pT
    vmovl.u16 q3, d6                // [0, 1, 2, 3]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q12, q12

intra_pred_bi_fill_block_loop4_y:

    vadd.u16 d8, d8, d10            // pTop[x] += pT[x];
    vshll.u16 q6, d8, #2            // pTop[x] << ishift_x (ishift_x = 2)

    ldrsh r5, [r9], #2              // pLeft[y];
    ldrsh r6, [r8], #2              // pL[y];

    vmov.u16 r12, d28[0]            // (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vmul.u32 q10, q9, q3            // [0, 1, 2, 3] * add

    vadd.u32 q10, q10, q8           // (predx << ishift_y) + (pTop[x] << ishift_x) + wxy

    vadd.u32 q10, q10, q6

    vshl.s32 q10, q10, q12          // right shift ishift_x + ishift_y

    vrshrn.u32 d20, q10, #1         // right shift 1

    subs r4, r4, #1
    vqmovn.u16 d20, q10

    vst1.32 d20[0], [r1], r2

    bgt intra_pred_bi_fill_block_loop4_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_loop16x:

    cmp r3, #32
    blt intra_pred_bi_fill_block_loop16
    bgt intra_pred_bi_fill_block_loop64

// intra_pred_bi_fill_block_loop32:

    vmovl.u16 q15, d6               // [0, 1, 2, 3]

    vld1.8 {q0, q1}, [r11]!         // pTop
    vld1.8 {q2, q3}, [r11]
    vld1.8 {q4, q5}, [r10]!         // pT
    vld1.8 {q6, q7}, [r10]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q13, q12

    sub r2, r2, #32                 // i_dst - width

intra_pred_bi_fill_block_loop32_y:

    vmov.u16 r12, d28[0]            // val = (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    ldrsh r5, [r9], #2
    ldrsh r6, [r8], #2
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vadd.u16 q0, q0, q4             // pTop[x] += pT[x];
    vadd.u16 q1, q1, q5
    vadd.u16 q2, q2, q6
    vadd.u16 q3, q3, q7

    vmul.u32 q10, q9, q15           // [0, 1, 2, 3] * add
    vshl.u32 q9, q9, #2

    vshll.u16 q11, d0, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d1, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d2, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d3, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d4, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d5, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d6, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d7, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    subs r4, r4, #1
    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    add r1, r1, r2
    bgt intra_pred_bi_fill_block_loop32_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_loop16:

    vmovl.u16 q15, d6               // [0, 1, 2, 3]

    vld1.8 {q0, q1}, [r11]          // pTop
    vld1.8 {q4, q5}, [r10]          // pT

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q13, q12

intra_pred_bi_fill_block_loop16_y:

    vmov.u16 r12, d28[0]            // val = (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    ldrsh r5, [r9], #2
    ldrsh r6, [r8], #2
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vadd.u16 q0, q0, q4             // pTop[x] += pT[x];
    vadd.u16 q1, q1, q5

    vmul.u32 q10, q9, q15           // [0, 1, 2, 3] * add
    vshl.u32 q9, q9, #2

    vshll.u16 q11, d0, #4           // pTop[x] << ishift_x (ishift_x = 4)
    vshll.u16 q12, d1, #4

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d4, q11

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d2, #4           // pTop[x] << ishift_x (ishift_x = 4)
    vshll.u16 q12, d3, #4

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    subs r4, r4, #1
    vqmovn.u16 d5, q11
    vst1.32 {q2}, [r1], r2

    bgt intra_pred_bi_fill_block_loop16_y

    b intra_pred_bi_end

intra_pred_bi_fill_block_loop64:

    vmovl.u16 q15, d6               // [0, 1, 2, 3]

    vld1.8 {q0, q1}, [r11]!         // pTop
    vld1.8 {q2, q3}, [r11]!
    vld1.8 {q4, q5}, [r11]!
    vld1.8 {q6, q7}, [r11]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q13, q12

    sub r2, r2, #64                 // i_dst - width

intra_pred_bi_fill_block_loop64_y:

    vld1.8 {q8, q9}, [r10]!
    vld1.8 {q10, q11}, [r10]!
    vadd.u16 q0, q0, q8             // pTop[x] += pT[x];
    vadd.u16 q1, q1, q9
    vadd.u16 q2, q2, q10
    vadd.u16 q3, q3, q11
    vld1.8 {q8, q9}, [r10]!
    vld1.8 {q10, q11}, [r10]
    vadd.u16 q4, q4, q8
    vadd.u16 q5, q5, q9
    vadd.u16 q6, q6, q10
    vadd.u16 q7, q7, q11

    sub r10, r10, #96

    vmov.u16 r12, d28[0]            // val = (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    ldrsh r5, [r9], #2
    ldrsh r6, [r8], #2
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vmul.u32 q10, q9, q15           // [0, 1, 2, 3] * add
    vshl.u32 q9, q9, #2

    vshll.u16 q11, d0, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d1, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d2, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d3, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d4, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d5, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d6, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d7, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d8, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d9, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d10, #6          // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d11, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d12, #6          // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d13, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d14, #6          // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d15, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    subs r4, r4, #1
    vqmovn.u16 d22, q11
    vst1.32 {d22}, [r1]!

    add r1, r1, r2
    bne intra_pred_bi_fill_block_loop64_y

intra_pred_bi_end:

    add sp, sp, #3072

    vpop {q4-q7}
    pop {r4-r12, pc}


function uavs3d_intra_pred_bi_ipf_armv7
//pSrc->r0, dst->r1, width->r2, height->r3
    push {r4-r12, lr}
    vpush {q4-q7}

    mov r4, r3
    mov r3, r2
    lsl r2, r2, #1

    mov r6, #-1
    vmov.s32 d0[0], r6
    mov r7, #21
    vmov.s32 d0[1], r7
    mov r8, #13
    vmov.s32 d1[0], r8
    mov r9, #7
    vmov.s32 d1[1], r9
    mov r10, #4
    vmov.s32 d2[0], r10
    mov r11, #2
    vmov.s32 d2[1], r11
    vpush {q0, q1}

    clz r5, r3
    clz r6, r4
    rsb r5, r5, #31                     // log2[width]
    rsb r6, r6, #31                     // log2[height]

    vdup.16 q13, r5                     // ishift = min(ishift_x, ishift_y);
    vdup.16 q14, r6
    vmin.u16 q15, q13, q14

    add r12, r0, r3                     // a = pTop[width - 1] = pSrc[width]
    ldrb r5, [r12]
    sub r12, r0, r4                     // b = pLeft[height - 1] = pSrc[-height]
    ldrb r6, [r12]

    vdup.16 q0, r5
    vdup.16 q1, r6

    cmp r3, r4
    bne intra_pred_bi_ipf_width_ne_height

//intra_pred_bi_ipf_width_eq_height:
    vadd.u16 q3, q0, q1                 // c = (a + b + 1) >> 1
    vrshr.u16 q2, q3, #1
    vshl.u16 q2, q2, #1
    vsub.u16 q2, q2, q3                 // w = (c << 1) - a - b

    add sp, sp, #32
    b intra_pred_bi_ipf_pT_pTop_pLeft_pL

intra_pred_bi_ipf_width_ne_height:

    // c = (((a << ishift_x) + (b << ishift_y)) * wc + (1 << (ishift + 5))) >> (ishift + 6)
    vshl.u16 q2, q0, q13
    vshl.u16 q3, q1, q14
    vadd.u16 q2, q2, q3

    vsub.s16 q12, q13, q14
    vabs.s16 q12, q12
    vmov.u16 r7, d24[0]
    lsl r7, r7, #2
    add sp, sp, r7
    vldmia sp, {d24}
    sub sp, sp, r7
    vmov.s32 r7, d24[0]
    vdup.16 d16, r7
    vmull.u16 q2, d4, d16
    vmov.u16 d16, #6
    vaddl.u16 q8, d16, d30
    vneg.s32 q8, q8
    vrshl.s32 q2, q2, q8
    vmovn.s32 d4, q2
    vmov d5, d4

    add sp, sp, #32
    //w = (c << 1) - a - b
    vshl.u16 q2, q2, #1
    vsub.u16 q2, q2, q0
    vsub.u16 q2, q2, q1

intra_pred_bi_ipf_pT_pTop_pLeft_pL:
    mov r12, sp
    sub sp, sp, #3072

    sub r11, r12, #1024             // pTop
    sub r10, r12, #1536             // pT
    sub r9, r12, #2048              // pLeft
    sub r8, r12, #2560              // pL
    sub r7, r12, #3072              // wy

// pT and pTop
    add r5, r0, #1

//branch
    cmp r3, #8
    blt intra_pred_bi_ipf_pT_pTop_loop4
    bgt intra_pred_bi_ipf_pT_pTop_loop16x

//intra_pred_bi_ipf_pT_pTop_loop8:
    vld1.8 {d16}, [r5]
    vsubw.u8 q9, q1, d16            // pT[x] = b - pTop[x];
    vst1.8 {q9}, [r10]
    vmovl.u8 q8, d16
    vshl.u16 q8, q8, q14            // pTop[x] <<= ishift_y;
    vst1.8 {q8}, [r11]

    b intra_pred_bi_ipf_pT_pTop_end

intra_pred_bi_ipf_pT_pTop_loop4:
    vld1.32 d16[0], [r5]
    vsubw.u8 q9, q1, d16            // pT[x] = b - pTop[x];
    vst1.8 {d18}, [r10]
    vmovl.u8 q8, d16
    vshl.u16 q8, q8, q14            // pTop[x] <<= ishift_y;
    vst1.8 {d16}, [r11]

    b intra_pred_bi_ipf_pT_pTop_end

intra_pred_bi_ipf_pT_pTop_loop16x:

    cmp r3, #32
    blt intra_pred_bi_ipf_pT_pTop_loop16
    bgt intra_pred_bi_ipf_pT_pTop_loop64

//intra_pred_bi_ipf_pT_pTop_loop32:
    vld1.8 {q8, q9}, [r5]
    vsubw.u8 q4, q1, d16            // pT[x] = b - pTop[x];
    vsubw.u8 q5, q1, d17
    vsubw.u8 q6, q1, d18
    vsubw.u8 q7, q1, d19
    vst1.8 {q4, q5}, [r10]!
    vst1.8 {q6, q7}, [r10]
    vmovl.u8 q4, d16
    vmovl.u8 q5, d17
    vmovl.u8 q6, d18
    vmovl.u8 q7, d19
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vshl.u16 q6, q6, q14
    vshl.u16 q7, q7, q14
    vst1.8 {q4, q5}, [r11]!
    vst1.8 {q6, q7}, [r11]
    sub r10, #32
    sub r11, #32

    b intra_pred_bi_ipf_pT_pTop_end

intra_pred_bi_ipf_pT_pTop_loop16:
    vld1.8 {q8}, [r5]
    vsubw.u8 q4, q1, d16            // pT[x] = b - pTop[x];
    vsubw.u8 q5, q1, d17
    vst1.8 {q4, q5}, [r10]
    vmovl.u8 q4, d16
    vmovl.u8 q5, d17
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vst1.8 {q4, q5}, [r11]

    b intra_pred_bi_ipf_pT_pTop_end

intra_pred_bi_ipf_pT_pTop_loop64:
    vld1.8 {q8, q9}, [r5]!
    vld1.8 {q10, q11}, [r5]
    vsubw.u8 q4, q1, d16            // pT[x] = b - pTop[x];
    vsubw.u8 q5, q1, d17
    vsubw.u8 q6, q1, d18
    vsubw.u8 q7, q1, d19
    vst1.8 {q4, q5}, [r10]!
    vst1.8 {q6, q7}, [r10]!
    vsubw.u8 q4, q1, d20
    vsubw.u8 q5, q1, d21
    vsubw.u8 q6, q1, d22
    vsubw.u8 q7, q1, d23
    vst1.8 {q4, q5}, [r10]!
    vst1.8 {q6, q7}, [r10]

    vmovl.u8 q4, d16
    vmovl.u8 q5, d17
    vmovl.u8 q6, d18
    vmovl.u8 q7, d19
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vshl.u16 q6, q6, q14
    vshl.u16 q7, q7, q14
    vst1.8 {q4, q5}, [r11]!
    vst1.8 {q6, q7}, [r11]!
    vmovl.u8 q4, d20
    vmovl.u8 q5, d21
    vmovl.u8 q6, d22
    vmovl.u8 q7, d23
    vshl.u16 q4, q4, q14            // pTop[x] <<= ishift_y;
    vshl.u16 q5, q5, q14
    vshl.u16 q6, q6, q14
    vshl.u16 q7, q7, q14
    vst1.8 {q4, q5}, [r11]!
    vst1.8 {q6, q7}, [r11]

    sub r10, r10, #96
    sub r11, r11, #96

intra_pred_bi_ipf_pT_pTop_end:

// pLeft and pL and wy

    cmp r4, #8
    blt intra_pred_bi_ipf_pL_pLeft_wy_loop4
    bgt intra_pred_bi_ipf_pL_pLeft_wy_loop16x

// intra_pred_bi_ipf_pL_pLeft_wy_loop8:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d24, r6, r5                // d24: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vtbl.8 d22, {d24}, d24          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #8
    vld1.8 d16, [r5]
    vtbl.8 d16, {d16}, d24
    vsubw.u8 q4, q0, d16            // pL[y] = a - pLeft[y]
    vst1.8 {q4}, [r8]
    vmovl.u8 q8, d16
    vshl.u16 q4, q8, q13            // pLeft[y] <<= ishift_x
    vst1.8 {q4}, [r9]
    vmul.u16 q4, q3, q2             // wy[y] = tmp
    vst1.8 {q4}, [r7]

    b intra_pred_bi_ipf_pL_pLeft_wy_end

intra_pred_bi_ipf_pL_pLeft_wy_loop4:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    vmov d24, r5, r5                // d24: 3, 2, 1, 0, 3, 2, 1, 0(char)
    vtbl.8 d22, {d24}, d24          // d22: 0, 1, 2, 3, 0, 1, 2, 3(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 0, 1, 2, 3(short)

    sub r5, r0, #4
    vld1.8 d16, [r5]
    vtbl.8 d16, {d16}, d24
    vsubw.u8 q4, q0, d16            // pL[y] = a - pLeft[y]
    vst1.8 {d8}, [r8]
    vmovl.u8 q8, d16
    vshl.u16 d8, d16, d26           // pLeft[y] <<= ishift_x
    vst1.8 {d8}, [r9]
    vmul.u16 d8, d6, d4             // wy[y] = tmp
    vst1.8 {d8}, [r7]


    b intra_pred_bi_ipf_pL_pLeft_wy_end

intra_pred_bi_ipf_pL_pLeft_wy_loop16x:

    cmp r4, #32
    blt intra_pred_bi_ipf_pL_pLeft_wy_loop16
    bgt intra_pred_bi_ipf_pL_pLeft_wy_loop64

//intra_pred_bi_ipf_pL_pLeft_wy_loop32:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d25, r6, r5                // d25: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vmov.u8 d24, #8
    vadd.u8 d24, d25, d24           // d24: 15, 14, 13, 12, 11, 10, 9, 8(char)
    vtbl.8 d22, {d25}, d25          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #32
    vld1.8 {q8, q9}, [r5]
    vrev64.8 q8, q8
    vrev64.8 q9, q9
    vsubw.u8 q4, q0, d19            // pL[y] = a - pLeft[y]
    vsubw.u8 q5, q0, d18
    vsubw.u8 q6, q0, d17
    vsubw.u8 q7, q0, d16
    vst1.8 {q4, q5}, [r8]!
    vst1.8 {q6, q7}, [r8]
    vmovl.u8 q4, d19
    vmovl.u8 q5, d18
    vmovl.u8 q6, d17
    vmovl.u8 q7, d16
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vshl.u16 q6, q6, q13
    vshl.u16 q7, q7, q13
    vst1.8 {q4, q5}, [r9]!
    vst1.8 {q6, q7}, [r9]
    vmov.u16 q7, #8
    vmul.u16 q7, q7, q2             // 8 * w
    vmul.u16 q4, q2, q3             // wy[y] = tmp
    vadd.u16 q5, q4, q7
    vadd.u16 q6, q5, q7
    vadd.u16 q7, q6, q7
    vst1.8 {q4, q5}, [r7]!
    vst1.8 {q6, q7}, [r7]
    sub r8, #32
    sub r9, #32
    sub r7, #32

    b intra_pred_bi_ipf_pL_pLeft_wy_end

intra_pred_bi_ipf_pL_pLeft_wy_loop16:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d25, r6, r5                // d25: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vmov.u8 d24, #8
    vadd.u8 d24, d25, d24           // d24: 15, 14, 13, 12, 11, 10, 9, 8(char)
    vtbl.8 d22, {d25}, d25          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #16
    vld1.8 {q8}, [r5]
    vrev64.8 q8, q8
    vsubw.u8 q4, q0, d17            // pL[y] = a - pLeft[y]
    vsubw.u8 q5, q0, d16
    vst1.8 {q4, q5}, [r8]
    vmovl.u8 q4, d17
    vmovl.u8 q5, d16
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vst1.8 {q4, q5}, [r9]
    vmov.u16 q7, #8
    vmul.u16 q7, q7, q2             // 8 * w
    vmul.u16 q4, q2, q3             // wy[y] = tmp
    vadd.u16 q5, q4, q7
    vst1.8 {q4, q5}, [r7]

    b intra_pred_bi_ipf_pL_pLeft_wy_end

intra_pred_bi_ipf_pL_pLeft_wy_loop64:

    mov r5, #0x0003
    add r5, #0x0200
    movt r5, #0x0001
    mov r6, #0x0007
    add r6, #0x0600
    movt r6, #0x0405
    vmov d25, r6, r5                // d25: 7, 6, 5, 4, 3, 2, 1, 0(char)
    vmov.u8 d24, #8
    vadd.u8 d24, d25, d24           // d24: 15, 14, 13, 12, 11, 10, 9, 8(char)
    vtbl.8 d22, {d25}, d25          // d22: 0, 1, 2, 3, 4, 5, 6, 7(char)
    vmovl.u8 q3, d22                // q3: 0, 1, 2, 3, 4, 5, 6, 7(short)

    sub r5, r0, #64
    vld1.8 {q8, q9}, [r5]!
    vld1.8 {q10, q11}, [r5]
    vrev64.8 q8, q8
    vrev64.8 q9, q9
    vrev64.8 q10, q10
    vrev64.8 q11, q11
    vsubw.u8 q4, q0, d23            // pL[y] = a - pLeft[y]
    vsubw.u8 q5, q0, d22
    vsubw.u8 q6, q0, d21
    vsubw.u8 q7, q0, d20
    vst1.8 {q4, q5}, [r8]!
    vst1.8 {q6, q7}, [r8]!
    vsubw.u8 q4, q0, d19
    vsubw.u8 q5, q0, d18
    vsubw.u8 q6, q0, d17
    vsubw.u8 q7, q0, d16
    vst1.8 {q4, q5}, [r8]!
    vst1.8 {q6, q7}, [r8]
    vmovl.u8 q4, d23
    vmovl.u8 q5, d22
    vmovl.u8 q6, d21
    vmovl.u8 q7, d20
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vshl.u16 q6, q6, q13
    vshl.u16 q7, q7, q13
    vst1.8 {q4, q5}, [r9]!
    vst1.8 {q6, q7}, [r9]!
    vmovl.u8 q4, d19
    vmovl.u8 q5, d18
    vmovl.u8 q6, d17
    vmovl.u8 q7, d16
    vshl.u16 q4, q4, q13            // pLeft[y] <<= ishift_x
    vshl.u16 q5, q5, q13
    vshl.u16 q6, q6, q13
    vshl.u16 q7, q7, q13
    vst1.8 {q4, q5}, [r9]!
    vst1.8 {q6, q7}, [r9]
    vmov.u16 q7, #8
    vmul.u16 q12, q7, q2            // 8 * w
    vmul.u16 q4, q2, q3             // wy[y] = tmp
    vadd.u16 q5, q4, q12
    vadd.u16 q6, q5, q12
    vadd.u16 q7, q6, q12
    vst1.8 {q4, q5}, [r7]!
    vst1.8 {q6, q7}, [r7]!
    vadd.u16 q4, q7, q12
    vadd.u16 q5, q4, q12
    vadd.u16 q6, q5, q12
    vadd.u16 q7, q6, q12
    vst1.8 {q4, q5}, [r7]!
    vst1.8 {q6, q7}, [r7]

    sub r7, r7, #96
    sub r9, r9, #96
    sub r8, r8, #96

intra_pred_bi_ipf_pL_pLeft_wy_end:

    cmp r3, #8
    blt intra_pred_bi_ipf_fill_block_loop4
    bgt intra_pred_bi_ipf_fill_block_loop16x

//intra_pred_bi_ipf_fill_block_loop8:

    vld1.8 {q4}, [r11]              // pTop
    vld1.8 {q5}, [r10]              // pT

    vmovl.u16 q3, d6                // [0, 1, 2, 3]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q12, q12

intra_pred_bi_ipf_fill_block_loop8_y:

    vadd.u16 q4, q4, q5             // pTop[x] += pT[x];
    vshll.u16 q6, d8, #3            // pTop[x] << ishift_x (ishift_x = 3)
    vshll.u16 q7, d9, #3

    ldrsh r5, [r9], #2              // pLeft[y];
    ldrsh r6, [r8], #2              // pL[y];

    vmov.u16 r12, d28[0]            // (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vmul.u32 q10, q9, q3            // [0, 1, 2 ```, 7] * add
    vshl.u32 q11, q9, #2
    vadd.u32 q11, q11, q10

    vadd.u32 q10, q10, q8           // (predx << ishift_y) + (pTop[x] << ishift_x) + wxy
    vadd.u32 q11, q11, q8

    vadd.u32 q10, q10, q6
    vadd.u32 q11, q11, q7

    vshl.s32 q10, q10, q12          // right shift ishift_x + ishift_y
    vshl.s32 q11, q11, q12

    subs r4, r4, #1
    vrshrn.u32 d20, q10, #1         // right shift 1
    vrshrn.u32 d21, q11, #1

    vst1.64 {d20, d21}, [r1], r2

    bgt intra_pred_bi_ipf_fill_block_loop8_y

    b intra_pred_bi_ipf_end

intra_pred_bi_ipf_fill_block_loop4:

    vld1.8 {d8}, [r11]              // pTop
    vld1.8 {d10}, [r10]             // pT
    vmovl.u16 q3, d6                // [0, 1, 2, 3]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q12, q12

intra_pred_bi_ipf_fill_block_loop4_y:

    vadd.u16 d8, d8, d10            // pTop[x] += pT[x];
    vshll.u16 q6, d8, #2            // pTop[x] << ishift_x (ishift_x = 2)

    ldrsh r5, [r9], #2              // pLeft[y];
    ldrsh r6, [r8], #2              // pL[y];

    vmov.u16 r12, d28[0]            // (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6       // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vmul.u32 q10, q9, q3       //[0, 1, 2, 3] * add

    vadd.u32 q10, q10, q8        //(predx << ishift_y) + (pTop[x] << ishift_x) + wxy

    vadd.u32 q10, q10, q6

    vshl.s32 q10, q10, q12         // right shift ishift_x + ishift_y

    subs r4, r4, #1
    vrshrn.u32 d20, q10, #1        // right shift 1
    vst1.64 d20, [r1], r2
    bgt intra_pred_bi_ipf_fill_block_loop4_y

    b intra_pred_bi_ipf_end

intra_pred_bi_ipf_fill_block_loop16x:

    cmp r3, #32
    blt intra_pred_bi_ipf_fill_block_loop16
    bgt intra_pred_bi_ipf_fill_block_loop64

// intra_pred_fill_block_loop32:

    vmovl.u16 q15, d6               // [0, 1, 2, 3]

    vld1.8 {q0, q1}, [r11]!         // pTop
    vld1.8 {q2, q3}, [r11]
    vld1.8 {q4, q5}, [r10]!         // pT
    vld1.8 {q6, q7}, [r10]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q13, q12

    sub r2, r2, #64                 // i_dst - width

intra_pred_bi_ipf_fill_block_loop32_y:

    vmov.u16 r12, d28[0]            // val = (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    ldrsh r5, [r9], #2
    ldrsh r6, [r8], #2
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vadd.u16 q0, q0, q4             // pTop[x] += pT[x];
    vadd.u16 q1, q1, q5
    vadd.u16 q2, q2, q6
    vadd.u16 q3, q3, q7

    vmul.u32 q10, q9, q15           // [0, 1, 2, 3] * add
    vshl.u32 q9, q9, #2

    vshll.u16 q11, d0, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d1, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d2, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d3, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d4, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d5, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d6, #5           // pTop[x] << ishift_x (ishift_x = 5)
    vshll.u16 q12, d7, #5

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    subs r4, r4, #1
    vst1.32 {q11}, [r1]!
    add r1, r1, r2
    bgt intra_pred_bi_ipf_fill_block_loop32_y

    b intra_pred_bi_ipf_end

intra_pred_bi_ipf_fill_block_loop16:

    sub r2, r2, #16

    vmovl.u16 q15, d6               // [0, 1, 2, 3]

    vld1.8 {q0, q1}, [r11]          // pTop
    vld1.8 {q4, q5}, [r10]          // pT

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q13, q12

intra_pred_bi_ipf_fill_block_loop16_y:

    vmov.u16 r12, d28[0]            // val = (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    ldrsh r5, [r9], #2
    ldrsh r6, [r8], #2
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vadd.u16 q0, q0, q4             // pTop[x] += pT[x];
    vadd.u16 q1, q1, q5

    vmul.u32 q10, q9, q15           // [0, 1, 2, 3] * add
    vshl.u32 q9, q9, #2

    vshll.u16 q11, d0, #4           // pTop[x] << ishift_x (ishift_x = 4)
    vshll.u16 q12, d1, #4

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d2, #4           // pTop[x] << ishift_x (ishift_x = 4)
    vshll.u16 q12, d3, #4

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    subs r4, r4, #1
    vst1.32 {q11}, [r1], r2
    bgt intra_pred_bi_ipf_fill_block_loop16_y

    b intra_pred_bi_ipf_end

intra_pred_bi_ipf_fill_block_loop64:

    vmovl.u16 q15, d6               // [0, 1, 2, 3]

    vld1.8 {q0, q1}, [r11]!         // pTop
    vld1.8 {q2, q3}, [r11]!
    vld1.8 {q4, q5}, [r11]!
    vld1.8 {q6, q7}, [r11]

    vaddl.u16 q12, d26, d28         // ishift_x + ishift_y;
    vneg.s32 q13, q12

    sub r2, r2, #128                // i_dst - width

intra_pred_bi_ipf_fill_block_loop64_y:

    vld1.8 {q8, q9}, [r10]!
    vld1.8 {q10, q11}, [r10]!
    vadd.u16 q0, q0, q8             // pTop[x] += pT[x];
    vadd.u16 q1, q1, q9
    vadd.u16 q2, q2, q10
    vadd.u16 q3, q3, q11
    vld1.8 {q8, q9}, [r10]!
    vld1.8 {q10, q11}, [r10]
    vadd.u16 q4, q4, q8
    vadd.u16 q5, q5, q9
    vadd.u16 q6, q6, q10
    vadd.u16 q7, q7, q11

    sub r10, r10, #96

    vmov.u16 r12, d28[0]            // val = (pLeft[y] << ishift_y) + (pL[y] << ishift_y);
    ldrsh r5, [r9], #2
    ldrsh r6, [r8], #2
    lsl r5, r5, r12
    lsl r6, r6, r12
    add r5, r5, r6
    vdup.32 q8, r5

    ldrsh r5, [r7], #2
    add r5, r5, r6                  // add = (pL[y] << ishift_y) + wy[y]
    vdup.32 q9, r5

    vmul.u32 q10, q9, q15           // [0, 1, 2, 3] * add
    vshl.u32 q9, q9, #2

    vshll.u16 q11, d0, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d1, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d2, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d3, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d4, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d5, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d6, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d7, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d8, #6           // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d9, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d10, #6          // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d11, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d12, #6          // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d13, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    vst1.32 {q11}, [r1]!

    vadd.u32 q10, q9, q10

    vshll.u16 q11, d14, #6          // pTop[x] << ishift_x (ishift_x = 6)
    vshll.u16 q12, d15, #6

    vadd.u32 q11, q11, q8           // (pTop[x] << ishift_x) + val
    vadd.u32 q12, q12, q8

    vadd.u32 q11, q11, q10          // (pTop[x] << ishift_x) + val + add
    vadd.u32 q10, q9, q10
    vadd.u32 q12, q12, q10

    vshl.s32 q11, q11, q13          // right shift ishift_x + ishift_y
    vshl.s32 q12, q12, q13

    vrshrn.u32 d22, q11, #1
    vrshrn.u32 d23, q12, #1

    subs r4, r4, #1
    vst1.32 {q11}, [r1]!

    add r1, r1, r2
    bgt intra_pred_bi_ipf_fill_block_loop64_y

intra_pred_bi_ipf_end:

    add sp, sp, #3072

    vpop {q4-q7}
    pop {r4-r12, pc}


#endif
