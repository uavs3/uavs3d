### This file is jni/Android.mk

LOCAL_PATH   := $(call my-dir)
SRC_PATH     := ../../../../source
INCLUDE_PATH := ../../../../source/decore

### Name of the local module
include $(CLEAR_VARS) 
LOCAL_MODULE            := uavs3d
LOCAL_LDLIBS:=-L$(SYSROOT)/usr/lib -lm -llog

### for posix pthread
#LOCAL_SHARED_LIBRARIES := libcutil

### include search path when compiling all sources (C,C++,Assembly)
LOCAL_C_INCLUDES +=$(INCLUDE_PATH)                             \
                   $(LOCAL_PATH)/../app           

### c source code
uavs3d_srcs_c   += $(SRC_PATH)/decore/alf.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/deblock.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/inter_pred.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/intra_pred.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/inv_trans.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/pic_manager.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/recon.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/sao.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/com_table.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/threadpool.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/win32thread.c
uavs3d_srcs_c   += $(SRC_PATH)/decore/com_util.c
uavs3d_srcs_c   += $(SRC_PATH)/decoder/uavs3d.c
uavs3d_srcs_c   += $(SRC_PATH)/decoder/bitstream.c
uavs3d_srcs_c   += $(SRC_PATH)/decoder/parser.c
uavs3d_srcs_c   += $(SRC_PATH)/decoder/dec_util.c

LOCAL_CFLAGS    += -O3 -fPIC -std=gnu99
LOCAL_LDFLAGS   += -fPIC

#if build_executable
LOCAL_CFLAGS    += -pie -fPIE
LOCAL_LDFLAGS   += -pie -fPIE
uavs3d_srcs_test+= $(SRC_PATH)/../test/utest.c  
#endif

#if build armv7a
#LOCAL_CFLAGS 	+= -mfpu=neon
#include $(LOCAL_PATH)/uavs3d_armv7a.mk
#elif build arm64
include $(LOCAL_PATH)/uavs3d_arm64.mk
#endif

LOCAL_SRC_FILES := $(uavs3d_srcs_c) $(uavs3d_srcs_arm) $(uavs3d_srcs_test)

#include $(BUILD_SHARED_LIBRARY)
#include $(BUILD_STATIC_LIBRARY)
include $(BUILD_EXECUTABLE)
