# Ansible安装部署使用



## 一、Ansible概念

### 1.参考文档

[ansible入门](https://www.cnblogs.com/arnoLixi/p/10375245.html)

### 2.Ansible简介

Ansible是一个开源的自动化工具，用于配置管理、应用部署、任务自动化和多节点编排。它由Michael DeHaan创建，并于2015年被Red Hat公司收购。Ansible以其简单易用、无代理架构和基于SSH的通信而受到广泛欢迎。

它也是一个配置管理系统（configuration management system）。你只需要可以使用ssh访问你的服务器或设备就可以；它不同于其他工具，因为它使用的是推送的方式，而不像其他工具一样使用拉去安装agent。

Ansible 核心软件是一个命令行工具，它不运行作为后台服务或守护进程，所以它没有“启动”或“重启”服务的概念，Ansible 直接通过命令行执行操作，如运行 playbook、ad-hoc 命令等，要使用 Ansible 执行任务，需要创建 inventory 文件和 playbook。

Ansible 可以帮助我们完成一些批量任务，或者完成一些需要经常重复的工作；例如在多台服务器中同时部署一个服务，并且启动。

### 3.Ansible组件

以下是Ansible的一些关键概念和组件：

- **Playbooks**：Playbooks是Ansible的配置、部署和编排语言。它们可以描述你想在远程机器上执行的策略或环境。Playbooks使用YAML格式编写，易于阅读和编写。
- **Modules**：Ansible执行任务时使用模块。这些模块是独立的代码块，可以执行特定的任务，如安装软件包、复制文件或管理用户账户。
- **Inventory**：Inventory是一个配置文件，定义了Ansible管理的主机列表。它可以是静态的，也可以是动态生成的。
- **Roles**：Roles是一种组织Playbooks、模板、文件和Ansible其他元素的方式，以便于重用和共享。
- **Ad-hoc Commands**：除了Playbooks，Ansible还允许用户通过简单的命令行指令执行任务，这些被称为ad-hoc命令。
- **Facts**：Facts是Ansible从远程主机收集的信息，如操作系统版本、IP地址等。这些信息可以在Playbooks中使用。
- **Handlers**：Handlers是Ansible中的一种特殊任务，它们在发生特定事件（如文件更改）时被触发。
- **Variables**：Ansible允许在Playbooks中定义变量，以便于控制任务的行为。
- **Templating**：Ansible使用Jinja2模板引擎，允许在配置文件中使用变量和条件语句。
- **Galaxy**：Ansible Galaxy是一个社区平台，用户可以在这里分享和下载Ansible roles。

Ansible的设计哲学是“简单、强大、无代理”，这意味着你不需要在远程主机上安装任何额外的软件来使用Ansible。它的主要优势在于其易用性、一致性和可扩展性，使得它成为自动化IT任务的流行选择。

#### 3.1 playbook编写

编写一个`test.yml`的测试文件：

```bash
---
- name: Test SSH Connection
  hosts: all
  become: yes
  tasks: 
    - name: Echo a message
      shell: echo "Hello, this is test."
      register: echo_output

    - name: Print the output of the echo command
      debug:
        var: echo_output.stdout
```

playbook解释：

- `---`：这是YAML文档的开始标记。
- `- name: Test SSH Connection`：这是Play的名称。它是一个描述性的标题，用于标识Play的目的。在这个例子中，Play的目的是测试SSH连接。
- `hosts: all`：这指定了Play将应用于哪些主机。`all`关键字意味着Play将应用于Inventory文件中定义的所有主机。你也可以指定一个主机组或单个主机。
- `become: yes`：这指示Ansible在执行任务时使用`become`（即`sudo`或类似权限提升命令）。`yes`表示对于这个Play中的所有任务，Ansible都将尝试提升权限。如果你不想提升权限，可以将`become`设置为`no`。
- `tasks:`：这标志着任务列表的开始。在Play中，你可以定义一个或多个任务。
- `- name: Echo a message`：这是第一个任务的名称。它描述了任务的目的，即在远程主机上执行`echo`命令。
- `shell: echo "Hello, this is test."`：这是任务的实际内容。`shell`模块用于执行命令，这里执行的是`echo "Hello, this is test."`。`shell`模块会捕获命令的输出，而`command`模块则不会。
- `register: echo_output`：这指示Ansible将`shell`任务的输出存储在名为`echo_output`的变量中。这样，你就可以在后续任务中引用这个变量。
- `- name: Print the output of the echo command`：这是第二个任务的名称。它的目的是打印之前`echo`命令的输出。
- `debug: var: echo_output.stdout`：这是第二个任务的内容。`debug`模块用于输出信息到Ansible控制台。`var: echo_output.stdout`指示`debug`模块输出`echo_output`变量的`stdout`属性，即`echo`命令的输出。

这个Playbook的目的是在所有远程主机上执行一个简单的`echo`命令，并将输出存储在一个变量中，然后打印这个变量的内容。这样，你就可以验证Ansible是否能够成功地与远程主机通信，并且是否能够正确地捕获和处理命令的输出。

#### 3.2 playbook执行

使用`ansible-playbook`命令执行playbook文件，并指定主机`10.22.51.63`：

```bash
ansible-playbook -i 10.22.51.63, /data/ansible/playbook/test.yml
```

执行结果如下：

```bash
TASK [Print the output of the echo command] ********************************************************************************
ok: [10.22.51.63] => {
    "echo_output.stdout": "Hello, this is test."
}
```

#### 3.3 Facts配置

Facts是关于远程主机的信息，如网络接口、操作系统版本、IP地址等。你可以使用`setup`模块来收集这些信息。以下是一个简单的Ansible Playbook示例，它使用`setup`模块来收集Facts并将结果存储在一个变量中：

```bash
---
-  name: Collect facts from remote hosts
   hosts: all
   gather_facts: no


   tasks:
     - name: Gather facts
       setup:
         filter: ansible_hostname
    
     - name: Store facts in a variable
       set_fact:
         gathered_facts: "{{ ansible_facts }}"
    
     - name: Debug the gathered facts
       debug: 
        var: gathered_facts
```

部分解释：

- `filter: ansible_hostname`：代表只收集主机名称。

使用`ansible-playbook`命令执行playbook文件，并指定主机`10.22.51.63`：

```bash
ansible-playbook -i 10.22.51.63, /data/ansible/playbook/collect_facts.yml
```

执行结果如下：

```bash
TASK [Debug the gathered facts] **************************************************************************************************************************************
ok: [10.22.51.63] => {
"gathered_facts": {
   "discovered_interpreter_python": "/usr/libexec/platform-python",
   "hostname": "jerion"
}
}
```



## 二、安装ansible

这里安装用的是`yum安装脚本`。

### 1.手动安装

暂无。

### 2.yum安装脚本

```bash
#!/bin/bash

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "请以 root 用户运行此脚本。"
        exit 1
    fi
}

check_command() {
    if [ $? -ne 0 ]; then
        echo "$1 失败，请检查您的网络连接或软件源配置。"
        exit 1
    fi
}

install_epel() {
    echo "正在安装 EPEL 仓库..."
    yum install -y epel-release
    check_command "安装 EPEL 仓库"
}

install_ansible() {
    echo "正在安装 Ansible..."
    yum install -y ansible
    check_command "安装 Ansible"
}

check_ansible_installed() {
    if command -v ansible > /dev/null; then
        echo "Ansible 已安装，版本信息如下："
        ansible --version
        exit 0
    fi
}

main() {
    check_root
    check_ansible_installed
    install_epel
    install_ansible
    echo "Ansible 安装成功，版本信息如下："
    ansible --version
}

main
```

### 3.源码安装脚本

```bash
#!/bin/bash

PYTHON_VERSION="3.10.0"
VIRTUAL_ENV_NAME="myenv"
ANSIBLE_VERSION="2.9.6"
REQUIRED_MODULES="os sys json"

install_dependencies() {
    echo "正在安装所需依赖..."
    yum update -y
    yum groupinstall -y "Development Tools"
    yum install -y gcc openssl-devel bzip2-devel libffi-devel wget zlib-devel \
                   libbz2-devel readline-devel sqlite-devel curl llvm \
                   ncurses-devel ncurses-libs xz-devel tk-devel liblzma-devel gdbm-devel \
                   db4-devel libpcap-devel expat-devel epel-release git \
                   python3-devel
}

clean_pyenv() {
    echo "清理旧的 pyenv 安装..."
    rm -rf ~/.pyenv
}

install_pyenv() {
    echo "正在安装 pyenv..."
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init --path)"\nfi' >> ~/.bashrc
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    source ~/.bashrc

    if command -v pyenv &> /dev/null; then
        echo "pyenv 安装成功。"
    else
        echo "pyenv 安装失败，正在退出..."
        exit 1
    fi
}

install_python() {
    if command -v pyenv &> /dev/null; then
        echo "正在使用 pyenv 安装 Python $PYTHON_VERSION..."
        pyenv uninstall -f $PYTHON_VERSION
        CFLAGS="-I/usr/include/ffi -I/usr/include/openssl" \
        LDFLAGS="-L/usr/lib64 -L/usr/lib64/openssl" \
        pyenv install $PYTHON_VERSION
        pyenv global $PYTHON_VERSION
    else
        echo "pyenv 未安装，正在退出..."
        exit 1
    fi
}

check_required_modules() {
    local python_path=$(pyenv which python)
    local missing_module_flag=0
    for module in $REQUIRED_MODULES; do
        if ! $python_path -c "import $module" &> /dev/null; then
            echo "缺少必需的 Python 模块: $module"
            missing_module_flag=1
        fi
    done
    return $missing_module_flag
}

create_virtualenv() {
    echo "正在创建虚拟环境..."
    pyenv virtualenv $PYTHON_VERSION $VIRTUAL_ENV_NAME
    pyenv activate $VIRTUAL_ENV_NAME
}

install_ansible() {
    echo "正在安装 Ansible..."
    pip install --upgrade pip setuptools wheel cython
    pip install "ansible==$ANSIBLE_VERSION" --no-binary :all:
    if [ $? -eq 0 ]; then
        echo "Ansible 安装成功。"
    else
        echo "Ansible 安装失败。"
    fi
}

main() {
    install_dependencies
    clean_pyenv
    install_pyenv
    install_python
    if check_required_modules; then
        echo "所有必需的模块已安装。"
    else
        echo "有必需的模块未能安装，正在退出..."
        exit 1
    fi
    create_virtualenv
    install_ansible
}

main

echo "Python 3.10、虚拟环境及 Ansible 设置已完成。"
echo "要激活虚拟环境，请运行：pyenv activate $VIRTUAL_ENV_NAME"
echo "激活虚拟环境后，通过运行 'ansible --version' 来验证 Ansible 是否正确安装。"
```

### 4.查看ansible版本

执行以下命令查看：

```bash
[root@jerion tmp]# ansible --version
ansible [core 2.16.3]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.12/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.1 (main, Feb 21 2024, 14:18:26) [GCC 8.5.0 20210514 (Red Hat 8.5.0-21)] (/usr/bin/python3.12)
  jinja version = 3.1.2
  libyaml = True
```

**解释说明：**

> - `ansible [core 2.16.3]`：这是Ansible的核心版本号，表示当前安装的是2.16.3版本的Ansible。
> - `config file`：配置文件路径。这表示Ansible的主要配置文件位于`/etc/ansible/ansible.cfg`。
> - `configured module search path`：模块搜索路径，指明了 Ansible 查找模块的路径，可以在这些路径下添加自定义模块。Ansible会在这些目录中查找自定义模块。
> - `ansible python module location`：Ansible的Python模块位置，这表示Ansible的Python模块安装在`/usr/lib/python3.12/site-packages/ansible`目录下。
> - `ansible collection location`：集合（Collections）位置，Ansible会在这些路径下查找和使用集合。
> - `executable location`：可执行文件位置，Ansible的可执行文件位于`/usr/bin/ansible`。
> - `python version`：Ansible运行在Python 3.12.1环境中，编译器是GCC 8.5.0，具体编译时间是2024年2月21日，Python可执行文件位于`/usr/bin/python3.12`。
> - `jinja version`：Jinja2模板引擎版本，Ansible使用的Jinja2版本是3.1.2。
> - `libyaml = True`：AML库支持。表示Ansible支持libyaml，这可以提高处理YAML文件的性能。



## 三、Ansible配置文件

Ansible 的常见和默认目录结构，用于组织 Ansible 的配置文件、主机清单（inventory）、以及角色（roles）。以下是对这些目录及其用途的详细说明：

ansible配置文件默认是在`/etc/ansible`目录下。

### 1.主配置文件

`/data/ansible/ansible.cfg ` 是 Ansible 的主配置文件，用于定义全局设置，如何控制一些行为参数比如并发数、远程连接方式、默认的 inventory 文件位置等。

如果配置文件目录**不存在**或想**更改路径**，可按以下操作进行。

#### 1.1 创建配置文件目录

```bash
mkdir -p /data/ansible
```

#### 1.2 配置ansible.cfg文件

创建`vim /data/ansible/ansible.cfg`配置文件：

```bash
vim /data/ansible/ansible.cfg
```

编辑内容：

```bash
[defaults]
inventory = /data/ansible/hosts
remote_user = root
host_key_checking = False
retry_files_enabled = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[inventory]
enable_plugins = host_list, script, yaml, ini
```

> **`[defaults]` 部分：**
>
> - `inventory = /data/ansible/hosts`：指定默认的 inventory 文件路径。Ansible 将使用 `/data/ansible/hosts` 作为主机清单文件，列出所有被管理的主机。
> - `remote_user = root`：设置默认远程用户为 `root`。除非在命令行或任务中另行指定，Ansible 会默认使用 `root` 用户进行连接。
> - `host_key_checking = False`：关闭 SSH 主机密钥检查。这样可以避免在首次连接到新主机时要求确认其 SSH 密钥（但会降低安全性）。
> - `retry_files_enabled = False`：禁用重试文件的创建。Ansible 默认在执行失败时生成重试文件，禁用此功能可以避免创建这些文件。
>
> **`[privilege_escalation]` 部分：**
>
> - `become = True`：启用特权提升（权限提升）。允许在需要时切换到另一个用户（通常是 `root`）。
> - `become_method = sudo`：设置特权提升的方法为 `sudo`。Ansible 将使用 `sudo` 命令来提升权限。
> - `become_user = root`：设置特权提升后的目标用户为 `root`。Ansible 将尝试切换到 `root` 用户执行任务。
> - `become_ask_pass = False`：禁用在使用 `sudo` 提升权限时询问密码。如果 `sudo` 配置为不需要密码，这项设置将很有用。
>
> **`[inventory]` 部分：**
>
> - `enable_plugins`：启用指定的 inventory 插件。这些插件允许 Ansible 使用不同格式的主机清单文件：
>   - `host_list`: 处理由逗号分隔的主机列表。
>   - `script`: 允许使用动态 inventory 脚本。
>   - `yaml`: 处理 YAML 格式的 inventory 文件。
>   - `ini`: 处理 INI 格式的 inventory 文件。

#### 1.3 设置环境变量

```bash
vim ~/.bashrc
export ANSIBLE_CONFIG="/data/ansible/ansible.cfg"
```

#### 1.4 重新加载 Shell 环境

```bash
source ~/.bashrc
```

执行` ansible --version`验证ansible变更，查看config file 是否变更：

```bash
[root@jerion ansible]# ansible --version
ansible [core 2.16.3]
  config file = /data/ansible/ansible.cfg
```

### 2.主机清单

`/data/ansible/hosts` 是 Ansible 的主机清单，即[Inventory文件](https://ansible-tran.readthedocs.io/en/latest/docs/intro_inventory.html#id7)。Ansible必须通过Inventory 来管理主机。Ansible 可同时操作属于一个组的多台主机，组和主机之间的关系通过 inventory 文件配置， 默认的文件路径为`/etc/ansible/hosts`，也可自定义。

**语法格式：**

```bash
# 单台主机
    www.test.com     # FQDN方式
    172.16.1.100      # IP地址
    172.16.1.100:12222  # SSH服务端口不是22时使用

# 多台主机
    [mysqlServer]       # 定义一个组名
    mysql.test.com     # FQDN方式 【定义组内单台主机的地址】
    172.16.1.101        # IP地址
    
    [webServer]
    172.16.1.100        # 一台主机可以在不同的组内，它同时属于[mysqlServer]组

# 组嵌套组
    [group01:Server]   # group01为自定义的组名，Server是关键字，固定语法必须填写；
    mysqlServer          # group01 组内包含的其他组名
    webServer             # group01 组内包含的其他组名

# 有规律的主机地址
    www.wj[01:06].test.com
    //相当于：
    www.wj01.test.com
    www.wj02.test.com
    ........
    www.wj06.test.com
# 可以定义有规律的ip地址，也可以定义 有规律的字母地址，例如 [a:f]

# 还有一个隐藏的组是 [all] 组，不指定机器或组，就默认主机列表中所有机器
```

默认的主机清单文件，也称为 inventory 文件。它定义了 Ansible 可以管理的所有主机，并且可以将它们组织成不同的组，以便可以针对特定组执行任务。Inventory 文件支持 INI 和 YAML 两种格式，可以根据个人喜好选择编写方式。

- 方括号[]中是组名,用于对系统进行分类,便于对不同系统进行个别的管理；
- 一个系统可以属于不同的组,比如一台服务器可以同时属于 webserver组 和 dbserver组.这时属于两个组的变量都可以为这台主机所用；
- 如果有主机的SSH端口不是标准的22端口,可在主机名之后加上端口号,用冒号分隔.SSH 配置文件中列出的端口号不会在 paramiko 连接中使用,会在 openssh 连接中使用；

端口号不是默认时，可明确的表示：

```bash
badwolf.example.com:5309
```

**主机列表中的参数说明：**

```bash
    ansible_ssh_host
    //将要连接的远程主机名.与你想要设定的主机的别名不同的话,可通过此变量设置.

    ansible_ssh_port
    //ssh端口号.如果不是默认的端口号,通过此变量设置.这种可以使用 ip:端口 192.168.1.100:2222

    ansible_ssh_user
    //默认的 ssh 用户名

    ansible_ssh_pass
    //ssh 密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥)

    ansible_sudo_pass
    //sudo 密码(这种方式并不安全,我们强烈建议使用 --ask-sudo-pass)

    ansible_sudo_exe (new in version 1.8)
    //sudo 命令路径(适用于1.8及以上版本)

    ansible_connection
    //与主机的连接类型.比如:local, ssh 或者 paramiko. Ansible 1.2 以前默认使用 paramiko.1.2 以后默认使用 'smart','smart' 方式会根据是否支持 ControlPersist, 来判断'ssh' 方式是否可行.

    ansible_ssh_private_key_file
    //ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况.

    ansible_shell_type
    //目标系统的shell类型.默认情况下,命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'.

    ansible_python_interpreter
    //目标主机的 python 路径.适用于的情况: 系统中有多个 Python, 或者命令路径不是"/usr/bin/python",比如  \*BSD, 或者 /usr/bin/python 不是 2.X 版本的 Python.
    //我们不使用 "/usr/bin/env" 机制,因为这要求远程用户的路径设置正确,且要求 "python" 可执行程序名不可为 python以外的名字(实际有可能名为python26).

    //与 ansible_python_interpreter 的工作方式相同,可设定如 ruby 或 perl 的路径....
```

### 3.存放角色的目录

`/data/ansible/roles/` 是Ansible用来存放角色的目录，角色是一种特殊类型的 Ansible 结构，允许您把复杂的任务分解成更小、更可重用的部分。每个角色通常包含其自己的任务、变量、文件、模板和模块等，这样可以在多个 playbook 中重用。

这些文件目录非必须的，特别是在有特定的文件结构或当 Ansible 安装非全局（例如，在用户级别或使用虚拟环境时）的情况下。但是，使用这些标准目录有助于保持项目的组织性和一致性，尤其是在协作环境中。

如果 Ansible 是通过系统包管理器安装的，通常这些目录会自动创建。如果没有，或者您需要自定义路径，可以手动创建这些目录，并在 `ansible.cfg` 配置文件中指定这些路径。



## 四、生成ssh密钥

### 1.内网服务器

#### 1.1 生成 SSH 密钥对

使用 `ssh-keygen` 工具生成一个新的 SSH 密钥对：

```bash
ssh-keygen -t rsa -b 4096
```

> - `ssh-keygen`: 用于生成、管理和转换认证密钥的工具。
> - `-t rsa`: 指定密钥类型为 RSA（Rivest-Shamir-Adleman），这是一种广泛使用的公钥加密算法。
> - `-b 4096`: 指定密钥长度为 4096 比特，比默认的 2048 比特更安全。

#### 1.2 查看生成的密钥

生成后，有两个文件：一个私钥（默认为 `~/.ssh/id_rsa`）和一个公钥（默认为 `~/.ssh/id_rsa.pub`），路径为`/root/.ssh/`：

```bash
[root@jerion .ssh]# ll /root/.ssh/
总用量 16
-rw-------. 1 root root  746 6月   5 11:45 authorized_keys
-rw-------. 1 root root 3381 6月  14 14:01 id_rsa
-rw-r--r--. 1 root root  737 6月  14 14:01 id_rsa.pub
-rw-r--r--. 1 root root  173 6月  13 23:04 known_hosts
```

#### 1.3 复制公钥到远程主机

使用`ssh-copy-id`工具将本地生成的 SSH 公钥复制到远程服务器：

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.22.51.65
```

> - `ssh-copy-id`: 一个用于将本地 SSH 公钥复制到远程主机的工具。
> - `-i ~/.ssh/id_rsa.pub`: 指定要复制的公钥文件。默认情况下，SSH 公钥文件存储在 `~/.ssh/id_rsa.pub`。

执行上述命令后，会有一些信息输出如下：

- **验证远程主机的真实性：**

```bash
The authenticity of host '10.22.51.65 (10.22.51.65)' can't be established.
ECDSA key fingerprint is SHA256:ToyzHGYadimKzbP/giKpcaVr/U4F84WYc7e8y+yM6yw.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

系统提示你确认远程主机的真实性。这是因为这是你第一次连接到该主机，SSH 客户端无法验证其身份。输入 `yes` 继续连接。

- **安装公钥：**

```bash
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
Password:
```

系统尝试使用新密钥登录，并提示你输入远程服务器 `root` 用户的密码，以便将公钥安装到远程服务器。

- **成功添加公钥：**

```bash
Number of key(s) added: 1
```

这表示公钥已成功添加到远程服务器的 `~/.ssh/authorized_keys` 文件中。

- **验证无密码登录：**

```bash
Now try logging into the machine, with:   "ssh 'root@10.22.51.65'"
```

现在可以尝试无密码登录远程服务器，以确保公钥认证配置正确。

#### 1.4 无密钥登录测试

使用`ssh`命令登录远程服务器：

```bash
[root@jerion .ssh]# ssh root@10.22.51.65
Last login: Fri Jun 14 14:07:35 2024 from 10.18.88.135
[root@zhongjl-test-02 /root]# 
```

### 2.云服务器

云服务器除了要复制公钥过来，还要配置一些权限。

> 内网端：10.22.51.63
>
> 远端配置：120.78.156.217 && 47.113.113.48

#### 2.1 复制公钥到远程主机

使用`ssh-copy-id`工具将本地生成的 SSH 公钥复制到远程服务器：

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub root@120.78.156.217
ssh-copy-id -i ~/.ssh/id_rsa.pub root@47.113.113.48
```

#### 2.2 修改 sshd_config 配置文件

远程服务器的 SSH 配置允许使用密钥登录。查看 `/etc/ssh/sshd_config` 文件，确认以下设置：

```bash
PubkeyAuthentication yes		#权限给够，有些可以不用开启
AuthorizedKeysFile .ssh/authorized_keys
```

> - **启用公钥认证**：这行配置确保 SSH 服务启用了公钥认证。
> - **指定授权密钥文件**：这行配置指定了存放公钥的文件路径，相对于用户的主目录。

#### 2.3 重启 SSH 服务

进行了更改，需要重启 SSH 服务：

```bash
systemctl restart sshd
```

#### 2.4 修改 root 目录及文件的权限

远程的服务器权限配置：

```bash
chmod 700 /root
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

> - `/root` 目录的权限应该足够严格。通常建议的权限是 `750` 或 `700`。
> - `/root/.ssh` 目录应该有 `700` 的权限。
> - `/root/.ssh/authorized_keys` 文件应该有 `600` 的权限。

如果仍然报错，监听ssh日志分析问题：

```bash
tail -f /var/log/secure
```

#### 2.5 无密钥登录测试

```bash
ssh root@120.78.156.217
ssh root@47.113.113.48
```



## 五、ansible使用

###  1.创建ansible项目目录

```bash
mkdir -p /data/ansible/inventories
mkdir -p /data/ansible/playbooks
mkdir -p /data/ansible/roles
```

查看目录结构：

```bash
[root@jerion ~]# tree /data/ansible
/data/ansible
├── ansible.cfg
├── inventories
├── playbooks
└── roles
```

> - `inventories/`：目录存放不同环境（如生产、预生产、开发）的 Inventory 文件。
> - `playbooks/`：目录存放所有 Playbook 文件。

### 2.主机清单inventory

#### 2.1 修改 hosts 文件

修改Ansible 的主机清单（inventory）文件的内容，编辑 `vim /data/ansible/hosts`文件：

```bash
[web_servers]
10.22.51.65

[database_servers]
db1.example.com

[all:vars]
ansible_user=root
ansible_ssh_private_key_file=/root/.ssh/id_rsa
```

**解释说明：**

- `[web_servers]`：这一行定义了一个名为 `web_servers` 的组，该组用于存放所有的 Web 服务器。在这个例子中，`10.22.51.65` 是该组下唯一的成员。这意味着任何针对 `web_servers` 组的 Ansible 任务都将只对这个 IP 地址为 `10.22.51.65` 的服务器执行。
- `[database_servers]`：同样地，这一行定义了一个名为 `database_servers` 的组，用于分类所有数据库服务器。`db1.example.com` 是这个组的成员，表示任何针对 `database_servers` 组的任务将只对这个主机名为 `db1.example.com` 的服务器执行。
- `[all:vars]`：这部分定义了适用于所有主机的组变量。
  - `ansible_user=root`：定义了连接到所有主机时使用的默认用户名为 `root`。
  - `ansible_ssh_private_key_file=/root/.ssh/id_rsa`：指定了用于 SSH 连接的私钥文件路径。

**使用场景：**

通过这样的组织方式，您可以针对不同类型的服务器执行特定的配置和管理任务。例如，您可能希望对所有 Web 服务器执行一些安全更新，而对数据库服务器执行不同的备份操作。这可以通过 Ansible playbooks 实现，其中您可以指定对哪个组执行哪些任务。

**组变量设置含义：**

- 所有主机（无论是 `web_servers` 还是 `database_servers`）都将使用 `root` 用户和 `/root/.ssh/id_rsa` 作为 SSH 密钥文件。

- 不需要在每个主机项下重复这些 SSH 相关的设置。

去除掉`[all:vars]`的另一种写法，编辑`vim /data/ansible/hosts`文件：

```bash
[web_servers]
10.22.51.65 ansible_ssh_user=root ansible_ssh_private_key_file=/root/.ssh/id_rsa

[database_servers]
db1.example.com ansible_ssh_user=root ansible_ssh_private_key_file=/root/.ssh/id_rsa
```

#### 2.2 测试 Inventory 文件

执行以下命令：

```bash
ansible-inventory --list
```

如果 inventory 正确无误，输出将类似于：

```bash
{
    "_meta": {
        "hostvars": {
            "10.22.51.65": {
                "ansible_ssh_private_key_file": "/root/.ssh/id_rsa",
                "ansible_user": "root"
            },
            "db1.example.com": {
                "ansible_ssh_private_key_file": "/root/.ssh/id_rsa",
                "ansible_user": "root"
            }
        }
    },
    "all": {
        "children": [
            "database_servers",
            "ungrouped",
            "web_servers"
        ]
    },
    "database_servers": {
        "hosts": [
            "db1.example.com"
        ]
    },
    "web_servers": {
        "hosts": [
            "10.22.51.65"
        ]
    }
}
```

### 3.ansible测试ping

```bash
ansible 10.22.51.65 -m ping			# 单台执行
ansible web_servers -m ping     	# ping web_servers组
ansible all -m ping					# ping全部
```

执行后输出信息如下：

```bash
10.22.51.65 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

**解释输出：**

Ansible 成功通过 SSH 连接到了位于 `10.22.51.65` 的服务器，并且执行了 `ping` 模块。这表示您的配置正确，Ansible 能够利用指定的 SSH 私钥和用户身份（在这里是 root 用户）顺利连接到远程主机。

>- `"ansible_facts"`：包含 Ansible 自动发现的有关目标主机的各种信息。
>  - `"discovered_interpreter_python": "/usr/bin/python"`：这表示 Ansible 在远程主机上自动发现了 Python 解释器的路径。Ansible 使用 Python 来执行其模块，因此需要在目标机器上找到 Python 解释器。
>- `"changed": false`：表示此次操作没有对目标主机做任何更改。`ping` 模块只是用于测试连接性，所以不会对主机进行更改。
>- `"ping": "pong"`：表示 `ping` 模块的返回结果是 `pong`，这是 `ping` 模块的标准响应，表示远程主机可达并响应 Ansible 的请求。

### 4.编写Playbook测试

#### 4.1 创建 Playbook 文件

创建一个`Playbook`文件，来检查远程服务器的磁盘空间：

```bash
vim /data/ansible/playbooks/check_disk_space.yml
```

添加以下内容：

```bash
- name: Check disk space
  #hosts: web_servers
  hosts: all
  tasks:
    - name: Disk free space
      command: df -Th
      register: disk_space

    - name: Show disk space
      debug:
        msg: "{{ disk_space.stdout }}"
```

**解释说明：**

> 这个 Ansible Playbook 文件定义了一个名为“Check disk space”的任务，它执行两个具体的任务来检查并显示所有主机的磁盘空间。以下是每个部分的详细描述：
>
> - **顶层定义：**
>
>   - `- name: Check disk space`：这是 Playbook 的名称，用于描述该 Playbook 的总体目的，即检查磁盘空间。
>   - `hosts: all`：指定此 Playbook 将应用到所有主机（`all`）。如果只需要应用于 `web_servers` 组，可以将这行改为 `hosts: web_servers`。
>
> - **任务列表（tasks）：**
>
>   Playbook 包含两个任务：
>
>   - **检查磁盘空间：**
>     - `name: Disk free space`：任务的名称，用于描述该任务的目的，即检查磁盘剩余空间。
>     - `command: df -Th`：使用 `command` 模块执行 `df -Th` 命令。`df -Th` 命令会以人类可读的格式显示文件系统的磁盘使用情况。
>     - `register: disk_space`：将命令的输出结果注册到变量 `disk_space` 中，以便在后续任务中使用。
>   - **显示磁盘空间：**
>     - `name: Show disk space`：任务的名称，用于描述该任务的目的，即显示磁盘剩余空间。
>     - `debug`：使用 `debug` 模块显示信息。
>       - `msg: "{{ disk_space.stdout }}"`：显示 `disk_space` 变量的 `stdout` 属性，即 `df -Th` 命令的标准输出内容。

#### 4.2 执行 Playbook 文件

- **对所有服务器执行playbook：**

使用`ansible-playbook`命令执行playbook文件，并指定主机清单文件的路径`/data/ansible/hosts`：

```bash
ansible-playbook -i /data/ansible/hosts /data/ansible/playbooks/check_disk_space.yml
```

输出内容如下：

```bash
PLAY [Check disk space] *********************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [10.22.51.65]
ok: [db1.example.com]

TASK [Disk free space] **********************************************************************************************
changed: [10.22.51.65]
changed: [db1.example.com]

TASK [Show disk space] **********************************************************************************************
ok: [10.22.51.65] => {
    "msg": "文件系统                 类型      容量  已用  可用 已用% 挂载点\ndevtmpfs                 devtmpfs  3.9G     0  3.9G    0% /dev\ntmpfs                    tmpfs     3.9G   12K  3.9G    1% /dev/shm\ntmpfs                    tmpfs     3.9G   42M  3.8G    2% /run\ntmpfs                    tmpfs     3.9G     0  3.9G    0% /sys/fs/cgroup\n/dev/mapper/sys-root     xfs        39G   29G   11G   73% /\n/dev/sda2                xfs      1014M  150M  865M   15% /boot\ntmpfs                    tmpfs     783M     0  783M    0% /run/user/0\n10.22.51.63:/data/public nfs4       35G  7.7G   27G   23% /mnt/nsd\noverlay                  overlay    39G   29G   11G   73% /var/lib/docker/overlay2/5ac739315d94fc3a467fbb4d2653911baf7044b73de383aca2d524207222a763/merged\noverlay                  overlay    39G   29G   11G   73% /var/lib/docker/overlay2/87ac405f7fe63b7ea890519121dc58a0435cad4559ddc826e2c84794112bfa74/merged\noverlay                  overlay    39G   29G   11G   73% /var/lib/docker/overlay2/8c5e044076ac652e5ba953a7b81d6b170a0c6cafb2fc35e7f4ba9f1d24cf53a1/merged"
}
ok: [db1.example.com] => {
    "msg": "文件系统                 类型      容量  已用  可用 已用% 挂载点\ndevtmpfs                 devtmpfs  3.9G     0  3.9G    0% /dev\ntmpfs                    tmpfs     3.9G   12K  3.9G    1% /dev/shm\ntmpfs                    tmpfs     3.9G   42M  3.8G    2% /run\ntmpfs                    tmpfs     3.9G     0  3.9G    0% /sys/fs/cgroup\n/dev/mapper/sys-root     xfs        39G   29G   11G   73% /\n/dev/sda2                xfs      1014M  150M  865M   15% /boot\ntmpfs                    tmpfs     783M     0  783M    0% /run/user/0\n10.22.51.63:/data/public nfs4       35G  7.7G   27G   23% /mnt/nsd\noverlay                  overlay    39G   29G   11G   73% /var/lib/docker/overlay2/5ac739315d94fc3a467fbb4d2653911baf7044b73de383aca2d524207222a763/merged\noverlay                  overlay    39G   29G   11G   73% /var/lib/docker/overlay2/87ac405f7fe63b7ea890519121dc58a0435cad4559ddc826e2c84794112bfa74/merged\noverlay                  overlay    39G   29G   11G   73% /var/lib/docker/overlay2/8c5e044076ac652e5ba953a7b81d6b170a0c6cafb2fc35e7f4ba9f1d24cf53a1/merged"
}

PLAY RECAP **********************************************************************************************************
10.22.51.65                : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
db1.example.com            : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

**解释输出：**

> - `PLAY [Check disk space]`：Playbook 名称。
> - `TASK [Gathering Facts]`：Ansible 收集目标主机的基本信息（facts）。
> - `TASK [Disk free space]`：执行 `df -Th` 命令并注册输出到变量 `disk_space`。
> - `TASK [Show disk space]`：使用 `debug` 模块显示 `df -Th` 命令的输出。
> - `PLAY RECAP`：Playbook 执行摘要，包括各主机的执行状态。

- **对单台服务器执行playbook：**

>当在命令行中直接指定单个主机时，`hosts`属性必须存在，且`hosts` 属性应该设置为 `all` 或者主机的具体IP，以确保它能匹配任何传入的主机，即使 `hosts` 设置为 `all`，Ansible 只会对指定的主机执行操作。

```bash
ansible-playbook -i 10.22.51.65, -e "ansible_user=root ansible_ssh_private_key_file=/root/.ssh/id_rsa" /data/ansible/playbooks/check_disk_space.yml
```

> - `-i 10.22.51.65,` ：指定目标主机为 `10.22.51.65`。逗号（`,`）确保 Ansible 将其识别为主机列表，即使只有一台主机。
> - `-e` ：通过命令行传递额外的变量，指定使用 `root` 用户和 `/root/.ssh/id_rsa` 私钥文件进行连接。

- **发现问题：**指定目标主机时，无论hosts文件内是否有配置该主机，也能成功。

  **原因：**使用命令行参数指定目标主机时，Ansible 会优先使用命令行中指定的主机信息，而不是 Playbook 文件中 `hosts` 属性或清单文件中的定义。

- **清单文件的作用：**在这种情况下，清单文件 `/data/ansible/hosts` 不会被使用，因为已经在命令行中指定了要连接的单个主机 IP 地址。

- **`hosts` 属性在 Playbook 中的作用：**在 Playbook 中定义的 `hosts` 属性主要用于指定 Playbook 应该在哪些主机上运行任务。当你在命令行中指定主机时，Playbook 中的 `hosts` 属性不再被使用。

#### 4.3 注意事项

在 Ansible 的工作流程中，`hosts` 属性在 Playbook 中设置的主要目的是为了定义任务的目标主机集。尽管在命令行中指定了主机，Playbook 文件中的 `hosts` 属性仍然需要存在，具体原因如下：

- **定义任务目标**：`hosts` 属性告诉 Ansible 哪些主机应该执行该 Playbook 的任务。即使在命令行中指定了主机，Playbook 中的 `hosts` 属性仍然是任务选择的基础。
- **清单文件的接口**：当你不在命令行中指定主机时，Ansible 会从清单文件中读取目标主机。`hosts` 属性提供了一个接口，允许你在 Playbook 内部指定任务应该在哪些主机上执行。

**命令行与 Playbook 的关系：**

- **命令行优先**：当你在命令行中指定主机时，这些指定会覆盖 Playbook 中的 `hosts` 设置。这是因为命令行参数通常具有更高的优先级。
- **Playbook 中的配置**：即使你在命令行中指定了主机，Playbook 中的 `hosts` 属性依然存在，主要是为了在没有命令行指定主机时使用，以及为清单文件提供接口。



## 六、ansible获取nginx信息

> 在对单个服务器执行`ansible`命令前，需要确保该服务器IP地址存在于`inventory`文件中，即`/data/ansible/hosts`文件，无论在哪个组里都行。
>
> 这里假设添加了如下IP地址到组里：
>
> ```bash
> [servers]
> 172.18.0.161
> 172.18.0.78
> ```

### 1.检查nginx路径

使用`ansible`命令来在远程`172.18.0.161`主机上运行 `which nginx` 命令：

```bash
ansible 172.18.0.161 -m shell -a 'which nginx'
```

>  `which nginx` 命令可以查看 Nginx 的可执行文件的安装路径。

执行结果如下：

```bash
172.18.0.161 | CHANGED | rc=0 >>
/bin/nginx
```

### 2.查看nginx配置文件所在

使用`ansible`命令来在远程`172.18.0.161`主机上运行 `nginx -V` 命令：

```
ansible 172.18.0.78 -m shell -a 'nginx -V'
```

> `nginx -V` 命令可以显示 Nginx 的编译器版本和编译时配置选项等详细信息。

执行结果如下：

```bash
172.18.0.78 | CHANGED | rc=0 >>
nginx version: nginx/1.18.0
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_v2_module
```

### 3.查看nginx配置文件内容

```bash
ansible 172.18.0.78 -m shell -a 'cat /usr/local/nginx/conf/nginx.conf'
```

如确定了nginx配置目录，可以查看conf目录下`ssl_certificate`。

### 4.查找服务器上所有的ssl证书

```bash
ansible 172.18.0.161 -m shell -a 'grep -r "ssl_certificate" /data/nginx/conf/conf.d/'
```

> `grep -r`命令可以递归搜索目录`/data/nginx/conf/conf.d/`中是否有文件包含其内容`ssl_certificate`。

执行结果如下：

```bash
172.18.0.161 | CHANGED | rc=0 >>
/data/nginx/conf/conf.d/wecom.iboss.sunline.cn.conf:  ssl_certificate cert/wecom.iboss.sunline.cn.pem;
/data/nginx/conf/conf.d/wecom.iboss.sunline.cn.conf:  ssl_certificate_key cert/wecom.iboss.sunline.cn.key;
/data/nginx/conf/conf.d/iboss.sunline.cn-8443.conf:  ssl_certificate cert/iboss.sunline.cn.pem;
/data/nginx/conf/conf.d/iboss.sunline.cn-8443.conf:  ssl_certificate_key cert/iboss.sunline.cn.key;
/data/nginx/conf/conf.d/hr.iboss.sunline.cn-9443.conf:  ssl_certificate cert/hr.iboss.sunline.cn_bundle.pem;
/data/nginx/conf/conf.d/hr.iboss.sunline.cn-9443.conf:  ssl_certificate_key cert/hr.iboss.sunline.cn.key;
/data/nginx/conf/conf.d/iboss.sunline.cn.conf:  ssl_certificate cert/iboss.sunline.cn.pem;
/data/nginx/conf/conf.d/iboss.sunline.cn.conf:  ssl_certificate_key cert/iboss.sunline.cn.key;
/data/nginx/conf/conf.d/none.conf:  ssl_certificate cert/none-ca.crt;
/data/nginx/conf/conf.d/none.conf:  ssl_certificate_key cert/none-ca.key;
```

### 5.搜索证书的确切路径

```bash
ansible 172.18.0.161 -m shell -a 'find / -name "wecom.iboss.sunline.cn.pem"'
```

执行结果如下：

```bash
172.18.0.161 | CHANGED | rc=0 >>
/data/nginx/conf/cert/wecom.iboss.sunline.cn.pem
```

### 6.查看证书所在目录

```bash
ansible 172.18.0.161 -m shell -a 'ls -l /data/nginx/conf/cert'
```



## 七、获取证书列表信息

缺陷：API调用可能存在限制，非443端口的域名无法获取。

>例如：
>
>wecom.iboss.sunline.cn:6443
>
>```bash
># 暂时不使用api查询
>```
>

### 1.配置python脚本（云服务器）

这里以自己的云服务器上的证书为例，配置的脚本文件存放在`/usr/local/scripts`目录下，脚本内容如下：

```python
#!/usr/bin/python3

# 导入必要的库
import time
import requests
from requests.auth import HTTPBasicAuth

# 登录时先进行身份认证的账号密码
auth_username = "sunline"
auth_password = "sunline"

# 登录域名和SSL证书监控系统的账号密码
admin_username = "admin"
admin_password = "dream13889"

# 系统的登录URL和域名列表URL
login_url = 'https://domain.jerion.cn/api/login'
domain_list_url = 'https://domain.jerion.cn/api/getDomainList'
cert_info_url = 'https://domain.jerion.cn/api/getCertInformation'

# 创建认证对象
auth = HTTPBasicAuth(auth_username, auth_password)

# 准备登录请求的负载
login_payload = {
    "username": admin_username,
    "password": admin_password
}

# 发送登录请求并处理响应
login_response = requests.post(login_url, json=login_payload, auth=auth)
if login_response.status_code == 200:
    login_data = login_response.json()
    token = login_data.get('data', {}).get('token')
    if token:
        print("登录成功，获取到 Token")

		# 设置请求头和准备获取域名列表的请求体
        headers = {
            "Content-Type": "application/json",
            "X-TOKEN": token
        }
        domain_list_payload = {
            "page": 1,
            "size": 10  # 可调整获取更多域名
        }

        # 发送获取域名列表的请求并处理响应
        domain_response = requests.post(domain_list_url, headers=headers, json=domain_list_payload, auth=auth)
        if domain_response.status_code == 200:
            domain_data = domain_response.json()
            domain_list = domain_data.get('data', {}).get('list', [])
            if domain_list:
                file_path = '/tmp/certificates_jerion.txt'
                with open(file_path, 'w') as file:
                    for domain_info in domain_list:
                        domain = domain_info.get('domain')
                        print(f"获取域名: {domain}")
                        time.sleep(1)
                        
                        # 循环处理每个域名，获取其证书信息并写入文件
                        cert_payload = {
                            "domain": domain
                        }
                        cert_response = requests.post(cert_info_url, headers=headers, json=cert_payload, auth=auth)
                        
                        if cert_response.status_code == 200:
                            data = cert_response.json()
                            print(f"证书响应: {data}")
                            time.sleep(1)

                            if data.get('code') == 0:
                                cert_info = data.get('data', {})
                                parsed_cert = cert_info.get('parsed_cert', {})
                                domain_name = cert_info.get('resolve_domain')
                                issuer = parsed_cert.get('issuer', {})
                                start_date = parsed_cert.get('notBefore')
                                expire_date = parsed_cert.get('notAfter')
                                subject = parsed_cert.get('subject', {})

                                try:
                                    file.write(f"Domain: {domain_name}\n")
                                    file.write(f"Issuer: {issuer}\n")
                                    file.write(f"Start Date: {start_date}\n")
                                    file.write(f"Expire Date: {expire_date}\n")
                                    file.write(f"Subject: {subject}\n")
                                    file.write("\n")
                                    print(f"写入文件: Domain: {domain_name}, Issuer: {issuer}, Start Date: {start_date}, Expire Date: {expire_date}, Subject: {subject}")
                                except Exception as e:
                                    print(f"写入文件失败: {e}")
                            else:
                                print(f"获取 {domain} 的证书信息失败。返回消息: {data.get('msg')}")
                        else:
                            print(f"获取 {domain} 的证书信息失败。状态码: {cert_response.status_code}, 响应: {cert_response.text}")
            			print()
                        time.sleep(2)
            else:
                print("未找到任何域名。")
        else:
            print(f"获取域名列表失败。状态码: {domain_response.status_code}, 响应: {domain_response.text}")
    else:
        print("登录失败，未能获取到 Token")
else:
    print(f"登录失败。状态码: {login_response.status_code}, 响应: {login_response.text}")

print("获取证书信息执行结束！")
```

#### 1.1 脚本功能说明

这个脚本的功能是登录一个域名和SSL证书监控系统，获取域名列表，并且获取每个域名的证书信息，最后将这些信息写入到一个文件中。

##### 1.1.1 导入必要及可选的库

- `requests` ：该库用于发送HTTP请求。
- `from requests.auth import HTTPBasicAuth`：使用 `requests` 库中的 `HTTPBasicAuth` 类来提供认证信息。

##### 1.1.2 定义登录信息和URL

- `auth_username`：登录系统前进行身份认证的账号。
- `auth_password`：登录系统前进行身份认证的密码。
- `admin_username` ：存储登录所需的账号。
-  `admin_password`：存储登录所需的密码。
- `login_url`：登录API的URL。
- `domain_list_url`：是获取域名列表的API的URL。
- `cert_info_url`：是获取证书信息的API的URL。

##### 1.1.3 准备自动进行身份认证的信息（可选）

- `HTTPBasicAuth(admin_username, admin_password)`：创建一个认证对象，用于在HTTP请求中实现基本认证，基本认证是一种通过在HTTP请求头中添加用户名和密码进行身份验证的方式，这里是因为在`NginxwebUI`中配置了`htpasswd`身份认证，将用户名和密码传递给`auth`。

##### 1.1.4 准备登录请求的负载

- `login_payload` ：发送到登录API的请求体，包含用户名和密码。

##### 1.1.5 发送登录请求并处理响应

```python
login_response = requests.post(login_url, json=login_payload, auth=auth)
if login_response.status_code == 200:
    login_data = login_response.json()
    token = login_data.get('data', {}).get('token')
    if token:
        print("登录成功，获取到 Token")
```

- `requests.post()`：是 `requests` 库中的一个方法，用于发送HTTP POST请求。
  - `login_url`: 目标API的URL地址。
  - `json=login_payload`: 请求的JSON数据。`login_payload` 是一个字典，包含了要发送的登录信息（用户名和密码），该参数会将字典 `login_payload` 自动转换为JSON格式并设置合适的 `Content-Type` 头。
  - `auth=auth`: 使用创建的 `HTTPBasicAuth` 对象进行身份认证。
- `login_response.status_code`：检查响应状态码是否为200（表示请求成功）。
- `login_response.json()`：用于将HTTP响应的内容解析为JSON格式的Python对象，通常是一个字典。
- `login_data.get('data', {})`：从 `login_data` 字典中获取键 `'data'` 的值，如果 `'data'` 键存在，则返回其对应的值（这里是一个嵌套的字典），如果 `'data'` 键不存在，则返回一个默认的空字典 `{}`，避免抛出 `KeyError` 异常。
- `.get('token')`：对于外层 `get` 方法返回的字典（可能是嵌套的字典，或者是空字典），获取键 `'token'` 的值。
- 如果获取到`Token`，则打印成功消息。

##### 1.1.6 设置请求头和准备获取域名列表的请求体

```python
headers = {
    "Content-Type": "application/json",
    "X-TOKEN": token
}
domain_list_payload = {
    "page": 1,
    "size": 10  # 可调整获取更多域名
}
```

- `headers` ：包含请求头，其中 `X-TOKEN` 用于认证。
- `domain_list_payload` ：获取域名列表的请求体，指定分页参数。

##### 1.1.7 发送获取域名列表的请求并处理响应

```bash
domain_response = requests.post(domain_list_url, headers=headers, json=domain_list_payload)
if domain_response.status_code == 200:
    domain_data = domain_response.json()
    domain_list = domain_data.get('data', {}).get('list', [])
    if domain_list:
        file_path = '/tmp/certificates_jerion.txt'
        with open(file_path, 'w') as file:
            for domain_info in domain_list:
                domain = domain_info.get('domain')
                print(f"获取域名: {domain}")
```

- `requests.post()`：发送一个HTTP POST请求到 `domain_list_url` 以获取域名列表。
  - `domain_list_url`: 请求的URL（获取域名列表的API端点）；
  - `headers`: 包含HTTP头信息的字典，这里包括认证所需的Token；
  - `json=domain_list_payload`: 请求体，包含分页参数（如第几页，每页多少条记录）；
  - `auth=auth`: 使用创建的 `HTTPBasicAuth` 对象进行身份认证。
- `domain_response.status_code`：检查响应状态码是否为200（表示请求成功）。
- `domain_response.json()`：用于将HTTP响应的内容解析为JSON格式的Python对象，通常是一个字典。
- `domain_data.get('data', {})`：从 `domain_data` 字典中获取键 `'data'` 的值，如果不存在则返回空字典 `{}`。
- `.get('list', [])`：从嵌套的字典中获取键 `'list'` 的值，如果不存在则返回空列表 `[]`，`domain_list` 是一个包含域名信息的列表。
- `file_path`：定义一个文件路径变量 `file_path`，用于存储证书信息。
- `with open(file_path, 'w') as file`：打开（或创建）一个文件，以写模式(`'w'`)打开，并将文件对象赋值给 `file`。
  - `open(file_path, 'w')`：打开 `file_path` 指定的文件，如果文件不存在则创建它，如果存在则清空其内容；
  - `as file`：将文件对象赋值给变量 `file`，以便在 `with` 语句块中使用。
- `for domain_info in domain_list`：对 `domain_list` 列表中的每个元素（域名信息字典）进行迭代。
- `domain_info.get('domain')`：获取 `domain_info` 字典中键 `'domain'` 的值（即域名）。

##### 1.1.8 循环处理每个域名，获取其证书信息并写入文件

```python
cert_payload = {
    "domain": domain
}
cert_response = requests.post(cert_info_url, headers=headers, json=cert_payload)

if cert_response.status_code == 200:
    data = cert_response.json()
    print(f"证书响应: {data}")
    if data.get('code') == 0:
        cert_info = data.get('data', {})
        parsed_cert = cert_info.get('parsed_cert', {})
        domain_name = cert_info.get('resolve_domain')
        issuer = parsed_cert.get('issuer', {})
        start_date = parsed_cert.get('notBefore')
        expire_date = parsed_cert.get('notAfter')
        subject = parsed_cert.get('subject', {})

        try:
            file.write(f"Domain: {domain_name}\n")
            file.write(f"Issuer: {issuer}\n")
            file.write(f"Start Date: {start_date}\n")
            file.write(f"Expire Date: {expire_date}\n")
            file.write(f"Subject: {subject}\n")
            file.write("\n")
            print(f"写入文件: Domain: {domain_name}, Issuer: {issuer}, Start Date: {start_date}, Expire Date: {expire_date}, Subject: {subject}")
```

- `cert_payload`：创建一个字典 `cert_payload`，包含的是获取域名信息的请求体。
- `requests.post()`：发送一个HTTP POST请求到 `cert_info_url`，请求头包含认证信息，请求体包含查询的域名。
  - `cert_info_url`: 证书信息API的URL；
  - `headers`: 请求头，包含认证Token等信息；
  - `json=cert_payload`: 请求体，包含查询的域名；
  - `auth=auth`: 使用创建的 `HTTPBasicAuth` 对象进行身份认证。
- `cert_response.status_code`：检查证书请求的HTTP状态码是否为200，表示请求成功。
- `cert_response.json()`：将响应内容解析为JSON格式的字典。
- `data.get('code')`：检查响应数据中的 `code` 字段是否为0，表示请求成功。
- `data.get('data', {})`：从 `data` 字典中获取 `data` 键的值，即证书信息，如果不存在，则返回空字典 `{}`。
- `cert_info.get('parsed_cert', {})`：从 `cert_info` 字典中获取 `parsed_cert` 键的值，即解析后的证书信息，如果不存在，则返回空字典 `{}`。
- `cert_info.get('resolve_domain')`: 从 `cert_info` 获取 `resolve_domain` 键的值，即域名。
- `parsed_cert.get('issuer', {})`: 从 `parsed_cert` 获取 `issuer` 键的值，即颁发者，如果不存在，则返回空字典 `{}`。
- `parsed_cert.get('notBefore')`: 从 `parsed_cert` 获取证书的开始日期。
- `parsed_cert.get('notAfter')`: 从 `parsed_cert` 获取证书的过期日期。
- `parsed_cert.get('subject', {})`: 从 `parsed_cert` 获取 `subject` 键的值，即主题，如果不存在，则返回空字典 `{}`。
- `file.write()`：向文件中写入证书信息。

##### 1.1.9 处理失败情况

```python
	else:
		print("未找到任何域名。")
......
else:
    print(f"登录失败。状态码: {login_response.status_code}, 响应: {login_response.text}")
```

- 如果未找到任何域名，打印相应消息。
- 如果获取域名列表失败，打印状态码和响应内容。
- 如果登录失败且未获取到Token，打印相应消息。
- 如果登录请求失败，打印状态码和响应内容。

#### 1.2 脚本相关问题

##### 1.2.1 如何查看后端登录的URL

- **打开登录系统：** `https://domain.jerion.cn`；
- **打开浏览器开发者工具：**在浏览器中按 `F12` 或右键点击页面，然后选择“检查”或“检查元素”；
- **切换到“网络”标签：**在网络标签中，可以看到页面加载时发起的所有网络请求；
- **进行登录操作：**
  - 在登录页面输入用户名和密码，然后点击登录按钮；
  - 在网络标签中查找类型为 `POST` 的请求，就可以看到看看后端登录的URL。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/c19b03695cb8491fe9b5de5c2cb821a6-image-20240616194906976-a9b68b.png" alt="image-20240616194906976" style="zoom:50%;" />

##### 1.2.2 如何查看后端登录后的域名列表URL

登录系统后，打开【证书监控】——【域名列表】，在网络标签中找到名称为`getDomainList`的请求，在“标头”栏可以看到请求URL：

![image-20240616200813941](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/a7f94eabdfdc1791a58ddf7ee472e55c-image-20240616200813941-722f1c.png)

##### 1.2.3 如何查看后端登录后的获取证书信息URL

登录系统后，打开【工具箱】——【证书信息查询】，假设这里查询`domain.jerion.cn`域名，点击“查询”后，在网络标签中找到名称为`getCertInformation`的请求，在“标头”栏可以看到请求URL：

![image-20240616224150221](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/35dce0e17305e9679908372cf3fefceb-image-20240616224150221-31e5b1.png)

##### 1.2.4 如何查看抓取到的token值

登录系统后，在网络标签中找到名称为`login`的请求，点击“响应”栏，可以看到`token`值：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/abbc3f20c0b9efbd197a486072ad1d80-image-20240616212749123-5b9afc.png" alt="image-20240616212749123" style="zoom:50%;" />

##### 1.2.5 如何查看登录请求的负载

登录系统后，在网络标签中找到名称为`login`的请求，点击“负载”栏，可以看到json格式信息包含的账号密码：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/c7c61ef4a10eb2777ad66b27d3c44d57-image-20240616213807957-cf080b.png" alt="image-20240616213807957" style="zoom:50%;" />

##### 1.2.6 如何查看请求头和准备获取域名列表的请求体

登录系统后，打开【证书监控】——【证书列表】，在网络标签中找到名称为`getDomainList`的请求，在“标头”栏，往下拉可以看到请求表头中包含的`Content-Type`值和`X-Token`值：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/f7d92943c92d3244a535c6ad64423c63-image-20240616214122424-e0f864.png" alt="image-20240616214122424" style="zoom:50%;" />

点击“负载”栏，查看获取域名列表的请求负载，可以看到包含了`page`和`size`属性值：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/2bebca786410b173e43936b96a38c768-image-20240616214303999-be013c.png" alt="image-20240616214303999" style="zoom:50%;" />

##### 1.2.7 如何查看查询并获取证书信息的请求体

登录系统后，打开【工具箱】——【证书信息查询】，假设这里查询`domain.jerion.cn`域名，点击“查询”后，在网络标签中找到名称为`getCertInformation`的请求，点击“负载”栏，查看获取域名列表的请求负载，可以看到包含了`domain`属性值：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/59fc9e90cf49a614047daabe28ee0fd7-image-20240616225512560-d2c86e.png" alt="image-20240616225512560" style="zoom:50%;" />

点击“响应”栏，可以看到域名的一些证书信息的属性及属性值：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/16/35fe0b8e1f4fe80de155a377312ec0c1-image-20240616225529867-5d7ab1.png" alt="image-20240616225529867" style="zoom:50%;" />

### 2.运行python脚本（云服务器）

使用`python3`命令执行脚本`get_domain_info_jerion.py `：

```bash
#查找python3的路径
which python3

#指定Python3的路径
#!/usr/bin/python3

#使用python解释器执行python脚本
python3 get_domain_info.py 

#安装依赖
pip3 install requests
pip3 uninstall urllib3		#如果已存在其它版本，卸载
pip3 install urllib3==1.26.16
```

可通过执行`cat /tmp/certificates_jerion.txt`命令，查看执行结果如下：

```bash
Domain: domain.jerion.cn
Issuer: {'C': 'CN', 'O': 'TrustAsia Technologies, Inc.', 'CN': 'TrustAsia RSA DV TLS CA G3'}
Start Date: 2024-05-27 08:00:00
Expire Date: 2024-08-26 07:59:59
Subject: {'CN': 'domain.jerion.cn'}

......
```

### 3.配置python脚本（sunline）

这里以公司sunline的证书为例，配置的脚本文件存放在`/usr/local/scripts`目录下，脚本内容如下：

```bash
#!/usr/bin/python3

# 导入必要的库
import time
import requests

# 登录域名和SSL证书监控系统的账号密码
admin_username = "admin"
admin_password = "Sunline11"

# 系统的登录URL和域名列表URL
login_url = 'http://domain.its.sunline.cn/api/login'
domain_list_url = 'http://domain.its.sunline.cn/api/getDomainList'
cert_info_url = 'http://domain.its.sunline.cn/api/getCertInformation'

# 准备登录请求的负载
login_payload = {
    "username": admin_username,
    "password": admin_password
}

# 发送登录请求并处理响应
login_response = requests.post(login_url, json=login_payload)
if login_response.status_code == 200:
    login_data = login_response.json()
    token = login_data.get('data', {}).get('token')
    if token:
        print("登录成功，获取到 Token")
        
        # 设置请求头和准备获取域名列表的请求体
        headers = {
            "Content-Type": "application/json",
            "X-TOKEN": token
        }

        all_domains = []
        page = 1
        size = 10  # 可调整获取更多域名

        while True:
            domain_list_payload = {
                "page": page,
                "size": size
            }

            domain_response = requests.post(domain_list_url, headers=headers, json=domain_list_payload)
            if domain_response.status_code == 200:
                domain_data = domain_response.json()
                domain_list = domain_data.get('data', {}).get('list', [])
                if not domain_list:
                    break  # 没有更多域名时退出循环

                all_domains.extend(domain_list)
                page += 1
            else:
                print(f"获取域名列表失败。状态码: {domain_response.status_code}, 响应: {domain_response.text}")
                break

        if all_domains:
            file_path = '/tmp/certificates_sunline.txt'
            with open(file_path, 'w') as file:
                for domain_info in all_domains:
                    domain = domain_info.get('domain')
                    print(f"获取域名: {domain}")
                    time.sleep(1)
                    
                    # 循环处理每个域名，获取其证书信息并写入文件
                    cert_payload = {
                        "domain": domain
                    }
                    cert_response = requests.post(cert_info_url, headers=headers, json=cert_payload)

                    if cert_response.status_code == 200:
                        data = cert_response.json()
                        print(f"证书响应: {data}")
                        time.sleep(1)
                        
                        if data.get('code') == 0:
                            cert_info = data.get('data', {})
                            parsed_cert = cert_info.get('parsed_cert', {})
                            domain_name = cert_info.get('resolve_domain')
                            issuer = parsed_cert.get('issuer', {})
                            start_date = parsed_cert.get('notBefore')
                            expire_date = parsed_cert.get('notAfter')
                            subject = parsed_cert.get('subject', {})

                            try:
                                file.write(f"Domain: {domain_name}\n")
                                file.write(f"Issuer: {issuer}\n")
                                file.write(f"Start Date: {start_date}\n")
                                file.write(f"Expire Date: {expire_date}\n")
                                file.write(f"Subject: {subject}\n")
                                file.write("\n")
                                print(f"写入文件: Domain: {domain_name}, Issuer: {issuer}, Start Date: {start_date}, Expire Date: {expire_date}, Subject: {subject}")
                            except Exception as e:
                                print(f"写入文件失败: {e}")
                        else:
                            print(f"获取 {domain} 的证书信息失败。返回消息: {data.get('msg')}")
                    else:
                        print(f"获取 {domain} 的证书信息失败。状态码: {cert_response.status_code}, 响应: {cert_response.text}")
                    print()
                    time.sleep(2)
        else:
            print("未找到任何域名。")
    else:
        print("登录失败，未能获取到 Token")
else:
    print(f"登录失败。状态码: {login_response.status_code}, 响应: {login_response.text}")

print("获取证书信息执行结束！")
```

**脚本说明：**

​		这里是与前面的脚本唯一不同的地方，因为脚本里配置的`size`属性值为`10`，即每一页最多显示10个域名信息，而公司内的域名比较多，会不止一页，因此通过在`while Ture`循环语句来增加页数`page`，直到最后一个域名打破跳出循坏。

### 4.运行python脚本（sunline）

使用`python3`命令执行脚本`get_domain_info_sunline.py `：

```bash
python3 get_domain_sunline.py 
```

可通过执行`cat /tmp/certificates_sunline.txt`命令，查看执行结果如下：

```bash
Domain: harbor.sh.sunline.cn
Issuer: {'C': 'CN', 'O': 'TrustAsia Technologies, Inc.', 'CN': 'TrustAsia RSA DV TLS CA G2'}
Start Date: 2023-07-21 08:00:00
Expire Date: 2024-07-21 07:59:59
Subject: {'CN': 'harbor.sh.sunline.cn'}

......
```



## 八、获取nginx配置

> **前面ansible获取nginx信息，是手动一个个执行ansible命令，以下是通过脚本，定义好server文件，自动执行，执行完成会筛出nginx的IP、安装路径、证书、密钥等等信息。**

### 1.导出域名信息

登录[Domain Admin-域名和SSL证书监控系统](http://domain.its.sunline.cn)，打开【证书列表】，导出域名信息，命名为`domain_info.txt`，并上传到服务器上的`/usr/local/scripts/domain/`目录下：

```bash
mkdir /usr/local/scripts/domain
cd /usr/local/scripts/domain
rz
```

### 2.配置将域名解析为IP的脚本

#### 2.1 仅输出为IP信息且不重复

##### 2.1.1 配置shell脚本

通过`ping`命令读取一个包含域名的输入文件`domain_info.txt`，将每个域名解析出对应的服务器IP地址，并存入到`/usr/local/scripts/domain`目录下的`server_ip`输出文件内。

这里创建了一个shell脚本`ping_domain.sh`，用于批量`ping`域名解析到的IP并存到文件内，具体内容如下：

```shell
#!/bin/bash

# 域名信息路径
DOMAIN_FILE="/usr/local/scripts/domain/domain_info.txt"

# 存入IP地址的文件
OUTPUT_FILE="/usr/local/scripts/domain/server_ip"

# 邮箱域名解析的IP
SKIP_IP="14.17.27.155"

> $OUTPUT_FILE

# 创建临时文件
TEMP_FILE=$(mktemp)

while read -r domain; do
  ip=$(ping -c 1 $domain | grep 'PING' | awk -F'[()]' '{print $2}')

  if [ -n "$ip" ] && [ "$ip" != "$SKIP_IP" ] && ! grep -q "$ip" "$TEMP_FILE"; then
    echo "$ip" >> $OUTPUT_FILE
    echo "$ip" >> $TEMP_FILE
  fi
done < $DOMAIN_FILE

rm $TEMP_FILE

echo "Ping操作完成，结果已保存到$OUTPUT_FILE。"
```

**脚本说明：**

- `> $OUTPUT_FILE`：清空 `OUTPUT_FILE` 文件的内容。如果文件不存在，则会创建一个空文件。

- `TEMP_FILE=$(mktemp)`：创建一个临时文件，并将临时文件的路径保存到变量 `TEMP_FILE` 中。这里的作用是为了跟踪已经处理过的IP地址，确保每个IP地址只处理一次，并避免重复记录。

- `while read -r domain; do ... done < $DOMAIN_FILE`：读取 `DOMAIN_FILE` 文件中的每一行（即每个域名），对每个域名执行循环体内的命令。

- `ip=$(......)`：获取IP地址。

  - `ping -c 1 $domain`：对当前读取的域名执行 `ping` 命令，只发送一个包（`-c 1`）。
  - `grep 'PING'`：从 `ping` 命令的输出中筛选包含`PING`文本内容的行。
  - `awk -F'[()]' '{print $2}'`：将 `grep` 命令筛选出的行作为输入，并使用 `awk` 来处理，最终打印出第二个字段。
    - `-F` ：用于指定字段分隔符；
    - `[()]`：是一个正则表达式字符类，匹配中括号内的任意一个字符，这里表示匹配括号 `(` 或 `)` 作为分隔符；
    - `{print $2}`：表示打印分隔后的第二个字段。

  ```bash
  [root@jerion domain]# ping -c 1 iboss.sunline.cn
  PING iboss.sunline.cn (172.18.0.160) 56(84) bytes of data.
  64 bytes from wecom.iboss.sunline.cn (172.18.0.160): icmp_seq=1 ttl=63 time=0.174 ms
  
  --- iboss.sunline.cn ping statistics ---
  1 packets transmitted, 1 received, 0% packet loss, time 0ms
  rtt min/avg/max/mdev = 0.174/0.174/0.174/0.000 ms
  [root@jerion domain]# ping -c 1 iboss.sunline.cn | grep 'PING'
  PING iboss.sunline.cn (172.18.0.161) 56(84) bytes of data.
  [root@jerion domain]# ping -c 1 iboss.sunline.cn | grep 'PING' | awk -F'[()]' '{print $2}' 
  172.18.0.161
  ```

- `-n "$ip"`：检查变量 `ip` 是否非空，如果 `ip` 是一个非空字符串，这个条件为真。

- `grep -q "$ip" "$TEMP_FILE"`：用于检查 `TEMP_FILE` 文件中是否包含指定的IP地址（即变量 `ip` 的内容）。

  - `grep` 是一个搜索工具，用于在文件或标准输入中搜索文本。
  - `-q` 选项告诉 `grep` 以安静模式（quiet mode）运行，即不输出任何内容，只返回一个退出状态码。
    - 如果找到匹配的行，`grep` 返回退出状态码 0；
    - 如果未找到匹配的行，`grep` 返回退出状态码 1。
  - `"$ip"` ：要搜索的模式，即IP地址。
  - `"$TEMP_FILE"` ：要搜索的文件。

##### 2.1.2 运行shell脚本

通过`sh`命令执行脚本`ping_domain.sh`，该脚本存放于`/usr/local/scripts/domain`目录下：

```bash
cd /usr/local/scripts/domain
sh ping_domain.sh
```

执行后的`server_ip`文件内容如下：

```bash
[root@jerion domain]# cat server_ip
10.10.200.19
172.18.0.160
172.18.0.79
172.18.0.100
10.22.50.249
10.22.50.221
10.22.50.220
172.18.0.78
10.22.21.99
10.22.50.135
172.18.0.161
10.22.50.129
172.18.0.82
172.18.0.50
```

#### 2.2 输出为域名+IP信息

##### 2.2.1 配置shell脚本

检查并安装`dig`命令（如果未安装），然后读取一个包含域名的输入文件`domain_info.txt`，对每个域名进行DNS解析，并将解析结果保存到`/usr/local/scripts/domain`目录下的`server_domain_ip`输出文件内。

这里创建了一个shell脚本`get_domain_ip.sh`，确保shell脚本和输入输出文件放在同一个目录，用于批量`dig`域名解析到的IP并将域名和IP存到文件内，具体内容如下：

```bash
#!/bin/bash

if ! which dig &> /dev/null; then
    
  echo "dig 命令未安装，正在安装....."
  yum install -y bind-utils

  if which dig &> /dev/null; then
    echo "dig 命令已安装."
  else
    echo "dig安装失败，请查看yum配置或者网络."
  fi
else
  echo "dig命令已安装"

fi


input_file="domain_info.txt"
output_file="server_domain_ip"

skip_domains=("mail.sunline-i.com" "mail.sunline.cn")

if [ ! -f "$input_file" ]; then
    echo "输入文件 $input_file 不存在，请检查后再运行脚本。"
    exit 1
fi

if [ ! -f "$output_file" ]; then
    touch $output_file
    echo "输出文件不存在，已创建 $output_file 文件。"
else
    echo "输出文件已存在，程序开始写入数据。"
fi

> $output_file

while IFS= read -r line
do
    # 去除行首行尾的空白字符
    domain=$(echo "$line" | tr -d '[:space:]')

    # 检查当前域名是否在跳过列表中
    skip=false
    for skip_domain in "${skip_domains[@]}"; do
        if [[ "$domain" == "$skip_domain" ]]; then
            skip=true
            echo "跳过域名：$domain"
            break
        fi
    done

    if [ "$skip" = true ]; then
        continue
    fi

    # 使用dig命令解析域名，提取IP地址
    # ip=$(dig +short $domain | head -n 1)
    
    # 使用nslookup命令解析域名，提取IP地址
    ip=$(nslookup $domain | grep "Address" | awk -F': ' 'NR==2 {print $2}')
    echo "$domain:$ip" >> $output_file
done < "$input_file"

echo "域名解析完成，结果已保存至$output_file。"
```

**脚本说明：**

- `if ! which dig &> /dev/null; then`：检查`dig`命令是否存在，如果不存在则执行条件块内的代码。
- `skip_domains=( )`：定义一个数组，包含需要跳过解析的域名，数组内的域名以空格分开。
- `while IFS= read -r line; do ... done < "$input_file"`：开始读取输入文件的每一行，并将每一行的内容存储在变量`line`中。
  - `IFS=`：在 `while` 循环的前面，我们设置 `IFS` 为空字符串。这意味着 `read` 命令不会将读取的行拆分成多个字段，而是将整行内容读入变量 `line` 中。
  - `read -r line`：`read` 命令读取文件的每一行，并将其存储在变量 `line` 中。`-r` 选项告诉 `read` 命令不要对反斜杠进行转义处理。
  - `done < "$input_file"`：通过重定向符号 `<`，我们将 `example.txt` 文件的内容作为输入提供给 `while` 循环。
- `domain=$(echo "$line" | tr -d '[:space:]')`：去除变量 `line` 中的所有空白字符（包括空格、制表符和换行符），并将处理后的结果存储在变量 `domain` 中。
  - `echo "$line"`：将变量 `line` 的内容输出到标准输出。
  - `|`：管道符，将 `echo` 命令的输出作为 `tr` 命令的输入。
  - `tr -d '[:space:]'`：`tr` 命令删除所有的空白字符。`tr` 是一个用于进行字符转换或删除的命令，`-d` 选项表示删除指定的字符集，这里使用了 POSIX 字符类 `[:space:]`，代表所有的空白字符。
  - `domain=$(...)`：将管道命令的输出结果赋值给变量 `domain`。
- `${skip_domains[@]}`：表示引用整个数组，`@`符号确保数组中的每个元素被单独处理，而不是作为一个单一的字符串。
- `dig +short $domain | head -n 1`：使用`dig`命令解析域名，并提取第一个IP地址。
- `nslookup $domain | grep "Address" | awk -F': ' 'NR==2 {print $1}'`：使用`nslookup`命令解析域名，并查找包含`Address`文本内容的行，然后通过`awk`命令只处理第二行内容，使用分隔符`': '`（冒号后面还有个空格）来将第二步结果进行分割，最终提取到IP地址。

##### 2.2.2 运行shell脚本

通过`sh`命令执行脚本`get_domain_ip.sh`，该脚本存放于`/usr/local/scripts/domain`目录下：

```bash
cd /usr/local/scripts/domain
sh get_domain_ip.sh
```

执行后的`server_domain_ip`文件内容如下：

```bash
[root@jerion domain]# cat server_domain_ip
harbor.sh.sunline.cn:10.10.200.19
iboss.sunline.cn:172.18.0.161
wecom.iboss.sunline.cn:172.18.0.161
yhtprdnew.clhd.sunline.cn:172.18.0.79
password.its.sunline.cn:172.18.0.100
jump.its.sunline.cn:10.22.50.249
demo.its.sunline.cn:172.18.0.100
proxy.its.sunline.cn:172.18.0.100
onlyoffice.cloud.sunline.cn:10.22.50.221
nx.cloud.sunline.cn:10.22.50.220
yhtprd.clhd.sunline.cn:172.18.0.78
yhtsit.clhd.sunline.cn:10.22.21.99
test.erp.sunline.cn:10.22.50.135
hr.iboss.sunline.cn:172.18.0.160
test.boss.sunline.cn:10.22.50.129
ers.sunline.cn:172.18.0.82
boss.sunline.cn:172.18.0.8
sunline-i.com:172.18.0.50
sunline.cn:172.18.0.50
```

### 3.获取nginx配置

#### 3.1 配置主机清单文件

将前面获取到的`server_ip`文件内的所有`ip`复制到`/data/ansible/hosts`主机清单文件中，命名为`domain_ip`组：

```bash
[root@jerion ansible]# vim hosts
[domain_ip]
10.10.200.19
172.18.0.160
172.18.0.79
172.18.0.100
10.22.50.249
10.22.50.221
10.22.50.220
172.18.0.78
10.22.21.99
10.22.50.135
172.18.0.161
10.22.50.129
172.18.0.82
172.18.0.50
```

由于我是在测试机`10.22.51.63`上执行ansible命令的，发现有一些服务器IP本身做了`iptables`规则，运行脚本前通过`ansible domain_ip -m shell -a 'ls -l'`命令发现有以下服务器IP无法远程：

```bash
172.18.0.160
172.18.0.161
10.22.50.220
10.10.200.19
172.18.0.82
10.22.50.129
```

可以在服务器`10.22.50.249`上远程上面这些服务器，在`iptables`配置文件内添加如下规则临时增加权限，保存后重启iptables服务：

```bash
[root@nextcloud-ctrix ~]# vim /etc/sysconfig/iptables
-A INPUT -s 10.22.51.63/32 -j ACCEPT
```

其中，`10.10.200.19`和`10.22.50.129`不知道root密码，所以没办法通过`ansible`命令去远程执行，因此可以在`/data/ansible/hosts`主机清单文件和`/usr/local/scripts/domain/server_ip`文件内删掉。

```bash
[root@jerion ~]# vim /data/ansible/hosts
[domain_ip]
172.18.0.160
172.18.0.79
172.18.0.100
10.22.50.249
10.22.50.221
10.22.50.220
172.18.0.78
10.22.21.99
10.22.50.135
172.18.0.161
172.18.0.82
172.18.0.50
[root@jerion ~]# vim /usr/local/scripts/domain/server_ip
172.18.0.160
172.18.0.79
172.18.0.100
10.22.50.249
10.22.50.221
10.22.50.220
172.18.0.78
10.22.21.99
10.22.50.135
172.18.0.161
172.18.0.82
172.18.0.50
```

添加完规则后，重新执行`ansible`命令进行测试：

```bash
ansible domain_ip -m shell -a 'ls -l'
```

#### 3.2 配置获取nginx配置和证书信息的脚本

##### 3.2.1 配置shell脚本

该Shell脚本文件的目的是去循环读取一个包含域名ip的输入文件`server_ip`，然后通过 Ansible 对指定服务器执行一系列操作，以获取和处理 Nginx 配置和证书信息，并存入到`/usr/local/scripts/nginx_configuration`目录下的输出文件内。

这里创建了一个shell脚本`extract_nginx_configuration.sh`，具体内容如下：

```bash
#!/bin/bash

#/usr/local/scripts/domain/server_ip 定义一个服务器IP列表
server_list="/usr/local/scripts/domain/server_ip"

#read -p "输入服务器列表文件路径: " server_list

output_dir="/usr/local/scripts/nginx_configuration"

if [ ! -f "$server_list" ]; then
    echo "输入文件 $server_list 不存在，请检查后再运行脚本。"
    exit 1
fi

if [ ! -d "$output_dir" ]; then
    mkdir -p $output_dir
    echo -e "输出目录不存在，已创建 $output_dir 目录。\n"
else
    echo -e "输出目录已存在，程序开始写入数据。\n"
fi

while IFS= read -r server_ip
do
    output_file="${output_dir}/ansible_${server_ip}_nginx.txt"
    {
        echo "处理服务器: $server_ip"
        
        echo -e "\n\n###### <1> 检查 nginx 路径"
        
        nginx_path=$(ansible $server_ip -m shell -a "which nginx" | grep '/nginx')
        if [[ -z "$nginx_path" ]]; then
            echo "未找到 Nginx 路径，说明该服务器未安装 Nginx。"
        else
            echo "Nginx 路径: $nginx_path"

            echo -e "\n\n\n###### <2> 查看 nginx 配置文件所在路径"
        
            nginx_config_output=$(ansible $server_ip -m shell -a "$nginx_path -V" 2>&1 | grep 'prefix=' | grep -oP 'prefix=\K[^ ]*')
            nginx_config_output="${nginx_config_output%/}"/conf  # 添加 /conf 以修正路径
            echo "Nginx 配置路径: $nginx_config_output"

            echo -e "\n\n\n###### <3> 查看 nginx 配置文件内容"
        
            nginx_conf_file="${nginx_config_output}/nginx.conf"
            ansible $server_ip -m shell -a "cat $nginx_conf_file" | grep -v 'CHANGED | rc=0'
            echo -e "\n包含的配置文件:"
            
            conf_files=$(ansible $server_ip -m shell -a "grep 'include' $nginx_conf_file" | grep -v '#' | grep -oP '(conf.d|vhost)' | head -n 1)
            confd_conf_files=''
            if [ -z "$conf_files" ]; then
                echo "无"
            else
                confd_conf_files=$(ansible $server_ip -m shell -a "ls $nginx_config_output/$conf_files" | grep -oP '.*conf$')
                echo "$confd_conf_files"
            fi
            
            echo -e "\n\n\n###### <4> 提取的证书路径"

            cert_files=$(ansible $server_ip -m shell -a "grep -v '#' $nginx_conf_file" | grep -oP 'ssl_certificate(_key)?\s+\K[^;]*')
            echo -e "从nginx.conf提取的证书路径:"
            if [ -z "$cert_files" ]; then
                echo -e "无\n"
            else
                cert_files_array=($cert_files)   # 转换为数组
                cert_paths=''
                for cert_file in "${cert_files_array[@]}"; do
                    if ! [[  "$cert_file" =~ "none" ]]; then
                        if [[ ${cert_file:0:1} != "/" ]]; then
                            cert_paths+="$nginx_config_output/$cert_file"
                        else
                            cert_paths+="$cert_file"
                        fi
                        cert_paths+=$'\n'   # 添加换行符作为分隔符
                    fi
                done
                echo "$cert_paths"
            fi

            echo -e "从非nginx.conf提取的证书路径:"
            if [ -z "$confd_conf_files" ]; then
                echo -e "无\n"
            else
                cert_files2=$(ansible $server_ip -m shell -a "cd $nginx_config_output/$conf_files && echo '$confd_conf_files' | xargs cat" | grep -v '#' | grep -oP 'ssl_certificate(_key)?\s+\K[^;]*')
                if [ -z "$cert_files2" ]; then
                    echo -e "无\n"
                else
                    cert_files_array2=($cert_files2)   # 转换为数组
                    cert_paths2=''
                    for cert_file2 in "${cert_files_array2[@]}"; do
                        if ! [[  "$cert_file2" =~ "none" ]]; then
                            if [[ ${cert_file2:0:1} != "/" ]]; then
                                cert_paths2+="$nginx_config_output/$cert_file2"
                            else
                                cert_paths2+="$cert_file2"
                            fi
                            cert_paths2+=$'\n'   # 添加换行符作为分隔符
                        fi
                    done
                    echo "$cert_paths2"
                fi
            fi
        fi
    } > $output_file

    echo "服务器 $server_ip 的结果已保存到 ${output_file}"
done < "$server_list"

echo -e "\n所有服务器执行完毕！"
```

**脚本说明：**

###### 3.2.1.1 检查 nginx 路径

- `! -f "$server_list"`：检查文件是否不存在。

- `-d "$output_dir"`：检查目录是否存在。

- `search_dirs=( )`：定义一个数组 `search_dirs`，包含多个目录路径，用于在系统中搜索证书文件。

- `while IFS= read -r server_ip`：使用 `while` 循环逐行读取服务器列表文件，每行存储在变量 `server_ip` 中。

- `{ ...... } > $output_file`：使用花括号 `{}` 包含所有命令，确保所有输出重定向到 `output_file`。

- `"which nginx" | grep '/nginx'`：

  - `which nginx`：这个命令用于查找 `nginx` 可执行文件的位置，并输出其路径。
  - `| grep '/nginx'`：通过管道将 `which nginx` 的输出传递给 `grep` 命令，并查找包含“/nginx"内容的行。

  **存在nginx，以`172.18.0.160`为例：**

  ```bash
  [root@jerion ~]# ansible 172.18.0.160 -m shell -a 'which nginx'
  172.18.0.160 | CHANGED | rc=0 >>
  /bin/nginx
  [root@jerion nginx_configuration]# ansible 172.18.0.160 -m shell -a 'which nginx' | grep '/nginx'
  /bin/nginx
  ```

  **不存在nginx，以`10.22.50.249`为例：**

  ```bash
  [root@jerion ~]# ansible 10.22.50.249 -m shell -a 'which nginx'
  10.22.50.249 | FAILED | rc=1 >>
  which: no nginx in (/sbin:/bin:/usr/sbin:/usr/bin)non-zero return code
  [root@jerion nginx_configuration]# ansible 10.22.50.249 -m shell -a 'which nginx' | grep '/nginx'
  [root@jerion nginx_configuration]# 
  ```

###### 3.2.1.2 查看 nginx 配置文件所在路径

- `echo -e`：用于打印带有转义字符的字符串，使用 `-e` 选项时，`echo` 会解释转义字符，例如 `\n` 表示换行，`\t` 表示制表符等。

- `"$nginx_path -V" 2>&1 | grep 'prefix=' | grep -oP 'prefix=\K[^ ]*'`：从nginx的版本信息中提取nginx的安装路径。

  - `$nginx_path -V`：执行nginx的路径变量（`$nginx_path`）加上`-V`参数，通常用于显示nginx的版本信息及编译时的相关配置。

  - `2>&1`：将标准错误（stderr）合并到标准输出（stdout）。这样，错误信息也会被传递到管道中，确保所有输出都被处理。

  - `grep 'prefix='`：从合并后的输出中筛选包含`prefix=`的行。`prefix`是nginx编译时设置的安装目录。

  - `grep -oP 'prefix=\K[^ ]*'`：
    
    - `grep -oP`: `-P`表示使用 Perl 正则表达式（PCRE），`-o` 表示只输出匹配部分。
    - `'prefix=\K[^ ]*'` ：这是一个要匹配的正则表达式。
      - `prefix=`：直接匹配字符串 `prefix=`，这部分用于寻找包含 `prefix=` 的文本行。
      - `\K`：重置匹配的开始位置，忽略 `prefix=` 。
      - `[^;]*` 从当前位置开始，匹配任何字符，但不包括空格，即直到遇到空格。
    
    **如果不想对圆括号进行转义，在 `sed` 中可以使用 `-E`或`-r` 选项，来使用扩展正则表达式，这样可以直接使用圆括号。**
    
    - `.*`：匹配捕获组之后的任意字符（除了换行符）。
    - `/\1/`：将匹配的内容替换为第一个捕获组的内容，这里最后面没有使用全局标志 `g` 的原因是这个命令只需要在每一行中进行一次替换操作。

  **存在nginx，以`172.18.0.160`为例：**

  ```bash
  [root@jerion ~]# ansible 172.18.0.160 -m shell -a "/bin/nginx -V" 2>&1
  172.18.0.160 | CHANGED | rc=0 >>
  nginx version: nginx/1.25.1
  built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
  built with OpenSSL 1.0.2k-fips  26 Jan 2017
  TLS SNI support enabled
  configure arguments: --user=nginx --group=nginx --prefix=/data/nginx --with-pcre --with-http_v2_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_stub_status_module --with-http_ssl_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module --with-http_dav_module --with-ld-opt=-Wl,-E --with-cc-opt=-Wno-error --with-ld-opt=-ljemalloc --add-module=/root/ngx_brotli --add-module=/root/ngx_http_substitutions_filter_module-master
  [root@jerion ~]# ansible 172.18.0.160 -m shell -a "/bin/nginx -V" 2>&1 | grep 'prefix='
  configure arguments: --user=nginx --group=nginx --prefix=/data/nginx --with-pcre --with-http_v2_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_stub_status_module --with-http_ssl_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module --with-http_dav_module --with-ld-opt=-Wl,-E --with-cc-opt=-Wno-error --with-ld-opt=-ljemalloc --add-module=/root/ngx_brotli --add-module=/root/ngx_http_substitutions_filter_module-master
  [root@jerion ~]# ansible 172.18.0.160 -m shell -a "/bin/nginx -V" 2>&1 | grep 'prefix=' | grep -oP 'prefix=\K[^ ]*' 
  /data/nginx
  ```

  **不存在nginx，以`10.22.50.249`为例：**

  ```bash
  [root@jerion ~]# ansible 10.22.50.249 -m shell -a "/bin/nginx -V" 2>&1
  10.22.50.249 | FAILED | rc=127 >>
  /bin/sh: /bin/nginx: 没有那个文件或目录non-zero return code
  [root@jerion ~]# ansible 10.22.50.249 -m shell -a "/bin/nginx -V" 2>&1 | grep 'prefix=' | grep -oP 'prefix=\K[^ ]*'
  [root@jerion ~]# 
  ```

###### 3.2.1.3 查看 nginx 配置文件内容（包含的配置文件）

- `${nginx_config_output%/}/conf`：

  - `${nginx_config_output%/}`：`${variable%pattern}` 是 Bash 中的一种字符串操作语法，`nginx_config_output%/` 表示从变量 `nginx_config_output` 的末尾删除一个 `/` 字符（如果存在），如果字符串末尾没有 `/`，则什么都不做。
  - `/conf`：在执行了前一步之后，将结果与字符串 `"/conf"` 连接起来。

- `"grep 'include' $nginx_conf_file" | grep -v '#' | grep -oP '(conf.d|vhost)' | head -n 1`：主要是在`nginx.conf`配置文件内，查找是否包含`conf`配置文件，然后提取父目录，**目的是为后面的从非nginx.conf提取的证书路径做准备**。

  - `grep 'include' $nginx_conf_file`：在 `nginx.conf` 文件中查找所有包含 "include" 的行。
  - `grep -v '#'`：查找所有包含“#”的行，将其删除。
  - `grep -oP '(conf.d|vhost)'`：
    - `grep -oP`: `-P`表示使用 Perl 正则表达式（PCRE），`-o` 表示只输出匹配部分。
    - `'(conf.d|vhost)'` ：这是一个要匹配的正则表达式，直接匹配字符串 `conf.d/`或`vhosts/`，这部分主要用于寻找`conf`配置文件存放在 `conf.d/`还是`vhosts/`目录下。
  - `head -n 1`：用`head`命令只取第一行的值，作用为若有多个配置文件，父目录均为相同，因此只需要取第一个即可。

  **存在nginx，且配置文件所在目录为`conf.d`，以`172.18.0.100`为例：**

  ```bash
  [root@jerion ~]# ansible 172.18.0.100 -m shell -a "grep 'include' /usr/local/nginx/conf/nginx.conf" | grep -v '#'
  172.18.0.100 | CHANGED | rc=0 >>
    include mime.types;
    include conf.d/proxy.its.sunline.cn.conf;
    include conf.d/demo.its.sunline.cn.conf;
    include conf.d/domain.its.sunline.cn.conf;
    include conf.d/share.mis.sunline.cn.conf;
    include conf.d/download.cloud.sunline.cn.conf;
    include conf.d/nginxui.its.sunline.cn.conf;
    include conf.d/password.its.sunline.cn.conf;
    include conf.d/harbor.sh.sunline.cn.conf;
    include conf.d/_.conf;
  [root@jerion ~]# ansible 172.18.0.100 -m shell -a "grep 'include' /usr/local/nginx/conf/nginx.conf" | grep -v '#' | grep -oP '(conf.d|vhost)' 
  conf.d
  conf.d
  conf.d
  conf.d
  conf.d
  conf.d
  conf.d
  conf.d
  conf.d
  [root@jerion ~]# ansible 172.18.0.100 -m shell -a "grep 'include' /usr/local/nginx/conf/nginx.conf" | grep -v '#' | grep -oP '(conf.d|vhost)' | head -n 1
  conf.d
  ```

  **存在nginx，且配置文件所在目录为`vhost`，以`172.18.0.50`为例：**

  ```bash
  [root@jerion ~]# ansible 172.18.0.50 -m shell -a "grep 'include' /usr/local/nginx/conf/nginx.conf" | grep -v '#'
  172.18.0.50 | CHANGED | rc=0 >>
    include mime.types;
    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload" always;
    include /usr/local/nginx/conf/vhost/*.conf;
  [root@jerion ~]# ansible 172.18.0.50 -m shell -a "grep 'include' /usr/local/nginx/conf/nginx.conf" | grep -v '#' | grep -oP '(conf.d|vhost)' | head -n 1
  vhost
  ```

- `"ls $nginx_config_output/$conf_files" | grep -oP '.*conf$'`：

  - `"ls $nginx_config_output/$conf_files"`：`$conf_files`属性值为`conf`配置文件所在的父目录，即列出父目录下的所有配置文件。
  - `grep -oP '.*conf$'`：
    - `-o` ：表示只输出匹配部分。
    - `-P`： 表示使用 Perl 兼容正则表达式（PCRE）。
    - `'.*conf$'` ：匹配任意多个字符，直到结尾为`conf`。
  
  **存在nginx，且配置文件所在目录为`conf.d`，以`172.18.0.160`为例：**
  
  ```bash
  [root@jerion ~]# ansible 172.18.0.160 -m shell -a "grep 'conf.d' /data/nginx/conf/nginx.conf"
  172.18.0.160 | CHANGED | rc=0 >>
    include conf.d/*.conf;
  [root@jerion ~]# ansible 172.18.0.160 -m shell -a "ls /data/nginx/conf/conf.d" |  grep -oP '.*conf$'
  hr.iboss.sunline.cn-9443.conf
  iboss.sunline.cn-8443.conf
  iboss.sunline.cn.conf
  none.conf
  wecom.iboss.sunline.cn-6443.conf
  ```
  
  **存在nginx，且配置文件所在目录为`vhost`，以`172.18.0.50`为例：**
  
  ```bash
  [root@jerion ~]# ansible 172.18.0.50 -m shell -a "grep 'vhost' /usr/local/nginx/conf/nginx.conf"
  172.18.0.50 | CHANGED | rc=0 >>
    include /usr/local/nginx/conf/vhost/*.conf;
  [root@jerion ~]# ansible 172.18.0.50 -m shell -a "ls /usr/local/nginx/conf/vhost"
  172.18.0.50 | CHANGED | rc=0 >>
  none.conf
  sunline.cn.conf
  sunline-i.com.conf
  www_cpanel.conf.bak
  zw-A.conf
  [root@jerion ~]# ansible 172.18.0.50 -m shell -a "ls /usr/local/nginx/conf/vhost" | grep -oP '.*conf$'
  none.conf
  sunline.cn.conf
  sunline-i.com.conf
  zw-A.conf
  ```
  

###### 3.2.1.4 从nginx.conf提取的证书路径

- `grep -oP 'ssl_certificate(_key)?\s+\K[^;]*'`：

  - `grep -oP`: `-P`表示使用 Perl 正则表达式（PCRE），`-o` 表示只输出匹配部分。
  -  `'ssl_certificate\s+\K[^;]*'` ：这是一个要匹配的正则表达式。
    - `ssl_certificate`：直接匹配字符串 `ssl_certificate`，这部分用于寻找包含 `ssl_certificate` 的文本行。
    - `(_key)?`：表示 `_key` 是可选的，可以出现0次或1次。
    - `\s+`：匹配到一个或多个空白字符（例如空格）。
    - `\K`：重置匹配的开始位置，忽略 `ssl_certificate` 和空白字符。
    - `[^;]*` 从当前位置开始，匹配任何字符，但不包括分号 `;`，即直到遇到分号 `;`。
  
  **存在nginx，以`172.18.0.78`为例：**
  
  ```bash
  [root@jerion ~]# ansible 172.18.0.78 -m shell -a "grep -v '#' /usr/local/nginx/conf/nginx.conf" | grep -oP 'ssl_certificate(_key)?\s+\K[^;]*'
  /usr/local/nginx/ssl/yhtprd.clhd.sunline.cn_bundle.crt
  /usr/local/nginx/ssl/yhtprd.clhd.sunline.cn.key
  /usr/local/nginx/ssl/none-ca.crt
  /usr/local/nginx/ssl/none-ca.key
  
  # 172.18.0.78的ssl证书所在目录/usr/local/nginx/ssl下不止nginx.conf中用到的，通过ls命令查看目录证书下，还包括了没有用到的，为20230103目录的证书，所以直接取nginx.conf中用到的路径就行
  [root@jerion ~]# ansible 172.18.0.78 -m shell -a "ls /usr/local/nginx/ssl"
  172.18.0.78 | CHANGED | rc=0 >>
  20230103
  none-ca.crt
  none-ca.key
  yhtprd.clhd.sunline.cn_bundle.crt
  yhtprd.clhd.sunline.cn.key
  ```

- `cert_files_array=($cert_files)`：将获取到的证书路径转换为数组。
- `for cert_file in "${cert_files_array[@]}"; do .... done`：这里通过for循环遍历证书路径数组目的为后面判断路径是相对路径还是绝对路径做准备，然后将所有路径存放于变量`cert_paths`中。
- `! [[  "$cert_file" =~ "none" ]]`：判断证书是否为none证书，不是的话执行if语句里的命令，是的话直接跳过。
- `${cert_files:0:1} != "/"`：判断字符串变量的第一个字符是否不等于`/`。这里主要是用来判断证书路径为绝对路径还是相对路径，如果是相对路径，第一个字符不会以`/`开始，则执行`if`语句里的命令。
  - `:0:1`：这是切片的部分，表示从字符串的第0个字符开始，取长度为1的子字符串。
  - ` != "/"`：判断是否不等于字符`/`。

###### 3.2.1.5 从非nginx.conf提取的证书路径

- `"cd $nginx_config_output/$conf_files && echo '$confd_conf_files' | xargs cat"`：

  - `cd $nginx_config_output/$conf_files`：进入到`conf`配置文件所在的父目录。
  - `&&`：使用逻辑与运算符，主要用于保证前后的命令在同一个子shell中执行。
  - `echo '$confd_conf_files' | xargs cat"`：
    - `echo '$confd_conf_files'`：输出变量 `$confd_conf_files` 的内容，即多个`conf`配置文件。
    - `|`：通过`|`管道操作符，将前一个命令的输出作为后一个命令的输入。
    - `xargs cat`：`xargs` 从标准输入读取数据并将其作为参数传递给后面的命令**（主要确保 `cat` 命令一次性读取所有文件）**，而后`cat` 命令会接收 `xargs` 传递的文件名并读取它们的内容。

    **存在nginx，以`172.18.0.161`为例：**

  ```bash
  # 先定义了一个变量confd_conf_files获取conf.d目录下的conf配置文件，然后通过cat命令读取所有配置文件的内容再进行处理
  [root@jerion ~]# confd_conf_files=$(ansible 172.18.0.161 -m shell -a "ls /data/nginx/conf/conf.d" | grep -oP '.*conf$')
  [root@jerion ~]# ansible 172.18.0.161 -m shell -a "cd /data/nginx/conf/conf.d && echo '$confd_conf_files' | xargs cat" | grep -v '#' | grep -oP 'ssl_certificate(_key)?\s+\K[^;]*'
  cert/hr.iboss.sunline.cn_bundle.pem
  cert/hr.iboss.sunline.cn.key
  cert/iboss.sunline.cn.pem
  cert/iboss.sunline.cn.key
  cert/iboss.sunline.cn.pem
  cert/iboss.sunline.cn.key
  cert/none-ca.crt
  cert/none-ca.key
  cert/wecom.iboss.sunline.cn.pem
  cert/wecom.iboss.sunline.cn.key
  ```

##### 3.2.2 运行shell脚本

执行脚本`extract_nginx_configuration.sh`，该脚本存放于`/usr/local/scripts/nginx_configuration`目录下：

```bash
cd /usr/local/scripts/nginx_configuration
sh extract_nginx_configuration.sh
```

执行后的结果如下：

```bash
[root@jerion nginx_configuration]# sh extract_nginx_configuration.sh 
输出目录已存在，程序开始写入数据。

服务器 172.18.0.160 的结果已保存到......
.......

所有服务器执行完毕！
```

执行后通过`ls`命令查看`nginx_configuration`目录，可以看到生成了获取nginx配置的每个服务器文件：

```bash
[root@jerion scripts]# ls nginx_configuration
ansible_10.22.21.99_nginx.txt   ansible_172.18.0.100_nginx.txt  ansible_172.18.0.79_nginx.txt
ansible_10.22.50.135_nginx.txt  ansible_172.18.0.160_nginx.txt  ansible_172.18.0.82_nginx.txt
ansible_10.22.50.220_nginx.txt  ansible_172.18.0.161_nginx.txt  extract_nginx_configuration.sh
ansible_10.22.50.221_nginx.txt  ansible_172.18.0.50_nginx.txt
ansible_10.22.50.249_nginx.txt  ansible_172.18.0.78_nginx.txt
```

进入`ansible_172.18.0.100_nginx.txt`文件，可以查看到每个获取的信息：

```bash
[root@jerion nginx_configuration]# vim ansible_172.18.0.100_nginx.txt
处理服务器: 172.18.0.100


###### <1> 检查 nginx 路径
Nginx 路径: /sbin/nginx

......


###### <4> 提取的证书路径
从nginx.conf提取的证书路径:
无

从非nginx.conf提取的证书路径:
/usr/local/nginxwebui/cert/demo.its.sunline.cn/demo.its.sunline.cn.pem
/usr/local/nginxwebui/cert/demo.its.sunline.cn/demo.its.sunline.cn.key
/usr/local/nginxwebui/cert/harbor.sh.sunline.cn/harbor.sh.sunline.cn.pem
/usr/local/nginxwebui/cert/harbor.sh.sunline.cn/harbor.sh.sunline.cn.key
/usr/local/nginxwebui/cert/password.its.sunline.cn/password.its.sunline.cn.pem
/usr/local/nginxwebui/cert/password.its.sunline.cn/password.its.sunline.cn.key
/usr/local/nginxwebui/cert/proxy.its.sunline.cn/proxy.its.sunline.cn.pem
/usr/local/nginxwebui/cert/proxy.its.sunline.cn/proxy.its.sunline.cn.key
```

#### 3.3 配置提取nginx及证书信息的脚本

##### 3.3.1 配置shell脚本

该脚本是基于上方每台服务器获取到nginx配置和证书信息生成的文件的脚本后执行，主要是将所有服务器的nginx配置和证书信息文件`ansible_*_nginx.txt`提取部分nginx信息并合并到一个文件，方便查看。

这里创建了一个shell脚本`extract_nginx_info.sh`，具体内容如下：

```bash
#!/bin/bash

output_file="/tmp/extract_nginx_data.txt"

echo -n "" > $output_file

directory="/usr/local/scripts/nginx_configuration"

for file in $directory/ansible_*.txt	
do
    ip=$(echo "$file" | grep -oP 'ansible_\K[0-9.]+(?=_nginx.txt)')
    echo "Processing $ip"
    nginx_path=$(grep "Nginx 路径" "$file" | awk -F': ' '{print $2}')
    if [ -z "$nginx_path" ]; then
        echo "IP: $ip" >> $output_file
        echo "No Nginx" >> $output_file
    else
        config_path=$(grep "Nginx 配置路径" "$file" | awk -F': ' '{print $2}')
        cert_path=$(grep -P '\.(pem|cer|crt)$' "$file")
        key_path=$(grep -P '\.key$' "$file")
        echo "IP: $ip" >> $output_file
        echo "Nginx Path: $nginx_path" >> $output_file
        echo "Config Path: $config_path" >> $output_file
        echo -e "Cert Path:\n$cert_path" >> $output_file
        echo -e "Key Path:\n$key_path" >> $output_file
    fi
    echo "-------------------------------------" >> $output_file
    sleep 1
done

echo "Data extraction complete. Results saved in $output_file"
```

**脚本说明：**

- `echo -n`：输出文本，`-n`表示不会在末尾添加换行符。
- `grep -oP 'ansible_\K[0-9.]+(?=_nginx.txt)'`：
  - `grep -oP`: `-P`表示使用 Perl 正则表达式（PCRE），`-o` 表示只输出匹配部分。
  - `'ansible_\K[0-9.]+(?=_nginx.txt)'` ：这是一个要匹配的正则表达式。
    - `\K`：重置匹配的起始位置，只将此位置之后的部分作为匹配结果的一部分。
    - `[0-9.]+`：匹配一个或多个数字（0-9）和点（.）。
    - `\K`：重置匹配的开始位置，忽略 `ssl_certificate` 和空白字符。
    - `(?=_nginx.txt)`：正向前瞻断言，表示匹配的内容后面紧跟着 "_nginx.txt"。`(?=...)` 是一个正向前瞻断言，它用于确保某个模式在匹配的位置之后存在，而不会将其包含在匹配结果中。
- `awk -F': ' '{print $2}'`：读取文件中的每一行，并以 `:  `（冒号后面有空格）作为分隔符，将行分割成多个字段，然后打印第二个字段。
- `'\.(pem|cer|crt)$'`：先匹配一个点（.），然后匹配 `pem`、`cer` 或 `crt` 其中之一，`$`表示以这三个为结尾的内容。
- `'\.key$'`：先匹配一个点（.），然后匹配`key`，`$`表示以`key`为结尾的内容。

##### 3.3.2 运行shell脚本

执行脚本`extract_nginx_info.sh`，该脚本存放于`/usr/local/scripts/nginx_configuration`目录下：

```bash
cd /usr/local/scripts/nginx_configuration
sh extract_nginx_info
```

执行后的结果如下：

```bash
[root@jerion nginx_configuration]# sh extract_nginx_info.sh
Processing 10.22.21.99
Processing 10.22.50.135
....
Data extraction complete. Results saved in /tmp/extract_nginx_data.txt
```

执行后通过`cat`命令查看`/tmp/extract_nginx_data.txt`文件，可以看到将每个服务器获取到nginx配置和证书信息文件内的部分信息提取并合并了起来：

```bash
[root@jerion nginx_configuration]# cat /tmp/extract_nginx_data.txt    
IP: 10.22.21.99
No Nginx
-------------------------------------
IP: 10.22.50.220
Nginx Path: /sbin/nginx
Config Path: /usr/local/nginx/conf
Cert Path:
/usr/local/nginx/cert/nx.cloud.sunline.cn_nginx/nx.cloud.sunline.cn_bundle.crt
Key Path:
/usr/local/nginx/cert/nx.cloud.sunline.cn_nginx/nx.cloud.sunline.cn.key
-------------------------------------
......
```



## 九、使用yunwei账号

`sshpass`是一个允许你在命令行中传递密码的工具。

### 1.安装sshpass

```bash
yum install -y epel-release
yum install -y sshpass
```

### 2.修改主机清单文件

修改`/data/ansible/hosts`文件如下：

```bash
[all:vars]
#ansible_user=root
#ansible_ssh_private_key_file=/root/.ssh/id_rsa
ansible_ssh_user=yunwei
ansible_ssh_pass=Sun%2020
ansible_sudo_pass=Sun%2020
```
