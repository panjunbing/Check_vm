#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){

    # �߳���
    $Throttle  = 10
    
    #$time_start = Get-Date

    # ��ȡ��������Ϣ�Ľű���
    $Script_vmhost = {
        Param  (
            $VMhost

        )
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
        Return $ReportObj
    }

    # ��ȡ�洢��Ϣ�Ľű���
    $Script_datastore = {
        Param  (
            $Datastore
        )
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

        Return $ReportObj
    }

    # ��ȡ�澯��Ϣ�Ľű���
    $Script_datacenter = {
        Param  (
            $Datacenter
        )
        $ReportObj = "" | Select "������������","�澯����"
        $ReportObj."������������" = $Datacenter.Name
        $ReportObj."�澯����" = $Datacenter.TriggeredAlarmState.Count

        Return $ReportObj
    }


    #����һ����Դ�أ�ָ�����ٸ�runspace����ͬʱִ��
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,$Throttle)
    $RunspacePool.Open()
    $Jobs_vmhost = @()
    $Jobs_datastore = @()
    $Jobs_datacenter = @()

    # ����VC
    #$ip = "10.100.96.252"
    #Connect-VIServer -Server $ip -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd

    #��ȡ������������Ϣ
    $VMhosts = Get-VMHost
    ForEach ($VMhost in $VMhosts)
    {
        $Job = [powershell]::Create().AddScript( $Script_vmhost).AddArgument($VMhost)
        $Job.RunspacePool = $RunspacePool
        $Jobs_vmhost += New-Object  PSObject -Property @{
            Pipe = $Job
            Result = $Job.BeginInvoke()
        }
    }


    #��ȡ���д洢��Ϣ
    $Report2 = @()
    $Datastores = Get-Datastore | Get-View | Select-Object Name,OverallStatus,TriggeredAlarmState,Summary
    #$Datastores = Get-Datastore
    ForEach ($Datastore in $Datastores)
    {
        $Job = [powershell]::Create().AddScript( $Script_datastore).AddArgument($Datastore)
        $Job.RunspacePool = $RunspacePool
        $Jobs_datastore += New-Object  PSObject -Property @{
            Pipe = $Job
            Result = $Job.BeginInvoke()
        }
    }


    #��ȡ�����������ĸ澯��Ϣ
    $Report3 = @()
    $Datacenters = Get-Datacenter | get-View | Select-Object Name,TriggeredAlarmState
    ForEach ($Datacenter in $Datacenters)
    {
        $Job = [powershell]::Create().AddScript( $Script_datacenter).AddArgument($Datacenters)
        $Job.RunspacePool = $RunspacePool
        $Jobs_datacenter += New-Object  PSObject -Property @{
            Pipe = $Job
            Result = $Job.BeginInvoke()
        }
    }

    $Jobs = $Jobs_vmhost + $Jobs_datastore + $Jobs_datacenter
    #ѭ������ȴ�����Ϣ.... ֱ�����е�job����� 
    Write-Host  "Waiting.."  -NoNewline
    Do{
        #Write-Host  "."  -NoNewline
        #Start-Sleep -Seconds 0.5
    }
    While  ( $Jobs.Result.IsCompleted  -contains  $false )
    Write-Host  "All jobs completed!"



    #������
    $Report1 = @()
    $Report2 = @()
    $Report3 = @()
    ForEach  ($Job in $Jobs_vmhost ){
        $Report1 += $Job.Pipe.EndInvoke($Job.Result)
    }
    ForEach  ($Job in $Jobs_datastore ){
        $Report2 += $Job.Pipe.EndInvoke($Job.Result)
    }
    ForEach  ($Job in $Jobs_datacenter ){
        $Report3 += $Job.Pipe.EndInvoke($Job.Result)
    }


    #��������
    $Path_vmhost = "data/" + $ip + "VmHost.csv"
    $Path_datastore = "data/" + $ip + "Datastore.csv"
    $Path_alarm = "data/" + $ip + "Alarm.csv"
    $Report1 | Export-Csv -NoTypeInformation -Encoding UTF8 -path $Path_vmhost
    $Report2 | Export-Csv -NoTypeInformation -Encoding UTF8 -path $Path_datastore
    $Report3 | Export-Csv -NoTypeInformation -Encoding UTF8 -path $Path_alarm

    #$time_end = Get-Date
    #echo ($time_end - $time_start).TotalSeconds
}

Check -ip $ip -username $username -passwd $passwd
