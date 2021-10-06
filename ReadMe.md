WindowsTargetToolchainFiles.cmake [![Unlicensed work](https://raw.githubusercontent.com/unlicense/unlicense.org/master/static/favicon.png)](https://unlicense.org/)
==================================
[![Libraries.io Status](https://img.shields.io/librariesio/github/KOLANICH-libs/WindowsTargetToolchainFiles.cmake.svg)](https://libraries.io/github/KOLANICH-libs/WindowsTargetToolchainFiles.cmake)

Set of CMake toolchain files for (cross-)building Windows applications with focus on unification and parameterization.

The main file is `toolchain.cmake`. The rest of files are just preset parameters for it.

One has to provide `WINDOWS_IS_HOST` variable because it seems we cannot determine it from CMake variables itself.
