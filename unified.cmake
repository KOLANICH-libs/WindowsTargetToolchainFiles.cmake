
message(STATUS "Host OS is ${CMAKE_HOST_SYSTEM_NAME}, applying the preset for it")

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
	if(NOT DEFINED llvm_Version)
		set(llvm_Version 13)
	endif()

	if(NOT DEFINED LLVM_SUFFIX_VERSION_USE)
		set(LLVM_SUFFIX_VERSION_USE OFF)
	endif()
	if(NOT DEFINED GCC_PREFIX_DOUBLE_USE)
		set(GCC_PREFIX_DOUBLE_USE OFF)
	endif()
	if(NOT DEFINED GCC_SUFFIX_VERSION_USE)
		set(GCC_SUFFIX_VERSION_USE OFF)
	endif()
	if(NOT DEFINED GCC_SUFFIX_FLAVOUR_USE)
		set(GCC_SUFFIX_FLAVOUR_USE OFF)
	endif()

	get_filename_component(DUMP_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)  # CACHE PATH "The dir where we have unpacked MinGW and CLang"
	message(STATUS "DUMP_DIR ${DUMP_DIR}")
else()
	if(NOT DEFINED TOOLCHAIN_FLAVOUR_NAME)
		set(TOOLCHAIN_FLAVOUR_NAME "posix")
	endif()

	if(NOT DEFINED GCC_COMPILERS_IN_USR_BIN)
		set(GCC_COMPILERS_IN_USR_BIN ON)
	endif()

	if(NOT DEFINED LLVM_TOOLS_IN_USR_BIN)
		set(LLVM_TOOLS_IN_USR_BIN OFF)
	endif()
endif()

include("${CMAKE_CURRENT_LIST_DIR}/common.cmake")

