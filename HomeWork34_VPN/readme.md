# Мосты, туннели, VPN

# **Prerequisite**
- Host OS: Debian 12.0.0
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.40
- Vagrant: 2.3.2
- Ansible: 2.13.4

# **Содержание ДЗ**

1. между двумя виртуалками поднять vpn в режимах
  - tun;
  - tap;
  
    Описать в чём разница, замерить скорость между виртуальными машинами в туннелях.

2. поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку.

# **Выполнение**

Развёрнуты две машины. Выполнена установка требуемых пакетов:
```
yum install -y epel-release
yum install -y openvpn iperf3 easy-rsa policycoreutils-python
```
Сгенерирован статический ключ, с которым в дальнейшем будет выполняться подключение:
```
openvpn --genkey --secret /etc/openvpn/static.key
```

Конфигурация сервера:
```
dev tap
ifconfig 10.10.10.1 255.255.255.0
topology subnet
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3

```
Конфигурация клиента:
```
dev tap
remote 192.168.10.10
ifconfig 10.10.10.2 255.255.255.0
topology subnet
route 192.168.10.0 255.255.255.0
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
```

Замер пропускной способности туннеля в режиме TAP:
```sh
[root@client vagrant]# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 33856 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  9.25 MBytes  15.5 Mbits/sec   20    226 KBytes
[  4]   5.00-10.00  sec  9.20 MBytes  15.4 Mbits/sec   86    119 KBytes
[  4]  10.00-15.00  sec  8.46 MBytes  14.2 Mbits/sec    5    132 KBytes
[  4]  15.00-20.00  sec  8.64 MBytes  14.5 Mbits/sec    5    138 KBytes
[  4]  20.00-25.00  sec  8.40 MBytes  14.1 Mbits/sec   11    107 KBytes
[  4]  25.00-30.00  sec  8.70 MBytes  14.6 Mbits/sec    0    152 KBytes
[  4]  30.00-35.01  sec  8.46 MBytes  14.2 Mbits/sec   22    116 KBytes
[  4]  35.01-40.00  sec  7.84 MBytes  13.2 Mbits/sec    8    116 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec  68.9 MBytes  14.5 Mbits/sec  157             sender
[  4]   0.00-40.00  sec  68.3 MBytes  14.3 Mbits/sec                  receiver

iperf Done.
```

Замер пропускной способности туннеля в режиме TUN:
```sh
[root@client vagrant]# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 33860 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  12.1 MBytes  20.3 Mbits/sec   49    145 KBytes
[  4]   5.00-10.01  sec  10.8 MBytes  18.2 Mbits/sec    0    192 KBytes
[  4]  10.01-15.00  sec  10.3 MBytes  17.4 Mbits/sec    7    196 KBytes
[  4]  15.00-20.00  sec  10.3 MBytes  17.3 Mbits/sec   56    111 KBytes
[  4]  20.00-25.01  sec  10.5 MBytes  17.6 Mbits/sec    4    139 KBytes
[  4]  25.01-30.01  sec  9.85 MBytes  16.5 Mbits/sec    0    182 KBytes
[  4]  30.01-35.01  sec  11.2 MBytes  18.9 Mbits/sec   38    124 KBytes
[  4]  35.01-40.00  sec  9.29 MBytes  15.6 Mbits/sec    4    144 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec  84.5 MBytes  17.7 Mbits/sec  158             sender
[  4]   0.00-40.00  sec  83.9 MBytes  17.6 Mbits/sec                  receiver

iperf Done.
```
- TAP 
  - виртуальный интерфейс, работает на L2
  - по сути представляет собой бридж между роутерами
  - подходит для проброса vlan`ов
  - позволяет использовать link-state протоколы динамической маршрутизации
- TUN 
  - виртуальный интерфейс, работает на L3
  - универсален с точки зрения типа и устройства подключения
  - не позволяет использовать link-state протоколы динамической маршрутизации

### *RAS*

Инициализация PKI
```
cd /etc/openvpn/
/usr/share/easy-rsa/3/easyrsa init-pki
echo 'rasvpn' | /usr/share/easy-rsa/3/easyrsa build-ca nopass
echo 'rasvpn' | /usr/share/easy-rsa/3/easyrsa gen-req server nopass
echo 'yes' | /usr/share/easy-rsa/3/easyrsa sign-req server server
/usr/share/easy-rsa/3/easyrsa gen-dh
openvpn --genkey --secret ta.key
echo 'client' | /usr/share/easy-rsa/3/easyrsa gen-req client nopass
echo 'yes' | /usr/share/easy-rsa/3/easyrsa sign-req client client
echo 'iroute 192.168.33.0 255.255.255.0' > /etc/openvpn/client/client
```

Конфигурация сервера RAS:
```
port 1207
proto udp
dev tun
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
server 10.10.10.0 255.255.255.0
route 192.168.10.0 255.255.255.0
push "route 192.168.10.0 255.255.255.0"
ifconfig-pool-persist ipp.txt
client-to-client
client-config-dir /etc/openvpn/client
keepalive 10 120
persist-key
persist-tun
tls-auth ta.key 0
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
```

т.к. используется нестандартный порт openvpn необходимо выполнить настройку SELinux:
```
semanage port -a -t openvpn_port_t -p udp 1207
```

Конфигурация клиента:
```
dev tun
proto udp
remote 192.168.56.103 1207
client
resolv-retry infinite
ca ./ca.crt
cert ./client.crt
key ./client.key
route 192.168.10.0 255.255.255.0
persist-key
persist-tun
comp-lzo
verb 3
tls-auth ta.key 1
```

После подключения клиента в системе появляется интерфейс `tun0`, в таблице маршрутизации появляются маршруты через этот интерфейс, пингуется адрес сервера:
```sh
root@nas:/etc/openvpn# openvpn --config server.conf --daemon
root@nas:/etc/openvpn#
root@nas:/etc/openvpn#
root@nas:/etc/openvpn# ping 10.10.10.1 -c 2
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=2.41 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=2.79 ms

--- 10.10.10.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 2.411/2.601/2.792/0.190 ms
root@nas:/etc/openvpn#
root@nas:/etc/openvpn#
root@nas:/etc/openvpn#
root@nas:/etc/openvpn# ip route
default via 192.168.88.1 dev enp4s0
10.10.10.0/24 via 10.10.10.5 dev tun0
10.10.10.5 dev tun0 proto kernel scope link src 10.10.10.6
78.29.2.21 via 192.168.88.1 dev enp4s0
78.29.2.22 via 192.168.88.1 dev enp4s0
192.168.10.0/24 via 10.10.10.5 dev tun0
192.168.56.0/24 dev vboxnet0 proto kernel scope link src 192.168.56.1
192.168.88.0/24 dev enp4s0 proto kernel scope link src 192.168.88.212
192.168.88.1 dev enp4s0 scope link
root@nas:/etc/openvpn#
root@nas:/etc/openvpn#
root@nas:/etc/openvpn#
root@nas:/etc/openvpn# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:25:22:f7:15:57 brd ff:ff:ff:ff:ff:ff
    inet 192.168.88.212/24 brd 192.168.88.255 scope global enp4s0
       valid_lft forever preferred_lft forever
    inet 192.168.88.254/24 brd 192.168.88.255 scope global secondary dynamic enp4s0
       valid_lft 164515sec preferred_lft 164515sec
    inet6 fe80::225:22ff:fef7:1557/64 scope link
       valid_lft forever preferred_lft forever
3: vboxnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 0a:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.1/24 brd 192.168.56.255 scope global vboxnet0
       valid_lft forever preferred_lft forever
    inet6 fe80::800:27ff:fe00:0/64 scope link
       valid_lft forever preferred_lft forever
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none
    inet 10.10.10.6 peer 10.10.10.5/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::edf9:26b0:1f21:fb29/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
```

Файл статуса openvpn содержит о подключенном клиенте и маршрутах:
```sh
[root@ras vagrant]# cat /var/log/openvpn-status.log
OpenVPN CLIENT LIST
Updated,Fri Nov  4 12:15:25 2022
Common Name,Real Address,Bytes Received,Bytes Sent,Connected Since
client,192.168.56.1:38261,3490,3134,Sat Mar  2 12:15:03 2024
ROUTING TABLE
Virtual Address,Common Name,Real Address,Last Ref
10.10.10.6,client,192.168.56.1:38261,Sat Mar  2 12:15:04 2024
192.168.33.0/24,client,192.168.56.1:38261,Sat Mar  2 12:15:04 2024
GLOBAL STATS
Max bcast/mcast queue length,0
END
```

# **Результаты**

Полученный в ходе работы `Vagrantfile` и плейбук Ansible помещены в публичный репозиторий. Создаются 3 машины:
- `server` , `client`. Тип интерфейса `tun\tap` зависит от значения переменной `ovpndev` в файле  `ansible\defaults\main.yml`.  
- `ras` для подключения с хостовой машины клиентом openvpn, конфиг\ключи\сертификаты для подключения клиента содержатся в `ansible\files\client.conf\`
  
Генерация ключей и сертификатов PKI предварительно выполнена.


