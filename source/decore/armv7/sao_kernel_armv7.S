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

/***********************************************************************************************************************************
*  void uavs3d_sao_eo_0_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height,
*                      char_t* mask)
*  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, start_x->r5, end_x->r6, mb_height->r7, mask->r8
************************************************************************************************************************************/
function uavs3d_sao_eo_0_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8}
    sub sp, sp, #40
    
    sub     r10, r6 , r5
    mov     r9 , #15
    and     r9 , r9 , r10
    add     r12, r8 , r9, lsl#4
    vld1.32 {q15}, [r12]            // load mask: mask+((end_x - start_x) & 0x0f)*16
    
    sub     r10, r6 , r9            // end_x_16 = end_x - ((end_x - start_x) & 0x0f)
    
    //------- set offset table: q0 -----------
    vld1.32 {q10}, [r4]             // load offset[0-3]
    ldr  r9 , [r4, #16]             // load offset4
    mov  r8, #0
    vmov d4, r9, r8
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                // convert int32 to byte
    
    vmov.u8 q1 , #2                 // constant(save)
    
    mov     r8 , #0                 // y = 0
loop_y_eo_0:
    mov     r9, r5                  // x = start_x
loop_x_eo_0:
    add     r12, r0 , r9
    sub     r11, r12, #1
    vld1.8  {q11}, [r12]            // load src[x]    (save)
    vld1.8  {q10}, [r11]            // load src[x-1]

    add     r12, r12 , #1

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13           // leftsign

    vld1.8 {q12}, [r12]             // load src[x+1]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13           // rightsign
    
    vadd.s8 q10, q12, q10           // edgetype
    
    vadd.s8 q10, q10, q1            // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21         // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22               // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14            // results
    
    add     r12, r1, r9             // dst+x
    cmp     r9, r10
    beq     maskmove_eo_0
    vst1.8  {q10}, [r12]
    add     r9, #16
    cmp     r9, r6
    blt     loop_x_eo_0
    b       loop_x_eo_0_end

maskmove_eo_0:
    //- maskmove
    vld1.8  {q12}, [r12]            // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]

loop_x_eo_0_end:    
    add     r0, r0, r2              // src+=src_stride
    add     r1, r1, r3              // dst+=dst_stride
    
    add     r8, #1                  // y++
    cmp     r8, r7                  // y == mb_height?
    bne     loop_y_eo_0
    
    ldmia   sp!, {r4-r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_0_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height,
 *                      char_t* mask)
 *  src->x0, dst->x1, src_stride->x2, dst_stride->x3, offset->x4, start_x->x5, end_x->x6, mb_height->x7, mask->x8
 ************************************************************************************************************************************/
function uavs3d_sao_eo_0_chroma_armv7
    stmdb sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8}
    sub sp, sp, #40
    vpush {q4-q7}

    sub     r10, r6 , r5
    mov     r9 , #15
    lsr     r10, #1
    and     r9 , r9 , r10
    add     r12, r8 , r9, lsl#4
    vld1.32 {q15}, [r12]            // load mask: mask+((end_x - start_x) & 0x0f)*16
    vmovl.s8 q7, d30
    vmovl.s8 q8, d31

    sub     r10, r6, r9, lsl #1     // r10 = end_x_16 = end_x - ((end_x - start_x) & 0x0f)

    mov     r8, #0x00ff
    vdup.16 q6, r8                  // mask_uv: for uv interlace

    vand    q7, q6                  // mask for last cols
    vand    q8, q6

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]             // load offset[0-3]
    ldr     r9 , [r4, #16]          // load offset4
    mov     r8, #0
    vmov     d4, r9, r8
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                // convert int32 to byte

    vmov.u8 q1 , #2                 // constant(save)

    mov     r8 , #0                 // y = 0
loop_y_eo_0_chroma:
    mov     r9, r5                  // x = start_x
loop_x_eo_0_chroma:
    add     r12, r0 , r9
    sub     r11, r12, #2
    vld1.8  {q4, q5}, [r12]         // load src[x]    (save) to q11
    vld1.8  {q9, q10}, [r11]        // load src[x-2]
    vmovn.u16 d22, q4               // delete the other chroma
    vmovn.u16 d23, q5               // q11: src[x]
    vmovn.u16 d21, q10              // q10: src[x-2]
    vmovn.u16 d20, q9

    add     r12, r12 , #2
    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13           // leftsign

    vld1.8 {q2, q3}, [r12]          // load src[x+2] to q12
    vmovn.u16 d24, q2
    vmovn.u16 d25, q3

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13           // rightsign

    vadd.s8 q10, q12, q10           // edgetype

    vadd.s8 q10, q10, q1            // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21         // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22               // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14            // results

    add     r12, r1, r9             // dst + x
    vld1.64 {q4, q5}, [r12]         // load 32 pixels from dst+x
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    cmp     r9, r10
    beq     maskmove_eo_0_chroma
    vbif    q11, q4, q6
    vbif    q12, q5, q6
    vst1.8  {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r6
    blt     loop_x_eo_0_chroma
    b       loop_x_eo_0_chroma_end

maskmove_eo_0_chroma:
    //- maskmove
    vbif    q11, q4, q7
    vbif    q12, q5, q8
    vst1.8  {q11, q12}, [r12]

loop_x_eo_0_chroma_end:
    add     r0, r0, r2              // src += src_stride
    add     r1, r1, r3              // dst += dst_stride

    add     r8, #1                  // y++
    cmp     r8, r7                  // y == mb_height?
    bne     loop_y_eo_0_chroma

    vpop    {q4-q7}
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_90_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width);
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, start_y->r5, end_y->r6, mb_width->r7
 ************************************************************************************************************************************/
function uavs3d_sao_eo_90_armv7
    stmdb sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #40
    
    mul     r8 , r2 , r5
    mul     r9 , r3 , r5
    add     r0 , r0 , r8                // src -= start_y*src_stride
    add     r1 , r1 , r9                // dst -= start_y*dst_stride
    
    sub     r10, r7 , #15               // r10 = end_x_16 = mb_width - 15
    
    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r9 , [r4, #16]              // load offset4
    mov     r8, #0
    vmov      d4, r9, r8
    vmov.u32  d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte
    
    vmov.u8 q1 , #2                     // constant(save)
    
    mov     r8 , r5                     // y = start_y
    
    mov     r12, #0
    mov     r9 , #-1
    vmov.i8 d30, #255
    vmov    d31, r9, r12                // mask="-1 repeat 12, 0, 0, 0, 0"

loop_y_eo_90:
    mov     r9, #0                      // x = 0
loop_x_eo_90:
    add     r12, r0 , r9
    vld1.8  {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    vld1.8  {q10}, [r12]                // load src[x-src_stride]
    
    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign
    
    add     r12, r12, r2, lsl #1
    vld1.8 {q12}, [r12]                 // load src[x+src_stride]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign
    
    vadd.s8 q10, q12, q10               // edgetype
    
    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results
    
    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_90
    vst1.8  {q10}, [r12]
    add     r9, #16
    cmp     r9, r7
    blt     loop_x_eo_90
    b       loop_x_eo_90_end
maskmove_eo_90:
    //- maskmove
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]

loop_x_eo_90_end:    
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    
    add     r8, #1                      // y++
    cmp     r8, r6                      // y == end_y?
    bne     loop_y_eo_90
    
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_90_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width);
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, start_y->r5, end_y->r6, mb_width->r7
 ************************************************************************************************************************************/
function uavs3d_sao_eo_90_chroma_armv7
    stmdb sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #40
    vpush {q4-q6}

    mul     r8 , r2 , r5
    mul     r9 , r3 , r5
    add     r0 , r0 , r8            // src -= start_y*src_stride
    add     r1 , r1 , r9            // dst -= start_y*dst_stride

    sub     r10, r7 , #31           // r10 = end_x_16 = mb_width - 31

    mov     r8, #0x00ff
    vdup.16 q6, r8

//----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]             // load offset[0-3]
    ldr     r9 , [r4, #16]          // load offset4
    mov     r8, #0
    vmov      d4, r9, r8
    vmov.u32  d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                // convert int32 to byte

    vmov.u8 q1 , #2                 // constant(save)

    mov     r8 , r5                 // y = start_y

    mov     r12, #0
    mov     r9 , #-1
    cmp     r7 , #8
    vmov.i8 q8, #255                // mask="-1 repeat 12, 0, 0, 0, 0"
    vdup.32 d18, r9
    vdup.32 d19, r12

eo_90_chroma_start:
    vand    q8, q6
    vand    q9, q6

loop_y_eo_90_chroma:
    mov     r9, #0                  // x = 0
loop_x_eo_90_chroma:
    add     r12, r0 , r9
    vld1.8  {q2, q3}, [r12]         // load src[x]    (save) to q11
    vmovn.u16 d22, q2
    vmovn.u16 d23, q3
    sub     r12, r12, r2
    vld1.8  {q4, q5}, [r12]         // load src[x - src_stride] to q10
    vmovn.u16 d20, q4
    vmovn.u16 d21, q5

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13           // leftsign

    add     r12, r12, r2, lsl #1
    vld1.8 {q4, q5}, [r12]          // load src[x + src_stride]
    vmovn.u16 d24, q4
    vmovn.u16 d25, q5

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13           // rightsign

    vadd.s8 q10, q12, q10           // edgetype

    vadd.s8 q10, q10, q1            // generate look-up indexs
    vtbl.8  d24, {d0}, d20
    vtbl.8  d25, {d0}, d21          // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22               // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14            // results

    add     r12, r1, r9             // dst+x
    cmp     r9, r10
    bge     maskmove_eo_90_chroma
    vld1.64 {q2, q3}, [r12]
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vbif     q11, q2, q6
    vbif     q12, q3, q6
    vst1.8  {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r7
    blt     loop_x_eo_90_chroma
    b       loop_x_eo_90_chroma_end
maskmove_eo_90_chroma:
    //- maskmove
    vld1.64 {q2, q3}, [r12]
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vbif    q11, q2, q8
    vbif    q12, q3, q9
    vst1.8  {q11, q12}, [r12]

loop_x_eo_90_chroma_end:
    add     r0, r0, r2                // src+=src_stride
    add     r1, r1, r3                // dst+=dst_stride

    add     r8, #1                    // y++
    cmp     r8, r6                    // y == end_y?
    bne     loop_y_eo_90_chroma

    vpop    {q4-q6}
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov     pc, lr


/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_135_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth, int start_x_r0,
 *  int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6, bit_depth->r7
 ************************************************************************************************************************************/
function uavs3d_sao_eo_135_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r4=offset; r5=mask; r6=mb_height; r7=bit_depth; r8=start_x_r0; r9=end_x_r0
    
    sub     r11, r9, r8
    and     r11, r11, #15
    sub     r10, r9, r11                // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);
    
    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov     d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte
    
    vmov.u8 q1 , #2                     // constant(save)
    
//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_135_r0:
    cmp     r11, r9
    bge     loop_x_eo_135_end_r0
    add     r12, r0, r11
    vld1.8  {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    sub     r12, r12, #1
    vld1.8  {q10}, [r12]                // load src[x-src_stride-1]

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign
    
    add     r12, r12, r2, lsl #1
    add     r12, r12, #2
    vld1.8 {q12}, [r12]                 // load src[x+src_stride+1]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign
    
    vadd.s8 q10, q12, q10               // edgetype
    
    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results
    
    add     r12, r1, r11                // dst+x
    cmp     r11, r10
    bge     maskmove_eo_135_r0
    vst1.8  {q10}, [r12]
    add     r11, #16
    b       loop_x_eo_135_r0
maskmove_eo_135_r0:
    sub     r7, r9, r10
    add     r7, r5 , r7, lsl #4         // offset = 16*rownum
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]

loop_x_eo_135_end_r0:    
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #15
    add     r12, r5, r9, lsl #4
    vld1.32 {q15}, [r12]                // mask_r
    
    sub     r10, r8, r9                 // r10=end_x_r_16

    mov     r11, #1                     // y = 1
loop_y_eo_135_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_135_r:
    add     r12, r0, r9
    vld1.8  {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    sub     r12, r12, #1
    vld1.8  {q10}, [r12]                // load src[x-src_stride-1]

    add     r12, r12, r2, lsl #1
    add     r12, r12, #2

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign

    vld1.8 {q12}, [r12]                 // load src[x+src_stride+1]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign
    
    vadd.s8 q10, q12, q10               // edgetype
    
    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results
    
    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_r
    vst1.8  {q10}, [r12]
    add     r9, #16
    cmp     r9, r8
    blt     loop_x_eo_135_r
    b       loop_x_eo_135_end_r
maskmove_eo_135_r:
    //- maskmove
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]

loop_x_eo_135_end_r:    
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    
    add     r11, #1                     // y++
    sub     r12, r6, #1
    cmp     r11, r12                    // y == mb_height - 1?
    bne     loop_y_eo_135_r
    
//-------------------------------last row--------------------------------
    ldmia   sp , {r6, r7}               // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #15
    sub     r10, r7, r8                 // r10=end_x_rn_16
    
    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_135_rn:
    cmp     r9 , r7
    bge     loop_x_eo_135_end_rn
    add     r12, r0 , r9
    vld1.8  {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    sub     r12, r12, #1
    vld1.8  {q10}, [r12]                // load src[x-src_stride-1]
    
    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign
    
    add     r12, r12, r2, lsl #1
    add     r12, r12, #2
    vld1.8 {q12}, [r12]                 // load src[x+src_stride+1]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign
    
    vadd.s8 q10, q12, q10               // edgetype
    
    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results
    
    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_rn
    vst1.8  {q10}, [r12]
    add     r9, #16
    b       loop_x_eo_135_rn
maskmove_eo_135_rn:
    sub     r6, r7 , r10
    add     r6, r5 , r6, lsl #4         // offset = 16*rownum
    vld1.32 {q15}, [r6]                 // load mask_rn
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]
loop_x_eo_135_end_rn:    
    sub     sp, sp, #72                 // reserve stack point
    ldmia   sp!, {r4-r12, lr}
    mov     pc, lr


/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_135_chroma_armv7(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth,
 *  int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6
 ************************************************************************************************************************************/
function uavs3d_sao_eo_135_chroma_armv7
    stmdb sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    vpush {q4-q7}
    add sp, sp, #104
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r4=offset; r5=mask; r6=mb_height; r7=start_x_r0; r8=end_x_r0

    sub     r11, r9, r8
    and     r11, r11, #31
    sub     r10, r9, r11                // r10: end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov     d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte

    mov     r11, #0x00ff
    vdup.16 q7, r11

    vmov.u8 q1, #2                      // constant(save)

//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_135_chroma_r0:
    cmp     r11, r9
    bge     loop_x_eo_135_chroma_end_r0
    add     r12, r0 , r11
    vld1.8  {q3, q4}, [r12]             // load src[x]    (save) to q11
    vmovn.u16 d22, q3
    vmovn.u16 d23, q4
    sub     r12, r12, r2
    sub     r12, r12, #2
    vld1.8  {q5, q6}, [r12]             // load src[x-src_stride-2] to q10
    vmovn.u16 d20, q5
    vmovn.u16 d21, q6

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #4
    vld1.8 {q5, q6}, [r12]              // load src[x+src_stride+2]
    vmovn.u16 d24, q5
    vmovn.u16 d25, q6

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign

    vadd.s8 q10, q12, q10               // edgetype

    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0}, d20
    vtbl.8  d25, {d0}, d21              // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results

    add     r12, r1, r11                // dst+x
    cmp     r11, r10
    bge     maskmove_eo_135_chroma_r0

    vld1.64 {q3, q4}, [r12]
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vbif    q11, q3, q7
    vbif    q12, q4, q7
    vst1.8  {q11, q12}, [r12]
    add     r11, #32
    b       loop_x_eo_135_chroma_r0
maskmove_eo_135_chroma_r0:
    sub     r7, r9, r10
    add     r7, r5 , r7, lsl #3         // offset = 16*rowid
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.64 {q3, q4}, [r12]
    vmovl.s8 q8, d30
    vmovl.s8 q9, d31
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q3, q8
    vbif    q12, q4, q9
    vst1.8  {q11, q12}, [r12]

loop_x_eo_135_chroma_end_r0:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #31
    add     r12, r5, r9, lsl #3
    vld1.32 {q15}, [r12]                // mask_r
    vmovl.s8 q8, d30
    vmovl.s8 q9, d31

    sub     r10, r8, r9                 // r10=end_x_r_16

    mov     r11, #1                     // y = 1
loop_y_eo_135_chroma_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_135_chroma_r:
    add     r12, r0 , r9
    vld1.8  {q3, q4}, [r12]             // load src[x]    (save)
    vmovn.u16 d22, q3
    vmovn.u16 d23, q4
    sub     r12, r12, r2
    sub     r12, r12, #2
    vld1.8  {q5, q6}, [r12]             // load src[x-src_stride-2]
    vmovn.u16 d20, q5
    vmovn.u16 d21, q6

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #4
    vld1.8 {q5, q6}, [r12]              // load src[x+src_stride+4]
    vmovn.u16 d24, q5
    vmovn.u16 d25, q6

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign

    vadd.s8 q10, q12, q10               // edgetype

    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_chroma_r
    vld1.64 {q3, q4}, [r12]
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vbif    q11, q3, q7
    vbif    q12, q4, q7
    vst1.8  {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r8
    blt     loop_x_eo_135_chroma_r
    b       loop_x_eo_135_chroma_end_r
maskmove_eo_135_chroma_r:
    //- maskmove
    vld1.64 {q3, q4}, [r12]
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q3, q8
    vbif    q12, q4, q9
    vst1.8  {q11, q12}, [r12]

loop_x_eo_135_chroma_end_r:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

    add     r11, #1                     // y++
    sub     r12, r6, #1
    cmp     r11, r12                    // y == mb_height - 1?
    bne     loop_y_eo_135_chroma_r

//-------------------------------last row--------------------------------
    ldmia   sp, {r6, r7}                // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #31
    sub     r10, r7, r8                 // r10=end_x_rn_16

    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_135_chroma_rn:
    cmp     r9 , r7
    bge     loop_x_eo_135_chroma_end_rn
    add     r12, r0 , r9
    vld1.8  {q3, q4}, [r12]             // load src[x]    (save)
    vmovn.u16 d22, q3
    vmovn.u16 d23, q4
    sub     r12, r12, r2
    sub     r12, r12, #2
    vld1.8  {q5, q6}, [r12]             // load src[x-src_stride-2]
    vmovn.u16 d20, q5
    vmovn.u16 d21, q6

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #4
    vld1.8 {q5, q6}, [r12]              // load src[x+src_stride+2]
    vmovn.u16 d24, q5
    vmovn.u16 d25, q6

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign

    vadd.s8 q10, q12, q10               // edgetype

    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_chroma_rn
    vld1.64 {q3, q4}, [r12]
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vbif    q11, q3, q7
    vbif    q12, q4, q7
    vst1.8  {q11, q12}, [r12]

    add     r9, #32
    b       loop_x_eo_135_chroma_rn
maskmove_eo_135_chroma_rn:
    sub     r6, r7, r10
    add     r6, r5, r6, lsl #3          // offset = 16*rownum
    vld1.32 {q15}, [r6]                 // load mask_rn
    vld1.64 {q3, q4}, [r12]
    vmovl.s8 q8, d30
    vmovl.s8 q9, d31
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q3, q8
    vbif    q12, q4, q9
    vst1.64 {q11, q12}, [r12]
loop_x_eo_135_chroma_end_rn:
    sub     sp, sp, #136                // reserve stack point
    vpop    {q4-q7}
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_45_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth
 *  int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6
 ************************************************************************************************************************************/
function uavs3d_sao_eo_45_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r7=bit_depth; r8=start_x_r0; r9=end_x_r0
    
    sub     r11, r9, r8
    and     r11, r11, #15
    sub     r10, r9, r11                // r10:end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);
    
    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov     d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte
    
    vmov.u8 q1 , #2                     // constant(save)
    
//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_45_r0:
    cmp     r11, r9
    bge     loop_x_eo_45_end_r0
    add     r12, r0, r11
    vld1.8  {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #1
    vld1.8  {q10}, [r12]                // load src[x-src_stride+1]
    
    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign
    
    add     r12, r12, r2, lsl #1
    sub     r12, r12, #2
    vld1.8 {q12}, [r12]                 // load src[x+src_stride-1]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign
    
    vadd.s8 q10, q12, q10               // edgetype
    
    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results
    
    add     r12, r1, r11                // dst+x
    cmp     r11, r10
    bge     maskmove_eo_45_r0
    vst1.8  {q10}, [r12]
    add     r11, #16
    b       loop_x_eo_45_r0
maskmove_eo_45_r0:
    sub     r7, r9, r10
    add     r7, r5 , r7, lsl #4         // offset = 16*rownum
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]

loop_x_eo_45_end_r0:    
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #15
    add     r12, r5, r9, lsl #4
    vld1.32 {q15}, [r12]                // mask_r
    
    sub     r10, r8, r9                 // r10=end_x_r_16

    mov     r11, #1                     // y = 1
loop_y_eo_45_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_45_r:
    add     r12, r0 , r9
    vld1.8  {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #1
    vld1.8  {q10}, [r12]                // load src[x-src_stride+1]
    
    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign
    
    add     r12, r12, r2, lsl #1
    sub     r12, r12, #2
    vld1.8 {q12}, [r12]                 // load src[x+src_stride-1]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign
    
    vadd.s8 q10, q12, q10               // edgetype
    
    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results
    
    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_45_r
    vst1.8  {q10}, [r12]
    add     r9, #16
    cmp     r9, r8
    blt     loop_x_eo_45_r
    b       loop_x_eo_45_end_r
maskmove_eo_45_r:
    //- maskmove
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]

loop_x_eo_45_end_r:    
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    
    add     r11, #1                     // y++
    sub     r12, r6, #1
    cmp     r11, r12                    // y == mb_height - 1?
    bne     loop_y_eo_45_r
    
//-------------------------------last row--------------------------------
    ldmia   sp , {r6, r7}               // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #15
    sub     r10, r7, r8                 // r10=end_x_rn_16
    
    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_45_rn:
    cmp     r9 , r7
    bge     loop_x_eo_45_end_rn
    add     r12, r0 , r9
    vld1.8  {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #1
    vld1.8  {q10}, [r12]                // load src[x-src_stride+1]
    
    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign
    
    add     r12, r12, r2, lsl #1
    sub     r12, r12, #2
    vld1.8 {q12}, [r12]                 // load src[x+src_stride-1]
    
    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign
    
    vadd.s8 q10, q12, q10               // edgetype
    
    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset
    
    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23
    
    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12
    
    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results
    
    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_45_rn
    vst1.8  {q10}, [r12]
    add     r9, #16
    b       loop_x_eo_45_rn
maskmove_eo_45_rn:
    sub     r6, r7, r10
    add     r6, r5, r6, lsl #4         // offset = 16*rownum
    vld1.32 {q15}, [r6]                 // load mask_rn
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]
loop_x_eo_45_end_rn:    
    sub     sp, sp, #72                 // reserve stack point
    ldmia   sp!, {r4-r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_45_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth,
 *  int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6
 ************************************************************************************************************************************/
function uavs3d_sao_eo_45_chroma_armv7
    stmdb sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    vpush {q4-q7}
    add sp, sp, #104                    // 4*10 + 16*4
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r7=bit_depth; r8=start_x_r0; r9=end_x_r0

    sub     r11, r9, r8
    and     r11, r11, #31
    sub     r10, r9, r11                // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov    d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte

    mov     r11, #0x00ff
    vdup.16 q7 , r11

    vmov.u8 q1 , #2                     // constant(save)

//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_45_chroma_r0:
    cmp     r11, r9
    bge     loop_x_eo_45_chroma_end_r0
    add     r12, r0, r11
    vld1.8  {q3, q4}, [r12]             // load src[x]    (save)
    vmovn.u16 d22, q3
    vmovn.u16 d23, q4
    sub     r12, r12, r2
    add     r12, r12, #2
    vld1.8  {q5, q6}, [r12]             // load src[x-src_stride+2]
    vmovn.u16 d20, q5
    vmovn.u16 d21, q6

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #4
    vld1.8  {q3, q4}, [r12]             // load src[x+src_stride-2]
    vmovn.u16 d24, q3
    vmovn.u16 d25, q4

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign

    vadd.s8 q10, q12, q10               // edgetype

    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results

    add     r12, r1, r11                // dst+x
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21

    cmp     r11, r10
    bge     maskmove_eo_45_chroma_r0
    vld1.64 {q3, q4}, [r12]
    vbif    q11, q3, q7
    vbif    q12, q4, q7
    vst1.8  {q11, q12}, [r12]
    add     r11, #32
    b       loop_x_eo_45_chroma_r0
maskmove_eo_45_chroma_r0:
    sub     r7, r9, r10
    add     r7, r5, r7, lsl #3          // offset = 16*rownum
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.64 {q4, q5}, [r12]
    vmovl.s8 q8, d30
    vmovl.s8 q9, d31
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q4, q8
    vbif    q12, q5, q9
    vst1.64 {q11, q12}, [r12]

loop_x_eo_45_chroma_end_r0:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #31
    add     r12, r5, r9, lsl #3
    vld1.32 {q15}, [r12]                // mask_r

    sub     r10, r8, r9                 // r10=end_x_r_16

    vmovl.s8 q8, d30
    vmovl.s8 q9, d31

    mov     r11, #1                     // y = 1
loop_y_eo_45_chroma_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_45_chroma_r:
    add     r12, r0 , r9
    vld1.8  {q3, q4}, [r12]             // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #2
    vmovn.u16 d22, q3
    vmovn.u16 d23, q4
    vld1.8  {q5, q6}, [r12]             // load src[x-src_stride+2]
    vmovn.u16 d20, q5
    vmovn.u16 d21, q6

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #4
    vld1.8 {q5, q6}, [r12]              // load src[x+src_stride-2]
    vmovn.u16 d24, q5
    vmovn.u16 d25, q6

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign

    vadd.s8 q10, q12, q10               // edgetype

    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    vmovl.u8    q11, d20
    vmovl.u8    q12, d21
    vld1.64 {q4, q5}, [r12]
    bge     maskmove_eo_45_chroma_r
    vbif    q11, q4, q7
    vbif    q12, q5, q7
    vst1.8  {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r8
    blt     loop_x_eo_45_chroma_r
    b       loop_x_eo_45_chroma_end_r
maskmove_eo_45_chroma_r:
    //- maskmove
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q4, q8
    vbif    q12, q5, q9
    vst1.8  {q11, q12}, [r12]

loop_x_eo_45_chroma_end_r:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

    add     r11, #1                     // y++
    sub     r12, r6, #1
    cmp     r11, r12                    // y == mb_height - 1?
    bne     loop_y_eo_45_chroma_r

//-------------------------------last row--------------------------------
    ldmia   sp , {r6, r7}               // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #31
    sub     r10, r7, r8                 // r10=end_x_rn_16

    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_45_chroma_rn:
    cmp     r9 , r7
    bge     loop_x_eo_45_chroma_end_rn
    add     r12, r0 , r9
    vld1.8  {q3, q4}, [r12]             // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #2
    vmovn.u16 d22, q3
    vmovn.u16 d23, q4
    vld1.8    {q5, q6}, [r12]           // load src[x-src_stride+2]
    vmovn.u16 d20, q5
    vmovn.u16 d21, q6

    vmin.u8 q12, q10, q11
    vceq.u8 q13, q12, q10
    vceq.u8 q14, q12, q11
    vsub.s8 q10, q14, q13               // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #4
    vld1.8 {q5, q6}, [r12]              // load src[x+src_stride-2]
    vmovn.u16 d24, q5
    vmovn.u16 d25, q6

    vmin.u8 q13, q11, q12
    vceq.u8 q14, q13, q11
    vceq.u8 q13, q13, q12
    vsub.s8 q12, q14, q13               // rightsign

    vadd.s8 q10, q12, q10               // edgetype

    vadd.s8 q10, q10, q1                // generate look-up indexs
    vtbl.8  d24, {d0} , d20
    vtbl.8  d25, {d0} , d21             // get offset

    vmovl.s8 q13, d24
    vmovl.s8 q14, d25
    vmovl.u8 q10, d22                   // src[x] low 8 samples
    vmovl.u8 q12, d23

    vadd.s16 q13, q13, q10
    vadd.s16 q14, q14, q12

    vqmovun.s16 d20, q13
    vqmovun.s16 d21, q14                // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    vmovl.u8    q11, d20
    vmovl.u8    q12, d21
    vld1.64 {q4, q5}, [r12]
    bge     maskmove_eo_45_chroma_rn
    vbif    q11, q4, q7
    vbif    q12, q5, q7
    vst1.8  {q11, q12}, [r12]
    add     r9, #32
    b       loop_x_eo_45_chroma_rn
maskmove_eo_45_chroma_rn:
    sub     r6, r7, r10
    add     r6, r5, r6, lsl #3         // offset = 16*rownum
    vld1.32 {q15}, [r6]                 // load mask_rn
    vmovl.s8 q8, d30
    vmovl.s8 q9, d31
    vand     q8, q7
    vand     q9, q7
    vbif     q11, q4, q8
    vbif     q12, q5, q9
    vst1.8  {q11, q12}, [r12]
loop_x_eo_45_chroma_end_rn:
    sub     sp, sp, #136                // 10*4 + 16*4 + 7*4
    vpop    {q4-q7}
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_bo_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int *bind_ids, int mb_width, int mb_height)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, bind_ids->r5, mb_width->r6, mb_height->r7
 ************************************************************************************************************************************/
function uavs3d_sao_bo_armv7
    stmdb sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7}
    sub sp, sp, #40
    vpush {q4-q7}

    vld1.32 {q3}, [r5]
    vmovn.i32 d6, q3
    vmovn.i16 d6, q3
    vdup.8 q0, d6[0]
    vdup.8 q1, d6[1]
    vdup.8 q2, d6[2]
    vdup.8 q3, d6[3]

    vld1.32 {q8}, [r4]

    vmov    r9, r10, d16
    vmov    r11, r12, d17
    vdup.8  q4, r9                      // offset[0]
    vdup.8  q5, r10                     // offset[1]
    vdup.8  q6, r11                     // offset[2]
    vdup.8  q7, r12                     // offset[3]

    mov     r5 , #0                     // y = 0
    sub     r10, r6, #12                // r10 = mb_width - 12
    mov     r12, #0
    mov     r9 , #-1

    vmov.i8 d30, #255
    vmov    d31, r9, r12                // mask="-1 repeat 12, 0, 0, 0, 0"

loop_y_bo:
    mov     r9, #0                      // x = 0
loop_x_bo:
    add     r12, r0, r9
    vld1.8  {q13}, [r12]                // load src[x]    (save)
    vshr.u8 q8, q13, #3
    
    vceq.i8 q9 , q8, q0
    vceq.i8 q10, q8, q1
    vceq.i8 q11, q8, q2
    vceq.i8 q12, q8, q3

    vand    q9 , q9 , q4
    vand    q10, q10, q5
    vand    q11, q11, q6
    vand    q12, q12, q7

    vorr    q9 , q9 , q10
    vorr    q11, q11, q12
    vorr    q9 , q9 , q11               // get offsets

    vmovl.s8 q10, d18
    vmovl.s8 q11, d19
    vmovl.u8 q12, d26                   // src[x] low 8 samples
    vmovl.u8 q13, d27
    
    vadd.s16 q10, q12, q10
    vadd.s16 q11, q11, q13
    
    vqmovun.s16 d20, q10
    vqmovun.s16 d21, q11                // results
    
    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_bo
    add     r9, #16
    vst1.8  {q10}, [r12]
    cmp     r9, r6
    blt     loop_x_bo
    b       loop_x_bo_end
maskmove_bo:
    //- maskmove
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]

loop_x_bo_end:
    add     r5, #1                      // y++
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

    cmp     r5, r7                      // y == mb_height?
    bne     loop_y_bo

    vpop    {q4-q7}
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_bo_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int *bind_ids, int mb_width, int mb_height)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, bind_ids->r5, mb_width->r6, mb_height->r7
 ************************************************************************************************************************************/
function uavs3d_sao_bo_chroma_armv7
    stmdb sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8}
    sub sp, sp, #40
    vpush {q4-q7}

    vld1.32 {q3}, [r5]              // bindid
    vmovn.i32 d6, q3
    vmovn.i16 d6, q3
    vdup.8 q0, d6[0]
    vdup.8 q1, d6[1]
    vdup.8 q2, d6[2]
    vdup.8 q3, d6[3]

    mov    r9, #0x00ff
    vdup.16 q8, r9                  // mask_uv

    vld1.32 {q9}, [r4]

    vmov    r9, r10, d18
    vmov    r11, r12, d19
    vdup.8  q4, r9                  // offset[0]
    vdup.8  q5, r10                 // offset[1]
    vdup.8  q6, r11                 // offset[2]
    vdup.8  q7, r12                 // offset[3]

    mov     r5 , #0                 // y = 0
    sub     r10, r6, #24
    mov     r12, #0
    mov     r9 , #-1
    vmov.i8 q14, #255
    vdup.32 d30, r9
    vdup.32 d31, r12                // mask="-1 repeat 12, 0, 0, 0, 0"

    vand    q14, q8
    vand    q15, q8

loop_y_bo_chroma:
    mov     r9, #0                  // x = 0
loop_x_bo_chroma:
    add     r12, r0 , r9
    vld1.8  {q9, q10}, [r12]        // load src[x]    (save)
    vmovn.u16 d26, q9
    vmovn.u16 d27, q10
    vshr.u8 q12, q13, #3

    vceq.i8 q9 , q12, q0
    vceq.i8 q10, q12, q1
    vceq.i8 q11, q12, q2
    vceq.i8 q12, q12, q3

    vand    q9 , q9 , q4
    vand    q10, q10, q5
    vand    q11, q11, q6
    vand    q12, q12, q7

    vorr    q9 , q9 , q10
    vorr    q11, q11, q12
    vorr    q9 , q9 , q11           // get offsets

    vmovl.s8 q10, d18
    vmovl.s8 q11, d19
    vmovl.u8 q12, d26               // src[x] low 8 samples
    vmovl.u8 q13, d27

    vadd.s16 q10, q12, q10
    vadd.s16 q11, q11, q13

    vqmovun.s16 d20, q10
    vqmovun.s16 d21, q11            // results

    add r12, r1, r9                 // dst+x
    cmp r9, r10
    vmovl.u8 q11, d20
    vmovl.u8 q12, d21
    vld1.64 {q9, q10}, [r12]
    bge     maskmove_bo_chroma
    vbif    q11, q9, q8
    vbif    q12, q10, q8
    add     r9, #32
    vst1.64 {q11, q12}, [r12]
    cmp     r9, r6
    blt     loop_x_bo_chroma
    b       loop_x_bo_chroma_end
maskmove_bo_chroma:
    // maskmove
    vbif    q11, q9, q14
    vbif    q12, q10, q15
    vst1.64 {q11, q12}, [r12]

loop_x_bo_chroma_end:
    add     r5, #1                  // y++
    add     r0, r0, r2              // src+=src_stride
    add     r1, r1, r3              // dst+=dst_stride

    cmp     r5, r7                  // y == mb_height?
    bne     loop_y_bo_chroma

    vpop    {q4-q7}
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
    mov     pc, lr

#else

/***********************************************************************************************************************************
*  void uavs3d_sao_eo_0_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height,
*                      char_t* mask, int bit_depth)
*  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, start_x->r5, end_x->r6, mb_height->r7, mask->r8, bit_depth->r9
************************************************************************************************************************************/
function uavs3d_sao_eo_0_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8, r9}
    sub sp, sp, #40

    vpush {q4, q5}

    lsl r2, #1
    lsl r3, #1

    sub r10, r6, r5
    mov r11, #7
    and r11, r11, r10
    add r12, r8 , r11, lsl#5
    vld1.32 {q15}, [r12]            // load mask: mask+((end_x - start_x) & 0x07)*16*sizeof(pel)

    sub r10, r6 , r11               // end_x_16 = end_x - ((end_x - start_x) & 0x0f)

    mov r11, #1
    lsl r5, #1
    lsl r6, #1
    lsl r10, #1
    lsl r11, r11, r9

    //------- set offset table: q0 -----------
    vld1.32 {q10}, [r4]             // load offset[0-3]
    ldr  r12, [r4, #16]             // load offset4
    mov  r8, #0
    vmov d4, r12, r8
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                // convert int32 to byte

    sub r11, #1

    vmov.u16 q1, #2                 // constant(save)
    vmov.u16 q5, #0
    vdup.u16 q4, r11                // max_pel
loop_y_eo_0:
    mov     r9, r5                  // x = start_x
loop_x_eo_0:
    add     r12, r0 , r9
    sub     r11, r12, #2
    vld1.16 {q11}, [r12]            // load src[x] (save)
    vld1.16 {q10}, [r11]            // load src[x-1]

    add     r12, r12, #2

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13          // leftsign

    vld1.16 {q12}, [r12]            // load src[x+1]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13          // rightsign

    vadd.s16 q10, q12, q10          // edgetype

    vadd.s16 q10, q10, q1           // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8 d24, {d0}, d20           // get offset

    vaddw.s8 q11, q11, d24          // src[x] + offset

    vmin.s16 q11, q11, q4
    vmax.s16 q11, q11, q5

    add     r12, r1, r9             // dst+x
    cmp     r9, r10
    beq     maskmove_eo_0
    add     r9, #16
    vst1.16  {q11}, [r12]
    cmp     r9, r6
    blt     loop_x_eo_0
    b       loop_x_eo_0_end

maskmove_eo_0:
    //- maskmove
    vld1.16  {q12}, [r12]           // load 8 pixels from dst+x
    vbif    q11, q12, q15
    vst1.16  {q11}, [r12]

loop_x_eo_0_end:
    subs    r7, #1                  // mb_height--
    add     r0, r0, r2              // src+=src_stride
    add     r1, r1, r3              // dst+=dst_stride
    bgt     loop_y_eo_0             // mb_height > 0 ?

    vpop    {q4, q5}
    ldmia   sp!, {r4-r12, pc}

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_0_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_x, int end_x, int mb_height,
 *                      char_t* mask, int bit_depth)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, start_x->r5, end_x->r6, mb_height->r7, mask->r8, bit_depth->r9
 ************************************************************************************************************************************/
function uavs3d_sao_eo_0_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8, r9}
    sub sp, sp, #40
    vpush {q4-q7}

    sub     r10, r6 , r5
    mov     r11, #7
    lsr     r10, #1
    and     r11, r11, r10
    add     r12, r8 , r11, lsl#5
    vld1.32 {q15}, [r12]            // load mask: mask+((end_x - start_x) & 0x07)*16*sizeof(pel)
    vmovl.s16 q7, d30
    vmovl.s16 q8, d31

    sub     r10, r6, r11, lsl #1    // r10 = end_x_16 = end_x - ((end_x - start_x) & 0x07)

    mov     r8, #1
    lsl     r8, #16
    sub     r8, #1                  // 0x0000ffff
    vdup.32 q6, r8                  // mask_uv: for uv interlace

    mov     r11, #1

    vand    q7, q6                  // mask for last cols
    vand    q8, q6
    lsl     r11, r9                 // 1 << bit_depth

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]             // load offset[0-3]
    ldr     r9, [r4, #16]           // load offset4
    mov     r8, #0
    vmov     d4, r9, r8
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                // convert int32 to byte

    sub     r11, #1
    lsl     r2, #1
    lsl     r3, #1
    lsl     r5, #1
    lsl     r6, #1
    lsl     r10, #1

    vmov.u16 q1, #2                 // constant(save)
    vmov.u16 q2, #0                 // min_pel
    vdup.u16 q3, r11                // max_pel

loop_y_eo_0_chroma:
    mov     r9, r5                  // x = start_x
loop_x_eo_0_chroma:
    add     r12, r0 , r9
    sub     r11, r12, #4
    vld1.16 {q4, q5}, [r12]         // load src[x]
    vld1.16 {q9, q10}, [r11]        // load src[x-2]
    vmovn.u32 d22, q4               // delete the other chroma
    vmovn.u32 d23, q5               // q11: src[x]
    vmovn.u32 d21, q10              // q10: src[x-2]
    vmovn.u32 d20, q9

    add     r12, r12, #4
    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13          // leftsign

    vld1.16 {q4, q5}, [r12]         // load src[x+2] to q12
    vmovn.u32 d24, q4
    vmovn.u32 d25, q5

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13          // rightsign

    vadd.s16 q10, q12, q10          // edgetype

    vadd.s16 q10, q10, q1           // generate look-up indexs

    vmovn.u16 d20, q10
    vtbl.8  d24, {d0}, d20         // get offset

    vaddw.s8 q10, q11, d24

    // clip
    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3

    add     r12, r1, r9             // dst + x
    vld1.64 {q4, q5}, [r12]         // load 32 pixels from dst+x
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    cmp     r9, r10
    beq     maskmove_eo_0_chroma
    vbif    q11, q4, q6
    vbif    q12, q5, q6
    vst1.8  {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r6
    blt     loop_x_eo_0_chroma
    b       loop_x_eo_0_chroma_end

maskmove_eo_0_chroma:
    //- maskmove
    vbif    q11, q4, q7
    vbif    q12, q5, q8
    vst1.8  {q11, q12}, [r12]

loop_x_eo_0_chroma_end:
    subs    r7, #1                  // mb_height--
    add     r0, r0, r2              // src += src_stride
    add     r1, r1, r3              // dst += dst_stride
    bgt     loop_y_eo_0_chroma

    vpop    {q4-q7}
    ldmia   sp!, {r4-r12, pc}

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_90_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width);
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, start_y->r5, end_y->r6, mb_width->r7, bit_depth->r8
 ************************************************************************************************************************************/
function uavs3d_sao_eo_90_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8}
    sub sp, sp, #40

    lsl     r2, #1
    lsl     r3, #1
    lsl     r7, #1

    mul     r10, r2, r5
    mul     r11, r3, r5
    add     r0 , r0, r10                // src -= start_y*src_stride
    add     r1 , r1, r11                // dst -= start_y*dst_stride

    sub     r10, r7, #15                // r10 = end_x_16 = mb_width - 15

    mov     r11, #1
    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r9, [r4, #16]               // load offset4
    mov     r12, #0
    vmov      d4, r9, r12
    vmov.u32  d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte

    lsl     r11, r8                     // 1 << bit_depth

    vmov.u16 q1 , #2                    // constant(save)

    sub     r8 , r6, r5                 // y = end_y - start_y
    sub     r11, #1
    mov     r12, #0
    mov     r9 , #-1

    vmov.u16 q2, #0                     // min_pel
    vdup.u16 q3, r11                    // max_pel

loop_y_eo_90:
    mov     r9, #0                      // x = 0
loop_x_eo_90:
    add     r12, r0 , r9
    vld1.16 {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    vld1.16 {q10}, [r12]                // load src[x-src_stride]

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add    r12, r12, r2, lsl #1
    vld1.16 {q12}, [r12]                // load src[x+src_stride]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs

    vmovn.u16 d20, q10
    vtbl.8 d24, {d0} , d20              // get offset

    vaddw.s8 q10, q11, d24

    vmin.s16 q10, q10, q3
    vmax.s16 q10, q10, q2

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_90
    vst1.8  {q10}, [r12]
    add     r9, #16
    cmp     r9, r7
    blt     loop_x_eo_90
    b       loop_x_eo_90_end
maskmove_eo_90:
    //- maskmove
    vst1.16 {d20}, [r12]

loop_x_eo_90_end:
    subs    r8, #1                      // y--
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    bgt     loop_y_eo_90

    ldmia   sp!, {r4-r12, pc}

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_90_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int start_y, int end_y, int mb_width);
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, start_y->r5, end_y->r6, mb_width->r7, bit_depth->r8
 ************************************************************************************************************************************/
function uavs3d_sao_eo_90_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8}
    sub sp, sp, #40
    vpush {q4-q6}

    mov     r12, #1
    lsl     r2 , #1
    lsl     r3 , #1
    lsl     r7 , #1
    mul     r10, r2 , r5
    mul     r11, r3 , r5
    add     r0 , r0 , r10           // src -= start_y*src_stride
    add     r1 , r1 , r11           // dst -= start_y*dst_stride
    lsl     r12, r8                 // 1 << bit_depth
    sub     r10, r7 , #31           // r10 = end_x_16 = mb_width - 31

    mov     r11, #1
    lsl     r11, #16
    sub     r11, #1                 // 0x0000ffff
    vdup.32 q6, r11

//----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]             // load offset[0-3]
    ldr     r9, [r4, #16]           // load offset4
    mov     r8, #0
    vmov      d4, r9, r8
    vmov.u32  d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                // convert int32 to byte

    sub     r12, #1
    vmov.u16 q1, #2                 // constant(save)
    vmov.u16 q2, #0                 // min_pel
    vdup.u16 q3, r12                // max_pel

    sub     r8, r6, r5              // y = end_y - start_y

loop_y_eo_90_chroma:
    mov     r9, #0                  // x = 0
loop_x_eo_90_chroma:
    add     r12, r0 , r9
    vld1.16 {q12, q13}, [r12]       // load src[x](save) to q11
    vmovn.u32 d22, q12
    vmovn.u32 d23, q13
    sub     r12, r12, r2
    vld1.16 {q4, q5}, [r12]         // load src[x - src_stride] to q10
    vmovn.u32 d20, q4
    vmovn.u32 d21, q5

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13          // leftsign

    add     r12, r12, r2, lsl #1
    vld1.16 {q4, q5}, [r12]         // load src[x + src_stride]
    vmovn.u32 d24, q4
    vmovn.u32 d25, q5

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13          // rightsign

    vadd.s16 q10, q12, q10          // edgetype

    vadd.s16 q10, q10, q1           // generate look-up indexs
    vmovn.s16 d20, q10

    vtbl.8  d24, {d0}, d20          // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3           // results

    add     r12, r1, r9             // dst+x
    cmp     r9, r10
    bge     maskmove_eo_90_chroma
    vld1.64 {q4, q5}, [r12]
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    vbif     q11, q4, q6
    vbif     q12, q5, q6
    vst1.16 {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r7
    blt     loop_x_eo_90_chroma
    b       loop_x_eo_90_chroma_end
maskmove_eo_90_chroma:
    //- maskmove
    vld1.64 {q4}, [r12]
    vmovl.u16 q11, d20
    vbif    q11, q4, q6
    vst1.16 {q11}, [r12]

loop_x_eo_90_chroma_end:
    subs    r8, #1                    // y--
    add     r0, r0, r2                // src+=src_stride
    add     r1, r1, r3                // dst+=dst_stride
    bgt     loop_y_eo_90_chroma

    vpop    {q4-q6}
    ldmia   sp!, {r4-r12, pc}


/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_135_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth, int start_x_r0,
 *  int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6, bit_depth->r7
 ************************************************************************************************************************************/
function uavs3d_sao_eo_135_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r4=offset; r5=mask; r6=mb_height; r7=bit_depth; r8=start_x_r0; r9=end_x_r0

    mov     r12, #1
    sub     r11, r9, r8
    and     r11, r11, #7
    sub     r10, r9, r11                // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x07);
    lsl     r7 , r12, r7                // 1 << bit_depth

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov     d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte

    sub r7, #1
    lsl r2, #1
    lsl r3, #1
    lsl r8, #1
    lsl r9, #1
    lsl r10, #1

    vmov.u16 q1, #2                     // constant(save)
    vmov.u16 q2, #0
    vdup.u16 q3, r7

//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_135_r0:
    cmp     r11, r9
    bge     loop_x_eo_135_end_r0
    add     r12, r0, r11
    vld1.16 {q11}, [r12]                // load src[x](save)
    sub     r12, r12, r2
    sub     r12, r12, #2
    vld1.16 {q10}, [r12]                // load src[x-src_stride-1]

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #4
    vld1.16 {q12}, [r12]                // load src[x+src_stride+1]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.s16 d20, q10

    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3

    add     r12, r1, r11                // dst+x
    cmp     r11, r10
    bge     maskmove_eo_135_r0
    vst1.16 {q10}, [r12]
    add     r11, #16
    b       loop_x_eo_135_r0
maskmove_eo_135_r0:
    sub     r7, r9, r10
    add     r7, r5, r7, lsl #4          // offset = 16*rownum*sizeof(pel)
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.16 {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.16 {q10}, [r12]

loop_x_eo_135_end_r0:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #7
    add     r12, r5, r9, lsl #5
    vld1.32 {q15}, [r12]                // mask_r

    sub     r10, r8, r9                 // r10=end_x_r_16

    sub     r11, r6, #2                 // y = mb_height - 2
    lsl     r7 , #1
    lsl     r8 , #1
    lsl     r10, #1

loop_y_eo_135_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_135_r:
    add     r12, r0, r9
    vld1.16 {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    sub     r12, r12, #2
    vld1.16 {q10}, [r12]                // load src[x-src_stride-1]

    add     r12, r12, r2, lsl #1
    add     r12, r12, #4

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    vld1.16 {q12}, [r12]                // load src[x+src_stride+1]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.s16 d20, q10
    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_r
    vst1.16 {q10}, [r12]
    add     r9, #16
    cmp     r9, r8
    blt     loop_x_eo_135_r
    b       loop_x_eo_135_end_r
maskmove_eo_135_r:
    //- maskmove
    vld1.16 {q12}, [r12]                // load 8 pixels from dst+x
    vbif    q10, q12, q15
    vst1.16 {q10}, [r12]

loop_x_eo_135_end_r:
    subs    r11, #1                     // y--
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    bgt     loop_y_eo_135_r

//-------------------------------last row--------------------------------
    ldmia   sp , {r6, r7}               // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #7
    sub     r10, r7, r8                 // r10=end_x_rn_16

    lsl     r6, #1
    lsl     r7, #1
    lsl     r10, #1
    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_135_rn:
    cmp     r9 , r7
    bge     loop_x_eo_135_end_rn
    add     r12, r0 , r9
    vld1.16 {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    sub     r12, r12, #2
    vld1.16 {q10}, [r12]                // load src[x-src_stride-1]

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #4
    vld1.16 {q12}, [r12]                // load src[x+src_stride+1]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.s16 d20, q10
    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_rn
    vst1.8  {q10}, [r12]
    add     r9, #16
    b       loop_x_eo_135_rn
maskmove_eo_135_rn:
    sub     r6, r7 , r10
    add     r6, r5 , r6, lsl #4         // offset = 16*rownum
    vld1.32 {q15}, [r6]                 // load mask_rn
    vld1.8  {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.8  {q10}, [r12]
loop_x_eo_135_end_rn:
    sub     sp, sp, #72                 // reserve stack point
    ldmia   sp!, {r4-r12, pc}


/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_135_chroma_armv7(pel* src, pel* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth,
 *  int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6
 ************************************************************************************************************************************/
function uavs3d_sao_eo_135_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4-q7}
    add sp, sp, #104
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r4=offset; r5=mask; r6=mb_height; r7=bit_depth; r8=start_x_r0; r9=end_x_r0

    mov     r12, #1
    sub     r11, r9, r8
    and     r11, r11, #15
    sub     r10, r9, r11                // r10: end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);
    lsl     r7, r12, r7                 // 1 << bit_depth

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov     d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte

    sub     r7, #1
    mov     r11, #1
    lsl     r11, #16
    sub     r11, #1                     // 0x0000ffff
    vdup.32 q7, r11

    lsl     r2, #1
    lsl     r3, #1
    lsl     r8, #1
    lsl     r9, #1
    lsl     r10, #1

    vmov.u16 q1, #2                     // constant(save)
    vmov.u16 q2, #0                     // min_pel
    vdup.u16 q3, r7                     // max_pel

//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_135_chroma_r0:
    cmp     r11, r9
    bge     loop_x_eo_135_chroma_end_r0
    add     r12, r0 , r11
    vld1.16 {q13, q14}, [r12]           // load src[x] (save) to q11
    sub     r12, r12, r2
    sub     r12, r12, #4
    vmovn.u32 d22, q13
    vmovn.u32 d23, q14
    vld1.16 {q5, q6}, [r12]             // load src[x-src_stride-2] to q10
    vmovn.u32 d20, q5
    vmovn.u32 d21, q6

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #8
    vld1.16 {q5, q6}, [r12]             // load src[x+src_stride+2]
    vmovn.u32 d24, q5
    vmovn.u32 d25, q6

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.s16 d20, q10
    vtbl.8  d24, {d0}, d20              // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3

    add     r12, r1, r11                // dst+x
    cmp     r11, r10
    bge     maskmove_eo_135_chroma_r0

    vld1.64 {q5, q6}, [r12]
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    vbif    q11, q5, q7
    vbif    q12, q6, q7
    vst1.16 {q11, q12}, [r12]
    add     r11, #32
    b       loop_x_eo_135_chroma_r0
maskmove_eo_135_chroma_r0:
    sub     r7, r9, r10
    add     r7, r5, r7, lsl #3          // offset = 16*rowid
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.64 {q5, q6}, [r12]
    vmovl.s16 q8, d30
    vmovl.s16 q9, d31
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q5, q8
    vbif    q12, q6, q9
    vst1.16 {q11, q12}, [r12]

loop_x_eo_135_chroma_end_r0:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #15
    add     r12, r5, r9, lsl #4
    vld1.32 {q15}, [r12]                // mask_r
    vmovl.s16 q8, d30
    vmovl.s16 q9, d31

    sub     r10, r8, r9                 // r10=end_x_r_16

    lsl     r7, #1
    lsl     r8, #1
    lsl     r10, #1
    sub     r11, r6, #2                 // y = mb_height - 2
loop_y_eo_135_chroma_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_135_chroma_r:
    add     r12, r0 , r9
    vld1.16 {q13, q14}, [r12]           // load src[x](save)
    vmovn.u32 d22, q13
    vmovn.u32 d23, q14
    sub     r12, r12, r2
    sub     r12, r12, #4
    vld1.16 {q5, q6}, [r12]             // load src[x-src_stride-2]
    vmovn.u32 d20, q5
    vmovn.u32 d21, q6

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #8
    vld1.16 {q5, q6}, [r12]             // load src[x+src_stride+4]
    vmovn.u32 d24, q5
    vmovn.u32 d25, q6

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_chroma_r
    vld1.64 {q5, q6}, [r12]
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    vbif    q11, q5, q7
    vbif    q12, q6, q7
    vst1.16 {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r8
    blt     loop_x_eo_135_chroma_r
    b       loop_x_eo_135_chroma_end_r
maskmove_eo_135_chroma_r:
    //- maskmove
    vld1.64 {q5, q6}, [r12]
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q5, q8
    vbif    q12, q6, q9
    vst1.16 {q11, q12}, [r12]

loop_x_eo_135_chroma_end_r:
    subs    r11, #1                     // y--
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    bgt     loop_y_eo_135_chroma_r

//-------------------------------last row--------------------------------
    ldmia   sp , {r6, r7}               // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #15
    sub     r10, r7, r8                 // r10=end_x_rn_16

    lsl     r6 , #1
    lsl     r7 , #1
    lsl     r10, #1
    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_135_chroma_rn:
    cmp     r9 , r7
    bge     loop_x_eo_135_chroma_end_rn
    add     r12, r0 , r9
    vld1.16 {q13, q14}, [r12]           // load src[x]    (save)
    vmovn.u32 d22, q13
    vmovn.u32 d23, q14
    sub     r12, r12, r2
    sub     r12, r12, #4
    vld1.16 {q5, q6}, [r12]             // load src[x-src_stride-2]
    vmovn.u32 d20, q5
    vmovn.u32 d21, q6

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    add     r12, r12, #8
    vld1.16 {q5, q6}, [r12]             // load src[x+src_stride+2]
    vmovn.u32 d24, q5
    vmovn.u32 d25, q6

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_135_chroma_rn
    vld1.64 {q4, q5}, [r12]
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    vbif    q11, q4, q7
    vbif    q12, q5, q7
    vst1.16 {q11, q12}, [r12]

    add     r9, #32
    b       loop_x_eo_135_chroma_rn
maskmove_eo_135_chroma_rn:
    sub     r6, r7, r10
    add     r6, r5, r6, lsl #3          // offset = 16*rownum
    vld1.32 {q15}, [r6]                 // load mask_rn
    vld1.64 {q4, q5}, [r12]
    vmovl.s16 q8, d30
    vmovl.s16 q9, d31
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q4, q8
    vbif    q12, q5, q9
    vst1.64 {q11, q12}, [r12]
loop_x_eo_135_chroma_end_rn:
    sub     sp, sp, #136                // reserve stack point
    vpop    {q4-q7}
    ldmia   sp!, {r4-r12, pc}

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_45_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth
 *  int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6
 ************************************************************************************************************************************/
function uavs3d_sao_eo_45_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r7=bit_depth; r8=start_x_r0; r9=end_x_r0

    mov     r12, #1
    sub     r11, r9, r8
    and     r11, r11, #7
    sub     r10, r9, r11                // r10:end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x07);
    lsl     r7 , r12, r7                // 1 << bit_depth

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov     d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte
    sub     r7, #1
    lsl     r2, #1
    lsl     r3, #1
    lsl     r8, #1
    lsl     r9, #1
    lsl     r10, #1
    vmov.u16 q1, #2                     // constant(save)
    vmov.u16 q2, #0
    vdup.u16 q3, r7

//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_45_r0:
    cmp     r11, r9
    bge     loop_x_eo_45_end_r0
    add     r12, r0, r11
    vld1.16 {q11}, [r12]                // load src[x] (save)
    sub     r12, r12, r2
    add     r12, r12, #2
    vld1.16 {q10}, [r12]                // load src[x-src_stride+1]

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #4
    vld1.16 {q12}, [r12]                // load src[x+src_stride-1]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r11                // dst+x
    cmp     r11, r10
    bge     maskmove_eo_45_r0
    vst1.16 {q10}, [r12]
    add     r11, #16
    b       loop_x_eo_45_r0
maskmove_eo_45_r0:
    sub     r7, r9, r10
    add     r7, r5 , r7, lsl #4         // offset = 16*rownum
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.16 {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.16 {q10}, [r12]

loop_x_eo_45_end_r0:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #7
    add     r12, r5, r9, lsl #5
    vld1.32 {q15}, [r12]                // mask_r

    sub     r10, r8, r9                 // r10=end_x_r_16

    lsl     r7, #1
    lsl     r8, #1
    lsl     r10, #1
    sub     r11, r6, #2                 // y = mb_height - 2
loop_y_eo_45_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_45_r:
    add     r12, r0 , r9
    vld1.16 {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #2
    vld1.16 {q10}, [r12]                // load src[x-src_stride+1]

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #4
    vld1.16 {q12}, [r12]                // load src[x+src_stride-1]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_45_r
    add     r9, #16
    vst1.16 {q10}, [r12]
    cmp     r9, r8
    blt     loop_x_eo_45_r
    b       loop_x_eo_45_end_r
maskmove_eo_45_r:
    //- maskmove
    vld1.16 {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.16 {q10}, [r12]

loop_x_eo_45_end_r:
    subs    r11, #1                     // y--
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    bgt     loop_y_eo_45_r

//-------------------------------last row--------------------------------
    ldmia   sp , {r6, r7}               // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #7
    sub     r10, r7, r8                 // r10=end_x_rn_16

    lsl     r6, #1
    lsl     r7, #1
    lsl     r10, #1
    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_45_rn:
    cmp     r9 , r7
    bge     loop_x_eo_45_end_rn
    add     r12, r0 , r9
    vld1.16 {q11}, [r12]                // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #2
    vld1.16 {q10}, [r12]                // load src[x-src_stride+1]

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #4
    vld1.16 {q12}, [r12]                // load src[x+src_stride-1]

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0}, d20              // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_eo_45_rn
    vst1.16 {q10}, [r12]
    add     r9, #16
    b       loop_x_eo_45_rn
maskmove_eo_45_rn:
    sub     r6, r7, r10
    add     r6, r5, r6, lsl #4         // offset = 16*rownum
    vld1.32 {q15}, [r6]                 // load mask_rn
    vld1.16 {q12}, [r12]                // load 16 pixels from dst+x
    vbif    q10, q12, q15
    vst1.16 {q10}, [r12]
loop_x_eo_45_end_rn:
    sub     sp, sp, #72                 // reserve stack point
    ldmia   sp!, {r4-r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_eo_45_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, char_t* mask, int mb_height, int bit_depth,
 *  int start_x_r0, int end_x_r0, int start_x_r, int end_x_r, int start_x_rn, int end_x_rn)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, mask->r5, mb_height->r6
 ************************************************************************************************************************************/
function uavs3d_sao_eo_45_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    vpush {q4-q7}
    add sp, sp, #104                    // 4*10 + 16*4
    ldmia sp!, {r4, r5, r6, r7, r8, r9} // r7=bit_depth; r8=start_x_r0; r9=end_x_r0

    mov     r12, #1
    sub     r11, r9, r8
    and     r11, r11, #15
    sub     r10, r9, r11                // end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);
    lsl     r7 , r12, r7                // 1 << bit_depth

    //----- set offset table: q0 -----------
    vld1.32 {q10}, [r4]                 // load offset[0-3]
    ldr     r11, [r4, #16]              // load offset4
    mov     r12, #0
    vmov    d4, r11, r12
    vmov.u32 d5, #0
    vmovn.s32 d0, q10
    vmovn.s32 d1, q2
    vmovn.s16 d0, q0                    // convert int32 to byte

    sub     r7, #1
    mov     r11, #1
    lsl     r11, #16
    sub     r11, #1                     // 0x0000ffff
    lsl     r8, #1
    lsl     r9, #1
    lsl     r2, #1
    lsl     r3, #1
    lsl     r10, #1
    vdup.32  q7, r11
    vmov.u16 q1, #2                     // constant(save)
    vmov.u16 q2, #0                     // min_pel
    vdup.u16 q3, r7                     // max_pel

//-------------------first row-------------------------
    mov     r11, r8                     // x = start_x_r0
loop_x_eo_45_chroma_r0:
    cmp     r11, r9
    bge     loop_x_eo_45_chroma_end_r0
    add     r12, r0, r11
    vld1.16 {q13, q14}, [r12]           // load src[x]    (save)
    vmovn.u32 d22, q13
    vmovn.u32 d23, q14
    sub     r12, r12, r2
    add     r12, r12, #4
    vld1.16 {q5, q6}, [r12]             // load src[x-src_stride+2]
    vmovn.u32 d20, q5
    vmovn.u32 d21, q6

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #8
    vld1.16 {q5, q6}, [r12]             // load src[x+src_stride-2]

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    vmovn.u32 d24, q5
    vmovn.u32 d25, q6

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0}, d20              // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r11                // dst+x
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21

    cmp     r11, r10
    bge     maskmove_eo_45_chroma_r0
    vld1.64 {q5, q6}, [r12]
    vbif    q11, q5, q7
    vbif    q12, q6, q7
    vst1.16 {q11, q12}, [r12]
    add     r11, #32
    b       loop_x_eo_45_chroma_r0
maskmove_eo_45_chroma_r0:
    sub     r7, r9, r10
    add     r7, r5, r7, lsl #3          // offset = 16*rownum
    vld1.32 {q15}, [r7]                 // load mask_r0
    vld1.64 {q5, q6}, [r12]
    vmovl.s16 q8, d30
    vmovl.s16 q9, d31
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q5, q8
    vbif    q12, q6, q9
    vst1.64 {q11, q12}, [r12]

loop_x_eo_45_chroma_end_r0:
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride

//------------------------------middle rows--------------------------------
    ldmia   sp!, {r7, r8}               // r7=start_x_r; r8=end_x_r
    sub     r9 , r8, r7
    and     r9 , r9, #15
    add     r12, r5, r9, lsl #4
    vld1.32 {q15}, [r12]                // mask_r

    sub     r10, r8, r9                 // r10=end_x_r_16

    vmovl.s16 q8, d30
    vmovl.s16 q9, d31
    lsl     r7, #1
    lsl     r8, #1
    lsl     r10, #1
    sub     r11, r6, #2                 // y = mb_height - 2
loop_y_eo_45_chroma_r:
    mov     r9, r7                      // x = start_x_r
loop_x_eo_45_chroma_r:
    add     r12, r0, r9
    vld1.16 {q13, q14}, [r12]           // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #4
    vmovn.u32 d22, q13
    vmovn.u32 d23, q14
    vld1.16 {q5, q6}, [r12]             // load src[x-src_stride+2]
    vmovn.u32 d20, q5
    vmovn.u32 d21, q6

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #8
    vld1.16 {q5, q6}, [r12]             // load src[x+src_stride-2]
    vmovn.u32 d24, q5
    vmovn.u32 d25, q6

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0} , d20             // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    vmovl.u16   q11, d20
    vmovl.u16   q12, d21
    vld1.64 {q5, q6}, [r12]
    bge     maskmove_eo_45_chroma_r
    vbif    q11, q5, q7
    vbif    q12, q6, q7
    vst1.16 {q11, q12}, [r12]
    add     r9, #32
    cmp     r9, r8
    blt     loop_x_eo_45_chroma_r
    b       loop_x_eo_45_chroma_end_r
maskmove_eo_45_chroma_r:
    //- maskmove
    vand    q8, q7
    vand    q9, q7
    vbif    q11, q5, q8
    vbif    q12, q6, q9
    vst1.16 {q11, q12}, [r12]

loop_x_eo_45_chroma_end_r:
    subs    r11, #1                     // y--
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    bgt     loop_y_eo_45_chroma_r

//-------------------------------last row--------------------------------
    ldmia   sp , {r6, r7}               // r6=start_x_rn; r7=end_x_rn;  don't update sp
    sub     r8 , r7, r6
    and     r8 , r8, #15
    sub     r10, r7, r8                 // r10=end_x_rn_16

    lsl     r6, #1
    lsl     r7, #1
    lsl     r10, #1
    mov     r9 , r6                     // x = start_x_rn
loop_x_eo_45_chroma_rn:
    cmp     r9 , r7
    bge     loop_x_eo_45_chroma_end_rn
    add     r12, r0, r9
    vld1.16 {q13, q14}, [r12]           // load src[x]    (save)
    sub     r12, r12, r2
    add     r12, r12, #4
    vmovn.u32 d22, q13
    vmovn.u32 d23, q14
    vld1.16   {q5, q6}, [r12]           // load src[x-src_stride+2]
    vmovn.u32 d20, q5
    vmovn.u32 d21, q6

    vmin.u16 q12, q10, q11
    vceq.u16 q13, q12, q10
    vceq.u16 q14, q12, q11
    vsub.s16 q10, q14, q13              // leftsign

    add     r12, r12, r2, lsl #1
    sub     r12, r12, #8
    vld1.16 {q5, q6}, [r12]             // load src[x+src_stride-2]
    vmovn.u32 d24, q5
    vmovn.u32 d25, q6

    vmin.u16 q13, q11, q12
    vceq.u16 q14, q13, q11
    vceq.u16 q13, q13, q12
    vsub.s16 q12, q14, q13              // rightsign

    vadd.s16 q10, q12, q10              // edgetype

    vadd.s16 q10, q10, q1               // generate look-up indexs
    vmovn.u16 d20, q10
    vtbl.8  d24, {d0}, d20              // get offset

    vaddw.s8 q10, q11, d24

    vmax.s16 q10, q10, q2
    vmin.s16 q10, q10, q3               // results

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    vmovl.u16   q11, d20
    vmovl.u16   q12, d21
    vld1.64 {q5, q6}, [r12]
    bge     maskmove_eo_45_chroma_rn
    vbif    q11, q5, q7
    vbif    q12, q6, q7
    vst1.16 {q11, q12}, [r12]
    add     r9, #32
    b       loop_x_eo_45_chroma_rn
maskmove_eo_45_chroma_rn:
    sub     r6, r7, r10
    add     r6, r5, r6, lsl #3         // offset = 16*rownum
    vld1.32 {q15}, [r6]                // load mask_rn
    vmovl.s16 q8, d30
    vmovl.s16 q9, d31
    vand     q8, q7
    vand     q9, q7
    vbif     q11, q5, q8
    vbif     q12, q6, q9
    vst1.16 {q11, q12}, [r12]
loop_x_eo_45_chroma_end_rn:
    sub     sp, sp, #136                // 10*4 + 16*4 + 7*4
    vpop    {q4-q7}
    ldmia   sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    mov     pc, lr

/***********************************************************************************************************************************
 *  void uavs3d_sao_bo_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int *bind_ids, int mb_width, int mb_height, int bit_depth)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, bind_ids->r5, mb_width->r6, mb_height->r7, bit_depth->r8
 ************************************************************************************************************************************/
function uavs3d_sao_bo_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8}
    sub sp, sp, #40
    vpush {q4-q7}

    mov     r9, #1
    lsl     r2, #1
    lsl     r3, #1
    lsl     r6, #1
    lsl     r8, r9, r8                  // 1 << bit_depth

    vld1.32 {q3}, [r5]
    vmovn.i32 d6, q3
    vdup.16 q0, d6[0]
    vdup.16 q1, d6[1]
    vdup.16 q2, d6[2]
    vdup.16 q3, d6[3]

    vld1.32 {q8}, [r4]

    sub     r8, #1
    vmov    r9, r10, d16
    vmov    r11, r12, d17

    vmov.u16 q14, #0                    // min_pel
    vdup.u16 q15, r8                    // max_pel

    vdup.16 q4, r9                      // offset[0]
    vdup.16 q5, r10                     // offset[1]
    vdup.16 q6, r11                     // offset[2]
    vdup.16 q7, r12                     // offset[3]

    sub     r10, r6, #15                // r10 = mb_width - 15

    cmp     r8, #255
    bgt     loop_y_bo_10bit
loop_y_bo:
    mov     r9, #0                      // x = 0
loop_x_bo:
    add     r12, r0, r9
    vld1.16 {q13}, [r12]                // load src[x] (save)
    vshr.u16 q8, q13, #3

    vceq.i16 q9 , q8, q0
    vceq.i16 q10, q8, q1
    vceq.i16 q11, q8, q2
    vceq.i16 q12, q8, q3

    vand    q9 , q9 , q4
    vand    q10, q10, q5
    vand    q11, q11, q6
    vand    q12, q12, q7

    vorr    q9 , q9 , q10
    vorr    q11, q11, q12
    vorr    q9 , q9 , q11               // get offsets

    vadd.s16 q10, q9, q13

    vmax.s16 q10, q10, q14
    vmin.s16 q10, q10, q15

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_bo
    add     r9, #16
    vst1.8  {q10}, [r12]
    cmp     r9, r6
    blt     loop_x_bo
    b       loop_x_bo_end
maskmove_bo:
    vst1.16 {d20}, [r12]

loop_x_bo_end:
    subs    r7, #1                      // y--
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    bgt     loop_y_bo
    b       sao_bo_end

loop_y_bo_10bit:
    mov     r9, #0                      // x = 0
loop_x_bo_10bit:
    add     r12, r0, r9
    vld1.16 {q13}, [r12]                // load src[x] (save)
    vshr.u16 q8, q13, #5

    vceq.i16 q9 , q8, q0
    vceq.i16 q10, q8, q1
    vceq.i16 q11, q8, q2
    vceq.i16 q12, q8, q3

    vand    q9 , q9 , q4
    vand    q10, q10, q5
    vand    q11, q11, q6
    vand    q12, q12, q7

    vorr    q9 , q9 , q10
    vorr    q11, q11, q12
    vorr    q9 , q9 , q11               // get offsets

    vadd.s16 q10, q9, q13

    vmax.s16 q10, q10, q14
    vmin.s16 q10, q10, q15

    add     r12, r1, r9                 // dst+x
    cmp     r9, r10
    bge     maskmove_bo_10bit
    add     r9, #16
    vst1.8  {q10}, [r12]
    cmp     r9, r6
    blt     loop_x_bo_10bit
    b       loop_x_bo_10bit_end
maskmove_bo_10bit:
    vst1.16 {d20}, [r12]

loop_x_bo_10bit_end:
    subs    r7, #1                      // y--
    add     r0, r0, r2                  // src+=src_stride
    add     r1, r1, r3                  // dst+=dst_stride
    bgt     loop_y_bo_10bit

sao_bo_end:
    vpop    {q4-q7}
    ldmia   sp!, {r4-r12, pc}

/***********************************************************************************************************************************
 *  void uavs3d_sao_bo_chroma_armv7(pel_t* src, pel_t* dst, int src_stride, int dst_stride, int* offset, int *bind_ids, int mb_width, int mb_height)
 *  src->r0, dst->r1, src_stride->r2, dst_stride->r3, offset->r4, bind_ids->r5, mb_width->r6, mb_height->r7, bit_depth->r8
 ************************************************************************************************************************************/
function uavs3d_sao_bo_chroma_armv7
    stmdb sp!, {r4-r12, lr}
    add sp, sp, #40
    ldmia sp, {r4, r5, r6, r7, r8}
    sub sp, sp, #40
    vpush {q4-q7}

    mov     r9, #1
    lsl     r2, #1
    lsl     r3, #1
    lsl     r6, #1
    lsl     r8, r9, r8              // 1 << bit_depth

    vld1.32 {q3}, [r5]              // bindid
    vmovn.i32 d6, q3
    vdup.16 q0, d6[0]
    vdup.16 q1, d6[1]
    vdup.16 q2, d6[2]
    vdup.16 q3, d6[3]

    sub     r8, #1
    mov     r9, #1
    lsl     r9, #16
    sub     r9, #1                  // 0x0000ffff
    vdup.32 q8, r9                  // mask_uv

    vld1.32 {q9}, [r4]

    vmov    r9, r10, d18
    vmov    r11, r12, d19
    vdup.16 q4, r9                  // offset[0]
    vdup.16 q5, r10                 // offset[1]
    vdup.16 q6, r11                 // offset[2]
    vdup.16 q7, r12                 // offset[3]

    vmov.u16 q14, #0
    vdup.u16 q15, r8

    sub     r10, r6, #31            // r10 = mb_width - 15

    cmp     r8, #255
    bgt     loop_y_bo_10bit_chroma

loop_y_bo_chroma:
    mov     r9, #0                  // x = 0
loop_x_bo_chroma:
    add     r12, r0 , r9
    vld1.16 {q9, q10}, [r12]        // load src[x]    (save)
    vmovn.u32 d26, q9
    vmovn.u32 d27, q10
    vshr.u16 q12, q13, #3

    vceq.i16 q9 , q12, q0
    vceq.i16 q10, q12, q1
    vceq.i16 q11, q12, q2
    vceq.i16 q12, q12, q3

    vand    q9 , q9 , q4
    vand    q10, q10, q5
    vand    q11, q11, q6
    vand    q12, q12, q7

    vorr    q9 , q9 , q10
    vorr    q11, q11, q12
    vorr    q9 , q9 , q11           // get offsets

    vadd.s16 q10, q9, q13

    vmax.s16 q10, q10, q14
    vmin.s16 q10, q10, q15          // results

    add r12, r1, r9                 // dst+x
    cmp r9, r10
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    bge     maskmove_bo_chroma
    vld1.64 {q9, q10}, [r12]
    vbif    q11, q9, q8
    vbif    q12, q10, q8
    add     r9, #32
    vst1.64 {q11, q12}, [r12]
    cmp     r9, r6
    blt     loop_x_bo_chroma
    b       loop_x_bo_chroma_end
maskmove_bo_chroma:
    // maskmove
    vld1.64 {q9}, [r12]
    vbif    q11, q9, q8
    vst1.64 {q11}, [r12]

loop_x_bo_chroma_end:
    subs    r7, #1                  // y--
    add     r0, r0, r2              // src+=src_stride
    add     r1, r1, r3              // dst+=dst_stride
    bgt     loop_y_bo_chroma
    b       sao_bo_chroma_end

loop_y_bo_10bit_chroma:
    mov     r9, #0                  // x = 0
loop_x_bo_10bit_chroma:
    add     r12, r0 , r9
    vld1.16 {q9, q10}, [r12]        // load src[x]    (save)
    vmovn.u32 d26, q9
    vmovn.u32 d27, q10
    vshr.u16 q12, q13, #5

    vceq.i16 q9 , q12, q0
    vceq.i16 q10, q12, q1
    vceq.i16 q11, q12, q2
    vceq.i16 q12, q12, q3

    vand    q9 , q9 , q4
    vand    q10, q10, q5
    vand    q11, q11, q6
    vand    q12, q12, q7

    vorr    q9 , q9 , q10
    vorr    q11, q11, q12
    vorr    q9 , q9 , q11           // get offsets

    vadd.s16 q10, q9, q13

    vmax.s16 q10, q10, q14
    vmin.s16 q10, q10, q15          // results

    add r12, r1, r9                 // dst+x
    cmp r9, r10
    vmovl.u16 q11, d20
    vmovl.u16 q12, d21
    bge     maskmove_bo_10bit_chroma
    vld1.64 {q9, q10}, [r12]
    vbif    q11, q9, q8
    vbif    q12, q10, q8
    add     r9, #32
    vst1.64 {q11, q12}, [r12]
    cmp     r9, r6
    blt     loop_x_bo_10bit_chroma
    b       loop_x_bo_10bit_chroma_end
maskmove_bo_10bit_chroma:
    // maskmove
    vld1.64 {q9}, [r12]
    vbif    q11, q9, q8
    vst1.64 {q11}, [r12]

loop_x_bo_10bit_chroma_end:
    subs    r7, #1                  // y--
    add     r0, r0, r2              // src+=src_stride
    add     r1, r1, r3              // dst+=dst_stride
    bgt     loop_y_bo_10bit_chroma
sao_bo_chroma_end:
    vpop    {q4-q7}
    ldmia   sp!, {r4-r12, pc}

#endif

#endif
