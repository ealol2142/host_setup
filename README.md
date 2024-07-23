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
