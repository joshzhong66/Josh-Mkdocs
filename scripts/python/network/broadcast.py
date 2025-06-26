# 获取广播地址

from netaddr import IPNetwork

# 定义一个网络
network = IPNetwork('192.168.1.0/24')

# 获取广播地址
broadcast_address = network.broadcast

# 打印广播地址
print(f"广播地址: {broadcast_address}")
