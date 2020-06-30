#  MIT License
#
#  Copyright (c) 2020 CK Tan, Raphael Beck
#  https://github.com/cktan/tomlc99
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

cmake_minimum_required(VERSION 3.15)

project(tomlc89 C)

set(CMAKE_C_STANDARD 90)

if (WIN32 AND BUILD_SHARED_LIBS)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif ()

option(TOMLC89_BUILD_PROGRAMS "Build tomlc89 programs." ON)
option(TOMLC89_BUILD_TESTS "Build tomlc89 unit tests." OFF)

set(${PROJECT_NAME}_SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/include/toml.h
        ${CMAKE_CURRENT_LIST_DIR}/src/toml.c)

add_library(${PROJECT_NAME} ${${PROJECT_NAME}_SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)

if (TOMLC89_BUILD_PROGRAMS)

    add_executable(toml_cat
            ${${PROJECT_NAME}_SOURCES}
            ${CMAKE_CURRENT_LIST_DIR}/src/toml_cat.c)

    target_link_libraries(toml_cat PUBLIC ${PROJECT_NAME})

    add_executable(toml_json
            ${${PROJECT_NAME}_SOURCES}
            ${CMAKE_CURRENT_LIST_DIR}/src/toml_json.c)

    target_link_libraries(toml_json PUBLIC ${PROJECT_NAME})

endif ()

if (TOMLC89_BUILD_TESTS)

    add_executable(t1
            ${${PROJECT_NAME}_SOURCES}
            ${CMAKE_CURRENT_LIST_DIR}/unittest/t1.c)

    target_link_libraries(t1 PUBLIC ${PROJECT_NAME})

endif ()
