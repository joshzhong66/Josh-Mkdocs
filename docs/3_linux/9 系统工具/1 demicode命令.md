# dmidecode命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `dmidecode` 命令用法。

## 一、简介

`dmidecode` 是一个非常实用的 Linux 系统硬件信息查看工具，它可以读取系统 BIOS 提供的 DMI（Desktop Management Interface）表 信息，从而显示服务器或电脑的详细硬件信息，比如：主板、CPU、内存、BIOS、序列号等。

**基本介绍：**

- **命令名称**：`dmidecode` ；
- **作用**：解析 DMI 表，显示系统硬件的详细信息；
- **运行权限**：通常需要 root 权限；
- **适用系统**：大多数 Linux 发行版（如 CentOS、Ubuntu、openEuler、Debian 等）。



## 二、安装

```bash
# CentOS / RHEL / openEuler
yum install dmidecode -y

# Ubuntu / Debian
apt install dmidecode -y
```



## 三、基本用法

### 1.查看所有硬件信息

```bash
dmidecode
```

输出很长，包含多个 section，例如：

- BIOS Information；
- System Information；
- Base Board Information（主板）；
- Processor Information（CPU）；
- Memory Device（内存条）。

### 2.查看特定类型的信息

通过 `-t` 参数指定类型：

```bash
dmidecode -t <type>
```

常见类型如下：

| 类型编号 |   类型名称   |               说明               |
| :------: | :----------: | :------------------------------: |
|    0     |     bios     |            BIOS 信息             |
|    1     |    system    | 系统信息（厂商、产品名、序列号） |
|    2     |  baseboard   |             主板信息             |
|    3     |   chassis    |             机箱信息             |
|    4     |  processor   |            处理器信息            |
|    17    |    memory    |             内存信息             |
|    16    | memory array |           内存阵列信息           |
|    7     |    cache     |             缓存信息             |
|    9     |     slot     |             插槽信息             |
|    11    | oem-specific |           OEM 特定信息           |

例如：

```bash
dmidecode -t system
```

输出如下：

```bash
System Information
    Manufacturer: Dell Inc.
    Product Name: PowerEdge R740
    Version: Not Specified
    Serial Number: ABCD123
    UUID: 4C4C4544-0053-5910-8052-C7C04F4C3331
```

### 3.查看BIOS信息

```bash
dmidecode -t bios
```

输出包括：

- BIOS 厂商、版本号；
- BIOS 发布时间；
- 支持的启动特性。

### 4.查看主板信息

```bash
dmidecode -t baseboard
```

### 5.查看CPU信息

```bash
dmidecode -t processor
```

### 6.查看内存信息

```bash
dmidecode -t memory
```

输出每个内存插槽的详细信息，包括：

- 容量；
- 厂商；
- 型号；
- 速度（MHz）；
- 插槽号。



## 四、查看DMI类型列表

想知道所有可查询类型，可执行：

```bash
dmidecode -t
```

会显示支持的类型编号与名称。



## 五、常用组合命令

```bash
# 查看序列号
dmidecode -s system-serial-number

# 查看系统厂商
dmidecode -s system-manufacturer

# 查看产品型号
dmidecode -s system-product-name

# 查看 BIOS 版本
dmidecode -s bios-version

# 查看所有支持的 -s 参数
dmidecode -s
```



## 六、-s参数支持的字段

部分常用字段如下：

|          命令          |    说明    |
| :--------------------: | :--------: |
|  system-manufacturer   | 系统制造商 |
|  system-product-name   |  产品名称  |
|  system-serial-number  | 系统序列号 |
|      bios-version      | BIOS 版本  |
| baseboard-manufacturer |  主板厂商  |
| baseboard-product-name |  主板型号  |
|   processor-version    |  CPU 型号  |



## 七、使用示例汇总

```bash
# 查看系统型号
dmidecode -s system-product-name

# 查看主板型号
dmidecode -s baseboard-product-name

# 查看序列号
dmidecode -s system-serial-number

# 查看 CPU 型号
dmidecode -s processor-version

# 查看 BIOS 版本
dmidecode -s bios-version
```



## 八、注意事项

1. **必须使用 root 权限**（否则会提示权限不足或输出不全）；
2. 读取信息来源于 BIOS，因此**虚拟机中输出可能不完整**；
3. 某些 OEM 服务器厂商（如 HP、Dell）可能会在 BIOS 层面屏蔽或定制 DMI 信息；
4. 输出结果仅供读取，不支持修改。
