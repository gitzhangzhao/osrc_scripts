#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：1. 编译并安装内核
#           2. 编译并安装设备树
#           3. 编译并安装内核模块（注意：需要先准备好根文件系统）
# 版 本 号：V1.0
###############################################################################
# => Setting The Development Environment Variables
if [ ! "${ZN_CONFIG_DONE}" ];then
    echo "[ERROR] Please source the settings64.sh script first" && exit 1
fi

# => Filename of the running script.
ZN_SCRIPT_NAME="$(basename ${BASH_SOURCE})"

###############################################################################
# => The beginning
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Starting ${ZN_SCRIPT_NAME}"

# => Make sure the source is there
if [ "`ls -A ${ZN_KERNEL_DIR}`" = "" ]; then
    error_exit "Can't find the source code of kernel"
else
    cd ${ZN_KERNEL_DIR}
fi

# => Make sure the target directory is there
[[ ! "${ZN_TARGET_DIR}" ]] && error_exit "Can't find the target directory"

# => 1. Compiling the Kernel
echo_info "Building the kernel image on the ${ZN_KERNEL_DIR}"
make ${MAKE_JOBS} UIMAGE_LOADADDR=0x8000 uImage
if [ $? -eq 0 ]; then
    echo_info "Installing the Kernel Image"
    cp -a ${ZN_KERNEL_DIR}/arch/arm/boot/zImage ${ZN_TARGET_DIR}
    cp -a ${ZN_KERNEL_DIR}/arch/arm/boot/uImage ${ZN_TARGET_DIR}
    cp -a ${ZN_KERNEL_DIR}/arch/arm/boot/uImage ${ZN_TARGET_DIR}/uImage.bin
else
    error_exit "Kernel Image - Build Failed"
fi

# => 2. Compiling the Device Tree Binaries
echo_info "Building the Device Tree Binaries on the ${ZN_DTS_DIR}"

${ZN_DTC_DIR}/dtc -I dts -O dtb -o ${ZN_DTB_DIR}/${ZN_DTB_NAME} ${ZN_DTS_DIR}/${ZN_DTS_NAME}
if [ $? -eq 0 ]; then
    echo_info "The Device Tree - Build OK"
else
    error_exit "The Device Tree - Build Failed"
fi

# => 3. Compiling the Kernel Modules
echo_info "Building the Kernel Modules on the ${ZN_KERNEL_DIR}"

make ${MAKE_JOBS} modules
if [ $? -eq 0 ]; then
    echo_info "Installing the Kernel Modules"

    sudo rm -rf ${ZN_ROOTFS_MOUNT_POINT}/*
    sudo tar zxf ${ZN_TARGET_DIR}/rootfs.tar.gz -C ${ZN_ROOTFS_MOUNT_POINT}
    sudo rm -rf ${ZN_ROOTFS_MOUNT_POINT}/lib/modules/

    sudo make ${MAKE_JOBS} ARCH=arm INSTALL_MOD_PATH=${ZN_ROOTFS_MOUNT_POINT} modules_install
    if [ $? -eq 0 ]; then
        sudo rm ${ZN_TARGET_DIR}/rootfs.tar.gz
        sudo tar zcf ${ZN_TARGET_DIR}/rootfs.tar.gz -C ${ZN_ROOTFS_MOUNT_POINT} .
        sudo rm -rf ${ZN_ROOTFS_MOUNT_POINT}/*
        echo_info "The Kernel Modules - Install OK"
    else
        sudo rm -rf ${ZN_ROOTFS_MOUNT_POINT}/*
        error_exit "The Kernel Modules - Install Failed"
    fi

else
    error_exit "Kernel Modules - Build Failed"
fi

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
