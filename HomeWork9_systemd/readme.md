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
```
[root@otus ~]# systemctl status watchlog.service
● watchlog.service - Test watchlog service
   Loaded: loaded (/usr/lib/systemd/system/watchlog.service; static; vendor preset: disabled)
   Active: inactive (dead) since Fri 2022-07-01 00:41:37 UTC; 4s ago
  Process: 28429 ExecStart=/opt/watchlog.sh $WORD $LOG (code=exited, status=0/SUCCESS)
 Main PID: 28429 (code=exited, status=0/SUCCESS)

Jul 01 00:41:37 otus systemd[1]: Starting Test watchlog service...
Jul 01 00:41:37 otus systemd[1]: Started Test watchlog service.
[root@otus ~]# systemctl status watchlog.timer
● watchlog.timer - Run watchlog script every 30 second
   Loaded: loaded (/usr/lib/systemd/system/watchlog.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Fri 2022-07-01 00:31:01 UTC; 10min ago

Jul 01 00:31:01 otus systemd[1]: Started Run watchlog script every 30 second.
[root@otus ~]# systemctl list-timers
NEXT                         LEFT     LAST                         PASSED  UNIT                         ACTIVATES
Fri 2022-07-01 00:42:07 UTC  7s left  Fri 2022-07-01 00:41:37 UTC  22s ago watchlog.timer               watchlog.service
Fri 2022-07-01 14:25:48 UTC  13h left Thu 2022-06-30 14:25:48 UTC  10h ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

2 timers listed.
Pass --all to see loaded but inactive timers, too.
```

### Создание unit-файла сервиса из init-скрипта

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
```
[root@otus ~]# systemctl start spawn-fcgi.service
[root@otus ~]#
[root@otus ~]# systemctl status spawn-fcgi.service
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/usr/lib/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2022-06-30 14:21:01 UTC; 10h ago
 Main PID: 3122 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─3122 /usr/bin/php-cgi
           ├─3123 /usr/bin/php-cgi
           ├─3124 /usr/bin/php-cgi
           ├─3125 /usr/bin/php-cgi
           ├─3126 /usr/bin/php-cgi
           ├─3127 /usr/bin/php-cgi
           ├─3128 /usr/bin/php-cgi
           ├─3129 /usr/bin/php-cgi
           ├─3130 /usr/bin/php-cgi
           ├─3131 /usr/bin/php-cgi
           ├─3132 /usr/bin/php-cgi
           ├─3133 /usr/bin/php-cgi
           ├─3134 /usr/bin/php-cgi
           ├─3135 /usr/bin/php-cgi
           ├─3136 /usr/bin/php-cgi
           ├─3137 /usr/bin/php-cgi
           ├─3138 /usr/bin/php-cgi
           ├─3139 /usr/bin/php-cgi
           ├─3140 /usr/bin/php-cgi
           ├─3141 /usr/bin/php-cgi
           ├─3142 /usr/bin/php-cgi
           ├─3143 /usr/bin/php-cgi
           ├─3144 /usr/bin/php-cgi
           ├─3145 /usr/bin/php-cgi
           ├─3146 /usr/bin/php-cgi
           ├─3147 /usr/bin/php-cgi
           ├─3148 /usr/bin/php-cgi
           ├─3149 /usr/bin/php-cgi
           ├─3150 /usr/bin/php-cgi
           ├─3151 /usr/bin/php-cgi
           ├─3152 /usr/bin/php-cgi
           ├─3153 /usr/bin/php-cgi
           └─3154 /usr/bin/php-cgi

Jun 30 14:21:01 otus systemd[1]: Started Spawn-fcgi startup service by Otus.
```

### Конфигурация для запуска нескольких инстансов сервиса apache httpd

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
```
[root@otus ~]# systemctl start httpd@first
[root@otus ~]# systemctl start httpd@second
[root@otus ~]# systemctl status httpd*
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2022-06-30 14:49:22 UTC; 10h ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 3414 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─3414 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3415 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3416 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3417 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3418 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3419 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─3420 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Jun 30 14:49:22 otus systemd[1]: Starting The Apache HTTP Server...
Jun 30 14:49:22 otus httpd[3414]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set th...is message
Jun 30 14:49:22 otus systemd[1]: Started The Apache HTTP Server.

● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2022-06-30 14:49:17 UTC; 10h ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 3401 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─3401 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3402 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3403 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3404 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3405 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3406 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─3407 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Jun 30 14:49:16 otus systemd[1]: Starting The Apache HTTP Server...
Jun 30 14:49:17 otus httpd[3401]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set th...is message
Jun 30 14:49:17 otus systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```

Сконфигурированные ранее порты прослушиваются сервисами:
```
[root@otus ~]# ss -tnlp | grep httpd
LISTEN     0      128       [::]:8081                  [::]:*                   users:(("httpd",pid=3407,fd=4),("httpd",pid=3406,fd=4),("httpd",pid=3405,fd=4),("httpd",pid=3404,fd=4),("httpd",pid=3403,fd=4),("httpd",pid=3402,fd=4),("httpd",pid=3401,fd=4))
LISTEN     0      128       [::]:8082                  [::]:*                   users:(("httpd",pid=3420,fd=4),("httpd",pid=3419,fd=4),("httpd",pid=3418,fd=4),("httpd",pid=3417,fd=4),("httpd",pid=3416,fd=4),("httpd",pid=3415,fd=4),("httpd",pid=3414,fd=4))
```

# **Результаты**

Выполняемые при конфигурировании сервера команды перенесены в bash-скрипт для автоматического конфигурирования машины при развёртывании.
После развёртывания машины стартуют сервисы `watchlog.timer`, `spawn-fcgi.service`, `httpd@first.service`, `httpd@second.service`.

Полученный в ходе работы `Vagrantfile` и внешний скрипт `init.sh` для shell provisioner помещены в публичный репозиторий:

- **GitHub** - https://github.com/jimidini77/otus-linux-day09
