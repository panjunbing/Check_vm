from base import merge


# 输出虚拟机文件
def get_vm_ouput():
    name = '虚拟机信息'
    list_path = ['data/*vm.csv']
    list_sheet = ['虚拟机信息']
    merge(name, list_path, list_sheet)
    return None
