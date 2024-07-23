# host_setup

- В КВМ выбираем:
    - Drive -> Image: systemrescue-11.00-amd64.iso -> Connect drive to Server 
    - System -> Show keyboard -> Ctrl+Alt+Delete и нажимает F2, пока не появится BIOS.
    - Вводим пароль от BIOS если он есть -> выбираем Boot Menu(F8) -> UEFI:PiKVM CD-ROM Drive 0515 (853MB) -> выбираем первый пункт

- Дальнейшие действия можно ставить в Text -> поле для ввода текста -> Paste или вводить руками.

    - Вставляем:

        ``` bash
        nmcli conn mod "Wired connection 1" ipv4.addr 0.0.0.0/25;
        nmcli conn mod "Wired connection 1" ipv4.gateway 1.1.1.1;
        nmcli conn mod "Wired connection 1" ipv4.dns 8.8.8.8;
        nmcli conn mod "Wired connection 1" ipv4.method manual;
        nmcli conn up "Wired connection 1”;
        ```
        Где:    
        - ipv4.addr 0.0.0.0/25 - ваш айпи и маска подсети
        - ipv4.gateway 1.1.1.1 - шлюз
        - ipv4.dns 8.8.8.8 - DNS

    Должна появиться надпись "Connection succesfully activated"

    - Устанавливаем Vim или другой редактор текста

        ``` bash
        pacman -Sy vim 
        ```

    - Клонируем и переходим в репу

        ``` bash
        git clone https://github.com/ealol2142/host_setup.git &&
        cd host_setup &&
        ```

    - Смотрим количество подключенных nvme*n1 дисков 

        ``` bash
        lsblk | grep nvme
        ```
    - Редактируем setup.conf файл

        ``` bash
        vim tmp/setup.conf
        ```
        Где:
        - вместо <enter CRYPTPASSWORD> вводим криптоключ, который можно взять у ПМа или старшего девопса.
        - Удаляем лишние "DRIVE* /dev/nvme*n1", оставяем только подключенные nvme\*n1
        - После нажимаем esc -> :q -> enter

    - Добавляем свой паблик ssh ключ 

        ``` bash
        echo "<you_ssh_key>" >> tmp/authorized_keys
        ```
        Где:
         - <you_ssh_key> - ваш паблик ssh ключ

    - Запускаем установку

        ``` bash
        ./start.sh
        ```