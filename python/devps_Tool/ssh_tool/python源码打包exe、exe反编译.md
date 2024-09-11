### 一、python3打包为exe文件
这里有个hello.py文件
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519455037-647fae9f-5f21-4470-b733-f657f4deefb2.png#averageHue=%23d1c677&clientId=uff8195c8-89a9-4&from=paste&height=72&id=uf8c0fc27&originHeight=143&originWidth=1477&originalType=binary&ratio=2&rotation=0&showTitle=false&size=14886&status=done&style=none&taskId=udbab826c-3854-4177-aa89-2a1f0085ab0&title=&width=738.5)

step1：安装pyinstaller包
```
pip install pyinstaller
```
step2：在cmd中进入hello.py文件所在路径。可以直接在hello.py文件路径下直接进入cmd
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519565482-fb7d7755-07d3-487f-9696-d115e26bc1c9.png#averageHue=%233d3b3a&clientId=uff8195c8-89a9-4&from=paste&height=141&id=ub6a8a618&originHeight=281&originWidth=679&originalType=binary&ratio=2&rotation=0&showTitle=false&size=22024&status=done&style=none&taskId=u89e8c9a0-0edc-4203-9101-4743ad3ac77&title=&width=339.5)
step3：打包生成exe文件，使用如下命令，将其打包为单一exe（去掉-F则不是单一exe，-w是不生成window窗口，--name是自定义exe包的命名）
```
pyinstaller -F -w hello.py --name hello
```
生成了build，dist 和Hello.spec三个文件
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519662079-441882a7-403f-40b0-9702-1fd713df40d8.png#averageHue=%23fbfaf9&clientId=uff8195c8-89a9-4&from=paste&height=127&id=u477708f2&originHeight=253&originWidth=1237&originalType=binary&ratio=2&rotation=0&showTitle=false&size=22376&status=done&style=none&taskId=ufe8a2081-7e60-46fa-9ae4-477c2a43d79&title=&width=618.5)
exe文件在dist文件夹中，双击即可运行
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519686507-d6c8f37b-a093-42ea-aa1f-d83ac9517377.png#averageHue=%23fdfdfc&clientId=uff8195c8-89a9-4&from=paste&height=85&id=uecb81c5f&originHeight=169&originWidth=1111&originalType=binary&ratio=2&rotation=0&showTitle=false&size=12492&status=done&style=none&taskId=udc8df03a-aeb2-41b8-93e2-d1b33c5063c&title=&width=555.5)
**注：如果要打包多个文件，如sh脚本文件，执行如下命令：**
```
pyinstaller -F -w --add-data "script1.sh:." hello.py --name hello
```
**同时在Pyhton文件中，需操作以下代码：**
```
import os

sh_file_path = os.path.join(os.path.dirname(__file__), 'script.sh')
```
       这行代码首先使用 os.path.dirname(__file__) 获取当前 Python 脚本的目录路径，然后使用 os.path.join() 函数将该路径与 'additional_script.sh' 文件名结合起来，生成了一个完整的路径 sh_file_path，指向同目录下的 additional_script.sh 文件。

### 二、python3将exe文件进行反编译为源码
exe反编译工具：pyinstxtractor.py下载：[https://github.com/extremecoders-re/pyinstxtractor](https://github.com/extremecoders-re/pyinstxtractor)

将pyinstxtractor.py放到exe文件相同目录
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519751813-0a2fd82c-a05e-4678-82a4-451e85445334.png#averageHue=%23f2573a&clientId=uff8195c8-89a9-4&from=paste&height=114&id=u4db1b22d&originHeight=227&originWidth=1111&originalType=binary&ratio=2&rotation=0&showTitle=false&size=19943&status=done&style=none&taskId=u0369fc1b-c8c7-4c67-95a9-e3f6e44230d&title=&width=555.5)
接下来，在该路径的cmd中执行下面命令
```
python pyinstxtractor.py hello.exe
```
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519808503-ed93fec4-dcb2-4c02-80db-9df886dd2772.png#averageHue=%2316110f&clientId=uff8195c8-89a9-4&from=paste&height=237&id=u2c12a552&originHeight=473&originWidth=1353&originalType=binary&ratio=2&rotation=0&showTitle=false&size=46615&status=done&style=none&taskId=u9e005bbf-87f9-4144-bfe1-573d7d72db8&title=&width=676.5)
成功解压(反编译)，多了个Hello.exe_extracted文件夹
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519825741-7dfd0fdf-cd3d-4c3c-bafb-eb0420aceb44.png#averageHue=%23fbf7f6&clientId=uff8195c8-89a9-4&from=paste&height=131&id=u4e0f7158&originHeight=261&originWidth=1061&originalType=binary&ratio=2&rotation=0&showTitle=false&size=25767&status=done&style=none&taskId=u3dee7dff-8cb6-41db-a1dc-930ca06e5d4&title=&width=530.5)
进入Hello.exe_extracted文件夹，有个hello文件，此为被解压出的pyc文件，需通过
![image.png](https://cdn.nlark.com/yuque/0/2024/png/43116951/1711519882702-0f6a9753-cf6a-4836-92da-b7990ce15731.png#averageHue=%23f9f6f6&clientId=uff8195c8-89a9-4&from=paste&height=165&id=u7b004c8e&originHeight=329&originWidth=1131&originalType=binary&ratio=2&rotation=0&showTitle=false&size=38144&status=done&style=none&taskId=u38f76f1d-624e-4f78-9a47-1da84f1f930&title=&width=565.5)

接下来尝试对hello文件反编译
首先安装反编译uncompyle6包**（注：3.9以上版本无法使用）**
```
pip install uncompyle6
```
需将hello文件添加.pyc后缀，不然不能编译。运行下面代码反编译hello.pyc文件。在该路径的cmd中运行
```
uncompyle6 hello.pyc > hello.py
```

