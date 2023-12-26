# PAM
<b>Запретить всем пользователям, кроме группы admin, логин в выходные (суббота и воскресенье), без учета праздников.</b>
___
1) <a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork23_PAM/Vagrantfile">Vagrantfile</a>
2) <a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork23_PAM/login.sh">/usr/local/bin/login.sh</a>
3) <a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork23_PAM/sshd">/etc/pam.d/sshd</a>
___
После выполнения <b>vagrant up</b> подключаемся к ВМ, <b>vagrant ssh</b>

Переключаемся на root <b>sudo -i</b>

Создаем группы, пользователей и добавляем их в созданную группу

<b>useradd otusadm && useradd otus</b>

<b>echo "password123" | passwd --stdin otusadm && echo "password123" | passwd --stdin otus</b>

<b>groupadd -f admin</b>

<b>usermod otusadm -aG admin && usermod root -aG admin && usermod vagrant -aG admin</b>

Создаем файл-скрипт <b><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork23_PAM/login.sh">/usr/local/bin/login.sh</a></b> и добавляем права на исполнение

<b>chmod +x /usr/local/bin/login.sh</b>

Указываем в файле <b><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork23_PAM/sshd">/etc/pam.d/sshd</a></b> модуль pam_exec и созданный скрипт.

Проверяем возможность подключения по SSH. Для проверки работоспособности скрипта можно изменить дату на ВМ или добавить другой день в условии (если в момент выполнения не выходной день).

![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork23_PAM/images/pam.png)
