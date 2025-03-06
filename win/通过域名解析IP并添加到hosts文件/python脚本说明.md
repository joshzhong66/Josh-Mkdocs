# python脚本说明



> 本文代码是一个用于读取域名列表、通过 `ping` 命令检查这些域名的网络连接状态，并在连接失败时通过 Webhook 发送警报的脚本。这里以在 Linux 系统中操作为例。

## 一、安装Python

这里直接通过脚本安装好了 python，安装的版本为 `3.9.7` 。



## 二、创建脚本目录

```bash
mkdir -p /data/scripts
```



## 三、创建并进入虚拟环境

```bash
cd /data/scripts
python3 -m venv venv
source venv/bin/activate
```



## 四、配置python脚本

### 1.安装python模块

使用 `pip` 包管理工具命令安装脚本所需要的 python 模块：

```bash
pip install requests
pip install "urllib3<2"
```

> 注：这里 `urllib3` 模块安装的版本需要小于 `2.0` ，这是因为系统默认使用的 OpenSSL 版本为 `1.0.2k-fips`，如果要使用大于 `2.0` 的版本，则需要将系统的 OpenSSL 版本升级到 `1.1.1+` 以上。

### 2.创建脚本文件

在 `/data/scripts` 目录下创建名为 `domain_monitor.py` 的脚本文件，添加以下内容：

```python
cat > /data/scripts/domain_monitor.py <<'EOF'
import os
import requests
import subprocess
import platform


def read_domains(file_path):
    # 从文件中读取域名列表
    with open(file_path, 'r') as file:
        # 去除每行的前后空白字符，且只保留非空行
        domains = [line.strip() for line in file.readlines() if line.strip()]
    return domains


# 两种ping的调用方式
'''
def ping_domain(domain):
    # 判断当前操作系统
    if platform.system().lower() == "windows":
        # Windows 的 ping 命令参数
        response = os.system(f"ping -n 3 {domain} > nul")
    else:
        # Linux 的 ping 命令参数
        response = os.system(f"ping -c 3 -w 3 {domain} > /dev/null 2>&1")
    return response == 0
'''


def ping_domain(domain):
    # Ping 一个域名，如果成功则返回 True，否则返回 False。
    try:
        if platform.system().lower() == "windows":
            result = subprocess.run(
                ["ping", "-n", "3", domain],   # Windows ping 命令
                stdout=subprocess.DEVNULL,          # 丢弃标准输出
                stderr=subprocess.DEVNULL           # 丢弃标准错误
            )
        else:
            result = subprocess.run(
                ["ping", "-c", "3", domain],   # Linux ping 命令
                stdout=subprocess.DEVNULL,          # 丢弃标准输出
                stderr=subprocess.DEVNULL           # 丢弃标准错误
            )
        return result.returncode == 0     # 如果返回码是 0，表示 ping 成功
    except FileNotFoundError:
        # 捕获 FileNotFoundError，表示系统找不到 ping 命令
        print("Ping command not found.")
        return False


def send_webhook_alert(domain):
    # 如果 ping 失败，发送 webhook 警报
    webhook_url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7"
    payload = {
        "msgtype": "markdown",
        "markdown": {
            "content": f"> <font color=warning>Ping域名[{domain}]失败！</font>"
        }
    }
    response = requests.post(webhook_url, json=payload)
    if not response.status_code == 200:
        print(f"为域名[{domain}]发送告警失败，错误码：{response.status_code}")


def main():
    # file_path = r'E:\LearningNotes\Bat\Bat脚本\通过域名解析IP并添加到hosts文件\domain.txt'
    file_path = '/data/scripts/domain.txt'
    if not os.path.exists(file_path):
        print("未找到域名列表文件！")
        return 1
    
    domains = read_domains(file_path)
    for domain in domains:
        if not ping_domain(domain):
            print(f"Ping域名[{domain}]失败！")
            send_webhook_alert(domain)
        else:
            print(f"Ping域名[{domain}]成功！")


if __name__ == "__main__":
    main()
EOF
```

这段代码是一个用于读取域名列表、通过 `ping` 命令检查这些域名的网络连接状态，并在连接失败时通过 Webhook 发送警报的脚本。它支持 Windows 和 Linux 操作系统，根据操作系统不同执行相应的 `ping` 命令。如果某个域名无法 ping 通，它会发送一个 Webhook 警报（这里是一个钉钉群消息）。

#### 2.1 代码结构解析

1. **导入模块：**

   - `os` 用于与操作系统进行交互，如文件操作。
   - `requests` 用于发送 HTTP 请求，脚本中用于发送 Webhook 警报。
   - `subprocess` 用于执行外部命令（如 `ping`）。
   - `platform` 用于获取当前操作系统的信息，以决定执行哪种 `ping` 命令。

2. **`read_domains` 函数：**

   - **功能**：从指定路径的文件中读取域名列表。
   - **实现**：
     - `file.readlines()` 读取文件的每一行。
     - `line.strip()` 去除每行的前后空白字符。
     - `if line.strip()` 用于过滤掉空行。
   - 返回一个包含所有有效域名（去除空行和空白字符）的列表。

3. **`ping_domain` 函数：**

   - **功能**：通过 `ping` 命令检查域名是否可以访问。
   - **判断操作系统**：使用 `platform.system().lower()` 获取操作系统类型，根据操作系统决定使用 Windows 或 Linux 的 `ping` 命令。
   - **`subprocess.run`**：用来执行 `ping` 命令，并且重定向标准输出和标准错误到 `/dev/null` 或 `nul`，即不显示 `ping` 命令的输出。
   - **返回值**：
     - `returncode == 0` 表示 `ping` 成功，返回 `True`。
     - 如果 `ping` 失败或找不到 `ping` 命令，返回 `False`。

4. **`send_webhook_alert` 函数：**

   - **功能**：发送 Webhook 警报，如果 `ping` 失败，向指定的 Webhook URL 发送一个消息。
   - **实现**：
     - 使用 `requests.post` 发送 POST 请求，`json=payload` 将请求内容以 JSON 格式发送。
     - `payload` 是一个字典，包含要发送的消息内容。
     - 如果请求成功，`status_code` 应为 `200`，否则输出错误码。

5. **`main` 函数：**

   - **功能**：这是脚本的主逻辑。
   - **实现：**
     - 检查域名列表文件是否存在，如果不存在则打印错误消息并返回。
     - 调用 `read_domains` 函数读取域名列表。
     - 遍历每个域名，调用 `ping_domain` 检查是否能够 `ping` 通。如果失败，调用 `send_webhook_alert` 发送警报。

6. **`if __name__ == "__main__":`：**

   - **功能**：确保当脚本作为主程序运行时执行 `main()` 函数。

     `__name__` 的值是 `'__main__'` 时，说明脚本是直接运行，而不是作为模块导入。

#### 2.2 运行流程

1. **读取域名列表**：从文件 `/root/scripts/domain.txt` 中读取所有非空的域名。
2. **Ping 每个域名**：遍历读取到的域名列表，检查每个域名是否能够 ping 通。
   - 如果 ping 成功，输出 `Ping域名[domain]成功！`。
   - 如果 ping 失败，输出 `Ping域名[domain]失败！` 并发送 Webhook 警报。
3. **发送 Webhook 警报**：如果 `ping` 失败，脚本会向指定的 Webhook 发送一个钉钉消息，提醒某个域名无法 ping 通。

#### 2.3 使用场景

- **监控域名连通性**：用来定期检查一组域名的网络连接状态，如果无法连接会及时发送警报。
- **集成到系统监控**：可以将此脚本集成到更大的监控系统中，用于监控内部或外部服务的可用性。

### 3.赋权脚本文件

```bash
chmod +x /data/scripts/domain_monitor.py
```

### 4.创建域名列表文件

前面配置的脚本文件中还引用了一个域名列表文件，因此，需要在 `/data/scripts` 目录下创建名为 `domain.txt` 文件，在该文件内添加所需要测试的域名信息：

```bash
cat > /data/scripts/domain.txt <<'EOF'
www.google.com
www.google.com.hk
id.google.com.hk
ogads-pa.googleapis.com
www.google.com
google.com
accounts.google.com
workspace.google.com
meet.google.com
play.google.com
signaler-pa.clients6.google.com
ogads-pa.clients6.google.com
apis.google.com
lh3.googleusercontent.com
myaccount.google.com
calendar.google.com
ogs.google.com
slides.google.com
docs.google.com
gds.google.com
lh3.google.com
clients6.google.com
waa-pa.clients6.google.com
drive.google.com
drivefrontend-pa.clients6.google.com
people-pa.clients6.google.com
drive-thirdparty.googleusercontent.com
addons-pa.clients6.google.com
youtube.googleapis.com
apps.google.com
chatgpt.com
ab.chatgpt.com
auth.openai.com
auth0.openai.com
cdn.oaistatic.com
challenges.cloudflare.com
EOF
```

### 4.执行脚本文件

在虚拟环境中直接使用 `python` 命令执行脚本文件：

```bash
python domain_monitor.py
```

输出信息如下：

```bash
Ping域名[www.google.com]成功！
Ping域名[www.google.com.hk]成功！
Ping域名[id.google.com.hk]成功！
Ping域名[ogads-pa.googleapis.com]成功！
Ping域名[www.google.com]成功！
Ping域名[google.com]成功！
Ping域名[accounts.google.com]成功！
Ping域名[workspace.google.com]成功！
Ping域名[meet.google.com]成功！
Ping域名[play.google.com]成功！
Ping域名[signaler-pa.clients6.google.com]成功！
Ping域名[ogads-pa.clients6.google.com]成功！
Ping域名[apis.google.com]成功！
Ping域名[lh3.googleusercontent.com]成功！
Ping域名[myaccount.google.com]成功！
Ping域名[calendar.google.com]成功！
Ping域名[ogs.google.com]成功！
Ping域名[slides.google.com]成功！
Ping域名[docs.google.com]成功！
Ping域名[gds.google.com]成功！
Ping域名[lh3.google.com]成功！
Ping域名[clients6.google.com]成功！
Ping域名[waa-pa.clients6.google.com]成功！
Ping域名[drive.google.com]成功！
Ping域名[drivefrontend-pa.clients6.google.com]成功！
Ping域名[people-pa.clients6.google.com]成功！
Ping域名[drive-thirdparty.googleusercontent.com]失败！
Ping域名[addons-pa.clients6.google.com]成功！
Ping域名[youtube.googleapis.com]成功！
Ping域名[apps.google.com]成功！
Ping域名[chatgpt.com]成功！
Ping域名[ab.chatgpt.com]成功！
Ping域名[auth.openai.com]成功！
Ping域名[auth0.openai.com]成功！
Ping域名[cdn.oaistatic.com]成功！
Ping域名[challenges.cloudflare.com]成功！
```

其中，有一个域名 ping 失败了，会将告警发送到企微上，如下图所示：

![image-20241111220428810](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/11/11/6258cab3f2998d1c568f48f55a09b99e-image-20241111220428810-14688e.png)





