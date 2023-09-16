# LVM

## Создание PV, VG, LV.

**[root@lvm ~]# pvcreate /dev/sdb**

Physical volume "/dev/sdb" successfully created.

**[root@lvm ~]# vgcreate vg_root /dev/sdb**

  Volume group "vg_root" successfully created
  
**[root@lvm ~]# lvcreate -n lv_root -l +100%FREE /dev/vg_root**

  Logical volume "lv_root" created.

## Создаю ФС
[root@lvm ~]# mkfs.xfs /dev/vg_root/lv_root
meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
###Монтирую
[root@lvm ~]# mount /dev/vg_root/lv_root /mnt
###Копирую все данные
[root@lvm ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
xfsdump: using file dump (drive_simple) strategy
...
...
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 8 seconds elapsed
xfsrestore: Restore Status: SUCCESS

###Переконфигурация grub
[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
...
...
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
###Замена в grub.cfg
[root@lvm boot]# sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/g' /boot/grub2/grub.cfg
[root@lvm boot]# exit
exit
[root@lvm ~]# exit
exit
###ребут
Script done on Thu 14 Sep 2023 07:09:32 PM UTC
