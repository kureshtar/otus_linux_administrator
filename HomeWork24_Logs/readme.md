# Основы сбора и хранения логов
## **Содержание ДЗ**

1. В Vagrant разворачиваем 2 виртуальные машины web и log
2. на web настраиваем nginx
3. на log настраиваем центральный лог сервер на любой системе на выбор
journald;
rsyslog;
elk.
4. настраиваем аудит, следящий за изменением конфигов nginx 

Все критичные логи с web должны собираться и локально и удаленно.
Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
Логи аудита должны также уходить на удаленную систему.

___

## **Выполнение**

### 1. Создаём виртуальные машины
Создаём каталог, в котором будут храниться настройки виртуальной машины. В каталоге создаём файл с именем Vagrantfile, добавляем в него следующее [содержимое](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/Vagrantfile).


Результатом выполнения команды vagrant up станут 2 созданные виртуальные машины
Заходим на web-сервер: vagrant ssh web
Дальнейшие действия выполняются от пользователя root. Переходим в root пользователя: sudo -i
Для правильной работы c логами, нужно, чтобы на всех хостах было настроено одинаковое время. 
Укажем часовой пояс (Московское время):
```
cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
```
Перезупустим службу NTP Chrony: 
```
systemctl restart chronyd
```
Проверим, что служба работает корректно: 
```
systemctl status chronyd
```
Далее проверим, что время и дата указаны правильно:
```
date
```
Настроить NTP нужно на обоих серверах.

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/Screenshot%20from%202024-01-22%2022-26-55.png)

Также, для удобства редактирования конфигурационных файлов можно установить текстовый редактор vim: yum install -y vim

### 2. Установка nginx на виртуальной машине web
Для установки nginx сначала нужно установить epel-release:

```
yum install epel-release 
```

Установим nginx: 

```
yum install -y nginx  
```
Проверим, что nginx работает корректно:

```
systemctl status nginx
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/Screenshot%20from%202024-01-22%2022-28-56.png)


Также работу nginx можно проверить на хосте. В браузере ввведем в адерсную строку http://192.168.50.10 
Видим что nginx запустился корректно.

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/Screenshot%20from%202024-01-22%2022-29-27.png)


### 3. Настройка центрального сервера сбора логов

Откроем еще одно окно терминала и подключаемся по ssh к ВМ log: 
```
vagrant ssh log
```
Перейдем в пользователя root: 
```
sudo -i
```
rsyslog должен быть установлен по умолчанию в нашей ОС, проверим это:
```
yum list rsyslog
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/Screenshot%20from%202024-01-22%2022-33-50.png)

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/Screenshot%20from%202024-01-22%2022-33-50.png)
Все настройки Rsyslog хранятся в файле 
```
/etc/rsyslog.conf 
```
Для того, чтобы наш сервер мог принимать логи, нам необходимо внести следующие изменения в файл: 
Открываем порт 514 (TCP и UDP):
Находим закомментированные строки:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/sn01.PNG)

И приводим их к виду:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/sn2.PNG)

В конец файла /etc/rsyslog.conf добавляем правила приёма сообщений от хостов:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/images/sn3.PNG)

Данные параметры будут отправлять в папку /var/log/rsyslog логи, которые будут приходить от других серверов. 
Например, Access-логи nginx от сервера web, будут идти в файл /var/log/rsyslog/web/nginx_access.log

Далее сохраняем файл [/etc/rsyslog.conf](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork24_Logs/rsyslog.conf) и перезапускаем службу rsyslog:
```
systemctl restart rsyslog
```
Если ошибок не допущено, то у нас будут видны открытые порты TCP,UDP 514:

Далее настроим отправку логов с web-сервера
Заходим на web сервер: vagrant ssh web
Переходим в root пользователя: sudo -i 
Проверим версию nginx: rpm -qa | grep nginx

Версия nginx должна быть 1.7 или выше. В нашем примере используется версия nginx 1.20. 
Находим в файле /etc/nginx/nginx.conf раздел с логами и приводим их к следующему виду:

Для Access-логов указыаем удаленный сервер и уровень логов, которые нужно отправлять. Для error_log добавляем удаленный сервер. Если требуется чтобы логи хранились локально и отправлялись на удаленный сервер, требуется указать 2 строки. 	
Tag нужен для того, чтобы логи записывались в разные файлы.
По умолчанию, error-логи отправляют логи, которые имеют severity: error, crit, alert и emerg. Если трубуется хранили или пересылать логи с другим severity, то это также можно указать в настройках nginx. 
Далее проверяем, что конфигурация nginx указана правильно: nginx -t

Далее перезапустим nginx: systemctl restart nginx
Чтобы проверить, что логи ошибок также улетают на удаленный сервер, можно удалить картинку, к которой будет обращаться nginx во время открытия веб-сраницы: rm /usr/share/nginx/html/img/header-background.png

Попробуем несколько раз зайти по адресу http://192.168.50.10
Далее заходим на log-сервер и смотрим информацию об nginx:
cat /var/log/rsyslog/web/nginx_access.log 
cat /var/log/rsyslog/web/nginx_error.log 

Видим, что логи отправляются корректно. 
4. Настройка аудита, контролирующего изменения конфигурации nginx
За аудит отвечает утилита auditd, в RHEL-based системах обычно он уже предустановлен. Проверим это: rpm -qa | grep audit

Настроим аудит изменения конфигурации nginx:
Добавим правило, которое будет отслеживать изменения в конфигруации nginx. Для этого в конец файла /etc/audit/rules.d/audit.rules добавим следующие строки:

Данные правила позволяют контролировать запись (w) и измения атрибутов (a) в:
/etc/nginx/nginx.conf
Всех файлов каталога /etc/nginx/default.d/
Для более удобного поиска к событиям добавляется метка nginx_conf
Перезапускаем службу auditd: service auditd restart

После данных изменений у нас начнут локально записываться логи аудита. Чтобы проверить, что логи аудита начали записываться локально, нужно внести изменения в файл /etc/nginx/nginx.conf или поменять его атрибут, потом посмотреть информацию об изменениях: ausearch -f /etc/nginx/nginx.confq
Также можно воспользоваться поиском по файлу /var/log/audit/audit.log, указав наш тэг: grep nginx_conf /var/log/audit/audit.log













Далее настроим пересылку логов на удаленный сервер. Auditd по умолчанию не умеет пересылать логи, для пересылки на web-сервере потребуется установить пакет audispd-plugins: yum -y install audispd-plugins

Найдем и поменяем следующие строки в файле /etc/audit/auditd.conf: 


В name_format  указываем HOSTNAME, чтобы в логах на удаленном сервере отображалось имя хоста. 
В файле /etc/audisp/plugins.d/au-remote.conf поменяем параметр active на yes:

В файле /etc/audisp/audisp-remote.conf требуется указать адрес сервера и порт, на который будут отправляться логи:

Далее перезапускаем службу auditd: service auditd restart
На этом настройка web-сервера завершена. Далее настроим Log-сервер. 

Отроем порт TCP 60, для этого уберем значки комментария в файле /etc/audit/auditd.conf:


Перезапустим службу auditd: service auditd restart
На этом настройка пересылки логов аудита закончена. Можем попробовать поменять атрибут у файла /etc/nginx/nginx.conf и проверить на log-сервере, что пришла информация об изменении атрибута:

##  **Результаты**

Полученный скрипт <a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork10_bash/mail_send.sh">mail_send.sh</a> помещен в публичный репозиторий.

Анализируемые логи  -  `/var/log/httpd/access_log` и `/var/log/httpd/error_log`
