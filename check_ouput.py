from base import merge


# 输出巡检文件
def check_output():
    name = '虚拟平台巡检附件'
    list_path = ['data/*VmHost.csv', 'data/*Datastore.csv', 'data/*Alarm.csv']
    list_sheet = ['宿主机巡检结果', '存储巡检结果', '告警次数']
    merge(name, list_path, list_sheet)
    return None
