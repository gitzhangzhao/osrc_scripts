#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：1. 清除配置文件和编译中间结果
#           2. 重新配置内核
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
if [ "`ls -A ${ZN_KERNEL_DIR}`" = "" ]; then
    error_exit "Can't find the source code of kernel"
else
    cd ${ZN_KERNEL_DIR}
fi

# => 1. Cleaning the Sources
echo_info "To delete all build products as well as the configuration"
make distclean || error_exit "Failed to make distclean"

# => 2. To configure the sources for the intended target.
echo_info "Configure Linux kernel on the ${ZN_KERNEL_DIR}"
make ${ZN_LINUX_KERNEL_DEFCONFIG} || error_exit "Failed to make ${ZN_LINUX_KERNEL_DEFCONFIG}"

# => 3. Prepare for compiling the source code
echo_info "Prepare for compiling the source code"
make prepare scripts || error_exit "Failed to make prepare scripts"

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
