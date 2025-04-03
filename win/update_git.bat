@echo off

chcp 65001 >nul

::功能:
::✅ 检测 Git 是否可用
::✅ 切换到目标目录
::✅ 自动暂存未提交的更改并 stash 处理，防止 git pull --rebase 失败
::✅ 拉取远端代码 并自动处理 stash
::✅ 提交更新并推送到远端

:: 检测 git 是否可用
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git 未安装或未配置环境变量，请检查后重试。
    pause
    exit /b
)

:: 进入指定目录
cd /d E:\LearningNotes || (
    echo 目录 E:\LearningNotes 不存在！
    pause
    exit /b
)

:: 检查是否有未暂存的更改
git status --porcelain | findstr /r "^ [MADRCU]" >nul
if %errorlevel% equ 0 (
    echo 检测到未暂存的更改，正在暂存...
    git add .
    git stash
)

:: 拉取远端代码
echo 正在拉取远端代码...
git pull origin main --rebase

:: 如果之前有暂存的更改，则恢复它们
git stash list | findstr "stash@{0}" >nul
if %errorlevel% equ 0 (
    echo 恢复之前暂存的更改...
    git stash pop
)

:: 提示用户输入 commit 信息
set /p commitMsg=请输入提交信息: 

:: 添加所有更改并提交
git add .
git commit -m "%commitMsg%"

:: 推送到远端
echo 正在推送到远端...
git push origin main

echo 操作完成！
pause

