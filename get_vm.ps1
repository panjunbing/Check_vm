#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #综合域、协同域、安全域、用户体验域
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd


    #虚拟机信息
    $Report = @()
    $VMs = Get-VM
    ForEach ($VM in $VMs)
    {
        $ReportObj = "" | Select "虚拟机名称","IP","电源状态","网卡状态","操作系统","CPU","内存","置备空间（GB）","已使用空间（GB）","虚拟机UID", "所属主机", "备注"
        #基本信息
        $ReportObj."虚拟机名称" = $VM.Name
        $ReportObj."IP" = $VM.guest.ipaddress[0]
        $ReportObj."电源状态" = $VM.PowerState
        $Network = $VM | Get-NetworkAdapter
        $ReportObj."网卡状态" = $Network.ConnectionState.Connected
        $ReportObj."操作系统" = $VM.guest.osfullname
        # CPU内存
        $NumCpu = $VM.NumCpu
        $CoresPerSocket = $VM.CoresPerSocket
        $ReportObj."CPU" = $NumCpu * $CoresPerSocket
        $ReportObj."内存" = $VM.MemoryGB
        #存储
        $ReportObj."置备空间（GB）" = $VM.ProvisionedSpaceGB
        $ReportObj."已使用空间（GB）" = $VM.UsedSpaceGB
        #其他
        $ReportObj."虚拟机UID" = $VM.Uid
        $ReportObj."所属主机" = $VM.VMHost
        $ReportObj."备注" = $VM.Notes
        $Report += $ReportObj
    }
    $path = "data/" + $ip + "vm.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
}

Check -ip $ip -username $username -passwd $passwd
