---
title: "Compressed ramdisk"
permalink: /docs/ram-disk/
excerpt: "Setting up a compressed RAM disk"
toc: true
---

Since our boards are a bit limited on the RAM usage but we still want to perform fuzzing tests inside of a ramdisk, I decided to use the kernel module zram. ZRAM allows you to [create compressed block devices](https://www.kernel.org/doc/Documentation/blockdev/zram.txt) which reside in the RAM and are compressing data on-the-fly. I didn't measure the performance impact of it, but I guess that the impact shouldn't be that much.

## Setup a ramdisk
The following script reloads the kernel module, sets up a 700M compressed ramdisk, sets up the according file system on the ramdisk and mounts it.
```bash
sudo mkdir /fuzzing
sudo rmmod zram
sudo modprobe zram num_devices=1
echo 700M | sudo tee /sys/block/zram0/disksize
sudo mke2fs -q -m 0 -b 4096 -O sparse_super -L zram /dev/zram0
sudo umount /fuzzing
sudo mount -o relatime,nosuid /dev/zram0 /fuzzing
```
To automate this process on reboot, consider using an entry in /etc/fstab or somehow run this script after the node booted up.