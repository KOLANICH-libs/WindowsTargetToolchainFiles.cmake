#[[
This is a comprehensive toolchain file, which tries to accomodate all my needs in building software with free toolchains: MinGW-w64 and LLVM & Clang.

See the docs in toolchain.cmake

#]]

set(CMAKE_SYSTEM_PROCESSOR "x86_64")
set(USE_CLANG_AS_COMPILER OFF CACHE BOOL "If this is selected, the compiler is clang and clang++, otherwise it is MinGW GCC")

include("${CMAKE_CURRENT_LIST_DIR}/unified.cmake")
