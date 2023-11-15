# SELinux

# **Содержание ДЗ**

* Запуск `nginx` на нестандартном порту тремя способами
* Обеспечить работоспособность приложения, развернутого из приложенного стенда, при включенном SELinux


# **Выполнение**

## Запуск `nginx` на нестандартном порту тремя способами

Создана машина с установленным `nginx` в конфиге, которого стандартный порт заменён на 4881.
Файл Vagrantfile опубликован в репозитории. 

Используется образ, скаченный руками и добавленный при помощи команды:
```
vagrant box add centos7 CentOS-7-x86_64-Vagrant-2004_01.VirtualBox.box
```
На этапе разворачивание машины получены сообщения об ошибках. SELinux блокирует работу сервиса на нестандартном порту:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-14%2017-03-49.png)

Проверка состояния файрвола:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-14%2017-05-44.png)

Проверка конфига nginx:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-14%2017-06-17.png)

Проверка режима работы SELinux:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-14%2017-07-34.png)

### **Способ 1** Разрешение c помощью переключателей setsebool
В логах аудита информация о блокировании порта анализируется утилитой `audit2why`:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-14%2017-15-55.png)

Установка рекомендованного параметра и рестарт nginx:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-14%2017-18-12.png)

nginx слушает порт и отдаёт данные:
```sh
[root@selinux ~]# ss -tnlp | grep 4881
LISTEN     0      128       [::]:4881                  [::]:*                   users:(("nginx",pid=3063,fd=7),("nginx",pid=3062,fd=7))
[root@selinux ~]#
[root@selinux ~]#
[root@selinux ~]# curl -I http://localhost:4881
HTTP/1.1 200 OK
Server: nginx/1.20.1
Date: Tue, 15 Nov 2023 13:20:16 GMT
Content-Type: text/html
Content-Length: 4833
Last-Modified: Fri, 16 May 2014 15:12:48 GMT
Connection: keep-alive
ETag: "53762af0-12e1"
Accept-Ranges: bytes
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2008-56-06.png)

Текущее состояние параметра политики SELinux:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2008-57-14.png)

Возврат состояния параметра и остановка nginx для следующего способа:
```sh
[root@selinux ~]# setsebool -P nis_enabled off
[root@selinux ~]# systemctl restart nginx.service
```

### **Способ 2** Разрешение c помощью добавления нестандартного порта в имеющийся тип

Поиск имеющегося типа, для http трафика:
```sh
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```
Добавление порта в тип `http_port_t`:
```sh
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http_port_t
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
```
Успешный рестарт nginx:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-01-36.png)

Возврат состояния параметра для следующего способа:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-03-05.png)

### **Способ 3** Разрешение c помощью формирования и установки модуля SELinux

Создание модуля утилитой `audit2allow` на основе логов SELinux:
```sh
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp
```

Применение сформированного модуля и запуск `nginx`:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-05-36.png)

nginx слушает порт и отдаёт данные:
```sh
[root@selinux ~]# ss -tnlp | grep 4881
LISTEN     0      128       [::]:4881                  [::]:*                   users:(("nginx",pid=22269,fd=7),("nginx",pid=22268,fd=7))
[root@selinux ~]#
[root@selinux ~]#
[root@selinux ~]# curl -I http://localhost:4881
HTTP/1.1 200 OK
Server: nginx/1.20.1
Date: Tue, 15 Nov 2023 05:10:21 GMT
Content-Type: text/html
Content-Length: 4833
Last-Modified: Fri, 16 May 2014 15:12:48 GMT
Connection: keep-alive
ETag: "53762af0-12e1"
Accept-Ranges: bytes
```

Модуль в списке установленных:
```sh
[root@selinux ~]# semodule -l | grep -C 2 nginx
netutils        1.12.1
networkmanager  1.15.2
nginx   1.0
ninfod  1.0.0
nis     1.12.0
```

## Обеспечить работоспособность приложения, развернутого из приложенного стенда, при включенном SELinux

Склонирован репозиторий, развёрнут стенд `selinux_dns_problems`:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-18-28.png)

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-20-28.png)

На машине `client` при попытке внесения изменений в зону - ошибка:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-22-39.png)

Логи SELinux ошибки не показывают:
```sh
[vagrant@client ~]$ sudo -i
[root@client ~]# cat /var/log/audit/audit.log | audit2why
[root@client ~]#
```

На машине `ns01` логи SELinux содержат ошибки:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-36-00.png)

Ошибка в контексте безопасности. Вместо типа `named_t` используется тип `etc_t`.
Проблема в каталоге `/etc/named`:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-42-55.png)

Необходимо выполнить изменение типа контекста безопасности для каталога `/etc/named`: 

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-42-27.png)

Теперь на машине `client` при попытке внесения изменений в зону - успех:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork17_SELinux/images/Screenshot%20from%202023-11-15%2009-47-03.png)

![Screenshot](https://github.com/jimidini77/otus-linux-day17/blob/main/Screenshot.png?raw=true)

# **Результаты**
Выполнен запуск nginx на нестандартном порту:
- установкой переключателя setsebool;
- добавлением нестандартного порта в имеющийся тип;
- формированием и установкой модуля SELinux;

Предпочтительным является второй способ, позволяющий более точно и осознано выполнять настройку SELinux.

На тестовом стенде содержащем неправильную конфигурацию, выполнена диагностика ошибки SELinux и внесено исправление в контекст безопасности файлов конфигурации DNS-сервера.

- **GitHub** - https://github.com/jimidini77/otus-linux-day17
