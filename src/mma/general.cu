#include <cuda_runtime.h>

#include "../common/cu_commons.h"
#include "../cuda_threads/include.h"
#include "../cuda_kernels/handles.h"
#include "../tensor/include.h"
#include "general.h"

using namespace nvcuda;



extern "C" float matmul_backward(Scope_Struct *scope_struct, void *inp, void *weight, void *dinp, void *dw, void *dout, int B, int C, int OC) {

  float one = 1.0f, zero = 0.0f;
  int tid = scope_struct->thread_id;
  cudaStream_t stream = ThreadsStream[tid];
  // std::cout << "matmul backward " << B << ", C " << C << ", OC " << OC << "\n";


  // &one - &zero: reset
  // &one - &one: +=
  // backwad to dx
  cublasCheck(cublasGemmEx(cublas_handle, CUBLAS_OP_N, CUBLAS_OP_N, C, B, OC, &one,
            *(float**)weight, CUBLAS_LOWP, C, *(float**)dout, CUBLAS_LOWP, OC, &one,
            *(float**)dinp, CUBLAS_LOWP, C, cublas_compute, CUBLAS_GEMM_DEFAULT_TENSOR_OP));


  // backward to weight, uses += in the backward pass (accumulate the gradient) by setting alpha=one
  cublasCheck(cublasGemmEx(cublas_handle, CUBLAS_OP_N, CUBLAS_OP_T, C, OC, B, &one,
            *(float**)inp, CUBLAS_LOWP, C, *(float**)dout, CUBLAS_LOWP, OC, &one,
            *(float**)dw, CUBLAS_LOWP, C, cublas_compute, CUBLAS_GEMM_DEFAULT_TENSOR_OP));




  /*
  cudaStream_t dx_stream;
  cudaStreamCreate(&dx_stream);

  dim3 block_size(TILE_SIZE, TILE_SIZE);
  dim3 grid_size(std::ceil(C/(float)TILE_SIZE), std::ceil(B/(float)TILE_SIZE));
  int shared_mem_size = 2*TILE_SIZE_SQ*sizeof(float);

  cudaStreamSynchronize(main_stream);

  mult_backwarddx<<<grid_size, block_size, shared_mem_size>>>(weight, dinp, dout, TILE_SIZE, TILE_SIZE_SQ, B, C, OC);

  RegisterEvent(dx_stream);


  dim3 grid_size2(std::ceil(C/(float)TILE_SIZE), std::ceil(OC/(float)TILE_SIZE));
  mult_backwarddw_acc<<<grid_size2, block_size, shared_mem_size>>>(inp, dw, dout, TILE_SIZE, TILE_SIZE_SQ, B, C, OC);



  //PrintTensorF(dw, OC, C);

  StreamAwaitStreamB(main_stream, dx_stream);
  cudaStreamDestroy(dx_stream);
  */





  /*
  float alpha = 1.0f, beta = 1.0f;
  using ColumnMajor = cutlass::layout::ColumnMajor;
  using RowMajor = cutlass::layout::RowMajor;

  using CutlassGemm_dx = cutlass::gemm::device::Gemm<float,
                                RowMajor,
                                float,
                                RowMajor,
                                float,
                                RowMajor>;

  CutlassGemm_dx gemm_operator_dx;

  CutlassGemm_dx::Arguments args({B, C, OC},
            {dout, OC},
            {weight, C},
            {dinp, C},
            {dinp, C},
            {alpha, beta});
            
  gemm_operator_dx(main_stream);
  gemm_operator_dx(args);




  using ColumnMajor = cutlass::layout::ColumnMajor;
  using RowMajor = cutlass::layout::RowMajor;

  using CutlassGemm_dw = cutlass::gemm::device::Gemm<float,
                                ColumnMajor,
                                float,
                                RowMajor,
                                float,
                                RowMajor>;

  CutlassGemm_dw gemm_operator_dw;

  CutlassGemm_dw::Arguments args_dw({OC, C, B},
            {dout, OC},
            {inp, C},
            {dw, C},
            {dw, C},
            {alpha, beta});
            
  gemm_operator_dw(main_stream);
  gemm_operator_dw(args_dw);
  */
  return 0;
}

void matmul_forward(float* out,
                     float* inp, float* W,
                     int B, int C, int OC, int thread_id) {
        
  const float alpha = 1.0f;
  const float beta = 0.0f;
  

  int tid = thread_id;
  cudaStream_t stream = ThreadsStream[tid];


  if (thread_id==0) {
    cublasCheck(cublasSgemm(cublas_handle, CUBLAS_OP_T, CUBLAS_OP_N, OC, B, C, &alpha, W, C, inp, C, &beta, out, OC));
    // constexpr int num_warps_x{4};
    // constexpr int num_warps_y{4};
    
    // constexpr int WMMA_T{16};
    // dim3 block_size(num_warps_x * WARP_SIZE, num_warps_y);
    // dim3 grid_size(std::ceil((OC + (num_warps_x*WMMA_T - 1)) / (float)(num_warps_x*WMMA_T)), std::ceil((B + (num_warps_y*WMMA_T - 1)) / (float)(num_warps_y*WMMA_T)));

    // int shared_mem_size = num_warps_y*WMMA_T*WMMA_T*num_warps_x*sizeof(float);
    
    // wmma_mult_kernel<WMMA_T,num_warps_x,num_warps_y><<<grid_size, block_size, shared_mem_size, stream>>>(inp, W, out, B, C, OC);

  } else {
    // dim3 block_size(TILE_SIZE, TILE_SIZE);
    // dim3 grid_size(std::ceil(OC/(float)TILE_SIZE), std::ceil(B/(float)TILE_SIZE));
    // int shared_mem_size = 2*TILE_SIZE*TILE_SIZE*sizeof(float);

    // mult_kernel<<<grid_size, block_size, shared_mem_size>>>(inp, W, out, TILE_SIZE, TILE_SIZE*TILE_SIZE, B, C, OC);
  }
  
  
  

  /*
  using ColumnMajor = cutlass::layout::ColumnMajor;
  using RowMajor = cutlass::layout::RowMajor;

  using CutlassGemm = cutlass::gemm::device::Gemm<float,
                                                  RowMajor,
                                                  float,
                                                  ColumnMajor,
                                                  float,
                                                  RowMajor>;
  CutlassGemm gemm_operator;

  CutlassGemm::Arguments args({B, OC, C},
                              {inp, C},
                              {weight, C},
                              {out, OC},
                              {out, OC},
                              {alpha, beta});
                              
  gemm_operator(main_stream);
  gemm_operator(args);
  */
    
  /* //bias
  if (bias != NULL) {
      int block_size = sqrt_block_size * sqrt_block_size;
      int grid_size = ceil_div(OC * B * T, block_size);
      add_bias<<<grid_size, block_size>>>(out, bias, B, T, OC);
  }
  */
}
