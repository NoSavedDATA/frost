
#include<string>
#include<vector>
#include<map>
#include<cstring>
#include<random>
#include<thread>
#include<cstdarg>

#include "../pool/include.h"
#include "../common/cu_commons.h"
#include "../cuda_kernels/calculate_grids.h"
#include "../cuda_threads/include.h"
#include "../tensor/include.h"
#include "../../src/nsk_cpp.h"
#include "include.h"


extern "C" void *zeros_cuda_pool(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate_pool(scope_struct, 8, data_name_to_type()["float_pp"]);
    float *tensor_ptr = tarena.Allocate<float>(size);

    cudaCheck(cudaMemsetAsync(tensor_ptr, 0, size*4, ThreadsStream[scope_struct->thread_id]));

    *ptr = tensor_ptr;
    return (void*)ptr;
}


extern "C" void *cupool(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate_pool(scope_struct, 8, data_name_to_type()["float_pp"]);
    float *tensor_ptr = tarena.Allocate<float>(size);
    *ptr = tensor_ptr;
    return (void*)ptr;
}




extern "C" void *randu_cpu(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_random_float_uniform(size);
    *ptr = tensor_cpu;
    return (void*)ptr;
}
extern "C" void *xavu_cuda(Scope_Struct *scope_struct, int size, int m, int n){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_xavier_uniform_float(size, m, n);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *xavu_relu_cuda(Scope_Struct *scope_struct, int size, int m, int n){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_xavier_uniform_float_relu(size, m, n);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *kaiming_cuda(Scope_Struct *scope_struct, int size, int m, int n, float scale){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_kaiming_uniform_float(size, m, n, scale);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *conv_w_cuda(Scope_Struct *scope_struct, int size, int m, int n, float scale){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_conv_kaiming_float(size, m, n, scale);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *randu_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_random_float_uniform(size);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *zeros_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate_pool(scope_struct, 8, data_name_to_type()["float_pp"]);
    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);

    cudaCheck(cudaMemsetAsync(tensor_ptr, 0, size*4, ThreadsStream[scope_struct->thread_id]));
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *ones_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);

    float *tensor_cpu = make_ones_float(size);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);

    // cudaCheck(cudaMemsetAsync(tensor_ptr, 0, size*4, ThreadsStream[scope_struct->thread_id]));
    *ptr = tensor_ptr;
    return (void*)ptr;
}


extern "C" void *randu_bf16_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "bf16_pp");
    uint16_t *tensor_cpu = make_random_bf16_uniform(size);

    uint16_t *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*2);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*2, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *zeros_bf16_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate_pool(scope_struct, 8, data_name_to_type()["bf16_pp"]);
    uint16_t *tensor_cpu = make_zeros_bf16(size);

    uint16_t *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*2);
    cudaCheck(cudaMemcpyAsync(tensor_ptr, tensor_cpu, size*2, cudaMemcpyHostToDevice, ThreadsStream[scope_struct->thread_id]));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}



extern "C" void float_pp_Clean_Up(void *ptr, int tid) {
    // std::cout << "" << ptr << "\n";
    // float *fptr = *(float**)ptr;
    // if (fptr)
    //     cudaFree(fptr);
}
extern "C" void float_cpu_Clean_Up(void *ptr, int tid) {
    // std::cout << "float cpu" << ptr << "\n";
    float *fptr = *(float**)ptr;
    if (fptr)
        cudaFree(fptr);
}


