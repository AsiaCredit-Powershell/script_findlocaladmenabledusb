
# Настраиваем переменные под работу и забираем старые данные 
$JSONPath = "C:\temp\AuditAMD.json"
$NamePCs = (Get-ADComputer -Filter 'name -like "*cash*"').name 
$OldData = Get-Content -Path $JSONPath

# Очищаем старый файл с данными и в цикле подключаемся к компам 
Remove-Item -Path $JSONPath
$NewData = foreach ($namePC in $namePCs) {
    Invoke-Command -ComputerName $namePC -ScriptBlock {    
        
        # Ищем WMI и ищем там администраторов 
        $LocalGroup = Get-CimInstance win32_groupuser  
        $Users = ($LocalGroup | where {$_.GroupComponent.Name -like "Администраторы" -or $_.GroupComponent.Name -like "administrators"}).partcomponent.name
        
        # Формируем hash-table для последующей записи в JSON
        $Array = [pscustomobject]@{ComputerName = $env:COMPUTERNAME
            Date = (get-date -Format 'dd-MM-yyyy hh:mm')
            UserName = $Users
            }
        
        # Формируем пути и основные выводы 
        $USBStatus = (Get-ItemProperty  "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR\").start
        $MsgUSBEnable = "На ПК включены USB порты. Status № " + "$USBStatus"
        $MsgUSBDisable = "На ПК отключены USB порты. Status №  " + "$USBStatus"
        $MsgUSBUnknow = "Статус портов определить не удалось. Status №  " + "$USBStatus"

        if ($USBStatus -eq 3) 
        {
            Add-Member -InputObject $Array -MemberType NoteProperty -Name StatusUSB -Value $MsgUSBEnable
        }

        elseif ($USBStatus -eq 4)
        {
            Add-Member -InputObject $Array -MemberType NoteProperty -Name StatusUSB -Value $MsgUSBDisable
        }

        else 
        {
            Add-Member -InputObject $Array -MemberType NoteProperty -Name StatusUSB -Value $MsgUSBUnknow
        }
        
        $Array
    }
}

# Соединяем таблицы и берем только уникальные значения и записываем их в файл 
$uniqueComps = ($OldData + $NewData).computername | Get-Unique 
$uniqueData = foreach ($uniqueComp in $uniqueComps) {
    $Data = $NewData | Where-Object {$_.computername -like "$uniqueComp"} 
    $Data
}
ConvertTo-Json -InputObject $uniqueData | Out-File $JSONPath -Encoding utf8 -Append