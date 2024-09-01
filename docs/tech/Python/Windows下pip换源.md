# Windows下pip换源



在Windows环境下，你可以通过修改pip配置文件来更换源。以下是步骤和示例代码：

1. 找到或创建pip配置文件：
   - 对于用户级别的配置，文件通常位于%APPDATA%\pip\pip.ini。
   - 对于系统级别的配置，文件通常位于%PROGRAMFILES%\pip\pip.ini。

2. 编辑配置文件，添加以下内容来指定新的源：
```bash
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
```
这里以清华大学的源为例。你可以根据需要替换为其他源，例如阿里云、豆瓣等。
#清华大学：[https://pypi.tuna.tsinghua.edu.cn/simple](https://pypi.tuna.tsinghua.edu.cn/simple)/
#阿里云：[http://mirrors.aliyun.com/pypi/simple/](http://mirrors.aliyun.com/pypi/simple/)
#豆瓣：[http://pypi.douban.com/simple](http://pypi.douban.com/simple/)/
#中国科技大学:[https://pypi.mirrors.ustc.edu.cn/simple/](https://pypi.mirrors.ustc.edu.cn/simple/)
#百度：[https://mirror.baidu.com/pypi/simple](https://mirror.baidu.com/pypi/simple)

3. 保存配置文件。

4. 之后使用pip时，它将会自动使用新配置的源。

如果你想临时使用其他源，可以在pip命令中使用--index-url选项：
```bash
pip install --index-url https://pypi.tuna.tsinghua.edu.cn/simple some-package
```
替换some-package为你想要安装的包名。

