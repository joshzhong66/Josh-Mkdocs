from netaddr import IPSet, IPRange, IPAddress, IPNetwork
 
# IP  以IPv4 地址范围示例
ipv4_addr_space = IPSet(['0.0.0.0/0'])
private = IPSet(['10.0.0.0/8', '172.16.0.0/12', '192.0.2.0/24', '192.168.0.0/16', '239.192.0.0/14'])
reserved = IPSet(['225.0.0.0/8', '226.0.0.0/7', '228.0.0.0/6', '234.0.0.0/7', '236.0.0.0/7', '238.0.0.0/8', '240.0.0.0/4'])
unavailable = reserved | private
available = ipv4_addr_space ^ unavailable
#print(ipv4_addr_space)
#print(private)
#print(reserved)
#print(unavailable)
#print(available)
#print("*" * 100)
 
# for cidr in available.iter_cidrs():
#     print(cidr, cidr[0], cidr[-1])
 
#print("*" * 100)
 
print(ipv4_addr_space ^ available)
#print(ipv4_addr_space ^ unavailable)