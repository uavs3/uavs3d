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

#include "def_arm64.S"

#if defined(__arm64__)

//void uavs3d_intra_pred_hor_uv_arm64(pel_t *src, pel_t *dst, int i_dst, int width, int height)
//src->x0, dst->x1, i_dst->x2, width->x3, height->x4
function uavs3d_intra_pred_hor_uv_arm64

    sub x0, x0, #6      // src[-3]

	//branch
    cmp w3, #8
    beq intra_pred_hor_uv_w8
    bgt intra_pred_hor_uv_w16x

intra_pred_hor_uv_w4:
    ld1 {v18.4h}, [x0]

    dup v0.4h, v18.h[3]
    dup v1.4h, v18.h[2]
    dup v2.4h, v18.h[1]
    dup v3.4h, v18.h[0]

    st1 {v0.4h}, [x1], x2          // store dst[x]
    st1 {v1.4h}, [x1], x2
    subs w4, w4, #4
    sub x0, x0, #8
    st1 {v2.4h}, [x1], x2
    st1 {v3.4h}, [x1], x2
    bgt intra_pred_hor_uv_w4

    b intra_pred_hor_uv_end

intra_pred_hor_uv_w8:
    ld1 {v18.4h}, [x0]

	dup v0.8h, v18.h[3]
    dup v1.8h, v18.h[2]
    dup v2.8h, v18.h[1]
    dup v3.8h, v18.h[0]

	st1 {v0.8h}, [x1], x2  		// store dst[x]
    st1 {v1.8h}, [x1], x2
    subs w4, w4, #4
    sub x0, x0, #8
    st1 {v2.8h}, [x1], x2
    st1 {v3.8h}, [x1], x2
    bgt intra_pred_hor_uv_w8

	b intra_pred_hor_uv_end

intra_pred_hor_uv_w16x:

    cmp w3, #32
    beq intra_pred_hor_uv_w32
    bgt intra_pred_hor_uv_w64

intra_pred_hor_uv_w16:
    ld1 {v16.4h}, [x0]

    dup v0.8h, v16.h[3]
    dup v2.8h, v16.h[2]
    dup v4.8h, v16.h[1]
    dup v6.8h, v16.h[0]
    sub x0, x0, #8

    mov v1.16b, v0.16b
    mov v3.16b, v2.16b
    mov v5.16b, v4.16b
    mov v7.16b, v6.16b

    subs w4, w4, #4
    st1 {v0.8h, v1.8h}, [x1], x2    // store dst[x]
    st1 {v2.8h, v3.8h}, [x1], x2
    st1 {v4.8h, v5.8h}, [x1], x2
    st1 {v6.8h, v7.8h}, [x1], x2

	bgt intra_pred_hor_uv_w16

	b intra_pred_hor_uv_end

intra_pred_hor_uv_w32:
    ld1 {v14.4h}, [x0]

    dup v0.8h, v14.h[3]
    dup v4.8h, v14.h[2]
    dup v18.8h, v14.h[1]
    dup v22.8h, v14.h[0]

    sub x0, x0, #8

    mov v1.16b, v0.16b
    mov v2.16b, v0.16b
    mov v3.16b, v0.16b
    mov v5.16b, v4.16b
    mov v6.16b, v4.16b
    mov v7.16b, v4.16b
    mov v19.16b, v18.16b
    mov v20.16b, v18.16b
    mov v21.16b, v18.16b
    mov v23.16b, v22.16b
    mov v24.16b, v22.16b
    mov v25.16b, v22.16b

	st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2  		// store dst[x]
    st1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v18.8h, v19.8h, v20.8h, v21.8h}, [x1], x2
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x1], x2
	bgt intra_pred_hor_uv_w32

    b intra_pred_hor_uv_end

intra_pred_hor_uv_w64:
    sub x2, x2, #64

    intra_pred_hor_uv_w64_y:
    ld1 {v24.4h}, [x0]

    dup v0.8h, v24.h[3]
    dup v4.8h, v24.h[2]
    dup v18.8h, v24.h[1]
    dup v22.8h, v24.h[0]

    sub x0, x0, #8

    mov v1.16b, v0.16b
    mov v2.16b, v0.16b
    mov v3.16b, v0.16b
    mov v5.16b, v4.16b
    mov v6.16b, v4.16b
    mov v7.16b, v4.16b
    mov v19.16b, v18.16b
    mov v20.16b, v18.16b
    mov v21.16b, v18.16b
    mov v23.16b, v22.16b
    mov v24.16b, v22.16b
    mov v25.16b, v22.16b

    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x1], #64
    st1 {v4.8h, v5.8h, v6.8h, v7.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v18.8h, v19.8h, v20.8h, v21.8h}, [x1], #64
    st1 {v18.8h, v19.8h, v20.8h, v21.8h}, [x1], x2
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x1], #64
    st1 {v22.8h, v23.8h, v24.8h, v25.8h}, [x1], x2

    bgt intra_pred_hor_uv_w64_y

intra_pred_hor_uv_end:

    ret

.macro dc_fillblock_w32_h8
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
.endm

.macro dc_fillblock_w64_h8
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
.endm

//void uavs3d_intra_pred_dc_uv_arm64(pel_t *src, pel_t *dst, int i_dst, int width, int height, int avail, int sample_bit_depth)
//src->x0, dst->x1, i_dst->x2, width->x3, height->x4, avail->x5, sample_bit_depth->x6
function uavs3d_intra_pred_dc_uv_arm64

    and w7, w5, #2          // left avail
    and w8, w5, #1          // up avail
    lsr w7, w7, #1

    and w9, w7, w8
    cmp w9, #0
    bne intra_pred_dc_uv_above_left

    cmp w8, #0
    bne intra_pred_dc_uv_above

    cmp w7, #0
    beq intra_pred_dc_uv_none

intra_pred_dc_uv_left:
    sub x10, x0, x4, lsl #1
    mov w7, w4
    b intra_pred_dc_uv_single_line
intra_pred_dc_uv_above:
    add x10, x0, #2
    mov w7, w3
intra_pred_dc_uv_single_line:
    cmp w7, #16
    beq intra_pred_dc_uv_1ref_w16
    bgt intra_pred_dc_uv_1ref_w32x

    cmp w7, #8
    beq intra_pred_dc_uv_1ref_w8

//intra_pred_dc_uv_1ref_w4:
    ld1 {v0.4h}, [x10]

    ext v1.8b, v0.8b, v0.8b, #4 // last 2UV
    uaddl v0.8h, v0.8b, v1.8b
    ext v2.8b, v0.8b, v0.8b, #4
    add v0.4h, v0.4h, v2.4h

    sqrshrun v0.8b, v0.8h, #2
    dup v0.8h, v0.h[0]

    b intra_pred_dc_uv_fillblock

intra_pred_dc_uv_1ref_w8:
    ld1 {v0.8h}, [x10]
    ext v1.16b, v0.16b, v0.16b, #8  // last 4UV
    uaddl v0.8h, v0.8b, v1.8b
    ext v1.16b, v0.16b, v0.16b, #8
    add v0.4h, v0.4h, v1.4h
    ext v2.8b, v0.8b, v0.8b, #4
    add v0.4h, v0.4h, v2.4h

    sqrshrun v0.8b, v0.8h, #3
    dup v0.8h, v0.h[0]

    b intra_pred_dc_uv_fillblock

intra_pred_dc_uv_1ref_w16:
    ld1 {v0.8h, v1.8h}, [x10]
    uaddl  v2.8h, v0.8b, v1.8b
    uaddl2 v3.8h, v0.16b, v1.16b
    add    v0.8h, v2.8h, v3.8h

    ext v1.16b, v0.16b, v0.16b, #8  // last 2UV
    add v0.4h, v0.4h, v1.4h
    ext v1.16b, v0.16b, v0.16b, #8
    add v0.4h, v0.4h, v1.4h
    ext v2.8b, v0.8b, v0.8b, #4
    add v0.4h, v0.4h, v2.4h

    sqrshrun v0.8b, v0.8h, #4
    dup v0.8h, v0.h[0]

    b intra_pred_dc_uv_fillblock

intra_pred_dc_uv_1ref_w32x:
    cmp w7, #64
    beq intra_pred_dc_uv_1ref_w64

    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x10]
    uaddl  v4.8h, v0.8b, v1.8b
    uaddl2 v5.8h, v0.16b, v1.16b
    uaddl  v6.8h, v2.8b, v3.8b
    uaddl2 v7.8h, v2.16b, v3.16b

    add  v4.8h, v4.8h, v5.8h
    add  v6.8h, v6.8h, v7.8h
    add  v0.8h, v4.8h, v6.8h

    ext v1.16b, v0.16b, v0.16b, #8  // last 2UV
    add v0.4h, v0.4h, v1.4h
    ext v2.8b, v0.8b, v0.8b, #4
    add v0.4h, v0.4h, v2.4h

    sqrshrun v0.8b, v0.8h, #5
    dup v0.8h, v0.h[0]

    b intra_pred_dc_uv_fillblock

intra_pred_dc_uv_1ref_w64:
    ld1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x10], #64
    ld1 {v20.8h, v21.8h, v22.8h, v23.8h}, [x10]

    uaddl  v4.8h, v0.8b, v1.8b
    uaddl2 v5.8h, v0.16b, v1.16b
    uaddl  v6.8h, v2.8b, v3.8b
    uaddl2 v7.8h, v2.16b, v3.16b
    uaddl  v16.8h, v20.8b, v21.8b
    uaddl2 v17.8h, v20.16b, v21.16b
    uaddl  v18.8h, v22.8b, v23.8b
    uaddl2 v19.8h, v22.16b, v23.16b

    add  v4.8h, v4.8h, v5.8h
    add  v6.8h, v6.8h, v7.8h
    add  v16.8h, v16.8h, v17.8h
    add  v18.8h, v18.8h, v19.8h
    add  v0.8h, v4.8h, v6.8h
    add  v1.8h, v16.8h, v18.8h
    add  v0.8h, v0.8h, v1.8h

    ext v1.16b, v0.16b, v0.16b, #8  // last 2UV
    add v0.4h, v0.4h, v1.4h
    ext v2.8b, v0.8b, v0.8b, #4
    add v0.4h, v0.4h, v2.4h

    sqrshrun v0.8b, v0.8h, #6
    dup v0.8h, v0.h[0]

    b intra_pred_dc_uv_fillblock

intra_pred_dc_uv_none:

    movi v0.16b, #128            // iDCValue = 1 << (sample_bit_depth - 1);
    b intra_pred_dc_uv_fillblock

intra_pred_dc_uv_above_left:

    add x10, x0, #2             // rsrc = src + 1;

    //branch
    cmp w3, #16
    beq intra_pred_dc_uv_above_left_w16
    bgt intra_pred_dc_uv_above_left_w32x

    cmp w3, #8
    beq intra_pred_dc_uv_above_left_w8

//intra_pred_dc_uv_above_left_w4:

    movi v0.8h, #0
    ld1 {v0.4h}, [x10]
    uxtl v0.8h, v0.8b
    b intra_pred_dc_uv_above_left_h

intra_pred_dc_uv_above_left_w8:
    movi v0.8h, #0
    ld1 {v0.4h, v1.4h}, [x10]
    uaddl v0.8h, v0.8b, v1.8b
    b intra_pred_dc_uv_above_left_h

intra_pred_dc_uv_above_left_w16:
    ld1 {v0.16b, v1.16b}, [x10]
    uaddl  v2.8h, v0.8b, v1.8b
    uaddl2 v3.8h, v0.16b, v1.16b
    add    v0.8h, v2.8h, v3.8h
    b intra_pred_dc_uv_above_left_h

intra_pred_dc_uv_above_left_w32x:
    cmp w3, #64
    beq intra_pred_dc_uv_above_left_w64

    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x10]
    uaddl  v4.8h, v0.8b, v1.8b
    uaddl2 v5.8h, v0.16b, v1.16b
    uaddl  v6.8h, v2.8b, v3.8b
    uaddl2 v7.8h, v2.16b, v3.16b

    add  v4.8h, v4.8h, v5.8h
    add  v6.8h, v6.8h, v7.8h
    add  v0.8h, v4.8h, v6.8h
    b intra_pred_dc_uv_above_left_h

intra_pred_dc_uv_above_left_w64:
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x10], #64
    ld1 {v4.16b, v5.16b, v6.16b, v7.16b}, [x10]
    uaddl  v16.8h, v0.8b, v1.8b
    uaddl2 v17.8h, v0.16b, v1.16b
    uaddl  v18.8h, v2.8b, v3.8b
    uaddl2 v19.8h, v2.16b, v3.16b
    uaddl  v20.8h, v4.8b, v5.8b
    uaddl2 v21.8h, v4.16b, v5.16b
    uaddl  v22.8h, v6.8b, v7.8b
    uaddl2 v23.8h, v6.16b, v7.16b

    add  v16.8h, v16.8h, v17.8h
    add  v18.8h, v18.8h, v19.8h
    add  v20.8h, v20.8h, v21.8h
    add  v22.8h, v22.8h, v23.8h

    add  v16.8h, v16.8h, v18.8h
    add  v20.8h, v20.8h, v22.8h
    add  v0.8h, v16.8h, v20.8h
    
intra_pred_dc_uv_above_left_h:

    //branch
    cmp w4, #16
    beq intra_pred_dc_uv_above_left_h16
    bgt intra_pred_dc_uv_above_left_h32x

    cmp w4, #8
    beq intra_pred_dc_uv_above_left_h8

//intra_pred_dc_uv_above_left_h4:
    sub  x10, x0, #8
    ld1 {v1.4h}, [x10]
    uaddw v0.8h, v0.8h, v1.8b
    b intra_pred_dc_uv_above_left_dcvalue

intra_pred_dc_uv_above_left_h8:
    sub  x10, x0, #16
    ld1 {v1.8b, v2.8b}, [x10]
    uaddl v1.8h, v1.8b, v2.8b
    add   v0.8h, v0.8h, v1.8h
    b intra_pred_dc_uv_above_left_dcvalue

intra_pred_dc_uv_above_left_h16:
    sub  x10, x0, #32
    ld1 {v1.16b, v2.16b}, [x10]
    uaddl  v3.8h, v1.8b, v2.8b
    uaddl2 v4.8h, v1.16b, v2.16b
    add    v3.8h, v3.8h, v4.8h
    add    v0.8h, v0.8h, v3.8h
    b intra_pred_dc_uv_above_left_dcvalue

intra_pred_dc_uv_above_left_h32x:
    cmp w4, #64
    beq intra_pred_dc_uv_above_left_h64

    sub  x10, x0, #64
    ld1 {v4.16b, v5.16b, v6.16b, v7.16b}, [x10]
    uaddl  v16.8h, v4.8b , v5.8b
    uaddl2 v17.8h, v4.16b, v5.16b
    uaddl  v18.8h, v6.8b , v7.8b
    uaddl2 v19.8h, v6.16b, v7.16b

    add  v2.8h, v16.8h, v17.8h
    add  v3.8h, v18.8h, v19.8h
    add  v2.8h, v2.8h, v3.8h
    add  v0.8h, v0.8h, v2.8h
    b intra_pred_dc_uv_above_left_dcvalue

intra_pred_dc_uv_above_left_h64:
    sub  x10, x0, #128
    ld1 {v24.16b, v25.16b, v26.16b, v27.16b}, [x10], #64
    ld1 {v4.16b, v5.16b, v6.16b, v7.16b}, [x10]
    uaddl  v16.8h, v24.8b, v25.8b
    uaddl2 v17.8h, v24.16b, v25.16b
    uaddl  v18.8h, v26.8b, v27.8b
    uaddl2 v19.8h, v26.16b, v27.16b
    uaddl  v20.8h, v4.8b, v5.8b
    uaddl2 v21.8h, v4.16b, v5.16b
    uaddl  v22.8h, v6.8b, v7.8b
    uaddl2 v23.8h, v6.16b, v7.16b

    add  v16.8h, v16.8h, v17.8h
    add  v18.8h, v18.8h, v19.8h
    add  v20.8h, v20.8h, v21.8h
    add  v22.8h, v22.8h, v23.8h

    add  v16.8h, v16.8h, v18.8h
    add  v20.8h, v20.8h, v22.8h
    add  v1.8h, v16.8h, v20.8h
    add  v0.8h, v0.8h, v1.8h
    
intra_pred_dc_uv_above_left_dcvalue:

    ext v1.16b, v0.16b, v0.16b, #8  // last 2UV
    add v0.4h, v0.4h, v1.4h
    ext v2.8b, v0.8b, v0.8b, #4
    add v0.4h, v0.4h, v2.4h

    // (dc + ((w + h) >> 1)) * (4096 / (w + h)) >> 12;
    add w10, w3, w4
    mov w11, #4096
    lsr w12, w10, #1                // ((w + h) >> 1)
    udiv w11, w11, w10              // (4096 / (w + h))

    umov w8, v0.h[0]
    umov w9, v0.h[1]
    add w8, w8, w12                 // dc += ((w + h) >> 1);
    add w9, w9, w12
    mul w8, w8, w11                 // dc = (dc * (4096 / (w + h))) >> 12;
    mul w9, w9, w11
    lsr w8, w8, #12
    lsr w9, w9, #12

    add w8, w8, w9, lsl #8
    dup v0.8h, w8

intra_pred_dc_uv_fillblock:

    //branch
    cmp w3, #16
    beq intra_pred_dc_uv_fillblock_w16
    bgt intra_pred_dc_uv_fillblock_w32x

    cmp w3, #8
    beq intra_pred_dc_uv_fillblock_w8

// intra_pred_dc_uv_fillblock_w4:

intra_pred_dc_uv_fillblock_w4_y:
    st1 {v0.4h}, [x1], x2       // store dst[x]
    st1 {v0.4h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.4h}, [x1], x2
    st1 {v0.4h}, [x1], x2
    bgt intra_pred_dc_uv_fillblock_w4_y
    b   intra_pred_dc_uv_end

intra_pred_dc_uv_fillblock_w8:

    st1 {v0.8h}, [x1], x2       // store dst[x]
    st1 {v0.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8h}, [x1], x2
    st1 {v0.8h}, [x1], x2
    bgt intra_pred_dc_uv_fillblock_w8
    b   intra_pred_dc_uv_end

intra_pred_dc_uv_fillblock_w16:
    mov v1.8h, v0.8h
intra_pred_dc_uv_fillblock_w16_y:
    st1 {v0.8h, v1.8h}, [x1], x2  // store dst[x]
    st1 {v0.8h, v1.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8h, v1.8h}, [x1], x2
    st1 {v0.8h, v1.8h}, [x1], x2
    bgt intra_pred_dc_uv_fillblock_w16_y
    b   intra_pred_dc_uv_end

intra_pred_dc_uv_fillblock_w32x:

    cmp w3, #64
    beq intra_pred_dc_uv_fillblock_w64

    mov v1.8h, v0.8h
    mov v2.8h, v0.8h
    mov v3.8h, v0.8h
intra_pred_dc_uv_fillblock_w32_y:
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2  // store dst[x]
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    subs w4, w4, #4
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    bgt intra_pred_dc_uv_fillblock_w32_y
    b   intra_pred_dc_uv_end

intra_pred_dc_uv_fillblock_w64:

    sub x2, x2, #64
    mov v1.8h, v0.8h
    mov v2.8h, v0.8h
    mov v3.8h, v0.8h
intra_pred_dc_uv_fillblock_w64_y:
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    subs w4, w4, #8
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], #64
    st1 {v0.8h, v1.8h, v2.8h, v3.8h}, [x1], x2
    bgt intra_pred_dc_uv_fillblock_w64_y
    
intra_pred_dc_uv_end:
    ret

tab_chroma_plane_mul_shift:
.byte 13, 17, 5, 11, 23, 7, 10, 11, 15, 19, 0, 0

tab_chroma_plane_coef:
.byte 16, 17, 14, 15, 12, 13, 10, 11, 8, 9, 6, 7, 4, 5, 2, 3, 0, 0, 1, 1, 2, 2, 3, 3

//void uavs3d_intra_pred_plane_uv_arm64(pel_t *src, pel_t *dst, int i_dst, int width, int height, int sample_bit_depth)
//src->x0, dst->x1, i_dst->x2, width->x3, height->x4, sample_bit_depth->x5
function uavs3d_intra_pred_plane_uv_arm64

    mov x9, #61
    clz x7, x3
    clz x8, x4
    adr x12, tab_chroma_plane_mul_shift
    sub x7, x9, x7                      // log2[width] - 2
    sub x8, x9, x8                      // log2[height] - 2
    add x10, x7, x12
    add x11, x8, x12

    ldrb w5, [x10]                      // im_h = ib_mult[log2[width] - 2]
    ldrb w6, [x11]                      // im_v = ib_mult[log2[height] - 2]

    add x10, x10, #5
    add x11, x11, #5
    ldrb w7, [x10]                      // is_h = ib_shift[log2[width] - 2]
    ldrb w8, [x11]                      // is_v = ib_shift[log2[height] - 2]

    dup v28.2s, w5
    dup v29.2s, w7
    dup v30.4s, w6
    dup v31.4s, w8
    mov v28.d[1], v30.d[0]              // im_h im_h im_v im_v
    mov v29.d[1], v31.d[0]              // is_h is_h is_v is_v

    lsr x9, x3, #1                      // w2
    cmp x9, #4
    blt chroma_plane_ih_lt4
    beq chroma_plane_ih_eq4

chroma_plane_ih_gt4:
    adr x10, tab_chroma_plane_coef
    ld1 {v17.8h}, [x10]                 // v17.16b: 16, 17, 14, 15, 12, 13, 10, 11, 8, 9, 6, 7, 4, 5, 2, 3
    ushr v16.16b, v17.16b, #1           // v16.16b: 8,8,7,7,....,1,1
    uxtl v18.8h, v16.8b
    uxtl2 v19.8h, v16.16b

    movi v0.8h, #0
    movi v5.16b, #2
    movi v20.8h, #0
    movi v21.8h, #8

    mov x8, x9
    add x5, x0, x3                      // src_h = src + width
    sub x6, x5, #16
    add x7, x5, #2                      // src_h + 2
    sub v17.16b, v17.16b, v5.16b

chroma_plane_ih_gt4_loop:

    ld1 {v1.8h}, [x7]
    ld1 {v3.8h}, [x6]

    tbl v2.16b, {v1.16b}, v17.16b

    usubl  v4.8h, v2.8b, v3.8b          // x * (src_h[x] - src_h[-x])
    usubl2 v5.8h, v2.16b, v3.16b

    mul    v2.8h, v4.8h, v18.8h
    mul    v3.8h, v5.8h, v19.8h

    saddl  v4.4s, v2.4h, v3.4h
    saddl2 v5.4s, v2.8h, v3.8h

    add v0.4s, v0.4s, v4.4s
    add v0.4s, v0.4s, v5.4s

    subs x8, x8, #8
    add v18.8h, v18.8h, v21.8h
    add v19.8h, v19.8h, v21.8h
    add x7, x7, #16
    sub x6, x6, #16
    bgt chroma_plane_ih_gt4_loop

    mov v1.d[0], v0.d[1]
    add v30.2s, v0.2s, v1.2s             // v0.2s: iHorU, iHorV

    b chroma_plane_iv

chroma_plane_ih_lt4:
    mov w6, #0x0202
    mov w7, #0x0101
    add w6, w6, w7, lsl #16
    mov v16.s[0], w6
    uxtl v17.8h, v16.8b                 // v13.4h: 2, 2, 1, 1(short)

    add x5, x0, x3                      // src_h = src + iW2*2
    sub x14, x5, #4
    ld1 {v1.8h}, [x14]                  // load src_h[-4][-3][-2][-1]...
    mov v2.h[0], v1.h[4]                // src_h[4][5][2][3]
    mov v2.h[1], v1.h[3]

    usubl v1.8h, v2.8b, v1.8b
    smull v0.4s, v1.4h, v17.4h          // x * (src_h[x] - src_h[-x])

    mov v1.d[0], v0.d[1]
    add v30.2s, v0.2s, v1.2s             // v0.2s: coef_hor_u, coef_hor_v
    b chroma_plane_iv

chroma_plane_ih_eq4:
    adr x10, tab_chroma_plane_coef
    add x10, x10, #8
    ld1 {v16.8b}, [x10]                 // v14.8b: 8, 9, 6, 7, 4, 5, 2, 3
    ushr v17.8b, v16.8b, #1
    uxtl v17.8h, v17.8b                 // v13.8h: 4, 4, 3, 3, 2, 2, 1, 1

    add x5, x0, x3                      // rsrc = src + iW2*2
    sub x6, x5, #8

    ld1 {v1.8h}, [x5]
    ld1 {v2.8b}, [x6]

    tbl v0.8b, {v1.16b}, v16.8b

    usubl v0.8h, v0.8b, v2.8b           // x * (rsrc[x] - rsrc[-x])
    mul   v0.8h, v0.8h, v17.8h

    mov v1.d[0], v0.d[1]
    saddl v0.4s, v0.4h, v1.4h
    mov v1.d[0], v0.d[1]
    add v30.2s, v0.2s, v1.2s

chroma_plane_iv:
    lsr x9, x4, #1                      // w2

    cmp x9, #4
    blt chroma_plane_iv_lt4
    beq chroma_plane_iv_eq4

chroma_plane_iv_gt4:
    adr x10, tab_chroma_plane_coef
    ld1 {v17.8h}, [x10]                 // v13.16b: 16, 17, 14, 15, 12, 13, 10, 11, 8, 9, 6, 7, 4, 5, 2, 3
    ushr v16.16b, v17.16b, #1           // v16.16b: 8,8,7,7,....,1,1
    uxtl v18.8h, v16.8b
    uxtl2 v19.8h, v16.16b

    movi v0.8h, #0
    movi v5.16b, #2
    movi v20.8h, #0
    movi v21.8h, #8

    mov x8, x9
    sub x5, x0, x4                      // src_v = src - height
    sub x6, x5, #16
    add x7, x5, #2                      // src_v + 2
    sub v17.16b, v17.16b, v5.16b

chroma_plane_iv_gt4_loop:

    ld1 {v1.8h}, [x7]                   // src_v[-16] - src_v[-1]
    ld1 {v3.8h}, [x6]                   // src_v[2-17]

    tbl v2.16b, {v1.16b}, v17.16b

    usubl  v4.8h, v3.8b, v2.8b          // y * (src_v[-y] - src_v[y])
    usubl2 v5.8h, v3.16b, v2.16b

    mul    v2.8h, v4.8h, v18.8h
    mul    v3.8h, v5.8h, v19.8h

    saddl  v4.4s, v2.4h, v3.4h
    saddl2 v5.4s, v2.8h, v3.8h

    add v0.4s, v0.4s, v4.4s
    add v0.4s, v0.4s, v5.4s

    subs x8, x8, #8
    add v18.8h, v18.8h, v21.8h
    add v19.8h, v19.8h, v21.8h
    add x7, x7, #16
    sub x6, x6, #16
    bgt chroma_plane_iv_gt4_loop

    mov v1.d[0], v0.d[1]
    add v31.2s, v0.2s, v1.2s            // v20.2s: coef_ver_u, coef_ver_v

    b chroma_plane_iv_end
chroma_plane_iv_lt4:
    mov w6, #0x0202
    mov w7, #0x0101
    add w6, w6, w7, lsl #16
    mov v16.s[0], w6
    uxtl v17.8h, v16.8b                 // v13.4h: 2, 2, 1, 1(short)

    sub x5, x0, x4                      // src_v = src - iH2*2
    sub x14, x5, #4
    ld1 {v1.8h}, [x14]                  // load src_v[-4][-3][-2][-1]...
    mov v2.h[0], v1.h[4]                // src_v[4][5][2][3]
    mov v2.h[1], v1.h[3]

    usubl v1.8h, v1.8b, v2.8b
    smull v0.4s, v1.4h, v17.4h          // y * (src_v[-y] - src_v[y])

    mov v1.d[0], v0.d[1]
    add v31.2s, v0.2s, v1.2s            // v0.2s: iHorU, iHorV

    b chroma_plane_iv_end

chroma_plane_iv_eq4:
    adr x10, tab_chroma_plane_coef
    add x10, x10, #8
    ld1 {v16.8b}, [x10]                 // v16.8b: 8, 9, 6, 7, 4, 5, 2, 3
    ushr v17.8b, v16.8b, #1
    uxtl v17.8h, v17.8b                 // v17.8h: 4, 4, 3, 3, 2, 2, 1, 1

    sub x5, x0, x4                      // rsrc = src + iH2*2
    sub x6, x5, #8

    ld1 {v1.8h}, [x5]
    ld1 {v2.8b}, [x6]

    tbl v0.8b, {v1.16b}, v16.8b

    usubl v0.8h, v2.8b, v0.8b           // y * (rsrc[-y] - rsrc[y])
    mul   v0.8h, v0.8h, v17.8h

    mov v1.d[0], v0.d[1]
    saddl v0.4s, v0.4h, v1.4h
    mov v1.d[0], v0.d[1]
    add v31.2s, v0.2s, v1.2s

chroma_plane_iv_end:

    sub x10, x0, x4, lsl #1             // iA = (src[-1 - (height - 1)] + src[1 + width - 1]) << 4
    add x11, x0, x3, lsl #1
    ldrh w6, [x10]
    ldrh w7, [x11]
    and w5, w6, #0xff
    and w8, w7, #0xff
    lsr w6, w6, #8
    lsr w7, w7, #8
    add w5, w5, w8
    add w6, w6, w7
    lsl w5, w5, #4                      // a_u
    lsl w6, w6, #4                      // a_v

    trn1 v0.2d, v30.2d, v31.2d          // v0.4s: iH_U iH_V iV_U iV_V
    shl v0.4s, v0.4s, #5                // iB = ((iH << 5) * im_h + (1 << (is_h - 1))) >> is_h
    mul v0.4s, v0.4s, v28.4s            // iC = ((iV << 5) * im_v + (1 << (is_v - 1))) >> is_v
    movi v3.4s, #1
    sub v2.4s, v29.4s, v3.4s
    ushl v1.4s, v3.4s, v2.4s
    add v0.4s, v0.4s, v1.4s
    neg v29.4s, v29.4s                  // shr only support shift immediate
    sshl v0.4s, v0.4s, v29.4s           // v0.4s: iBU, iBV, iCU, iCV

    lsr w8, w3, #1
    lsr w9, w4, #1

    mov v2.s[0], w5                     // iAU
    mov v2.s[1], w6                     // iAV
    dup v4.2s, w8
    dup v5.4s, w9
    mov v4.d[1], v5.d[0]                // v4.4s: iW2 iW2 iH2 iH2

    sub v1.4s, v4.4s, v3.4s             // iTmp = iA - (iH2 - 1) * iC - (iW2 - 1) * iB
    mul v1.4s, v0.4s, v1.4s
    ext v5.16b, v1.16b, v1.16b, #8
    add v1.2s, v1.2s, v5.2s             // (iH2 - 1) * iC + (iW2 - 1) * iB

    adr x10, tab_chroma_plane_coef
    add x10, x10, #16

    sub v1.2s, v2.2s, v1.2s
    dup v4.2d, v1.d[0]
    xtn v4.4h, v4.4s

    ld1 {v16.8b}, [x10]                 // v16.8b: 0, 0, 1, 1, 2, 2, 3, 3
    dup v31.2d, v4.d[0]                 // v31.8h: (iTmpU, iTmpV)x4

    uxtl v16.8h, v16.8b

    dup v28.2d, v0.d[0]                 // v28.4s: iBU, iBV, iBU, iBV
    dup v29.2d, v0.d[1]                 // v29.4s: iCU, iCV, iCU, iCV
    xtn v28.4h, v28.4s
    xtn v29.4h, v29.4s
    dup v28.2d, v28.d[0]                // v28.8h: iBU, iBV, iBU, iBV, iBU, iBV, iBU, iBV
    dup v29.2d, v29.d[0]                // v29.8h: iCU, iCV, iCU, iCV, iCU, iCV, iCU, iCV

    mul v27.8h, v28.8h, v16.8h
    add v31.8h, v27.8h, v31.8h          // temp_u temp_v

    cmp x3, #8
    beq chroma_plane_w8
    blt chroma_plane_w4

chroma_plane_gt8:
    cmp x3, #32
    beq chroma_plane_w32
    bgt chroma_plane_w64
    shl v28.8h, v28.8h, #2              // (iBU, iBV...)*4
chroma_plane_w16_y:
    add v3.8h, v31.8h, v28.8h
    sqrshrun v4.8b, v31.8h, #5
    add v2.8h, v3.8h, v28.8h
    sqrshrun v5.8b, v3.8h, #5

    add v3.8h, v2.8h, v28.8h
    sqrshrun v6.8b, v2.8h, #5
    sqrshrun v7.8b, v3.8h, #5

    subs x4, x4, #1
    st1 {v4.8b, v5.8b, v6.8b, v7.8b}, [x1], x2

    add v31.8h, v31.8h, v29.8h
    bgt chroma_plane_w16_y

    b chroma_plane_end

chroma_plane_w32:
    sub x2, x2, #32
    shl v30.8h, v28.8h, #3
    shl v28.8h, v28.8h, #2              // (iBU, iBV...)*4
chroma_plane_w32_y:
    add v2.8h, v31.8h, v28.8h
    add v3.8h, v31.8h, v30.8h
    sqrshrun v4.8b, v31.8h, #5
    sqrshrun v5.8b, v2.8h, #5
    sqrshrun v6.8b, v3.8h, #5
    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v7.8b, v2.8h, #5
    sqrshrun v16.8b, v3.8h, #5
    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v17.8b, v2.8h, #5
    add v2.8h, v2.8h, v30.8h
    sqrshrun v18.8b, v3.8h, #5
    sqrshrun v19.8b, v2.8h, #5
    st1 {v4.8b, v5.8b, v6.8b, v7.8b}, [x1], #32
    subs x4, x4, #1                     // height--
    st1 {v16.8b, v17.8b, v18.8b, v19.8b}, [x1], x2

    add v31.8h, v31.8h, v29.8h
    bgt chroma_plane_w32_y

    b chroma_plane_end

chroma_plane_w64:
    sub x2, x2, #96
    shl v30.8h, v28.8h, #3
    shl v28.8h, v28.8h, #2              // (iBU, iBV...)*4
chroma_plane_w64_y:
    add v2.8h, v31.8h, v28.8h
    add v3.8h, v31.8h, v30.8h
    sqrshrun v4.8b, v31.8h, #5
    sqrshrun v5.8b, v2.8h, #5
    sqrshrun v6.8b, v3.8h, #5

    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v7.8b, v2.8h, #5
    sqrshrun v16.8b, v3.8h, #5
    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v17.8b, v2.8h, #5
    sqrshrun v18.8b, v3.8h, #5
    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v19.8b, v2.8h, #5
    sqrshrun v20.8b, v3.8h, #5
    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v21.8b, v2.8h, #5
    sqrshrun v22.8b, v3.8h, #5
    st1 {v4.8b, v5.8b, v6.8b, v7.8b}, [x1], #32
    st1 {v16.8b, v17.8b, v18.8b, v19.8b}, [x1], #32
    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v23.8b, v2.8h, #5
    sqrshrun v24.8b, v3.8h, #5
    add v2.8h, v2.8h, v30.8h
    add v3.8h, v3.8h, v30.8h
    sqrshrun v25.8b, v2.8h, #5
    add v2.8h, v2.8h, v30.8h
    sqrshrun v26.8b, v3.8h, #5
    sqrshrun v27.8b, v2.8h, #5
    st1 {v20.8b, v21.8b, v22.8b, v23.8b}, [x1], #32
    subs x4, x4, #1
    st1 {v24.8b, v25.8b, v26.8b, v27.8b}, [x1], x2

    add v31.8h, v31.8h, v29.8h
    bgt chroma_plane_w64_y

    b chroma_plane_end

chroma_plane_w8:
    shl v28.8h, v28.8h, #2                  // (iBU, iBV...)*4
chroma_plane_w8_y:
    add v2.8h, v31.8h, v28.8h
    sqrshrun v4.8b, v31.8h, #5
    sqrshrun v5.8b, v2.8h, #5
    add v31.8h, v31.8h, v29.8h
    st1 {v4.8b, v5.8b}, [x1], x2

    add v2.8h, v31.8h, v28.8h
    sqrshrun v4.8b, v31.8h, #5
    sqrshrun v5.8b, v2.8h, #5
    add v31.8h, v31.8h, v29.8h
    subs x4, x4, #2
    st1 {v4.8b, v5.8b}, [x1], x2
    bgt chroma_plane_w8_y

chroma_plane_w4:
    add v30.8h, v31.8h, v29.8h
    sqrshrun v4.8b, v31.8h, #5
    sqrshrun v5.8b, v30.8h, #5
    st1 {v4.8b}, [x1], x2
    add v31.8h, v30.8h, v29.8h
    st1 {v5.8b}, [x1], x2
    add v30.8h, v31.8h, v29.8h

    subs x4, x4, #4                         // height -= 4
    sqrshrun v4.8b, v31.8h, #5
    sqrshrun v5.8b, v30.8h, #5
    add v31.8h, v30.8h, v29.8h
    st1 {v4.8b}, [x1], x2
    st1 {v5.8b}, [x1], x2
    bgt chroma_plane_w4

chroma_plane_end:
    ret

#endif


