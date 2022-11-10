#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：配置开发所需要的环境变量
# 版 本 号：V1.0
###############################################################################
# => 确保使用 source settings64.sh 的方式来执行本脚本。
if [ ${BASH_SOURCE[0]} == "$0" ]; then
    echo "[ERROR] 请以“source settings64.sh”的方式执行本脚本。" && exit 1
fi

#------------------------------------------------------------------------------
# 项目基本目录
#------------------------------------------------------------------------------
# => Directory containing the running script (as required)
export ZN_SCRIPTS_DIR="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Import local function from common.sh
if [ -f "${ZN_SCRIPTS_DIR}/common.sh" ]; then
    source ${ZN_SCRIPTS_DIR}/common.sh
else
    echo "[ERROR] Could not find file '${ZN_SCRIPTS_DIR}/common.sh'." &&  return 1
fi

# => The Top Directory (as required)
export ZN_TOP_DIR="$(dirname $ZN_SCRIPTS_DIR)"
export ZN_TOP_NAME="$(basename $ZN_TOP_DIR)"

# => The Boards Directory (as required)
export ZN_BOARDS_DIR="${ZN_TOP_DIR}/boards"

# => The Sources Directory (as required)
export ZN_SOURCES_DIR="${ZN_TOP_DIR}/sources"

# => The Packages (as required)
export ZN_DOWNLOADS_DIR="${ZN_TOP_DIR}/packages"

# => Host tools, cross compiler, utilities (as required)
export ZN_TOOLS_DIR=${ZN_TOP_DIR}/tools

# => Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_BOARDS_DIR} ${ZN_SOURCES_DIR} ${ZN_DOWNLOADS_DIR} ${ZN_TOOLS_DIR}

#------------------------------------------------------------------------------
# 项目基本设置
#------------------------------------------------------------------------------
# => The Board Name
export ZN_BOARD_NAME="MZ7X"

# => The Board Directory
export ZN_BOARD_DIR="${ZN_BOARDS_DIR}/${ZN_BOARD_NAME}"

# => The Project Name ( 可选选项：buildroot、debian、ubuntu ）
export ZN_PROJECT_NAME="debian"

# => The Project Directory
export ZN_PROJECT_DIR="${ZN_BOARD_DIR}/${ZN_PROJECT_NAME}"

# => The Build Output Directory
export ZN_OUTPUT_DIR=${ZN_PROJECT_DIR}/output
export ZN_TARGET_DIR=${ZN_OUTPUT_DIR}/target
export ZN_ROOTFS_MOUNT_POINT=${ZN_OUTPUT_DIR}/rootfs
export ZN_SDCARD_MOUNT_POINT=${ZN_OUTPUT_DIR}/sdcard

# => The System Images Directory
export ZN_IMGS_DIR=${ZN_PROJECT_DIR}/images

# => Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_BOARD_DIR} ${ZN_PROJECT_DIR} ${ZN_OUTPUT_DIR} ${ZN_TARGET_DIR} \
    ${ZN_ROOTFS_MOUNT_POINT} ${ZN_SDCARD_MOUNT_POINT} ${ZN_IMGS_DIR}

#------------------------------------------------------------------------------
# 硬件设计
#------------------------------------------------------------------------------
# => Current Vivado/LabTool/SDK Version (Example:2015.4).
export VIVADO_VERSION="${VIVADO_VERSION:-2017.4}"

# => Vivado工程名称（根据项目需求进行修改）
export ZN_VIVADO_PROJECT_NAME=system

# => Vivado工程路径（根据项目需求进行修改）
export ZN_VIVADO_PROJECT_DIR="${ZN_PROJECT_DIR}/fpga/${ZN_VIVADO_PROJECT_NAME}"

# => SDK工程路径（根据项目需求进行修改）
export ZN_SDK_PROJECT_DIR="${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.sdk"

# => Block design name（根据项目需求进行修改）
export ZN_BD_NAME="system"

# => Vivado export a hardware description file for use whith the SDK
export ZN_HW_DESC_FILE_DIR="${ZN_SDK_PROJECT_DIR}/${ZN_BD_NAME}_wrapper_hw_platform_0"

# => Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_VIVADO_PROJECT_DIR}

#------------------------------------------------------------------------------
# 交叉编译工具
#------------------------------------------------------------------------------
# => ARCH指明目标体系架构，即编译好的内核运行在什么平台上，如x86、arm或mips等
export ARCH=arm

# => 设置交叉编译工具
# http://www.wiki.xilinx.com/Install+Xilinx+tools
export ZN_TOOLCHAIN_PATH=${ZN_TOOLS_DIR}/cross_compiler
if [ -d "${ZN_TOOLCHAIN_PATH}/bin" ]; then
    export PATH=$PATH:${ZN_TOOLCHAIN_PATH}/bin
    if which arm-linux-gnueabihf-gcc > /dev/null 2>&1 ; then
        export ZN_TOOLCHAIN_PREFIX=arm-linux-gnueabihf
        export CROSS_COMPILE=${ZN_TOOLCHAIN_PREFIX}-
    elif which arm-xilinx-linux-gnueabi-gcc > /dev/null 2>&1 ; then
        export ZN_TOOLCHAIN_PREFIX=arm-xilinx-linux-gnueabi
        export CROSS_COMPILE=${ZN_TOOLCHAIN_PREFIX}-
    else
        echo_error "Could not find the cross compiler" && return 1
    fi
else
    echo_error "Could not find the cross compiler" && return 1
fi

# => Scale the maximum concurrency with the number of CPUs.
# http://www.verydemo.com/demo_c131_i121360.html
NUMBER_THREADS=`cat /proc/cpuinfo | grep "processor" | wc -l`
# Do not run with really big numbers unless you want your machine to be dog-slow!
if [ ${NUMBER_THREADS} -le 8 ] ; then
    export MAKE_JOBS="-j${NUMBER_THREADS}"
    export PARALLEL_MAKE="-j${NUMBER_THREADS}"
else
    export MAKE_JOBS="-j`expr ${NUMBER_THREADS} / 2`"
    export PARALLEL_MAKE="-j`expr ${NUMBER_THREADS} / 2`"
fi

#------------------------------------------------------------------------------
# 系统设计
#------------------------------------------------------------------------------
# => the First Stage Boot Loader (FSBL)
export ZN_FSBL_NAME=zynq_fsbl

# => Device Tree
# ==> DTG (Device Tree Generator)
export ZN_DTG_DIR=${ZN_SOURCES_DIR}/dtg

# ==> DTS (Device Tree Source)
export ZN_DTS_NAME="system-top.dts"
export ZN_DTS_DIR=${ZN_PROJECT_DIR}/dts

# ==> DTB (Device Tree Blob)
export ZN_DTB_NAME="devicetree.dtb"
export ZN_DTB_DIR=${ZN_TARGET_DIR}

# ==> Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_DTG_DIR} ${ZN_DTS_DIR}

# => Build U-Boot
# ==> ssbl : this folder stores all the U-Boot code.
export ZN_UBOOT_DIR=${ZN_SOURCES_DIR}/u-boot
# The uImage target of the Linux kernel compilation needs a recent mkimage tool
# which is actually built during U-Boot compilation as explained further below.
# Ensure that one is included in PATH:
export PATH=${ZN_UBOOT_DIR}/tools:$PATH

# ==> Configure the bootloader for the Zynq target
export ZN_UBOOOT_DEFCONFIG=zynq_mz7x_defconfig

# ==> Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_UBOOT_DIR}

# => Build Linux
# ==> kernel : this folder stores the object files (not sources) of the kernel
# build process.
export ZN_KERNEL_DIR=${ZN_SOURCES_DIR}/kernel

# ==> DTC (Device Tree Compiler)
export ZN_DTC_DIR=${ZN_KERNEL_DIR}/scripts/dtc
export PATH=${ZN_DTC_DIR}:$PATH

# ==> Configure the Linux Kernel for the Zynq target
export ZN_LINUX_KERNEL_DEFCONFIG=xilinx_mz7x_defconfig

# ==> Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_KERNEL_DIR}

# => The root filesystem (buildroot, debian, ubuntu)
if [ ${ZN_PROJECT_NAME} == "ubuntu" ]; then
    export ZN_ROOTFS_TYPE="ubuntu"
    export ZN_ROOTFS_DIR=${ZN_SOURCES_DIR}/rootfs/${ZN_ROOTFS_TYPE}

elif [ ${ZN_PROJECT_NAME} == "debian" ]; then
    export ZN_ROOTFS_TYPE="debian"
    export ZN_ROOTFS_DIR=${ZN_SOURCES_DIR}/rootfs/${ZN_ROOTFS_TYPE}

elif [ ${ZN_PROJECT_NAME} == "buildroot" ]; then
    export ZN_ROOTFS_TYPE="buildroot"
    export ZN_ROOTFS_DIR=${ZN_SOURCES_DIR}/rootfs/${ZN_ROOTFS_TYPE}
    # setup Buildroot download cache directory
    export BR2_DL_DIR=${ZN_DOWNLOADS_DIR}/buildroot

    # ==> Configure the buildroot for the Zynq target
    export ZN_BUILDROOT_DEFCONFIG=zynq_mz7x_defconfig

    # => Ramdisk Constants
    export ZN_BLOCK_SIZE=1024
    export ZN_RAMDISK_SIZE="$((32 * 1024))" # 32MB

    # ==> Invoke a second make in the output directory, passing relevant variables
    # check that the output directory actually exists
    mkdir -p ${BR2_DL_DIR}

else
    echo_error "There is no root filesystem" && exit 1
fi

# ==> Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_ROOTFS_DIR}

#------------------------------------------------------------------------------
# Adding the Directory to the Path
#------------------------------------------------------------------------------
export PATH=${ZN_SCRIPTS_DIR}:$PATH

for dir in $( ls ${ZN_SCRIPTS_DIR}/ ); do
    if [ -d "${ZN_SCRIPTS_DIR}/${dir}" ]; then
        export PATH=${ZN_SCRIPTS_DIR}/${dir}:$PATH
    fi
done

if [ -d "${ZN_SCRIPTS_DIR}/rootfs/${ZN_ROOTFS_TYPE}" ]; then
    export PATH="${ZN_SCRIPTS_DIR}/rootfs/${ZN_ROOTFS_TYPE}":$PATH
fi

# => The end
export ZN_CONFIG_DONE="done"
