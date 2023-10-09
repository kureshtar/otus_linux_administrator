# bash
### **Содержание ДЗ**

<b>Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.</b>
___
<b>Необходимая информация в письме:</b>

Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;

Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;

Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта;

Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения;

Ошибки веб-сервера/приложения c момента последнего запуска.
___

### **Выполнение**

В секции с переменными задаются параметры запуска скрипта

```
#VARIABLES_BEGIN
DATE=$(date -d '1 hour ago' "+%d/%m/%Y %H:00:00")
ACCESS_LOG='/var/log/httpd/access_log'
ERROR_LOG='/var/log/httpd/error_log'
RUN_FLAG=/tmp/watchdog.run
#VARIABLES_END
```

Защита от мультизапуска реализована созданием при старте контрольного файла и удалением его при корректном завершении скрипта:
```
if [[ -f $RUN_FLAG ]]; # если создан флаг, скрипт уже запущен или некорректно завершён
    then echo "!!! SCRIPT ALWAYS RUNNING OR UNSUCCESSFULY COMPLITED !!! If you're sure, delete the file /tmp/watchdog.run and run again."; exit 1;
fi
touch $RUN_FLAG # создание флага запущенного скрипта
```

Используется bash trap для удаления контрольного файла при при нормальном завершении, 
при получении прерывающего сигнала, который может быть обработан (не сработает, если:
скрипт был убит сигналом SIGKILL, OOM-killer убил скрипт, машина внезапно выключилась/потеряла питание):
```
function finish {
    rm -f "$RUN_FLAG";
    exit 0;
}
trap finish EXIT 
```

Для отправки e-mail используется `mail` с почтового ящика на Yandex

<p><b>Скрипт</b> - <a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork10_bash/mail_send.sh">mail_send.sh</a>

<p><b>crontab</b></p>
  
![img_1](https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork10_bash/images/img1.JPG)

###  **Результаты**

Полученный скрипт mail_send.sh помещен в публичный репозиторий.
Анализируемые логи  -  `/var/log/httpd/access_log` и '/var/log/httpd/error_log'
