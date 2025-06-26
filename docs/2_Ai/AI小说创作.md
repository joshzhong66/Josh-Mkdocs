# AI小说创作

## 一、Prompt

```
设计一个个结构清晰、跌宕起伏，引人入胜，拥有冲突和障碍的猎奇故事解说文案大纲。
主线剧情具备起承转合的连贯性和引人入胜的吸引力。
利用夸张和情绪性修辞，提升文本感染力，丰富的感官描写，让读者感同身受。
简单通顺的句式，提高可读性，感叹句、反问句表达强烈情感，排比句式，增加文本节奏感，断句技巧，突出剧情转折。
短小精悍的句子，强调情节的紧张，故事结局要违背真实生活，需要生后中不常见的结局，结局要合理，前后呼应，把人性的丑恶元素融入进去，必须符合起点中文网平台的社区规范。

故事叙述是一个剑仙的故事，主角定为穿越的男子，目前15岁，因一次意外，从此踏上修仙之路。

创作，要求不少于6个故事情节，每个情节要有爽点，反转剧情不少于4处。
```



## 二、RWKV-Runner

>Github开源地址：https://github.com/josStorer/RWKV-Runner

### 1.目标

**网文小说创作**

### 2.我的电脑配置

- CPU：i5-8500（6核6线程）
- 显卡：RX580 8GB（DirectML 支持）
- 内存：32GB

### 3.推荐模型配置

| 模型选项             | 说明                                              | 推荐程度 |
| -------------------- | ------------------------------------------------- | -------- |
| `GPU-6G-3B-CN` ✅     | 中文模型，3B 参数，显存需求约 5~6GB，适合 RX580   | ⭐⭐⭐⭐     |
| `GPU-8G-3B-CN` ✅     | 中文 + 更高精度，适配 8G 显存显卡，适合长对话写作 | ⭐⭐⭐⭐⭐    |
| `GPU-2G-1B5-World` ✅ | 通用英文模型，适配显存较小显卡，轻量级            | ⭐⭐⭐      |

`GPU-6G`、`GPU-8G` 等：表示所需显存（≈估算）

`1B5`, `3B`, `7B`：参数规模，数字越大越“聪明”

`CN`：专为中文训练，适合网文/对话/小说

`World`：多语种或英文为主，泛用模型

### 4.下载模型

选择GPU-8G-3B-CN

![image-20250619142508580](http://pic.its.sunline.cn/i/0/2025/06/19/ni8z8b-0.png)

### 5.更新依赖

![image-20250619142843237](http://pic.its.sunline.cn/i/0/2025/06/19/nkhant-0.png)



## 三、AI-Writer

测试总结：只能写短篇内容（500字左右），根据开头输入的提示（一句话、一个关键词），然后续写到500字

>https://github.com/BlinkDL/AI-Writer

### 1.克隆代码到本地

```
git clone https://github.com/BlinkDL/AI-Writer.git
```

### 2.下载对应的显卡模型

下载地址：https://github.com/BlinkDL/AI-Writer/releases

### 3.下载python3.8

官方下载地址：https://www.python.org/downloads/release/python-380/

Josh_Download：https://file.joshzhong.top/1_BaseSoftware/6_Python/python-3.8.0-amd64.exe

### 4.安装Python3.8

Python3.8——默认安装目录

>```
>C:\Users\joshz\AppData\Local\Programs\Python\Python38
>```

![image-20250619105613442](http://pic.its.sunline.cn/i/0/2025/06/19/hen0tb-0.png)



### 5.添加环境变量

复制Python38的安装目录路径

```
C:\Users\joshz\AppData\Local\Programs\Python\Python38
```

添加到系统环境变量

![image-20250619110452394](http://pic.its.sunline.cn/i/0/2025/06/19/i7naio-0.png)



因存在多个版本，，修改Python38目录下的`python.exe`为`python3.8.0`，这样比较好区分版本执行，如下：

```
c:\Windows\System32>python
Python 3.12.7 (tags/v3.12.7:0b05ead, Oct  1 2024, 03:06:41) [MSC v.1941 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
>>> ^Z


c:\Windows\System32>python3.8.0
Python 3.8.0 (tags/v3.8.0:fa919fd, Oct 14 2019, 19:37:50) [MSC v.1916 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
```

### 6.VS Code设置

创建test.py

```
import sys
print(sys.executable)
```

再点击【查看】-【命令面板】-【Python:选择解释器】，点击输入解释器路径，复制以下路径，回车

```
C:\\Users\\joshz\\AppData\\Local\\Programs\\Python\\Python38\\python3.8.0.exe
```

执行test.py脚本，正常会显示当前使用的python版本为3.8

```
C:\Users\joshz\AppData\Local\Programs\Python\Python38\python3.8.0.exe
```



### 4.A/I卡跑模型

#### 1.安装python依赖

A/I卡指的是AMD、Inter的显卡，如果是使用CPU跑，也是相同，同样安装依赖torch、onnxruntime-directml，执行如下命令：

```
C:\Users\joshz\AppData\Local\Programs\Python\Python38\python3.8.0.exe -m pip install torch onnxruntime-directml
```

#### 2.下载代码和模型

下载[A.-.-wangwen-2022-02-15.zip](https://github.com/BlinkDL/AI-Writer/releases/download/v2022-02-15-A/A.-.-wangwen-2022-02-15.zip)、[Source code(zip)](https://github.com/BlinkDL/AI-Writer/archive/refs/tags/v2022-02-15-A.zip)

#### 3.解压移动文件

Source_code则是代码文件，解压放到代码目录即可

A.-.-wangwen-2022-02-15解压后，将文件放到model目录下

![image-20250619144032704](http://pic.its.sunline.cn/i/0/2025/06/19/nrk5ep-0.png)

#### 4.执行代码

打开run.py，修改代码

```
RUN_DEVICE = 'dml' # gpu 或 dml 或 cpu

MODEL_NAME = 'model/wangwen-2022-02-15' # 模型名
WORD_NAME = 'model/wangwen-2022-02-15' # 这个也修改

参数修改参考：
（我这边是A卡，选择dml）
# gpu：只支持 nvidia 显卡，速度最快，需 cuda+cudnn
# dml：支持 amd / intel / nvidia 显卡，需不同模型，需 pip install onnxruntime-directml 然后在 run.py 和 server.py 设置为 dml 模式
# cpu：没显卡就选它，但也用 nvidia 卡的模型
```



```
NUM_OF_RUNS = 999 # 写多少遍
LENGTH_OF_EACH = 512 # 每次写多少字

context = "这是一颗"
```

> ```
> NUM_OF_RUNS和LENGTH_OF_EACH
> # 你需要多少字内容，并且根据提供的开头内容，写多少次
> ```
>
> 定义写的内容：

>```
># 开头非常重要。开头需创造剧情点。开头文笔越好，续写就越好。开头乱写，续写也乱写。
>```

>多行开头定义：
>
>```
># 多行的开头这样输入：
># context = """
># 这几天心里颇不宁静。今晚在院子里坐着乘凉，忽然想起日日走过的荷塘，在这满月的光里，总该另有一番样子吧。月亮渐渐地升高了，墙外马路上孩子们的欢笑，已经听不见了；妻在屋里拍着闰儿，迷迷糊糊地哼着眠歌。我悄悄地披了大衫，带上门出去。
># 沿着荷塘，是一条曲折的小煤屑路。这是一条幽僻的路；白天也少人走，夜晚更加寂寞。荷塘四面，长着许多树，蓊蓊郁郁的。路的一旁，是些杨柳，和一些不知道名字的树。没有月光的晚上，这路上阴森森的，有些怕人。今晚却很好，虽然月光也还是淡淡的。
># 路上只我一个人，背着手踱着。这一
># """
>```



