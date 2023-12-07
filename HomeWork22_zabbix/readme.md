# otus-linux-day22
Системы мониторинга. Zabbix. Prometheus.

# **Содержание ДЗ**

* Настройка мониторинга. На сервере установить Zabbix, настроить дашборд с 4-мя графиками:
  - процессор;
  - память;
  - диск;
  - сеть;

## Установка Zabbix
Установил Zabbix по этой инструкции:
https://www.zabbix.com/download?zabbix=6.4&os_distribution=ubuntu&os_version=22.04&components=server_frontend_agent&db=mysql&ws=apache

Перед выполнением пункта "C. Create initial database"  нужно поставить mysql командой (для Ubuntu):
```
sudo apt-get install mysql-server
```
Настроенный дашборд:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork22_zabbix/images/Screenshot%20from%202023-12-07%2005-08-26.png)
