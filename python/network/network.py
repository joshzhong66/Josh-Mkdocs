from netaddr import IPNetwork

# 定义一个网络
network = IPNetwork('192.168.1.0/24')

# 获取子网
subnets = list(network.subnet(26))  # 每个子网的掩码是 /26，表示每个子网有 64 个 IP 地址

# 打印每个子网的信息
for idx, subnet in enumerate(subnets):
    print(f"子网 {idx + 1}:")
    print(f"  网络地址: {subnet.network}")
    print(f"  广播地址: {subnet.broadcast}")
    print(f"  可用的 IP 地址范围: {subnet[1]} - {subnet[-2]}")
    print(f"  子网掩码: {subnet.netmask}")
    print(f"  子网大小: {subnet.size} 个 IP 地址\n")

# 为每个子网分配第一个可用 IP 地址
for idx, subnet in enumerate(subnets):
    ip = subnet[1]  # 第一个可用 IP 地址（排除网络地址）
    print(f"为子网 {idx + 1} 分配的 IP 地址: {ip}")
