# PowerShell 脚本：get_installer_name.ps1
$url = "https://mirrors.sunline.cn/application/360zip/"
$response = Invoke-WebRequest -Uri $url -UseBasicParsing
$match = [regex]::Match($response.Content, 'href="([^"]+\.exe)"')
if ($match.Success) {
    $match.Groups[1].Value
}
