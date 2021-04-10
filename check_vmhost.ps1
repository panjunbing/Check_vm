#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #综合域、协同域、安全域、用户体验域
    #Connect-VIServer -Server "10.100.96.252" -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd


    #宿主机信息
    $Report = @()
    #$VMhosts = Get-VMHost | Select-Object Name,Parent,PowerState,ConnectionState,CpuTotalMhz,CpuUsageMhz,MemoryTotalGB,MemoryUsageGB
    $VMhosts = Get-VMHost
    ForEach ($VMhost in $VMhosts)
    {
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
        $Report += $ReportObj
    }
    #导出报表
    $path = "data/" + $ip + "VmHost.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
}

Check -ip $ip -username $username -passwd $passwd
