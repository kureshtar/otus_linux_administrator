# iptables

# **Содержание ДЗ**

- реализовать knocking port, centralRouter может попасть на ssh inetrRouter через knock скрипт пример в материалах;
- добавить inetRouter2, который виден (маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост;
- запустить nginx на centralServer;
- пробросить 80-й порт на inetRouter2 8080;
- дефолт в инет оставить через inetRouter;

# **Выполнение**

Развёрнуты 4 машины:
- **inetRouter** - дефолный маршрут в интернет идёт через него
- **inetRouter2** - принимает подключения на порт 8080\tcp и пробрасывает на 80\tcp centralServer
- **centralRouter** - 
- **centralServer** - веб-сервер

Подсеть машрутизаторов:
- 192.168.255.0/29 (inetRouter, inetRouter2, centralRouter)

Подсеть серверов:
- 192.168.0.0/24 (centralRouter, centralServer)

На всех маршрутизаторах разрешен форвардинг траффика:
```yml
    - name: Persistent forwarding enable
      lineinfile:
        line: "net.ipv4.ip_forward = 1"
        path: /etc/sysctl.conf
      notify: restart network
```
На centralRouter дефолтный маршрут настроен на inetRouter:
```yml
    - name: centralRouter static routes set
      lineinfile:
        line: '{{ item.line }}'
        path: '{{ item.file }}'
        create: yes
      with_items: 
        - { line: "DEFROUTE=no", file: "/etc/sysconfig/network-scripts/ifcfg-eth0" }
        - { line: "GATEWAY=192.168.255.1", file: "/etc/sysconfig/network-scripts/ifcfg-eth1"}
      when: (ansible_hostname == "centralRouter")
      notify: restart network
```

На centralServer дефолтный маршрут настроен на centralServer:
```yml
    - name: centralServer static routes set
      lineinfile:
        line: '{{ item.line }}'
        path: '{{ item.file }}'
        create: yes
      with_items: 
        - { line: "DEFROUTE=no", file: "/etc/sysconfig/network-scripts/ifcfg-eth0" }
        - { line: "GATEWAY=192.168.0.1", file: "/etc/sysconfig/network-scripts/ifcfg-eth1"}
      when: (ansible_hostname == "centralServer")
      notify: restart network
```

На внешних маршрутизаторах прописан маршрут к внутренней серверной подсети:
```yml
    - name: inetRouter static routes set
      lineinfile:
        line: '{{ item }}'
        path: /etc/sysconfig/network-scripts/route-eth1
        create: yes
      loop:
        - "192.168.0.0/24 via 192.168.255.3"
      when: (ansible_hostname == "inetRouter")
      notify: restart network

    - name: inetRouter2 static routes set
      lineinfile:
        line: '{{ item }}'
        path: /etc/sysconfig/network-scripts/route-eth1
        create: yes
      loop:
        - "192.168.0.0/24 via 192.168.255.3"
      when: (ansible_hostname == "inetRouter2")
      notify: restart network
```

На всех машрутизаторы при настройке машин копируются преднастроеные конфиги для iptables:

- centralRouter. Cпециальных настроек не имеет:
```
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
COMMIT
```

- inetRouter2 
  - В таблице nat цепочки PREROUTING и POSTROUTING дополнены правилами проброса подключений к порту 8080\tcp на 80\tcp centralServer:
```
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -p tcp -m tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:80
-A POSTROUTING -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
COMMIT
```

- inetRouter 
  - Таблица nat: все пакеты предназначенные для внешних адресов подвергаются маскарадингу.
  - для реализации port knocking таблица filter дополнена цепочками TRAFFIC, SSH-INPUT, SSH-INPUTTWO. Используется модуль recent. Все приходящие новые пакеты на 22\tcp последовательно проверяются на наличие источника в таблицах `/proc/net/xt_recent/SSH0`, `/proc/net/xt_recent/SSH1`, `/proc/net/xt_recent/SSH2` и вхождении записей в этих таблицах в 30-ти секундный интервал. Установление нового соединения по SSH возможно, если выполнено условие последовательного последовательного открытия портов 888\tcp, 777\tcp, 999\tcp
  - <font size="6">!</font> <u>после выполнении конфигурирования через Ansible Vagrant не сможет управлять машиной</u> доступ возможен с centralRouter, где установлен nmap и knocking-скрипт
```

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:TRAFFIC - [0:0]
:SSH-INPUT - [0:0]
:SSH-INPUTTWO - [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -j TRAFFIC
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 22 -m recent --rcheck --seconds 30 --name SSH2 -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH2 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 999 -m recent --rcheck --name SSH1 -j SSH-INPUTTWO
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH1 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 777 -m recent --rcheck --name SSH0 -j SSH-INPUT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH0 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 888 -m recent --name SSH0 --set -j DROP
-A SSH-INPUT -m recent --name SSH1 --set -j DROP
-A SSH-INPUTTWO -m recent --name SSH2 --set -j DROP
-A TRAFFIC -j REJECT --reject-with icmp-host-prohibited
COMMIT
```

На centralRouter установлен nmap. Скрипт позволяющий установить подключение по SSH к inetRouter находится в `/home/vagrant/knock.sh`
```sh
[root@centralRouter vagrant]# /home/vagrant/knock.sh 192.168.255.1 888 777 999

Starting Nmap 6.40 ( http://nmap.org ) at 2024-02-28 13:36 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0026s latency).
PORT    STATE    SERVICE
888/tcp filtered accessbuilder
MAC Address: 08:00:27:91:73:C0 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 13.72 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2024-02-28 13:36 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0029s latency).
PORT    STATE    SERVICE
777/tcp filtered multiling-http
MAC Address: 08:00:27:91:73:C0 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 13.61 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2024-02-28 13:36 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0023s latency).
PORT    STATE    SERVICE
999/tcp filtered garcon
MAC Address: 08:00:27:91:73:C0 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 13.60 seconds
[root@centralRouter vagrant]# ssh vagrant@192.168.255.1
vagrant@192.168.255.1's password:
Last login: Wed Feb 28 17:51:36 2022 from 192.168.255.3
[vagrant@inetRouter ~]$
[vagrant@inetRouter ~]$
[vagrant@inetRouter ~]$
[vagrant@inetRouter ~]$ cat /proc/net/xt_recent/SSH0
src=192.168.255.3 ttl: 51 last_seen: 4295859821 oldest_pkt: 1 4295859821
[vagrant@inetRouter ~]$ cat /proc/net/xt_recent/SSH1
src=192.168.255.3 ttl: 45 last_seen: 4295873546 oldest_pkt: 1 4295873546
[vagrant@inetRouter ~]$ cat /proc/net/xt_recent/SSH2
src=192.168.255.3 ttl: 53 last_seen: 4295887221 oldest_pkt: 1 4295887221
[vagrant@inetRouter ~]$
```

При конфигурировании машины inetRouter2 порт 8080\tcp проброшен в хостовую ОС. Подключение к веб-серверу можно проверить с хостовой машины:
```sh
root@nas:/study/day29# curl -I http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.20.1
Date: Wed, 28 Feb 2024 14:20:40 GMT
Content-Type: text/html
Content-Length: 4833
Last-Modified: Fri, 16 May 2014 15:12:48 GMT
Connection: keep-alive
ETag: "53762af0-12e1"
Accept-Ranges: bytes

root@nas:/study/day29#
```


# **Результаты**

Полученный в ходе работы `Vagrantfile` и плейбук Ansible помещены в публичный репозиторий.
