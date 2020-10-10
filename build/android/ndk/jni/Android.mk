### This file is jni/Android.mk

LOCAL_PATH   := $(call my-dir)
SRC_PATH     := ../../../../source
INCLUDE_PATH := ../../../../source/decore

### Name of the local module
include $(LOCAL_PATH)/uavs3d_clear_vars.mk
LOCAL_MODULE            := uavs3d-static
LOCAL_MODULE_FILENAME   := libuavs3d
include $(LOCAL_PATH)/uavs3d_main.mk
include $(BUILD_STATIC_LIBRARY)

include $(LOCAL_PATH)/uavs3d_clear_vars.mk
LOCAL_MODULE            := uavs3d-shared
LOCAL_MODULE_FILENAME   := libuavs3d
LOCAL_LDLIBS:=-L$(SYSROOT)/usr/lib -lm -llog
LOCAL_LDFLAGS   += -fPIC
include $(LOCAL_PATH)/uavs3d_main.mk
include $(BUILD_SHARED_LIBRARY)


include $(LOCAL_PATH)/uavs3d_clear_vars.mk
LOCAL_MODULE            := uavs3d
LOCAL_LDLIBS:=-L$(SYSROOT)/usr/lib -lm -llog
LOCAL_CFLAGS    += -pie -fPIE
LOCAL_LDFLAGS   += -pie -fPIE
uavs3d_srcs_test+= $(SRC_PATH)/../test/utest.c
include $(LOCAL_PATH)/uavs3d_main.mk
include $(BUILD_EXECUTABLE)
