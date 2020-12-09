#include <stdio.h>
#include <com_def.h>

// NOTE: Only defined this flag on old non-AVX2 CPU like me.
//#define SIM_AVX2

#ifndef SIM_AVX2
    #include <immintrin.h>
#else
    #define SIMDE_ENABLE_NATIVE_ALIASES 
    #include <x86/avx2.h>
#endif

#define ITER    (1000)

// TODO: unnecessary code, copy from source tree because compile with intrinsic simulate
static void uavs3d_if_hor_chroma_w8_avx2(const pel *src, int i_src, pel *dst, int i_dst, int width, int height, const s8 *coeff, int max_val)
{
    const int offset = 32;
    const int shift = 6;

    __m256i mCoefy1_hor = _mm256_set1_epi16(*(s16*)coeff);
    __m256i mCoefy2_hor = _mm256_set1_epi16(*(s16*)(coeff + 2));
    __m256i mSwitch0 = _mm256_setr_epi8(0, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 7, 6, 8, 7, 9, 0, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 7, 6, 8, 7, 9);
    __m256i mSwitch1 = _mm256_setr_epi8(0+4, 2+4, 1+4, 3+4, 2+4, 4+4, 3+4, 5+4, 4+4, 6+4, 5+4, 7+4, 6+4, 8+4, 7+4, 9+4,
                                        0+4, 2+4, 1+4, 3+4, 2+4, 4+4, 3+4, 5+4, 4+4, 6+4, 5+4, 7+4, 6+4, 8+4, 7+4, 9+4);
    __m256i mAddShift = _mm256_set1_epi16(0x8000 >> shift);
    __m256i T0, T1, S0, R0, R1, sum;
    __m128i s0, s1;

    src -= 2;

    while (height > 0) {
        s0 = _mm_loadu_si128((__m128i*)(src));
        s1 = _mm_loadu_si128((__m128i*)(src + i_src));

        S0 = _mm256_set_m128i(s1, s0);

        R0 = _mm256_shuffle_epi8(S0, mSwitch0);      // 4 rows s0 and s1 
        R1 = _mm256_shuffle_epi8(S0, mSwitch1);

        T0 = _mm256_maddubs_epi16(R0, mCoefy1_hor); // 4x4: s0*c0 + s1*c1 
        T1 = _mm256_maddubs_epi16(R1, mCoefy2_hor);
        sum = _mm256_add_epi16(T0, T1);

        sum = _mm256_mulhrs_epi16(sum, mAddShift);

        s0 = _mm_packus_epi16(_mm256_castsi256_si128(sum), _mm256_extracti128_si256(sum, 1));
        _mm_storel_epi64((__m128i*)(dst), s0);
        _mm_storeh_pi((__m64*)(dst + i_dst), _mm_castsi128_ps(s0));

        height -= 2;
        src += i_src << 1;
        dst += i_dst << 1;
    }
}

static int test_if_hor_chroma_w8()
{
    int i, j, k;
    pel bufI[64 * 64];
    pel bufO[2][64 * 64];
    const int i_src = 64;
    const int i_dst = 32;
    const int width = 8;

    memset(bufO, 0xCD, sizeof(bufO));
    for(i = 0; i < 64*64; ++i) {
        bufI[i] = rand() & 0xFF;
    }

    for(i = 0; i < ITER; ++i) {
        const int height = (rand() % 32) * 2 + 2;
        for(j = 0; j < 16; ++j) {
            uavs3d_if_hor_chroma        (bufI, i_src, bufO[0], i_dst, width, height, g_tbl_mc_coeff_luma_hp[j], 255);
            uavs3d_if_hor_chroma_w8_avx2(bufI, i_src, bufO[1], i_dst, width, height, g_tbl_mc_coeff_luma_hp[j], 255);

            for(k = 0; k < 16; ++k) {
                if (memcmp(&bufO[0][k * i_dst], &bufO[1][k * i_dst], width * sizeof(pel))) {
                    fprintf(stderr, "mismatch on row %d\n", k);
                    return -1;
                }
            }
        }
    }

    return 0;
}

int main()
{
    int ret = 0;

    ret |= test_if_hor_chroma_w8();

    if(ret == 0) {
        printf("All passed.\n");
    }
    else {
        printf("Check failed.\n");
    }

    return ret;
}

