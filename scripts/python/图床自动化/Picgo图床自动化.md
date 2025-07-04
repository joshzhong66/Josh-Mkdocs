# Picgo图床自动化

## 1.安装picgo

以管理员身份运行cmd，安装picgo

```
npm install -g picgo
```

>```
>C:\Windows\System32>npm install -g picgo
>npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
>npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4 are no longer supported
>npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
>
>added 19 packages, removed 1 package, and changed 295 packages in 34s
>
>39 packages are looking for funding
>  run `npm fund` for details
>npm notice
>npm notice New major version of npm available! 10.8.2 -> 11.4.2
>npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.4.2
>npm notice To update run: npm install -g npm@11.4.2
>npm notice
>```

>```
>C:\Windows\System32>picgo -v
>1.5.9
>```

## 2.寻找picgo

```
C:\Windows\System32>picgo -v
1.5.9

C:\Windows\System32>where picgo
C:\Program Files\nodejs\node_global\node_modules\picgo\bin\picgo
C:\Program Files\nodejs\node_global\picgo
C:\Program Files\nodejs\node_global\picgo.cmd
```

>C:\Program Files\nodejs\node_global\picgo.cmd
>
>`.cmd` 文件是在 Python 脚本中调用的命令行入口

## 3.配置picgo的配置

![image-20250627110648467](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/06/27/cbe590f4029be1f7e84b5bd780dc47e5-image-20250627110648467-8c98b9.png)



`config.json`

```
{
  "picBed": {
    "uploader": "githubPlus",
    "current": "githubPlus",
    "githubPlus": {
      "repo": "joshzhong66/Pibced",
      "branch": "main",
      "token": "you_api_token",
      "path": "blog-images",
      "customUrl": "",
      "origin": "github"
    }
  },
  "picgoPlugins": {
    "picgo-plugin-github-plus": true,
    "picgo-plugin-rename-file": true
  },
  "picgo-plugin-github-plus": {
    "lastSync": "2025-06-27 11:06:50"
  },
  "picgo-plugin-rename-file": {
    "format": "{y}/{m}/{d}/{hash}-{origin}-{rand:6}"
  }
}
```







