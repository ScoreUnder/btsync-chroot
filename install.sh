#!/bin/sh
dir=${1:?Pass the name of the directory to install to}
umask 022
mkdir -p -- "$dir/btsync_chroot/usr/lib" || exit
install -- run-btsync "$dir" || exit
dir=$dir/btsync_chroot

ln -s -- usr/lib "$dir/lib"
ln -s -- usr/lib "$dir/lib64"
ln -s -- lib "$dir/usr/lib64"

install -m1777 -d -- "$dir/tmp"

mkdir -- "$dir/dev"
(
    IFS=:
    for dev in null zero random urandom; do
        mknod -- "$dir/dev/$dev" c $(cat /sys/devices/virtual/mem/$dev/dev) || exit
    done
) || exit

for f in ld-2.20.so libcrypt.so.1 libc.so.6 libdl.so.2 libm.so.6 libpthread.so.0 librt.so.1; do
    cp -- "/lib/$f" "$dir/lib" || exit
done
ln -s -- ld-2.20.so "$dir/lib/ld-linux-x86-64.so.2"

mkdir -- "$dir/proc"

mkdir -p -- "$dir/var/lib/btsync"
chown -- nobody:nobody "$dir/var/lib/btsync"

cd -- "$dir/var/lib/btsync" || exit
wget http://download.getsyncapp.com/endpoint/btsync/os/linux-x64/track/stable -O btsync.tar.gz || exit
tar xzf btsync.tar.gz && rm btsync.tar.gz || exit
