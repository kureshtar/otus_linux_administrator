# Инициализация системы. Systemd

### **Содержание ДЗ**

1. Написать service, который раз в 30 секунд мониторит лог на предмет наличия ключевого слова.
2. Установить spawn-fcgi и переписать init-скрипт на unit-файл.
3. Дополнить unit-файл httpd возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.
____________________________________________________

### **Выполнение**

### 1. Написать service, который раз в 30 секунд мониторит лог на предмет наличия ключевого слова.

Создание файла конфигурации сервиса, используется ключевое слово `ALERT`:

<p><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/watchlog">watchlog</a> - /etc/sysconfig/watchlog</p>

Исполняемый модуль сервиса:

<p><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/watchlog.sh">watchlog.sh</a> - /opt/watchlog.sh</p>

Unit-файл сервиса:

<p><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/watchlog.service">watchlog.service</a> - /etc/systemd/system/watchlog.service</p>

Unit-файл таймера, запускающего сервис каждые 30 секунд:

<p><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/watchlog.time">watchlog.timer</a> - /etc/systemd/system/watchlog.timer</p>

При запуске таймера и записи ключевого слова в лог:
```
[root@otus ~]# systemctl start watchlog.timer
[root@otus ~]# echo 'ALERT' > /var/log/watchlog.log
```

В системном журнале сообщения:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/images/Screenshot6.png)

Состояние сервисов:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/images/Screenshot7.png)

### 2. Установить spawn-fcgi и переписать init-скрипт на unit-файл.

Установка spawn-fcgi и необходимых пакетов:
```
yum install -y epel-release && yum install -y spawn-fcgi php php-cli mod_fcgid httpd
```

Unit-файл сервиса `spawn-fcgi`:
```
cat >> /lib/systemd/system/spawn-fcgi.service << EOF
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
```

Раскомментирование опций в конфиг-файле:
```
sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi
```

Запуск сервиса и его статус:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/images/Screenshot10.png)

### 3. Дополнить unit-файл httpd возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.

Подготовка Unit-файла:
```
cp /lib/systemd/system/httpd.service /lib/systemd/system/httpd@.service
sed -i 's|EnvironmentFile=/etc/sysconfig/httpd|&-%i|' /lib/systemd/system/httpd@.service
```

Создание файлов окружений из стандартного путём копирования и изменения опций конфиг-файлов:
```
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-first
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-second
sed -i 's|#OPTIONS=|OPTIONS=-f conf/first.conf|' /etc/sysconfig/httpd-first
sed -i 's|#OPTIONS=|OPTIONS=-f conf/second.conf|' /etc/sysconfig/httpd-second
```

Создание файлов конфигов для каждого экземпляра сервиса, явно указываются используемые порты (8081,8082) и Pid-файлы:
```
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sed -i 's|Listen 80|&81\nPidFile /var/run/httpd-first.pid|' /etc/httpd/conf/first.conf
sed -i 's|Listen 80|&82\nPidFile /var/run/httpd-second.pid|' /etc/httpd/conf/second.conf
```

Запуск сервисов и их состояние после запуска:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/images/Screenshot11.png)

Сконфигурированные ранее порты прослушиваются сервисами:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork9_systemd/images/Screenshot12.png)

# **Результаты**

Выполняемые при конфигурировании сервера команды перенесены в bash-скрипт для автоматического конфигурирования машины при развёртывании.
После развёртывания машины стартуют сервисы `watchlog.timer`, `spawn-fcgi.service`, `httpd@first.service`, `httpd@second.service`.

Полученный в ходе работы `Vagrantfile` и внешний скрипт `init.sh` для shell provisioner помещены в публичный репозиторий:

- **GitHub** - https://github.com/kureshtar/otus_linux_administrator/tree/main/HomeWork9_systemd
