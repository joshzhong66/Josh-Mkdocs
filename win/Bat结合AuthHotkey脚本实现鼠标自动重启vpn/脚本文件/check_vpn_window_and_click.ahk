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
    Sleep, 5000

    ; 点击AWS VPN Client窗口的"连接"
    MouseClick, Left, 300, 130
    Sleep, 12000

    ; 点击浏览器上登陆账号，一个全屏坐标，一个非全屏坐标
    MouseClick, Left, 650, 260
    Sleep, 1000
    MouseClick, Left, 400, 250
    Sleep, 5000

    ; 关闭浏览器，一个全屏坐标，一个非全屏坐标
    MouseClick, Left, 790, 20
    Sleep, 1000
    MouseClick, Left, 1260, 20
}
else
{
    MsgBox, 目标窗口未找到。
}
 
return