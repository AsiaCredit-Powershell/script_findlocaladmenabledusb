    Потребовалось сделать выборку локальных админов на ПК и узнать машины у которых включены USB
    Для этого написал этот скрипт. Он берет данные по админам из WMI и включенный USB из реестра на ПК
    HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR\" Параметр - Start. Где 3 = включено, 4 = выключено. 
    Это конвертируется в JSON и выгружается в файл C:\temp\AuditAMD.json" - сам файл каждый раз очищается после переноса его в переменную.
    Потом провожу проверку на уникальность и перезаписываю уникальные значения в файл. 
    Уникальность выбирается по имени ПК.
    Для конверта JSON в любой другой формат использую этот ресурс https://tools.icoder.uz/json-to-excel-converter.php

    JSON такой формы:
        {
            "ComputerName":  "ILC-FTK-CASH1",
            "Date":  "16-05-2021 10:32",
            "UserName":  [
                         "administrator",
                         "Zalman",
                         "Администраторы домена",
                         "Администраторы локальных машин",
                         "r.krivova",
                         "s.zagorodnyuk",
                         "m.chamina"
                     ],
            "StatusUSB":  "На ПК включены USB порты. Status № 3",
            "PSComputerName":  "ILC-FTK-CASH1",
            "RunspaceId":  "7ecbd8d6-79c1-4282-a1db-2c2b6eeee5e4",
            "PSShowComputerName":  true
        }
    
    
    @Chentsov_VS