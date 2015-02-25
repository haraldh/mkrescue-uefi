#!/bin/bash

set -e

if ! [[ $1 ]]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

if [[ -f /etc/machine-id ]]; then
    read MACHINE_ID < /etc/machine-id
fi

if ! [[ $MACHINE_ID ]]; then
    echo "Could not determine your machine ID from /etc/machine-id." >&2
    echo "Please run 'systemd-machine-id-setup' as root. See man:machine-id(5)" >&2
    exit 1
fi

if [[ -d /boot/${MACHINE_ID}/0-rescue ]]; then
    KERNEL="/boot/${MACHINE_ID}/0-rescue/linux"
    INITRD="/boot/${MACHINE_ID}/0-rescue/initrd"
else
    KERNEL="/boot/vmlinuz-0-rescue-${MACHINE_ID}"
    INITRD="/boot/initramfs-0-rescue-${MACHINE_ID}.img"
fi

if ! [[ -f $KERNEL ]] || ! [[ -f $INITRD ]]; then
    [[ -f $KERNEL ]] || echo "Could not find $KERNEL" >&2
    [[ -f $INITRD ]] || echo "Could not find $INITRD" >&2
    exit 1
fi

trap '
    ret=$?;
    [[ $CMDLINE_DIR ]] && rm -rf -- "$CMDLINE_DIR";
    exit $ret;
    ' EXIT

readonly CMDLINE_DIR="$(mktemp -d -t cmdline.XXXXXX)"

echo -ne "rd.auto rd.retry=20 root=/dev/failme\x00" > "$CMDLINE_DIR/cmdline.txt"

objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline="$CMDLINE_DIR/cmdline.txt" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="$KERNEL" --change-section-vma .linux=0x40000 \
    --add-section .initrd="$INITRD" --change-section-vma .initrd=0x3000000 \
    /usr/lib/gummiboot/linuxx64.efi.stub "$1"

echo "Succesfully created '$1'"
echo "Now copy '$1' to a USB stick to EFI/BOOT/BOOTX64.EFI in the first (boot) FAT partition"
echo "and point your BIOS to boot from the USB stick"
