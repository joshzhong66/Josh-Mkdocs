@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 检查D盘是否存在
if not exist "E:\" (
    echo 错误：D盘不存在。
    pause
    exit /b 1
)

echo 正在扫描 D:\...
echo =========================================

:: 使用PowerShell扫描大文件和目录，并输出前10名
powershell -Command "$items = Get-ChildItem 'E:\' -Recurse -File -ErrorAction SilentlyContinue; $dirSizes = @{}; foreach ($file in $items) { $dir = $file.DirectoryName; do { if (-not $dirSizes.ContainsKey($dir)) { $dirSizes[$dir] = 0 }; $dirSizes[$dir] += $file.Length; $dir = Split-Path $dir -Parent } while ($dir -ne ''); }; $largeDirs = $dirSizes.GetEnumerator() | Where-Object { $_.Value -ge 2GB } | ForEach-Object { [PSCustomObject]@{ Path = $_.Name; SizeGB = [math]::Round($_.Value / 1GB, 2); IsDirectory = $true } }; $largeFiles = Get-ChildItem 'D:\' -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -ge 2GB } | ForEach-Object { [PSCustomObject]@{ Path = $_.FullName; SizeGB = [math]::Round($_.Length / 1GB, 2); IsDirectory = $false } }; $allLargeItems = $largeDirs + $largeFiles; $top10 = $allLargeItems | Sort-Object SizeGB -Descending | Select-Object -First 10; echo '以下是大文件/目录列表（前10名）：'; $top10 | ForEach-Object { Write-Output ('{0}：{1} GB' -f $_.Path, $_.SizeGB) }; echo '========================================='; echo '总计符合条件的项目：' $allLargeItems.Count; echo '前10名已列出。'"

echo.
echo =========================================
echo 按任意键退出...
pause >nul