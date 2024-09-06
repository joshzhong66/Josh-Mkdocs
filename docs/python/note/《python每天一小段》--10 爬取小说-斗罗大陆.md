## 爬取小说斗罗大陆
@[toc]
以下是根据提供的内容进行扩展和整理的《python每天一小段》博客文章的示例：

**章节效果：**
![在这里插入图片描述](https://img-blog.csdnimg.cn/direct/850fbbd7733242c1baef0a7e47c14efc.png)






在本篇文章中，将使用Python编写一个简单的爬虫程序，用于从小说网站上爬取《斗罗大陆》小说的章节内容，并将其保存到本地文件中。我们将使用requests库发送HTTP请求，lxml库解析HTML响应，并使用XPath表达式来提取所需的数据。


### （1）安装依赖库

```bash
pip install lxml
```

### （2）步骤概述

1. **获取代理头**：通过检查网页头部信息，获取User-Agent，用于伪装爬虫代码的访问信息。
2. **XPath安装使用**：安装XPath Helper扩展程序，并使用XPath表达式剔除HTML标签，提取小说文字内容。
3. **获取下一章内容**：通过检查网页元素，找到下一章的链接，并使用XPath表达式来获取下一章的URL。






### （3）爬虫准备步骤

url为小说的第一章，网页地址：**https://www.51shucheng.net/wangluo/douluodalu/21750.html**

![在这里插入图片描述](https://img-blog.csdnimg.cn/e399fa7f22e448688fb7bbe3fdf97dfd.png)

<font color=green size=4>**获取代理头：**

1. 获取代理头的作用主要是用于伪装代码访问的信息

2. 在网页空白处，鼠标右击点击检查，打开界面在network选项，使用ctrl+r刷新一下network的信息，截图中**2**的任意位置，鼠标左击，可以看到headers头部信息，找到User-Agent，复制该信息，用于代码：

```bash
User-Agent:
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/6468d5e1f2a5424fb6280b74fd1db240.png)

<font color=green size=4>**xpath安装使用**


1. google浏览器安装扩展程序:XPath Helper（可将快捷键设置为ctrl+u，没设置不知道具体快捷键，打不开黑框）
![在这里插入图片描述](https://img-blog.csdnimg.cn/df9cc9bc209c42c6a17c6aebc86e7dc2.png)

<font color=green size=4>在小说网页界面，按ctrl+uxpath的小黑框，输入：<font color=gree size=4>string(//div/p)

<font color=blue size=4>string(//div/p)是通过网页截取，因为不懂html，就粗略过一遍

![在这里插入图片描述](https://img-blog.csdnimg.cn/fd26b533bf9b4512ad2ee7bfdb653213.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/6d48a6d009bf4bd081e305667ea7d0f8.png)

![在这里插入图片描述](https://img-blog.csdnimg.cn/4f42bf72bcb147b9ae95e03cac1aaefa.png)




<font color=green size=4> xpath配合lxml模块，用于剔除html标签，以及底部的评论，剩下就是小说文字。


![在这里插入图片描述](https://img-blog.csdnimg.cn/963de33f78284fde8af04de20826956d.png)




<font color=green size=4>**获取下一章内容：**

<font color=blue size=4>在下一章处，鼠标右击点击检查

![在这里插入图片描述](https://img-blog.csdnimg.cn/d727a1a4ca2b4681b14fdd8dfc2e05a5.png)

<font color=blue size=4>在elements处，找到下一章的链接，
![在这里插入图片描述](https://img-blog.csdnimg.cn/aa392d2371ae4018a107576d2d150b12.png)
<font color=blue size=4>鼠标右击Copy->Copy Xpath
![在这里插入图片描述](https://img-blog.csdnimg.cn/c0737d02ee7b4ecf93d0d80691a32ca1.png)
<font color=blue size=4>粘贴xpath查看获取的具体内容是否正确，显示的时下一章的主题即可。

<font color=blue size=4>使用XPath表达式来从HTML页面中查找下一章链接的URL

```python
next_chapter_url = e.xpath('//*[@id="BookNext"]/@href')
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/2e53ef8039e64ca7b889716617aa094a.png)




### （4）爬虫代码实现

```python
#首先，我们导入所需的库：
import requests
from lxml import etree
from urllib.parse import urljoin

#然后，我们定义初始URL和一个循环，用于遍历每一章节：
url = 'https://www.51shucheng.net/wangluo/douluodalu/21750.html'

while True:
    # 发送GET请求
    resp = requests.get(url, headers=headers)
    
    # 解析HTML响应
    e = etree.HTML(resp.text)
    
    # 提取章节标题和内容
    info = ' '.join(e.xpath('//div/p//text()'))
    title = e.xpath('//h1/text()')[0]
    
    # 打印和保存章节内容
    print(title)
    with open('斗罗大陆.txt', 'a', encoding='utf-8') as f:
        f.write(title + '\n\n' + info + '\n\n')
    
    # 获取下一章的URL
    next_chapter_url = e.xpath('//*[@id="BookNext"]/@href')
    if not next_chapter_url:
        print("没有更多章节可用。")
        break
    
    # 更新URL
    url = urljoin(url, next_chapter_url[0])
```

在代码中，使用`requests.get()`发送GET请求，并使用`headers`参数传递代理头信息。然后，使用lxml库的`etree.HTML()`函数解析HTML响应，以便我们可以使用XPath表达式提取所需的数据。

我们使用XPath表达式 `//div/p//text()` 提取章节内容，并使用 `//h1/text()` 提取章节标题。然后，我们打印章节标题，并将章节标题和内容写入到名为 `斗罗大陆.txt` 的文件中。

接下来，我们使用XPath表达式 `//*[@id="BookNext"]/@href` 获取下一章的URL，并使用`urljoin()`函数将相对URL转换为绝对URL，以确保正确构建URL。

最后，通过循环继续处理下一章，直到没有更多章节可用。

### （5）执行结果

在代码执行完成后，我们将在控制台上看到每一章的标题，并将所有章节的标题和内容保存在 `斗罗大陆.txt` 文件中。

可以根据需要对代码进行修改和优化，例如添加异常处理、设置请求延迟等。

![在这里插入图片描述](https://img-blog.csdnimg.cn/direct/069545631f44444ba38ee47851c819e2.png)

**小说内容：**
![在这里插入图片描述](https://img-blog.csdnimg.cn/direct/57d5df4a163f4a4bb16375bd7c099229.png)