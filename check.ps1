#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #�ۺ���Эͬ�򡢰�ȫ���û�������
    
    #Connect-VIServer -Server $ip -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd

    #��������Ϣ
    $Report = @()
    #$VMhosts = Get-VMHost | Select-Object Name,Parent,PowerState,ConnectionState,CpuTotalMhz,CpuUsageMhz,MemoryTotalGB,MemoryUsageGB
    $VMhosts = Get-VMHost
    ForEach ($VMhost in $VMhosts)
    {
        $ReportObj = "" | Select "ESXi ������","����Ⱥ��","��Դ״̬","����״̬","CPU������MHz��","CPUʹ������MHz��","CPUʹ����", "�ڴ���������GB��","�ڴ�ʹ������GB��","�ڴ�ʹ����","�洢ƽ���ͺ�ʱ�䣨ms��","�洢��ͺ�ʱ�䣨ms��","�洢ƽ������������KBps��","�洢�������������KBps��","����ƽ������������KBps��","�����������������KBps��"
        $ReportObj."ESXi ������" = $VMhost.Name
        $ReportObj."����Ⱥ��" = $VMhost.Parent.Name
        $ReportObj."��Դ״̬" = $VMhost.PowerState
        $ReportObj."����״̬" = $VMhost.ConnectionState
        #$ReportObj."���彡��״̬" = $ESXHost_View.OverallStatus
        #$ReportObj."�澯����" = $ESXHost_View.TriggeredAlarmState.Count
        #CPUʹ�����
        $CpuTotalMhz = $VMhost.CpuTotalMhz
        $CpuUsageMhz = $VMhost.CpuUsageMhz
        $ReportObj."CPU������MHz��" = $CpuTotalMhz
        $ReportObj."CPUʹ������MHz��" = $CpuUsageMhz
        $ReportObj."CPUʹ����" = "{0:P2}" -f ($CpuUsageMhz/$CpuTotalMhz)
        #�ڴ�ʹ�����
        $MemoryTotalGB = $VMhost.MemoryTotalGB
        $MemoryUsageGB = $VMhost.MemoryUsageGB
        $ReportObj."�ڴ���������GB��" = $MemoryTotalGB
        $ReportObj."�ڴ�ʹ������GB��" = $MemoryUsageGB
        $ReportObj."�ڴ�ʹ����" = "{0:P2}" -f ($MemoryUsageGB/$MemoryTotalGB)
        #���һ�����������
        #�洢�ͺ�ʱ�䣨�Ƿ�С��30ms��
        #$disk_maxtotallatency = $VMhost | Get-Stat -Start ((Get-Date).adddays(-1)) -Finish (Get-Date) -Stat Disk.maxtotallatency.latest | Measure-Object -Maximum -Average -Property Value
        #�洢����������KBps��
        #$disk_usage = $VMhost | Get-Stat -Start ((Get-Date).adddays(-1)) -Finish (Get-Date) -Stat Disk.Usage.Average | Measure-Object -Maximum -Average -Property Value
        #��������������KBps��
        #$net_usage = $VMhost | Get-Stat -Start ((Get-Date).adddays(-1)) -Finish (Get-Date) -Stat Net.Usage.Average | Measure-Object -Maximum -Average -Property Value
        #$ReportObj."�洢ƽ���ͺ�ʱ�䣨ms��" = $disk_maxtotallatency.Average
        #$ReportObj."�洢��ͺ�ʱ�䣨ms��" = $disk_maxtotallatency.Maximum
        #$ReportObj."�洢ƽ������������KBps��" = $disk_usage.Average
        #$ReportObj."�洢�������������KBps��" = $disk_usage.Maximum
        #$ReportObj."����ƽ������������KBps��" = $net_usage.Average
        #$ReportObj."�����������������KBps��" = $net_usage.Maximum
        $Report += $ReportObj
    }
    #��������
    $path = "data/" + $ip + "VmHost.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path

    #�洢��Ϣ
    $Report2 = @()
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
        $Report2 += $ReportObj
    }
    $path = "data/" + $ip + "Datastore.csv"
    $Report2 | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
    #�������ĸ澯��Ϣ
    $Report3 = @()
    $Datacenters = Get-Datacenter | get-View | Select-Object Name,TriggeredAlarmState
    ForEach ($Datacenter in $Datacenters)
    {
        $ReportObj = "" | Select "������������","�澯����"
        $ReportObj."������������" = $Datacenter.Name
        $ReportObj."�澯����" = $Datacenter.TriggeredAlarmState.Count
        $Report3 += $ReportObj
    }
    $path = "data/" + $ip + "Alarm.csv"
    $Report3 | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path

    
}

Check -ip $ip -username $username -passwd $passwd
