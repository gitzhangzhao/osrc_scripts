#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：编译安装根文件系统
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

# Note: You should never use make -jN with Buildroot

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

# => Compiling Buildroot
make
if [ $? -eq 0 ]; then
    if [ ${ZN_SOURCES_DIR}/rootfs/buildroot/output/images/rootfs.tar ]; then
        echo_info "Installing the buildroot Image"
        cp ${ZN_SOURCES_DIR}/rootfs/buildroot/output/images/rootfs.tar ${ZN_TARGET_DIR}/
        rm -f ${ZN_TARGET_DIR}/rootfs.tar.gz && gzip ${ZN_TARGET_DIR}/rootfs.tar

    elif [ ${ZN_SOURCES_DIR}/rootfs/buildroot/output/images/rootfs.tar.gz ]; then
        echo_info "Installing the buildroot Image"
        rm -f ${ZN_TARGET_DIR}/rootfs.tar.gz
        cp ${ZN_SOURCES_DIR}/rootfs/buildroot/output/images/rootfs.tar.gz ${ZN_TARGET_DIR}/

    else
        error_exit "Can't find rootfs.tar"
    fi
else
    error_exit "Buildroot - Build Failed"
fi

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
