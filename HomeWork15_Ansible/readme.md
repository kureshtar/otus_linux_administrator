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


ansible nginx -i staging/hosts -m ping


![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork15_Ansible/images/Screenshot%20from%202023-11-08%2017-04-05.png)

