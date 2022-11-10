#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：保存配置文件到硬盘
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
[[ "`ls -A ${ZN_ROOTFS_DIR}`" = "" ]] && error_exit "Can't find the source code of buildroot"

# => To save Buildroot config use the command :
echo_info "To save buildroot config"
make -C ${ZN_ROOTFS_DIR} savedefconfig || error_exit "Failed to save defconfig"

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
