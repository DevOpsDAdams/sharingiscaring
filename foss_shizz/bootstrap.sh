#!/bin/bash

cd /

echo "Creating File Systems in EXT3"
for x in /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf; do mkfs.ext3 $x; done

echo "Creating /boot"
mv boot boot.old
mkdir boot

echo "Creating /boot Mount Point"
mount -t ext3 /dev/sdb /boot
mv /boot.old/* /boot/.
rmdir boot.old
chmod 555 /boot

echo "Adding /boot to fstab"
echo "/dev/sdb    /boot       ext3    defaults        0   0" >> /etc/fstab

echo "Creating /var"
mv /var /var.old
mkdir var

echo "Creating /var Mount Point"
mount -t ext3 /dev/sdc /var
mv /var.old/* /var
rmdir /var.old

echo "Adding /var to fstab"
echo "/dev/sdc    /var        ext3    defaults        0   0" >> /etc/fstab

echo "Creating /opt"
mv /opt /opt.old
mkdir /opt
mount -t ext3 /dev/sdd /opt
mv /opt.old/* /opt/.
rmdir /opt.old

echo "Adding /opt to fstab"
echo "/dev/sdd    /opt        ext3    defaults        0   0" >> /etc/fstab

echo "Creating /home"
mv /home /home.old
mkdir /home
mount -t ext3 /dev/sdf /home
mv /home.old/* /home/.
rmdir /home.old

echo "Adding /home to fstab"
echo "/dev/sdf    /home        ext3    defaults        0   0" >> /etc/fstab
