# yum或dnf命令



这里只以 yum 命令为例，dnf 命令基本相同：

```bash
yum list installed                        # 查看所有已安装的 yum 包
yum list installed | less                 # 分页查看
yum list installed -q                     # 简洁模式（不显示 extras 信息）
yum list installed | wc -l                # 统计已安装包的数量
yum list installed | grep <package_name>  # 查找特定软件包是否安装

yum info <installed_package_name>         # 查看某个软件包的详细信息

yum history list                          # 查看安装操作的历史记录（默认只显示最近 20 条记录）
yum history list --all                    # 查看安装操作的所有历史记录
yum history info <ID>                     # 查看某次操作的详细信息

yum repoinfo <baserepo>                   # 查看仓库详细信息（显示repo的baseurl、状态、元数据信息等）
# 仓库文件中，centos stream 9以上可用$stream，但在rhel 9上不行，只能用 $releasever-stream

yum --showduplicates list <package_name>  # 查看某个软件包的所有版本

yum repolist all                          # 列出所有配置的 Yum 仓库，包括已启用和已禁用的仓库
yum repolist enabled                      # 仅显示已启用的仓库
yum repolist disabled                     # 仅显示已禁用的仓库

yum groups list                           # 显示所有的环境组和功能组
yum groupinstall <package_groupname>      # 安装一个或多个软件包组
```

以下仅限 dnf 命令操作：

```bash
dnf repoquery --qf '%{name}' "*"           # 查看仓库里所有包名信息
dnf repoquery --qf "%{name}-%{version}-%{release}.%{arch}" "*"    # 查看仓库里所有包的名称+版本+架构
dnf repoquery --qf "%{name} from %{repoid}" <package_name>        # 查看某个包来自哪个仓库
dnf repoquery --qf "%{name} src: %{sourcerpm}" httpd              # 输出源RPM

# 禁用所有仓库并只启用epel仓库，然后查询仓库中以a开头的包名
dnf repoquery --disablerepo="*" --enablerepo="epel" --qf "%{name}" "a*"
# 禁用所有仓库并只启用epel仓库，然后查询仓库中以a开头的包名，并作为参数传给dnf download下载到本地当前目录中
dnf repoquery --disablerepo="*" --enablerepo="epel" --qf "%{name}" "a*" | xargs dnf download
# 通过上述命令，对a到z字母开头的epel仓库里的包名进行批量下载
for i in {a..z}; do dnf repoquery --disablerepo="*" --enablerepo="epel" --qf "%{name}" "${i}*" | xargs dnf download; done

# 查询指定版本（9）和架构（aarch64）的所有软件包名称
dnf --releasever=9 --forcearch=aarch64 repoquery --qf "%{name}" "*"
# 查询指定版本（9）和架构（aarch64）的所有软件包名称，并作为参数传给dnf --releasever=9 --forcearch=aarch64 download下载到本地当前目录中
dnf --releasever=9 --forcearch=aarch64 repoquery --qf "%{name}" "*" | xargs dnf --releasever=9 --forcearch=aarch64 download
```

