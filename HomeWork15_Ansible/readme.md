# Ansible

### **Содержание ДЗ**
Подготовить стенд на Vagrant. Используя Ansible необходимо развернуть nginx со следующими условиями:
- необходимо использовать модуль yum/apt
- конфигурационные файлы должны быть взяты из шаблона jinja2 с переменными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible
---
### **Выполнение ДЗ**

Структура проекта с использованием Ansible:

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork15_Ansible/images/Screenshot%20from%202023-11-08%2017-04-05.png)

Конфигурационный файл ansible.cfg содержит параметры подключения:
```
[defaults]
inventory = staging/hosts
remote_user = vagrant
host_key_checking = False
retry_files_enabled = False
```
Inventory файл staging/hosts с единственным хостом:
```
[web]
nginx ansible_host=127.0.0.1 ansible_port=2222 ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key
```
Файл шаблона templates/nginx.conf.j2 с конфигурацией Nginx:
```
# {{ ansible_managed }}
events {
    worker_connections 1024;
}

http {
    server {
        listen       {{ nginx_listen_port }} default_server;
        server_name  default_server;
        root         /usr/share/nginx/html;

        location / {
        }
    }
}
```
