```python
# 导入 H3C 交换机模块
from h3c import Switch

# 定义配置选项
class ConfigOptions:
    def __init__(self):
        self.ip_address = None
        self.username = None
        self.password = None
        self.vlans = []
        self.dhcp_pools = []

# 定义配置函数
def configure_switch(options):
    # 连接到交换机
    switch = Switch(options.ip_address, options.username, options.password)

    # 配置基本设置
    switch.send_command("system-view")
    switch.send_command("user-interface vty 0 63")
    switch.send_command("authentication-mode scheme")
    switch.send_command("user-role level-15")
    switch.send_command("local-user mengjia network admin")

    # 启用 SSH 和 Telnet 服务器
    switch.send_command("ssh server enable")
    switch.send_command("telnet server enable")

    # 配置全局设置
    switch.send_command("lldp global enable")
    switch.send_command("loopback-detection global enable vlan 1 to 4094")
    switch.send_command("system-working-mode standard")
    switch.send_command("xbar load-balance")
    switch.send_command("password-recovery enable")

    # 配置 VLAN
    for vlan in options.vlans:
        switch.send_command("vlan {}".format(vlan))
        switch.send_command("description {}".format(vlan.description))
        switch.send_command("interface vlan {}".format(vlan))
        switch.send_command("ip address {} {}".format(vlan.ip_address, vlan.mask))

    # 配置 DHCP
    for dhcp_pool in options.dhcp_pools:
        switch.send_command("dhcp server ip-pool {}".format(dhcp_pool.name))
        switch.send_command("gateway-list {}".format(dhcp_pool.gateway))
        switch.send_command("network {}".format(dhcp_pool.network))
        switch.send_command("dns-list {}".format(dhcp_pool.dns))

    # 保存配置
    switch.save_config()

# 主函数
def main():
    # 创建配置选项
    options = ConfigOptions()
    options.ip_address = "192.168.1.1"
    options.username = "admin"
    options.password = "admin"
    options.vlans.append(VLAN(5, "研发", "10.0.0.1", "255.255.255.0"))
    options.vlans.append(VLAN(100, "财务", "192.168.100.1", "255.255.255.0"))
    options.dhcp_pools.append(DHCPPool("内网AP", "10.0.2.1", "10.0.2.254"))
    options.dhcp_pools.append(DHCPPool("外网AP", "10.0.4.1", "10.0.4.254"))

    # 配置交换机
    configure_switch(options)

# 调用主函数
if __name__ == "__main__":
    main()

```
