# Загрузка Linux
1. Попасть в систему без пароля несколокими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd
________________________________________________________________________________
## 1. Попасть в систему без пароля несколокими способами

Для получения доступа необходимо открыть GUI VirtualBox (или другой системы
виртуализации), запустить виртуальную машину и при выборе ядра для загрузки нажать e - в
данном контексте edit. Попадаем в окно где мы можем изменить параметры загрузки:

1.1 init=/bin/sh

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork8_boot/images/img1.JPG)

![img_2](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork8_boot/images/img2.JPG)

1.2 rd.break

![img_3](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork8_boot/images/img3.JPG)


1.3 rw init=/sysroot/bin/sh

![img_4](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork8_boot/images/img4.JPG)

## 2. Установить систему с LVM, после чего переименовать VG

