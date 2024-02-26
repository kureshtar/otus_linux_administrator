## Резервное копирование

## **Содержание ДЗ**

Установка и настройка:

Тестовый стенд:

backupserver 192.168.50.10 CentOS 7

backupclient 192.168.50.11 CentOS 7

Подключаем на backupserver и на backupclient EPEL репозиторий с дополнительными пакетами
```
yum install epel-release
```
	
Устанавливаем на backupserver и backupclient ПО borgbackup:
```
yum install borgbackup
```

На сервере backupserver при создании машины должен быть дополнительный диск ~2Gb.
Настраиваем этот дополнительный диск:
Команда fdisk -l на сервере показывает, что есть диск sdb объемом 5 Гб, у которого пока нет разделв:
```
fdisk -l
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2022-56-17.png)

Создаем на нем primary раздел:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2022-57-52.png)

Сохраняем изменения по конфигурации диска:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2022-58-48.png)

Теперь видим созданный рездел:

```
fdisk -l
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2022-59-25.png)

Но у созданного раздела /dev/sdb1 пока нет файловой системы:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2022-59-53.png)

Форматируем в ext4:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-00-24.png)

Видим, что файловая система теперь отображается:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-02-41.png)


На сервере backupserver создаем пользователя и каталог /var/backup монтируем в эту папку дополнительный этот диск и назначаем на него права пользователя borg
```
adduser borg
passwd borg
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2022-53-28.png)

``` 
mkdir /var/backup
```

```
chown borg:borg /var/backup/
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-02-08.png)

mount /dev/sdb1 /var/backup 

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-02-22.png)


На сервере backupserver создаем каталог ~/.ssh/authorized_keys в каталоге /home/borg
```
su - borg
mkdir .ssh
touch .ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-04-59.png)

Гегерируем ssh ключ на клиенте:

```	
ssh-keygen
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-07-15.png)

Копируем полученный ключ на клиенте:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-08-26.png)

Вставляем этот ключ на сервере в /borg/.ssh/authorized_keys:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-09-48.png)

Все дальнейшие действия будут проходить на backupclient сервере.

Проверяем подключение по ssh ключу с клиента на сервер:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-11-48.png)

Инициализируем репозиторий borg на backup сервере с client сервера:

```
borg init --encryption=repokey borg@192.168.50.10:/var/backup/
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-13-27.png)

Запускаем для проверки создания бэкапа:
	
```
borg create --stats --list borg@192.168.50.10:/var/backup/::"etc-{now:%Y-%m-%d_%H:%M:%S}" /etc
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-14-27.png)

Смотрим, что у нас получилось:
```
borg list borg@192.168.50.10:/var/backup/
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-16-28.png)

Смотрим список файлов:
```
borg list borg@192.168.50.10:/var/backup/::etc-2024-02-14_06:12:58
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-17-11.png)

Достаем файл из бекапа:
```
borg extract borg@192.168.50.10:/var/backup/::etc-2024-02-14_06:12:58 etc/hostname
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-22-19.png)

## Автоматизируем создание бэкапов с помощью systemd.

Создаем сервис и таймер в каталоге /etc/systemd/system/

[/etc/systemd/system/borg-backup.service :](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/borg-backup.service)

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-24-33.png)

```
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

# Репозиторий
Environment=REPO=borg@192.168.50.10:/var/backup/
# Что бэкапим
Environment=BACKUP_TARGET=/etc

# Создание бэкапа
ExecStart=/bin/borg create \
    --stats                \
    ${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} ${BACKUP_TARGET}

# Проверка бэкапа
ExecStart=/bin/borg check ${REPO}

# Очистка старых бэкапов
ExecStart=/bin/borg prune \
    --keep-daily  90      \
    --keep-monthly 12     \
    --keep-yearly  1       \
    ${REPO}
```


[/etc/systemd/system/borg-backup.timer :](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/borg-backup.timer)


![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-24-54.png)

```
[Unit]
Description=Borg Backup

[Timer]
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

Включаем и запускаем службу таймера
```
systemctl enable borg-backup.timer 
systemctl start borg-backup.timer
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-26-26.png)

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-28-16.png)

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-28-45.png)

Проверяем работу таймера:
```
systemctl list-timers --all
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-29-14.png)


Проверяем список бекапов:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2023-30-08.png)



