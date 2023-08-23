cmake_minimum_required(VERSION 3.18)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(main LANGUAGES CXX)

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_compile_options(/MT)
endif()

add_executable(main main.cpp)

target_compile_options(main PUBLIC 
    $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-mavx2$<SEMICOLON>-mfma> 
    $<$<COMPILE_LANG_AND_ID:CXX,AppleClang,Clang>:-mavx2> 
    $<$<COMPILE_LANG_AND_ID:CXX,AppleClang,Clang>:-mfma> 
    $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/arch:AVX2>) # 如果你的电脑不支持 AVX2，请删除本行

#windows install is not like unix posix
# if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
#     message(STATUS "cmake with MSVC,add path:")
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/)
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/benchmark/)
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/benchmark/lib/)
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/benchmark/lib/cmake)
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/benchmark/lib/cmake/benchmark/)
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest-distribution)
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest-distribution/lib)
#     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest-distribution/lib/cmake/GTest)
#     #not work,fuck
#     list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest-distribution/lib/cmake/GTest")
#     list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest-distribution/lib/cmake/GTest/)
#     message(STATUS "cmake with prefix path: ${CMAKE_MODULE_PATH}")
#    
#     #include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/benchmark/include/)
#     #link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/benchmark/lib/)
#     #include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest-distribution/include/)
#     #link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest-distribution/lib/)
# endif()

# ---------------------what the fuck-----------------------
#what the fuck, benchmark_FOUND is not equal BENCHMARK_FOUND
# ---------------------what the fuck-----------------------
# if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
#     #find_package(benchmark REQUIRED PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/benchmark/lib/cmake/benchmark)
#     find_package(benchmark REQUIRED)
# else()
#     find_package(benchmark REQUIRED)
# endif()
# if(benchmark_FOUND)
#     message(WARNING "Configuring with Google benchmark!")
# else()
#     message(WARNING "Configuring without Google benchmark!")
# endif()

find_package(benchmark REQUIRED)
target_link_libraries(main PUBLIC benchmark::benchmark)
target_link_libraries(main PUBLIC benchmark::benchmark_main)  # 测试性能时使用此行

# if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
#     #find_package(GTest REQUIRED PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../GoogleOutPutLibrary/googletest/lib/cmake/GTest)
#     find_package(GTest REQUIRED)
# else()
#     find_package(GTest REQUIRED)
# endif()
# if(GTest_FOUND)
#     message(WARNING "Configuring with GoogleTest!")
# else()
#     message(WARNING "Configuring without GoogleTest!")
# endif()
find_package(GTest REQUIRED)
target_link_libraries(main PUBLIC GTest::gtest)
target_link_libraries(main PUBLIC GTest::gtest_main)  # 测试正确性时使用此行

find_package(OpenMP REQUIRED)
target_link_libraries(main PUBLIC OpenMP::OpenMP_CXX)

