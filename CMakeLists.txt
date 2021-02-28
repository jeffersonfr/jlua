cmake_minimum_required (VERSION 3.0)

project (jlua)

set (CMAKE_CXX_STANDARD 20)

find_package (PkgConfig REQUIRED)

pkg_check_modules (JCANVAS REQUIRED jcanvas)
pkg_check_modules (LUA5.3 REQUIRED lua5.3)

add_subdirectory (src)
