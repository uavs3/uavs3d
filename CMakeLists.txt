cmake_minimum_required(VERSION 3.1)

project(uavs3d)

set(CMAKE_C_STANDARD 99)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

aux_source_directory(./test DIR_SRC_TEST)

add_subdirectory(./source)

add_executable(uavs3dec ${DIR_SRC_TEST})

target_link_libraries(uavs3dec m)
target_link_libraries(uavs3dec uavs3d)
#target_link_libraries(uavs3dec dl)
