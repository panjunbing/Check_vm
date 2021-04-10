from base import get_ini, start_thread, del_his
import time


def get_vm():
    # 操作前删除旧数据
    del_his("data\\*vm.csv")
    # 开始
    print("开始搜集虚拟机信息")
    start_time = time.time()
    print(time.asctime(time.localtime(start_time)))
    # 获取连接信息
    list_ip, list_username, list_passwd = [], [], []
    get_ini(list_ip, list_username, list_passwd)
    # 多线程运行脚本
    start_thread(r"get_vm.ps1", list_ip, list_username, list_passwd)
    # 结束
    print("搜集信息结束")
    end_time = time.time()
    print("本次搜集信息所需时间：")
    print(end_time - start_time)
