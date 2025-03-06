# Bat脚本说明



## 一、提取名字.bat

```bash
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 获取当前目录
set "current_dir=%cd%"

:: 设置输出文件名
set "output_file=%current_dir%\file_list.txt"

:: 创建一个存储文件名的文件，并输出标题
echo. > "%output_file%"
echo 文件和目录列表: >> "%output_file%"

:: 遍历当前目录下的所有文件和目录并输出到文件
echo [目录] >> "%output_file%"
for /d %%d in (*) do (
    echo %%d >> "%output_file%"
)

echo. >> "%output_file%"
echo [文件] >> "%output_file%"
for %%f in (*) do (
    if "%%f" neq "file_list.txt" (
		if "%%f" neq "提取名字.bat" (
			if not exist "%%f\" (
				echo %%~nf >> "%output_file%"
			)
        )
    )
)

:: 提示完成
echo 文件和目录名已输出到 %output_file%
pause
```

### 1.解释说明

- `@echo off`：关闭命令回显功能，避免命令在执行时显示在控制台上。
- `chcp 65001 >nul`：
  - `chcp 65001`：将代码页设置为UTF-8（65001），以确保处理中文字符不会出现乱码。
  - `>nul`：将输出重定向到空设备，避免显示命令的输出结果。若不配置，则输出结果开头会显示如下：`Active code page: 65001`。
- `setlocal enabledelayedexpansion`：启用延迟变量扩展，允许在变量中使用`!`代替`%`进行扩展。
- `::`：批处理脚本中的注释符号，用于在脚本中添加注释。
- `set "current_dir=%cd%"`：`set`命令将当前目录路径存储在变量`current_dir`中。
- `set "output_file=%current_dir%\file_list.txt"`：`set`命令将输出文件的路径存储在变量`output_file`中，文件名为`file_list.txt`。
- `for /d %%d in (*) do (...)`：
  - `/d`：只匹配目录。
  - `%%d`：循环变量名`d`，用于存储当前遍历到的目录名。在批处理脚本中，循环变量需要使用双百分号`%%`。如果是在命令行直接运行，则使用单百分号`%`。
  - `in (*)`：`(*)`表示匹配当前目录下的所有目录。星号`*`是通配符，表示任意名称。
  - `do ( ... )`：`do`后面跟着一个命令块，命令块中的所有命令会针对每一个匹配的目录执行一次。
- `echo.`：输出一个空行换行符。相当于在控制台或者输出文件中插入一个空白行，以便更好地组织和阅读输出内容。
- `if "%%f" neq "file_list.txt"`：确保输出文件本身不会被包含在文件列表中。
- `if not exist "%%f\"`：确保只处理文件，不处理目录。通过检查文件名后面是否有反斜杠来判断是否为文件。
- `echo %%~nf >> "%output_file%"`：将文件的名字（不带扩展名）追加到输出文件中。
- `%%~nf`：由 `%%f` 和 `%%~n` 组合，组合起来，`%%~nf` 就是从变量 `%%f` 中提取不带路径和扩展名的文件名。
  - `%%f`：代表`for`循环中的一个变量，指向当前遍历的文件。
  - `%%~n`：是一个修饰符，用于提取文件名（不包括路径和扩展名）。

**在批处理文件中，重定向符号 `>` 是用来将命令的输出发送到文件或设备的。但是，如果 `>` 前面有任何非命令的文本（比如“文件和目录列表:”），那么批处理解释器会尝试将这个文本当作命令来执行，从而引发错误。因此先通过换行符重定向到第一行后再执行。**

### 2.执行效果

将该bat脚本放到需要提取的所在目录下，双击执行：

```bash
文件和目录名已输出到 D:\GitHub\joshzhong_LearningNotes\Bat\file_list.txt
Press any key to continue . . .
```

得到输出的文件名`file_list.txt`：

```bash
 
文件和目录列表: 
[目录] 
 
[文件] 
(激活运行，运行后按1)KMS Win_Office 
Bat脚本说明 
修改网卡 
关闭程序 
删除win凭据
多开微信
批量新建目录
查看系统信息 
检查系统到期时间 
激活win10_office程序 
自启Windows Installer服务
获取电脑IP信息
配置DNS 
配置系统代理 
```



## 二、删除win凭据.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal

:: 检查参数个数
if "%~1"=="" (
    set /p "ipAddress=请输入要删除凭据的IP地址: "
) else (
    set "ipAddress=%~1"
)

:: 检查是否输入了IP地址
if "%ipAddress%"=="" (
    echo 没有提供IP地址，脚本将退出。
    pause
    exit /b 1
)

:: 使用cmdkey列出凭据并寻找匹配的IP地址
for /f "tokens=1,* delims=: " %%a in ('cmdkey /list ^| findstr /i /c:"%ipAddress%"') do (
    set "credential=%%b"
)

:: 检查是否找到凭据
if not defined credential (
    echo 没有找到与IP地址 %ipAddress% 相关的凭据。
    pause
    exit /b 1
)

:: 删除凭据
cmdkey /delete:%credential%

:: 检查操作结果
if errorlevel 1 (
    echo 删除凭据失败。
    pause
    exit /b 1
) else (
    echo 已成功删除IP地址 %ipAddress% 的凭据。
    pause
    exit /b 0
)
```

### 1.解释说明

- `setlocal`：启动本地环境，使得在批处理文件中所做的环境变量更改不会影响到外部环境。

- `openfiles >nul 2>nul`：

  - `openfiles`：这个命令通常在管理员权限下使用，用于查看或管理打开的文件（在文件共享或文件锁定时使用）。
  - `>nul`：将标准输出（正常信息）重定向到 `nul`，这意味着不会显示任何命令输出。
  - `2>nul`：将标准错误（错误信息）重定向到 `nul`，这意味着如果命令执行失败，也不会显示错误信息。

  通过这种方式，`openfiles` 命令在后台运行，检查是否有权限执行。如果命令执行失败（通常由于缺乏管理员权限），`%errorlevel%` 变量会被设置为非零值。

- `if '%errorlevel%' NEQ '0'`：

  - `%errorlevel%`：这个变量存储了上一个命令的返回码。返回码为 `0` 表示成功，非零表示失败或有错误发生。
  - `NEQ '0'`：`NEQ` 是 "not equal" 的缩写。此条件检查 `%errorlevel%` 是否不等于 `0`，即判断 `openfiles` 命令是否失败。如果失败（通常意味着脚本没有管理员权限），则执行括号中的代码块。

- `powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"`：

  - `powershell -Command`：调用 PowerShell 来执行命令。
  - `Start-Process cmd`：使用 PowerShell 启动一个新的 `cmd` 进程。
  - `-ArgumentList '/c \"%~f0\"'`：传递参数给 `cmd`，`/c` 表示执行完命令后关闭窗口，`\"%~f0\"` 是当前批处理文件的完整路径（`%~f0` 是脚本本身的路径），表示重新运行当前脚本。
  - `-Verb RunAs`：以管理员身份运行这个命令。这会触发 UAC（用户账户控制）的提示，要求用户确认以管理员身份运行。


- `%~1` ：一个批处理中的参数扩展形式，具体含义如下：
  - `%1` ：表示获取传递给批处理文件的第一个参数（即用户在命令行中输入的第一个值）。
  - `~` ：是一个特殊的修饰符，用于对参数进行扩展。
  - `~1` ：扩展形式可以去除参数周围的引号（如果存在的话）。
- `set /p ipAddress=请输入要删除凭据的IP地址：`：提示用户输入一个IP地址，然后使用这个输入继续执行脚本。**（注意：等号两边不能为空）**
- `/b`：表示退出批处理文件的当前批处理上下文。
- `for /f`：一个增强的 `for` 命令，专门用于处理文本文件的内容或命令输出。在这个特定场景中，使用 `/f` 是要逐行处理 `cmdkey /list` 命令的输出。
- `"tokens=1,* delims=: " %%a`：
  - `tokens=1,*` ：表示将每一行按分隔符 `:` 拆分成多个部分，并将第一个部分（即 `: `左边的部分）赋值给变量 `%%a`，剩余部分赋值给 `%%b`。
  - `delims=: `：指定 `:` 和空格为分隔符。
- `in ('cmdkey /list ^| findstr /i /c:"%ipAddress%"')`：指定循环的内容是通过管道命令 `cmdkey /list` 和 `findstr /i /c:"%ipAddress%"` 获取的。
  - `cmdkey /list`：列出当前系统中所有存储的凭据。
  - `^|`：是转义后的管道符号 `|`，用于将 `cmdkey /list` 的输出传递给 `findstr`。
  - `findstr /i /c:"%ipAddress%"`：在 `cmdkey` 输出中查找包含指定 IP 地址（变量 `%ipAddress%`）的行，`/i` 表示忽略大小写，`/c` 表示搜索完整字符串，返回对应的行。
- `set "credential=%%b"`：对每一行匹配的输出，提取分割后的第二部分（即 `%%b`）并存储到 `credential` 环境变量中。
- `if not defined credential (...)`：检查变量 `credential` 是否被定义，如果没有找到与指定 IP 地址相关的凭据，则输出一条消息并退出批处理脚本。
- `if errorlevel 1` ：用于检查上一个命令的返回代码（错误级别）。`1`表示如果返回代码大于等于1，则执行if语句内块。

### 2.执行效果

#### 2.1 查看当前系统中所有存储的凭据

```bash
C:\Users\jerion>cmdkey /list

当前保存的凭据:

    目标: LegacyGeneric:target=GitHub - https://api.github.com/zyx3721
    类型: 普通
    用户: zyx3721

    目标: Domain:target=10.24.1.105
    类型: 域密码
    用户: hongzelong
```

#### 2.2 输入空的IP地址

```bash
请输入要删除凭据的IP地址：
未输入IP地址。
Press any key to continue . . .
```

#### 2.3 输入不存在的IP地址

```bash
请输入要删除凭据的IP地址：10.10.10.10
没有找到与IP地址 10.10.10.10 相关的凭据。
Press any key to continue . . .
```

#### 2.4 输入存在的IP地址

```bash
请输入要删除凭据的IP地址：10.24.1.105
找到的凭据:Domain:target=10.24.1.105
已成功删除IP地址 10.24.1.105 的凭据。
Press any key to continue . . .
```



## 三、批量新建目录.bat

```bash
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置要创建的目录数量
set /p num_folders=请输入要创建的目录数量：

:: 检查是否输入了要创建的目录数量
if "%num_folders%"=="" (
    echo 未输入要创建的目录数量。
	pause
    exit /b 1
)

:: 设置是否需要自定义目录名
echo.
set /p yes_no=是否需要自定义目录名（请输入y或n）：

:: 检查是否输入了是否需要自定义目录名
if "%yes_no%"=="" (
    echo 未输入是否需要自定义目录名。
	pause
    exit /b 1
)

:: 检查是否输入了正确的是否需要自定义目录名
if "%yes_no%" neq "y" if "%yes_no%" neq "n" (
    echo 输入的是否需要自定义目录名不是有效的选项。
	pause
    exit /b 1
)

:: 循环创建目录
echo.
if "%yes_no%"=="y" (
    for /l %%i in (1, 1, %num_folders%) do (
	    set /p folder_name=请输入第%%i个目录名：
		
		:: 检查是否输入了目录名
		:loop
		if "!folder_name!"=="" (
			set /p folder_name=请勿输入空名，重新输入：
			goto :loop
		)
		md "!folder_name!"
	)
) else (
    for /l %%i in (1, 1, %num_folders%) do (
		set "folder_name=第%%i个目录"
	    md "!folder_name!"
	)
)

pause
```

### 1.解释说明

- `if "%yes_no%" neq "y" if "%yes_no%" neq "n"`：是一种嵌套条件检查的写法，用于判断变量 `%yes_no%` 是否既不等于 `"y"` 也不等于 `"n"`。

- `for /l %%i in (1, 1, %num_folders%) do`：

  - `for /l`：用于创建一个循环计数器，从起始值开始，按照指定步长递增，直到终止值。这是一个循环命令，用于生成一个指定范围内的数字序列。
  - `%%i`：这是循环变量，用于依次代表每个生成的数字。
  - `in (1, 1, %num_folders%)`：这指定了循环范围。从数字 `1` 开始，每次递增 `1`，直到 `%num_folders%`（即要创建的目录数量）。

  在这个例子中，`%%i` 会依次取 `1` 到 `%num_folders%` 之间的值，每次循环执行循环体中的操作。
  
- `:loop`：是一个标签，用于表示循环的开始点。

- `goto :loop`：是一个无条件跳转，将控制流程回到 `:loop` 标签，实现循环。直到`"!folder_name!"!=""`后跳出循环，类似`while true`语句。

> 延迟环境变量扩展（Delayed Environment Variable Expansion）是指在批处理脚本中一种特定的环境变量扩展方式。在默认情况下，批处理脚本在解析时会立即展开 `%variable%` 形式的环境变量，这意味着它们在脚本解析阶段就会被替换为其当前值。
>
> 然而，在某些情况下，可能需要在执行时根据需要延迟展开环境变量，即在运行时才真正替换成变量的当前值。这种情况下，可以使用延迟环境变量扩展，即使用 `!variable!` 的形式来表示。
>
> 延迟环境变量扩展通常在以下几种情况下很有用：
>
> - **循环中的变量处理**：当需要在循环中使用递增的变量时，直接使用 `%variable%` 可能会导致问题，因为所有变量都在循环开始时被扩展了一次。使用 `!variable!` 可以确保在每次迭代中都使用变量的当前值。
> - **嵌套批处理或命令中的变量**：在嵌套的命令或批处理调用中，延迟环境变量扩展可以避免由于变量替换顺序而导致的问题。
> - **处理包含特殊字符或空格的变量值**：有时候变量的值中包含特殊字符或空格，直接使用 `%variable%` 可能会引起解析错误，延迟环境变量扩展可以更安全地处理这种情况。
>
> 要启用延迟环境变量扩展，可以使用 `setlocal enabledelayedexpansion` 命令将其开启，然后可以在脚本中使用 `!variable!` 来访问延迟扩展的变量。

### 2.执行效果

#### 2.1 未输入要创建的目录数量

```bash
请输入要创建的目录数量：
未输入要创建的目录数量。
Press any key to continue . . .
```

#### 2.1 未输入是否需要自定义目录名

```bash
请输入要创建的目录数量：3

是否需要自定义目录名（请输入y或n）：
未输入是否需要自定义目录名。
Press any key to continue . . .
```

#### 2.3 输入不正确的是否需要自定义目录名

```bash
请输入要创建的目录数量：3

是否需要自定义目录名（请输入y或n）：ye
输入的是否需要自定义目录名不是有效的选项。
Press any key to continue . . .
```

#### 2.4 新建非自定义目录名

```bash
请输入要创建的目录数量：3

是否需要自定义目录名（请输入y或n）：n

Press any key to continue . . .
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/28/d3726edebf0d750f06ce127048612166-image-20240628094523960-b6c93a.png" alt="image-20240628094523960" style="zoom:50%;" />

#### 2.5 新建自定义目录名

```bash
请输入要创建的目录数量：3

是否需要自定义目录名（请输入y或n）：y

请输入第1个目录名：一
请输入第2个目录名：二
请输入第3个目录名：三
Press any key to continue . . .
```



## 四、自启Windows Installer服务.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal enabledelayedexpansion

echo 正在尝试启动Windows Installer服务...
echo.

REM 检查Windows Installer服务是否正在运行
sc queryex msiserver | find "RUNNING">nul

if !errorlevel! equ 0 (
    echo Windows Installer服务已经在运行
	echo.
    pause
    exit /b 0
) else (
	REM 尝试启动Windows Installer服务	
	echo 尝试启动Windows Installer服务...
	echo.
	
    net start msiserver >nul

	if !errorlevel! equ 0 (
	    echo Windows Installer服务启动成功
	) else (
		echo 无法启动Windows Installer服务
	)
	
	pause
    exit /b 0
)
```

### 1.解释说明

- `REM`：也是批处理脚本中用于添加注释的一种方法，后面需要加空格再进行注释，也可以在同一行命令后面添加注释。
- `sc queryex msiserver | find "RUNNING">nul`：
  - `sc queryex msiserver`：使用`sc queryex`命令查询名为`msiserver`（Windows Installer服务）的状态。
    - `sc`：全称为Service Control，该命令用于与系统服务进行交互。
    - `queryex`：这个命令与 `query` 类似，但提供了更详细的服务信息。输出除了基本信息外，还包括服务的详细配置信息，如服务进程 ID、服务启动参数等。
  - `| find "RUNNING">nul`：将输出结果通过管道传递给`find`命令以查找包含"RUNNING"的行。`>nul`用于抑制命令的输出。
- `if !errorlevel! equ 0`：判断上一条命令执行是否成功，`0`表示成功，进行if语句内块。后面接`0`表示成功，命令执行没有遇到错误；如果接`1`表示失败，不同的非零值可能表示不同类型的错误。
  - 这条语句近似等价于`if errorlevel 0`，区别是`if errorlevel 0`表示大于等于0的条件，相比还是前者好一些。
  - 这里使用`!`代替`%`进行扩展，是由于脚本中使用多次`errorlevel`，防止下一次使用的值为上次保存的值，因为使用`!`，来使脚本解析阶段就会被替换为其当前值。
- `net start msiserver`：使用`net start`命令启动名为`msiserver`的服务。



### 2.执行效果

#### 2.1 服务已经在运行

```bash
正在尝试启动Windows Installer服务...

Windows Installer服务已经在运行

Press any key to continue . . .
```

#### 2.2 服务未启动并启动服务

```bash
正在尝试启动Windows Installer服务...

尝试启动Windows Installer服务...

Windows Installer服务启动成功
Press any key to continue . . .
```



## 五、获取电脑IP信息.bat

```bash
@echo off
chcp 65001>nul

::hostname

:: %%i是for语句里面特有的变量，只有在批处理里面才写两个%%号表示变量(用1个会报错)，在cmd中则只用一个%号(用2个会报错)
:: 批处理中之所以用两个%%是因为编译器编译的时候要屏蔽一个%
for /f %%i in ('curl -s ifconfig.io')  do  ( 
	set wanip=%%i
)

::%%~表示删除引号
for /f "tokens=1,2,3 delims=={,}" %%a in ('wmic NICCONFIG where "IPEnabled='TRUE'" get DefaultIPGateway^,DNSServerSearchOrder^,IPAddress^,IPSubnet /value^|findstr "={"') do (
	if "%%a"=="DefaultIPGateway" (set "Gate=%%~b"
	) else if "%%a"=="DNSServerSearchOrder" (set "DNS1=%%~b"&set "DNS2=%%~c"
	) else if "%%a"=="IPAddress" (set "IP=%%~b"
	) else if "%%a"=="IPSubnet" (set "Mask=%%~b")
	if defined Gate if defined Mask goto :show
)

:show
	echo; 计算机名:     %USERDOMAIN%
	echo; 用户名：      %USERNAME%
	echo; 本机内网IP:   %IP%
	echo; 子网掩码:     %Mask%
	echo; 默认网关:     %Gate%
	echo; 首选 DNS:     %DNS1%
	echo; 备用 DNS:     %DNS2%
	echo; 公网出口IP:   %wanip%
                  
pause
```

### 1.解释说明

- `curl -s ifconfig.io`：从`ifconfig.io`网址上获取到对应的IP地址。`-s`表示静默模式，不显示进度条和错误信息。
- `for /f`：一个增强的 `for` 命令，专门用于处理文本文件的内容或命令输出。在这个特定场景中，使用 `/f` 是要逐行处理 `cmdkey /list` 命令的输出。
- `'wmic NICCONFIG where "IPEnabled='TRUE'" get DefaultIPGateway^,DNSServerSearchOrder^,IPAddress^,IPSubnet /value`：
  - `wmic NICCONFIG`：使用 WMI (Windows Management Instrumentation) 命令行工具来查询网络适配器配置的命令。
  - `where "IPEnabled='TRUE'"`：这是 `wmic` 命令的过滤条件，用于筛选出已启用 IP 的网络适配器。
  - `get DefaultIPGateway^,DNSServerSearchOrder^,IPAddress^,IPSubnet /value`：
    - `get` ：指示 `wmic` 命令获取指定属性的值。
    - `DefaultIPGateway^,DNSServerSearchOrder^,IPAddress^,IPSubnet`：这列出了要获取的属性，包括默认网关、DNS服务器地址、IP地址和子网掩码。
    - `^`：用来转义特殊字符，使得它们在命令解析时被正确地处理而不被误解。
    - `/value`：这个参数告诉 `wmic` 命令以键值对的形式输出每个属性的名称和值。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/28/07932b567e2c2820f607458e8dc28929-image-20240628143401407-d1bfc3.png" alt="image-20240628143401407" style="zoom: 33%;" />

- `^|findstr "={"'`：

  - `^|`：这是管道符号，这里通过`^`转义，使其不被误解，将 `wmic` 命令的输出传递给后面的命令。
  - `findstr "={"'`：用于在文本文件中搜索字符串模式的命令，用于在 `wmic` 命令的输出中筛选包含 `={` 字符串的行。

  ```bash
  C:\Users\Jerion>wmic NICCONFIG where "IPEnabled='TRUE'" get DefaultIPGateway,DNSServerSearchOrder,IPAddress,IPSubnet /value | findstr "={"
  DefaultIPGateway={"10.18.88.1"}
  DNSServerSearchOrder={"10.22.50.5","10.22.50.6"}
  IPAddress={"10.18.88.135","fe80::781f:e9d4:fbc5:7c35"}
  IPSubnet={"255.255.248.0","64"}
  IPAddress={"192.168.56.1","fe80::370b:d605:c595:4e40"}
  IPSubnet={"255.255.255.0","64"}
  IPAddress={"192.168.1.1","fe80::fd78:4f27:ba44:925d"}
  IPSubnet={"255.255.255.0","64"}
  IPAddress={"192.168.222.1","fe80::eecc:211e:2115:f37b"}
  IPSubnet={"255.255.255.0","64"}
  ```

- `"tokens=1,2,3 delims=={,}" %%a`：

  - `tokens=1,2,3` ：表示将每一行按分隔符`=`或 `{` 或`,`或`}`拆分成三个部分，并将第一个部分（即 `: `左边的部分）赋值给变量 `%%a`，剩余部分赋值给 `%%b`、`%%c`。
  - `delims=: `：指定 `:` 和空格为分隔符。

  **要注意的是，如果for循环中使用`%%a`表示第一个变量，for循环的`%%a`可以替换为如`%%j`，则后续变量必须遵循字母顺序规则。**

- `if defined Gate if defined Mask goto :show`：如果`Gate`和`Mask`变量都已定义（即有值），则跳转到标签`:show`，表示已成功获取所需的网络配置信息。

- `:show`：是一个标签，用于表示循环的开始点。

- `goto :show`：是一个无条件跳转，将控制流程跳到 `:show` 标签，表示已成功获取所需的网络配置信息。

- `echo; `：格式化输出，开头会多出空格。

### 2.执行效果

```bash
 计算机名:     WHIZHZL
 用户名：      Jerion
 本机内网IP:   10.18.88.135
 子网掩码:     255.255.248.0
 默认网关:     10.18.88.1
 首选 DNS:     10.22.50.5
 备用 DNS:     10.22.50.6
 公网出口IP:   218.17.157.169
Press any key to continue . . .
```



## 六、配置DNS自动和手动模式.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001>nul
setlocal enabledelayedexpansion

:: 右键-以管理员身份运行即可，以太网改为你的网络名称
:: 关闭360杀毒软件

for /f "tokens=1,* delims= " %%a in ('netsh interface ip show config "WLAN" ^| findstr "配置的 DNS 服务器"') do (
    set "config_status=%%~a"
)

if "%config_status%"=="Statically" (
	echo 当前 DNS 为手动配置，将切换为自动获取DNS...
	
	netsh interface ip set dnsservers "WLAN" dhcp >nul
) else (
	echo 当前 DNS 为自动获取DNS，将切换为手动指定 8.8.8.8...
	
	netsh interface ip set dnsservers "WLAN" static 8.8.8.8 primary >nul
	netsh interface ip add dnsservers "WLAN" 223.5.5.5 index=2 >nul
	ipconfig /flushdns >nul
)

echo DNS 设置已更新并刷新 DNS 缓存。
pause
exit /b 0
```

### 1.解释说明

- `netsh interface ip set dnsservers "WLAN" static 114.114.114.114 primary`：
  - `netsh`：用于配置和管理 Windows 网络设置的命令行工具。
  - `interface ip`：指定配置 IP 设置。
  - `set dnsservers`：设置 DNS 服务器。
  - `"WLAN"`：目标网络连接的名称。
  - `static 114.114.114.114`：指定静态 DNS 服务器地址为 `114.114.114.114`。
  - `primary`：将这个 DNS 服务器设置为主 DNS 服务器。
- `netsh interface ip add dnsservers "以太网" 8.8.8.8 index=2`：
  - `add dnsservers`：添加一个新的 DNS 服务器。
  - `index=2`：将这个 DNS 服务器设置为第二个（备用） DNS 服务器。
- `ipconfig /flushdns`：刷新 DNS 解析缓存，清除存储的 DNS 记录。

### 2.执行效果

以管理员身份运行bat脚本：

#### 2.1 从自动模式到手动模式

```bash
当前 DNS 为自动获取DNS，将切换为手动指定 8.8.8.8...
DNS 设置已更新并刷新 DNS 缓存。
Press any key to continue . . .
```

#### 2.2 从手动模式到自动模式

```
当前 DNS 为手动配置，将切换为自动获取DNS...
DNS 设置已更新并刷新 DNS 缓存。
Press any key to continue . . .
```



## 七、关闭程序.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)
chcp 65001>nul

:: 关闭程序(.exe是您要关闭的程序的文件名。如果您要关闭不同的程序，请替换成相应的文件名。)
taskkill /f /im cloudmusic.exe
echo 网易云音乐已关闭

taskkill /f /im DingtalkLauncher.exe
echo 钉钉已关闭

taskkill /f /im QQScLauncher.exe
echo qq已关闭


taskkill /f /im WeChat.exe
echo 微信已关闭

taskkill /f /im 有道云笔记.exe
echo 有道云笔记已关闭

taskkill /f /im Snipaste.exe
taskkill /f /im Everything.exe
taskkill /f /im Foxmail.exe


echo 所有程序已成功关闭
pause
```

### 1.解释说明

- `taskkill /f /im`：用于强制终止指定的进程。
  - `/f`：表示强制终止进程。
  - `/im`：表示指定进程名称。



## 八、多开微信.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul

:: 点击一次，开一个客户端进程

set /p open_count=请输入需要打开微信程序的个数：

:: 检查是否输入了需要打开微信程序的个数
if "%open_count%"=="" (
    echo 未输入需要打开微信程序的个数。
	pause
    exit /b 1
)

for /l %%i in (1,1,%open_count%) do (
	echo 正在启动第%%i个微信...
	start "" "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
	echo 第%%i个微信已启动。
	echo.
	timeout /t 2 > nul
)

echo 微信已全部启动。
pause
exit /b 0
```

### 1.解释说明

- `for /l`：用于创建一个循环计数器，从起始值开始，按照指定步长递增，直到终止值。
- `start "" "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"`：
  - `start`：用于启动一个新的进程或打开一个新窗口。这里用于启动微信程序。
  - `""` ：表示窗口标题。如果不需要指定窗口标题，可以用空引号。
  - `"路径\到\程序.exe"`：是程序的完整路径。
- `timeout /t 2 > nul`：用于程序进行暂停。
  - `/t 2`：表示暂停2秒钟。
  - `> nul`：用于将 `timeout` 命令的输出重定向到 `nul`，这样不会在屏幕上显示倒计时。

### 2.执行效果

#### 2.1 未输入需要需要打开微信程序的个数

```bash
请输入需要打开微信程序的个数：
未输入需要打开微信程序的个数。
Press any key to continue . . .
```

#### 2.2 多开微信

```bash
请输入需要打开微信程序的个数：3
正在启动第1个微信...
第1个微信已启动。

正在启动第2个微信...
第2个微信已启动。

正在启动第3个微信...
第3个微信已启动。

微信已全部启动。
Press any key to continue . . .
```



## 九、查看系统信息.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal enabledelayedexpansion

echo 获取计算机信息，请稍候...

echo.
echo [CPU信息]
echo -----------------------------------------
wmic cpu get name,CurrentClockSpeed,MaxClockSpeed /format:list | findstr "="

echo.
echo [内存信息]
echo -----------------------------------------
echo     插槽      容量(GB)        速度(MHz)
for /f "tokens=1,2 delims==" %%a in ('wmic MEMORYCHIP get BankLabel^,Capacity^,Speed /format:list ^| findstr "="') do (
	REM 获取内存的插槽标签
    if "%%a"=="BankLabel" set "bank=%%b"

	REM 获取内存的容量内存，并计算为GB为单位
    if "%%a"=="Capacity" for /f %%x in ('powershell -Command "[math]::truncate(%%b / 1073741824)"') do set "size=%%x"
	
	REM 获取内存的速度
    if "%%a"=="Speed" set "speed=%%b"
	
    if defined size if defined speed if defined bank (
        echo !bank!		!size!GB		!speed!
        set "size="
        set "speed="
        set "bank="
    )
)

echo.
echo [显卡信息]
echo -----------------------------------------
wmic path win32_videocontroller get name /format:list | findstr "="

echo.
echo [硬盘信息]
echo -----------------------------------------
wmic diskdrive get model,size /format:list | findstr "Model="
for /f "tokens=2 delims==" %%s in ('wmic diskdrive get size /format:list ^| findstr "Size="') do (
    for /f %%x in ('powershell -Command "[math]::truncate(%%s / 1073741824)"') do set "disksize=%%x"
    echo 硬盘容量: !disksize! GB
)

echo.
echo [系统信息]
echo -----------------------------------------
systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Manufacturer" /C:"System Model" /C:"System Type" /C:"BIOS Version"

echo.
echo 信息获取完毕。
pause
```

### 1.解释说明

- `wmic cpu get Name,CurrentClockSpeed,MaxClockSpeed /format:list | findstr "="`：

  - `wmic cpu`：使用 WMI (Windows Management Instrumentation) 命令行工具来查询CPU配置的命令。
  - `get Name,CurrentClockSpeed,MaxClockSpeed /format:list`：
    - `get` ：指示 `wmic` 命令获取指定属性的值。
    - `Name,CurrentClockSpeed,MaxClockSpeed`：这列出了要获取的属性，包括处理器名称、当前时钟速度、最大时钟速度的信息。
    - `/format:list` ：指定输出格式为列表格式，左边为属性，右边为属性的值，中间以 `=` 符号赋予关系。

  <img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/28/b0e4d84d60b3d2d73b8aec965d28ffdb-image-20240628231142202-193978.png" alt="image-20240628231142202" style="zoom:50%;" />

  - `| findstr "="`：
    - `|`：这是管道符号，将 `wmic` 命令的输出传递给后面的命令。
    - `findstr "="`：用于在文本文件中搜索字符串模式的命令，用于在 `wmic` 命令的输出中筛选包含 `=` 字符串的行。

  ```bash
  C:\Users\jerion>wmic cpu get name,CurrentClockSpeed,MaxClockSpeed /format:list | findstr "="
  CurrentClockSpeed=3301
  MaxClockSpeed=3301
  Name=AMD Ryzen 5 5600H with Radeon Graphics
  ```

- `'wmic MEMORYCHIP get BankLabel^, Capacity^, Speed /format:list ^| findstr "="'`：

  - `wmic MEMORYCHIP`：使用 WMI (Windows Management Instrumentation) 命令行工具来查询MEMORYCHIP配置的命令。
  - `get BankLabel^, Capacity^, Speed /format:list`：
    - `get` ：指示 `wmic` 命令获取指定属性的值。
    - `BankLabel^, Capacity^, Speed`：这列出了要获取的属性，包括插槽、容量(GB)、速度(MHz)信息。
    - `^`：用来转义特殊字符，使得它们在命令解析时被正确地处理而不被误解。
    - `/format:list`：指定输出格式为列表格式，左边为属性，右边为属性的值，中间以 `=` 符号赋予关系。

  <img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/29/ea47811590524dcef40a8203b5521a76-image-20240629000747231-b8ea2f.png" alt="image-20240629000747231" style="zoom:50%;" />

  - `^| findstr "="'`：筛选包含 `=` 字符串的行。

    ```bash
    C:\Users\jerion>wmic MEMORYCHIP get BankLabel, Capacity, Speed /format:list | findstr "="
    BankLabel=P0 CHANNEL A
    Capacity=8589934592
    Speed=3200
    BankLabel=P0 CHANNEL B
    Capacity=8589934592
    Speed=3200
    ```

- `"tokens=1,2 delims==" %%a`：

  - `tokens=1,2` ：表示将每一行按分隔符`=`拆分成两个部分，并将第一个部分（即 `: `左边的部分）赋值给变量 `%%a`，剩余部分赋值给 `%%b`。
  - `delims== `：指定 `=` 为分隔符。

- `'powershell -Command "[math]::truncate(%%b / 1073741824)"'`：这段 PowerShell 命令的作用是将环境变量 `%%b` 的值除以 1073741824（即1GB对应的字节数），然后对结果取整数部分。

  - `[math]::truncate()` ：PowerShell 中是一个静态方法，用于将一个浮点数或双精度数值截断为最接近的整数。

- `wmic path win32_videocontroller get Name /format:list | findstr "="`：

  - `wmic path win32_videocontroller`：使用 WMI (Windows Management Instrumentation) 命令行工具来获取显示控制器（显卡）信息的命令。执行这个命令将列出所有安装在计算机上的显示控制器的详细信息，包括制造商、型号、显存大小等。

  <img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/28/f4dfa82f5dc4ba424ff51cb9f04cc807-image-20240628231359551-a781de.png" alt="image-20240628231359551" style="zoom:50%;" />

  - `| findstr "="`：筛选包含 `=` 字符串的行。

    ```bash
    C:\Users\jerion>wmic path win32_videocontroller get name /format:list | findstr "="
    Name=AMD Radeon(TM) Graphics
    Name=NVIDIA GeForce GTX 1650
    ```

- `wmic diskdrive get Model,Size /format:list | findstr "Model="`：

  - `wmic diskdrive`：使用 WMI (Windows Management Instrumentation) 命令行工具来显示安装在计算机上的所有磁盘驱动器的型号和容量信息。

  <img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/28/7d1c903d632ff884aa20648b60388ba7-image-20240628231442840-f2d9e3.png" alt="image-20240628231442840" style="zoom:50%;" />

  - `findstr "Model="`：筛选包含 `Model=` 字符串的行。

  ```bash
  C:\Users\jerion>wmic diskdrive get Model,Size /format:list | findstr "Model="
  Model=Generic MassStorageClass USB Device
  Model=SKHynix_HFS512GDE9X084N
  Model=Generic MassStorageClass USB Device
  ```

- `'wmic diskdrive get size /format:list ^| findstr "Size="'`：

```bash
C:\Users\jerion>wmic diskdrive get Model,Size /format:list | findstr "Size="
Size=
Size=512105932800
Size=
```

- `"tokens=2 delims==" %%s`：
  - `tokens=2` ：表示将每一行按分隔符`=`进行分割，并将从第二个分割之后的部分赋值给变量 `%%s`。
  - `delims== `：指定 `=` 为分隔符。

### 2.执行效果

```bash
获取计算机信息，请稍候...

[CPU信息]
-----------------------------------------
CurrentClockSpeed=3301
MaxClockSpeed=3301
Name=AMD Ryzen 5 5600H with Radeon Graphics

[内存信息]
-----------------------------------------
    插槽      容量(GB)        速度(MHz)
P0 CHANNEL A    8GB             3200
P0 CHANNEL B    8GB             3200

[显卡信息]
-----------------------------------------
Name=AMD Radeon(TM) Graphics
Name=NVIDIA GeForce GTX 1650

[硬盘信息]
-----------------------------------------
Model=Generic MassStorageClass USB Device
Model=SKHynix_HFS512GDE9X084N
Model=Generic MassStorageClass USB Device
硬盘容量: + GB
硬盘容量: 476 GB
硬盘容量: + GB

[系统信息]
-----------------------------------------
OS Name:                   Microsoft Windows 11 家庭中文版
OS Version:                10.0.22000 N/A Build 22000
System Manufacturer:       LENOVO
System Model:              82L5
System Type:               x64-based PC
BIOS Version:              LENOVO GSCN29WW, 2021/10/8

信息获取完毕。
Press any key to continue . . .
```



## 十、检查系统激活时间.bat

```bash
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 正在检查Windows系统激活时间...
echo.
cscript //nologo C:\Windows\System32\slmgr.vbs /xpr

pause
```

### 1.解释说明

- `cscript //nologo slmgr.vbs /xpr`：

  - `cscript`：Windows 脚本宿主命令行版本，用于直接从命令行运行脚本。
  - `//nologo`：该选项用于抑制运行 `cscript` 时通常显示的徽标。

  ```bash
  # 加//nologo运行，会显示以下信息，不加后运行就没有
  Microsoft (R) Windows Script Host Version 5.812
  版权所有(C) Microsoft Corporation。保留所有权利。
  ```

  - `slmgr.vbs`：用于 Windows 软件许可管理的 Visual Basic 脚本。
  - `/xpr`：检查 Windows 操作系统的激活状态。

  <img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/29/516c899f25e73ce0d36592816a3b5965-image-20240629121912390-b9d40a.png" alt="image-20240629121912390" style="zoom:50%;" />

### 2.执行效果

```bash
正在检查Windows系统激活时间...

Windows(R), CoreCountrySpecific edition:
    计算机已永久激活。

Press any key to continue . . .
```



## 十一、修改网卡.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal enabledelayedexpansion

:: 适用于win操作系统，在cmd输入ipconfig/all确认网卡名称
:: 右键-以管理员身份运行即可，以太网改为你的网络名称

:: 设置IP地址
:main
set /p choice=请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):
echo.

if "%choice%"=="1" goto ip1
if "%choice%"=="2" goto ip2
if "%choice%"=="3" goto ip3
goto main

:ip1
echo 固定内网IP自动设置开始...
echo.

echo 正在设置固定内网IP及子网掩码...
netsh interface ip set address name="WLAN" source=static addr=10.18.88.135 mask=255.255.255.0 gateway=10.18.88.1 gwmetric=1

echo 正在设置固定内网DNS服务器...
netsh interface ip add dnsservers name="WLAN" address=8.8.8.8 index=1 >nul
netsh interface ip add dnsservers name="WLAN" address=114.114.114.114 index=2 >nul

echo.
echo 固定内网IP设置完成。

if errorlevel 1 goto main
if errorlevel 0 goto end

:ip2
echo 自动获取IP自动设置开始...
echo.

echo 正在设置自动获取IP地址...
netsh interface ip set address name="WLAN" source=dhcp

echo 正在设置自动获取DNS服务器...
netsh interface ip set dns name="WLAN" source=dhcp

echo 自动获取IP设置完成。

if errorlevel 1 goto main
if errorlevel 0 goto end

:ip3
echo 临时固定IP自动设置开始...
echo.

echo 正在设置临时固定IP及子网掩码...
set /p ip=请输入需要配置的IP地址:
set /p ym=请输入需要配置的子网掩码:
set /p gt=请输入需要配置的网关:
netsh interface ip set address name="WLAN" source=static addr="%ip%" mask="%ym%" gateway="%gt%" gwmetric=1

echo 正在设置内网DNS服务器...
netsh interface ip add dnsservers name="WLAN" address=8.8.8.8 index=1 >nul
netsh interface ip add dnsservers name="WLAN" address=114.114.114.114 index=2 >nul

echo.
echo 临时固定IP设置完成。

if errorlevel 1 goto main
if errorlevel 0 goto end

:end
pause
exit /b 0
```

### 1.解释说明

- `netsh interface ip set address name="WLAN" source=static addr=10.18.88.135 mask=255.255.255.0 gateway=10.18.88.1 gwmetric=1`：
  - `netsh interface ip set address`：使用 `netsh` 命令配置网络接口的 IP 地址。
  - `name="WLAN"`：指定要配置的网络接口名称。这里的接口名称是“WLAN”。如果你的网络接口名称不同，请相应替换。
  - `source=static`：将 IP 地址设置为静态。
  - `addr=10.18.88.135`: 指定新的静态 IP 地址。
  - `mask=255.255.255.0`: 指定子网掩码。
  - `gateway=10.18.88.1`: 指定默认网关。
  - `gwmetric=1`: 指定网关的度量值（Metric），用来确定路由的优先级。值越小优先级越高。
- `netsh interface ip add dnsservers name="WLAN" address=8.8.8.8 index=1`：
  - `netsh interface ip add dnsservers`: 使用 `netsh` 命令配置网络接口的 DNS 服务器列表进行添加操作。
  - `index=1`：指定了 DNS 服务器在列表中的索引位置，这里是添加到第一个位置。

### 2.执行效果

#### 2.1选择设置类型未输入或输入有误

```bash
请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):

请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):4

请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):
```

#### 2.1 设置固定内网IP

```
请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):1

固定内网IP自动设置开始...

正在设置固定内网IP及子网掩码...

正在设置固定内网DNS服务器...

固定内网IP设置完成。
Press any key to continue . . .
```

#### 2.2 设置自动获取IP

```bash
请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):2

自动获取IP自动设置开始...

正在设置自动获取IP地址...

正在设置自动获取DNS服务器...

自动获取IP设置完成。
Press any key to continue . . .
```

#### 2.3 设置临时固定IP

```bash
请选择设置类型(1:固定内网IP / 2:自动获取IP / 3:临时固定IP ):3

临时固定IP自动设置开始...

正在设置临时固定IP及子网掩码...
请输入需要配置的IP地址:10.10.10.10
请输入需要配置的子网掩码:255.255.255.0
请输入需要配置的网关:10.10.10.254

正在设置内网DNS服务器...

临时固定IP设置完成。
Press any key to continue . . .
```



## 十二、激活win10_office程序.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal enabledelayedexpansion

for /l %%i in (1,1,7) do echo.

echo 正在启动 PowerShell 来激活 Windows 和 Office...
echo.

echo 激活程序加载中，请在弹出的页面进行操作。
echo.

echo 输入数字键选择激活内容:
echo 1 激活 Windows
echo 2 激活 Office
echo.

powershell -Command "irm https://get.activated.win | iex"

echo 请根据弹出的菜单选择激活选项。
echo.
pause
```

### 1.解释说明

- `powershell -Command "irm https://get.activated.win | iex"`：这条命令的含义是使用 PowerShell 执行从指定 URL（https://get.activated.win）下载的脚本。

  - `powershell -Command`：用于在命令行中执行 PowerShell 命令的方式。在这种模式下，`-Command` 后面可以跟随一个或多个要执行的 PowerShell 命令，多个命令之间可以用分号 `;` 分隔。
  - `irm`：`Invoke-RestMethod` 的简写，用于从指定的 URL 下载内容。
  - `|`：管道符号，将上一个命令的输出作为输入传递给下一个命令。
  - `iex`：`Invoke-Expression` 的简写，用于执行从前一个命令获取的文本内容作为 PowerShell 脚本。

  `iex` 是 PowerShell 中的一个命令，全称为 `Invoke-Expression`。它的作用是将以字符串形式提供的命令或表达式作为 PowerShell 脚本来执行。具体来说，`iex` 接受一个字符串参数，并将其解释为 PowerShell 代码进行执行。

### 2.执行效果

```bash
正在启动 PowerShell 来激活 Windows 和 Office...

激活程序加载中，请在弹出的页面进行操作。

输入数字键选择激活内容:
1 激活 Windows
2 激活 Office

请根据弹出的菜单选择激活选项。

Press any key to continue . . .
```



## 十三、配置系统代理.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
setlocal enabledelayedexpansion

:main
set /p userChoice="输入1启动代理，输入2关闭代理: "

if "%userChoice%"=="1" goto enableProxy
if "%userChoice%"=="2" goto disableProxy
goto main

:enableProxy
REM 设置服务器地址和端口
set "proxyServer=10.22.51.64:7890"

REM 启用服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul

REM 设置服务器地址和端口
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "%proxyServer%" /f >nul

REM 刷新设置
netsh winhttp import proxy source=ie >nul

echo.
echo 代理已修改为：%proxyServer%

goto end

:disableProxy
REM 关闭服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul

REM 刷新设置
netsh winhttp reset proxy >nul

echo.
echo 已关闭代理。

:end
pause
exit /b 0
```

### 1.解释说明

- `reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f`：这条命令的作用是将 `ProxyEnable` 的值设置为 1，用于启用代理设置。

  - `reg add`：这是 Windows 中用于添加或更新注册表项的命令。
  - `"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"`：这是要操作的注册表路径，表示当前用户的 Internet 设置。`HKCU`的路径就是`计算机\HKEY_CURRENT_USER`。
  - `/v ProxyEnable`：指定要操作的注册表值名称为 `ProxyEnable`。
  - `/t REG_DWORD`：指定值的数据类型为 `REG_DWORD`，即双字（DWORD）类型，用于存储一个 32 位的数值。
  - `/d 1`：指定要设置的数值为 1。
  - `/f`：表示强制执行操作，即使目标注册表路径不存在也会创建它。

- `netsh winhttp import proxy source=ie`：这条命令的作用是从当前用户的 Internet Explorer 设置中导入代理配置，并应用到 WinHTTP 设置中。

  - `netsh winhttp`：是 Windows 中用于配置 WinHTTP 设置的命令行工具。
  - `import proxy`：表示要导入代理配置。
  - `source=ie`：指定从 Internet Explorer 的当前用户设置中获取代理配置信息。

  这条命令的执行会将当前用户在 Internet Explorer 中配置的代理信息（如代理服务器地址、端口号等）导入到系统的 WinHTTP 设置中，以便系统级别的应用程序（如系统服务、Windows Update 等）可以使用这些代理设置进行网络通信。

- `netsh winhttp reset proxy`：重置当前的 WinHTTP 代理设置。

  执行这条命令会将当前系统的 WinHTTP 代理设置恢复为默认状态，移除任何已配置的代理服务器信息，以及可能存在的代理免费地址和例外列表。

### 2.执行效果

#### 2.1 启动代理

```bash
输入1启动代理，输入2关闭代理: 1

代理已修改为：10.22.51.64:7890
Press any key to continue . . .
```

#### 2.2 关闭代理

```bash
输入1启动代理，输入2关闭代理: 2

已关闭代理。
Press any key to continue . . .
```



## 十四、检测网页.bat

### 1.脚本用途

定时检测一个网络服务的可用性，并根据服务的状态决定是否发送通知。

### 2.脚本内容

#### 2.1 检测网页_cmd_gbk.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 936 >nul

set /a counter=0

:loop
echo.
set /p ="正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F..." < nul

echo.
curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt

::type result.txt
set /p status=<result.txt

set /p ="收到的状态码：%status%" < nul
echo.

if not "%status%"=="200" (
    echo 状态码不是200，检查是否需要发送通知...
    set /p ="当前消息发送计数器：%counter%" < nul
    echo.
    if "%counter%"=="0" (
        set /p ="发送通知..." < nul
        echo.
        curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f
        set /a counter=60
        set /p ="消息发送计数器设置为：%counter%" < nul
        echo.
    ) else (
        set /p ="未发送通知，仅减少计数器" < nul
        echo.
        set /a counter-=1
        set /p ="消息发送计数器减少，当前值：%counter%" < nul
        echo.
    )
) else (
    set /p ="网站正常访问，停止计数。" < nul
	echo.
    if "%counter%" neq "0" (
        set /a counter=0
        set /p ="消息发送计数器重置为：0" < nul
        echo.
    )
)

set /p ="等待1分钟后重新检测..." < nul
echo.
timeout /t 60

goto loop
```

#### 2.2 检测网页_powershell_utf8.bat

```bash
@echo off
:: 检查是否具有管理员权限
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

chcp 65001 > nul

set /a counter=0

:loop
echo.
echo 正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F...

echo.
curl -s -o NUL -w "%%{http_code}" https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F > result.txt

::type result.txt
set /p status=<result.txt

echo 收到的状态码：%status%


if not "%status%"=="200" (
    echo 状态码不是200，检查是否需要发送通知...
    echo 当前消息发送计数器：%counter%
	
    if "%counter%"=="0" (
        echo 发送通知...
		
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$OutputEncoding = New-Object System.Text.UTF8Encoding; Invoke-RestMethod -Uri 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f' -Method Post -ContentType 'application/json' -Body (@{msgtype='text'; text=@{content='The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%'}} | ConvertTo-Json)"
		set /a counter=60
		
        echo 消息发送计数器设置为：%counter%
    ) else (
        echo 未发送通知，仅减少计数器
		
        set /a counter-=1
		
        echo 消息发送计数器减少，当前值：%counter%
    )
) else (
    echo 网站正常访问，停止计数。
	
    if "%counter%" neq "0" (
        set /a counter=0
		
		echo 消息发送计数器重置为：0
    )
)

echo 等待1分钟后重新检测...

timeout /t 60

goto loop
```

### 3.解释说明

- `chcp 936`：表示cmd将使用`简体中文GKB`，`65001`则是使用`utf-8`编码（在文本编辑器中编辑批处理文件，确保文件编码设置为`ANSI`或与`chcp`命令设置相同的代码页）。

- `set /a counter=0`：设置计数器，初始化变量`counter`，控制发送通知次数。
  - `set`：设置环境变量的命令。
  - `/a`：指示 `set` 命令进行算术运算。
  - `counter=0`：将变量 `counter` 的值设置为 `0`。
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

- `if not "%status%"=="200"`：判断状态码是否为200，如果不是200，根据 `counter` 判断是否需要发送通知，如果需要发送通知，使用 `curl` 发送POST请求通知服务状态，并更新计数器，控制下次通知的间隔，如果不发需要发送通知，开始减少消息发送计数器重新开始，如果状态码是200，则重置计数器。

- `curl -H "Content-Type: application/json" -X POST -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%\"}}" https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f`：这条命令使用 `curl` 发送一个 HTTP POST 请求到指定的 URL (`https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f`)，用于微信企业号的 webhook 发送一条通知消息，告知某个网站不可访问，并包含状态码信息。

  - `-H "Content-Type: application/json"`：设置请求头的内容类型为 JSON。
  - `-X POST`：指定请求方法为 POST。
  - `-d "{\"msgtype\":\"text\",\"text\":{\"content\":\"The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%\"}}"`：设置请求的 JSON 数据负载。

- `powershell -NoProfile -ExecutionPolicy Bypass -Command "$OutputEncoding = New-Object System.Text.UTF8Encoding; Invoke-RestMethod -Uri 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f' -Method Post -ContentType 'application/json' -Body (@{msgtype='text'; text=@{content='The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%'}} | ConvertTo-Json)"`：这条 PowerShell 命令的作用是向微信企业号的 webhook 发送一条通知消息，告知某个网站不可访问，并包含状态码信息。

  - `powershell -NoProfile -ExecutionPolicy Bypass -Command`：
    - `-NoProfile`：不加载用户配置文件，这样可以加快启动速度并避免加载用户配置文件中的设置。
    - `-ExecutionPolicy Bypass`：绕过脚本执行策略，使脚本可以在不受限制的情况下执行。
    - `-Command`：指定要执行的 PowerShell 命令。
  - `$OutputEncoding = New-Object System.Text.UTF8Encoding`：设置 PowerShell 的输出编码为 UTF-8，确保发送的请求内容使用 UTF-8 编码。
  - `Invoke-RestMethod`：
    - `-Uri 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=f0a765e3-6454-4d2f-85be-ad485f94cb1f'`：指定请求的 URL，这是微信企业号的 webhook 地址。
    - `-Method Post`：指定请求方法为 POST。
    - `-ContentType 'application/json'`：设置请求头的内容类型为 JSON。
    - `-Body`：指定请求的 JSON 数据负载。
  - `(@{msgtype='text'; text=@{content='The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%'}} | ConvertTo-Json)`：使用哈希表（`@{}`）构建 JSON 数据。
    - `msgtype='text'`：消息类型为文本。
    - `text=@{content='The website https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=%2F is not accessible. Status code: %status%'}`：文本内容，包含网站不可访问的消息和状态码占位符 `%status%`。
    - 使用 `ConvertTo-Json` 将哈希表转换为 JSON 格式。

- `timeout /t 60`：是一个在 Windows 命令提示符（CMD）或批处理脚本中用来延迟执行的命令。

  - `timeout`：延迟命令。
  - `/t 60`：指定延迟的时间，这里是 60 秒（即一分钟）。

### 4.执行效果

#### 2.1 状态码为200

```bash
正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：200
网站正常访问，停止计数。
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...
```

#### 2.2 状态码为非200

```
正在检测网址 https://kb-scb-cbs-logging-np.np.private.azscb.tech:5601/login?next=F...
收到的状态码：000
状态码不是200，检查是否需要发送通知...
当前消息发送计数器：0
发送通知...
消息发送计数器设置为：60
等待1分钟后重新检测...

Waiting for 60 seconds, press a key to continue ...
```



## 十五、修改文件的创建时间.bat

```bash
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置要修改创建时间的文件路径
:loop
set file_path=
set /p file_path=请输入修改创建时间的文件路径：
echo.

:: 检查是否输入了要修改创建时间的文件路径
if "!file_path!"=="" (
    echo 未输入修改创建时间的文件路径。
	echo.

    :loop2
    set exit_script=
    set /p exit_script=是否需要重新输入（y或n）：
	echo.

    if /i "!exit_script!"=="y" (
        goto loop
    ) else if /i "!exit_script!"=="n" (
        echo 退出脚本.
        pause
        exit /b 0
    ) else (
        goto loop2
    )
)

:: 判断文件路径是否存在
if exist "!file_path!" (
    echo 文件存在于系统中！准备执行修改创建时间...
    echo.
) else (
    echo 文件不存在于系统中！请检查路径是否正确！
    echo.
    goto loop
)

:: 输入要修改的指定时间
:time_input
set new_creation_time=
set /p new_creation_time=请输入要修改的指定时间（格式： yyyy-MM-dd HH:mm:ss ）：
echo.

:: 调用 PowerShell 检查时间格式是否正确
powershell -command ^
"$pattern = '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'; ^
if ('!new_creation_time!' -match $pattern) { ^
    exit 0 ^
} else { ^
    exit 1 ^
}"

:: 检查 PowerShell 的返回值
if !errorlevel! neq 0 (
    echo 时间格式不正确，请重新输入。
    echo.
    goto time_input
)

:: 调用 powershell 执行修改创建时间命令
powershell -command "(Get-Item !file_path!).CreationTime = (Get-Date '!new_creation_time!')" >nul

if !errorlevel! neq 0 (
    echo 指定的时间不符合实际上的时间范围内，请重新输入。
    echo.
    goto time_input
)

echo 修改成功！指定的修改创建时间为 "!new_creation_time!"
pause
exit /b 0
```

### 1.解释说明

- `set file_path=`：由于在每次循环开始时，如果用户没有输入任何内容直接回车，那么变量的值会用上一次循环时的值来引用，因此需要在每次循环时，将变量重新初始化为空。
- `powershell -Command ^ ... `：这部分指定了 PowerShell 脚本将作为命令执行。
  - `$pattern = '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'`：定义了一个正则表达式模式，匹配的日期时间格式为：
    - `^\d{4}`：4位数字开头（年份）；
    - `-\d{2}`：后跟一个连字符和2位数字（月份）；
    - `-\d{2}`：后跟另一个连字符和2位数字（日期）；
    - `\d{2}`：后跟一个空格和2位数字（小时）；
    - `:\d{2}`：后跟一个冒号和2位数字（分钟）；
    - `:\d{2}$`：后跟另一个冒号和2位数字（秒）。
  - `if ('!new_creation_time!' -match $pattern)`：检查 `!new_creation_time!` 变量的值是否匹配定义的正则表达式 `$pattern`。
    - `-match`：该运算符用于检查一个字符串是否与正则表达式模式匹配。它返回一个布尔值：如果字符串符合正则表达式，则返回 `$true`，否则返回 `$false`。
- `powershell -command "(Get-Item !file_path!).CreationTime = (Get-Date '!new_creation_time!')" >nul`：这段 PowerShell 命令用于设置文件的创建时间。
  - `(Get-Item !file_path!)`：`Get-Item` 是 PowerShell 中的一个 cmdlet，用于获取指定路径的文件或目录。`!file_path!` 是 batch 脚本中的变量引用，表示文件路径。
  - `.CreationTime`：这是 `Get-Item` 返回的文件对象的属性之一，表示文件的创建时间。
  - `= (Get-Date '!new_creation_time!')`：`Get-Date` 是 PowerShell 中的一个 cmdlet，用于获取或创建一个日期时间对象。`!new_creation_time!` 是要设置的新创建时间的变量。`Get-Date` 将字符串 `!new_creation_time!` 转换为日期时间对象，然后将其赋值给文件的 `CreationTime` 属性。
  - `>nul`：将命令的输出重定向到 `nul`，即不显示任何输出。这在 batch 脚本中常用来隐藏 PowerShell 命令的输出。

### 2.执行效果

#### 2.1 未输入或输入不正确的文件路径

##### 2.1.1 需要重新输入

```bash
请输入修改创建时间的文件路径：

未输入修改创建时间的文件路径。

是否需要重新输入（y或n）：

是否需要重新输入（y或n）：y

请输入修改创建时间的文件路径：123

文件不存在于系统中！请检查路径是否正确！

请输入修改创建时间的文件路径：

未输入修改创建时间的文件路径。

是否需要重新输入（y或n）：y

请输入修改创建时间的文件路径：33

文件不存在于系统中！请检查路径是否正确！

请输入修改创建时间的文件路径：
```

##### 2.1.2 不需要重新输入

```bash
请输入修改创建时间的文件路径：123

文件不存在于系统中！请检查路径是否正确！

请输入修改创建时间的文件路径：

未输入修改创建时间的文件路径。

是否需要重新输入（y或n）：n

退出脚本.
Press any key to continue . . .
```

#### 2.2 输入正确的文件路径

##### 2.2.1 输入不正确的时间格式

```bash
请输入修改创建时间的文件路径：C:\Users\jerion\Desktop\新建文本文档.txt

文件存在于系统中！准备执行修改创建时间...

请输入要修改的指定时间（格式： yyyy-MM-dd HH:mm:ss ）：123

时间格式不正确，请重新输入。

请输入要修改的指定时间（格式： yyyy-MM-dd HH:mm:ss ）：
```

##### 2.2.2 输入不正确的实际时间

```bash
请输入修改创建时间的文件路径：C:\Users\jerion\Desktop\新建文本文档.txt

文件存在于系统中！准备执行修改创建时间...

请输入要修改的指定时间（格式： yyyy-MM-dd HH:mm:ss ）：2024-08-06 26:12:12

指定的时间不符合实际上的时间范围内，请重新输入。

请输入要修改的指定时间（格式： yyyy-MM-dd HH:mm:ss ）：
```

##### 2.2.3 输入正确的实际时间

```bash
请输入修改创建时间的文件路径：C:\Users\jerion\Desktop\新建文本文档.txt

文件存在于系统中！准备执行修改创建时间...

请输入要修改的指定时间（格式： yyyy-MM-dd HH:mm:ss ）：2024-08-06 12:22:22

修改成功！指定的修改创建时间为 "2024-08-06 12:22:22"
Press any key to continue . . .
```

效果如下：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/07/258974b39135d7279bc9635e0dfbeeab-image-20240807230718601-33dd6d.png" alt="image-20240807230718601" style="zoom: 50%;" />



## 十六、连接共享盘.bat

```bash
@echo off
chcp 65001 >nul

REM 保存网络路径的凭据
cmdkey /add:10.24.1.105 /user:zhsm /pass:zxRRVwzF

REM 取消映射指定的网络驱动器（如果已经存在）
net use K: /delete /y >nul 2>&1
net use H: /delete /y >nul 2>&1
net use L: /delete /y >nul 2>&1

REM 使用指定的网络路径、用户名和密码映射网络驱动器并设置持久化
net use K: \\10.24.1.105\咨询项目文件  /persistent:yes >nul 2>&1
net use H: \\10.24.1.105\共享服务部  /persistent:yes >nul 2>&1
net use L: \\10.24.1.105\行政服务部  /persistent:yes >nul 2>&1

REM 检查是否映射成功
if %errorlevel% neq 0 (
    echo 映射网络驱动器失败！
) else (
    echo 网络驱动器已成功!
)

pause
```

### 1.解释说明

- `cmdkey /add:10.24.1.105 /user:zhsm /pass:zxRRVwzF`：
  - `cmdkey`：命令行工具，用于创建、删除和显示存储的用户凭据。
  - `/add:10.24.1.105`：
    - `/add` 选项用于添加新的凭据。
    - `10.24.1.105` 是要添加凭据的目标（通常是一个 IP 地址或计算机名）。
  - `/user:zhsm`：`/user` 选项指定与目标相关联的用户名。在这个例子中，用户名是 `zhsm`。
  - `/pass:zxRRVwzF`：`/pass` 选项用于指定与用户相关联的密码。在这里，密码是 `zxRRVwzF`。
- `net use K: /delete /y`：用于在 Windows 系统中删除映射到驱动器 K: 的网络共享。
  - `/delete`：表示删除操作；
  - `/y`：表示自动确认删除，无需额外提示。
- `net use K: \\10.24.1.105\咨询项目文件 /persistent:yes`：用于在 Windows 系统中映射网络共享。
  - `K:` ：表示要映射的本地驱动器字母。
  - `\\10.24.1.105\咨询项目文件` ：要映射的网络共享路径，其中 `10.24.1.105` 是网络计算机的 IP 地址，`咨询项目文件` 是共享的文件夹名称。
  - `/persistent:yes` ：表示该映射将是持久的，系统重启后仍然保持映射状态。
- `\>nul 2>&1`：将标准错误（stderr）重定向到标准输出（stdout），而标准输出已经被重定向到 `nul`，这样两个流都被丢弃了。

### 2.执行效果

```bash
CMDKEY: Credential added successfully.
网络驱动器已成功!
Press any key to continue . . .
```



## 十七、通过域名解析IP.bat

```bash
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置输入文件和输出文件路径
set inputFile=domain.txt
set outputFile=domain_ip.txt

:: 读取每个域名并查询 IP 地址
for /f "tokens=*" %%a in (%inputFile%) do (
    set domain=%%a
    :: 用于标记是否已经找到并输出了第一个 IP 地址
    set found=0

    :: 使用 PowerShell 查询域名的 IP 地址
    for /f "delims=" %%b in ('powershell -Command "Resolve-DnsName !domain! -Server 8.8.8.8 | Where-Object { $_.IPAddress -match '^\d{1,3}(\.\d{1,3}){3}$' } | Select-Object -ExpandProperty IPAddress"') do (
        :: 如果找到第一个 IPv4 地址，进入 if 语句
        if !found! == 0 (
            set ip=%%b
            echo 域名 !domain! 解析为：!ip!
            echo !ip!    !domain!>> %outputFile%
            :: 标记为 1，丢弃其他 IPv4 地址
            set found=1
        )
    )
)

echo.
echo 解析完成，结果已保存到 %outputFile%
pause
```

### 1.解释说明

- `setlocal enabledelayedexpansion`：启用延迟变量扩展，这样在循环中可以实时更新和读取变量的值。
- `for /f "tokens=*" %%a in (%inputFile%) do`：这是一个 `for` 循环，用于逐行读取 `domain.txt` 文件中的域名。
  - `/f` 选项表示从文件中读取内容并按行处理。
  - `"tokens=*"` 表示每一行的完整内容都会被读取到变量 `%%a` 中（即读取整个域名）。
  - `%inputFile%` 是输入文件 `domain.txt` 的路径。
  - `%%a` 是循环变量，表示当前读取的每个域名。
- `for /f "delims=" %%b in ('powershell -Command "Resolve-DnsName !domain! -Server 8.8.8.8 | Where-Object { $_.IPAddress -match '^\d{1,3}(\.\d{1,3}){3}$' } | Select-Object -ExpandProperty IPAddress"') do`：这是一个嵌套的 `for` 循环，用来执行 PowerShell 命令，并将返回的每个 IP 地址存入变量 `%%b`。
  - `'powershell -Command ...'` 用来调用 PowerShell 脚本。
  - `Resolve-DnsName !domain! -Server 8.8.8.8` 查询指定域名（`!domain!`）的 DNS 信息，使用的是 Google 的公共 DNS 服务器 `8.8.8.8`。
  - `Where-Object { $_.IPAddress -match '^\d{1,3}(\.\d{1,3}){3}$' }` 用正则表达式过滤出 IPv4 地址（IPv6 地址会被忽略）。
    - `Where-Object`：是 PowerShell 中的一个 cmdlet，用于从管道中筛选符合条件的对象。它会逐一处理传入的对象，并根据 `{}` 中的条件进行筛选。如果条件为真，当前对象会通过管道输出；否则会被过滤掉。
    - `$_.IPAddress`：`$_` 代表当前对象，`.IPAddress` 是当前对象的一个属性。在进行 DNS 查询时，`Resolve-DnsName` 返回的对象会包含一个 `IPAddress` 属性，这个属性存储了解析到的 IP 地址（可以是 IPv4 或 IPv6）。
    - `-match`：是 PowerShell 中用于正则表达式匹配的操作符。它会检查左侧的字符串是否符合右侧的正则表达式模式。如果匹配成功，`-match` 返回 `$true`，否则返回 `$false`。
    - `^\d{1,3}(\.\d{1,3}){3}$`：这个正则表达式 `^\d{1,3}(\.\d{1,3}){3}$` 用于匹配 IPv4 地址。
      - `^` 是正则表达式的起始符号，表示匹配输入字符串的开始位置。
      - `\d{1,3}`：`\d`表示匹配一个数字（0-9），`{1,3}` 是量词，表示前面的 `\d` 可以重复 1 到 3 次。
    - `(\.\d{1,3}){3}`：
      - `\.` 匹配字符点（`.`），在正则表达式中点是特殊字符，表示匹配任意字符。所以需要加反斜杠 `\` 来转义它，表示字面意义的点。
      - `\d{1,3}` 和前面一样，表示匹配 1 到 3 位的数字。
      - `(\.\d{1,3})` 是一个子表达式（或称为一个组），它匹配一个点 `.` 后跟 1 到 3 位数字的组合。
      - `{3}` 表示这个子表达式重复 3 次。也就是说，`(\.\d{1,3})` 需要出现 3 次，匹配 3 个“点+数字”的组合，确保地址中有 3 个点和 3 个数字组。
  - `Select-Object -ExpandProperty IPAddress` 选取每个 IP 地址（而不是整个对象）。
  - `%%b` 存储返回的每个 IP 地址。

### 2.执行效果

```bash
域名 www.google.com 解析为：199.16.158.12
域名 www.google.com.hk 解析为：31.13.73.9
域名 id.google.com.hk 解析为：199.59.148.96
......

解析完成，结果已保存到 domain_ip.txt
Press any key to continue . . .
```



## 十八、临时关闭Defender服务

```bash
@echo off
chcp 65001>nul

title 安全中心控制脚本

:: 获取管理员权限
%1 %2
ver|find "5.">nul&&goto :admin
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :admin","","runas",1)(window.close)&exit
:admin

echo 正在关闭实时监控...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
if %errorlevel% equ 0 (
    echo [✓] 操作成功，实时监控已关闭（重启后自动恢复）
) else (
    echo [×] 操作失败，错误代码：%errorlevel%
)
timeout /t 5 >nul
```

### 1.解释说明

这段脚本是一个批处理脚本，用于关闭 Windows 系统的实时监控功能，具体功能逐行解释如下：

- `title 安全中心控制脚本`：设置命令行窗口的标题为“安全中心控制脚本”。
- `%1 %2`：这两行代码是通过命令行参数尝试获取管理员权限。`%1` 和 `%2` 是批处理脚本的第一个和第二个命令行参数。如果脚本以管理员身份运行，接下来的代码会跳转到 `:admin` 标签。
- `ver|find "5.">nul&&goto :admin`：通过 `ver` 命令获取系统版本并使用 `find` 命令查找 "5."，如果是 Windows 7 或更早版本，跳转到 `:admin` 标签。
- `mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :admin","","runas",1)(window.close)&exit`：通过 `mshta` 启动一个 VBScript，使用 `runas` 参数尝试以管理员身份重新启动当前批处理脚本，执行 `goto :admin`，然后关闭窗口。
- `:admin`：标签，表示获取到管理员权限后跳转到这里继续执行。
- `powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"`：使用 PowerShell 命令关闭 Windows Defender 实时监控。`Set-MpPreference -DisableRealtimeMonitoring $true` 设置实时监控为禁用。

### 2.执行效果

```bash
正在关闭实时监控...
[✓] 操作成功，实时监控已关闭（重启后自动恢复）
```
