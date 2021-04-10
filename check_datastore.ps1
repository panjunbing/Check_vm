#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #�ۺ���Эͬ�򡢰�ȫ���û�������
    #Connect-VIServer -Server "10.100.96.252" -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd

    #�洢��Ϣ
    $Report = @()
    $Datastores = Get-Datastore | Get-View | Select-Object Name,OverallStatus,TriggeredAlarmState,Summary
    #$Datastores = Get-Datastore
    ForEach ($Datastore in $Datastores)
    {
        $ReportObj = "" | Select "�洢��","��ע","��������GB��","���彡��״̬","�澯����","ʹ��������GB��","����������GB��","�洢ʹ����","�洢������"
        $ReportObj."�洢��" = $Datastore.Name
        #$ReportObj."��ע" = $Datastore.ParentFolder
        $ReportObj."���彡��״̬" = $Datastore.OverallStatus
        $ReportObj."�澯����" = $Datastore.TriggeredAlarmState.Count
        #capacity and free
        $DatastoreCapacity = [math]::round($Datastore.Summary.Capacity/1024/1024, 2)
        $DatastoreFree = [math]::round($Datastore.Summary.FreeSpace/1024/1024, 2)
        #$DatastoreCapacity = $Datastore.CapacityMB
        #$DatastoreFree = $Datastore.FreeSpaceGB
        $DatastoreUse = $DatastoreCapacity - $DatastoreFree
        $DatastoreProvisione = $DatastoreCapacity - $DatastoreFree + [math]::round($Datastore.Summary.Uncommitted/1024/1024, 2)
        $ReportObj."��������GB��" = $DatastoreCapacity
        $ReportObj."ʹ��������GB��" = $DatastoreUse
        $ReportObj."����������GB��" = $DatastoreProvisione
        $ReportObj."�洢ʹ����" = "{0:P2}" -f ($DatastoreUse/$DatastoreCapacity)
        $ReportObj."�洢������" = "{0:P2}" -f ($DatastoreProvisione/$DatastoreCapacity)
        $Report += $ReportObj
    }
    $path = "data/" + $ip + "Datastore.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
}

Check -ip $ip -username $username -passwd $passwd
