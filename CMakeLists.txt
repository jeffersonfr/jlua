cmake_minimum_required (VERSION 3.0)

project (jlua)

set (CMAKE_CXX_STANDARD 20)

find_package (PkgConfig REQUIRED)

pkg_check_modules (jCanvas REQUIRED IMPORTED_TARGET jcanvas)
pkg_check_modules (Lua5.3 REQUIRED IMPORTED_TARGET lua5.3)

add_subdirectory (src)
