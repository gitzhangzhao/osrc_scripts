#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：编译并安装 U-Boot
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
if [ "`ls -A ${ZN_UBOOT_DIR}`" = "" ]; then
    error_exit "Can't find the source code of u-boot"
else
    cd ${ZN_UBOOT_DIR}
fi

# => Building the U-Boot bootloader is a part of the Xilinx design flow.
echo_info "Build U-Boot on the ${ZN_UBOOT_DIR}"
make ${MAKE_JOBS}
if [ $? -eq 0 ]; then
    ###
    # 1. U-Boot normally
    ###
    cp ${ZN_UBOOT_DIR}/u-boot ${ZN_TARGET_DIR}/u-boot.elf

    ###
    # 2. U-Boot SPL
    ###
    if [ -f "${ZN_UBOOT_DIR}/u-boot.img" ]; then
        cp ${ZN_UBOOT_DIR}/u-boot.img        ${ZN_TARGET_DIR}
        cp ${ZN_UBOOT_DIR}/spl/boot.bin      ${ZN_TARGET_DIR}
    fi

    echo_info "U-Boot - Build OK"
else
    error_exit "U-Boot - Build Failed"
fi

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
