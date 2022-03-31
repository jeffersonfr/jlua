cmake_minimum_required (VERSION 3.0)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "In-source build is not allowed")
endif()

project (jlua)

set (CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

pkg_check_modules (jCanvas REQUIRED IMPORTED_TARGET jcanvas)
pkg_check_modules (Lua5.3 REQUIRED IMPORTED_TARGET lua5.3)

find_package (PkgConfig REQUIRED)

enable_testing()

add_subdirectory (src)
