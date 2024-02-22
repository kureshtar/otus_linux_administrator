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
 
 # 			
	# mkdir /var/backup
	# chown borg:borg /var/backup/
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork26_backup/images/Screenshot%20from%202024-02-14%2022-53-28.png)



На сервер backup создаем каталог ~/.ssh/authorized_keys в каталоге /home/borg
	# su - borg
	# mkdir .ssh
   	# touch .ssh/authorized_keys
   	# chmod 700 .ssh
   	# chmod 600 .ssh/authorized_keys

На csu 
	# ssh-keygen

Все дальнейшие действия будут проходить на client сервере.
Инициализируем репозиторий borg на backup сервере с client сервера:
	# borg init --encryption=repokey borg@192.168.11.160:/var/backup/


Запускаем для проверки создания бэкапа
	# borg create --stats --list borg@192.168.11.160:/var/backup/::"etc-{now:%Y-%m-%d_%H:%M:%S}" /etc

Смотрим, что у нас получилось
	# borg list borg@192.168.11.160:/var/backup/
Enter passphrase for key ssh://borg@192.168.11.160/var/backup: 
etc-2021-10-15_23:00:15              Fri, 2021-10-15 23:00:21 [573f7b4071bd2e079957217f397394c336eaf172208755110b311ada735e16d3]
 
Смотрим список файлов
	# borg list borg@192.168.11.160:/var/backup/::etc-2021-10-15_23:00:15

Достаем файл из бекапа
	# borg extract borg@192.168.11.160:/var/backup/::etc-2021-10-15_23:00:15 etc/hostname

Автоматизируем создание бэкапов с помощью systemd
Создаем сервис и таймер в каталоге /etc/systemd/system/
# /etc/systemd/system/borg-backup.service
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

# Парольная фраза
Environment="BORG_PASSPHRASE=Otus1234"
# Репозиторий
Environment=REPO=borg@192.168.11.160:/var/backup/
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



# /etc/systemd/system/borg-backup.timer
[Unit]
Description=Borg Backup

[Timer]
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target

Включаем и запускаем службу таймера
# systemctl enable borg-backup.timer 
# systemctl start borg-backup.timer

Проверяем работу таймера
# systemctl list-timers --all
NEXT                          LEFT          LAST                          PASSED       UNIT                         ACTIVATES
Сб 2021-10-16 11:37:51 UTC  3min 25s left Сб 2021-10-16 11:32:51 UTC  1min 34s ago borg-backup.timer            borg-backup.service

Проверяем список бекапов
Enter passphrase for key ssh://borg@192.168.11.160/var/backup: 
etc-2021-10-15_23:00:15 Fri, 2021-10-15 23:00:21 
etc-2021-10-16_11:32:51 Sat, 2021-10-16 11:32:52

