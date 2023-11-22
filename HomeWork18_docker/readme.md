# Docker

# **Содержание ДЗ**

* Создание кастомного образа `nginx` на базе `alpine`

Для проверки ДЗ:
1. Загрузите образ (без запуска) используя команду docker pull kentro/docker-day18:nginx
2. Запустите контейнер, используйте команду docker run -d -p 80:80 --name web1 kentro/docker-day18:nginx
3. Для проверки работоспособности контейнера используйте команду curl -a http://localhost:80
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork18_docker/images/Screenshot%20from%202023-11-22%2009-47-39.png)

# **Выполнение**

### Создание кастомного образа `nginx` на базе `alpine`

Установка и включение `docker` на ubuntu согласно документации:
https://docs.docker.com/engine/install/ubuntu/
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# To install the latest version, run:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable containerd.service
systemctl enable docker.service
systemctl start containerd.service
systemctl start docker.service
```

Содержимое `Dockerfile`. Образ собирается на основе последнего образа `alpine`, 
в образ устанавливается `nginx`, в образ копируется кастомный файл index.html:

```
FROM nginx:alpine
RUN apk update
COPY ./index.html /usr/share/nginx/html/index.html
```

Содержимое кастомного файла `index.html`:

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>NGINX</title>
</head>
<body>
    Server is online
</body>
</html>
```


Сборка образа:
```
docker build -t my-nginx:v1 .
```

Запуск контейнера из образа `docker-nginx:v1` с пробросом портов 80 из контейнера на 80 хостовой ОС:
```
docker run -d -p 0.0.0.0:80:80 my-nginx:v1
```

Информация о запущенном контейнере:
```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                  NAMES
1fd3e65b186a        my-nginx:v1     "nginx"             2 hours ago         Up 7 seconds        0.0.0.0:80->80/tcp   hardcore_dijkstra
```

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork18_docker/images/Screenshot%20from%202023-11-22%2009-47-11.png)

Состояние портов в хостовой ОС:
```
[root@otus mynginx]# ss -tnlp | grep 80
LISTEN     0      128       [::]:80                    [::]:*                   users:(("docker-proxy-cu",pid=29672,fd=4))
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork18_docker/images/Screenshot%20from%202023-11-22%2009-47-39.png)

При запросе к 80 порту хостовой ОС nginx из контейнера отдаёт страницу:
```
[root@otus mynginx]# curl -a http://localhost:80
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>NGINX</title>
</head>
<body>
    Server is online
</body>
</html>
```
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork18_docker/images/Screenshot%20from%202023-11-22%2009-47-55.png)

Загрузка созданного образа в Docker Hub:
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork18_docker/images/Screenshot%20from%202023-11-22%2010-06-25.png)

