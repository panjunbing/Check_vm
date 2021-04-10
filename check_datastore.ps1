#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #综合域、协同域、安全域、用户体验域
    #Connect-VIServer -Server "10.100.96.252" -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd

    #存储信息
    $Report = @()
    $Datastores = Get-Datastore | Get-View | Select-Object Name,OverallStatus,TriggeredAlarmState,Summary
    #$Datastores = Get-Datastore
    ForEach ($Datastore in $Datastores)
    {
        $ReportObj = "" | Select "存储名","备注","总容量（GB）","总体健康状态","告警次数","使用容量（GB）","分配容量（GB）","存储使用率","存储分配率"
        $ReportObj."存储名" = $Datastore.Name
        #$ReportObj."备注" = $Datastore.ParentFolder
        $ReportObj."总体健康状态" = $Datastore.OverallStatus
        $ReportObj."告警次数" = $Datastore.TriggeredAlarmState.Count
        #capacity and free
        $DatastoreCapacity = [math]::round($Datastore.Summary.Capacity/1024/1024, 2)
        $DatastoreFree = [math]::round($Datastore.Summary.FreeSpace/1024/1024, 2)
        #$DatastoreCapacity = $Datastore.CapacityMB
        #$DatastoreFree = $Datastore.FreeSpaceGB
        $DatastoreUse = $DatastoreCapacity - $DatastoreFree
        $DatastoreProvisione = $DatastoreCapacity - $DatastoreFree + [math]::round($Datastore.Summary.Uncommitted/1024/1024, 2)
        $ReportObj."总容量（GB）" = $DatastoreCapacity
        $ReportObj."使用容量（GB）" = $DatastoreUse
        $ReportObj."分配容量（GB）" = $DatastoreProvisione
        $ReportObj."存储使用率" = "{0:P2}" -f ($DatastoreUse/$DatastoreCapacity)
        $ReportObj."存储分配率" = "{0:P2}" -f ($DatastoreProvisione/$DatastoreCapacity)
        $Report += $ReportObj
    }
    $path = "data/" + $ip + "Datastore.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
}

Check -ip $ip -username $username -passwd $passwd
