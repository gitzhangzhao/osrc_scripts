#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：安装 JTAG 驱动
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

# => Setting Zynq-7000 Development Environment Variables
if [ -f "${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh" ]; then
    source ${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh
else
    error_exit "Could not find file ${ZN_SCRIPTS_DIR}/xilinx/export_xilinx_env.sh"
fi

# You may have noticed that during installation (see step 5 above) the option
# to install cable drivers is grayed out, with a note to check guide UG973.
# If you own a Xilinx Platform USB cable you will need to manually install them:
if [ -d "${XILINX_VIVADO}" ]; then
    cd ${XILINX_VIVADO}/data/xicom/cable_drivers/lin64/install_script/install_drivers/
    sudo ./install_drivers
else
    error_exit "找不到Vivado设计套件"
fi

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
