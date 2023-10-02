cmake_minimum_required (VERSION 3.20)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "In-source build is not allowed")
endif()

project(jlua
  LANGUAGES CXX
  HOMEPAGE_URL https://github.com/jeffersonfr/jlua
  DESCRIPTION "Game engine in lua"
  VERSION 1.0.0
)

set (CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package (PkgConfig REQUIRED)

pkg_check_modules (jCanvas REQUIRED IMPORTED_TARGET jcanvas)
pkg_check_modules (Lua5.3 REQUIRED IMPORTED_TARGET lua5.3)

enable_testing()

add_subdirectory (src)
