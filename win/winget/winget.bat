

:: 安装 winget
$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle




代码解释

- 禁用 PowerShell 的进度显示，使下载过程不显示进度条（静默模式）
- 输出提示信息，告诉用户正在下载 WinGet 及其依赖项
- 从 `https://aka.ms/getwinget` 下载 WinGet 的安装包（`.msixbundle` 文件）
- 下载 **Visual C++ Runtime (VCLibs)** 依赖项（`.appx` 文件）
- 下载 **Microsoft UI XAML (WinUI 2.7)** 依赖项（`.appx` 文件）
- 安装 Visual C++ Runtime (VCLibs) 依赖项
- 安装 Microsoft UI XAML (WinUI 2.7) 依赖项
- 安装 WinGet 主程序（`.msixbundle` 文件）


