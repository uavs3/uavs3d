
set(LIBNAME uavs3d)

# check cpu
if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "AMD64" OR
   "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
  if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
    set(UAVS3D_TARGET_CPU "x86")
  elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
    set(UAVS3D_TARGET_CPU "x86_64")
  else()
    message(FATAL_ERROR
              " Unexpected pointer size ${CMAKE_SIZEOF_VOID_P} for ${CMAKE_SYSTEM_PROCESSOR}\n")
  endif()
elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "i386" OR
       "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86")
  set(UAVS3D_TARGET_CPU "x86")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "aarch64")
  set(UAVS3D_TARGET_CPU "arm64")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "^arm")
  set(UAVS3D_TARGET_CPU "armv7")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "loongarch64")
  set(UAVS3D_TARGET_CPU "loongarch64")
else()
  message(WARNING "unsupported architecture: ${CMAKE_SYSTEM_PROCESSOR}\n")
  set(UAVS3D_TARGET_CPU "generic")
endif()

# add source
aux_source_directory(./decoder DIR_UAVS3D_SRC)
aux_source_directory(./decore DIR_UAVS3D_CORE)

list(APPEND DIR_UAVS3D_SRC ${DIR_UAVS3D_CORE})

include_directories("decore")
set(UAVS3D_ASM_FILES "")

if("${UAVS3D_TARGET_CPU}" MATCHES "x86" OR
   "${UAVS3D_TARGET_CPU}" MATCHES "x86_64")
  aux_source_directory(./decore/sse DIR_X86_SRC)
  aux_source_directory(./decore/avx2 DIR_X86_256_SRC)
  set_source_files_properties(${DIR_X86_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -msse4.2")
  set_source_files_properties(${DIR_X86_256_SRC} PROPERTIES COMPILE_FLAGS "${CMAKE_C_FLAGS} -mavx2")

  list(APPEND UAVS3D_ASM_FILES ${DIR_X86_SRC})
  list(APPEND UAVS3D_ASM_FILES ${DIR_X86_256_SRC})
elseif("${UAVS3D_TARGET_CPU}" MATCHES "armv7")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/armv7.c")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/alf_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/deblock_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/def_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/inter_pred_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/intra_pred_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/dct2_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/itrans_dct8_dst7_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/pixel_armv7.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/sao_armv7.c")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/sao_kernel_armv7.S")

  add_definitions(-D _armv7a)
  enable_language(ASM)
elseif("${UAVS3D_TARGET_CPU}" MATCHES "arm64")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/arm64.c")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/alf_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/deblock_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/def_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/inter_pred_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/intra_pred_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/intra_pred_chroma_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/itrans_arm64.c")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/itrans_dct2_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/itrans_dct8_dst7_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/pixel_arm64.S")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/sao_arm64.c")
  list(APPEND UAVS3D_ASM_FILES "./decore/arm64/sao_kernel_arm64.S")

  add_definitions(-D _arm64)
  enable_language(ASM)
elseif("${UAVS3D_TARGET_CPU}" MATCHES "loongarch64")
  # loongarch64
endif()

if(COMPILE_10BIT)
    add_definitions(-DCOMPILE_10BIT=1)
    message("-- compile 10bit")
else()
    add_definitions(-DCOMPILE_10BIT=0)
    message("-- compile 8bit")
endif()

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

MESSAGE(STATUS "Target CPU\t\t\t: ${UAVS3D_TARGET_CPU}")
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
add_library(${LIBNAME} ${DIR_UAVS3D_SRC} ${UAVS3D_ASM_FILES})

if (NOT MSVC)
    target_link_libraries(${LIBNAME} m)
endif()
if(CMAKE_USE_PTHREADS_INIT)
target_link_libraries(${LIBNAME} pthread)
endif()

# install
install(TARGETS uavs3d LIBRARY DESTINATION ${CMAKE_INSTALL_LIB_DIR} ARCHIVE DESTINATION ${CMAKE_INSTALL_LIB_DIR})
install(FILES decoder/uavs3d.h DESTINATION ${CMAKE_INSTALL_INCLUDE_DIR})
install(FILES ${CONFIG_DIR}/${LIBNAME}.pc DESTINATION ${CMAKE_INSTALL_PKGCONFIG_DIR})
