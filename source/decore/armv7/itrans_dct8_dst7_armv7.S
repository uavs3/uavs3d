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

#include "def_armv7.S"

#if defined(__arm__)

//*************************************************************************************************
//void uavs3d_itrans_dct8_pb4_armv7(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *it);
//r0->coeff blk, 16 bit
//r1->resi blk, 16 bit
//r7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dct8_pb4_armv7
    push {r4-r8, lr}
    add sp, sp, #24
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #24
    vpush {q4-q7}

    neg r8, r2
    vdup.32 q15, r8     //left shift
    vdup.16 d28, r6     //min_tr_val
    vdup.16 d29, r5     //max_tr_val

    //加载系数
    mov r4, #4
    vld1.8 d0, [r7], r4
    vld1.8 d2, [r7], r4
    vld1.8 d4, [r7], r4
    vld1.8 d6, [r7], r4
    vmovl.s8 q0, d0
    vmovl.s8 q1, d2
    vmovl.s8 q2, d4
    vmovl.s8 q3, d6

    mov r4, #0
    lsl r3, r3, #1

dct8_pb4_armv7_loopi:
    //加载源文件
    add r9, r4, r0
    vld1.8 d8, [r9], r3
    vld1.8 d10, [r9], r3
    vld1.8 d12, [r9], r3
    vld1.8 d14, [r9], r3
    vdup.s16 d8, d8[0]
    vdup.s16 d10, d10[0]
    vdup.s16 d12, d12[0]
    vdup.s16 d14, d14[0]

    vmull.s16 q4, d0, d8
    vmull.s16 q5, d2, d10
    vmull.s16 q6, d4, d12
    vmull.s16 q7, d6, d14
    vqadd.s32 q4, q5, q4
    vqadd.s32 q6, q7, q6
    vqadd.s32 q4, q6, q4

    cmp r2, #5
    bne dct8_pb4_armv7_shift12

    vqrshrn.s32 d8, q4, #5
    b dct8_pb4_armv7_store

dct8_pb4_armv7_shift12:
    vrshl.s32 q4, q4, q15
    vmovn.s32 d8, q4
    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28

dct8_pb4_armv7_store:
    vst1.64 d8, [r1]
    add r1, r1,#8
    add r4, r4, #2
    cmp r4, r3
    blo dct8_pb4_armv7_loopi


    vpop {q4-q7}
    pop  {r4-r8, lr}
    mov  pc, lr


//*************************************************************************************************
//void uavs3d_itrans_dct8_pb8_armv7(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *it)
//r0->coeff blk, 16 bit
//r1->resi blk, 16 bit
//r7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dct8_pb8_armv7
    push {r4-r8, lr}
    add sp, sp, #24
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #24
    vpush {q4-q7}

    neg r8, r2
    vdup.32 q15, r8     //left shift
    vdup.16 d28, r6     //min_tr_val
    vdup.16 d29, r5     //max_tr_val

    lsl r3, r3, #1
    mov r4, #0 //i
dct8_pb8_armv7_loopi:
    mov r5, #0 //j
    mov r9, r7 //r9系数指针
dct8_pb8_armv7_loopj:
    vmov.s32 q8, #0 //累加的矢量寄存器
    mov r6, #0 //k
dct8_pb8_armv7_loopk:
    //加载系数
    mov r8, #8
    vld1.8 d0, [r9], r8
    vld1.8 d2, [r9], r8
    vld1.8 d4, [r9], r8
    vld1.8 d6, [r9], r8
    vmovl.s8 q0, d0
    vmovl.s8 q1, d2
    vmovl.s8 q2, d4
    vmovl.s8 q3, d6

    //加载源文件
    vld1.8 d8, [r0], r3
    vld1.8 d10, [r0], r3
    vld1.8 d12, [r0], r3
    vld1.8 d14, [r0], r3
    vdup.s16 d8, d8[0]
    vdup.s16 d10, d10[0]
    vdup.s16 d12, d12[0]
    vdup.s16 d14, d14[0]

    //计算
    vmull.s16 q4, d0, d8
    vmull.s16 q5, d2, d10
    vmull.s16 q6, d4, d12
    vmull.s16 q7, d6, d14
    vqadd.s32 q4, q5, q4
    vqadd.s32 q6, q7, q6
    vqadd.s32 q4, q6, q4

    vqadd.s32 q8, q8, q4

    add r6, r6, #1
    cmp r6, #2
    blo dct8_pb8_armv7_loopk

    cmp r2, #5
    bne dct8_pb8_armv7_shift12

    vqrshrn.s32 d16, q8, #5
    b dct8_pb8_armv7_store

dct8_pb8_armv7_shift12:
    vrshl.s32 q8, q8, q15
    vmovn.s32 d16, q8
    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28

dct8_pb8_armv7_store:
    vst1.64 d16, [r1]
    add r1, r1, #8
    sub r9, r9, #60
    mov r8, r3
    lsl r8, r8, #3
    sub r0, r0, r8
    add r5, r5, #1
    cmp r5, #2
    blo dct8_pb8_armv7_loopj

    add r4, r4, #2
    add r0, r0, #2
    cmp r4, r3
    blo dct8_pb8_armv7_loopi

    vpop {q4-q7}
    pop  {r4-r8, lr}


//*************************************************************************************************
//void uavs3d_itrans_dct8_pb16_armv7(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *it);
//r0->coeff blk, 16 bit
//r1->resi blk, 16 bit
//r7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dct8_pb16_armv7
    push {r4-r8, lr}
    add sp, sp, #24
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #24
    vpush {q4-q7}

    neg r8, r2
    vdup.32 q15, r8     //left shift
    vdup.16 d28, r6     //min_tr_val
    vdup.16 d29, r5     //max_tr_val

    lsl r3, r3, #1
    mov r4, #0 //i
dct8_pb16_armv7_loopi:
    mov r5, #0 //j
    mov r9, r7 //r9系数指针
dct8_pb16_armv7_loopj:
    vmov.s32 q8, #0 //累加的矢量寄存器
    mov r6, #0 //k
dct8_pb16_armv7_loopk:
    //加载系数
    mov r8, #16
    vld1.8 d0, [r9], r8
    vld1.8 d2, [r9], r8
    vld1.8 d4, [r9], r8
    vld1.8 d6, [r9], r8
    vmovl.s8 q0, d0
    vmovl.s8 q1, d2
    vmovl.s8 q2, d4
    vmovl.s8 q3, d6

    //加载源文件
    vld1.8 d8, [r0], r3
    vld1.8 d10, [r0], r3
    vld1.8 d12, [r0], r3
    vld1.8 d14, [r0], r3
    vdup.s16 d8, d8[0]
    vdup.s16 d10, d10[0]
    vdup.s16 d12, d12[0]
    vdup.s16 d14, d14[0]

    //计算
    vmull.s16 q4, d0, d8
    vmull.s16 q5, d2, d10
    vmull.s16 q6, d4, d12
    vmull.s16 q7, d6, d14
    vqadd.s32 q4, q5, q4
    vqadd.s32 q6, q7, q6
    vqadd.s32 q4, q6, q4

    vqadd.s32 q8, q8, q4

    add r6, r6, #1
    cmp r6, #4
    blo dct8_pb16_armv7_loopk

    cmp r2, #5
    bne dct8_pb16_armv7_shift12

    vqrshrn.s32 d16, q8, #5
    b dct8_pb16_armv7_store

dct8_pb16_armv7_shift12:
    vrshl.s32 q8, q8, q15
    vmovn.s32 d16, q8
    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28

dct8_pb16_armv7_store:
    vst1.64 d16, [r1]
    add r1, r1, #8
    sub r9, r9, #252
    mov r8, r3
    lsl r8, r8, #4
    sub r0, r0, r8
    add r5, r5, #1
    cmp r5, #4
    blo dct8_pb16_armv7_loopj

    add r4, r4, #2
    add r0, r0, #2
    cmp r4, r3
    blo dct8_pb16_armv7_loopi

    vpop {q4-q7}
    pop  {r4-r8, lr}
    mov  pc, lr


//*************************************************************************************************
//void uavs3d_itrans_dst7_pb4_armv7(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *it);
//r0->coeff blk, 16 bit
//r1->resi blk, 16 bit
//r7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dst7_pb4_armv7
    push {r4-r8, lr}
    add sp, sp, #24
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #24
    vpush {q4-q7}

    neg r8, r2
    vdup.32 q15, r8     //left shift
    vdup.16 d28, r6     //min_tr_val
    vdup.16 d29, r5     //max_tr_val

    //加载系数
    mov r4, #4
    vld1.8 d0, [r7], r4
    vld1.8 d2, [r7], r4
    vld1.8 d4, [r7], r4
    vld1.8 d6, [r7], r4
    vmovl.s8 q0, d0
    vmovl.s8 q1, d2
    vmovl.s8 q2, d4
    vmovl.s8 q3, d6

    mov r4, #0
    lsl r3, r3, #1

dst7_pb4_armv7_loopi:
    //加载源文件
    add r9, r4, r0
    vld1.8 d8, [r9], r3
    vld1.8 d10, [r9], r3
    vld1.8 d12, [r9], r3
    vld1.8 d14, [r9], r3
    vdup.s16 d8, d8[0]
    vdup.s16 d10, d10[0]
    vdup.s16 d12, d12[0]
    vdup.s16 d14, d14[0]

    vmull.s16 q4, d0, d8
    vmull.s16 q5, d2, d10
    vmull.s16 q6, d4, d12
    vmull.s16 q7, d6, d14
    vqadd.s32 q4, q5, q4
    vqadd.s32 q6, q7, q6
    vqadd.s32 q4, q6, q4

    cmp r2, #5
    bne dct8_pb4_armv7_shift12

    vqrshrn.s32 d8, q4, #5
    b dst7_pb4_armv7_store

dst7_pb4_armv7_shift12:
    vrshl.s32 q4, q4, q15
    vmovn.s32 d8, q4
    vmin.s16 d8, d8, d29
    vmax.s16 d8, d8, d28

dst7_pb4_armv7_store:
    vst1.64 d8, [r1]
    add r1, r1,#8
    add r4, r4, #2
    cmp r4, r3
    blo dst7_pb4_armv7_loopi

    vpop {q4-q7}
    pop  {r4-r8, lr}
    mov  pc, lr


//*************************************************************************************************
//void uavs3d_itrans_dst7_pb8_armv7(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *it)
//r0->coeff blk, 16 bit
//r1->resi blk, 16 bit
//r7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dst7_pb8_armv7
    push {r4-r8, lr}
    add sp, sp, #24
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #24
    vpush {q4-q7}

    neg r8, r2
    vdup.32 q15, r8     //left shift
    vdup.16 d28, r6     //min_tr_val
    vdup.16 d29, r5     //max_tr_val

    lsl r3, r3, #1
    mov r4, #0 //i
dst7_pb8_armv7_loopi:
    mov r5, #0 //j
    mov r9, r7 //r9系数指针
dst7_pb8_armv7_loopj:
    vmov.s32 q8, #0 //累加的矢量寄存器
    mov r6, #0 //k
dst7_pb8_armv7_loopk:
    //加载系数
    mov r8, #8
    vld1.8 d0, [r9], r8
    vld1.8 d2, [r9], r8
    vld1.8 d4, [r9], r8
    vld1.8 d6, [r9], r8
    vmovl.s8 q0, d0
    vmovl.s8 q1, d2
    vmovl.s8 q2, d4
    vmovl.s8 q3, d6

    //加载源文件
    vld1.8 d8, [r0], r3
    vld1.8 d10, [r0], r3
    vld1.8 d12, [r0], r3
    vld1.8 d14, [r0], r3
    vdup.s16 d8, d8[0]
    vdup.s16 d10, d10[0]
    vdup.s16 d12, d12[0]
    vdup.s16 d14, d14[0]

    //计算
    vmull.s16 q4, d0, d8
    vmull.s16 q5, d2, d10
    vmull.s16 q6, d4, d12
    vmull.s16 q7, d6, d14
    vqadd.s32 q4, q5, q4
    vqadd.s32 q6, q7, q6
    vqadd.s32 q4, q6, q4

    vqadd.s32 q8, q8, q4

    add r6, r6, #1
    cmp r6, #2
    blo dct8_pb8_armv7_loopk

    cmp r2, #5
    bne dct8_pb8_armv7_shift12

    vqrshrn.s32 d16, q8, #5
    b dct8_pb8_armv7_store

dst7_pb8_armv7_shift12:
    vrshl.s32 q8, q8, q15
    vmovn.s32 d16, q8
    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28

dst7_pb8_armv7_store:
    vst1.64 d16, [r1]
    add r1, r1, #8
    sub r9, r9, #60
    mov r8, r3
    lsl r8, r8, #3
    sub r0, r0, r8
    add r5, r5, #1
    cmp r5, #2
    blo dct8_pb8_armv7_loopj

    add r4, r4, #2
    add r0, r0, #2
    cmp r4, r3
    blo dct8_pb8_armv7_loopi

    vpop {q4-q7}
    pop  {r4-r8, lr}
    mov  pc, lr


//*************************************************************************************************
//void uavs3d_itrans_dst7_pb16_armv7(s16 *coeff, s16 *block, int shift, int line, int limit_line, int max_tr_val, int min_tr_val, s8 *it);
//r0->coeff blk, 16 bit
//r1->resi blk, 16 bit
//r7->transform block, 8bit
//*************************************************************************************************
function uavs3d_itrans_dst7_pb16_armv7
    push {r4-r8, lr}
    add sp, sp, #24
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #24
    vpush {q4-q7}

    neg r8, r2
    vdup.32 q15, r8     //left shift
    vdup.16 d28, r6     //min_tr_val
    vdup.16 d29, r5     //max_tr_val

    lsl r3, r3, #1
    mov r4, #0 //i
dst7_pb16_armv7_loopi:
    mov r5, #0 //j
    mov r9, r7 //r9系数指针
dst7_pb16_armv7_loopj:
    vmov.s32 q8, #0 //累加的矢量寄存器
    mov r6, #0 //k
dst7_pb16_armv7_loopk:
    //加载系数
    mov r8, #16
    vld1.8 d0, [r9], r8
    vld1.8 d2, [r9], r8
    vld1.8 d4, [r9], r8
    vld1.8 d6, [r9], r8
    vmovl.s8 q0, d0
    vmovl.s8 q1, d2
    vmovl.s8 q2, d4
    vmovl.s8 q3, d6

    //加载源文件
    vld1.8 d8, [r0], r3
    vld1.8 d10, [r0], r3
    vld1.8 d12, [r0], r3
    vld1.8 d14, [r0], r3
    vdup.s16 d8, d8[0]
    vdup.s16 d10, d10[0]
    vdup.s16 d12, d12[0]
    vdup.s16 d14, d14[0]

    //计算
    vmull.s16 q4, d0, d8
    vmull.s16 q5, d2, d10
    vmull.s16 q6, d4, d12
    vmull.s16 q7, d6, d14
    vqadd.s32 q4, q5, q4
    vqadd.s32 q6, q7, q6
    vqadd.s32 q4, q6, q4

    vqadd.s32 q8, q8, q4

    add r6, r6, #1
    cmp r6, #4
    blo dct8_pb16_armv7_loopk

    cmp r2, #5
    bne dst7_pb16_armv7_shift12

    vqrshrn.s32 d16, q8, #5
    b dst7_pb16_armv7_store

dst7_pb16_armv7_shift12:
    vrshl.s32 q8, q8, q15
    vmovn.s32 d16, q8
    vmin.s16 d16, d16, d29
    vmax.s16 d16, d16, d28

dst7_pb16_armv7_store:
    vst1.64 d16, [r1]
    add r1, r1, #8
    sub r9, r9, #252
    mov r8, r3
    lsl r8, r8, #4
    sub r0, r0, r8
    add r5, r5, #1
    cmp r5, #4
    blo dst7_pb16_armv7_loopj

    add r4, r4, #2
    add r0, r0, #2
    cmp r4, r3
    blo dst7_pb16_armv7_loopi

    vpop {q4-q7}
    pop  {r4-r8, lr}
    mov  pc, lr

#endif
