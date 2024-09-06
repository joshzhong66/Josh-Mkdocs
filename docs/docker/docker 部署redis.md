# docker部署redis

Redis是一款开源的高性能键值存储数据库，广泛应用于缓存、队列、实时分析等场景。使用Docker部署Redis可以简化安装和配置过程，提高部署效率。本文将介绍如何使用Docker部署Redis，并提供更详细的扩展内容，让你能够更好地理解和应用Redis。

## 一、拉取Redis镜像

以Redis 6.0.8为例，可以使用以下命令从Docker Hub上拉取Redis镜像：

```bash
docker pull redis:6.0.8
```

## 二、Redis安装

### （1）简单版Redis

**1、简单版Redis容器的创建启动**

命令如下：

```bash
docker run -p 6379:6379 -d redis:6.0.8
```

简单版Redis没有配置容器卷映射，当容器被删除时数据无法恢复。适用于测试和开发环境。



**2、连接redis容器**

执行命令```docker exec -it 容器id /bin/bash``连接容器（容器id获取：docker ps）

```
docker exec -it 8009fd9e4739 /bin/bash
```

**3、操作redis测试**

将键"username"的值设置为"scott"，并返回"OK"表示设置成功。

```
127.0.0.1:6379> set username scott
OK
```
获取键"username"的值，并返回"scott"，表示成功获取到了之前设置的值。

```
127.0.0.1:6379> get username
"scott"
```
删除键"username"，并返回整数1，表示成功删除了一个键。

```
127.0.0.1:6379> del username
(integer) 1
```
通过以上操作，成功地连接到Redis，并进行了设置值、获取值和删除键的操作。





### （2）实际应用版Redis

实际应用中，我们通常需要将Redis的配置文件和数据文件与宿主机进行映射，以便于配置和数据的管理。

**步骤：**

1. 在宿主机上创建目录，用于存放Redis的配置文件和数据文件：

```bash
mkdir -p /app/redis
```

2. 在/app/redis目录下创建文件redis.conf，并进行相应的配置修改。以下是一些常用的配置项：

   - 开启密码验证（可选）：

     ```conf
     requirepass 123
     ```

   - 允许Redis外部连接，需要注释掉绑定的IP：

     ```conf
     # bind 127.0.0.1
     ```

   - 关闭保护模式（可选）：

     ```conf
     protected-mode no
     ```

   - 注释掉daemonize yes，或者配置成daemonize no。因为该配置和docker run中的-d参数冲突，会导致容器一直启动失败：

     ```conf
     daemonize no
     ```

   - 开启Redis数据持久化（可选）：

     ```conf
     appendonly yes
     ```

   最终的配置文件内容如下：

   ```conf
   # 开启密码验证（可选）
   requirepass 123
   # 允许Redis外部连接，需要注释掉绑定的IP
   # bind 127.0.0.1
   # 关闭保护模式（可选）
   protected-mode no
   # 注释掉daemonize yes，或者配置成daemonize no。因为该配置和docker run中的-d参数冲突，会导致容器一直启动失败
   daemonize no
   # 开启Redis数据持久化（可选）
   appendonly yes
   ```

3. 启动Redis容器，并指定容器运行的命令为`redis-server`以使用自定义的配置文件：

```bash
docker run -d -p 6379:6379 \
--name redis \
--privileged=true \
-v /app/redis/redis.conf:/etc/redis/redis.conf \
-v /app/redis/data:/data \
redis:6.0.8 redis-server /etc/redis/redis.conf
```

通过上述命令，我们将Redis容器的6379端口映射到宿主机的6379端口，同时将配置文件和数据文件与宿主机进行映射。这样，我们可以方便地修改配置和管理数据。

以上就是使用Docker部署Redis的简单步骤。接下来，我们可以进一步了解Redis的高可用部署、集群模式等内容，以满足不同场景的需求。





### （3）集群部署Redis

**搭建3主3从的Redis集群，每台主机都对应一台从机。**



#### 1、启动6台redis容器

启动6台节点的命令：

```bash
# 启动第1台节点
docker run -d --name redis-node-1 --net host --privileged=true -v /app/redis-cluster/share/redis-node-1:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6381

# 启动第2台节点
docker run -d --name redis-node-2 --net host --privileged=true -v /app/redis-cluster/share/redis-node-2:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6382

# 启动第3台节点
docker run -d --name redis-node-3 --net host --privileged=true -v /app/redis-cluster/share/redis-node-3:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6383

# 启动第4台节点
docker run -d --name redis-node-4 --net host --privileged=true -v /app/redis-cluster/share/redis-node-4:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6384

# 启动第5台节点
docker run -d --name redis-node-5 --net host --privileged=true -v /app/redis-cluster/share/redis-node-5:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6385

# 启动第6台节点
docker run -d --name redis-node-6 --net host --privileged=true -v /app/redis-cluster/share/redis-node-6:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6386


```

这条命令将启动第2台Redis节点，并配置它作为Redis集群的一部分。参数解释如下：

- `-d`：以后台模式运行容器。
- `--name redis-node-xx`：指定容器的名称为redis-node xx。
- `--net host`：使用宿主机的网络设置。
- `--privileged=true`：在容器内启用特权模式，以便容器可以执行一些特权操作。
- `-v /app/redis-cluster/share/redis-node-2:/data`：将宿主机的`/app/redis-cluster/share/redis-node-2`目录映射到容器内的`/data`目录，用于持久化Redis数据。
- `redis:6.0.8`：使用Redis 6.0.8镜像。
- `--cluster-enabled yes`：开启Redis集群模式。
- `--appendonly yes`：开启Redis的AOF持久化。
- `--port 6382`：配置Redis节点的端口号为6382。

通过运行以上命令，你将成功启动第2台Redis节点，并使其成为Redis集群的一部分。你可以根据需要修改命令中的参数来启动其他节点。





#### 2、构建主从关系

接下来是构建主从关系的步骤：

1. 首先，进入任意一个节点（这里以节点1为例）：

```bash
docker exec -it redis-node-1 /bin/bash
```

2. 在节点1的容器中，执行以下命令来构建主从关系：

```bash
redis-cli --cluster create 192.168.xxx.xxx:6381 192.168.xxx.xxx:6382 192.168.xxx.xxx:6383 192.168.xxx.xxx:6384 192.168.xxx.xxx:6385 192.168.xxx.xxx:6386 --cluster-replicas 1
```

其中，`192.168.xxx.xxx`是宿主机的IP地址，后面的端口号分别对应每个节点的Redis端口号。`--cluster-replicas 1`表示为每个主节点创建一个从节点。

3. 执行上述命令后，Redis会尝试自动进行主从节点的分配。由于我们在Docker容器中使用的IP地址相同，可能会出现警告，但可以忽略该警告。

4. 当Redis完成自动分配后，会显示分配结果，需要输入`Yes`确认配置信息。

```bash
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.31.223:6385 to 192.168.31.223:6381
Adding replica 192.168.31.223:6386 to 192.168.31.223:6382
Adding replica 192.168.31.223:6384 to 192.168.31.223:6383
>>> Trying to optimize slaves allocation for anti-affinity
[WARNING] Some slaves are in the same host as their master
M: 0c54ff47b1cb373485bfbdd964a618ecea76bb29 192.168.31.223:6381   slots:[0-5460] (5461 slots) master
M: 703a1f294087c009d04eda5acf2c4255ce14c28a 192.168.31.223:6382   slots:[5461-10922] (5462 slots) master
M: 30e2409b3031a0c927efe75b56909bec5281c3d8 192.168.31.223:6383   slots:[10923-16383] (5461 slots) master
S: 03d3bd91c1df1e618a5b887b24b510466efa55a3 192.168.31.223:6384   replicates 30e2409b3031a0c927efe75b56909bec5281c3d8
S: fef4eee9045d7c434c3f22b36eb16391f1078f59 192.168.31.223:6385   replicates 0c54ff47b1cb373485bfbdd964a618ecea76bb29
S: 44950ffde9147011c424e906a0e1f001c1c17a71 192.168.31.223:6386   replicates 703a1f294087c009d04eda5acf2c4255ce14c28a
Can I set the above configuration? (type 'yes' to accept): yes
```

5. 在确认配置信息后，Redis会向其他节点发送信息加入集群，并分配哈希槽。

```bash
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join ...
>>> Performing Cluster Check (using node 192.168.31.223:6381)
M: 0c54ff47b1cb373485bfbdd964a618ecea76bb29 192.168.31.223:6381   slots:[0-5460] (5461 slots) master   1 additional replica(s)
M: 703a1f294087c009d04eda5acf2c4255ce14c28a 192.168.31.223:6382   slots:[5461-10922] (5462 slots) master   1 additional replica(s)
S: 03d3bd91c1df1e618a5b887b24b510466efa55a3 192.168.31.223:6384   slots: (0 slots) slave   replicates 30e2409b3031a0c927efe75b56909bec5281c3d8
S: 44950ffde9147011c424e906a0e1f001c1c17a71 192.168.31.223:6386   slots: (0 slots) slave   replicates 703a1f294087c009d04eda5acf2c4255ce14c28a
M: 30e2409b3031a0c927efe75b56909bec5281c3d8 192.168.31.223:6383   slots:[10923-16383] (5461 slots) master   1 additional replica(s)
S: fef4eee9045d7c434c3f22b36eb16391f1078f59 192.168.31.223:6385   slots: (0 slots) slave   replicates 0c54ff47b1cb373485bfbdd964a618ecea76bb29
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

完成以上步骤后，你将成功构建了一个包含3个主节点和3个从节点的Redis集群，并完成了主从关系的配置。你可以根据需要修改命令中的IP地址和端口号来适应你的环境。





#### 3、查看集群状态

查看集群状态的步骤：

1. 首先，进入任意一个节点（这里以节点1为例）：

```bash
docker exec -it redis-node-1 /bin/bash
```

2. 在节点1的容器中，使用以下命令连接到节点1的Redis实例（端口号为6381）：

```bash
redis-cli -p 6381
```

3. 使用Redis的相关命令来查看集群状态：

```bash
cluster info
```

执行上述命令后，将显示集群的状态信息，包括分配的哈希槽数量、集群节点数量等：

```
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:560
cluster_stats_messages_pong_sent:564
cluster_stats_messages_sent:1124
cluster_stats_messages_ping_received:559
cluster_stats_messages_pong_received:560
cluster_stats_messages_meet_received:5
cluster_stats_messages_received:1124
```

4. 如果想查看集群的节点信息，可以使用以下命令：

```bash
cluster nodes
```

执行上述命令后，将显示集群中所有节点的信息，包括节点的ID、IP地址、端口号等。

通过以上步骤，你可以查看Redis集群的状态信息和节点信息，以确保集



#### 4、集群读写出错

处理集群读写出错的步骤：

1. 首先，进入任意一个节点（这里以节点1为例）：

```bash
docker exec -it redis-node-1 /bin/bash
```

2. 在节点1的容器中，使用以下命令连接到节点1的Redis实例（端口号为6381），并不加`-c`参数：

```bash
redis-cli -p 6381
```

3. 在没有使用`-c`参数的情况下，尝试向Redis中添加键值对，可能会成功，也可能会失败。举例来说，执行以下命令：

```bash
set k1 v1
```

如果键`k1`经过计算得到的哈希槽为12706，但当前连接的Redis服务器为6381（即节点1），它的哈希槽范围是[0,5460]（在创建构建主从关系时Redis有提示，也可以通过`cluster nodes`查看），因此会因为不在范围内而报错。而执行`set k2 v2`可以成功，因为`k2`计算出的哈希槽在[0-5460]范围中。

```
127.0.0.1:6381> set k1 v1
(error) MOVED 12706 192.168.31.223:6383
127.0.0.1:6381> set k2 v2
OK
```

4. 为了解决这个问题，需要使用带有`-c`参数的`redis-cli`命令来连接集群。`-c`表示连接到集群，可以正常地插入所有数据。执行以下命令：

```bash
redis-cli -p 6381 -c
```

连接成功后，可以执行命令插入数据，例如：

```bash
127.0.0.1:6381> set k1 v1
-> Redirected to slot [12706] located at 192.168.31.223:6383
OK
```

会有提示信息显示，哈希槽为12706，重定向到6383（即节点3，哈希槽范围为[10923, 16383]）。这样就可以成功地插入数据了。



#### 5、检查集群信息

以下是检查集群信息的步骤：

1. 首先，进入任意一个节点（这里以节点1为例）：

```bash
docker exec -it redis-node-1 /bin/bash
```

2. 在节点1的容器中，使用以下命令来检查集群信息：

```bash
redis-cli --cluster check 192.168.xxx.xxx:6381
```

其中，`192.168.xxx.xxx:6381`是任意一个主节点的地址，可以选择其中一个主节点进行检查。

3. 执行以上命令后，将返回集群的检查结果。例如：

```bash
192.168.31.223:6381 (0c54ff47...) -> 1 keys | 5461 slots | 1 slaves.
192.168.31.223:6382 (703a1f29...) -> 0 keys | 5462 slots | 1 slaves.
192.168.31.223:6383 (30e2409b...) -> 1 keys | 5461 slots | 1 slaves.
[OK] 2 keys in 3 masters. 0.00 keys per slot on average.
```

该结果显示了每个节点存储的键的数量、哈希槽的分布情况以及从节点的数量。

4. 检查主从关系的信息，执行以上命令后会显示主从节点的信息，例如：

```bash
>>> Performing Cluster Check (using node 192.168.31.223:6381)
M: 0c54ff47b1cb373485bfbdd964a618ecea76bb29 192.168.31.223:6381   slots:[0-5460] (5461 slots) master   1 additional replica(s)
M: 703a1f294087c009d04eda5acf2c4255ce14c28a 192.168.31.223:6382   slots:[5461-10922] (5462 slots) master   1 additional replica(s)
S: 03d3bd91c1df1e618a5b887b24b510466efa55a3 192.168.31.223:6384   slots: (0 slots) slave   replicates 30e2409b3031a0c927efe75b56909bec5281c3d8
S: 44950ffde9147011c424e906a0e1f001c1c17a71 192.168.31.223:6386   slots: (0 slots) slave   replicates 703a1f294087c009d04eda5acf2c4255ce14c28a
M: 30e2409b3031a0c927efe75b56909bec5281c3d8 192.168.31.223:6383   slots:[10923-16383] (5461 slots) master   1 additional replica(s)
S: fef4eee9045d7c434c3f22b36eb16391f1078f59 192.168.31.223:6385   slots: (0 slots) slave   replicates 0c54ff47b1cb373485bfbdd964a618ecea76bb29
```

该结果显示了每个节点的角色（主节点或从节点）、哈希槽的范围、从节点的复制关系等信息。

5. 最后，检查哈希槽的覆盖情况，执行以上命令后会显示哈希槽的覆盖情况，例如：

```bash
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

该结果表示所有的16384个哈希槽都被覆盖了，没有未分配的哈希槽。

通过以上步骤，可以检查集群的信息、主从关系以及哈希槽的覆盖情况，确保集群正常运行。



#### 6、主从扩容

假设由于业务量激增，需要将当前的3主3从集群扩容，加入1个主节点和1个从节点。

以下是具体操作步骤：

1. 启动两个新的容器节点。

   ```
   # 启动第7台节点
   docker run -d --name redis-node-7 --net host --privileged=true -v /app/redis-cluster/share/redis-node-7:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6387

   # 启动第8台节点
   docker run -d --name redis-node-8 --net host --privileged=true -v /app/redis-cluster/share/redis-node-8:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6388
   ```

2. 进入6387节点（第7台节点）的容器内部。

   ```
   docker exec -it redis-node-7 /bin/bash
   ```

3. 将6387节点作为主节点加入集群。

   ```
   # 使用redis-cli命令将本节点加入到集群中的任一节点
   redis-cli --cluster add-node 192.168.xxx.xxx:6387 192.168.xxx.xxx:6381
   ```

   这里的`192.168.xxx.xxx:6387`是当前节点的地址，而`192.168.xxx.xxx:6381`是集群中的任一节点地址。

请注意，上述步骤中的IP地址和端口号需要根据实际情况进行替换。另外，对于第8台节点，可以按照相似的步骤将其加入集群。完成这些步骤后，你将成功扩容主从集群。



4. 检查当前集群状态

运行以下命令来检查集群的状态：

```
redis-cli --cluster check 192.168.xxx.xxx:6381
```

这将显示集群的状态信息。在这里，你可以发现6387节点已经作为主节点成功加入了集群，但是该节点尚未被分配任何槽位。

5. 重新分配集群的槽位

使用以下命令重新分配集群的槽位：

```
redis-cli --cluster reshard 192.168.xxx.xxx:6381
```

执行此命令后，Redis会提示你需要分配的槽位数量。例如，假设你现在有4个主节点，你想给node7分配4096个槽位，使得每个节点都有4096个槽位。输入4096后，Redis会要求你输入要接收这些哈希槽位的节点ID，填入node7的节点ID（节点ID是一长串十六进制字符串，如0abc6c68790b604e8a418a3f6f3bfd4ef442a3a0）即可。

接下来，Redis会询问你从哪些节点中拨出一部分槽位来凑足4096个槽位，以分配给Node7。一般选择"all"，即将之前的3个主节点的槽位均匀分配给Node7，以实现每个节点的槽位数均衡。输入"all"后，Redis会列出一个计划，显示自动从前面的3个主节点中拨出一部分槽位分配给Node7。你需要确认此分配计划。输入"yes"确认后，Redis将自动重新分配槽位，将其分配给Node7。

完成以上步骤后，Redis会重新洗牌并分配槽位，确保Node7获得了相应的槽位。



重新分配完成后，你可以运行以下命令检查集群信息，查看槽位的重新分配结果：

```
redis-cli --cluster check 192.168.xxx.xxx:6381
```

运行该命令后，你将看到槽位的重新分配情况。例如：

```
192.168.31.223:6381 (0c54ff47...) -> 0 keys | 4096 slots | 1 slaves.
192.168.31.223:6382 (703a1f29...) -> 0 keys | 4096 slots | 1 slaves.
192.168.31.223:6383 (30e2409b...) -> 1 keys | 4096 slots | 1 slaves.
192.168.31.223:6387 (0abc6c68...) -> 1 keys | 4096 slots | 0 slaves.

[OK] 2 keys in 4 masters. 0.00 keys per slot on average.
```

这里显示了每个节点的信息，包括节点的IP地址、端口号、节点ID以及分配的槽位情况。你可以根据这些信息确认槽位的重新分配结果。

最后，Redis会进行一次集群检查，确保槽位的分配没有问题。

```
>>> Performing Cluster Check (using node 192.168.31.223:6381)
M: 0c54ff47b1cb373485bfbdd964a618ecea76bb29 192.168.31.223:6381   slots:[1365-5460] (4096 slots) master   1 additional replica(s)
M: 703a1f294087c009d04eda5acf2c4255ce14c28a 192.168.31.223:6382   slots:[6827-10922] (4096 slots) master   1 additional replica(s)
S: 03d3bd91c1df1e618a5b887b24b510466efa55a3 192.168.31.223:6384   slots: (0 slots) slave   replicates 30e2409b3031a0c927efe75b56909bec5281c3d8
S: 44950ffde9147011c424e906a0e1f001c1c17a71 192.168.31.223:6386   slots: (0 slots) slave   replicates 703a1f294087c009d04eda5acf2c4255ce14c28a
M: 30e2409b3031a0c927efe75b56909bec5281c3d8 192.168.31.223:6383   slots:[12288-16383] (4096 slots) master   1 additional replica(s)
M: 0abc6c68790b604e8a418a3f6f3bfd4ef442a3a0 192.168.31.223:6387    #节点id：0abc6c68790b604e8a418a3f6f3bfd4ef442a3a0   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
S: fef4eee9045d7c434c3f22b36eb16391f1078f59 192.168.31.223:6385   slots: (0 slots) slave   replicates 0c54ff47b1cb373485bfbdd964a618ecea76bb29

[OK] All nodes agree about slots configuration.
```

这里显示了每个节点的详细信息，包括主节点、从节点、槽位范围等。最后，Redis会检查是否存在未分配的槽位以及槽位的覆盖情况，确保所有的16384个槽位都得到了覆盖。

通过执行以上步骤，你已经成功地扩容了主从集群，并重新分配了槽位，使得每个节点都具有相等数量的槽位。





如果你想为主节点6387分配从节点6388，并且希望从前三个节点中分配一部分槽位给节点7，可以执行以下步骤：

1. 首先，使用以下命令将节点6388添加到集群中作为节点6387的从节点：

```
redis-cli --cluster add-node 192.168.xxx.xxx:6388 192.168.xxx.xxx:6387 --cluster-slave --cluster-master-id <node7节点的ID>
```

这将使节点6388加入集群，并成为节点6387的从节点。Redis会向节点6388发送消息，使其加入集群并与节点6387建立主从复制关系。

2. 接下来，你需要手动将一部分槽位从前三个节点中分配给节点7（即节点6388）。可以使用以下命令将槽位从节点1、节点2和节点3中迁移给节点7：

```
redis-cli --cluster reshard 192.168.xxx.xxx:6381 --cluster-from <node1节点的ID> --cluster-to <node7节点的ID> --cluster-slots <槽位数量> --cluster-yes
redis-cli --cluster reshard 192.168.xxx.xxx:6381 --cluster-from <node2节点的ID> --cluster-to <node7节点的ID> --cluster-slots <槽位数量> --cluster-yes
redis-cli --cluster reshard 192.168.xxx.xxx:6381 --cluster-from <node3节点的ID> --cluster-to <node7节点的ID> --cluster-slots <槽位数量> --cluster-yes
```

在上述命令中，将 `<node1节点的ID>`、`<node2节点的ID>` 和 `<node3节点的ID>` 替换为实际节点1、节点2和节点3的ID。将 `<node7节点的ID>` 替换为节点7（即节点6388）的ID。`<槽位数量>` 是你想要迁移的槽位数量。

3. 完成槽位迁移后，你可以使用以下命令检查集群的当前状态：

```
redis-cli --cluster check 192.168.xxx.xxx:6381
```

这个命令将显示集群的信息，包括每个节点的角色、槽位分配情况和从节点信息。

通过执行以上步骤，你可以将节点6388添加为节点6387的从节点，并从前三个节点中迁移一部分槽位给节点6388。最后，你可以使用 `redis-cli --cluster check` 命令来验证集群的状态。



#### 7、主从缩容



如果你想将主从集群从4主4从缩容到3主3从，并移除节点8和节点7，可以按照以下步骤进行操作：

**1. 删除从节点6388：**

首先，进入容器节点1，可以使用以下命令：

```
docker exec -it redis-node-1 /bin/bash
```

然后，检查容器状态，获取节点6388的节点编号，可以使用以下命令：

```
redis-cli --cluster check 192.168.xxx.xxx:6381
```

接下来，使用以下命令将节点6388从集群中移除：

```
redis-cli --cluster del-node 192.168.xxx.xxx:6388 <6388节点编号>
```

请将 `<6388节点编号>` 替换为实际的节点6388的编号。

**2. 对节点7重新分配哈希槽：**

首先，使用以下命令对集群进行哈希槽的重新分配：

```
redis-cli --cluster reshard 192.168.xxx.xxx:6381
```

Redis会提示你输入要移动的槽位数量。如果你想将节点7的所有4096个哈希槽都分配给某个节点，可以直接输入4096。

然后，Redis会要求你输入要接收这些哈希槽的节点ID。假设你想将这4096个槽位都分配给节点1，直接输入节点1的编号即可。

接下来，Redis会询问你要从哪些节点中移动一部分槽位以满足4096个槽位分配给节点1。在这里，你需要输入节点7的节点编号，然后按回车，最后输入"done"表示完成。

一旦节点7上没有哈希槽，你就可以将节点7从集群中移除。使用以下命令将节点7从集群中移除：

```
redis-cli --cluster del-node 192.168.xxx.xxx:6387 <node7节点编号>
```

请将 `<node7节点编号>` 替换为实际的节点7的编号。

通过执行以上步骤，你可以将主从集群从4主4从缩容到3主3从，并移除节点8和节点7。请确保在移除节点之前，节点7上没有任何哈希槽。



## 三、自定义配置文件启动redis

**redis使用自定义配置文件启动**



1、创建持久化挂载redis配置文件

```
mkdir -p /data/docker/redis
vim redis.conf

#写入内容：
appendonly yes
requirepass 123456
```



创建数据挂载目录

```
mkdir -p /data/docker/data
```

创建日志挂载文件

```
touch /data/docker/redis/logs
```



启动redis容器命令：

```
docker run -v /data/docker/redis/redis.conf:/etc/redis/redis.conf \
-v /data/docker/redis/data:/data \
-v /data/docker/redis/logs:/var/log/redis \
-d --name redis \
-p 6379:6379 \
redis:latest  redis-server /etc/redis/redis.conf

```

- `-v /data/docker/redis/redis.conf:/etc/redis/redis.conf`：使用卷挂载功能，将本地文件 `/data/docker/redis/redis.conf` 挂载到容器内的 `/etc/redis/redis.conf` 文件。这样可以在容器中使用自定义的 Redis 配置文件。
- `-v /data/docker/redis/data:/data`：使用卷挂载功能，将本地目录 `/data/docker/redis/data` 挂载到容器内的 `/data` 目录。这样可以将 Redis 数据持久化到本地目录。
- ```-v /data/docker/redis/logs:/var/log/redis ```挂载本地目录 /data/docker/redis/logs 到容器内的 Redis 日志文件位置 /var/log/redis
- `-d`：以后台模式运行容器。
- `--name myredis`：为容器指定一个名称，这里是 "myredis"。
- `-p 6379:6379`：将容器内的端口 6379 映射到主机的端口 6379。这样可以通过主机的端口访问 Redis 服务。
- `redis:latest`：基于 Redis 镜像运行容器，使用最新的标签。
- `redis-server /etc/redis/redis.conf`：在容器内部执行的命令，启动 Redis 服务并指定配置文件为 `/etc/redis/redis.conf`。





## 四、redis客户端连接





## 五、扩展内容

1. Redis高可用部署：介绍Redis Sentinel和Redis Cluster两种常见的高可用部署方案，以保证Redis的可靠性和容错性。

2. Redis持久化配置：详细介绍Redis的持久化机制，包括RDB快照和AOF日志，以及如何根据实际需求进行配置。

3. Redis性能优化：提供一些常见的Redis性能优化技巧，包括使用连接池、合理设置过期时间、优化数据结构等。

4. Redis应用场景：介绍Redis在缓存、队列、实时分析等场景中的应用，并提供相应的最佳实践和示例代码。

5. Redis安全配置：讲解如何保护Redis的安全，包括密码认证、网络访问控制等方面的配置。

通过对这些扩展内容的整理和扩展，可以帮助读者更好地理解和应用Redis，以上是关于使用Docker部署Redis的内容扩展和整理，希望对你的学习和工作有所帮助。

