import ipaddress

def find_minimum_supernet(start_ip, end_ip):
    start = int(ipaddress.IPv4Address(start_ip))
    end = int(ipaddress.IPv4Address(end_ip))

    # 起点是 start，但我们不强求网络地址等于 start，只要求覆盖范围包含 start ~ end
    for prefix_len in range(32, -1, -1):
        network = ipaddress.IPv4Network((start, prefix_len), strict=False)
        if int(network.broadcast_address) >= end:
            return network
    return None

def main():
    # 可修改为任意起止 IP
    start_ip = "10.22.60.0"
    end_ip = "10.22.64.255"

    network = find_minimum_supernet(start_ip, end_ip)

    if network:
        print(f"最小可覆盖范围的子网: {network.with_prefixlen}")
        print(f"地址范围: {network.network_address} - {network.broadcast_address}")
        print(f"总地址数: {network.num_addresses}")
    else:
        print("无法找到合适的子网。")

if __name__ == "__main__":
    main()
