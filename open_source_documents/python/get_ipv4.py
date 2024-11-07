import subprocess
import re


List_Path = r'E:\GitHub\Josh-Mkdocs\open_source_documents\python\List.txt'
Result_Path = r'E:\GitHub\Josh-Mkdocs\open_source_documents\python\Result.txt'


with open(List_Path, 'r', encoding='utf-8') as infile, open(Result_Path, 'w', encoding='utf-8') as outfile:
    for line in infile:
        line = line.strip()
        # 检查是否为注释行
        if line.startswith('#') or not line:
            outfile.write(line + '\n')
            continue
        
        print(f'正在处理 {line}...')
        try:
            # 使用 subprocess 运行 nslookup 并获取输出
            result = subprocess.run(['nslookup', line, '8.8.8.8'], capture_output=True, text=True)
            output = result.stdout
            
            # 输出 nslookup 调试信息
            print(f'nslookup 输出:\n{output}')
            
            # 提取 IPv4 地址的正则表达式r'(?:\n|\r\n)\s+((?:\d{1,3}\.){3}\d{1,3})(?:\n|\r\n|$)'
            ipv4_addresses = re.findall(r'(?:\n|\r\n)\s+((?:\d{1,3}\.){3}\d{1,3})(?:\n|\r\n|$)', output)
            #ipv6_addresses = re.findall(r'Address:\s([0-9a-fA-F:]+)', output)

            # 优先提取 IPv4 地址，如果有 IPv6 也继续提取 IPv4
            if ipv4_addresses:
                for ip in ipv4_addresses:
                    outfile.write(f'{ip}\t{line}\n')
                print(f'找到的 IPv4 地址: {ipv4_addresses}')
            else:
                print(f'未找到 IPv4 地址: {line}')
            
            # 输出调试信息
            #if ipv6_addresses:
                #print(f'找到的 IPv6 地址: {ipv6_addresses}')

        except Exception as e:
            print(f'处理 {line} 时出错: {e}')

print('处理完成！')
