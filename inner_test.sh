#!/bin/sh -ex

losetup --find --show --partscan /mnt/disk.img
losetup --detach-all

echo "SUCCESS!"
