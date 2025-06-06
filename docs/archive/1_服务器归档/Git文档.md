# Git文档

## 一、git pull

### 1.git pull

git拉取出现错误提示 `fatal: Exiting because of unfinished merge`，说明 Git 发现有未完成的合并。这种情况通常发生在之前的合并或冲突解决未完成时。

```
Please, commit your changes before merging.
fatal: Exiting because of unfinished merge.
Done
Press Enter or Esc to close console...
```

### 2.查看git状态

1. 查看状态，是否有冲突的文件和未完成的合并

```
git status
```

### 3.强制覆盖本地内容

```
joshz@josh31314 MINGW64 /e/LearningNotes (main|MERGING)
$ git fetch --all
remote: Enumerating objects: 60, done.
remote: Counting objects: 100% (60/60), done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 44 (delta 23), reused 43 (delta 22), pack-reused 0 (from 0)
Unpacking objects: 100% (44/44), 29.45 KiB | 342.00 KiB/s, done.
From github.com:joshzhong66/LearningNotes
   dc49a00..480660f  main       -> origin/main

joshz@josh31314 MINGW64 /e/LearningNotes (main|MERGING)
$


joshz@josh31314 MINGW64 /e/LearningNotes (main|MERGING)
$ git reset --hard origin/main
HEAD is now at 480660f 新增Ubuntu22.4虚拟机安装及初始化

```

