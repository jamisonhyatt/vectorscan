
#include "util/arch/common/cpuid_flags.h"
#include "ue2common.h"
#include "hs_compile.h" // for HS_MODE_ flags
#include "util/arch.h"

#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#include <processthreadsapi.h>

u64a cpuid_flags(void) {
    u64a cap = 0;
    
    // Windows ARM64 guarantees NEON/ASIMD support
    cap |= HS_CPU_FEATURES_NEON;
    
    // Check for additional features using IsProcessorFeaturePresent
    // Note: Windows doesn't currently expose SVE through this API
    // but we can check for crypto instructions if needed
    if (IsProcessorFeaturePresent(PF_ARM_V8_CRYPTO_INSTRUCTIONS_AVAILABLE)) {
        // ARM v8 crypto extensions are available
        DEBUG_PRINTF("ARM v8 crypto instructions available\n");
    }
    
    DEBUG_PRINTF("Windows ARM64 NEON support enabled\n");
    return cap;
}

u32 cpuid_tune(void) {
    return HS_TUNE_FAMILY_GENERIC;
}

#else
// Fallback - include the original Linux implementation
#include "cpuid_flags.c"
#endif
