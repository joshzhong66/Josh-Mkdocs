# jq命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `jq` 命令用法。

## 一、简介

`jq` 是一个轻量级的命令行工具，用于处理 JSON 数据。在 Linux 环境中，它广泛应用于解析、筛选和格式化 JSON 格式的数据。



## 二、选项

|    选项     |                    说明                    |                             示例                             |
| :---------: | :----------------------------------------: | :----------------------------------------------------------: |
|    `-r`     |           输出原始文本，不加引号           |      `jq -r '.name' file.json` 输出 `John`（不带引号）       |
|    `-c`     |       压缩输出，去除多余的空格和换行       |          `jq -c '.' file.json` 输出单行格式的 JSON           |
|    `-M`     |   禁用彩色输出（默认情况下启用彩色输出）   |          `jq -M '.' file.json` 输出不带颜色的 JSON           |
|    `-s`     |       将多个 JSON 文件合并为一个数组       |  `jq -s '.' file1.json file2.json` 合并两个 JSON 文件为数组  |
|    `-e`     |     如果查询结果为空，则返回非零退出码     |  `jq -e '.name' file.json` 如果 `.name` 不存在，返回非零值   |
|    `-f`     |            从文件中读取 jq 脚本            | `jq -f script.jq file.json` 读取并执行 `script.jq` 中的查询  |
|    `-n`     |   不读取输入文件，而是使用空输入进行操作   |  `jq -n '{ "name": "John", "age": 30 }'` 创建新的 JSON 对象  |
|   `--arg`   |   定义一个字符串类型的变量并在查询中使用   | `jq --arg name "Alice" '.name = $name' file.json` 设定 `name` 值 |
| `--argjson` | 定义一个 JSON 数据类型的变量并在查询中使用 | `jq --argjson data '{"key": "value"}' '.data = $data' file.json` |



## 三、安装jq

```bash
yum install -y jq
```



## 四、提取原理

在 `jq` 中，使用 `.` 来表示当前对象或数据流，并通过路径访问字段或数组元素。

- `.` 表示当前的 JSON 对象。
- 通过 `.` 后面跟着字段名或数组索引来提取特定的内容。



## 五、使用示例

### 1.示例一

#### 1.1 创建JSON文件

创建一个名为 `my_info1.json`，内容如下：

```bash
{
  "name": "Josh",
  "age": 20,
  "city": "Shen Zhen",
  "like": {
    "1": "骑车",
    "2": "爬山"
  }
}
```

#### 1.2 提取单个字段

以 `.` 开头，提取 `name` 字段：

```bash
[root@zhongjl-51-64 /tmp]# jq '.name' my_info1.json 
"Josh"
```

#### 1.3 提取多个字段

```bash
[root@zhongjl-51-64 /tmp]# jq '.name, .age, .city' my_info1.json 
"Josh"
20
"Shen Zhen"
```

#### 1.4 提取全部

```bash
[root@zhongjl-51-64 /tmp]# jq '.' my_info1.json 
{
  "name": "Josh",
  "age": 20,
  "city": "Shen Zhen",
  "like": {
    "1": "骑车",
    "2": "爬山"
  }
}
```

### 2.示例二

#### 2.1 创建嵌套JSON

创建嵌套的 json 文件 `my_info2.json`，内容如下：

```bash
{
  "my_info": {
    "name": "Josh",
    "age": 20,
    "city": "Shen Zhen",
    "like": {
      "1": "骑车",
      "2": "爬山"
    }
  }
}
```

#### 2.2 提取name

```bash
[root@zhongjl-51-64 /tmp]# jq '.my_info.name' my_info2.json 
"Josh"
```

#### 2.3 提取 `like` 第1个值

```bash
[root@zhongjl-51-64 /tmp]# jq '.my_info.like."1"' my_info2.json
"骑车"
```

> **注：**键为数字时，需要加双引号引用。

### 3.示例三

#### 3.1 创建带数组的JSON

创建JSON名为 `my_info3.json`，内容如下：

```bash
{
  "my_info": {
    "name": "Josh",
    "age": 20,
    "city": "Shen Zhen",
    "like": {
      "1": "骑车",
      "2": "爬山"
    },
    "friends": [
      { "name": "Tom", "age": 21 },
      { "name": "Jerry", "age": 22 }
    ]
  }
}
```

#### 3.2 提取全部

```bash
[root@zhongjl-51-64 /tmp]# jq '.' my_info3.json 
{
  "my_info": {
    "name": "Josh",
    "age": 20,
    "city": "Shen Zhen",
    "like": {
      "1": "骑车",
      "2": "爬山"
    },
    "friends": [
      {
        "name": "Tom",
        "age": 21
      },
      {
        "name": "Jerry",
        "age": 22
      }
    ]
  }
}
```

#### 3.3 提取name

```bash
[root@zhongjl-51-64 /tmp]# jq '.my_info.name' my_info3.json 
"Josh"
```

#### 3.4 提取数组的第1个字段

提取 `friends` 数组的第一个朋友的 `name` 字段：

```bash
[root@zhongjl-51-64 /tmp]# jq '.my_info.friends[0].name' my_info3.json 
"Tom"
```

