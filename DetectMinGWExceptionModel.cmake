#[[
This file provides a function to detect CMake exception model.
It is absolutely required to be known if compiling with CLang.

Great thanks to Michael Burr for his answer https://stackoverflow.com/questions/17410718/the-procedure-entry-point-gxx-personality-v0-could-not-be-located-in-the-dynami/17417496#17417496

outVar - variable to which put the result
LIBSTDCPLUSPLUS_DLL_A - something like /usr/lib/gcc/x86_64-w64-mingw32/10-posix/libstdc++.dll.a, but corresponding to YOUR toolchain.

MINGW_ALL_EXCEPTIONS_MODELS variable contains list of all exception models and can be used in SCRINGS property of CACHE variable to create a list in GUI.
]]#

#todo: wasm
set(MINGW_ALL_EXCEPTIONS_PERSONALITIES "sj;v;seh")
set(MINGW_ALL_EXCEPTIONS_MODELS "sjlj;dwarf;seh")
list(LENGTH MINGW_ALL_EXCEPTIONS_MODELS MINGW_ALL_EXCEPTIONS_MODELS_COUNT)

function(detectExceptionModel outVar NM_BINARY_PATH LIBSTDCPLUSPLUS_DLL_A)
	message(STATUS "Detecting MinGW exception model")
	#message(STATUS "NM_BINARY_PATH ${NM_BINARY_PATH}")
	#message(STATUS "LIBSTDCPLUSPLUS_DLL_A ${LIBSTDCPLUSPLUS_DLL_A}")
	execute_process(COMMAND "${NM_BINARY_PATH}" "${LIBSTDCPLUSPLUS_DLL_A}"
		OUTPUT_VARIABLE NM_OUTPUT
	)
	string(REPLACE "\n" ";" NM_OUTPUT "${NM_OUTPUT}")
	foreach(l ${NM_OUTPUT})
		string(REPLACE " " ";" l "${l}")
		list(LENGTH l ll)
		#message(STATUS "${ll} ${l}")
		if(ll EQUAL 3)
			list(GET l 2 name)
			string(REGEX MATCH "^_+gxx_personality_([a-zA-Z]+)[0-9]*$" MATCHED "${name}")
			if(MATCHED)
				set(personality "${CMAKE_MATCH_1}")
				message(STATUS "Detected personality: ${personality}")
				break()
			endif()
		endif()
	endforeach()
	if(personality)
		foreach(i RANGE 0 ${MINGW_ALL_EXCEPTIONS_MODELS_COUNT})
			list(GET MINGW_ALL_EXCEPTIONS_PERSONALITIES ${i} personalityCandidate)
			if(personality STREQUAL "${personalityCandidate}")
				list(GET MINGW_ALL_EXCEPTIONS_MODELS ${i} ${outVar})
				set(${outVar} "${${outVar}}" PARENT_SCOPE)
				message(STATUS "Detected exception model: ${${outVar}}")
				break()
			endif()
		endforeach()
		if(${outVar})
		else()
			message(FATAL_ERROR "Unknown personality: ${personality}")
		endif()
	else()
		message(FATAL_ERROR "Failed to detect personality")
	endif()
endfunction()
