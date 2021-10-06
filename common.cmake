set(USE_MSVC_CLANG_AS_COMPILER OFF CACHE BOOL "If this is selected, the compiler is clang-cl, otherwise it is just clang and clang++. Requires MSVC standard library.")

include("${CMAKE_CURRENT_LIST_DIR}/toolchain.cmake")
