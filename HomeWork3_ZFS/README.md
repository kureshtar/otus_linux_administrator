# ZFS
## 1. Определение алгоритма с наилучшим сжатием
Смотрим список всех дисков, которые есть в виртуальной машине:

![lsblk](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-21%2014-19-36.png)

Создаём три пула в режиме RAID 1, каждый пул состоящий из двух дисков:

![zpool create](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-21%2014-22-55.png)

Смотрим информацию о пулах:

![zpool list](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-21%2014-24-02.png)

Добавим разные алгоритмы сжатия в каждую файловую систему:

- Алгоритм lzjb: zfs set compression=lzjb otus1
- 
- Алгоритм lz4:  zfs set compression=lz4 otus2
- 
- Алгоритм gzip: zfs set compression=gzip-9 otus3
- 
- Алгоритм zle:  zfs set compression=zle otus4

