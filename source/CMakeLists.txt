
set(LIBNAME uavs3d)

# add source
aux_source_directory(./decoder DIR_UAVS3D_SRC)
aux_source_directory(./decore DIR_UAVS3D_CORE)
aux_source_directory(./decore/sse DIR_X86_SRC)
aux_source_directory(./decore/avx2 DIR_X86_256_SRC)

list(APPEND DIR_UAVS3D_SRC ${DIR_UAVS3D_CORE})

include_directories("decore")

set_source_files_properties(${DIR_UAVS3D_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -fPIC -std=c99 -O3")
set_source_files_properties(${DIR_X86_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -fPIC -std=c99 -O3 -msse4.2")
set_source_files_properties(${DIR_X86_256_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -fPIC -std=c99 -O3 -mavx2")

# get version
set (CONFIG_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..)
execute_process(COMMAND sh ${CONFIG_DIR}/version.sh ${CONFIG_DIR})

function(extract_version_string version_file version_string_out)
  file(STRINGS "${version_file}" uavs3d_version REGEX "VERSION_STR")
  string(REPLACE "#define VERSION_STR " "" uavs3d_version "${uavs3d_version}")
  string(REPLACE "\"" "" uavs3d_version "${uavs3d_version}")
  string(REPLACE " " "" uavs3d_version "${uavs3d_version}")
  set("${version_string_out}" "${uavs3d_version}" PARENT_SCOPE)
endfunction()

extract_version_string("${CONFIG_DIR}/version.h" uavs3d_version)
MESSAGE(STATUS "uavs3d version \t\t: ${uavs3d_version}")

# pkg-config
find_package(Threads REQUIRED)
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(includedir "include")
set(libdir "lib")
set(pc_file "${CONFIG_DIR}/${LIBNAME}.pc")

set(CMAKE_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/${includedir}")
set(CMAKE_INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/${libdir}")
set(CMAKE_INSTALL_PKGCONFIG_DIR "${CMAKE_INSTALL_LIB_DIR}/pkgconfig")
MESSAGE(STATUS "INSTALL_INCLUDE_DIR \t\t: ${CMAKE_INSTALL_INCLUDE_DIR}")
MESSAGE(STATUS "INSTALL_LIB_DIR \t\t: ${CMAKE_INSTALL_LIB_DIR}")
MESSAGE(STATUS "INSTALL_PKGCONFIG_DIR\t: ${CMAKE_INSTALL_PKGCONFIG_DIR}")
# write pkg-config file
file(WRITE "${pc_file}" "prefix=${prefix}\n")
file(APPEND "${pc_file}" "exec_prefix=\${prefix}\n")
file(APPEND "${pc_file}" "includedir=\${prefix}/${includedir}\n")
file(APPEND "${pc_file}" "libdir=\${exec_prefix}/${libdir}\n\n")
file(APPEND "${pc_file}" "Name: ${LIBNAME}\n")
file(APPEND "${pc_file}" "Description: AVS3 decoder library \n")
file(APPEND "${pc_file}" "Version: ${uavs3d_version}\n")
if(CMAKE_USE_PTHREADS_INIT)
  file(APPEND "${pc_file}" "Libs: -L\${libdir} -l${LIBNAME} -lm -lpthread\n")
else()
  file(APPEND "${pc_file}" "Libs: -L\${libdir} -l${LIBNAME} -lm\n")
file(APPEND "${pc_file}" "Libs.private: \n")
endif()
file(APPEND "${pc_file}" "Cflags: -I\${includedir}\n")

# set library
if(BUILD_SHARED_LIBS)
MESSAGE(STATUS "BUILD_SHARED_LIBS \t\t: true")
else()
MESSAGE(STATUS "BUILD_SHARED_LIBS \t\t: false")
endif()
add_library(${LIBNAME} ${DIR_UAVS3D_SRC} ${DIR_X86_256_SRC} ${DIR_X86_SRC})

target_link_libraries(${LIBNAME} m)
if(CMAKE_USE_PTHREADS_INIT)
target_link_libraries(${LIBNAME} pthread)
endif()

# install
install(TARGETS uavs3d LIBRARY DESTINATION ${CMAKE_INSTALL_LIB_DIR} ARCHIVE DESTINATION ${CMAKE_INSTALL_LIB_DIR})
install(FILES decoder/uavs3d.h DESTINATION ${CMAKE_INSTALL_INCLUDE_DIR})
install(FILES ${CONFIG_DIR}/${LIBNAME}.pc DESTINATION ${CMAKE_INSTALL_PKGCONFIG_DIR})

