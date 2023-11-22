# Docker

# **Содержание ДЗ**

* Создание кастомного образа `nginx` на базе `alpine`

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

Сборка образа:
```
docker build -t my-nginx:v1 .
```

Запуск контейнера из образа `docker-nginx:v1` с пробросом портов 8080 из контейнера на 80 хостовой ОС:
```
docker run -d -p 0.0.0.0:80:80 my-nginx:v1
```

Информация о запущенном контейнере:
```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                  NAMES
33010c091a68        my-nginx:v1     "nginx"             2 hours ago         Up 7 seconds        0.0.0.0:80->80/tcp   pensive_spence
```

Состояние портов в хостовой ОС:
```
[root@otus mynginx]# ss -tnlp | grep 80
LISTEN     0      128       [::]:80                    [::]:*                   users:(("docker-proxy-cu",pid=29672,fd=4))
```

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

Загрузка созданного образа в Docker Hub:
```
[root@otus mynginx]# docker login --username kentro
Password:
Login Succeeded
[root@otus mynginx]# docker tag my-nginx:v1 kentro/docker-day18:nginx
[root@otus mynginx]# docker push kentro/docker-day18:nginx
The push refers to a repository [docker.io/kentro/docker-day18]
5915ee3e31c5: Pushed
8adb465b142c: Pushed
8607ed268395: Pushed
24302eb7d908: Mounted from library/alpine
nginx: digest: sha256:2e62b8da0fbec05868dcb988a3e4bd040963b0bbfceeaa2d37507054b0d8eab4 size: 1153
```

