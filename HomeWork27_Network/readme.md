# Network
___
Цель:
* Соединить офисы в сеть согласно схеме и настроить роутинг
* Все сервера и роутеры должны ходить в инет черз inetRouter
* Все сервера должны видеть друг друга
* У всех новых серверов отключить дефолт на нат (eth0/ensp03), который вагрант поднимает для связи, при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс


1) <b>Расчет характеристик сетей</b>
___
<table>
  <tr><td>Name</td><td>Сеть</td><td>Маска</td><td>Кол-во адресов</td><td>Первый адрес в сети</td><td>Последний адрес в сети</td><td>Broadcast — адрес</td></tr>
  <tr><td colspan="7" align="center"><b>Central Network</b></td></tr>
    <tr><td>Directors</td><td>192.168.0.0/28</td><td>255.255.255.240</td><td>14</td><td>192.168.0.1</td><td>192.168.0.14</td><td>192.168.0.15</td></tr>
    <tr><td>Office hardware</td><td>192.168.0.32/28</td><td>255.255.255.240</td><td>14</td><td>192.168.0.33</td><td>192.168.0.46</td><td>192.168.0.47</td></tr>
    <tr><td>Wi-fi(mgt network)</td><td>192.168.0.64/26</td><td>255.255.255.192</td><td>62</td><td>192.168.0.65</td><td>192.168.0.126</td><td>192.168.0.127</td></tr>
  <tr><td colspan="7" align="center"><b>Office 1 network</b></td></tr>
    <tr><td>Dev</td><td>192.168.2.0/26</td><td>255.255.255.192</td><td>14</td><td>192.168.2.1</td><td>192.168.2.62</td><td>192.168.2.63</td></tr>
    <tr><td>Test</td><td>192.168.2.64/26</td><td>255.255.255.192</td><td>14</td><td>192.168.2.65</td><td>192.168.2.126</td><td>192.168.2.127</td></tr>
    <tr><td>Managers</td><td>192.168.2.128/26</td><td>255.255.255.192</td><td>14</td><td>192.168.2.129</td><td>192.168.2.190</td><td>192.168.2.191</td></tr>
    <tr><td>Office hardware</td><td>192.168.2.192/26</td><td>255.255.255.192</td><td>14</td><td>192.168.2.193</td><td>192.168.2.254</td><td>192.168.2.255</td></tr>
  <tr><td colspan="7" align="center"><b>Office 2 network</b></td></tr>
    <tr><td>Dev</td><td>192.168.1.0/25</td><td>255.255.255.128</td><td>126</td><td>192.168.1.1</td><td>192.168.1.126</td><td>192.168.1.127</td></tr>
    <tr><td>Test</td><td>192.168.1.128/26</td><td>255.255.255.192</td><td>62</td><td>192.168.1.129</td><td>192.168.1.190</td><td>192.168.1.191</td></tr>
    <tr><td>Office</td><td>192.168.1.192/26</td><td>255.255.255.192</td><td>62</td><td>192.168.1.193</td><td>192.168.1.254</td><td>192.168.1.255</td></tr>
  <tr><td colspan="7" align="center"><b>InetRouter — CentralRouter network</b></td></tr>
    <tr><td>Inet — central</td><td>192.168.255.0/30</td><td>255.255.255.252</td><td>2</td><td>192.168.255.1</td><td>192.168.255.2</td><td>192.168.255.3</td></tr>
</table>

2) <b>Настройка инфраструктуры:</b>

<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork27_Network/Vagrantfile">Vagrantfile</a>

<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork27_Network/ansible.cfg">ansible.cfg</a>

ansible-playbook -i hosts playbooks/<a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork27_Network/networklab.yml">networklab.yml</a>
