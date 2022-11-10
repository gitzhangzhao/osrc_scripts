#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：1. 清除配置文件和编译中间结果
#           2. 重新配置根文件系统
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

# => Try lsb_release, fallback with /etc/issue then uname command
distributions="(Debian|Ubuntu|RedHat|CentOS|openSUSE|SUSE)"
distribution=$(                                             \
    lsb_release -d 2>/dev/null | grep -Eo $distributions    \
    || grep -Eo $distributions /etc/issue 2>/dev/null       \
    || grep -Eo $distributions /etc/*-release 2>/dev/null   \
    || uname -s                                             \
    )

case ${distribution} in
    CentOS)
        # You have PERL_MM_OPT defined because Perl local::lib
        # is installed on your system. Please unset this variable
        # before starting Buildroot, otherwise the compilation of
        # Perl related packages will fail
        unset PERL_MM_OPT
        ;;
    *)
        ;;
esac

# => Make sure the source is there
if [ "`ls -A ${ZN_ROOTFS_DIR}`" = "" ]; then
    error_exit "Can't find the source code of buildroot"
else
    cd ${ZN_ROOTFS_DIR}
fi

# => 1. Cleaning the Sources
echo_info "To delete all build products as well as the configuration"
make distclean || error_exit "Failed to make distclean"

# => 2. To configure the sources for the intended target.
echo_info "Configure Buildroot on the ${ZN_ROOTFS_DIR}"
make ${ZN_BUILDROOT_DEFCONFIG} || error_exit "Failed to make ${ZN_BUILDROOT_DEFCONFIG}"

# => 3. Download all sources needed for offline-build
echo_info "Download all sources needed for offline-build"
make source || error_exit "Failed to make source"

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
