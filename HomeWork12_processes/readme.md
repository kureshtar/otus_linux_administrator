# Управление процессами

### **Содержание ДЗ**

1. Написать свою реализацию ps ax используя анализ /proc
Результат ДЗ - рабочий скрипт который можно запустить.
____________________________________________________

### **Выполнение**

<p><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork12_processes/psax_custom.sh">psax_custom.sh</a> - сам скрипт.</p>

### **Основные моменты скрипта:**

Сохраняем список процессов в переменную $proc:
```
proc=$(ls /proc | grep -E "^[0-9]+$")
```
Сохраняем в переменную $clk_tck значение USER_HZ (равно 100):
```
clk_tck=$(getconf CLK_TCK)
```
Перебираем в цикле значения всех pid из переменной $proc:
```
for pid in $proc; do
```
Для каждого pid делаем проверку на существование каталога с номером данного pid в папке /proc/:
```
 if [ -d /proc/$pid ]; then
```
Далее в цикле, если каталог с текущим pid существует, получаем значения tty, state, time, cmd, данные для которых берем из файла /proc/$pid/stat

https://stackoverflow.com/questions/39066998/what-are-the-meaning-of-values-at-proc-pid-stat
```
    stat=$(</proc/$pid/stat)
    cmd=$(echo "$stat" | awk -F" " '{print $2}')
    state=$(echo "$stat" | awk -F" " '{print $3}')
    tty=$(echo "$stat" | awk -F" " '{print $7}')
    utime=$(echo "$stat" | awk -F" " '{print $14}')
    stime=$(echo "$stat" | awk -F" " '{print $15}')
    ttime=$((utime + stime))
    time=$((ttime / clk_tck))
```
Далее в этом же цикле выводим полученные значения pid, tty, state, time, cmd:
```
 echo "${pid}|${tty}|${state}|${time}|${cmd}" | column -t -s "|"
```
