
SHARED_LIBS := libix_solver.so

TARGETS := $(SHARED_LIBS)
all: $(TARGETS)

#0 hip as backend; 1 cuda as backend;
USE_CUDA := 0
ifeq ($(USE_CUDA), 1)
SRC_BACKEND_DIR := src/nvidia_detail
else
SRC_BACKEND_DIR := src/amd_detail
endif

# 0 relase, 1 debug
BUILD_TYPE ?= 0
ifeq ($(DEBUG), 1)
DEBUG_FLAG = -g
else
DEBUG_FLAG = -O3
endif

SRC_CXX := \
$(SRC_BACKEND_DIR)/hipsolver.cpp \
$(SRC_BACKEND_DIR)/hipsolver_compat.cpp \
$(SRC_BACKEND_DIR)/hipsolver_conversions.cpp \
$(SRC_BACKEND_DIR)/hipsolver_refactor.cpp \
src/common/hipsolver_compat_common.cpp

OBJ_CXX := $(SRC_CXX:.cpp=.o)

FC := gfortran
CXX_FLAGS := $(DEBUG_FLAG) -fPIC -Wall -fopenmp -std=c++17 -D__HIP_PLATFORM_AMD__ 
INC := -I./include -I./include/internal -I./src/include -I/opt/rocm/include
LD_FLAGS := -L/opt/rocm/lib  -lamdhip64 -lrocblas
#CXX := hipcc
CXX := g++

INSTALL_PREFIX := /opt/rocm

%.o: %.cpp
	$(CXX) $(CXX_FLAGS) $(INC) $< -c -o $@

$(SHARED_LIBS): $(OBJ_CXX)
	$(CXX) -shared $^ -o $@



.PHONY: clean
clean:
	rm -rf $(OBJ_CXX) $(TARGETS)


