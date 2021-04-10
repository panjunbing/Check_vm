from configparser import RawConfigParser
import threading
import subprocess
import glob
import pandas
import datetime


# import xlrw

# 获取配置文件
def get_ini(list_ip, list_username, list_passwd):
    config = RawConfigParser()
    config.read("conf.ini")
    count = int(config.get('config', 'count'))
    for i in range(count):
        vc = 'VCenter' + str(i)
        list_ip.append(config.get(vc, 'ip'))
        list_username.append(config.get(vc, 'username'))
        list_passwd.append(config.get(vc, 'passwd'))
    # return list_ip, list_username, list_passwd


# 多线程运行PS脚本
def start_thread(list_ps_name, list_ip, list_username, list_passwd):
    list_thread = []
    for ps_name in list_ps_name:
        for i in range(len(list_ip)):
            try:
                thread = PSThread(ps_name, list_ip[i], list_username[i], list_passwd[i])
                thread.start()
                list_thread.append(thread)
            except Exception as e:
                print("thread not start!")
                print(e)
    for thread in list_thread:
        thread.join()


# 多线程执行PS脚本
class PSThread(threading.Thread):
    def __init__(self, ps_name, ip, username, passwd):
        threading.Thread.__init__(self)
        self.ps_name = ps_name
        self.ip = ip
        self.passwd = passwd
        self.username = username

    def run(self):
        try:
            args = [r"powershell.exe", r"-file", self.ps_name, r"-ip", self.ip, r"-username", self.username, r"-passwd",
                    self.passwd]
            print("start run " + self.ps_name + " " + self.ip)
            popen = subprocess.Popen(args, stdout=subprocess.PIPE)
            dt = popen.stdout.read()
            return dt
        except Exception as e:
            print(e)
        return False


# 删除历史数据
def del_his(file_path):
    try:
        args = ["del", file_path]
        print("已经清除历史数据")
        popen = subprocess.Popen(args, shell=True)
        return popen.stdout.read()
    except Exception as e:
        print(e)
    return False


# 合并并输出excel文件
def merge(name, list_path, list_sheet):
    """
    :param name: 输出excel的文件名
    :param list_path: csv文件路径
    :param list_sheet: 工作表名称
    :return:
    """
    # 汇总后的csv文件
    list_dt = []
    print("开始合并文件")
    # 合并多个csv文件
    for i in list_path:
        list_dt.append(merge_csv(i))
    # 合并成excle多个工作表
    merge_excel(name, list_dt, list_sheet)
    print("合并文件成功")
    return None


# 合并多个csv文件
def merge_csv(data_paths):
    """
    :param data_paths: 需要合并csv文件的路径
    :return:多个csv合并后的DataFrame
    """
    # 获取需要合并的文件名
    data_path_list = glob.glob(data_paths)
    print('总共发现%s个文件:' % len(data_path_list))
    # 读取第一个文件
    data_dt = pandas.read_csv(data_path_list[0])
    # 删掉列表第一个元素
    del data_path_list[0]
    # 遍历打开所获取到的文件
    for data_path in data_path_list:
        print(data_path)
        data = pandas.read_csv(data_path)
        data_dt = data_dt.append(data)
    return data_dt


# 写入excel
def merge_excel(name, list_dt, sheet_list):
    """
    :param name: 输出excel的文件名
    :param list_csv: 合并后的csv文件
    :param sheet_list: 工作表名称
    :return:
    """
    # 设置时间
    date = datetime.datetime.now()
    file_name = name + str(date.year) + '年' + str(date.month) + '月' + str(date.day) + '日.xlsx'
    # dataframe转excel
    write = pandas.ExcelWriter(file_name)
    for i in range(len(list_dt)):
        list_dt[i].to_excel(write, sheet_name=sheet_list[i])
    write.save()
    return None


# 设置excel格式
def set_excel(excel_path):
    return None
