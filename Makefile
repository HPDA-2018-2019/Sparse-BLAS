#compilers

#GLOBAL_PARAMETERS
VALUE_TYPE = double
#NUM_RUN = 1000

#ENVIRONMENT_PARAMETERS
CUDA_INSTALL_PATH ?= /usr/local/cuda
CUDA_SAMPLES_PATH ?= /usr/local/cuda/samples


#CUDA_PARAMETERS
NVCC_FLAGS = -O3  -w -m64 -gencode=arch=compute_60,code=compute_60 --default-stream per-thread
CUDA_INCLUDES = -I$(CUDA_INSTALL_PATH)/include -I$(CUDA_SAMPLES_PATH)/common/inc
CUDA_LIBS = -L$(CUDA_INSTALL_PATH)/lib64 -lcudart -lcusparse -Xcompiler -fopenmp 
INC = -I ../include

.PHONY: all lib test clean

.DEFAULT_GOAL := all

all: lib test

lib: dspmv_mgpu_v2.o dspmv_mgpu_v1.o dspmv_mgpu_baseline.o csr5_kernel.o spmv_helper.o

test: lib dspmv_test.o
	(cd test && nvcc -ccbin g++ $(NVCC_FLAGS) ../src/csr5_kernel.o ../src/spmv_helper.o dspmv_test.o ../src/dspmv_mgpu_baseline.o ../src/dspmv_mgpu_v1.o ../src/dspmv_mgpu_v2.o -o test_spmv $(INC) $(CUDA_INCLUDES) $(CUDA_LIBS) -D VALUE_TYPE=$(VALUE_TYPE) -D NUM_RUN=$(NUM_RUN))

dspmv_mgpu_v2.o: ./src/dspmv_mgpu_v2.cu 
	(cd src && nvcc -ccbin g++ -c $(NVCC_FLAGS) dspmv_mgpu_v2.cu $(INC) $(CUDA_INCLUDES) $(CUDA_LIBS))

dspmv_mgpu_v1.o: ./src/dspmv_mgpu_v1.cu 
	(cd src && nvcc -ccbin g++ -c $(NVCC_FLAGS) dspmv_mgpu_v1.cu $(INC) $(CUDA_INCLUDES) $(CUDA_LIBS))

dspmv_mgpu_baseline.o: ./src/dspmv_mgpu_baseline.cu 
	(cd src && nvcc -ccbin g++ -c $(NVCC_FLAGS) dspmv_mgpu_baseline.cu $(INC) $(CUDA_INCLUDES) $(CUDA_LIBS))

dspmv_test.o: ./test/dspmv_test.cu 
	(cd test && nvcc -ccbin g++ -c $(NVCC_FLAGS) dspmv_test.cu $(INC) $(CUDA_INCLUDES) $(CUDA_LIBS))

csr5_kernel.o: ./src/csr5_kernel.cu
	(cd src && nvcc -ccbin g++ -c $(NVCC_FLAGS) csr5_kernel.cu $(INC) $(CUDA_INCLUDES) $(CUDA_LIBS))

spmv_helper.o: ./src/spmv_helper.cu 
	(cd src && nvcc -ccbin g++ -c $(NVCC_FLAGS) spmv_helper.cu $(INC) $(CUDA_INCLUDES) $(CUDA_LIBS))

clean:
	(cd src && rm *.o)
	(cd test && rm *.o)
	(cd test && rm test_spmv)
