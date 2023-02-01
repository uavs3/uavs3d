
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


LOCAL_CFLAGS    += -O3 -fPIC -std=gnu99 -I../../../source/decore

### To support 10bit streams decoding: edit it to -DCOMPILE_10BIT=1
LOCAL_CFLAGS	+= -DCOMPILE_10BIT=0

ifeq ($(TARGET_ARCH),arm)
    ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
        # build armv7a
        LOCAL_CFLAGS += -mfpu=neon -D_armv7a
        include $(LOCAL_PATH)/uavs3d_armv7a.mk
    endif
endif

ifeq ($(TARGET_ARCH),arm64)
    # build arm64
    LOCAL_CFLAGS += -D_arm64
    include $(LOCAL_PATH)/uavs3d_arm64.mk
endif

ifeq ($(TARGET_ARCH),x86)
    # build x86
    LOCAL_CFLAGS += -msse4.2 -mavx2
    include $(LOCAL_PATH)/uavs3d_sse2.mk
    include $(LOCAL_PATH)/uavs3d_avx2.mk
endif

ifeq ($(TARGET_ARCH),x86_64)
    # build x86_64
    LOCAL_CFLAGS += -msse4.2 -mavx2
    include $(LOCAL_PATH)/uavs3d_sse2.mk
    include $(LOCAL_PATH)/uavs3d_avx2.mk
endif

LOCAL_SRC_FILES := $(uavs3d_srcs_c) $(uavs3d_srcs_arm) $(uavs3d_srcs_sse) $(uavs3d_srcs_avx) $(uavs3d_srcs_test)
