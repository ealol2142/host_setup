# host_setup

## --- How to use ---

- В КВМ выбираем:
    - Drive -> Image: systemrescue-11.00-amd64.iso -> Connect drive to Server 
    - System -> Show keyboard -> Ctrl+Alt+Delete и нажимаем F2, пока не появится BIOS.
    - Вводим пароль от BIOS если он есть -> выбираем Boot Menu(F8) -> UEFI:PiKVM CD-ROM Drive 0515 (853MB) -> выбираем первый пункт

- Дальнейшие действия можно ставить в **Text -> поле для ввода текста -> Paste** или вводить руками.

    - Вставляем:

        ``` bash
        nmcli conn mod "Wired connection 1" ipv4.addr 0.0.0.0/25;
        nmcli conn mod "Wired connection 1" ipv4.gateway 1.1.1.1;
        nmcli conn mod "Wired connection 1" ipv4.dns 8.8.8.8;
        nmcli conn mod "Wired connection 1" ipv4.method manual;
        nmcli conn up "Wired connection 1”;
        ```
        Где:    
        - **ipv4.addr 0.0.0.0/25** - ваш айпи и маска подсети
        - **ipv4.gateway 1.1.1.1** - шлюз
        - **ipv4.dns 8.8.8.8** - DNS

    Должна появиться надпись ***"Connection successfully activated"***

    - Устанавливаем **Vim** или другой редактор текста:

        ``` bash
        pacman -Sy vim 
        ```

    - Клонируем и переходим в репу:

        ``` bash
        git clone https://github.com/ealol2142/host_setup.git &&
        cd host_setup
        ```

    - Смотрим количество подключенных nvme*n1 дисков:

        ``` bash
        lsblk | grep nvme
        ```
    - Редактируем **setup.conf** файл:

        ``` bash
        vim tmp/setup.conf
        ```
        Где:
        - вместо **\<enter CRYPTPASSWORD>** вводим криптоключ, который можно взять у ПМа или старшего девопса.
        - Удаляем лишние "DRIVE* /dev/nvme*n1", оставяем только подключенные nvme\*n1
        - После нажимаем esc -> :wq -> enter

    - Добавляем свой паблик ssh ключ:

        ``` bash
        echo "<you_ssh_key>" >> tmp/authorized_keys
        ```
        Где:
         - **<you_ssh_key>** - ваш паблик ssh ключ

    - Запускаем установку:

        ``` bash
        ./start.sh
        ```

    - После установки должна появиться надпись ***"INSTALLATION COMPLETE"***, перезагружаем систему:
    
        ``` bash
        reboot
        ```

    - Когда появится сообщение ***"Begin: Starting dropbear ..."*** - нажимаем enter. 

    - ***"Please unlock disk luks...:"*** - Text -> вставляем криптоключ в поле для ввода текста -> Paste. Ждем 3-5 секунд и нажимаем enter

    **ГОТОВО!**

В данной сборке используется кастомный **apt sources.list**, по этому не работает скачивание apt пакетов. Что бы это исправить нужно в терминале зайти на машину:

``` bash
ssh root@0.0.0.0
```
Где:
    **0.0.0.0** - IP адрес сервера

И заменить кастомный **apt sources.list** на оригинальный:
``` bash
rm -rf /etc/apt/sources.list &&
mv /etc/apt/sources.list.curtin.old /etc/apt/sources.list &&
apt update
```