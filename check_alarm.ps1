#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #综合域、协同域、安全域、用户体验域
    #Connect-VIServer -Server "10.100.96.252" -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd

    #数据中心告警信息
    $Report = @()
    $Datacenters = Get-Datacenter | get-View | Select-Object Name,TriggeredAlarmState
    ForEach ($Datacenter in $Datacenters)
    {
        $ReportObj = "" | Select "数据中心名称","告警次数"
        $ReportObj."数据中心名称" = $Datacenter.Name
        $ReportObj."告警次数" = $Datacenter.TriggeredAlarmState.Count
        $Report += $ReportObj
    }
    $path = "data/" + $ip + "Alarm.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
}

Check -ip $ip -username $username -passwd $passwd
