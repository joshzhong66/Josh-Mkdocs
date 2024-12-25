# Ansible-playbook规范



问：为什么不把所有的配置都写在一个playbook文件上，而是拆分这么多文件编写？

答：将Ansible配置拆分为多个文件而不是集中在一个Playbook中，主要是为了提升可维护性、可重用性和灵活性。



## 一、Ansible推荐目录结构

这种结构使配置在大规模项目中更具扩展性，也符合社区标准，更容易被新成员理解和使用。

```
roles/
  logstash/
    tasks/
    handlers/
    templates/
    vars/
    meta/
```



## 二、**解析角色目录结构**

- **handlers**：定义了重启Logstash服务的处理器（`main.yml`）。
- **meta**：角色的依赖声明（`main.yml`，例如依赖于`jdk`角色）。
- **tasks**：主要任务（`main.yml`），包括添加APT源、安装Logstash、配置SSL目录和证书、设置默认启动等。
- **templates**：存放Jinja2模板文件，如`02-beats-input.conf.j2`、`10-syslog-filter.conf.j2`等。
- **vars**：变量文件（`main.yml`），定义了Logstash的版本、日志和数据目录路径等。



## 三、Go安装

安装Go环境，兼容 **RedHat** 和 **Debian(Ubuntu)** 系统

------

### 1. **角色目录结构**

```plaintext
roles/
  go/
    tasks/
      main.yml          # 主任务文件
      variables.yml     # 根据系统设置变量
      setup-RedHat.yml  # RedHat系统安装任务
      setup-Debian.yml  # Debian系统安装任务
    vars/
      main.yml          # 公共变量
    handlers/
      main.yml          # 处理器（若需要）
    templates/
      golang.sh.j2      # 环境变量脚本模板
    meta/
      main.yml          # 元信息
```







以下是您提供的 Ansible Playbook 各个文件的调用顺序、执行逻辑以及各自的用途详细解释：

------

### **1. `install_go.yml`**

**调用方式：**
 这是入口文件，通过 `ansible-playbook` 执行，定义了目标主机和角色：

```yaml
- name: Install Go language environment
  hosts: centos7
  become: true
  roles:
    - go
```

- 功能：
  - 指定目标主机组（`centos7`）；
  - 确保任务以 `root` 权限运行（通过 `become: true`）；
  - 调用角色 `go`，实际任务逻辑由该角色实现。

------

### **2. `main.yml`**

**调用方式：**
 `install_go.yml` 文件中调用的角色 `go` 会在内部加载 `tasks/main.yml`，作为角色的默认入口文件。

**内容：**

```yaml
- ansible.builtin.include_vars: variables.yml

- ansible.builtin.include_tasks: setup-RedHat.yml
  when: ansible_os_family == 'RedHat'

- ansible.builtin.include_tasks: setup-Debian.yml
  when: ansible_os_family == 'Debian'

- name: Unsupported OS Family
  fail:
    msg: "This role only supports RedHat and Debian families. Detected: {{ ansible_os_family }}"
  when: ansible_os_family not in ['RedHat', 'Debian']

- name: Verify Go installation
  ansible.builtin.shell: go version
  register: go_version_check
  ignore_errors: yes

- name: Fail if Go installation failed
  fail:
    msg: "Go installation failed. Please check logs for more details."
  when: go_version_check.rc != 0
```

- 功能：

  - **加载变量文件**：通过 `include_vars` 加载 `variables.yml` 中的变量；

  - 根据操作系统类型调用子任务

    ：

    - 如果是 RedHat 系列（如 CentOS），调用 `setup-RedHat.yml`；
    - 如果是 Debian 系列，调用 `setup-Debian.yml`；
    - 如果是其他系统类型，直接报错并退出；

  - 验证安装结果

    ：

    - 执行 `go version` 检查安装是否成功；
    - 如果安装失败，触发失败任务并提示错误信息。

------

### **3. `variables.yml`**

**调用方式：**
 `main.yml` 使用 `ansible.builtin.include_vars` 引入。

**内容：**

```yaml
go_version: "1.22.5"
go_install_path: /usr/local/go
go_download_path: /usr/local/src
go_download_url: http://mirrors.sunline.cn/source/go/x86_64/go{{ go_version }}.linux-amd64.tar.gz
```

- 功能：
  - 定义通用变量，例如 Go 的版本号、安装路径、下载路径及下载地址；
  - 这些变量在其他任务文件（如 `setup-RedHat.yml` 和 `setup-Debian.yml`）中被引用，简化了重复配置。

------

### **4. `setup-RedHat.yml`**

**调用方式：**
 `main.yml` 中通过 `ansible.builtin.include_tasks` 调用，条件为 `ansible_os_family == 'RedHat'`。

**内容：**

```yaml
- name: Install dependencies for RedHat
  yum:
    name: "{{ item }}"
    state: present
  loop:
    - gcc
    - sed
    - git
    - easy-rsa
    - curl
    - jq
    - oathtool
    - wget

- name: Download Go Source Package
  get_url:
    url: "{{ go_download_url }}"
    dest: "{{ go_download_path }}/go{{ go_version }}.linux-amd64.tar.gz"
    mode: '0644'

- name: Unarchive Go Source Package
  unarchive:
    src: "{{ go_download_path }}/go{{ go_version }}.linux-amd64.tar.gz"
    dest: /usr/local
    remote_src: yes
    mode: '0755'

- name: Configure Go environment variables
  template:
    src: golang.sh.j2
    dest: /etc/profile.d/golang.sh
    mode: '0644'

- name: Reload environment variables
  shell: source /etc/profile
```

- 功能：
  - 安装 RedHat 系统所需的依赖包（如 `gcc`, `wget`, `curl` 等）；
  - 下载 Go 的源码包到指定目录；
  - 解压并安装 Go 到 `/usr/local`；
  - 配置环境变量，使用模板文件 `golang.sh.j2`；
  - 刷新环境变量，确保立即生效。

------

### **5. `setup-Debian.yml`**

**调用方式：**
 `main.yml` 中通过 `ansible.builtin.include_tasks` 调用，条件为 `ansible_os_family == 'Debian'`。

**内容：**

```yaml
- name: Install dependencies for Debian
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - build-essential
    - wget
    - tar
    - curl

- name: Download Go Source Package
  get_url:
    url: "{{ go_download_url }}"
    dest: "{{ go_download_path }}/go{{ go_version }}.linux-amd64.tar.gz"
    mode: '0644'

- name: Unarchive Go Source Package
  unarchive:
    src: "{{ go_download_path }}/go{{ go_version }}.linux-amd64.tar.gz"
    dest: /usr/local
    remote_src: yes
    mode: '0755'

- name: Configure Go environment variables
  template:
    src: golang.sh.j2
    dest: /etc/profile.d/golang.sh
    mode: '0644'

- name: Reload environment variables
  shell: source /etc/profile
```

- 功能：
  - 安装 Debian 系统所需的依赖包（如 `wget`, `curl` 等）；
  - 下载 Go 的源码包到指定目录；
  - 解压并安装 Go 到 `/usr/local`；
  - 配置环境变量，使用模板文件 `golang.sh.j2`；
  - 刷新环境变量，确保立即生效。

------

### **6. `golang.sh.j2`**

**调用方式：**
 `setup-RedHat.yml` 和 `setup-Debian.yml` 中使用 `template` 模块生成环境变量文件。

**内容：**

```bash
export GOROOT={{ go_install_path }}
export GOPATH=/usr/local/gopath
export GO111MODULE="on"
export GOPROXY=https://goproxy.cn,direct
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

- 功能：
  - 定义 Go 的环境变量，例如 `GOROOT`（Go 的安装路径）、`GOPATH`（工作目录）、`GO111MODULE`（模块支持）等；
  - 配置代理（`GOPROXY`）以加速依赖下载；
  - 将 Go 的二进制文件路径添加到 `PATH`。

------

### **执行顺序总结**

1. **`install_go.yml`**：入口文件，定义目标主机和角色；
2. **`main.yml`**：角色入口，加载变量文件和任务文件；
3. **`variables.yml`**：定义全局变量；
4. 根据操作系统类型：
   - 如果是 RedHat 系列，调用 `setup-RedHat.yml`；
   - 如果是 Debian 系列，调用 `setup-Debian.yml`；
5. 通过 `golang.sh.j2` 配置 Go 的环境变量；
6. 验证 Go 是否成功安装。

------

通过以上流程，Playbook 确保在不同操作系统上都能正确安装和配置 Go。
