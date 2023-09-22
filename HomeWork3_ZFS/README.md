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
- Алгоритм lz4:  zfs set compression=lz4 otus2
- Алгоритм gzip: zfs set compression=gzip-9 otus3
- Алгоритм zle:  zfs set compression=zle otus4

Проверим, что все файловые системы имеют разные методы сжатия:

![zfs get all](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-22%2009-11-54.png)

Скачаем один и тот же текстовый файл во все пулы: 
```
[root@zfs vagrant]# for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
```

Проверим, что файл был скачан во все пулы:

![ls -l /otus*](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-22%2009-14-20.png)

Видим, что самый оптимальный метод сжатия у нас используется в пуле otus3.

Проверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов:

![zfs list](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-22%2009-14-20.png)

Таким образом, у нас получается, что алгоритм gzip-9 самый эффективный по сжатию.

##  2. Определение настроек пула

Скачиваем архив в домашний каталог: 
```
[root@zfs vagrant]# wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
```

Разархивируем его и проверим, возможно ли импортировать данный каталог в пул::

![tar -xzvf archive.tar.gz](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-22%2009-18-51.png)

Данный вывод показывает нам имя пула, тип raid и его состав.

Сделаем импорт данного пула к нам в ОС:

```
[root@zfs ~]# zpool import -d zpoolexport/ otus
[root@zfs ~]# zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:


        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0


errors: No known data errors
```

C помощью команды grep можно уточнить конкретный параметр, например:

![zfs get](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-22%2009-22-20.png)

## 3. Работа со снапшотом, поиск сообщения от преподавателя

Скачаем файл, указанный в задании:

![wget](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork3_ZFS/images/Screenshot%20from%202023-09-22%2009-24-43.png)


