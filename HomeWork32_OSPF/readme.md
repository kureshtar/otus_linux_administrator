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

![img_4](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/4.png)

![img_5](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/5.png)

2.2 Настройка ассиметричного роутинга

ansible-playbook -i ansible/hosts ansible/<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/ansible%20/task2.yml">task2.yml</a>

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/6.png)

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/7.png)

2.3 Настройка симметичного роутинга

ansible-playbook -i ansible/hosts ansible/<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/ansible%20/task3.yml">task3.yml</a>

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork32_OSPF/images/8.png)
