# Управление пакетами. Дистрибьюция софта

### Ставим необходимые утилиты:
```
yum install -y redhat-lsblcore wget rpmdevtools rpm-build createrepo yum-utils gcc zlib-devel openssl-devel
```
### Качаем исходник nginx:
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.20.2-1.el7.ngx.src.rpm
```
### Устанавливаем исходник:
```
rpm -i nginx-1.20.2-1.el7.ngx.src.rpm
```
### Качаем  и распаковываем OpenSSL:
```
wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
unzip OpenSSL_1_1_1-stable.zip
```
1 Создать свой RPM пакет

2 Создать свой репозиторий и разместить там ранее собранный RPM




Содержимое:

default.conf - файл с измененными настройками nginx

nginx.spec - файл для сборки пакета

otus.repo - файл репозиторий

Vagrantfile - файл для создания виртуальной машины

Итог:

При поднятии VM применяются все необходимые настройки. Так же настроен проброс порта, работу можно проверить по http://127.0.0.1:8080/repo/


