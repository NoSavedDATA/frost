#include <vector>
#include <iostream>
#include <cuda_runtime.h>


#include "../../../src/nsk_cpp.h"


#include "../pool/include.h"
#include "../common/cu_commons.h"
#include "../cuda_threads/include.h"
#include "../mma/general.h"
#include "../tensor/include.h"
#include "activation_functions/activation_kernels.h"
#include "include.h"

extern "C" void *add_tensors(Scope_Struct *scope_struct, void *x, void *y, int dims) {
    int tid = scope_struct->thread_id;
    cudaStream_t stream = ThreadsStream[tid];
    void **z = allocate<void*>(scope_struct, 1, "float_pp");
    float *tensor_ptr = tarena.Allocate<float>(dims);
    *z = tensor_ptr;

    add_forward<<<(dims+255)/256, 256, 0, stream>>>(*((float**)z), *((float**)x), *((float**)y), dims);
    return (void*)z;
}

extern "C" float acc_tensors(Scope_Struct *scope_struct, void *x, void *y, int dims) {
    int tid = scope_struct->thread_id;
    cudaStream_t stream = ThreadsStream[tid];

    add_inplace<<<(dims+255)/256, 256, 0, stream>>>(*((float**)x), *((float**)y), dims);
    return 0;
}

extern "C" void *mma_tensors(Scope_Struct *scope_struct, void *x, void *y, int m, int n, int p) {
    int tid = scope_struct->thread_id;
    cudaStream_t stream = ThreadsStream[tid];

    void **z = allocate<void*>(scope_struct, 1, "float_pp");
    float *tensor_ptr = tarena.Allocate<float>(m*p);
    *z = tensor_ptr;

    matmul_forward(*(float**)z, *(float**)x, *(float**)y,
                  m, n, p, tid);

    return (void*)z;
}


extern "C" void *relu_k(Scope_Struct *scope_struct, void *x, int dims_prod) {
  int tid = scope_struct->thread_id;
  cudaStream_t stream = ThreadsStream[tid];

  int grid_size, block_size;
  CalculateGridAndBlockSizes(dims_prod, grid_size, block_size);
  float *out = tarena.Allocate<float>(dims_prod);
  
  relu_forward<<<grid_size, block_size, 0, stream>>>(*(float**)x, out, dims_prod);

  void **z = allocate<void*>(scope_struct, 1, "float_pp");
  *z = out;
  return (void*)z;
}
extern "C" int relu_backward_k(Scope_Struct *scope_struct,
                               void *y, void *dinp, void *dout,
                               int dims_prod) {
  int tid = scope_struct->thread_id;
  cudaStream_t stream = ThreadsStream[tid];

  int grid_size, block_size;
  CalculateGridAndBlockSizes(dims_prod, grid_size, block_size);
  
  relu_backward1<<<grid_size, block_size, 0, stream>>>(*(float**)y, *(float**)dinp, *(float**)dout, dims_prod);

  return 0;
}

extern "C" void *softmax_k(Scope_Struct *scope_struct, void *x, int M, int N) {
  int tid = scope_struct->thread_id;
  cudaStream_t stream = ThreadsStream[tid];
  int dims_prod = M*N;

  std::vector<int> grid_block_mem_sizes;
  grid_block_mem_sizes = CalculateGridAndBlockSizes(dims_prod);
  int grid_size  = M;
  int block_size = grid_block_mem_sizes[1];
  int shared_mem_size = 2 * block_size / 32 * sizeof(float);
  float *probs = tarena.Allocate<float>(dims_prod);
  
  softmax_forward_kernel4<<<grid_size, block_size, shared_mem_size, stream>>>(*(float**)x, probs, M, N);

  void **z = allocate<void*>(scope_struct, 1, "float_pp");
  *z = probs;
  return (void*)z;
}



static std::unordered_map<std::string, CUfunction> kernel_cache;
static std::mutex cache_mutex;

extern "C" void neve_gpu_launch(char *fn, char *ptx,
        int tid,
        int gx, int gy, int gz, int bx, int by, int bz,
        int smem,
        void **args) {

    cuInit(0);

    CUcontext ctx;
    cuCtxGetCurrent(&ctx);

    if (!ctx) {
        fprintf(stderr, "No active CUDA context\n");
        abort();
    }

    CUfunction kernel = nullptr;
    std::string cache_key = std::string(fn) + ptx;

    {
        std::lock_guard<std::mutex> lock(cache_mutex);
        auto it = kernel_cache.find(cache_key);
        
        if (it != kernel_cache.end()) {
            kernel = it->second; // Use cached kernel
        } else {
            std::cout << "NOT IN CACHE " << fn << "\n";
            CUmodule gpuModule;
            cuModuleLoadDataEx(&gpuModule, ptx, 0, nullptr, nullptr);
            
            CUresult res = cuModuleGetFunction(&kernel, gpuModule, fn);
            if (res != CUDA_SUCCESS) {
                const char *name;
                const char *str;

                cuGetErrorName(res, &name);
                cuGetErrorString(res, &str);

                std::cout << "LAUNCH ERROR" << "\n";
                printf("%s: %s\n", name, str);
                std::cout << ptx << "\n";
                abort();
            }
            
            // Save to cache (leak is prevented because we reuse this one module)
            kernel_cache[cache_key] = kernel; 
        }
    }


    CUresult res = cuLaunchKernel(
        kernel,
        gx, gy, gz,
        bx, by, bz,
        smem,
        ThreadsStream[tid],
        args,
        nullptr
    );


    if (res != CUDA_SUCCESS) {
        std::cout << "--KERNEL ERROR " << res << "\n";
        const char *name;
        const char *str;

        cuGetErrorName(res, &name);
        cuGetErrorString(res, &str);

        printf("%s: %s\n", name, str);
        abort();
        std::exit(0);
    }

}


extern "C" int smem_size_fn(Scope_Struct *ctx) {
  return deviceProp.sharedMemPerBlock;
  // return deviceProp.sharedMemPerBlockOptin;
}
