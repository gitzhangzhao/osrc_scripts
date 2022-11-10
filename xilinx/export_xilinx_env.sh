#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：配置开发所需要的环境变量
# 版 本 号：V1.0
###############################################################################
# => Setting The Development Environment Variables
if [ ! "${ZN_CONFIG_DONE}" ];then
    echo "[ERROR] 请以“source settings64.sh”的方式执行 settings64.sh 脚本。" && exit 1
fi

# => 确保使用 source export_xilinx_env.sh 的方式来执行本脚本。
if [ ${BASH_SOURCE[0]} == "$0" ]; then
    echo "[ERROR] 请以“source export_xilinx_env.sh”的方式执行本脚本。" && exit 1
fi

# => Current Vivado/LabTool/SDK Version (Example:2015.4).
export VIVADO_VERSION="${VIVADO_VERSION:-2015.4}"

# => Set Xilinx installation path (Default: /opt/Xilinx/).
export XILINX="${XILINX:-/mnt/workspace/Xilinx}"

# => Vivado Design Suite
export XILINX_VIVADO=${XILINX}/Vivado/${VIVADO_VERSION}

# => Xilinx Software Development Kit (XSDK):
# (only needed to build the FSBL).
export XILINX_SDK=${XILINX}/SDK/${VIVADO_VERSION}

# => High-Level Synthesis (HLS)
# 注意: 2017.4及以后版本， HLS 与 Vivado 为同一目录
export XILINX_VIVADO_HLS=${XILINX}/Vivado_HLS/${VIVADO_VERSION}

# => the SDSoC Development Environment
export XILINX_SDX=${XILINX}/SDx/${VIVADO_VERSION}

# => Docnav
export XILINX_DOCNAV=${XILINX}/DocNav

# => The Vivado Environment needs to be setup beforehand
###
# Note: There are two settings files available in the Vivado toolset:
# settings64.sh for use on 64-bit machines with bash;
# settings64.csh for use on 64-bit machines with C Shell.
###
if [ -d "${XILINX_VIVADO}" ]; then
    source ${XILINX_VIVADO}/settings64.sh
else
    echo_error "找不到Vivado设计套件" && return 1
fi

###
# Fixed: librdi_common* not found executing vivado
# https://forums.xilinx.com/t5/Installation-and-Licensing/librdi-common-not-found-executing-vivado/td-p/536991
###
if [ -n "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=${XILINX_VIVADO}/lib/lnx64.o:$LD_LIBRARY_PATH
else
    export LD_LIBRARY_PATH=${XILINX_VIVADO}/lib/lnx64.o
fi

###
# Fixed: SDK (SWT issues in Eclipse)
###
# Try lsb_release, fallback with /etc/issue then uname command
distributions="(Debian|Ubuntu|RedHat|CentOS|openSUSE|SUSE)"
distribution=$(                                             \
    lsb_release -d 2>/dev/null | grep -Eo $distributions    \
    || grep -Eo $distributions /etc/issue 2>/dev/null       \
    || grep -Eo $distributions /etc/*-release 2>/dev/null   \
    || uname -s                                             \
    )

case ${distribution} in
    Ubuntu)
        export SWT_GTK3=0
        ;;
    *)
        ;;
esac

###
# Fixed: Docnav
###
if [ -n "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=${XILINX_DOCNAV}:$LD_LIBRARY_PATH
else
    export LD_LIBRARY_PATH=${XILINX_DOCNAV}
fi
