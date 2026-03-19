HIPCC ?= hipcc
AMD_ARCH ?= $(shell amdgpu-offload-arch 2>/dev/null | head -n 1)

ifeq ($(strip $(AMD_ARCH)),)
$(error AMD_ARCH is not set. Install amdgpu-offload-arch or run `make AMD_ARCH=gfx1100`)
endif

ifneq ($(filter gfx8% gfx9%,$(AMD_ARCH)),)
$(error Unsupported AMD_ARCH `$(AMD_ARCH)`. This port only supports wave32 RDNA targets (gfx10+))
endif

HIPFLAGS=-std=c++11 -O3 -x hip --offload-arch=$(AMD_ARCH) -mno-wavefrontsize64 -Wall -Wextra

HEADERS = \
	src/bb_hip_common.cuh \
	src/bb_bin.cuh \
	src/bb_comput_common.cuh \
	src/bb_comput_l_keys.cuh \
	src/bb_comput_l.cuh \
	src/bb_comput_s_keys.cuh \
	src/bb_comput_s.cuh \
	src/bb_exch_keys.cuh \
	src/bb_exch.cuh \
	src/bb_segsort_common.cuh \
	src/bb_segsort_keys.cuh \
	src/bb_segsort.cuh

.PHONY: all clean

all: main.out

main.out: $(HEADERS) main.cu
	$(HIPCC) $(HIPFLAGS) main.cu -o main.out

clean:
	rm -f main.out
