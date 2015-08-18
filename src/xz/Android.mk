LOCAL_PATH:= $(call my-dir)

xz_gen := $(abspath $(TARGET_OUT_INTERMEDIATES)/EXECUTABLES/xz_intermediates)

xz-utils_prepare := $(xz_gen)/config.h
$(xz-utils_prepare): $(LOCAL_PATH)/../../config.h.$(TARGET_ARCH)
	@mkdir -p $(@D)
	@cat $^ > $@
	+touch $@

# ========================================================
# xz
# ========================================================
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	../common/tuklib_open_stdxxx.c \
	../common/tuklib_progname.c \
	../common/tuklib_exit.c \
	../common/tuklib_cpucores.c \
	../common/tuklib_mbstr_width.c \
	../common/tuklib_mbstr_fw.c \
	util.c \
	suffix.c \
	signals.c \
	options.c \
	mytime.c \
	message.c \
	main.c \
	list.c \
	hardware.c \
	file_io.c \
	coder.c \
	args.c
LOCAL_C_INCLUDES += \
	$(xz_gen) \
	$(LOCAL_PATH)/../../ \
	$(LOCAL_PATH)/../common \
	$(LOCAL_PATH)/../liblzma/api \
	$(LOCAL_PATH)/../liblzma/check \
	$(LOCAL_PATH)/../liblzma/common \
	$(LOCAL_PATH)/../liblzma/delta \
	$(LOCAL_PATH)/../liblzma/lz \
	$(LOCAL_PATH)/../liblzma/lzma \
	$(LOCAL_PATH)/../liblzma/rangecoder \
	$(LOCAL_PATH)/../liblzma/simple \
	$(LOCAL_PATH)

LOCAL_CFLAGS += \
	-DHAVE_CONFIG_H \
	-std=c99

LOCAL_MODULE := xz
LOCAL_MODULE_TAGS := eng
LOCAL_PRELINK_MODULE := false

ifeq ($(XPOSED_BUILD_STATIC),true)
  LOCAL_FORCE_STATIC_EXECUTABLE := true
  LOCAL_STATIC_LIBRARIES := libc liblzma
else
  LOCAL_SHARED_LIBRARIES := libc liblzma
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(xz-utils_prepare)

include $(BUILD_EXECUTABLE)
