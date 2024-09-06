# 普通pc部署esxi

>正常普通电脑安装都会报错，因为缺失网卡驱动
>
>参考博客：https://www.cnblogs.com/Sunzz/p/11438066.html



安装完成后，如果此前磁盘是其他格式的分区，可以通过以下命令进行配置

### 1.查看文件系统

1.`df -lh` 命令显示当前挂载的文件系统

```
Filesystem   Size   Used Available Use% Mounted on
VMFS-6     216.0G   1.4G    214.6G   1% /vmfs/volumes/datastore1
vfat       285.8M 173.8M    112.0M  61% /vmfs/volumes/66af2284-2a97d1ec-5741-d45d6406a2f3
vfat         4.0G   3.5M      4.0G   0% /vmfs/volumes/66af22a6-0d91df8d-8823-d45d6406a2f3
vfat       249.7M   4.0K    249.7M   0% /vmfs/volumes/95e0617d-4d6a7d3b-2468-2c90dc852dca
vfat       249.7M 149.5M    100.2M  60% /vmfs/volumes/ddfcf874-0af85ec7-f29d-d137b9bbb102
```





### 2.查看硬盘总数

执行`esxcli storage core device list` 命令，查看esxi主机存储硬盘总数

```
#显示了三个存储设备：
t10.ATA_____WD40EFRX2D2D2D68W320NO0__________________________PL2331LAH5184J
t10.ATA_____Colorful_SL500_240G_____________________AA000000000000001787
t10.ATA_____WD40EFRX2D2D68W320NO____1_________________PBKATDHS____________
```

1. 显示目前esxi使用的存储（如果你只装其中一块破，那么这个正常也就是系统安装盘）

   执行命令`esxcli storage vmfs extent list` 

   ```
   #显示现有的数据存储：
   Volume Name  VMFS UUID                            Extent Number  Device Name                                                               Partition
   -----------  -----------------------------------  -------------  ------------------------------------------------------------------------  ---------
   datastore1   66af22a6-ea55e212-86a7-d45d6406a2f3              0  t10.ATA_____Colorful_SL500_240G_____________________AA000000000000001787          3
   ```

>解释：
>
>- 当前已经有一个数据存储 `datastore1`，挂载在 `Colorful_SL500_240G` 设备上。
>- 另外两个设备 `WD40EFRX-68W320NO0` 和 `WD40EFRX-68W320NO1` 没有挂载。



### 3.查看未格式化的磁盘

**查看未格式化的磁盘** 确保这两块盘没有现有的分区：

```
[root@localhost:~] partedUtil getptbl /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D2D68W320NO0__________________________PL2331LAH5184J
gpt
486401 255 63 7814037168
1 8192 16785407 A19D880F05FC4D3BA006743F0F84911E unknown 0
2 16785408 20979711 A19D880F05FC4D3BA006743F0F84911E unknown 0
3 21241856 7813832351 A19D880F05FC4D3BA006743F0F84911E unknown 0
[root@localhost:~] partedUtil getptbl /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D68W320NO____1_________________PBKATDHS____________
gpt
486401 255 63 7814037168
1 8192 16785407 A19D880F05FC4D3BA006743F0F84911E unknown 0
2 16785408 20979711 A19D880F05FC4D3BA006743F0F84911E unknown 0
3 21241856 7813832351 A19D880F05FC4D3BA006743F0F84911E unknown 0
```



### 4.删除现有分区

使用 `partedUtil` 删除现有分区。

```
#对于 t10.ATA_____WD40EFRX2D2D2D68W320NO0__________________________PL2331LAH5184J：

partedUtil delete /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D2D68W320NO0__________________________PL2331LAH5184J 1
partedUtil delete /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D2D68W320NO0__________________________PL2331LAH5184J 2
partedUtil delete /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D2D68W320NO0__________________________PL2331LAH5184J 3



#对于 t10.ATA_____WD40EFRX2D2D68W320NO____1_________________PBKATDHS____________：

partedUtil delete /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D68W320NO____1_________________PBKATDHS____________ 1
partedUtil delete /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D68W320NO____1_________________PBKATDHS____________ 2
partedUtil delete /vmfs/devices/disks/t10.ATA_____WD40EFRX2D2D68W320NO____1_________________PBKATDHS____________ 3

```



### 5.挂载存储

一般到esxi的web后台操作更方便，然，如果不把这些硬盘以及存在的数据格式化，挂载不了，所以用命令合适。