#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #�ۺ���Эͬ�򡢰�ȫ���û�������
    #Connect-VIServer -Server "10.100.96.252" -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd

    #�������ĸ澯��Ϣ
    $Report = @()
    $Datacenters = Get-Datacenter | get-View | Select-Object Name,TriggeredAlarmState
    ForEach ($Datacenter in $Datacenters)
    {
        $ReportObj = "" | Select "������������","�澯����"
        $ReportObj."������������" = $Datacenter.Name
        $ReportObj."�澯����" = $Datacenter.TriggeredAlarmState.Count
        $Report += $ReportObj
    }
    $path = "data/" + $ip + "Alarm.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
}

Check -ip $ip -username $username -passwd $passwd
