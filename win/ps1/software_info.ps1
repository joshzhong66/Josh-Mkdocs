
# powershell执行脚本：Start-Process powershell -ArgumentList "-NoExit -ExecutionPolicy Bypass -File E:\Josh-Mkdocs\win\ps1\software_info.ps1" -Verb RunAs
# 
<#
.SYNOPSIS
Export installed software list to a text file on desktop.
#>



# 注册表路径
$uninstallPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

try {
    # 获取软件信息（使用英文列名）
    $software = Get-ItemProperty -Path $uninstallPaths -ErrorAction Stop |
                Where-Object { $_.DisplayName -and $_.DisplayName -notmatch '^Update for|^KB\d+' } |
                Select-Object @{Name="Name"; Expression={$_.DisplayName}},
                              @{Name="Version"; Expression={$_.DisplayVersion}},
                              @{Name="Publisher"; Expression={$_.Publisher}},
                              @{Name="InstallDate"; Expression={
                                  if ($_.InstallDate) { 
                                      [datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null).ToString('yyyy-MM-dd') 
                                  } else { 
                                      'N/A' 
                                  }
                              }} |
                Sort-Object "Name"
    
    if (-not $software) {
        Write-Warning "No software information found."
        exit 0
    }
}
catch {
    Write-Error "Error fetching software list: $_"
    exit 1
}

try {
    # 输出文件路径
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $outputFile = Join-Path -Path $desktopPath -ChildPath "software_list.txt"
    
    # 保存文件
    $software | Format-Table -AutoSize -Wrap | Out-File -FilePath $outputFile -Encoding UTF8 -Force -Width 200
    Write-Host "√ Software list saved to: $outputFile" -ForegroundColor Green
}
catch {
    Write-Error "Error saving file: $_"
    exit 1
}