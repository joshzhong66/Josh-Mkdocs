# 设置输出编码为 UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 获取用户目录
$userProfile = $env:USERPROFILE

# 初始化变量
$totalSize = 0
$folderCount = 0
$folderInfo = @()

Write-Host "正在扫描 $userProfile..."
Write-Host "========================================="

# 获取所有子文件夹（排除系统文件夹）
$excludeFolders = @('AppData', 'Default', '公用', 'Public', 'All Users', 'Default User')
$folders = Get-ChildItem -Path $userProfile -Directory | 
    Where-Object { $excludeFolders -notcontains $_.Name }

# 遍历文件夹计算大小
foreach ($folder in $folders) {
    $size = Get-ChildItem -LiteralPath $folder.FullName -Recurse -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Sum
    
    if ($null -eq $size) { $size = 0 }
    
    $sizeGB = [math]::Round($size/1GB, 2)
    Write-Host "$($folder.Name)：$sizeGB GB"
    
    $folderInfo += [PSCustomObject]@{
        Name = $folder.Name
        Path = $folder.FullName
        Bytes = $size
        GB = $sizeGB
    }
    
    $totalSize += $size
    $folderCount++
}

# 显示前5个最大文件夹及详情
Write-Host "`n前5个最大文件夹及其大文件详情："
Write-Host "========================================="

$folderInfo | Sort-Object Bytes -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Host "`n文件夹：$($_.Name) - $($_.GB) GB"
    Write-Host "大于1GB的项目："
    
    # 获取大于1GB的文件和文件夹
    $largeItems = Get-ChildItem -LiteralPath $_.Path -Recurse -ErrorAction SilentlyContinue | Where-Object {
        if ($_.PSIsContainer) {
            $subSize = (Get-ChildItem -LiteralPath $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $subSize -gt 1GB
        } else {
            $_.Length -gt 1GB
        }
    } | ForEach-Object {
        $itemSize = if ($_.PSIsContainer) {
            (Get-ChildItem -LiteralPath $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        } else {
            $_.Length
        }
        
        [PSCustomObject]@{
            Name = $_.Name
            Size = [math]::Round($itemSize/1GB, 2)
        }
    } | Sort-Object Size -Descending
    
    if ($largeItems) {
        $largeItems | ForEach-Object {
            Write-Host "  $($_.Name): $($_.Size) GB"
        }
    } else {
        Write-Host "  没有大于1GB的项目"
    }
}

# 显示总计信息
$totalGB = [math]::Round($totalSize/1GB, 2)
Write-Host "`n========================================="
Write-Host "总文件夹数：$folderCount"
Write-Host "合计大小：$totalGB GB"

# 等待用户输入
Write-Host "`n按回车键退出..."
Read-Host