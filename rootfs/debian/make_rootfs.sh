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

# => 1. Install required packages on your pc
host_packages="debootstrap qemu-user-static qemu-system"
for package in ${host_packages} ; do
    dpkg-query -W -f='${Package}\n' | grep ^$package$ > /dev/null
    if [ $? != 0 ] ; then
        echo_info "Installing ${package}"
        sudo apt-get --assume-yes install ${package}
    fi
done

# => 2. Configuring an Debian/Ubuntu guest rootfs
# 2.1 Supported Architectures
# ARCH="armel"                                                 # ARM
  ARCH="armhf"                                                 # ARM with hardware FPU

# 2.2 Setup a distribution
# DISTRO="jessie"                                              # debian 8.x
  DISTRO="stretch"                                             # debian 9.x

# 2.3
  BASETGZ="rootfs.tar.gz"
  BUILDPLACE="${ZN_ROOTFS_DIR}/rootfs"

# 2.4
# MIRRORSITE="http://deb.debian.org/debian"                        # default
  MIRRORSITE="http://mirrors.huaweicloud.com/debian"

# 2.5
#######################################################################################
# [NOTE] The repository components are:
# Main - Officially supported software.
# Restricted - Supported software that is not available under a completely free license.
# Universe - Community maintained software, i.e. not officially supported software.
# Multiverse - Software that is not free.
#######################################################################################
  COMPONENTS="main,contrib,non-free"
  REPOSITORIS="main contrib non-free"

# 2.6 Add useful packages (https://pkgs.org/)
  EXTRA_PKGS="sudo,udev,apt-utils,dialog,locales,bash-completion,can-utils,i2c-tools,usbutils"
  EXTRA_PKGS="${EXTRA_PKGS},ethtool,net-tools,ifupdown,dhcpcd5,ssh,curl,wget,rsync,vim,parted"
  EXTRA_PKGS="${EXTRA_PKGS},dosfstools,build-essential"

# => 3. Checking if a File Exists
if [ -f ${ZN_ROOTFS_DIR}/${BASETGZ} ]; then
    echo_info "The ${BASETGZ} Normal already exists."
    read -p "Do you want to use the existing file system and exit [y/N]? " REPLY
    case ${REPLY} in
        y|Y)
            echo_info "Copy Root File System Image on ${ZN_TARGET_DIR}"
            sudo rm -rf ${ZN_TARGET_DIR}/rootfs.tar.gz
            sudo cp ${ZN_ROOTFS_DIR}/${BASETGZ} ${ZN_TARGET_DIR}/rootfs.tar.gz
            echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}" && exit 0
            ;;
        *)
            sudo rm -rf ${ZN_ROOTFS_DIR}/${BUILDPLACE}
            sudo rm -rf ${ZN_ROOTFS_DIR}/${BASETGZ}
            ;;
    esac
fi

# => 4. Create an Debian/Ubuntu guest rootfs (First Stage / Second Stage)
sudo qemu-debootstrap --arch=${ARCH} --components=${COMPONENTS}   \
    --include=${EXTRA_PKGS} ${DISTRO} ${BUILDPLACE} ${MIRRORSITE} \
    || error_exit " Could not create the debian/ubuntu base system"

###############################################################################
# mount stuff, you will need more often
sudo mount --bind /dev     ${BUILDPLACE}/dev
sudo mount --bind /dev/pts ${BUILDPLACE}/dev/pts
sudo mount --bind /proc    ${BUILDPLACE}/proc

###############################################################################

# => 6. Update and upgrade the system
cat << END | sudo chroot ${BUILDPLACE}

cat << EOF > /etc/apt/sources.list
  deb     ${MIRRORSITE}/          ${DISTRO}           ${REPOSITORIS}
# deb-src ${MIRRORSITE}/          ${DISTRO}           ${REPOSITORIS}

  deb     ${MIRRORSITE}/          ${DISTRO}-updates   ${REPOSITORIS}
# deb-src ${MIRRORSITE}/          ${DISTRO}-updates   ${REPOSITORIS}

  deb     ${MIRRORSITE}/          ${DISTRO}-backports ${REPOSITORIS}
# deb-src ${MIRRORSITE}/          ${DISTRO}-backports ${REPOSITORIS}

# deb     ${MIRRORSITE}-security/ ${DISTRO}/updates   ${REPOSITORIS}
# deb-src ${MIRRORSITE}-security/ ${DISTRO}/updates   ${REPOSITORIS}
EOF

END

# => 6. setup locales
sudo chroot ${BUILDPLACE} apt-get install -y locales dialog
sudo chroot ${BUILDPLACE} apt-get install -y language-pack-zh language-pack-zh-base
sudo chroot ${BUILDPLACE} /bin/sh -c "echo LANG="zh_CN.UTF-8" >> /etc/environment"
sudo chroot ${BUILDPLACE} /bin/sh -c "echo LANGUAGE="zh_CN:zh:en_US:en" >> /etc/environment"
sudo chroot ${BUILDPLACE} locale-gen zh_CN.UTF-8 en_US.UTF-8

# => 7. Customize rootfs

# ==> Changing password for root.
echo "root:root" | sudo chroot ${BUILDPLACE} chpasswd

# ==> Create a User Administrator (https://wiki.ubuntu.com/Security/Privileges)
USERNAME=osrc
PASSWORD=root
sudo chroot ${BUILDPLACE} adduser --disabled-password --gecos "" $USERNAME
sudo chroot ${BUILDPLACE} usermod -aG sudo    $USERNAME    # add to sudo group for root access
sudo chroot ${BUILDPLACE} usermod -aG tty     $USERNAME    # add to tty group for tty access
sudo chroot ${BUILDPLACE} usermod -aG dialout $USERNAME    # add to dialout group for UART access
echo "$USERNAME:$PASSWORD" | sudo chroot ${BUILDPLACE} chpasswd

# ==> Set the hostname
HOSTNAME="${DISTRO}-${ARCH}"
echo ${HOSTNAME} | sudo tee ${BUILDPLACE}/etc/hostname

# ==> Set minimal hosts {{{
cat << END | sudo chroot ${BUILDPLACE}

cat > /etc/hosts << EOF
127.0.0.1    localhost
127.0.1.1    $HOSTNAME
EOF

END
# }}}

# ==> Configure networking:
cat << END | sudo chroot ${BUILDPLACE}

cat << EOF > /etc/network/interfaces
######################################################################
# /etc/network/interfaces -- configuration file for ifup(8), ifdown(8)
# See the interfaces(5) manpage for information on what options are
# available.
######################################################################

# We always want the loopback interface.
#
auto lo
iface lo inet loopback

# A. For DHCP on eth0
# auto eth0
# iface eth0 inet dhcp

# B. For static on eth0
# auto eth0
# iface eth0 inet static
#     address 192.168.0.42
#     network 192.168.0.0
#     netmask 255.255.255.0
#     broadcast 192.168.0.255
#     gateway 192.168.0.1

EOF

END

# => System update and upgrade
sudo chroot ${BUILDPLACE} apt-get update
# sudo chroot ${BUILDPLACE} apt-get -q -y upgrade

# => System cleaning
sudo chroot ${BUILDPLACE} apt-get -q -y autoremove
sudo chroot ${BUILDPLACE} apt-get -q -y autoclean

###############################################################################
[ ! -z ${BUILDPLACE} ] && sudo umount ${BUILDPLACE}/proc
[ ! -z ${BUILDPLACE} ] && sudo umount ${BUILDPLACE}/dev/pts
[ ! -z ${BUILDPLACE} ] && sudo umount ${BUILDPLACE}/dev
###############################################################################
# => Binary Tarball
sudo tar zcf ${ZN_ROOTFS_DIR}/${BASETGZ} -C ${BUILDPLACE} .
sudo cp ${ZN_ROOTFS_DIR}/${BASETGZ} ${ZN_TARGET_DIR}/rootfs.tar.gz
sudo rm -rf ${BUILDPLACE}

# => The end
print_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}\n"
###############################################################################
