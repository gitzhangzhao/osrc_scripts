#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：1. 清除配置文件和编译中间结果
#           2. 重新配置 U-Boot
#           3. 编译开发所需要的工具
# 版 本 号：V1.0
###############################################################################
# => Setting The Development Environment Variables
if [ ! "${ZN_CONFIG_DONE}" ];then
    echo "[ERROR] 请以“source settings64.sh”的方式执行 settings64.sh 脚本。" && exit 1
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

# => 1. Cleaning the Sources
echo_info "To delete all build products as well as the configuration"
make distclean || error_exit "Failed to make distclean"

# => 2. To configure the sources for the intended target.
echo_info "Configure u-boot on the ${ZN_UBOOT_DIR}"
make ${ZN_UBOOOT_DEFCONFIG} || error_exit "Failed to make ${ZN_UBOOOT_DEFCONFIG}"

# => 3. Prepare for compiling the source code
echo_info "Prepare for compiling the source code"
make tools || error_exit "Failed to make tools"

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
