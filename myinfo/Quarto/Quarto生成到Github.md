# Quarto生成Github展示

> 参考文档：
>
> https://www.aidoczh.com/quarto/docs/publishing/github-pages.html
>
> https://www.lianxh.cn/details/1338.html
>
> https://quarto.org/

## 一、Quarto介绍

Quarto 是一个支持科学和技术文档、博客、演示文稿等的工具，可以用 R Markdown、Jupyter Notebook 或纯 Markdown 编写内容。

## 二、新建Github项目

### 1.新建项目

- 项目名称为：Quarto-demo

### 2.添加.gitignore

```
/.quarto/
/_site/
```

- `/.quarto/`：忽略 **quarto** 文件，因为和网站没关系，是运行记录之类的
- `/_site/`：由于我们要在 Netlify 上发布，故需要关闭 GitHub 提供的网站发布功能

## 二.安装Quarto

### 1.[下载链接](https://quarto.org/docs/download/)

点击【下载链接】进行下载，安装步骤很简单，下一步至结束。（如果安装完，vs code无法识别到，需要重启电脑）

### 2.Quarto测试

测试`Quarto`是否安装成功，执行`quarto --version `

```
(venv) E:\>quarto --version 
1.6.39
```

## 三、创建Website站点

### 1.创建Website

```
cd E:\Quarto-demo

quarto create-project . --type website:blog
```

- **`create-project`**: 表示创建一个新的 Quarto 项目

- `.` 表示在当前路径

- **`--type website:blog`**: 指定项目的类型为 "博客网站"

**执行结果：**

Quarto 会在当前目录生成适合博客网站的文件和文件夹结构，例如：

- `index.qmd`: 网站的主页。
- `_quarto.yml`: 配置文件，用于定义网站的元信息（如标题、导航栏等）。
- `posts/`: 用于存放博客文章的目录，通常包含示例文章。



创建项目后，可编辑 `_quarto.yml` 和 `.qmd` 文件以自定义网站，使用 `quarto preview` 来实时预览网站效果，完成修改后，通过 `quarto publish` 或静态服务器部署生成的网站，其主要目的是快速搭建一个支持 Markdown 的现代博客网站。

### 2.网站树形结构

执行生成博客命令，生成的网站结构目录如下：

```
E:\Quarto-demo
├─ .gitignore         # Git忽略规则文件，用于指定不被Git追踪的文件或目录
├─ about.qmd          # 关于页面的 Quarto Markdown 文件，可能用于描述网站或项目的背景信息
├─ index.qmd          # 项目的主页或入口页面的 Quarto Markdown 文件
├─ profile.jpg        # 用户或项目的个人资料图片
├─ README.md          # 项目的自述文件，通常用于描述项目的基本信息和使用方法
├─ styles.css         # 样式表文件，用于定义项目的外观和布局
├─ _quarto.yml        # Quarto 配置文件，用于定义项目的全局配置，例如导航、主题等
└─ posts              # 文章目录，存储具体的博客文章或内容
   ├─ _metadata.yml         # 全局元数据文件，为目录下所有文章提供共享配置
   ├─ post-with-code        # 文章子目录：通常包含涉及代码的博客文章
   │  ├─ image.jpg          # 图片文件，用于展示或说明文章内容
   │  └─ index.qmd          # 具体博客文章的 Quarto Markdown 文件
   └─ welcome               # 文章子目录：可能是欢迎页面或简介文章
      ├─ index.qmd          # 欢迎页面的 Quarto Markdown 文件
      └─ thumbnail.jpg      # 缩略图，用于欢迎页面的视觉展示
```

**Quarto-demo根目录文件**

- 主要存放全局配置文件（`.gitignore`，`_quarto.yml`）、全局资源（`profile.jpg`，`styles.css`）和文档（`README.md`）。

**posts文章目录**

- 每个子目录代表一篇文章或一个专题，目录内可能包含元数据、资源（如图片）、以及内容文件（`.qmd`）。

### 3.安装Quarto插件

打开`VS Code`，安装`Quarto插件`，安装完成，重开`VS Code`客户端

![image-20241229205717112](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20241229205717112.png)



### 4.生成网页

以 `index.qmd` 为例，点击 `Preview` 按钮后终端执行相应命令，即相当于输入了命令

```
quarto preview "E:/Quarto-demo/index.qmd" --no-browser --no-watch-inputs
```

**命令分解**：

1. **`quarto preview`**
   - `quarto` 是 Quarto 的命令行工具，用于创建、编译和预览 Quarto 文档。
   - `preview` 是 Quarto 的一个子命令，用于启动本地开发服务器，实时预览指定的文件或项目。
2. **`"E:/Quarto-demo/index.qmd"`**
   - 指定要预览的文件路径，在这里是 `index.qmd` 文件，位于 `E:/Quarto-demo` 目录。
   - Quarto 会编译该文件，并在本地服务器中展示输出。
3. **`--no-browser`**
   - 阻止自动打开浏览器的行为。
   - 如果没有此选项，Quarto 默认会在预览时启动系统默认浏览器，访问本地服务器上的页面。
4. **`--no-watch-inputs`**
   - 禁用对输入文件（如 `.qmd` 文件或引用的资源文件）的自动监视。
   - 如果没有此选项，Quarto 会在检测到输入文件变化时自动重新生成和刷新预览页面。



### 5.VS Code加载Quarto: Preview

> 这是一个调试的可选项，并非必须，仅看个人习惯。
>
> 但是VS Code 必须安装Quarto插件插件

如果你希望在`VS Code`加载`Quarto: Preview终端`，可点击文件`index.qmd`在空白处，执行快捷键 `Ctrl+Shift+K+V`即可显示如下页面：

![image-20241229210241982](C:\Users\joshz\AppData\Roaming\Typora\typora-user-images\image-20241229210241982.png)

当然你也可以通过网页进行访问，例如`http://127.0.0.1:5189/`（注意：`5189`端口需要根据实际，自行更改）

## 四、Quarto配置

### 1.Quarto配置选项

支持自定义顶栏、侧边栏、选项框。在 `_quarto.yml` 文件中进行修改。

顶栏对于一个网站的访客体验来说是至关重要的，当他们进入一个新的网站，顶部栏通常是他们最先看到的地方。我们可以放置一些常用网站的图标与链接、菜单提示、搜索框、浏览模式切换等。

| 选项         | 描述                                                         |
| ------------ | ------------------------------------------------------------ |
| title        | 导航栏的标题                                                 |
| background   | 背景色，“primary”，“secondary”，“success”，“danger”，“warning”，“info”，“light”，“dark” |
| search       | 在站点导航栏或站点侧栏中添加站点搜索配置，在网页上显示为放大镜标志 |
| left / right | 相关内容在导航栏左侧或右侧显示                               |
| pinned       | 滚动页面时是否总是显示导航栏                                 |
| icon         | 标准 [Bootstrap 5 图标](https://icons.getbootstrap.com/)中的名称 |
| href         | 链接到项目或外部 URL 中包含的文件                            |
| text         | 为导航项显示的文本(默认为文档标题)                           |
| menu         | 用于填充下拉菜单的导航项列表。                               |
| collapse     | 当显示变窄时，将导航栏项折叠成汉堡包菜单(默认为 true)        |

侧边栏，可以导航帮助访客轻松找到一些博客分类，还能够显示博客的层次结构。

| 选项                   | 描述                                                         |
| ---------------------- | ------------------------------------------------------------ |
| title                  | 导航栏的标题                                                 |
| search                 | 如果顶栏已经有一个搜索框，则不会再显示在侧边栏               |
| contents               | 要显示的导航项列表                                           |
| style                  | “docked” ，侧边栏呈一个独特的背景色； “floating” ，侧边栏背景色更接近主体文本 |
| border                 | 是否在侧边栏上显示边框                                       |
| bread-crumbs           | 引导用户了解正在阅读的内容处于网站什么位置                   |
| page-navigation        | 页面底部导航到下一页(或上一页)                               |
| back-to-top-navigation | 在网站底部加入一个"回到顶部"的导航选择                       |
| page-footer            | 为网站中的所有页面提供通用页脚                               |
| reader-mode            | 是否启用阅读器模式，隐藏侧边导航和目录，提供集中阅读的体验   |



### 2.Quarto配置介绍

```
project:
  type: website               # 项目类型为网站
  output-dir: docs            # 编译输出的目录为 docs

execute:
  post-render: |              # 在渲染后执行的命令，用于替换输出文件中的特定内容
    find docs -name "*.html" -exec sed -i 's|/site_libs/|/demo/site_libs/|g' {} +
                                # 替换所有 HTML 文件中 "/site_libs/" 为 "/demo/site_libs/"，适用于托管路径修改

website:
  title: "Josh'Blog"          # 网站标题
  bread-crumbs: true          # 启用面包屑导航
  back-to-top-navigation: true # 启用返回顶部的导航
  page-footer: "© Josh Zhong 2024" # 页面底部显示的版权信息
  reader-mode: true           # 启用阅读模式，优化内容显示
  repo-url: https://github.com/joshzhong66/demo
                                # 仓库 URL，用于显示 "编辑" 和 "报告问题" 功能
  repo-actions: [edit, issue] # 在页面上显示编辑和提交问题的按钮

  navbar:                     # 网站顶部导航栏配置
    background: primary       # 导航栏背景色设置为主色
    foreground: light         # 导航栏文字设置为浅色
    pinned: true              # 固定导航栏
    search: true              # 启用导航栏搜索功能
    left:                     # 导航栏左侧内容
      - text: "主页"          # 菜单项：主页
        file: home.qmd        # 绑定的 Quarto 文件
      - text: "博客"          # 菜单项：博客
        file: blog.qmd        # 绑定的 Quarto 文件
      - text: "jupyter"       # 菜单项：Jupyter
        file: jupyter.qmd     # 绑定的 Quarto 文件
        menu:                 # 子菜单
          - text: "Latest Exercise 1"   # 子菜单项
          - file: posts/projects/Latest exercise1.qmd # 子菜单对应的 Quarto 文件
      - text: "关于我"          # 菜单项：关于我
        file: about.qmd       # 绑定的 Quarto 文件
    right:                    # 导航栏右侧内容
      - icon: github          # GitHub 图标
        menu:                 # GitHub 菜单项
        - text: Source Code   # 子菜单项：源代码
          url: https://code.com # 链接到源代码页面
        - text: Report a Bug  # 子菜单项：报告问题
          url: https://bugs.com # 链接到报告问题页面
      - icon: twitter         # Twitter 图标，链接到 Twitter
        href: https://twitter.com
      - icon: google          # Google 图标，链接到 Google
        href: http://google.com/

  sidebar:                    # 网站侧边栏配置
    - title: "博客"            # 第一个侧边栏标题
      style: docked           # 侧边栏固定样式
      type: dark              # 使用深色风格
      background: light       # 背景设置为浅色
      contents:               # 侧边栏包含的内容文件
        - index.qmd
        - techs.qmd
        - papers.qmd
        - books.qmd

    - title: "资料"            # 第二个侧边栏标题
      contents:               # 侧边栏包含的内容文件
        - references.qmd
        # navigation items   # 占位符，用于扩展导航内容

```

### 3.Quarto命令配置

```
quarto render				# 渲染整个项目 将 Quarto 项目或单独的文件从源文件（如 .qmd、.ipynb 等）渲染为最终输出格式（如 HTML、PDF、Word 等）
quarto render myfile.qmd	# 渲染单个文件
quarto render myfile.qmd --to pdf	# 渲染为指定格式
quarto preview				# 执行命令可以预览网站
quarto render --clean		# 清除现有输出并重新渲染
quarto render --incremental	# 只处理增量更新
```

## 4.添加子菜单文件

### 1.修改`_quarto.yml`

```
website:
  title: "Josh's Blog"
  bread-crumbs: true
  navbar:
    pinned: true
    search: true
    left:
      - text: "About Me"
        file: index.qmd             # about首页
      - text: "Resource Directory"
        file: resources.qmd         # 资源目录
      - text: "Project"
        menu: 
          - text: "Run Python Script"
            file: python/matplotlib_demo.qmd		# 主目录下创建python目录，并放入matplotlib_demo.qmd
          - text: "Run Python Jupyter Notebook"		
            file: jupyter_qmd/Latest_exercise1.qmd	# 所有jupyter转换到jupyter_qmd目录下，如果依赖csv也需要放入

```

### 2.编辑matplotlib_demo.qmd

````
---
title: "matplotlib demo"
format:
  html:
    code-fold: true
jupyter: python3
---

For a demonstration of a line plot on a polar axis, see @fig-polar.

```{python}
#| label: fig-polar
#| fig-cap: "A line plot on a polar axis"

import numpy as np
import matplotlib.pyplot as plt

r = np.arange(0, 2, 0.01)
theta = 2 * np.pi * r
fig, ax = plt.subplots(
  subplot_kw = {'projection': 'polar'} 
)
ax.plot(theta, r)
ax.set_rticks([0.5, 1, 1.5, 2])
ax.grid(True)
plt.show()
```
````

### 3.python执行结果

![image-20241230001953063](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20241230001953063.png)



### 4.编辑Latest_exercise1.qmd

将`1_CO2-data.csv`与`NH.Ts+dSST.csv`放入`Latest_exercise1.qmd`同一目录

````
---
jupyter: python3
---

```{python}
#| collapsed: true
# -*- coding: utf-8 -*-
# 导入所需库
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from lets_plot import *
```

```{python}

# 设置 Lets-Plot 显示
LetsPlot.setup_html(no_js=True)

# ------------------------ PART 1: 加载和查看数据 ------------------------
# 读取 NH.Ts+dSST.csv (北半球气温异常数据)
temp_df = pd.read_csv("NH.Ts+dSST.csv", skiprows=1, na_values="***")

# 清理列名
temp_df.columns = temp_df.columns.str.strip()

# 查看数据前几行
print("气温异常数据 (NH.Ts+dSST.csv):")
print(temp_df.head())

# 读取 1_CO2-data.csv (CO2 数据)
co2_df = pd.read_csv("1_CO2-data.csv")

# 查看 CO2 数据
print("CO2 数据 (1_CO2-data.csv):")
print(co2_df.head())
```

```{python}

# ------------------------ PART 2: 温度异常时序图 ------------------------
# 将年份作为索引
temp_df = temp_df.set_index("Year")

# 绘制一个月的温度异常图（例如: 1月）
month = "Jan"
plt.figure(figsize=(10, 5))
plt.axhline(0, color="orange", linestyle="--")
plt.annotate("1951–1980 average", xy=(0.7, -0.2), xycoords=("axes fraction", "data"))
temp_df[month].plot()
plt.title(f"Average Temperature Anomaly in {month} (1880—{temp_df.index.max()})")
plt.ylabel("Temperature anomaly (°C)")
plt.xlabel("Year")
plt.show()
```

```{python}

# 绘制四个季节的温度异常图
seasons = ["DJF", "MAM", "JJA", "SON"]
for season in seasons:
    plt.figure(figsize=(10, 5))
    plt.axhline(0, color="orange", linestyle="--")
    plt.annotate("1951–1980 average", xy=(0.7, -0.2), xycoords=("axes fraction", "data"))
    temp_df[season].plot()
    plt.title(f"Average Temperature Anomaly in {season} (1880—{temp_df.index.max()})")
    plt.ylabel("Temperature anomaly (°C)")
    plt.xlabel("Year")
    plt.show()
```

```{python}

# ------------------------ PART 3: CO₂ 数据的时序图 ------------------------
# 筛选1960年后的数据
co2_df = co2_df[co2_df["Year"] >= 1960]

# 绘制 CO₂ 时间序列图
plt.figure(figsize=(10, 5))
plt.plot(co2_df["Year"] + co2_df["Month"] / 12, co2_df["Interpolated"], label="Interpolated CO₂")
plt.plot(co2_df["Year"] + co2_df["Month"] / 12, co2_df["Trend"], label="Trend CO₂")
plt.title("CO₂ Levels Over Time (from 1960)")
plt.xlabel("Year")
plt.ylabel("CO₂ concentration (ppm)")
plt.legend()
plt.show()
```

```{python}

# ------------------------ PART 4: 温度和 CO₂ 数据相关性分析 ------------------------
# 筛选 CO₂ 数据中的6月数据
co2_june = co2_df[co2_df["Month"] == 6]

# 合并 CO₂ 数据和温度数据（6月）
merged_df = pd.merge(co2_june, temp_df, left_on="Year", right_index=True)
print("合并后的 CO₂ 和温度数据:")
print(merged_df[["Year", "Interpolated", "Jun"]].head())

# 计算相关系数
correlation = merged_df[["Interpolated", "Jun"]].corr()
print("CO₂ 浓度与 6 月温度异常的相关性:")
print(correlation)

# 绘制散点图 (CO₂ 和温度的关系)
(
    ggplot(merged_df, aes(x="Jun", y="Interpolated"))
    + geom_point(color="blue", size=3)
    + labs(
        title="Scatterplot of Temperature Anomalies vs CO₂ Levels",
        x="Temperature Anomaly in June (°C)",
        y="CO₂ Concentration (ppm)"
    )
)
```



````

### 5.jupyter执行结果

![image-20241230002311915](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20241230002311915.png)



## 五.[GitHub Pages介绍](https://www.aidoczh.com/quarto/docs/publishing/github-pages.html)

GitHub Pages 是一个网站托管服务，使您能够基于托管在 GitHub 仓库中的源代码发布内容。

有三种方法可以将 Quarto 网站和文档发布到 GitHub Pages：

1. **渲染到 `docs`**：在本地计算机上渲染网站到 `docs` 目录，将渲染后的网站提交到 GitHub，然后配置您的 GitHub 仓库从 `docs` 目录发布。
2. **quarto publish**：使用 `quarto publish` 命令发布本地渲染的内容。
3. **GitHub Action** 使用 [GitHub Action](https://www.aidoczh.com/quarto/docs/publishing/github-pages.html#github-action) 自动渲染您的文件（单个 Quarto 文档或 Quarto 项目），并在您推送源代码更改到仓库时发布生成的内容。

## 六.Github托管Website

以下是三种托管方式，可以任选其一，这边使用`渲染到docs`，以下是三种步骤介绍：

### 1.渲染到 `docs`

#### 1.修改`_quarto.yml`

```
project:
  type: website
  output-dir: docs		# 添加输出目录
```

#### 2.新建`.nojekyll` 文件

直接在根目录新建文件，改为`.nojekyll`

### 2.Quarto Publish

此种方式会使用两个分支 ，分别是`main` 和 `gh-pages`

- `main` 分支：项目的默认分支，用于存储项目的源代码、Quarto 配置文件（如 `_quarto.yml`）以及未渲染的内容（如 `.qmd` 和 `.ipynb` 文件）
  - `_quarto.yml`、`about.qmd`、`home.qmd`、`posts/` 目录中的 Markdown 文件
- `gh-pages` 分支
  - 用于 GitHub Pages 部署的分支，存储的是由 Quarto 渲染后的 HTML 文件以及相关资源文件。
  - 专门用于托管和展示网站。
  - 静态资源文件：如图片、CSS、JavaScript 文件（位于 `site_libs` 目录中）

执行 `quarto publish` 命令以发布到 GitHub Pages

```
quarto publish gh-pages
```

>当配置了源分支并更新了 `.gitignore`，导航到项目/git 仓库所在的目录，确保不在 `gh-pages` 分支上

### 3.GitHub Action

未做测试

当上述托管选项已设置完成，即可将其提交发布到Github Pages上进行页面展示

### 5.发布到GitHub Pages

提交仓库代码即可



### 5.修改page

点击-【Github项目名称】--【设置】--【Pages】，修改分支为【Main】，目录为【docs】，保存即可

![image-20241229065250242](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20241229065250242.png)

### 6.访问域名

托管的域名，一般是`github_username.github.io`

![image-20241229065645627](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20241229065645627.png)

### 7.域名地址

生成的域名地址为一般为`Github用户名.github.io/项目名称`，例如：

```
https://joshzhong66.github.io/demo/
```



![image-20241229065729913](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20241229065729913.png)

### 6.域名访问展示

![image-20241229065850852](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20241229065850852.png)

## 七、转jupyter为qmd

```
cd notebooks
quarto convert "Latest exercise1.ipynb"  #文件有空格，需要加冒号

(venv) E:\demo\notebooks>quarto convert "Latest exercise1.ipynb"
Converted to Latest exercise1.qmd

cd notebooks   	#进入jupyter源文件目录 
quarto convert "Latest exercise1.ipynb" -o ../jupyter_qmd/Latest_exercise1.qmd		# 转换该文件到../jupyter_qmd


```

- 如果需要使用到csv文件，将Latest_exercise1.qmd放到qmd同一目录下

