#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #�ۺ���Эͬ�򡢰�ȫ���û�������
    #Connect-VIServer -Server "10.100.96.252" -Protocol https -Username "root-admin" -Password "XXZX@%%1232ptywk"
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
}

Check -ip $ip -username $username -passwd $passwd
