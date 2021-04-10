#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){

    # 线程数
    $Throttle  = 10
    
    #$time_start = Get-Date

    # 获取宿主机信息的脚本块
    $Script_vmhost = {
        Param  (
            $VMhost

        )
        $ReportObj = "" | Select "ESXi 主机名","所属群集","电源状态","连接状态","CPU总量（MHz）","CPU使用量（MHz）","CPU使用率", "内存总容量（GB）","内存使用量（GB）","内存使用率","存储平均滞后时间（ms）","存储最长滞后时间（ms）","存储平均总吞吐量（KBps）","存储最大总吞吐量（KBps）","网络平均总吞吐量（KBps）","网络最大总吞吐量（KBps）"
        $ReportObj."ESXi 主机名" = $VMhost.Name
        $ReportObj."所属群集" = $VMhost.Parent.Name
        $ReportObj."电源状态" = $VMhost.PowerState
        $ReportObj."连接状态" = $VMhost.ConnectionState
        #$ReportObj."总体健康状态" = $ESXHost_View.OverallStatus
        #$ReportObj."告警次数" = $ESXHost_View.TriggeredAlarmState.Count
        #CPU使用情况
        $CpuTotalMhz = $VMhost.CpuTotalMhz
        $CpuUsageMhz = $VMhost.CpuUsageMhz
        $ReportObj."CPU总量（MHz）" = $CpuTotalMhz
        $ReportObj."CPU使用量（MHz）" = $CpuUsageMhz
        $ReportObj."CPU使用率" = "{0:P2}" -f ($CpuUsageMhz/$CpuTotalMhz)
        #内存使用情况
        $MemoryTotalGB = $VMhost.MemoryTotalGB
        $MemoryUsageGB = $VMhost.MemoryUsageGB
        $ReportObj."内存总容量（GB）" = $MemoryTotalGB
        $ReportObj."内存使用量（GB）" = $MemoryUsageGB
        $ReportObj."内存使用率" = "{0:P2}" -f ($MemoryUsageGB/$MemoryTotalGB)
        #最近一天的性能数据
        #存储滞后时间（是否小于30ms）
        #$disk_maxtotallatency = $VMhost | Get-Stat -Start ((Get-Date).adddays(-1)) -Finish (Get-Date) -Stat Disk.maxtotallatency.latest | Measure-Object -Maximum -Average -Property Value
        #存储总吞吐量（KBps）
        #$disk_usage = $VMhost | Get-Stat -Start ((Get-Date).adddays(-1)) -Finish (Get-Date) -Stat Disk.Usage.Average | Measure-Object -Maximum -Average -Property Value
        #网络总吞吐量（KBps）
        #$net_usage = $VMhost | Get-Stat -Start ((Get-Date).adddays(-1)) -Finish (Get-Date) -Stat Net.Usage.Average | Measure-Object -Maximum -Average -Property Value
        #$ReportObj."存储平均滞后时间（ms）" = $disk_maxtotallatency.Average
        #$ReportObj."存储最长滞后时间（ms）" = $disk_maxtotallatency.Maximum
        #$ReportObj."存储平均总吞吐量（KBps）" = $disk_usage.Average
        #$ReportObj."存储最大总吞吐量（KBps）" = $disk_usage.Maximum
        #$ReportObj."网络平均总吞吐量（KBps）" = $net_usage.Average
        #$ReportObj."网络最大总吞吐量（KBps）" = $net_usage.Maximum
        Return $ReportObj
    }

    # 获取存储信息的脚本块
    $Script_datastore = {
        Param  (
            $Datastore
        )
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

        Return $ReportObj
    }

    # 获取告警信息的脚本块
    $Script_datacenter = {
        Param  (
            $Datacenter
        )
        $ReportObj = "" | Select "数据中心名称","告警次数"
        $ReportObj."数据中心名称" = $Datacenter.Name
        $ReportObj."告警次数" = $Datacenter.TriggeredAlarmState.Count

        Return $ReportObj
    }


    #创建一个资源池，指定多少个runspace可以同时执行
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,$Throttle)
    $RunspacePool.Open()
    $Jobs_vmhost = @()
    $Jobs_datastore = @()
    $Jobs_datacenter = @()

    # 连接VC
    #$ip = "10.100.96.252"
    #Connect-VIServer -Server $ip -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd

    #获取所有宿主机信息
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


    #获取所有存储信息
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


    #获取所有数据中心告警信息
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
    #循环输出等待的信息.... 直到所有的job都完成 
    Write-Host  "Waiting.."  -NoNewline
    Do{
        #Write-Host  "."  -NoNewline
        #Start-Sleep -Seconds 0.5
    }
    While  ( $Jobs.Result.IsCompleted  -contains  $false )
    Write-Host  "All jobs completed!"



    #输出结果
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


    #导出报表
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
