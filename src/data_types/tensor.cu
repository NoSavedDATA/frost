
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
#include "../tensor/include.h"
#include "../../src/nsk_cpp.h"
#include "include.h"


extern "C" void *zeros_cuda_pool(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate_pool(scope_struct, 8, data_name_to_type()["float_pp"]);
    float *tensor_cpu = make_zeros_float(size);

    float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
    free(tensor_cpu);
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
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
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
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *kaiming_cuda(Scope_Struct *scope_struct, int size, int m, int n){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_kaiming_uniform_float(size, m, n);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *kaiming_relu_cuda(Scope_Struct *scope_struct, int size, int m, int n){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_kaiming_relu_uniform_float(size, m, n);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
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
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *zeros_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate_pool(scope_struct, 8, data_name_to_type()["float_pp"]);
    float *tensor_cpu = make_zeros_float(size);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *ones_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_ones_float(size);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*4);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*4, cudaMemcpyHostToDevice));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}


extern "C" void *randu_bf16_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate<char>(scope_struct, 8, "bf16_pp");
    uint16_t *tensor_cpu = make_random_bf16_uniform(size);

    uint16_t *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*2);
    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*2, cudaMemcpyHostToDevice));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}
extern "C" void *zeros_bf16_cuda(Scope_Struct *scope_struct, int size){
    void **ptr = (void**)allocate_pool(scope_struct, 8, data_name_to_type()["bf16_pp"]);
    uint16_t *tensor_cpu = make_zeros_bf16(size);

    uint16_t *tensor_ptr;
    cudaMalloc(&tensor_ptr, size*2);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, size*2, cudaMemcpyHostToDevice));
    free(tensor_cpu);
    *ptr = tensor_ptr;
    return (void*)ptr;
}





extern "C" void *xavu_conv(Scope_Struct *scope_struct, int m, int n, int ks, int ks2, int dims_prod) {
    void **ptr = (void**)allocate<char>(scope_struct, 8, "float_pp");
    float *tensor_cpu = make_xavier_uniform_float(dims_prod, m, n);

    float *tensor_ptr;
    cudaMalloc(&tensor_ptr, dims_prod*4);


    std::vector<float> h_filter;
    float *filter;
    for (std::size_t idx = 0; idx < m * n; ++idx) {
        // if (Init=="xavu_relu")
         filter = make_xavier_uniform_float_relu(ks*ks, ks*ks*m, ks*ks*n);
        // if (Init == "xavu_tanh")
        //  filter = make_xavier_uniform_float_tanh(ks*ks, ks*ks*m, ks*ks*n);
        // if (Init=="he_normal_relu")
        //  filter = make_he_normal_float_relu(ks*ks, ks*ks*m);
        // if (Init == "init_gpt")
        //  filter = make_gpt_init(ks*ks);
        // if (Init=="xavu")
        //  filter = make_xavier_uniform_float(ks*ks, ks*ks*m, ks*ks*n);
        // if (Init=="zeros")
        //  filter = make_zeros_float(ks*ks);
        // if (Init=="ones")
        //  filter = make_ones_float(ks*ks);
        // if (Init=="randu")
        //  filter = make_random_float_uniform(ks*ks);

        for (int i=0; i < ks*ks; i++)
         h_filter.emplace_back(filter[i]);

        delete[] filter;
        //for (const auto& val : filter) 
        //  h_filter.emplace_back(val);
    }

    cudaCheck(cudaMemcpy(tensor_ptr, h_filter.data(), dims_prod * sizeof(float), cudaMemcpyDefault));
  








    // float *tensor_ptr = tarena.Allocate<float>(size);
    cudaCheck(cudaMemcpy(tensor_ptr, tensor_cpu, dims_prod*4, cudaMemcpyHostToDevice));
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


