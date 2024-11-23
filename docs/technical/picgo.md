

使用picgo安装图床失败，提示操作系统拒绝了该操作。解决办法：需要以管理员身份运行picgo，日志如下：

>2024-11-22 10:17:27 [PicGo ERROR] 插件安装失败，失败码为1，错误日志为 
>[1mnpm[22m [31merror[39m The operation was rejected by your operating system.
>[1mnpm[22m [31merror[39m It's possible that the file was already in use (by a text editor or antivirus),
>[1mnpm[22m [31merror[39m or that you lack permissions to access it.
>[1mnpm[22m [31merror[39m
>[1mnpm[22m [31merror[39m If you believe this might be a permissions issue, please double-check the
>[1mnpm[22m [31merror[39m permissions of the file and its containing directories, or try running
>[1mnpm[22m [31merror[39m the command again as root/Administrator.
>[1mnpm[22m [31merror[39m Log files were not written due to an error writing to the directory: C:\Program Files\nodejs\node_cache\_logs
>[1mnpm[22m [31merror[39m You can rerun the command with `--loglevel=verbose` to see the logs in your terminal



