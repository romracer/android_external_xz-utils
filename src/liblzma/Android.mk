LOCAL_PATH:= $(call my-dir)

xz_gen := $(abspath $(TARGET_OUT_INTERMEDIATES)/STATIC_LIBRARIES/liblzma_intermediates)

xz-utils_prepare := $(xz_gen)/config.h
$(xz-utils_prepare): $(LOCAL_PATH)/../../config.h.$(TARGET_ARCH)
	@mkdir -p $(@D)
	@cat $^ > $@
	+touch $@

# ========================================================
# liblzma.a
# ========================================================
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	../common/tuklib_cpucores.c \
	../common/tuklib_physmem.c \
	common/common.c \
	common/block_util.c \
	common/easy_preset.c \
	common/filter_common.c \
	common/hardware_cputhreads.c \
	common/hardware_physmem.c \
	common/index.c \
	common/stream_flags_common.c \
	common/vli_size.c \
	common/alone_encoder.c \
	common/block_buffer_encoder.c \
	common/block_encoder.c \
	common/block_header_encoder.c \
	common/easy_buffer_encoder.c \
	common/easy_encoder.c \
	common/easy_encoder_memusage.c \
	common/filter_buffer_encoder.c \
	common/filter_encoder.c \
	common/filter_flags_encoder.c \
	common/index_encoder.c \
	common/stream_buffer_encoder.c \
	common/stream_encoder.c \
	common/stream_encoder_mt.c \
	common/stream_flags_encoder.c \
	common/vli_encoder.c \
	common/alone_decoder.c \
	common/auto_decoder.c \
	common/block_buffer_decoder.c \
	common/block_decoder.c \
	common/block_header_decoder.c \
	common/easy_decoder_memusage.c \
	common/filter_buffer_decoder.c \
	common/filter_decoder.c \
	common/filter_flags_decoder.c \
	common/index_decoder.c \
	common/index_hash.c \
	common/outqueue.c \
	common/stream_buffer_decoder.c \
	common/stream_decoder.c \
	common/stream_flags_decoder.c \
	common/vli_decoder.c \
	check/check.c \
	check/crc32_fast.c \
	check/crc32_table.c \
	check/crc64_fast.c \
	check/crc64_table.c \
	check/sha256.c \
	lz/lz_encoder.c \
	lz/lz_encoder_mf.c \
	lz/lz_decoder.c \
	lzma/fastpos_table.c \
	lzma/lzma_encoder.c \
	lzma/lzma_encoder_presets.c \
	lzma/lzma_encoder_optimum_fast.c \
	lzma/lzma_encoder_optimum_normal.c \
	lzma/lzma_decoder.c \
	lzma/lzma2_encoder.c \
	lzma/lzma2_decoder.c \
	rangecoder/price_table.c \
	delta/delta_common.c \
	delta/delta_encoder.c \
	delta/delta_decoder.c \
	simple/simple_coder.c \
	simple/simple_encoder.c \
	simple/simple_decoder.c \
	simple/x86.c \
	simple/powerpc.c \
	simple/ia64.c \
	simple/arm.c \
	simple/armthumb.c \
	simple/sparc.c

LOCAL_C_INCLUDES += \
	$(xz_gen) \
	$(LOCAL_PATH)/../../ \
	$(LOCAL_PATH)/../common \
	$(LOCAL_PATH)/api \
	$(LOCAL_PATH)/check \
	$(LOCAL_PATH)/common \
	$(LOCAL_PATH)/delta \
	$(LOCAL_PATH)/lz \
	$(LOCAL_PATH)/lzma \
	$(LOCAL_PATH)/rangecoder \
	$(LOCAL_PATH)/simple \
	$(LOCAL_PATH)

LOCAL_CFLAGS += \
	-DHAVE_CONFIG_H \
	-std=c99

LOCAL_MODULE := liblzma
LOCAL_MODULE_TAGS := eng
LOCAL_PRELINK_MODULE := false

LOCAL_ADDITIONAL_DEPENDENCIES += $(xz-utils_prepare)

ifeq ($(XPOSED_BUILD_STATIC),true)
  include $(BUILD_STATIC_LIBRARY)
else
  include $(BUILD_SHARED_LIBRARY)
endif
