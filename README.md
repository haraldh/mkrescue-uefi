# mkrescue-uefi
Creates a custom BOOTX64.EFI from a linux kernel, initrd and kernel cmdline

Lately Kay Sievers and David Herrmann created a UEFI loader stub, which starts a linux kernel with an initrd and a kernel command line, which are COFF sections of the executable. This enables us to create single UEFI executable with a standard distribution kernel, a custom initrd and our own kernel command line attached.

Of course booting a linux kernel directly from the UEFI has been possible before with the kernel EFI stub. But to add an initrd and kernel command line, this had to be specified at kernel compile time.

To demonstrate this feature and have a useful product, I created a shell script, which creates a “rescue” image on Fedora with the rescue kernel and rescue initrd. The kernel command line “rd.auto” instructs dracut to assemble all devices, while waiting 20 seconds for device appearance “rd.retry=20″ and drop to a final shell because “root=/dev/failme” is specified (which does not exist of course). Now in this shell you can fsck your devices, mount them and repair your system.

To run the script, you have to install gummiboot >= 46 and binutils.
```
# yum install gummiboot binutils
```

Run the script:
```
# bash mkrescue-uefi.sh BOOTX64.EFI
```

Copy BOOTX64.EFI to e.g. a USB stick to EFI/BOOT/BOOTX64.EFI in the FAT boot partition and point your BIOS to boot from the USB stick.

Voilà! A rescue USB stick with just one file! :-)
