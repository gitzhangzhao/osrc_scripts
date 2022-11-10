#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：1. 卸载已经挂了的分区
#           2. 删除已有的分区
#           3. 重新分区
#           4. 格式化分区
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

# => Check dependencies.
type parted >/dev/null 2>&1 || { sudo apt-get update; sudo apt-get install parted; }

# 0、 Plug in your SD Card to your Linux machine.

# 1、Determine what device to use
until [[ -b /dev/${DISK} && ${DISK} != "hda" && ${DISK} != "sda" && ${DISK} != "sr*" ]]; do
    lsblk -o NAME,RM,SIZE,TYPE,MODEL,SERIAL | grep -vE "hda|sda|sr|loop|part|boot|rpmb"
    read -p "[INFO] Type device filename, or press <Enter> to exit: " DISK
    [[ -z ${DISK} ]] && exit 0
done

# 2. Remove All Existing Partitions
read -p "[WARNING] ALL DATA ON ${DISK} WILL BE ERASED!!! DO YOU WANT TO CONTINUE [y/N]? " REPLY
case ${REPLY} in
    y|Y)
        echo_info "Umount All Mounted Partitions"
        for part in $(lsblk /dev/${DISK} -o mountpoint --noheadings); do
            sudo umount ${part}
        done

        echo_info "Remove All Existing Partitions from ${DISK}"
        for PARTITION in $(sudo parted /dev/${DISK} print | awk '/^ /{print $1}'); do
            sudo parted -s /dev/${DISK} rm ${PARTITION}
        done

        echo_info "Choose the MBR Partitioning Standard"
        sudo parted -s /dev/$DISK mklabel msdos

        echo_info "Create the fat32 partition and make it bootable"
        sudo parted -s /dev/$DISK mkpart primary fat32 0% 100% && sudo parted -s /dev/$DISK set 1 boot on

        echo_info "Re-read The Partition Table Without Rebooting Linux System"
        sudo partprobe /dev/$DISK && lsblk /dev/$DISK

        # Create a Filesystem on the New Partition
        for PARTITION in $(lsblk -l /dev/$DISK | grep part | awk '{print $1}'); do
            PARTNUM=${PARTITION##*[[:alpha:]]}
            case ${PARTNUM} in
                1)
                    echo_info "To format a FAT32 filesystem on /dev/${PARTITION} with a 'SDCARD' disk label"
                    sudo mkfs.vfat -F 32 -n "SDCARD" /dev/${PARTITION}
                    ;;
                *)
                    echo_warn "Extra unintended partition"
                    ;;
            esac
        done

        ;;
    *)
        ;;
esac

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
