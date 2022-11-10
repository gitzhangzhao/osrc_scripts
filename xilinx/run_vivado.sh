#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：打开 Vivado 开发套件
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

# The Vivado Environment needs to be setup beforehand
if [ -f "${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh" ]; then
    source ${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh
else
    error_exit "Could not find file ${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh"
fi

# vivado.jou and vivado.log files
# 1. The vivado.jou file is a journal file which contains tcl commands.
# 2. The vivado.log file also contains the tcl commands captured from the GUI
# operations but also contains all the messages returned by Vivado.

# This will ensure that the .jou and .log files are placed in the project directory.
cd ${ZN_VIVADO_PROJECT_DIR}

# => Open the Vivado Development Environment
if [ -f "${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.xpr" ]; then
    vivado ${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.xpr > /dev/null 2>&1 &

elif [ -f "${ZN_VIVADO_PROJECT_DIR}/create_project.tcl" ]; then
    vivado -source ${ZN_VIVADO_PROJECT_DIR}/create_project.tcl > /dev/null 2>&1 &

else
    vivado > /dev/null 2>&1 &
fi

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
