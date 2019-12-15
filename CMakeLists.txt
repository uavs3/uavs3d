cmake_minimum_required(VERSION 2.8)

project(uavs3d)

aux_source_directory(./test DIR_SRC_TEST)
set_source_files_properties(${DIR_SRC_TEST} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -std=c99 -O3")

add_subdirectory(./source)

add_executable(uavs3dec ${DIR_SRC_TEST})

target_link_libraries(uavs3dec m)
target_link_libraries(uavs3dec uavs3d)
#target_link_libraries(uavs3dec dl)

