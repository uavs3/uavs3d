aux_source_directory(./decoder DIR_UAVS3D_SRC)
aux_source_directory(./decore DIR_UAVS3D_CORE)
aux_source_directory(./decore/sse DIR_X86_SRC)
aux_source_directory(./decore/avx2 DIR_X86_256_SRC)

list(APPEND DIR_UAVS3D_SRC ${DIR_UAVS3D_CORE})

include_directories("decore")

set_source_files_properties(${DIR_UAVS3D_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -fPIC -std=c99 -O3")
set_source_files_properties(${DIR_X86_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -fPIC -std=c99 -O3 -msse4.2")
set_source_files_properties(${DIR_X86_256_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -fPIC -std=c99 -O3 -mavx2")

add_library(uavs3d ${DIR_UAVS3D_SRC} ${DIR_X86_256_SRC} ${DIR_X86_SRC})

target_link_libraries(uavs3d m)
target_link_libraries(uavs3d pthread)

install(TARGETS uavs3d LIBRARY DESTINATION /usr/lib ARCHIVE DESTINATION /usr/lib)
install(FILES decoder/uavs3d.h DESTINATION /usr/include/)
