#pragma once


#include "../../tensor/include.h"
#include "../../cuda_threads/include.h"
#include "../activation_functions/include.h"
#include "../calculate_grids.h"
#include "regression_kernels.h"


extern "C" float mse_backward_kernel(Scope_Struct *scope_struct,
                 void *dloss,
                 void *y_hat, void *y,
                 int dims_prod) {
  //std::cout << "MSE Backward" << "\n";
  int tid = scope_struct->thread_id;
  cudaStream_t stream = ThreadsStream[tid];

  int grid_size, block_size, shared_mem_size;
  CalculateGridAndBlockSizes(dims_prod, grid_size, block_size);
  
  mse_kernel<<<grid_size, block_size, 0, stream>>>(*(float**)dloss, *(float**)y_hat, *(float**)y, dims_prod);
  return 0;
}

