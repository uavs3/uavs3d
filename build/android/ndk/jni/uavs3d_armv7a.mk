
ARMV7_SRC_PATH:=../../../../source/decore/armv7

uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/armv7.c
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/def_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/pixel_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/inter_pred_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/intra_pred_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/deblock_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/alf_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/sao_armv7.c
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/sao_kernel_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/itrans_dct8_dst7_armv7.S
uavs3d_srcs_arm  += $(ARMV7_SRC_PATH)/dct2_armv7.S
