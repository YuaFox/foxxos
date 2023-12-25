#!/bin/bash

set -e

set -u

DEBIAN_VERSION=12.4.0
ISOFILE=debian-netinst.iso
ISOFILE_FINAL=foxxos-netinst.iso
ISODIR=debian-iso
ISODIR_WRITE=$ISODIR-rw

if [ -e $ISOFILE ]; then
    echo 'ISO exists'
else
    echo 'Downloading Debian ISO'
    wget -O $ISOFILE https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-$DEBIAN_VERSION-amd64-netinst.iso
fi

sudo rm -rf debian-iso-rw 
sudo rm -f $ISOFILE_FINAL

echo 'mounting ISO9660 filesystem...'
# source: http://wiki.debian.org/DebianInstaller/ed/EditIso
[ -d $ISODIR ] || mkdir -p $ISODIR
sudo mount -o loop $ISOFILE $ISODIR

echo 'coping to writable dir...'
rm -rf $ISODIR_WRITE || true
[ -d $ISODIR_WRITE ] || mkdir -p $ISODIR_WRITE
rsync -a -H --exclude=TRANS.TBL $ISODIR/ $ISODIR_WRITE

echo 'unmount iso dir'
sudo umount $ISODIR

echo 'correcting permissions...'
chmod 755 -R $ISODIR_WRITE

echo 'installing packages'
mkdir foxxos.proton
cp -r /home/$USER/.steam/steam/steamapps/common/Proton\ 8.0/* patch/opt/foxxos.proton

echo 'copying files...'
cp preseed.cfg $ISODIR_WRITE/preseed.cfg
tar -cf patch.tar -C patch .
cp patch.tar $ISODIR_WRITE/patch.tar

echo 'edit isolinux/txt.cfg...'
sed 's/initrd.gz/initrd.gz file=\/cdrom\/preseed.cfg/' -i $ISODIR_WRITE/isolinux/txt.cfg

sudo mkdir irmod
cd irmod
sudo gzip -d < ../$ISODIR_WRITE/install.amd/initrd.gz | \
sudo cpio --extract --make-directories --no-absolute-filenames
sudo cp ../preseed.cfg preseed.cfg
sudo chown root:root preseed.cfg
sudo cp ../patch.tar patch.tar
sudo chown root:root patch.tar
sudo chmod o+w ../$ISODIR_WRITE/install.amd/initrd.gz
find . | cpio -H newc --create | \
        gzip -9 > ../$ISODIR_WRITE/install.amd/initrd.gz
sudo chmod o-w ../$ISODIR_WRITE/install.amd/initrd.gz
cd ../
sudo rm -rf irmod/

echo 'fixing MD5 checksums...'
pushd $ISODIR_WRITE
  md5sum $(find -type f) > md5sum.txt
popd

echo 'making hybrid ISO...'
xorriso -as mkisofs \
  -r -J -V "jessie" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot \
  -partition_offset 16 \
  -boot-load-size 4 \
  -boot-info-table \
  -isohybrid-mbr "/usr/lib/ISOLINUX/isohdpfx.bin" \
  -o $ISOFILE_FINAL \
  ./$ISODIR_WRITE
