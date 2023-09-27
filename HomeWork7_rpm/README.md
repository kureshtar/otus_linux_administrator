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
```
```
unzip OpenSSL_1_1_1-stable.zip
```
### Доустанавливаем отсутствующие зависимости для Nginx:
```
yum-builddep /root/rpmbuild/SPECS/nginx.spec -y
```
### Добавляем в файле /root/rpmbuild/SPECS/nginx.spec в разделе %build строку для OpenSSL:
```
--with-openssl=/home/vagrant/openssl-OpenSSL_1_1_1-stable
```
### Собираем пакет:
```
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
```
### Устанавливаем собранный пакет:
```
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm
```
### Стартуем Nginx
```
systemctl start nginx
```
### Создаем папку для вебрепозитория:
```
mkdir /usr/share/nginx/html/repo
```
### Копируем в эту папку созданный rpm:
```
cp -f /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
```
### В файле /etc/nginx/conf.d/default.conf правим location:
```
 location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        autoindex on;
    }
```



Содержимое:

default.conf - файл с измененными настройками nginx

nginx.spec - файл для сборки пакета

otus.repo - файл репозиторий

Vagrantfile - файл для создания виртуальной машины

Итог:

При поднятии VM применяются все необходимые настройки. Так же настроен проброс порта, работу можно проверить по http://127.0.0.1:8080/repo/


