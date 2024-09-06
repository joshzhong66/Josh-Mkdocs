## 1、移动存储库后打开仓库报错

![image-20240830140547384](C:\Users\josh\AppData\Roaming\Typora\typora-user-images\image-20240830140547384.png)

打开 Git Bash，执行命令来添加信任这个目录

信任单个目录

```
git config --global --add safe.directory 'E:/GitHub/LearningNotes'
```

信任所有目录

```
git config --global --add safe.directory '*'
```







2、推送报错

>remote: GitLab: You are not allowed to push code to protected branches on this project.
>To 10.22.51.64:yunwei/devp_scripts.git
> ! [remote rejected] main -> main (pre-receive hook declined)
>error: failed to push some refs to '10.22.51.64:yunwei/devp_scripts.git'
>Done



```
josh@DESKTOP-85OL1ON MINGW64 /e/GitHub/devp_scripts (main)
$ git checkout -b shell		#创建分支
Switched to a new branch 'shell'

josh@DESKTOP-85OL1ON MINGW64 /e/GitHub/devp_scripts (shell)
$ git push origin shell		 #推送代码
Enumerating objects: 10, done.
Counting objects: 100% (10/10), done.
Delta compression using up to 8 threads
Compressing objects: 100% (9/9), done.
Writing objects: 100% (9/9), 16.58 KiB | 2.76 MiB/s, done.
Total 9 (delta 3), reused 0 (delta 0), pack-reused 0 (from 0)
remote:
remote: To create a merge request for shell, visit:
remote:   http://10.22.51.64:7070/yunwei/devp_scripts/-/merge_requests/new?merge_request%5Bsource_branch%5D=shell
remote:
To 10.22.51.64:yunwei/devp_scripts.git
 * [new branch]      shell -> shell

josh@DESKTOP-85OL1ON MINGW64 /e/GitHub/devp_scripts (shell)

```

