# journalctl命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `journalctl` 命令用法。

## 一、简介

`journalctl` 是 `systemd` 提供的日志查看工具，用于查看和管理 `systemd-journald` 维护的日志。它比传统的 `syslog` 方式更强大，能够按时间、服务、用户等多种方式筛选和过滤日志。



## 二、选项

|        选项         |                      说明                      |
| :-----------------: | :--------------------------------------------: |
|    `-a`, `--all`    |    显示所有日志条目，包括可能被截断的长消息    |
|   `-b`, `--boot`    |            显示当前或指定启动的日志            |
|        `-c`         |        兼容旧版 `journalctl`（已废弃）         |
| `-D`, `--directory` |                指定其他日志目录                |
|   `--disk-usage`    |             显示日志占用的磁盘空间             |
|      `--flush`      |           强制刷新日志数据到持久存储           |
|        `-e`         |               跳转到最新日志条目               |
|  `-f`, `--follow`   |         实时跟踪日志（类似 `tail -f`）         |
|   `-h`, `--help`    |                  显示帮助信息                  |
|   `-k`, `--dmesg`   |         仅显示内核日志（类似 `dmesg`）         |
|   `-m`, `--merge`   |             合并多个日志目录的数据             |
|   `-n`, `--lines`   |      显示最近的 `N` 行日志（默认 10 行）       |
|  `-o`, `--output`   |  指定日志输出格式（json、short、verbose 等）   |
| `-p`, `--priority`  | 按日志级别筛选（0-7，对应 emergency 到 debug） |
|   `-q`, `--quiet`   |              静默模式（减少输出）              |
|  `-r`, `--reverse`  |           逆序显示日志（最新的在前）           |
|   `-u`, `--unit`    |         仅显示指定 systemd 单元的日志          |
|        `-x`         |               显示附加的解释信息               |
|  `--after-cursor`   |              仅显示游标之后的日志              |
|  `--before-cursor`  |              仅显示游标之前的日志              |
|      `--field`      |             显示日志可用的字段名称             |
|   `--identifier`    |             仅显示指定标识符的日志             |
|   `--list-boots`    |             显示系统启动的时间索引             |
|    `--new-id128`    |           生成新的 `journal` 标识符            |
|    `--no-pager`     |                  禁用分页输出                  |
|   `--setup-keys`    |          设置 FSS 密钥，用于加密日志           |
|      `--since`      |             显示指定时间之后的日志             |
|      `--until`      |             显示指定时间之前的日志             |
|       `--utc`       |              以 UTC 时间显示日志               |
|     `--verify`      |               检查日志文件完整性               |
|     `--version`     |             显示 `journalctl` 版本             |
|    `--this-boot`    |              仅显示当前启动的日志              |
|      `--user`       |               显示当前用户的日志               |
|     `--system`      |                  显示系统日志                  |
|     `--no-tail`     |          显示完整日志，不进行自动滚动          |



## 三、示例

1. **查看系统日志：**

   ```bash
   journalctl
   ```

   显示所有系统日志，默认按照时间顺序排列。

2. **查看最新日志（实时刷新）：**

   ```bash
   journalctl -f
   ```

   类似 `tail -f /var/log/messages`，实时滚动显示最新日志。

3. **按时间筛选日志：**

   ```bash
   journalctl --since "2025-03-20 10:00:00"
   journalctl --since "1 hour ago"
   journalctl --since yesterday --until today
   ```

   显示特定时间范围的日志。

4. **按服务筛选日志：**

   ```bash
   journalctl -u zabbix_server
   journalctl -u nginx --since "30 min ago"
   ```

   仅查看某个 `systemd` 服务的日志。

5. **按优先级筛选日志：**

   ```bash
   journalctl -p err
   journalctl -p warning..crit
   ```

   只查看 `err` 级别以上的错误日志。

6. **查看系统最近一次启动的日志：**

   ```bash
   journalctl -b
   ```

   `-b -1` 查看上次启动日志，`-b -2` 查看上上次启动日志。

7. **查看特定进程（PID）的日志：**

   ```bash
   journalctl _PID=1234
   ```

   只显示 `PID=1234` 的进程日志。

8. **按用户筛选日志：**

   ```bash
   journalctl _UID=1000
   ```

   只查看 `UID=1000` 用户的日志。

9. **查看内核日志（dmesg 替代品）：**

   ```bash
   journalctl -k
   ```

   仅显示内核日志。

10. **导出日志到文件：**

    ```bash
    journalctl -u zabbix_server > zabbix.log
    ```

    将 `zabbix_server` 的日志导出到 `zabbix.log`。

11. **清理日志：**

    - 定期手动清理：
    
      ```bash
      # 临时手动执行
      journalctl --vacuum-size=500M   # 限制日志大小
      journalctl --vacuum-time=10d    # 保留最近10天的日志
      
      # 或用cron定时任务（编辑crontab -e）
      0 * * * * /usr/bin/journalctl --vacuum-size=500M
      ```
    
    - 配置持久化限制：
    
      - 修改 `systemd-journald` 配置文件，永久限制日志大小：
    
        ```bash
        vim /etc/systemd/journald.conf
        
        # 取消注释或添加以下参数
        [Journal]
        SystemMaxUse=500M    # 持久限制日志最大占用500MB
        #RuntimeMaxUse=500M  # 如果仅限制运行时日志（可选）
        ```
    
      - 重启日志服务生效：
    
        ```bash
        systemctl restart systemd-journald
        ```
    
      - 检查当前生效配置：
    
        ```bash
        journalctl --disk-usage
        ```
    
        
    
        
    
      