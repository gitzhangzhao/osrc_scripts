#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：创建系统安装镜像
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

# => Make sure the following files are needed.
targets=(                          \
    "zynq_fsbl.elf"                \
    "system.bit"                   \
    "u-boot.elf"                   \
    "uImage"                       \
    "devicetree.dtb"               \
    "rootfs.tar.gz"                \
    )

for target in "${targets[@]}"; do
    [[ ! -f "${ZN_TARGET_DIR}/${target}" ]] && error_exit "Target cannot be found: ${target}."
done

# => Make sure the target dir is there
DIRECTORIES=(                      \
    "boot"                         \
    "rootfs"                       \
    )

for DIR in ${DIRECTORIES[@]}; do
    [[ ! -d "${ZN_IMGS_DIR}/${DIR}" ]] && mkdir -p ${ZN_IMGS_DIR}/${DIR}
done

# => Setting Zynq-7000 Development Environment Variables
if [ -f "${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh" ]; then
    source ${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh
else
    error_exit "Could not find file ${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh"
fi

# =>
echo_info "1. Generate the boot image for sdcard mode"

BIF_FILE=${ZN_TARGET_DIR}/sd_image.bif

echo "//arch = zynq; split = false; format = BIN"          > ${BIF_FILE}
echo "the_ROM_image:"                                      >>${BIF_FILE}
echo "{"                                                   >>${BIF_FILE}
echo "  [bootloader]${ZN_TARGET_DIR}/zynq_fsbl.elf"        >>${BIF_FILE}
echo "  ${ZN_TARGET_DIR}/system.bit"                       >>${BIF_FILE}
echo "  ${ZN_TARGET_DIR}/u-boot.elf"                       >>${BIF_FILE}
echo "}"                                                   >>${BIF_FILE}

bootgen -image ${BIF_FILE} -o ${ZN_IMGS_DIR}/boot/BOOT.bin -w on

# =>
echo_info "2. Linux kernel with modified header for U-Boot"
cp ${ZN_TARGET_DIR}/uImage ${ZN_IMGS_DIR}/boot/uImage

# =>
echo_info "3. Device tree blob"
cp ${ZN_TARGET_DIR}/devicetree.dtb ${ZN_IMGS_DIR}/boot/devicetree.dtb

# =>
echo_info "4. Generate the ${ZN_ROOTFS_TYPE} Root filesystem"
cp ${ZN_TARGET_DIR}/rootfs.tar.gz ${ZN_IMGS_DIR}/rootfs/rootfs.tar.gz

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
