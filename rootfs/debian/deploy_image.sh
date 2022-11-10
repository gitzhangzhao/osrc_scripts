#!/bin/bash
###############################################################################
# 版    权：米联客
# 技术社区：www.osrc.cn
# 功能描述：部署系统镜像到 SD 卡
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

# 0、 Plug in your SD Card to your Linux machine.

# 1、Determine what device to use
until [[ -b /dev/${DISK} && ${DISK} != "hda" && ${DISK} != "sda" && ${DISK} != "sr*" ]]; do
    lsblk -o NAME,RM,SIZE,TYPE,MODEL,SERIAL | grep -vE "hda|sda|sr|loop|part"
    read -p "[INFO] Type device filename, or press <Enter> to exit: " DISK
    [[ -z ${DISK} ]] && exit 0
done

# 2、
echo_info "Umount All Mounted Partitions"
for part in $(lsblk /dev/${DISK} -o mountpoint --noheadings); do
    sudo umount ${part}
done

# 3、
BOOT_MOUNT_POINT=${ZN_SDCARD_MOUNT_POINT}/boot
ROOT_MOUNT_POINT=${ZN_SDCARD_MOUNT_POINT}/rootfs
mkdir -p ${BOOT_MOUNT_POINT} ${ROOT_MOUNT_POINT}

for PARTITION in $(lsblk -l /dev/$DISK | grep part | awk '{print $1}'); do
    PARTNUM=$( echo "$PARTITION" | tr -d "$DISK" | tr -cd "[0-9]" )
    case ${PARTNUM} in
        1)
            [[ $(lsblk -no FSTYPE /dev/${PARTITION}) != 'vfat' ]] && error_exit "no bootable device found"

            echo_info "mount the boot partition to ${BOOT_MOUNT_POINT}"
            sudo mount -t vfat /dev/${PARTITION} ${BOOT_MOUNT_POINT}

            echo_info "Install boot images to ${BOOT_MOUNT_POINT}"
            sudo rsync -rv ${ZN_IMGS_DIR}/boot/ ${BOOT_MOUNT_POINT} && sync

            echo_info "umount the boot partition from ${BOOT_MOUNT_POINT}"
            sudo umount ${BOOT_MOUNT_POINT}
            ;;
        2)
            [[ $(lsblk -no FSTYPE /dev/${PARTITION}) != 'ext4' ]] && error_exit "no rootfs partition found"

            echo_info "mount the rootfs partition to ${ROOT_MOUNT_POINT}"
            sudo mount -t ext4 /dev/${PARTITION} ${ROOT_MOUNT_POINT}

            if [ "`ls -A ${ROOT_MOUNT_POINT}`" != "lost+found" ]; then
                sudo umount ${ROOT_MOUNT_POINT}
                error_exit "The ROOTFS partition is dirty ,please clean it!"
            fi

            echo_info "Install rootfs images to ${ROOT_MOUNT_POINT}"
            sudo tar zxf ${ZN_IMGS_DIR}/rootfs/rootfs.tar.gz -C ${ROOT_MOUNT_POINT} && sync

            echo_info "umount the rootfs partition from ${ROOT_MOUNT_POINT}"
            sudo umount ${ROOT_MOUNT_POINT}
            ;;
        *)
            echo_warn "[WARNING] Extra unintended partition"
            ;;
    esac
done

# recovery

# => The end
echo_info "[ $(date "+%Y/%m/%d %H:%M:%S") ] Finished ${ZN_SCRIPT_NAME}"
###############################################################################
