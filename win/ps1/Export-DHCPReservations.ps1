# 定义DHCP服务器地址
$dhcpServer = "10.22.50.1"

# 定义日期时间格式
$dateTime = (Get-Date).ToString("yyyyMMddHHmm")  # 格式为 202501091000

# 定义CSV文件路径，带上时间戳
$csvPath = "C:\Users\Administrator\Desktop\scripts\DHCP_Reservations_$dateTime.csv"

Write-Host "正在连接到DHCP服务器: $dhcpServer..."

# 初始化CSV文件，写入表头
"ScopeId,IPAddress,ClientId" | Out-File -FilePath $csvPath -Encoding UTF8

# 获取所有作用域
Write-Host "正在获取所有作用域..."
$scopes = netsh dhcp server \\$dhcpServer show scope

# 遍历每个作用域
Write-Host "开始遍历作用域..."
foreach ($scope in $scopes) {
    # 提取作用域ID
    if ($scope -match "(\d+\.\d+\.\d+\.\d+)") {
        $scopeId = $matches[1]
        Write-Host "正在处理作用域: $scopeId..."

        # 获取当前作用域的保留地址
        Write-Host "正在获取作用域 $scopeId 的保留地址..."
        $reservedIps = netsh dhcp server \\$dhcpServer scope $scopeId show reservedip

        # 解析保留地址信息
        Write-Host "正在解析保留地址信息..."
        foreach ($line in $reservedIps) {
            if ($line -match "(\d+\.\d+\.\d+\.\d+)\s+-\s+([0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2}){5})") {
                $ipAddress = $matches[1]
                
                # 格式化MAC地址，去掉所有的短横线
                # $clientId = $matches[2]
                $clientId = $matches[2] -replace "-", ""
                # 写入单行到CSV文件
                "$scopeId,$ipAddress,$clientId" | Out-File -FilePath $csvPath -Encoding UTF8 -Append
                Write-Host "已写入保留地址: $ipAddress (客户端: $clientId)"
            }
        }
    }
}

Write-Host "DHCP保留地址已成功导出到 $csvPath"
Write-Host "脚本执行完成！"