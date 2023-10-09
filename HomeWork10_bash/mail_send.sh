#!/bin/bash
#VARIABLES_BEGIN
DATE=$(date -d '1 hour ago' "+%d/%m/%Y %H:00:00")
ACCESS_LOG='/var/log/httpd/access_log'
ERROR_LOG='/var/log/httpd/error_log'
RUN_FLAG=/tmp/watchdog.run
#VARIABLES_END

function finish {
    rm -f "$RUN_FLAG";
    exit 0;
}

if [[ -f $RUN_FLAG ]]; # если создан флаг, скрипт уже запущен или некорректно завершён
    then echo "!!! SCRIPT ALWAYS RUNNING OR UNSUCCESSFULY COMPLITED !!! If you're sure, delete the file /tmp/watchdog.run and run again."; exit 1;
fi
touch $RUN_FLAG # создание флага запущенного скрипта
trap finish EXIT # при нормальном завершении, при получении прерывающего сигнала, который может быть обработан удалить флаг запуска

#echo "Статистика за последний час начиная с $DATE"
COUNT_IP=$(grep "`date +"%d"`.*`date -d '1 hour ago' +"%H"`:[0-9][0-9]:[0-9][0-9]" $ACCESS_LOG | awk {'print $1'} | sort | uniq -c)
COUNT_URL=$(grep "`date +"%d"`.*`date -d '1 hour ago' +"%H"`:[0-9][0-9]:[0-9][0-9]" $ACCESS_LOG | awk {'print $7'} | sort | uniq -c)
COUNT_STATUS=$(grep "`date +"%d"`.*`date -d '1 hour ago' +"%H"`:[0-9][0-9]:[0-9][0-9]" $ACCESS_LOG | awk {'print $9'} | sort | uniq -c)
#echo "Ошибки за последний час начиная с $DATE"
LIST_ERROR=$(grep "`date +"%d"`.*`date -d '1 hour ago' +"%H"`:[0-9][0-9]:[0-9][0-9]" $ERROR_LOG)

echo -e "Статистика за последний час начиная с $DATE\n\n$COUNT_IP\n\n$COUNT_URL\n\n$COUNT_STATUS\n\n\nОшибки за последний час начиная с $DATE\n\n$LIST_ERROR" | mail -s "New report" -r kentonik@yandex.ru

finish # очистка флага запущенного скрипта и выход
