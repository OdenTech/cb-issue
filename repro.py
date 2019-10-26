#!/usr/bin/python3 -u

from contextlib import contextmanager
from sh import (
        file,
        losetup
)

IMAGE = "/img/disk.img"

@contextmanager
def losetup_ctxmgr():
    args = ["-f", "--show", "--offset", "0", "--sizelimit", "50000000000"]
    args.append(IMAGE)
    device = losetup(*args).stdout.decode("utf8").strip()
    yield device
    losetup("-d", device)

# @contextmanager
# def device_mount_ctxmgr(device):
#     mountpoint = mkdtemp()
#     mount(device, mountpoint)
#     yield mountpoint
#     umount(mountpoint)
#     os.rmdir(mountpoint)
# 
# @contextmanager
# def mount_ctx_mgr():
#     with losetup_ctxmgr() as device:
#         with device_mount_ctxmgr(device) as mountpoint:
#             yield mountpoint

def main():
    with losetup_context_manager() as device:
        out = file("-s", device).stdout.decode("utf8").strip()
        print(out)

if __name__ == "__main__":
    main()
