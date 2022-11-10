#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：保存配置文件到硬盘
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
fi

# => To save bootloader config use the command :
echo_info "To save bootloader config"
make -C ${ZN_UBOOT_DIR} savedefconfig
if [ $? != 0 ]; then
    error_exit "Failed to save defconfig"
else
    cp ${ZN_UBOOT_DIR}/defconfig ${ZN_UBOOT_DIR}/configs/${ZN_UBOOOT_DEFCONFIG}
fi

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
