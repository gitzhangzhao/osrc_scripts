#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：1. 导入 system.bit
#           2. 导入 zynq_fsbl.elf
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

# => hw_platform
ZYNQ_HW_PLATFORM_DIR=${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.sdk/${ZN_BD_NAME}_wrapper_hw_platform_0
# => bitstream
ZYNQ_BITSTREAM=${ZYNQ_HW_PLATFORM_DIR}/${ZN_BD_NAME}_wrapper.bit
if [ ! -f "${ZYNQ_BITSTREAM}" ]; then
    error_exit "could not find file 'system.bit'"
fi
cp ${ZYNQ_BITSTREAM} ${ZN_TARGET_DIR}/system.bit

# => zynq_fsbl
ZYNQ_FSBL_DIR=${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.sdk/zynq_fsbl
# 确定fsbl.elf文件是否存在
if [ -f "${ZYNQ_FSBL_DIR}/Release/zynq_fsbl.elf" ]; then
    cp ${ZYNQ_FSBL_DIR}/Release/zynq_fsbl.elf ${ZN_TARGET_DIR}/zynq_fsbl.elf
elif [ -f "${ZYNQ_FSBL_DIR}/Debug/zynq_fsbl.elf" ]; then
    cp ${ZYNQ_FSBL_DIR}/Debug/zynq_fsbl.elf ${ZN_TARGET_DIR}/zynq_fsbl.elf
else
    error_exit "could not find file 'zynq_fsbl.elf'"
fi

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
