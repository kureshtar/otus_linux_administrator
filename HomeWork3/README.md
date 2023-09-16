# LVM

## Создание PV, VG, LV.

**[root@lvm ~]# pvcreate /dev/sdb**

Physical volume "/dev/sdb" successfully created.

**[root@lvm ~]# vgcreate vg_root /dev/sdb**

  Volume group "vg_root" successfully created
  
**[root@lvm ~]# lvcreate -n lv_root -l +100%FREE /dev/vg_root**

  Logical volume "lv_root" created.

## Создаю ФС

**[root@lvm ~]# mkfs.xfs /dev/vg_root/lv_root**

meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=655104 blks

         =                       sectsz=512   attr=2, projid32bit=1
         
         =                       crc=1        finobt=0, sparse=0

data     =                       bsize=4096   blocks=2620416, imaxpct=25

         =                       sunit=0      swidth=0 blks

naming   =version 2              bsize=4096   ascii-ci=0 ftype=1

log      =internal log           bsize=4096   blocks=2560, version=2

         =                       sectsz=512   sunit=0 blks, lazy-count=1

realtime =none                   extsz=4096   blocks=0, rtextents=0

## Монтирую

**[root@lvm ~]# mount /dev/vg_root/lv_root /mnt**

## Копирую все данные

**[root@lvm ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt**

xfsdump: using file dump (drive_simple) strategy

...

...

xfsdump: Dump Status: SUCCESS

xfsrestore: restore complete: 8 seconds elapsed

xfsrestore: Restore Status: SUCCESS

## Переконфигурация grub

**[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done**

**[root@lvm ~]# chroot /mnt/**

**[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg**

Generating grub configuration file ...

Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64

Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img

done

**[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done**

Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force

...

...

*** Creating image file ***

*** Creating image file done ***

*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***

## Замена в grub.cfg

**[root@lvm boot]# sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/g' /boot/grub2/grub.cfg**

**[root@lvm boot]# exit**

exit

**[root@lvm ~]# exit**

exit

## ребут

Script done on Thu 14 Sep 2023 07:09:32 PM UTC

Script started on Thu 14 Sep 2023 07:11:35 PM UTC

**[root@lvm ~]# lsblk**

NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT

sda                       8:0    0   40G  0 disk 

├─sda1                    8:1    0    1M  0 part 

├─sda2                    8:2    0    1G  0 part /boot

└─sda3                    8:3    0   39G  0 part 

  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  
  └─VolGroup00-LogVol00 253:2    0 37.5G  0 lvm  

sdb                       8:16   0   10G  0 disk 

└─vg_root-lv_root       253:0    0   10G  0 lvm  /

sdc                       8:32   0    2G  0 disk 

sdd                       8:48   0    1G  0 disk 

sde                       8:64   0    1G  0 disk 

## Удаляю старый VG и создаю новый

**[root@lvm ~]# lvremove /dev/VolGroup00/LogVol00**

Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y

  Logical volume "LogVol00" successfully removed

**[root@lvm ~]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00**


WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y

  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  
  Logical volume "LogVol00" created.

## Создаю ФС и монтирую для копирования файлов

**[root@lvm ~]# mkfs.xfs /dev/VolGroup00/LogVol00**

meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks

         =                       sectsz=512   attr=2, projid32bit=1

         =                       crc=1        finobt=0, sparse=0

data     =                       bsize=4096   blocks=2097152, imaxpct=25

         =                       sunit=0      swidth=0 blks

naming   =version 2              bsize=4096   ascii-ci=0 ftype=1

log      =internal log           bsize=4096   blocks=2560, version=2

         =                       sectsz=512   sunit=0 blks, lazy-count=1

realtime =none                   extsz=4096   blocks=0, rtextents=0

**[root@lvm ~]# mount /dev/VolGroup00/LogVol00 /mnt**

**[root@lvm ~]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt**

xfsrestore: using file dump (drive_simple) strategy

xfsrestore: version 3.1.7 (dump format 3.0)

...

...

xfsdump: Dump Status: SUCCESS

xfsrestore: restore complete: 8 seconds elapsed

xfsrestore: Restore Status: SUCCESS

## Переконфигурирую grub

**[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done**

**[root@lvm ~]# chroot /mnt/**

**[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg**

Generating grub configuration file ...

Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64

Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img

done

**[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done**

Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force

dracut module 'busybox' will not be installed, because command 'busybox' could not be found!

dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!

...

...

*** Creating image file ***

*** Creating image file done ***

*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***

## Из свободных дисков создаю PV, VG, LV (зеркало m1)

**[root@lvm boot]# pvcreate /dev/sdc /dev/sdd**

  Physical volume "/dev/sdc" successfully created.

  Physical volume "/dev/sdd" successfully created.

**[root@lvm boot]# vgcreate vg_var /dev/sdc /dev/sdd**
  
  Volume group "vg_var" successfully created

**[root@lvm boot]# lvcreate -L 950M -m1 -n lv_var vg_var**

  Rounding up size to full physical extent 952.00 MiB

  Logical volume "lv_var" created.

## Создаю ФС

**[root@lvm boot]# mkfs.ext4 /dev/vg_var/lv_var**

mke2fs 1.42.9 (28-Dec-2013)

Filesystem label=

OS type: Linux

Block size=4096 (log=2)

Fragment size=4096 (log=2)

Stride=0 blocks, Stripe width=0 blocks

60928 inodes, 243712 blocks

12185 blocks (5.00%) reserved for the super user

First data block=0

Maximum filesystem blocks=249561088

8 block groups

32768 blocks per group, 32768 fragments per group

7616 inodes per group

Superblock backups stored on blocks: 

 32768, 98304, 163840, 229376

Allocating group tables: done                            

Writing inode tables: done                            

Creating journal (4096 blocks): done

Writing superblocks and filesystem accounting information: done

**[root@lvm boot]# mount /dev/vg_var/lv_var /mnt**

**[root@lvm boot]# cp -aR /var/* /mnt/**

**[root@lvm boot]# rsy**

rsync                  rsyslogd               rsyslog-recover-qi.pl  

**[root@lvm boot]# rsy**

rsync                  rsyslogd               rsyslog-recover-qi.pl  

**[root@lvm boot]# rsyrsync -avHPSAX /var/ /mnt/^C**

**[root@lvm boot]# ^C**

[root@lvm boot]# rsync -avHPSAX /var/ /mnt/

sending incremental file list

./

.updated

            163 100%    0.00kB/s    0:00:00 (xfr#1, ir-chk=1028/1030)

sent 130,104 bytes  received 561 bytes  261,330.00 bytes/sec

total size is 218,786,392  speedup is 1,674.41

**[root@lvm boot]# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar **

**[root@lvm boot]# umount /mnt**

**[root@lvm boot]# mount /dev/vg_var/lv_var /var**

## Правлю fstab для автоматического монтирования

**[root@lvm boot]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0"**

UUID="2b10ba22-7f65-4062-9a1d-eec3e1649f64" /var ext4 defaults 0 0

**[root@lvm boot]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab**

**[root@lvm boot]# exit**

exit

**[root@lvm ~]# exit**

exit

Script done on Thu 14 Sep 2023 07:16:10 PM UTC

