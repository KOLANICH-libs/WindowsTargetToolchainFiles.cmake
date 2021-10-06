#[[
This is a comprehensive toolchain file, which tries to accomodate all my needs in building software with free toolchains: MinGW-w64 and LLVM & Clang.

Thanks to freenode/#cmake, ngladitz & light2yellow for the advice when I was developing the files.

Either put mingw32/bin into PATH or uncomment the lines setting include paths.
CLang building works only with llvm toolchain.

todo: CMAKE_<LANG>_FLAGS_INIT¶

CMAKE_SYSTEM_PROCESSOR i686 if you target 32-bit Windows and x86_64 if you target 64-bit Windows
TOOLCHAIN_FLAVOUR_NAME - posix or win32, depending on which API you need. Posix is strongly recommended.
USE_CLANG_AS_COMPILER - ON means CLang, OFF means GCC

GCC_COMPILERS_IN_USR_BIN - ON - GCC compilers are in /usr/bin, OFF - GCC compilers are in the dedicated dir
GCC_PREFIX_DOUBLE_USE - ON - gcc compilers name begins with "target double", OFF - doesn't
GCC_SUFFIX_VERSION_USE - ON means the tools will be called like gcc-11, OFF means tools will not have the postfix
GCC_SUFFIX_FLAVOUR_USE - ON - gcc compilers name ends with flavour, OFF - doesn't

LLVM_TOOLS_IN_USR_BIN - ON - LLVM compilers are in /usr/bin, OFF - LLVM compilers are in the dedicated dir
LLVM_SUFFIX_VERSION_USE - ON means the tools will be called like llvm-readelf-14 and clang-14, OFF means tools will not have the postfix

REACTOS_SDK - Free open-source SDK for building drivers for Windows. Also contains some IDLs.
WINE_SOURCES - Sources of wine (its git repo). Needed for files not present in MinGW (sometimes MinGW lags a lot behind Wine).
WINE_DLLS_SOURCES - TODO: Remember what it is and why it is needed. Can be derived from WINE_SOURCES
WINE_INCLUDES - Location of the headers within Wine source repo. Can be derived from WINE_SOURCES
#]]

set(MINGW ON)  # BUG in CMake: when building wit CLang using MinGW runtime, it is not set automatically be CMake

if(NOT DEFINED CMAKE_HOST_WIN32)
	if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
		set(CMAKE_HOST_WIN32 ON)
	else()
		set(CMAKE_HOST_WIN32 OFF)
	endif()
endif()

if(NOT DEFINED CMAKE_SYSTEM_PROCESSOR)
	message(FATAL_ERROR "Set CMAKE_SYSTEM_PROCESSOR into i686 if you target 32-bit Windows and x86_64 if you target 64-bit Windows")
endif()

if(CMAKE_HOST_WIN32)
	set(GCC_COMPILERS_IN_USR_BIN OFF)
	set(LLVM_TOOLS_IN_USR_BIN OFF)
else()
	if(NOT DEFINED CMAKE_CROSSCOMPILING_EMULATOR)
		set(CMAKE_CROSSCOMPILING_EMULATOR "wine")
	endif()
	if(NOT DEFINED GCC_COMPILERS_IN_USR_BIN)
		message(FATAL_ERROR "You must specify GCC_COMPILERS_IN_USR_BIN")
	endif()
endif()

if(NOT DEFINED LLVM_TOOLS_IN_USR_BIN)
	message(FATAL_ERROR "You must specify LLVM_TOOLS_IN_USR_BIN")
endif()

if(GCC_COMPILERS_IN_USR_BIN)
	if(NOT DEFINED GCC_PREFIX_DOUBLE_USE)
		set(GCC_PREFIX_DOUBLE_USE ON)
	endif()
	if(NOT DEFINED GCC_SUFFIX_VERSION_USE)
		set(GCC_SUFFIX_VERSION_USE OFF)
	endif()
	if(NOT DEFINED GCC_SUFFIX_FLAVOUR_USE)
		set(GCC_SUFFIX_FLAVOUR_USE ON)
	endif()
endif()

if(NOT DEFINED GCC_PREFIX_DOUBLE_USE)
	message(FATAL_ERROR "You must specify GCC_PREFIX_DOUBLE_USE")
endif()

if(NOT DEFINED GCC_SUFFIX_VERSION_USE)
	message(FATAL_ERROR "You must specify GCC_SUFFIX_VERSION_USE")
endif()

if(NOT DEFINED GCC_SUFFIX_FLAVOUR_USE)
	message(FATAL_ERROR "You must specify GCC_SUFFIX_FLAVOUR_USE")
endif()


if(NOT DEFINED TOOLCHAIN_FLAVOUR_NAME)
	if(CMAKE_HOST_WIN32)
		set(TOOLCHAIN_FLAVOUR_NAME "")
	else()
		message(FATAL_ERROR "Set TOOLCHAIN_FLAVOUR_NAME into MinGW toolchain flavour, posix or win32")
	endif()
endif()

if(NOT DEFINED TOOLCHAIN_NAME)
	set(TOOLCHAIN_NAME "w64-mingw32")  # in MinGW-w64 from SourceForge it was windows-gnu, but that one is pretty rotten
endif()

if(NOT DEFINED USE_CLANG_AS_COMPILER)
	message(FATAL_ERROR "Set USE_CLANG_AS_COMPILER into ON if you want to build with CLang(++) and into OFF if you want to build with G(CC|++).")
endif()

if(NOT DEFINED REST_OF_TOOLCHAIN_IS_LLVM)
	if(USE_CLANG_AS_COMPILER)
		set(REST_OF_TOOLCHAIN_IS_LLVM ON)
	else()
		set(REST_OF_TOOLCHAIN_IS_LLVM OFF)
	endif()
endif()

if(REST_OF_TOOLCHAIN_IS_LLVM OR USE_CLANG_AS_COMPILER)
	if(NOT DEFINED CMAKE_SYSTEM_VERSION)
		set(CMAKE_SYSTEM_VERSION "4.0")
	endif()

	if(NOT DEFINED CMAKE_SUBSYSTEM_VERSION)
		set(CMAKE_SUBSYSTEM_VERSION "${CMAKE_SYSTEM_VERSION}")
	endif()

	if(NOT DEFINED LLVM_SUFFIX_VERSION_USE)
		if(LLVM_TOOLS_IN_USR_BIN)
			set(LLVM_SUFFIX_VERSION_USE ON)
		else()
			set(LLVM_SUFFIX_VERSION_USE OFF)
		endif()
	endif()

	if(NOT DEFINED llvm_Version)
		if(CMAKE_HOST_WIN32)
			message(FATAL_ERROR "You must specify LLVM version into llvm_Version. It is used to set the right additional flags for clang.")
		else()
			include("${CMAKE_CURRENT_LIST_DIR}/DetectInstalledLLVMVersion.cmake")
			detect_llvm_version(llvm_Version LLVM_ROOT "/usr/lib")
		endif()
	endif()

	if(CMAKE_HOST_WIN32)
		if(NOT DEFINED LLVM_ROOT)
			if(DEFINED DUMP_DIR)
				set(LLVM_ROOT "${DUMP_DIR}/LLVM-${llvm_Version}.0.0-win32")
			else()
				message(FATAL_ERROR "You must set DUMP_DIR if you don't specify the full path to CLang base dir in LLVM_ROOT") # CACHE PATH "Path to Clang root"
			endif()
		endif()
	else()
		if(NOT DEFINED LLVM_ROOT)
			if(LLVM_TOOLS_IN_USR_BIN)
				set(LLVM_ROOT "") # CACHE PATH "Path to Clang root"
			else()
				set(LLVM_ROOT "/usr/lib/llvm-${llvm_Version}") # CACHE PATH "Path to Clang root"
			endif()
		endif()
	endif()

	if(NOT DEFINED LLVM_SUFFIX_VERSION_USE)
		message(FATAL_ERROR "You must specify LLVM_SUFFIX_VERSION_USE")
	endif()
endif()


if(USE_CLANG_AS_COMPILER)
	if(NOT DEFINED USE_MSVC_CLANG_AS_COMPILER)
		message(FATAL_ERROR "You must specify USE_MSVC_CLANG_AS_COMPILER. If it is ON, MSVC stdlib is used with MSVC flavour of CLang. Otherwise MinGW stdlib is used.")
	endif()
endif()

set(USE_CLANG_AS_COMPILER "${USE_CLANG_AS_COMPILER}" CACHE BOOL "If this is selected, the compiler is clang and clang++, otherwise it is MinGW GCC")
set(USE_MSVC_CLANG_AS_COMPILER "${USE_MSVC_CLANG_AS_COMPILER}" CACHE BOOL "If this is selected, the compiler is clang-cl, otherwise it is just clang and clang++. Requires MSVC standard library.")
set(REST_OF_TOOLCHAIN_IS_LLVM "${REST_OF_TOOLCHAIN_IS_LLVM}" CACHE BOOL "If this is selected, the rest of toolchain is LLVM, otherwise it is MinGW")


set(CMAKE_SYSTEM_NAME Windows)
set(double "${CMAKE_SYSTEM_PROCESSOR}-${TOOLCHAIN_NAME}")
set(triple "${CMAKE_SYSTEM_PROCESSOR}-pc-${TOOLCHAIN_NAME}")
if(TOOLCHAIN_FLAVOUR_NAME)
	set(triple "${triple}-${TOOLCHAIN_FLAVOUR_NAME}")
endif()

if(GCC_SUFFIX_FLAVOUR_USE)
	set(GCC_TOOLS_FLAVOUR_SUFFIX "-${TOOLCHAIN_FLAVOUR_NAME}")
else()
	set(GCC_TOOLS_FLAVOUR_SUFFIX "")
endif()

if(GCC_PREFIX_DOUBLE_USE)
	set(GCC_TOOLS_DOUBLE_PREFIX "${double}-")
else()
	set(GCC_TOOLS_DOUBLE_PREFIX "")
endif()

if(LLVM_SUFFIX_VERSION_USE)
	set(LLVM_TOOLS_VERSION_SUFFIX "-${llvm_Version}")
else()
	set(LLVM_TOOLS_VERSION_SUFFIX "")
endif()

if(DEFINED DUMP_DIR)
	if(NOT DEFINED REACTOS_SDK)
		set(REACTOS_SDK "${DUMP_DIR}/reactos-sdk/")# CACHE PATH "Path to ReactOS SDK root"
		message(STATUS "REACTOS_SDK is set by default into ${REACTOS_SDK} . ")
	endif()
	if(NOT DEFINED WINE_SOURCES)
		set(WINE_SOURCES "${DUMP_DIR}/wine-master")
		message(STATUS "WINE_SOURCES is set by default into ${WINE_SOURCES} . ")
	endif()
endif()

if(DEFINED WINE_SOURCES)
	if(NOT DEFINED WINE_DLLS_SOURCES)
		set(WINE_DLLS_SOURCES "${WINE_SOURCES}/dlls")
		message(STATUS "WINE_DLLS_SOURCES is set by default into ${WINE_DLLS_SOURCES} . ")
	endif()
	if(NOT DEFINED WINE_INCLUDES)
		set(WINE_INCLUDES "${WINE_SOURCES}/include")
		message(STATUS "WINE_INCLUDES is set by default into ${WINE_INCLUDES} . ")
	endif()
endif()

if(CMAKE_HOST_WIN32)
	if(NOT DEFINED MINGW_ROOT)
		set(MINGW_ROOT "${DUMP_DIR}/mingw32") # CACHE PATH "Path to MinGW root"
	endif()
else()
	if(NOT DEFINED MINGW_ROOT)
		set(MINGW_ROOT "/usr/${double}")
	endif()# CACHE PATH "Path to MinGW root"
endif()

message(STATUS "CLang root: ${LLVM_ROOT}")
message(STATUS "MinGW root: ${MINGW_ROOT}")
#message(STATUS "ReactOS SDK root: ${REACTOS_SDK}")

if(CMAKE_HOST_WIN32)
	set(CMAKE_SYSROOT "${MINGW_ROOT}")
	set(LIBGCC_ROOT "${MINGW_ROOT}/lib/gcc/${double}")
else()
	set(LIBGCC_ROOT "/usr/lib/gcc/${double}")
endif()

if(NOT DEFINED MINGW_GCC_VERSION)
	include("${CMAKE_CURRENT_LIST_DIR}/DetectLibgccVersion.cmake")
	detect_libgcc_version(MINGW_GCC_VERSION LIBGCC_VER_FLAVOUR_ROOT "${LIBGCC_ROOT}" "${TOOLCHAIN_FLAVOUR_NAME}")
endif()

if(NOT DEFINED LIBGCC_VER_FLAVOUR_ROOT)
	if(CMAKE_HOST_WIN32)
		set(LIBGCC_VER_FLAVOUR_ROOT "${LIBGCC_ROOT}/${MINGW_GCC_VERSION}")
	else()
		set(LIBGCC_VER_FLAVOUR_ROOT "${LIBGCC_ROOT}/${MINGW_GCC_VERSION}-${TOOLCHAIN_FLAVOUR_NAME}")
	endif()
endif()

if(GCC_SUFFIX_VERSION_USE)
	set(GCC_TOOLS_VERSION_SUFFIX "-${MINGW_GCC_VERSION}")
else()
	set(GCC_TOOLS_VERSION_SUFFIX "")
endif()

if(CMAKE_HOST_WIN32)
	set(HOST_EXECUTABLE_SUFFIX ".exe")
else()
	set(HOST_EXECUTABLE_SUFFIX "")
endif()

if(LLVM_ROOT)
	set(CLANG_BIN "${LLVM_ROOT}/bin")
	set(LLVM_BIN_OPTIONAL "${CLANG_BIN}/")
	message(STATUS "CLang bin: ${CLANG_BIN}")
else()
	set(LLVM_BIN_OPTIONAL "")
endif()

if(MINGW_ROOT)
	set(MINGW_BIN "${MINGW_ROOT}/bin")
	message(STATUS "MinGW bin: ${MINGW_BIN}")
endif()

if(GCC_COMPILERS_IN_USR_BIN)
	#set(GCC_TOOLS_DIR_PREFIX "/usr/bin/")
	set(GCC_TOOLS_DIR_PREFIX "")
else()
	set(GCC_TOOLS_DIR_PREFIX "${MINGW_BIN}/")
endif()

if(NOT DEFINED COM_IDL_COMPILER_PATH)
	#ToDo: Try to use Wine one first, it is usually much fresher!
	set(COM_IDL_COMPILER_PATH "${MINGW_BIN}/widl${HOST_EXECUTABLE_SUFFIX}")
endif()

if(CMAKE_GENERATOR STREQUAL "Ninja")
	if(CMAKE_HOST_WIN32)
		set(CMAKE_MAKE_PROGRAM "${DUMP_DIR}/ninja${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to make")
	else()
		set(CMAKE_MAKE_PROGRAM "ninja" CACHE FILEPATH "Path to make")
	endif()
else()
	if(CMAKE_GENERATOR STREQUAL "MinGW Makefiles")
		set(CMAKE_MAKE_PROGRAM "${MINGW_BIN}/mingw32-make${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to make")
	else()
		message(FATAL_ERROR "CMake Generator ${CMAKE_GENERATOR} is not currently supported in the toolchain file")
	endif()
endif()

if (USE_CLANG_AS_COMPILER)
	message(STATUS "Setting CLang as compiler")
	if(USE_MSVC_CLANG_AS_COMPILER)
		set(CMAKE_CXX_COMPILER "clang-cl")
		set(CMAKE_C_COMPILER "${CMAKE_CXX_COMPILER}")
	else()
		set(CMAKE_C_COMPILER "clang")
		set(CMAKE_CXX_COMPILER "clang++")
	endif()
	set(CMAKE_C_COMPILER "${LLVM_BIN_OPTIONAL}${CMAKE_C_COMPILER}${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}")
	set(CMAKE_CXX_COMPILER "${LLVM_BIN_OPTIONAL}${CMAKE_CXX_COMPILER}${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}")

	if(CMAKE_HOST_WIN32)
		###########################################################
		
		set(CMAKE_FLAGS "${CMAKE_FLAGS} --target=${triple}") # DO NOT DELETE IT! CMake has a BUG. When this addition to args is present, the target triple in CLI args is doubled, but it does no harm. When thi is missing, Windows CMake ALWAYS identifies CLang as with MSVC runtime, not MinGW, even if ${triple} specifies to use MinGW runtime

		set(LIBCLANG_VER_ROOT "${LIBGCC_ROOT}/lib/clang/${llvm_Version}.0.0")

		link_directories(
			"${LIBGCC_ROOT}/lib"
			"${LIBGCC_VER_FLAVOUR_ROOT}"
		)
		#SET(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}" "${LIBGCC_ROOT}" "${LIBGCC_VER_FLAVOUR_ROOT}" "${LIBCLANG_VER_ROOT}")
		SET(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}")
	else()
		include_directories(SYSTEM "${LIBGCC_VER_FLAVOUR_ROOT}/include/c++")
		include_directories(SYSTEM "${LIBGCC_VER_FLAVOUR_ROOT}/include/c++/${double}")
		include_directories(SYSTEM "${LIBGCC_VER_FLAVOUR_ROOT}/include/c++/backward")
		include_directories(SYSTEM "${LIBGCC_VER_FLAVOUR_ROOT}/include-fixed")
	endif()
else()
	message(STATUS "Setting GCC as compiler")
	set(CMAKE_C_COMPILER "${GCC_TOOLS_DIR_PREFIX}${GCC_TOOLS_DOUBLE_PREFIX}gcc${GCC_TOOLS_VERSION_SUFFIX}${GCC_TOOLS_FLAVOUR_SUFFIX}${HOST_EXECUTABLE_SUFFIX}")
	set(CMAKE_CXX_COMPILER "${GCC_TOOLS_DIR_PREFIX}${GCC_TOOLS_DOUBLE_PREFIX}g++${GCC_TOOLS_VERSION_SUFFIX}${GCC_TOOLS_FLAVOUR_SUFFIX}${HOST_EXECUTABLE_SUFFIX}")
endif()
set(CMAKE_RC_COMPILER "${GCC_TOOLS_DIR_PREFIX}${GCC_TOOLS_DOUBLE_PREFIX}windres${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to resource compiler")


set(CMAKE_OBJCOPY "${MINGW_BIN}/objcopy${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to objcopy")

message(STATUS "make: ${CMAKE_MAKE_PROGRAM}")
message(STATUS "resource compiler: ${CMAKE_RC_COMPILER}")
message(STATUS "linker: ${CMAKE_LINKER}")

if(REST_OF_TOOLCHAIN_IS_LLVM)
	set(CMAKE_AR "${LLVM_BIN_OPTIONAL}llvm-ar${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to ar")
	set(CMAKE_OBJDUMP "${LLVM_BIN_OPTIONAL}llvm-objdump${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to objdump")
	set(CMAKE_NM "${LLVM_BIN_OPTIONAL}llvm-nm${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to nm")
	set(CMAKE_RANLIB "${LLVM_BIN_OPTIONAL}llvm-ranlib${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to ranlib")
	set(CMAKE_STRIP "${LLVM_BIN_OPTIONAL}llvm-strip${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to strip")
	if(USE_MSVC_CLANG_AS_COMPILER)
		set(CMAKE_LINKER "${LLVM_BIN_OPTIONAL}lld-link${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to linker")
	else()
		set(CMAKE_LINKER "${LLVM_BIN_OPTIONAL}ld.lld${LLVM_TOOLS_VERSION_SUFFIX}${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to linker")
	endif()
else()
	set(CMAKE_AR "${MINGW_BIN}/ar${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to ar")
	set(CMAKE_OBJDUMP "${MINGW_BIN}/objdump${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to objdump")
	set(CMAKE_NM "${MINGW_BIN}/nm${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to nm")
	set(CMAKE_RANLIB "${MINGW_BIN}/ranlib${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to ranlib")
	set(CMAKE_STRIP "${MINGW_BIN}/strip${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to strip")
	set(CMAKE_LINKER "${MINGW_BIN}/ld${HOST_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Path to linker")
endif()

message(STATUS "ar: ${CMAKE_AR}")
message(STATUS "objdump: ${CMAKE_OBJDUMP}")
message(STATUS "nm: ${CMAKE_NM}")
message(STATUS "ranlib: ${CMAKE_RANLIB}")
message(STATUS "linker: ${CMAKE_LINKER}")
message(STATUS "strip: ${CMAKE_STRIP}")

set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER_TARGET ${triple})
set(CMAKE_CPP_COMPILER_TARGET ${triple})

set(CMAKE_C_FLAGS ${CMAKE_FLAGS})
set(CMAKE_CXX_FLAGS ${CMAKE_FLAGS})

if(USE_CLANG_AS_COMPILER)
	if(NOT DEFINED exceptionStyle)
		include("${CMAKE_CURRENT_LIST_DIR}/DetectMinGWExceptionModel.cmake")
		detectExceptionModel(exceptionStyle "${CMAKE_NM}" "${LIBGCC_VER_FLAVOUR_ROOT}/libstdc++.dll.a")
		set(exceptionStyle "${exceptionStyle}" CACHE STRING "Exception style used by the toolchain")
		set_property(
			CACHE exceptionStyle
			PROPERTY STRINGS "${MINGW_ALL_EXCEPTIONS_MODELS}"
		)
	endif()

	string(REPLACE "." ";" CMAKE_SYSTEM_VERSION_LIST "${CMAKE_SYSTEM_VERSION}")
	list(GET CMAKE_SYSTEM_VERSION_LIST 0 CMAKE_SYSTEM_VERSION_MAJOR)
	list(GET CMAKE_SYSTEM_VERSION_LIST 1 CMAKE_SYSTEM_VERSION_MINOR)
	set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -Wl,--major-os-version,${CMAKE_SYSTEM_VERSION_MAJOR}")
	set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -Wl,--minor-os-version,${CMAKE_SYSTEM_VERSION_MINOR}")

	string(REPLACE "." ";" CMAKE_SUBSYSTEM_VERSION_LIST "${CMAKE_SUBSYSTEM_VERSION}")
	list(GET CMAKE_SUBSYSTEM_VERSION_LIST 0 CMAKE_SUBSYSTEM_VERSION_MAJOR)
	list(GET CMAKE_SUBSYSTEM_VERSION_LIST 1 CMAKE_SUBSYSTEM_VERSION_MINOR)
	set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -Wl,--major-subsystem-version,${CMAKE_SUBSYSTEM_VERSION_MAJOR}")
	set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -Wl,--minor-subsystem-version,${CMAKE_SUBSYSTEM_VERSION_MINOR}")


	#todo: CMAKE_<LANG>_FLAGS_INIT, CMAKE_*_LINKER_FLAGS_INIT, but they don't work. What is it?
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -f${exceptionStyle}-exceptions")
	set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -f${exceptionStyle}-exceptions")
	if (llvm_Version VERSION_GREATER 11)
		set(CMAKE_LINKER_FLAGS
			"-v --ld-path=\"${CMAKE_LINKER}\" ${CMAKE_LINKER_FLAGS}"
		)
	else()
		set(CMAKE_LINKER_FLAGS
			"-v -fuse-ld=\"${CMAKE_LINKER}\" ${CMAKE_LINKER_FLAGS}"
		)
	endif()
endif()
if(NOT CMAKE_HOST_WIN32)
	set(CMAKE_LINKER_FLAGS "-L${LIBGCC_VER_FLAVOUR_ROOT} ${CMAKE_LINKER_FLAGS}")
endif()


set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_LINKER_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_LINKER_FLAGS}")

set(CMAKE_C_LINKER_FLAGS ${CMAKE_LINKER_FLAGS})
set(CMAKE_CXX_LINKER_FLAGS ${CMAKE_LINKER_FLAGS})


set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE NEVER)
