#!/bin/bash -ex

dd if=/dev/zero of=/disk.img bs=1k count=1000
losetup -f /disk.img
mkfs -t ext2 /dev/loop0 100
mount -t ext2 /dev/loop0 /mnt
touch /mnt/foo
umount /dev/loop0
losetup -d /dev/loop0

echo "SUCCESS!"
