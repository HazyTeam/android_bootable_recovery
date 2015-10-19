# Copyright (C) 2007 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(call my-dir),$(call project-path-for,recovery))

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := fuse_sideload.c

LOCAL_CFLAGS := -O2 -g -DADB_HOST=0 -Wall -Wno-unused-parameter
LOCAL_CFLAGS += -D_XOPEN_SOURCE -D_GNU_SOURCE

LOCAL_MODULE := libfusesideload

LOCAL_STATIC_LIBRARIES := libcutils libc libmincrypt
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    adb_install.cpp \
    asn1_decoder.cpp \
    bootloader.cpp \
    device.cpp \
    fuse_sdcard_provider.c \
    install.cpp \
    recovery.cpp \
    roots.cpp \
    screen_ui.cpp \
    ui.cpp \
    verifier.cpp \

# External tools
LOCAL_SRC_FILES += \
	../../system/core/toolbox/dynarray.c \
    ../../system/core/toolbox/getprop.c \
    ../../system/core/toolbox/newfs_msdos.c \
    ../../system/core/toolbox/setprop.c \
    ../../system/core/toolbox/start.c \
    ../../system/core/toolbox/stop.c \
    ../../system/core/toolbox/wipe.c \
    ../../system/vold/vdc.c

LOCAL_MODULE := recovery

LOCAL_FORCE_STATIC_EXECUTABLE := true

ifeq ($(HOST_OS),linux)
LOCAL_REQUIRED_MODULES := mkfs.f2fs
endif

RECOVERY_API_VERSION := 3
RECOVERY_FSTAB_VERSION := 2
LOCAL_CFLAGS += -DRECOVERY_API_VERSION=$(RECOVERY_API_VERSION)
LOCAL_CFLAGS += -Wno-unused-parameter

LOCAL_C_INCLUDES += \
    system/vold \
    system/extras/ext4_utils \
    system/core/adb \

LOCAL_STATIC_LIBRARIES := \
    libext4_utils_static \
    libmake_ext4fs_static \
    libminizip_static \
    libsparse_static \
    libfsck_msdos \
    libminipigz \
    libreboot_static \
    libvoldclient \
    libsdcard \
    libminzip \
    libz \
    libmtdutils \
    libmincrypt \
    libminadbd \
    libbusybox \
    libfusesideload \
    libminui \
    libpng \
    libfs_mgr \
    libbase \
    libcutils \
    liblog \
    libselinux \
    libstdc++ \
    libm \
    libc \
    libext2_blkid \
    libext2_uuid

# OEMLOCK support requires a device specific liboemlock be supplied.
# See comments in recovery.cpp for the API.
ifeq ($(TARGET_HAVE_OEMLOCK), true)
    LOCAL_CFLAGS += -DHAVE_OEMLOCK
    LOCAL_STATIC_LIBRARIES += liboemlock
endif

#ifeq ($(TARGET_USERIMAGES_USE_EXT4), true)
    LOCAL_CFLAGS += -DUSE_EXT4
    LOCAL_C_INCLUDES += system/extras/ext4_utils
    LOCAL_STATIC_LIBRARIES += libext4_utils_static libz
endif

LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin

ifeq ($(TARGET_RECOVERY_UI_LIB),)
  LOCAL_SRC_FILES += default_device.cpp
else
  LOCAL_STATIC_LIBRARIES += $(TARGET_RECOVERY_UI_LIB)
endif

include $(BUILD_EXECUTABLE)

$(RECOVERY_SYMLINKS): RECOVERY_BINARY := $(LOCAL_MODULE)
$(RECOVERY_SYMLINKS):
	@echo "Symlink: $@ -> $(RECOVERY_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(RECOVERY_BINARY) $@

# Now let's do recovery symlinks
$(RECOVERY_BUSYBOX_SYMLINKS): BUSYBOX_BINARY := busybox
$(RECOVERY_BUSYBOX_SYMLINKS):
	@echo "Symlink: $@ -> $(BUSYBOX_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(BUSYBOX_BINARY) $@

include $(CLEAR_VARS)
LOCAL_MODULE := bu_recovery
LOCAL_MODULE_STEM := bu
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_SRC_FILES := \
    bu.cpp \
    backup.cpp \
    restore.cpp \
    messagesocket.cpp \
    roots.cpp
LOCAL_CFLAGS += -DMINIVOLD
LOCAL_CFLAGS += -Wno-unused-parameter
#ifeq ($(TARGET_USERIMAGES_USE_EXT4), true)
    LOCAL_CFLAGS += -DUSE_EXT4
    LOCAL_C_INCLUDES += system/extras/ext4_utils
    LOCAL_STATIC_LIBRARIES += libext4_utils_static libz liblz4-static
#endif
LOCAL_STATIC_LIBRARIES += \
    libsparse_static \
    libvoldclient \
    libz \
    libmtdutils \
    libminadbd \
    libminui \
    libfs_mgr \
    libtar \
    libcrypto_static \
    libselinux \
    libutils \
    libcutils \
    liblog \
    libm \
    libc \
    libext2_blkid \
    libext2_uuid

LOCAL_C_INCLUDES +=         	\
    system/core/fs_mgr/include	\
    system/core/include     	\
    system/core/libcutils       \
    system/vold                 \
    external/libtar             \
    external/libtar/listhash    \
    external/openssl/include    \
    external/zlib               \
    bionic/libc/bionic          \
    external/e2fsprogs/lib


include $(BUILD_EXECUTABLE)

# make_ext4fs
include $(CLEAR_VARS)
LOCAL_MODULE := libmake_ext4fs_static
LOCAL_MODULE_TAGS := optional
LOCAL_CFLAGS := -Dmain=make_ext4fs_main
LOCAL_SRC_FILES := ../../system/extras/ext4_utils/make_ext4fs_main.c
include $(BUILD_STATIC_LIBRARY)

# Minizip static library
include $(CLEAR_VARS)
LOCAL_MODULE := libminizip_static
LOCAL_MODULE_TAGS := optional
LOCAL_CFLAGS := -Dmain=minizip_main -D__ANDROID__ -DIOAPI_NO_64
LOCAL_C_INCLUDES := external/zlib
LOCAL_SRC_FILES := \
    ../../external/zlib/src/contrib/minizip/ioapi.c \
    ../../external/zlib/src/contrib/minizip/minizip.c \
    ../../external/zlib/src/contrib/minizip/zip.c
include $(BUILD_STATIC_LIBRARY)

# Reboot static library
include $(CLEAR_VARS)
LOCAL_MODULE := libreboot_static
LOCAL_MODULE_TAGS := optional
LOCAL_CFLAGS := -Dmain=reboot_main
LOCAL_SRC_FILES := ../../system/core/reboot/reboot.c
include $(BUILD_STATIC_LIBRARY)

# All the APIs for testing
include $(CLEAR_VARS)
LOCAL_MODULE := libverifier
LOCAL_MODULE_TAGS := tests
LOCAL_SRC_FILES := \
    asn1_decoder.cpp
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := verifier_test
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_MODULE_TAGS := tests
LOCAL_CFLAGS += -Wno-unused-parameter
LOCAL_SRC_FILES := \
    verifier_test.cpp \
    asn1_decoder.cpp \
    verifier.cpp \
    ui.cpp \
    messagesocket.cpp
LOCAL_STATIC_LIBRARIES := \
    libvoldclient \
    libmincrypt \
    libminui \
    libminzip \
    libcutils \
    libstdc++ \
    libc
LOCAL_C_INCLUDES += system/core/fs_mgr/include
include $(BUILD_EXECUTABLE)


include $(LOCAL_PATH)/minui/Android.mk \
    $(LOCAL_PATH)/minzip/Android.mk \
    $(LOCAL_PATH)/minadbd/Android.mk \
    $(LOCAL_PATH)/mtdutils/Android.mk \
    $(LOCAL_PATH)/tests/Android.mk \
    $(LOCAL_PATH)/tools/Android.mk \
    $(LOCAL_PATH)/edify/Android.mk \
    $(LOCAL_PATH)/uncrypt/Android.mk \
    $(LOCAL_PATH)/updater/Android.mk \
    $(LOCAL_PATH)/applypatch/Android.mk \
    $(LOCAL_PATH)/voldclient/Android.mk

endif
