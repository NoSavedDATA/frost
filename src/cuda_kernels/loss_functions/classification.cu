#pragma once

#include <iostream>

#include "../../../src/nsk_cpp.h"

#include "../../cuda_threads/include.h"
#include "../../pool/include.h"
#include "../../tensor/include.h"
#include "../activation_functions/include.h"
#include "../calculate_grids.h"
#include "classification_kernels.h"

extern "C" float ce_backward_kernel(Scope_Struct *scope_struct,
                 void *dloss,
                 void *y_hat, void *y,
                 int M, int N) {
  int tid = scope_struct->thread_id;
  cudaStream_t stream = ThreadsStream[tid];
  int dims_prod = M*N;

  std::vector<int> grid_block_mem_sizes;
  grid_block_mem_sizes = CalculateGridAndBlockSizes(dims_prod);
  int grid_size  = M;
  int block_size = grid_block_mem_sizes[1];
  int shared_mem_size = 2 * block_size / 32 * sizeof(float);
  float *probs = tarena.Allocate<float>(dims_prod);

  softmax_forward_kernel4<<<grid_size, block_size, shared_mem_size, stream>>>(*(float**)y_hat, probs, M, N);
  CalculateGridAndBlockSizes(dims_prod, grid_size, block_size);
  crossentropy_idx_backward_kernel<<<grid_size, block_size, 0, stream>>>(*(float**)dloss, probs, *(float**)y, M, N);
  return 0;
}

