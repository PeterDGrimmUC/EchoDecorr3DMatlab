#ifndef SIMD_ABSTRACTIONS_H_
#define SIMD_ABSTRACTIONS_H_

#if defined(__AVX512F__) || defined(__AVX2__) || defined(__ARM_NEON__)
#define use_simd true
#if defined(__ARM_NEON__)
#include <arm_neon.h>
#else
#include <immintrin.h>
#endif
#endif

#ifdef __AVX512F__
#define simd_reg_size 512

#elifdef __AVX2__
#define simd_reg_size 256

#elifdef __ARM_NEON__
#define simd_reg_size 128
#define simd_int_t int32x4_t
#define simd_ps_t float32x4_t
#define simd_pd_t float64x2_t

#define simd_add_ps vaddq_f32
#define simd_add_pd vaddq_f64

#define simd_add_int vaddq_s32
#define simd_and_int vandq_s32

#define simd_add_long vaddq_s64
#endif

#ifdef use_simd
#define bs_double simd_reg_size/sizeof(double)
#define bs_single simd_reg_size/sizeof(float)
#define bs_int simd_reg_size/sizeof(int)
#define bs_long simd_reg_size/sizeof(long int)
#define bs_byte simd_reg_size/8
#endif

#endif // SIMD_ABSTRACTIONS_H_
