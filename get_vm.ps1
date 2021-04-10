#Vmware Check
#Date: 2021/1/26 17:00
#Author:panjunbing

param($ip,$username,$passwd)
Function Check($ip,$username,$passwd){
    #�ۺ���Эͬ�򡢰�ȫ���û�������
    Connect-VIServer -Server $ip -Protocol https -Username $username -Password $passwd


    #�������Ϣ
    $Report = @()
    $VMs = Get-VM
    ForEach ($VM in $VMs)
    {
        $ReportObj = "" | Select "���������","IP","��Դ״̬","����״̬","����ϵͳ","CPU","�ڴ�","�ñ��ռ䣨GB��","��ʹ�ÿռ䣨GB��","�����UID", "��������", "��ע"
        #������Ϣ
        $ReportObj."���������" = $VM.Name
        $ReportObj."IP" = $VM.guest.ipaddress[0]
        $ReportObj."��Դ״̬" = $VM.PowerState
        $Network = $VM | Get-NetworkAdapter
        $ReportObj."����״̬" = $Network.ConnectionState.Connected
        $ReportObj."����ϵͳ" = $VM.guest.osfullname
        # CPU�ڴ�
        $NumCpu = $VM.NumCpu
        $CoresPerSocket = $VM.CoresPerSocket
        $ReportObj."CPU" = $NumCpu * $CoresPerSocket
        $ReportObj."�ڴ�" = $VM.MemoryGB
        #�洢
        $ReportObj."�ñ��ռ䣨GB��" = $VM.ProvisionedSpaceGB
        $ReportObj."��ʹ�ÿռ䣨GB��" = $VM.UsedSpaceGB
        #����
        $ReportObj."�����UID" = $VM.Uid
        $ReportObj."��������" = $VM.VMHost
        $ReportObj."��ע" = $VM.Notes
        $Report += $ReportObj
    }
    $path = "data/" + $ip + "vm.csv"
    $Report | Export-Csv -NoTypeInformation -Encoding UTF8 -path $path
}

Check -ip $ip -username $username -passwd $passwd
