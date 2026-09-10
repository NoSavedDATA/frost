#pragma once

#include <cublas_v2.h>
#include <cuda_fp16.h>
#include <mma.h>

#include "../frost/include.h"

using namespace nvcuda;





void matmul_forward(float* out,
                     float* inp, float* W,
                     int B, int C, int OC, int thread_id);
