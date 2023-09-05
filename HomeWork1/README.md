# HomeWork №1

## Создание и запуск виртуальной машины при помощи Vagrant

Ручками через tor-браузер качнул vagrant box с Centos7 отсюда:

**https://app.vagrantup.com/centos/boxes/7**

Добавляю скаченный box в vagrant:

**vagrant box add centos7 CentOS-7-x86_64-Vagrant-2004_01.VirtualBox.box**

Проверяю добавился ли box в список вагранта:

**vagrant box list**

<sub>centos7 (virtualbox, 0)</sub>

Создаю простейший файл вагранта по умолчанию:

**vagrant init centos7**

Запускаю образ:

**vagrant up**

Захожу по ssh:

**vagrant ssh**
 
 
 
 
 
## Обновление ядра

Версия ядра до обновления:
**uname -r**

**3.10.0-1127.el7.x86_64**

**sudo su**

**yum install -y http://www.elrepo.org/elrepo-release-7.0-6.el7.elrepo.noarch.rpm**

**yum --enablerepo elrepo-kernel install kernel-ml -y**

**sudo grub2-mkconfig -o /boot/grub2/grub.cfg**

**sudo grub2-set-default 0**

**reboot**

Версия ядра после обновления:
**uname -r**

**6.5.1-1.el7.elrepo.x86_64**






