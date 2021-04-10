from base import get_ini, start_thread, del_his
import time


def check():
    # 操作前删除旧数据
    del_his("data\\*VmHost.csv")
    del_his("data\\*Alarm.csv")
    del_his("data\\*Datastore.csv")
    # 开始
    print("开始巡检")
    start_time = time.time()
    print(time.asctime(time.localtime(start_time)))
    # 获取连接信息
    list_ip, list_username, list_passwd = [], [], []
    get_ini(list_ip, list_username, list_passwd)
    # 多线程运行脚本
    # list_ps_name = [r"check_vmhost.ps1", r"check_datastore.ps1", r"check_alarm.ps1"]
    list_ps_name = [r"check2.ps1"]
    start_thread(list_ps_name, list_ip, list_username, list_passwd)

    # 结束
    print("巡检结束")
    end_time = time.time()
    print("本次巡检所需时间：")
    print(end_time - start_time)
