LIBKERNELFLINGER_LOCAL_PATH := $(call my-dir)
include $(call all-subdir-makefiles)
LOCAL_PATH := $(LIBKERNELFLINGER_LOCAL_PATH)

include $(CLEAR_VARS)

PNG2C := $(HOST_OUT_EXECUTABLES)/png2c$(HOST_EXECUTABLE_SUFFIX)
GEN_IMAGES := $(LOCAL_PATH)/tools/gen_images.sh
GEN_FONTS := $(LOCAL_PATH)/tools/gen_fonts.sh

res_intermediates := $(call intermediates-dir-for,STATIC_LIBRARIES,libkernelflinger)

font_res := $(res_intermediates)/res/font_res.h
img_res := $(res_intermediates)/res/img_res.h

$(LOCAL_PATH)/ui_font.c: $(font_res)
$(LOCAL_PATH)/ui_image.c: $(img_res)

ifndef TARGET_KERNELFLINGER_IMAGES_DIR
TARGET_KERNELFLINGER_IMAGES_DIR := $(LOCAL_PATH)/res/images/
endif
ifndef TARGET_KERNELFLINGER_FONT_DIR
TARGET_KERNELFLINGER_FONT_DIR := $(LOCAL_PATH)/res/fonts/
endif

KERNELFLINGER_IMAGES := $(wildcard $(TARGET_KERNELFLINGER_IMAGES_DIR)/*.png)
KERNELFLINGER_FONTS := $(wildcard $(TARGET_KERNELFLINGER_FONT_DIR)/*.png)

$(img_res): $(KERNELFLINGER_IMAGES) $(PNG2C) $(GEN_IMAGES)
	$(hide) mkdir -p $(dir $@)
	$(hide) export PATH=$(HOST_OUT_EXECUTABLES):$$PATH; $(GEN_IMAGES) $(TARGET_KERNELFLINGER_IMAGES_DIR) $@

$(font_res): $(KERNELFLINGER_FONTS) $(PNG2C) $(GEN_FONTS)
	$(hide) mkdir -p $(dir $@)
	$(hide) export PATH=$(HOST_OUT_EXECUTABLES):$$PATH; $(GEN_FONTS) $(TARGET_KERNELFLINGER_FONT_DIR) $@

LOCAL_MODULE := libkernelflinger-$(TARGET_BUILD_VARIANT)
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/../include/libkernelflinger
LOCAL_CFLAGS := $(KERNELFLINGER_CFLAGS)
LOCAL_STATIC_LIBRARIES := $(KERNELFLINGER_STATIC_LIBRARIES)

ifeq ($(KERNELFLINGER_ALLOW_UNSUPPORTED_ACPI_TABLE),true)
    LOCAL_CFLAGS += -DALLOW_UNSUPPORTED_ACPI_TABLE
endif

ifeq ($(KERNELFLINGER_USE_WATCHDOG),true)
    LOCAL_CFLAGS += -DUSE_WATCHDOG
endif

ifeq ($(KERNELFLINGER_USE_CHARGING_APPLET),true)
    LOCAL_CFLAGS += -DUSE_CHARGING_APPLET
endif

ifneq ($(KERNELFLINGER_IGNORE_RSCI),true)
    LOCAL_CFLAGS += -DUSE_RSCI
endif

ifeq ($(KERNELFLINGER_IGNORE_NOT_APPLICABLE_RESET),true)
    LOCAL_CFLAGS += -DIGNORE_NOT_APPLICABLE_RESET
endif

LOCAL_SRC_FILES := \
	android.c \
	efilinux.c \
	acpi.c \
	lib.c \
	options.c \
	security.c \
	signature.c \
	vars.c \
	ui.c \
	ui_font.c \
	ui_textarea.c \
	ui_image.c \
	ui_boot_menu.c \
	ui_confirm.c \
	log.c \
	em.c \
	gpt.c \
	storage.c \
	pci.c \
	mmc.c \
	ufs.c \
	sdcard.c \
	sdio.c \
	sata.c \
	uefi_utils.c \
	targets.c \
	smbios.c \
	oemvars.c \
	text_parser.c \
	watchdog.c \
	slot.c \
	life_cycle.c \
	qsort.c

ifeq ($(HAL_AUTODETECT),true)
    LOCAL_SRC_FILES += blobstore.c
endif

ifeq ($(TARGET_USE_TRUSTY),true)
    LOCAL_SRC_FILES += trusty.c
endif

ifneq ($(TARGET_UEFI_ARCH),x86_64)
    LOCAL_SRC_FILES += pae.c
endif

ifeq ($(TARGET_BOOT_SIGNER),)
    LOCAL_SRC_FILES += \
	aosp_sig.c \
	asn1.c
else
    LOCAL_SRC_FILES += $(TARGET_BOOT_SIGNER)_sig.c
endif

#LOCAL_SRC_FILES += ias_sig.c

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include/libkernelflinger \
		$(res_intermediates)

include $(BUILD_EFI_STATIC_LIBRARY)
