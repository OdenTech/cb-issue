#!/bin/sh -ex


dd if=/dev/zero of=/disk.img bs=1k count=1000
LOOPDEV=$(losetup -f)
losetup ${LOOPDEV} /disk.img
mkfs -t ext2 ${LOOPDEV} 100
mount -t ext2 ${LOOPDEV} /mnt
touch /mnt/foo
umount ${LOOPDEV}
losetup -d ${LOOPDEV}

echo "SUCCESS!"
