# Управление процессами

### **Содержание ДЗ**

1. Написать свою реализацию ps ax используя анализ /proc
Результат ДЗ - рабочий скрипт который можно запустить.
____________________________________________________

### **Выполнение**

<p><a href="https://github.com/kureshtar/otus_linux_administrator/blob/main/HomeWork12_processes/psax_custom.sh">psax_custom.sh</a> - сам скрипт.</p>

Сохраняем список процессов в переменную $proc:
```
proc=$(ls /proc | grep -E "^[0-9]+$")
```
Сохраняем в переменную $clk_tck значение USER_HZ (равно 100):
```
clk_tck=$(getconf CLK_TCK)
```
