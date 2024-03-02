# OSPF
___
Цель:
* Создать домашнюю сетевую лабораторию.
* Научится настраивать протокол OSPF в Linux-based системах.

Выполнение:
Настройка VM и OSPF между машинами на базе Quagga

<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/Vagrantfile">Vagrantfile</a>

<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/ansible%20/ansible.cfg">ansible.cfg</a>

ansible-playbook -i ansible/hosts ansible/<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/ansible%20/task1.yml">task1.yml</a>

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/1.png)

![img_2](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/2.png)

![img_3](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/3.png)

Если мы правильно настроили OSPF, то с любого хоста нам должны быть доступны сети:
192.168.10.0/24
192.168.20.0/24
192.168.30.0/24
10.0.10.0/30 
10.0.11.0/30
10.0.13.0/30


Проверим доступность сетей с хоста router1:
Попробуем сделать ping до ip-адреса 192.168.30.1
И запустим трассировку до адреса 192.168.30.1.

![img_4](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/4.png)

Попробуем отключить интерфейс enp0s9 и немного подождем и снова запустим трассировку до ip-адреса 192.168.30.1
Как мы видим, после отключения интерфейса сеть 192.168.30.0/24 нам остаётся доступна:

![img_5](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/5.png)

## 2.2 Настройка ассиметричного роутинга

ansible-playbook -i ansible/hosts ansible/<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/ansible%20/task2.yml">task2.yml</a>

После внесения данных настроек, мы видим, что маршрут до сети 192.168.20.0/30  теперь пойдёт через router2, но обратный трафик от router2 пойдёт по другому пути. 

Давайте это проверим:

1) На router1 запускаем пинг от 192.168.10.1 до 192.168.20.1: 

```
ping -I 192.168.10.1 192.168.20.1
```

2) На router2 запускаем tcpdump, который будет смотреть трафик только на порту enp0s9.
```
tcpdump -i enp0s9
```

Видим что данный порт только получает ICMP-трафик с адреса 192.168.10.1:


![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/6.png)

На router2 запускаем tcpdump, который будет смотреть трафик только на порту enp0s8:
```
tcpdump -i enp0s8
```


![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/7.png)

Видим что данный порт только отправляет ICMP-трафик на адрес 192.168.10.1

Таким образом мы видим ассиметричный роутинг.


## 2.3 Настройка симметичного роутинга

Так как у нас уже есть один «дорогой» интерфейс, нам потребуется добавить ещё один дорогой интерфейс, чтобы у нас перестала работать ассиметричная маршрутизация. 

Так как в прошлом задании мы заметили что router2 будет отправлять обратно трафик через порт enp0s8, мы также должны сделать его дорогим и далее проверить, что теперь используется симметричная маршрутизация:

Поменяем стоимость интерфейса enp0s8 на router2:

ansible-playbook -i ansible/hosts ansible/<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/ansible%20/task3.yml">task3.yml</a>

После внесения данных настроек, мы видим, что маршрут до сети 192.168.10.0/30  пойдёт через router2.

Давайте это проверим:
1) На router1 запускаем пинг от 192.168.10.1 до 192.168.20.1: 

```
ping -I 192.168.10.1 192.168.20.1
```

2) На router2 запускаем tcpdump, который будет смотреть трафик только на порту enp0s9:
```
tcpdump -i enp0s9
```
Теперь мы видим, что трафик между роутерами ходит симметрично:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/8.png)
