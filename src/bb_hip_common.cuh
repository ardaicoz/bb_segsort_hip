#ifndef _H_BB_HIP_COMMON
#define _H_BB_HIP_COMMON

#include <hip/hip_runtime.h>

#include <iostream>

#if defined(__HIP_DEVICE_COMPILE__) && (defined(__GFX8__) || defined(__GFX9__))
#error "bb_segsort HIP build only supports wave32 RDNA targets (gfx10+)."
#endif

#if defined(__HIP_DEVICE_COMPILE__)
#define BB_HIP_WG_SIZE_512 __attribute__((amdgpu_flat_work_group_size(1, 512)))
#else
#define BB_HIP_WG_SIZE_512
#endif

#define BB_FULL_MASK 0x00000000ffffffffULL

#define HIP_CHECK(_e, _s) if((_e) != hipSuccess) { \
        std::cout << "HIP error (" << (_s) << "): " << hipGetErrorString((_e)) << std::endl; \
        return 0; }

#define HIP_CHECK_VOID(_e, _s) if((_e) != hipSuccess) { \
        std::cout << "HIP error (" << (_s) << "): " << hipGetErrorString((_e)) << std::endl; \
        return; }

inline bool bb_require_wave32_device(const char *caller)
{
    int device = 0;
    hipError_t err = hipGetDevice(&device);
    if(err != hipSuccess) {
        std::cout << "HIP error (" << caller << "): " << hipGetErrorString(err) << std::endl;
        return false;
    }

    int warp_size = 0;
    err = hipDeviceGetAttribute(&warp_size, hipDeviceAttributeWarpSize, device);
    if(err != hipSuccess) {
        std::cout << "HIP error (" << caller << "): " << hipGetErrorString(err) << std::endl;
        return false;
    }

    if(warp_size != 32) {
        std::cout << caller
                  << " requires wave32 execution on an RDNA (gfx10+) device, but warp size is "
                  << warp_size << std::endl;
        return false;
    }

    return true;
}

#endif
