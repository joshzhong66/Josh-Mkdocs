# Bat结合AuthHotkey脚本实现鼠标自动重启vpn



## 一、安装AuthHotkey

下载地址：https://www.autohotkey.com/

安装说明：1.1版本和2.0版本这两个版本都需要下载，因为有些脚本命令不支持2.0版本，下载顺序无影响。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/16/b52f051c940da235b4aefd3e66dc6dd7-image-20240716004347770-e27d90.png" alt="image-20240716004347770" style="zoom:50%;" />



## 二、使用AuthHotkey

打开`C:\Program Files\AutoHotkey`目录下的`WindowSpy.ahk`执行程序，该程序主要用来获取某个控件的所在位置，通过鼠标移动到“断开连接”按钮位置上，获取对应的`Window`坐标为 `300,130` ：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/16/1fa9dbc3dea6ea253dd94705e751cced-image-20240716202443215-5af282.png" alt="image-20240716202443215" style="zoom: 50%;" />

> 在 AutoHotkey 的 Window Spy 工具中，这些信息分别表示当前鼠标位置相对于不同参考点的坐标。具体含义如下：
>
> - **Screen：**当前鼠标位置相对于整个屏幕左上角的坐标。
> - **Window：**当前鼠标位置相对于当前活动窗口左上角的坐标。
> - **Client：**当前鼠标位置相对于当前活动窗口的客户区（不包括标题栏和边框）的左上角的坐标。
>
> 这些坐标对于定位控件或元素非常有用。以下是它们的具体作用：
>
> - **Screen 坐标：**
>
>   `Screen: 787, 881` 表示鼠标相对于整个屏幕左上角的坐标为 (787, 881)。这是全局坐标，可以用来定位屏幕上的任何位置。
>
> - **Window 坐标：**
>
>   `Window: 188, 815` 表示鼠标相对于当前活动窗口左上角的坐标为 (188, 815)。这是窗口相对坐标，用于在当前窗口内定位元素。
>
> - **Client 坐标：**
>
>   `Client: 180, 784 (default)` 表示鼠标相对于当前活动窗口的客户区左上角的坐标为 (180, 784)。客户区不包括窗口的标题栏和边框，这是窗口内的实际工作区域。



## 三、配置bat脚本

`check_website.bat`内容如下：

```bash
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 失败次数
set fail_count=1

:: 重置次数
set ahk_fail_count=1

:: 最大重试次数
set max_retries=20

set /p = < nul > status_log.txt

:loop
echo.
set /p ="正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F..." < nul

echo.
curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt

::type result.txt
set /p status=<result.txt

set /p ="收到的状态码：!status!" < nul
set /p ="收到的状态码：!status!" < nul >> status_log.txt
echo.
echo.  >> status_log.txt
echo.  >> status_log.txt

if not "!status!"=="200" (
    echo 状态码不是200，启动AutoHotkey脚本...
    start "" "C:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\Users\Administrator\Desktop\check_vpn_window_and_click.ahk"
    timeout /t 40

    if "%ahk_fail_count%"=="1" (
        echo AutoHotkey脚本刚开始启动，发送一条通知...
        curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt
        set /p status=<result.txt
        curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Now Status code: !status!. AWS VPN has been reconnected.\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f
        echo.
    )

    set /a ahk_fail_count+=1

    if %ahk_fail_count% geq %max_retries% (
        echo AutoHotkey脚本启动次数达到%max_retries%次，检查是否需要发送通知...
        curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Now Status code: !status!. AWS VPN has been reconnected multiple times.\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f
        set ahk_fail_count=1
        echo.
    )
    
    if not "%fail_count%"=="1" (
        echo 当前失败次数：%fail_count%
    )else (
        echo 当前失败次数：0或1
    )
    set /a fail_count+=1

)else (
    set fail_count=1
    set ahk_fail_count=1
)

set /p ="等待1分钟后重新检测..." < nul
echo.
timeout /t 60

goto loop

goto :eof
```

### 1.脚本说明

- 首先定义了三个变量，分别为`fail_count`、`ahk_fail_count`、`max_retries`，其值分别为`1`、`1`、`20`，`fail_count`变量用于显示连续失败了多少次，`max_retries`变量用于定义最大失败次数后的通知信息，`ahk_fail_count`变量用于判断连续失败的次数是否超过了`max_retries`变量从而发起通知；
- 创建一个空的日志文件`status_log.txt`，用于存放每次循环后的状态码输出信息；
- 开始循环脚本，首先开始检测网址，将检测后的状态码整数重定向到`result.txt`文件内，然后读取文件内的第一行文本并将其存储到变量 `status` ，并将将收到的状态码输出信息追加到日志文件`status_log.txt`内；
- 开始执行if语句：
  - 如果状态码不为200，即没有成功访问到网址，则启动AutoHotkey脚本，中间暂停40s，目的是先让AutoHotkey脚本运行完成后再接着执行批处理脚本；
    - 如果是第一次刚启动AutoHotkey脚本，在脚本运行完成后，再次检测网址并重新赋值给变量 `status`，然后给企微发送通知消息，便于知道网页是否已经恢复正常，同时回显信息中输出目前连续失败的次数；
    - 如果不是第一次启动AutoHotkey脚本，也就是已经第一次启动AutoHotkey脚本了，同时连续访问失败的次数还未超过最大次数，那么就不需要执行后面的命令，重新循环；
    - 如果启动AutoHotkey脚本的次数连续超过了最大失败次数，也就是变量`ahk_fail_count`超过了变量``max_retries`，那么就给企微发送通知消息，提示网页已经重启到了最大失败次数还是失败，手动打开后台查看；
  - 如果状态码为200，即成功访问到网址，那就不需要启动AutoHotkey脚本，重新循环，同时把变量`max_retries`和变量`ahk_fail_count`重新赋值为初始值。

### 2.命令解释

- `chcp 936`：表示cmd将使用`简体中文GKB`，`65001`则是使用`utf-8`编码（在文本编辑器中编辑批处理文件，确保文件编码设置为`ANSI`或与`chcp`命令设置相同的代码页）。

  使用notepad形式打开右下角可以查看：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/16/aba97c0322f1d0fd65cbe54a407fd30d-image-20240716112604166-7f2125.png" alt="image-20240716112604166" style="zoom:33%;" />

- `set /p = < nul > status_log.txt`：这条命令的效果是创建一个空的 `status_log.txt` 文件（如果文件已经存在，则清空它的内容）。

  - `set /p`：`set` 命令用于设置或显示环境变量，`/p` 选项用于提示用户输入一个值并将其赋值给指定的变量。在这种情况下，没有指定变量名，意味着将空输入赋值给一个未命名的变量。
  - `< nul`：这个部分将标准输入重定向到 `nul` 设备，这是一种特殊设备，表示“空”输入。因此，`set /p =` 将读取 `nul` 设备的内容（即空输入）。
  - `> status_log.txt`：这个部分将标准输出重定向到 `status_log.txt` 文件。因为 `set /p =` 没有产生任何输出，所以 `status_log.txt` 将是一个空文件。

- `set /p ="正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F..." < nul`：`set /p` 命令通常用于在批处理脚本中提示用户输入。但是，结合 `< nul` 使用，它可以在不等待用户输入的情况下输出一行文本。这在需要显示提示或信息但不需要用户输入的情况下非常有用。

  - `set /p =`：设置一个变量的值，`/p` 表示提示用户输入。
  - `"正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F..."`：要显示的提示信息。
  - `< nul`：重定向标准输入到 `nul`，这样命令会立即继续而不会等待用户输入。

- `curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt`：这条代码使用 `curl` 命令来访问一个 URL，并将 HTTP 响应代码保存到一个文件 `result.txt` 中。

  - `-s`：以静默模式运行，不显示进度条或错误信息。
  - `-o NUL`：将下载的内容重定向到 `NUL`（在 Windows 上相当于 `/dev/null`，即不保存任何内容）。
  - `-w "%%{http_code}"`：指定输出格式，仅显示 HTTP 响应代码。
  - `https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F`：要访问的 URL。
  - `> result.txt`：将输出（HTTP 响应代码）重定向到文件 `result.txt`。

- `type result.txt`：是一个在命令提示符（CMD）或批处理脚本中用来显示指定文件内容的命令。

  - `type`：是一个用于显示文件内容的命令。
  - `result.txt`：是要显示内容的文件名。

  执行 `type result.txt` 将会在命令行中显示 `result.txt` 文件的全部内容。这个命令通常用于查看文本文件的内容，特别是在需要快速检查文件内容而不用打开编辑器的情况下很有用。

- `set /p status=<result.txt`：是一个在批处理脚本中用来从文件中读取一行文本并将其存储到变量 `status` 中的命令。

  - `set /p status=`：这条命令使用 `set /p` 命令来从输入设备（通常是键盘或文件）读取数据，并将其存储到变量 `status` 中。
  - `<result.txt`：这部分指示命令从 `result.txt` 文件中读取数据，`<` 符号用于重定向文件的内容作为命令的输入。

  执行这条命令后，`status` 变量将包含 `result.txt` 文件中的第一行内容。

- `if not "%status%"=="200"`：判断状态码是否为200，如果不是200，则需要执行重启vpn的autohotkey脚本，然后判断重连次数是否超过5次，若是则发送通知，使用 `curl` 发送POST请求通知服务状态，如果状态码是200，说明网页正常访问，重新执行循环。

- `curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f`：这条命令使用 `curl` 发送一个 HTTP POST 请求到指定的 URL (`https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f`)，用于微信企业号的 webhook 发送一条通知消息，告知某个网站不可访问，并包含状态码信息。

  - `-H "Content-Type: application/json"`：设置请求头的内容类型为 JSON。
  - `-X POST`：指定请求方法为 POST。
  - `-d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%\"}}"`：设置请求的 JSON 数据负载。

- `start "" "C:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\Users\Administrator\Desktop\check_vpn_window_and_click.ahk"`：这条批处理脚本命令的作用是启动 AutoHotkey 脚本文件 `check_vpn_window_and_click.ahk`。

  - `start ""`：这是批处理命令 `start` 的语法，后面的空引号 `""` 表示不指定窗口标题，即启动命令不带任何窗口标题。
  - `"C:\Program Files\AutoHotkey\AutoHotkey.exe"`: 这部分是指定了 AutoHotkey 程序的完整路径，用双引号括起来，确保路径中有空格时也能正确识别路径。
  - `"C:\Users\Administrator\Desktop\check_vpn_window_and_click.ahk"`: 这部分是指定了要执行的 AutoHotkey 脚本文件的完整路径，同样用双引号括起来。

- `timeout /t 60`：是一个在 Windows 命令提示符（CMD）或批处理脚本中用来延迟执行的命令。

  - `timeout`：延迟命令。
  - `/t 60`：指定延迟的时间，这里是 60 秒（即一分钟）。



## 四、配置AuthHotkey脚本

> 注：在AutoHotkey中，获取窗口上按钮的“名称”（通常指的是按钮上显示的文本）并不是直接支持的功能，因为AutoHotkey主要用于发送键盘和鼠标命令，而不是直接读取窗口控件的属性。
>
> AuthHotkey脚本都是以`ank`为扩展名。

`check_vpn_window_and_click.ahk`内容如下：

```bash
#SingleInstance, Force
SetTitleMatchMode, 2 ; 使用部分匹配模式
DetectHiddenWindows, On

; 目标窗口的标题
targetWindowTitle := "AWS VPN Client"
 
; 如果目标窗口已经存在，则直接执行点击操作
if WinExist(targetWindowTitle)
{
    WinActivate, %targetWindowTitle%
    Sleep, 1000

    ; 点击AWS VPN Client窗口的"断开连接"
    MouseClick, Left, 300, 130
    Sleep, 3000

    ; 点击AWS VPN Client窗口的"连接"
    MouseClick, Left, 300, 130
    Sleep, 12000

    ; 点击浏览器上登陆账号
    MouseClick, Left, 400, 250
    Sleep, 5000

    ; 关闭浏览器
    MouseClick, Left, 790, 20
}
else
{
    MsgBox, 目标窗口未找到。
}
 
return
```

**解释说明：**

这段 AutoHotkey 脚本用于自动化操作一个名为 "AWS VPN Client" 的窗口。

- `#SingleInstance, Force`：这行指令确保脚本只有一个实例在运行，并强制重复运行时只保留一个。
- `SetTitleMatchMode, 2`：设置窗口标题匹配模式为部分匹配模式，即窗口标题的一部分匹配即可。
- `DetectHiddenWindows, On`：允许脚本操作隐藏的窗口。
- `targetWindowTitle := "AWS VPN Client"`：定义一个变量 `targetWindowTitle`，存储目标窗口的标题，这里是 "AWS VPN Client"。
- `if WinExist(targetWindowTitle)`：如果名为 `targetWindowTitle` 的窗口存在，则执行以下操作。
- `WinActivate, %targetWindowTitle%`：激活名为 `targetWindowTitle` 的窗口。
- `Sleep, 1000`：等待 1000 毫秒，即1秒钟。
- `MouseClick, Left, 300, 130`：在窗口内坐标为 (300, 130) 的位置左键点击，用于执行断开连接操作。
- `MsgBox, 目标窗口未找到。`：弹出一个消息框提示用户 "目标窗口未找到。"
- `return`：结束脚本。



## 五、运行脚本

双击执行bat脚本即可，运行效果如下三种情况。

### 1.当状态码连续不为200

```bash
正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
AutoHotkey脚本刚开始启动，发送一条通知...
{"errcode":0,"errmsg":"ok"}
当前失败次数：0或1
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
当前失败次数：2
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

......

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
AutoHotkey脚本启动次数达到20次，检查是否需要发送通知...
{"errcode":0,"errmsg":"ok"}
当前失败次数：20
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
AutoHotkey脚本刚开始启动，发送一条通知...
{"errcode":0,"errmsg":"ok"}
当前失败次数：21
等待1分钟后重新检测...
```

### 2.当状态码连续为200

```bash
正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...

Waiting for 0 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...

Waiting for 0 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...

Waiting for 0 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...

Waiting for 0 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...
```

### 3.当状态码不连续为200

```bash
正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
AutoHotkey脚本刚开始启动，发送一条通知...
{"errcode":0,"errmsg":"ok"}
当前失败次数：0或1
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
当前失败次数：2
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
AutoHotkey脚本刚开始启动，发送一条通知...
{"errcode":0,"errmsg":"ok"}
当前失败次数：0或1
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，启动AutoHotkey脚本...

Waiting for 40 seconds, press a key to continue ...
当前失败次数：2
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...

正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
等待1分钟后重新检测...
```



