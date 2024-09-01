# docker compose安装及参数说明



## 一、安装docker-copose v1

### 1.下载Docker Compose

可以访问[**官方GitHub仓库**](https://github.com/docker/compose/releases)查找最新版本。以下命令下载一个常用的版本，但请确认是否有更新的版本可用：

```bash
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### 2.赋权使二进制文件可执行

```bash
chmod +x /usr/local/bin/docker-compose
```

### 3.测试安装

```bash
docker-compose --version
```

### 4.启动停止

（1）在后台启动所有服务：

```bash
docker-compose up -d
```

（2）停止并移除所有服务，以及默认创建的网络。如果加上**-v**参数，则同时移除相关的卷：

```bash
docker-compose down
```

（3）查看后台启动日志：

```bash
docker-comose logs 容器id
```

（4）卸载docker compose v1：

```bash
rm -rf /usr/local/bin/docker-compose
```

上述为二进制安装，直接删除二进制文件，即可卸载docker-compose v1。



## 二、安装docker compose v2



### 1.[compose官网下载地址](https://github.com/docker/compose/tags)

下载compose v2：

```bash
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}

mkdir -p $DOCKER_CONFIG/cli-plugins

curl -SL  https://github.com/docker/compose/releases/download/v2.3.4/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
```

### 2.赋权

```bash
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```

### 3.测试安装是否成功

```bash
[root@zhongjl-test-01 /root]# docker compose version
Docker Compose version v2.3.4
```

#### 4.启动方式

```bash
docker compose up -d   # 使用此命令需要在拥有yml文件的目录下执行
```



## 三、相关说明

### 1.`docker-compose up -d` 和 `docker compose up -d` 的区别

​		主要区别在于命令的书写格式。

- `docker-compose up -d`：这是旧版本的 Docker Compose 命令格式。在较早的版本中，使用 `docker-compose` 命令来操作 Docker Compose 相关的功能。因此，`docker-compose up -d` 表示使用 `docker-compose` 工具来启动容器服务并在后台运行。
- `docker compose up -d`：这是新版本 Docker Compose 的命令格式。在较新的版本中，Docker 将 Docker Compose 的功能整合到了 Docker CLI 中，因此可以直接使用 `docker compose` 命令来操作 Docker Compose 相关的功能。所以，`docker compose up -d` 表示使用 Docker CLI 中的 `compose` 子命令来启动容器服务并在后台运行。

​		总的来说，两者的功能是相同的，只是命令格式略有不同。如果你使用的是较新版本的 Docker 和 Docker Compose，可以使用 `docker compose up -d` 来启动容器服务。如果你使用的是较旧版本的 Docker Compose，可以继续使用 `docker-compose up -d` 命令。

### 2.`docker compose up -d` 命令

​		默认情况下会在当前目录下查找 `docker-compose.yml` 或 `docker-compose.yaml` 文件，并基于该文件中定义的服务配置来启动容器服务。如果当前目录下有多个不同的 yml 文件，只有最先找到的文件会被用来启动服务。

​		如果想在不同路径下运行不同的 `docker-compose.yml` 文件，可以在运行命令时指定文件的路径，例如：

```bash
docker compose -f /path/to/your/docker-compose.yml up -d
```

​		这样就可以指定要使用的 `docker-compose.yml` 文件路径，从而确保你运行的是特定路径下的文件中定义的服务。

### 3.`docker compose`中的`version`参数说明

​		用于指定 Docker Compose 文件的语法版本。不同版本的 Docker Compose 文件格式和支持的功能可能有所不同。以下是一些主要版本的说明：

- **Version 1**：初始版本，功能有限，配置较简单。
- **Version 2**：引入了更多高级功能，如多容器应用的编排、网络和卷的管理等。
- **Version 3**：进一步扩展了功能，增加了对 Swarm 模式的支持，更适合于生产环境。

​		在使用 Docker Compose 文件时，建议遵循以下原则：

- **版本选择**: 根据你的需求和 Docker Compose 的版本选择合适的版本。如果你使用的是较新的Docker Compose，建议使用 `version: "3.3"` 或更新版本。
- **兼容性**: 确保 Docker 引擎和 Docker Compose 版本支持你指定的版本。例如，Docker Compose 1.25.0 及以上版本支持 Compose file 3.8。

​		不建议随便更改 `version` 参数，特别是从低版本更改到高版本，因为高版本可能包含一些新特性或改变，而低版本不支持这些特性。

### 4.通过Docker Compose创建后的容器网络

​		通过 Docker Compose 创建的容器会默认加入一个新的网络，网络名称是基于项目名生成的。除非你在Compose文件中明确指定了网络配置。

- **默认行为**: 如果没有在 Compose 文件中定义自定义网络，Docker Compose 会为每个项目创建一个默认的桥接网络，网络名称通常是 `项目名_default`。
- **自定义网络**: 你可以在 Compose 文件中自定义网络，明确定义网络名称和类型。

​		在Docker Compose文件中，定义网络配置时，还可以在`服务级别`或`全局级别`进行配置，分别为以下两种管理网络的方式：

- **显式引用网络**：在每个服务中明确指定使用的网络。
- **全局定义网络**：在全局网络定义部分集中管理，然后在每个服务中引用。

​		实际上，这两种方式在 Docker Compose 文件中的配置非常相似，以至于在文件中看起来几乎一模一样。

### 5.docker-compose中的`-`符号

#### 5.1 什么情况下每个属性前要加`-`

​		在 YAML 文件中，每个属性前是否需要加 `-` 取决于该属性是单独的键值对还是列表项。以下是一些基本规则和示例。

​		**基本规则：**

- **键值对**：当属性是普通的键值对时，不需要在前面加 `-`。
- **列表项**：当属性是列表中的一项时，需要在前面加 `-`。

​		**键值对示例：**

​		普通的键值对不需要在前面加 `-`。

```bash
version: '3'
services:
  app:
    image: myapp:latest
    environment:
      MODE: production
      LOG_LEVEL: INFO
    networks:
      - my_custom_network
```

​		**列表项示例：**

​		当属性是列表中的一项时，需要在前面加 `-`。

```bash
networks:
  my_custom_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16  # 列表项，需要加 -
          gateway: 172.20.0.1
        - subnet: 172.21.0.0/16  # 列表项，需要加 -
          gateway: 172.21.0.1
```

#### 5.2 如何叛变是否为列表项

​		判断是否是列表项主要看上下文，具体有以下几种情况：

- **直接定义列表**：如果一个键对应的是一个列表，那么列表中的每一项前都需要加 `-`。
- **列表中的字典**：列表中的每一项如果是字典，则每个字典前也需要加 `-`。

​		**判断方法和示例：**

- **直接定义列表：**当某个键的值是一个列表时，每个列表项前需要加 `-`。

```bash
services:
  app:
    image: myapp:latest
    networks:
      - my_custom_network  # 这是一个列表项
      - another_network  # 这是一个列表项
```

​		在上面的例子中，`networks` 是一个列表，因此它的每个项都需要加 `-`。

- **列表中的字典：**当某个列表中的每一项是一个字典时，每个字典前也需要加 `-`。

```bash
networks:
  my_custom_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16  # 这是一个列表中的字典项
          gateway: 172.20.0.1
        - subnet: 172.21.0.0/16  # 这是一个列表中的字典项
          gateway: 172.21.0.1
```

​		在这个例子中，`config` 是一个列表，因此每个字典项前需要加 `-`。

#### 5.3 定义服务使用自定义网络的情况

​		在 Docker Compose 文件中，定义服务使用自定义网络时，如果只是简单地将服务连接到一个网络，那么需要使用列表的方式；如果要在网络上设置其他属性（例如 `ipv4_address`），则不需要使用列表，而是直接定义键值对。下面具体解释这两种情况：

- **简单连接网络：**

​		当你只是将服务连接到一个网络，不需要设置额外的属性时，使用列表形式：

```bash
services:
  app:
    image: myapp:latest
    networks:
      - my_custom_network  # 这里是列表项
```

- **连接网络并设置属性：**

​		当你需要为网络配置额外的属性（例如 `ipv4_address`）时，直接在网络下定义键值对：

```bash
services:
  app:
    image: myapp:latest
    networks:
      my_custom_network:
        ipv4_address: 172.20.0.2  # 这里是键值对
```

​		**为什么不同的情况下是否需要 `-`：**

- 在 **简单连接网络** 的情况下，`networks` 是一个列表，每个网络是列表中的一个项，因此每个项前需要 `-`。
- 在 **设置网络属性** 的情况下，`networks` 是一个字典，其中键是网络名，值是另一个字典（这个字典包含了网络的配置），所以不需要 `-`。



## 四、Domain Admin的yml参数说明

```bash
version: '3.3'
services:
  domain-admin:
    volumes:
      - './database:/app/database'
      - './logs:/app/logs'
    ports:
      - '8000:8000'
    container_name: domain-admin
    image: mouday/domain-admin:latest
    network:
      - domain_admin
networks:
  domain_admin:
    name: halo_network
    ipam:
      driver: default
      config:
        - subnet: 172.196.0.0/16
```

### 1.version

​		这是 Docker Compose 文件的版本，定义了使用的语法版本。

### 2.services

​		这是一个顶层键，表示将要定义一组服务。

### 3.domain-admin

​		这是服务的名称。可以通过这个名称来引用这个服务。

### 4.volumes

​		这部分定义了要挂载到容器中的目录。

- `'./database:/app/database'`: 将主机上的 `./database` 目录挂载到容器中的 `/app/database` 目录。这通常用于持久化数据。
- `'./logs:/app/logs'`: 将主机上的 `./logs` 目录挂载到容器中的 `/app/logs` 目录。这通常用于存储日志文件。

### 5.ports

​		这部分定义了端口映射。

- `'8000:8000'`: 将主机上的 8000 端口映射到容器内的 8000 端口。这样你可以通过主机的 8000 端口访问容器内的服务。

### 6.container_name

​		定义了容器的名称，这里将容器命名为 `domain-admin`。

### 7.image

​		指定了要使用的 Docker 镜像。

- `mouday/domain-admin:latest`: 使用 `mouday` 仓库中的 `domain-admin` 镜像，并使用最新版本（`latest` 标签）。

### 8.network

​		指定该服务使用的网络，这里是 `domain_admin`。

- `name`：设置自定义网络名称，这里定义为`halo_network`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `halo_halo_network`。

### 9.ipam

​		是IP 地址管理。

- `driver: default`：使用默认驱动`bridge`。
- `config: - subnet`：设置子网为 `172.196.0.0/16`。



## 五、Halo的yml参数说明

```bash
version: "3"
services:
  halo:
    image: halohub/halo:2.14
    container_name: halo2
    networks:
      - halo_network
    restart: on-failure:3
    depends_on:
      halodb:
        condition: service_healthy
    volumes:
      - /data/Halo/halo2:/root/.halo2
    ports:
      - "8090:8090"
    healthcheck:
      # test: ["CMD", "curl", "-f", "http://localhost:8090/actuator/health/readiness"]
      test: ["CMD-SHELL", "curl -f http://localhost:8090/actuator/health/readiness || exit 1"]
      interval: 1m
      timeout: 10s
      retries: 3
      start_period: 1m
    command:
      - --spring.r2dbc.url=r2dbc:pool:postgresql://halodb/halo
      - --spring.r2dbc.username=halo
      # #设置你的数据库PostgreSQL的密码，请保证与下方POSTGRES_PASSWORD的变量值一致。
      - --spring.r2dbc.password=dream13889
      - --spring.sql.init.platform=postgresql
      # 外部访问地址，请根据实际需要修改
      - --halo.external-url=https://blog.jerion.cn/
      - --halo.security.initializer.superadminusername=admin
      - --halo.security.initializer.superadminpassword=dream13889
  halodb:
    image: postgres:15.4
    container_name: halodb2
    networks:
      - halo_network
    restart: on-failure:3
    volumes:
      - /data/Halo/db:/var/lib/postgresql/data
    healthcheck:
      # test: [ "CMD", "pg_isready" ]
      test: ["CMD-SHELL", "pg_isready -U halo -d halo -h localhost"]
      interval: 30s
      timeout: 5s
      retries: 5
    environment:
      - POSTGRES_PASSWORD=dream13889  #设置你的数据库密码
      - POSTGRES_USER=halo
      - POSTGRES_DB=halo
      - PGUSER=halo
networks:
  halo_network:
    name: halo_network
    ipam:
      driver: default
      config:
        - subnet: 172.197.0.0/16
```

### 1.版本

- `version`：指定了 Docker Compose 文件的版本，这里使用的是版本 3。

### 2.halo服务

- `image`: 指定使用的 Docker 镜像，这里是 `halohub/halo:2.14`。
- `container_name`: 容器的名称，这里是 `halo2`。
- `networks`: 指定该服务使用的网络，这里是 `halo_network`。
- `restart`: 指定重启策略，当容器失败时最多重试 3 次。
- `depends_on`: 指定服务的依赖关系，这里 `halo` 服务依赖于 `halodb` 服务，并且要求 `halodb` 服务处于健康状态。
- `volumes`: 将宿主机的 `/data/Halo/halo2` 目录挂载到容器的 `/root/.halo2` 目录。
- `ports`: 将宿主机的 8090 端口映射到容器的 8090 端口。
- `healthcheck`: 健康检查配置。
  - `test`: 检查命令，这里使用 `curl` 检查 `http://localhost:8090/actuator/health/readiness`。
  - `interval`: 检查间隔为 1 分钟。
  - `timeout`: 检查超时时间为 10 秒。
  - `retries`: 失败重试次数为 3 次。
  - `start_period`: 开始检查的初始等待时间为 1 分钟。
- `command`: 容器启动时执行的命令和参数。
  - `--spring.r2dbc.url`: 数据库连接 URL。
  - `--spring.r2dbc.username`: 数据库用户名。
  - `--spring.r2dbc.password`: 数据库密码。
  - `--spring.sql.init.platform`: 数据库平台类型。
  - `--halo.external-url`: 外部访问地址。
  - `--halo.security.initializer.superadminusername`: 超级管理员用户名。
  - `--halo.security.initializer.superadminpassword`: 超级管理员密码。

### 3.halodb服务

- `image`: 指定使用的 Docker 镜像，这里是 `postgres:15.4`。
- `container_name`: 容器的名称，这里是 `halodb2`。
- `networks`: 指定该服务使用的网络，这里是 `halo_network`。
- `restart`: 指定重启策略，当容器失败时最多重试 3 次。
- `volumes`: 将宿主机的 `/data/Halo/db` 目录挂载到容器的 `/var/lib/postgresql/data` 目录。
- `healthcheck`: 健康检查配置。
  - `test`: 检查命令，这里使用 `pg_isready` 检查数据库服务的可用性。
  - `interval`: 检查间隔为 30 秒。
  - `timeout`: 检查超时时间为 5 秒。
  - `retries`: 失败重试次数为 5 次。
- `environment`: 环境变量设置。
  - `POSTGRES_PASSWORD`: 设置数据库密码。
  - `POSTGRES_USER`: 设置数据库用户名。
  - `POSTGRES_DB`: 设置数据库名称。
  - `PGUSER`: 设置 PostgreSQL 用户。

### 4.网络定义

- `halo_network`：定义了一个名为 `halo_network` 的自定义网络，供 `halo` 和 `halodb` 服务使用。
  - `name`：设置自定义网络名称，这里定义为`halo_network`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `halo_halo_network`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config: - subnet`：设置子网为 `172.197.0.0/16`。



## 六、OneAPI的yml参数说明

```bash
version: '3.3'
services:
  mysql:
    image: mysql:8.0.36
    container_name: mysql
    restart: always
    ports:
      - 3307:3306
    networks:
      - oneapi
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_ROOT_PASSWORD: dream13889
      MYSQL_DATABASE: oneapi
    volumes:
      - ./mysql:/var/lib/mysql
  oneapi:
    container_name: oneapi
    image: ghcr.io/songquanpeng/one-api:latest
    ports:
      - 3000:3000
    depends_on:
      - mysql
    networks:
      - oneapi
    restart: always
    environment:
      - SQL_DSN=root:dream13889@tcp(mysql:3306)/oneapi
      # 登录凭证加密密钥
      - SESSION_SECRET=oneapikey
      # 内存缓存
      - MEMORY_CACHE_ENABLED=true
      # 启动聚合更新，减少数据交互频率
      - BATCH_UPDATE_ENABLED=true
      # 聚合更新时长
      - BATCH_UPDATE_INTERVAL=10
      # 初始化的 root 密钥（建议部署完后更改，否则容易泄露）
      - INITIAL_ROOT_TOKEN=dream13889
    volumes:
      - ./oneapi:/data
networks:
  oneapi:
    name: oneapi
    ipam:
      driver: default
      config:
        - subnet: 172.198.0.0/16
```

### 1.版本

- `version`：指定了 Docker Compose 文件的版本，这里使用的是版本 3.3。

### 2.mysql服务

- `image`：使用 `mysql` 镜像的 `8.0.36` 版本。

- `container_name`：容器名称为 "mysql"。

- `restart`：容器总是重新启动。

- `ports`：端口映射，将主机的 `3307` 端口映射到容器的 `3306` 端口。

- `networks`：使用名为 `oneapi` 的网络。

- `command`：运行容器时执行的命令，这里设置 MySQL 的默认认证插件为 `mysql_native_password`。

- `environment`：环境变量。

  - `MYSQL_ROOT_PASSWORD`：设置 MySQL 的 root 用户密码为 `dream13889`。

  - `MYSQL_DATABASE`：创建名为 `oneapi` 的数据库。

- `volumes`：数据卷。
  - `./mysql:/var/lib/mysql`：将当前目录下的 `mysql` 目录挂载到容器的 `/var/lib/mysql` 目录。

### 3.oneapi服务

- `container_name`：容器名称为 "oneapi"。

- `image：使用 `one-api` 镜像的最新版本。

- `ports：端口映射，将主机的 `3000` 端口映射到容器的 `3000` 端口。

- `depends_on：依赖关系，确保 `mysql` 服务先启动。

- `networks`：使用名为 `oneapi` 的网络。

- `restart：容器总是重新启动。

- `environment：环境变量。
  - `SQL_DSN=root:dream13889@tcp(mysql:3306)/oneapi`：连接 MySQL 数据库的 DSN（数据源名称）。
  
  - `SESSION_SECRET`：用于登录凭证加密的密钥。
  
  - `MEMORY_CACHE_ENABLED`：启用内存缓存。
  
  - `BATCH_UPDATE_ENABLED`：启用批量更新，以减少数据交互频率。
  
  - `BATCH_UPDATE_INTERVAL`：批量更新的时间间隔为 10 秒。
  
  - `INITIAL_ROOT_TOKEN`：初始化的 root 密钥（建议部署后更改）。
  
- `volumes`：数据卷。
  - `./oneapi:/data`：将当前目录下的 `oneapi` 目录挂载到容器的 `/data` 目录。

### 4.网络定义

- `oneapi`：定义了一个名为 `oneapi` 的自定义网络，供 `oneapi` 和 `mysql` 服务使用。
  - `name`：设置自定义网络名称，这里定义为`oneapi`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `oneapi_oneapi`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config: - subnet`：设置子网为 `172.198.0.0/16`。



## 七、FastGPT的yml参数说明

```bash
version: '3.3'
services:
  pg:
    image: pgvector/pgvector:0.7.0-pg15 # docker hub
    # image: ankane/pgvector:v0.5.0 # git
    # image: registry.cn-hangzhou.aliyuncs.com/fastgpt/pgvector:v0.5.0 # 阿里云
    container_name: pg
    restart: always
    ports: 
      - 5432:5432
    networks:
      - fastgpt
    environment:
      - POSTGRES_USER=hongzelong
      - POSTGRES_PASSWORD=dream13889
      - POSTGRES_DB=postgres
    volumes:
      - ./pg/data:/var/lib/postgresql/data
  mongo:
    image: mongo:5.0.18  # dockerhub
    container_name: mongo
    restart: always
    ports:
      - 27017:27017
    networks:
      - fastgpt
    command: mongod --keyFile /data/mongodb.key --replSet rs0
    environment:
      - MONGO_INITDB_ROOT_USERNAME=hongzelong
      - MONGO_INITDB_ROOT_PASSWORD=dream13889
    volumes:
      - ./mongo/data:/data/db
    entrypoint:
      - bash
      - -c
      - |
        openssl rand -base64 128 > /data/mongodb.key
        chmod 400 /data/mongodb.key
        chown 999:999 /data/mongodb.key
        echo 'const isInited = rs.status().ok === 1
        if(!isInited){
          rs.initiate({
              _id: "rs0",
              members: [
                  { _id: 0, host: "mongo:27017" }
              ]
          })
        }' > /data/initReplicaSet.js
        exec docker-entrypoint.sh "$$@" &

        until mongo -u hongzelong -p dream13889 --authenticationDatabase admin --eval "print('waited for connection')" > /dev/null 2>&1; do
          echo "Waiting for MongoDB to start..."
          sleep 2
        done

        mongo -u hongzelong -p dream13889 --authenticationDatabase admin /data/initReplicaSet.js

        wait $$!
  fastgpt:
    container_name: fastgpt
    image: ghcr.io/labring/fastgpt:v4.8.2 # git
    ports:
      - 9898:3000
    networks:
      - fastgpt
    depends_on:
      - mongo
      - pg
    restart: always
    environment:
      - DEFAULT_ROOT_PSW=dream13889
      - OPENAI_BASE_URL=http://172.18.0.104:3000/v1
      - CHAT_API_KEY=sk-Vz6HDEC74r73Y0F312E39d1072B443Fa935e766434FcD97e
      - DB_MAX_LINK=30
      - TOKEN_KEY=any
      - ROOT_KEY=root_key
      - FILE_TOKEN_KEY=filetoken
      - MONGODB_URI=mongodb://hongzelong:dream13889@mongo:27017/fastgpt?authSource=admin
      - PG_URL=postgresql://hongzelong:dream13889@pg:5432/postgres
    volumes:
      - ./config.json:/app/data/config.json
      - ./fastgpt/tmp:/app/tmp
networks:
  fastgpt:
    name: fastgpt
    ipam:
      driver: default
      config:
        - subnet: 172.199.0.0/16
```

### 1.版本

- `version`：指定了 Docker Compose 文件的版本，这里使用的是版本 3.3。

### 2.pg（PostgreSQL数据库）服务

- `image`：指定要使用的 Docker 镜像。

- `container_name `：容器的名称。

- `restart`：总是重新启动容器。

- `ports`：将主机的 5432 端口映射到容器的 5432 端口。

- `networks`：连接到 `fastgpt` 网络。

- `environment`：环境变量设置。

  - `POSTGRES_USER`：PostgreSQL 用户名。

  - `POSTGRES_PASSWORD`：PostgreSQL 密码。

  - `POSTGRES_DB`：数据库名称。

- `volumes:`数据卷。
  - ` ./pg/data:/var/lib/postgresql/data`：将主机的 `./pg/data` 目录挂载到容器的 `/var/lib/postgresql/data` 目录。

### 3.mongo（MongoDB 数据库）服务

- `image`：指定要使用的 Docker 镜像。

- `container_name`：容器的名称。

- `restart`：总是重新启动容器。

- `ports`：将主机的 27017 端口映射到容器的 27017 端口。

- `networks：连接到 `fastgpt` 网络。

- `command: mongod --keyFile /data/mongodb.key --replSet rs0`：指定 MongoDB 启动命令，启用密钥文件和副本集。

- `environment`：环境变量设置。

  - `MONGO_INITDB_ROOT_USERNAME：MongoDB 用户名。

  - `MONGO_INITDB_ROOT_PASSWORD`：MongoDB 密码。

- `volumes: `数据卷。
  - `- ./mongo/data:/data/db`：将主机的 `./mongo/data` 目录挂载到容器的 `/data/db` 目录。

- `entrypoint`：启动时执行的命令。

  - `bash -c`：使用 Bash 执行以下命令。

  - `openssl rand -base64 128 > /data/mongodb.key`：生成一个随机的密钥文件。

  - `chmod 400 /data/mongodb.key`：设置密钥文件权限为 400。

  - `chown 999:999 /data/mongodb.key`：更改密钥文件的所有者。

  - `echo '...initReplicaSet.js'`：生成初始化副本集的 JavaScript 文件。

  - `exec docker-entrypoint.sh "$$@" &`：执行 Docker 入口点脚本并将其放在后台。

  - `until mongo -u hongzelong -p dream13889 --authenticationDatabase admin --eval "print('waited for connection')"`：等待 MongoDB 启动完成。

  - `mongo -u hongzelong -p dream13889 --authenticationDatabase admin /data/initReplicaSet.js`：运行初始化副本集的脚本。

  - `wait $$!`：等待后台进程结束。

### 4.fastgpt服务

- `container_name：容器的名称。

- `image：指定要使用的 Docker 镜像。

- `ports：将主机的 9898 端口映射到容器的 3000 端口。

- `networks：连接到 `fastgpt` 网络。

- `depends_on`：依赖于 `mongo` 和 `pg` 服务，确保它们先启动。

- `restart：总是重新启动容器。

- `environment`：环境变量设置。

  - `DEFAULT_ROOT_PSW：默认根密码。

  - `OPENAI_BASE_URL`：OpenAI 基础 URL。

  - `CHAT_API_KEY：聊天 API 密钥。

  - `DB_MAX_LINK`：数据库最大连接数。

  - `TOKEN_KEY：令牌密钥。

  - `ROOT_KEY：根密钥。

  - `FILE_TOKEN_KEY`：文件令牌密钥。

  - `MONGODB_URI`：MongoDB URI。

  - `PG_URL`：PostgreSQL URI。

- `volumes`：卷挂载。

  - `./config.json:/app/data/config.json`：将主机的 `./config.json` 文件挂载到容器的 `/app/data/config.json` 文件。

  - `./fastgpt/tmp:/app/tmp`：将主机的 `./fastgpt/tmp` 目录挂载到容器的 `/app/tmp` 目录。

### 5.网络定义

- `fastgpt`：定义了一个名为 `fastgpt` 的自定义网络，供 `pg` 、`mongo`和 `fastgpt` 服务使用。
  - `name`：设置自定义网络名称，这里定义为`fastgpt`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `fastgpt_fastgpt`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config: - subnet`：设置子网为 `172.199.0.0/16`。



## 八、Dify的yml参数说明

```bash
version: '3'
services:
  api:
    image: langgenius/dify-api:0.6.9
    restart: always
    environment:
      MODE: api
      LOG_LEVEL: INFO
      SECRET_KEY: sk-9f73s3ljTXVcMT3Blb3ljTqtsKiGHXVcMT3BlbkFJLK7U
      CONSOLE_WEB_URL: ''
      INIT_PASSWORD: ''
      CONSOLE_API_URL: ''
      SERVICE_API_URL: ''
      APP_WEB_URL: ''
      FILES_URL: ''
      FILES_ACCESS_TIMEOUT: 300
      MIGRATION_ENABLED: 'true'
      DB_USERNAME: postgres
      DB_PASSWORD: difyai123456
      DB_HOST: db
      DB_PORT: 5432
      DB_DATABASE: dify
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_USERNAME: ''
      REDIS_PASSWORD: difyai123456
      REDIS_USE_SSL: 'false'
      REDIS_DB: 0
      CELERY_BROKER_URL: redis://:difyai123456@redis:6379/1
      WEB_API_CORS_ALLOW_ORIGINS: '*'
      CONSOLE_CORS_ALLOW_ORIGINS: '*'
      STORAGE_TYPE: local
      STORAGE_LOCAL_PATH: storage
      S3_ENDPOINT: 'https://xxx.r2.cloudflarestorage.com'
      S3_BUCKET_NAME: 'difyai'
      S3_ACCESS_KEY: 'ak-difyai'
      S3_SECRET_KEY: 'sk-difyai'
      S3_REGION: 'us-east-1'
      AZURE_BLOB_ACCOUNT_NAME: 'difyai'
      AZURE_BLOB_ACCOUNT_KEY: 'difyai'
      AZURE_BLOB_CONTAINER_NAME: 'difyai-container'
      AZURE_BLOB_ACCOUNT_URL: 'https://<your_account_name>.blob.core.windows.net'
      GOOGLE_STORAGE_BUCKET_NAME: 'yout-bucket-name'
      GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64: 'your-google-service-account-json-base64-string'
      VECTOR_STORE: weaviate
      WEAVIATE_ENDPOINT: http://weaviate:8080
      WEAVIATE_API_KEY: WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih
      QDRANT_URL: http://qdrant:6333
      QDRANT_API_KEY: difyai123456
      QDRANT_CLIENT_TIMEOUT: 20
      QDRANT_GRPC_ENABLED: 'false'
      QDRANT_GRPC_PORT: 6334
      MILVUS_HOST: 127.0.0.1
      MILVUS_PORT: 19530
      MILVUS_USER: root
      MILVUS_PASSWORD: Milvus
      MILVUS_SECURE: 'false'
      RELYT_HOST: db
      RELYT_PORT: 5432
      RELYT_USER: postgres
      RELYT_PASSWORD: difyai123456
      RELYT_DATABASE: postgres
      PGVECTOR_HOST: pgvector
      PGVECTOR_PORT: 5432
      PGVECTOR_USER: postgres
      PGVECTOR_PASSWORD: difyai123456
      PGVECTOR_DATABASE: dify
      MAIL_TYPE: ''
      MAIL_DEFAULT_SEND_FROM: 'YOUR EMAIL FROM (eg: no-reply <no-reply@dify.ai>)'
      SMTP_SERVER: ''
      SMTP_PORT: 465
      SMTP_USERNAME: ''
      SMTP_PASSWORD: ''
      SMTP_USE_TLS: 'true'
      SMTP_OPPORTUNISTIC_TLS: 'false'
      RESEND_API_KEY: ''
      RESEND_API_URL: https://api.resend.com
      SENTRY_DSN: ''
      SENTRY_TRACES_SAMPLE_RATE: 1.0
      SENTRY_PROFILES_SAMPLE_RATE: 1.0
      NOTION_INTEGRATION_TYPE: public
      NOTION_CLIENT_SECRET: you-client-secret
      NOTION_CLIENT_ID: you-client-id
      NOTION_INTERNAL_SECRET: you-internal-secret
      CODE_EXECUTION_ENDPOINT: "http://sandbox:8194"
      CODE_EXECUTION_API_KEY: dify-sandbox
      CODE_MAX_NUMBER: 9223372036854775807
      CODE_MIN_NUMBER: -9223372036854775808
      CODE_MAX_STRING_LENGTH: 80000
      TEMPLATE_TRANSFORM_MAX_LENGTH: 80000
      CODE_MAX_STRING_ARRAY_LENGTH: 30
      CODE_MAX_OBJECT_ARRAY_LENGTH: 30
      CODE_MAX_NUMBER_ARRAY_LENGTH: 1000
      SSRF_PROXY_HTTP_URL: 'http://ssrf_proxy:3128'
      SSRF_PROXY_HTTPS_URL: 'http://ssrf_proxy:3128'
      INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH: 1000
    depends_on:
      - db
      - redis
    volumes:
      - ./volumes/app/storage:/app/api/storage
    networks:
      dify_ssrf_proxy_network:
        ipv4_address: 172.20.0.2
      dify_default:
        ipv4_address: 172.20.1.2

  worker:
    image: langgenius/dify-api:0.6.9
    restart: always
    environment:
      CONSOLE_WEB_URL: ''
      MODE: worker
      LOG_LEVEL: INFO
      SECRET_KEY: sk-9f73s3ljTXVcMT3Blb3ljTqtsKiGHXVcMT3BlbkFJLK7U
      DB_USERNAME: postgres
      DB_PASSWORD: difyai123456
      DB_HOST: db
      DB_PORT: 5432
      DB_DATABASE: dify
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_USERNAME: ''
      REDIS_PASSWORD: difyai123456
      REDIS_DB: 0
      REDIS_USE_SSL: 'false'
      CELERY_BROKER_URL: redis://:difyai123456@redis:6379/1
      STORAGE_TYPE: local
      STORAGE_LOCAL_PATH: storage
      S3_ENDPOINT: 'https://xxx.r2.cloudflarestorage.com'
      S3_BUCKET_NAME: 'difyai'
      S3_ACCESS_KEY: 'ak-difyai'
      S3_SECRET_KEY: 'sk-difyai'
      S3_REGION: 'us-east-1'
      AZURE_BLOB_ACCOUNT_NAME: 'difyai'
      AZURE_BLOB_ACCOUNT_KEY: 'difyai'
      AZURE_BLOB_CONTAINER_NAME: 'difyai-container'
      AZURE_BLOB_ACCOUNT_URL: 'https://<your_account_name>.blob.core.windows.net'
      GOOGLE_STORAGE_BUCKET_NAME: 'yout-bucket-name'
      GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64: 'your-google-service-account-json-base64-string'
      VECTOR_STORE: weaviate
      WEAVIATE_ENDPOINT: http://weaviate:8080
      WEAVIATE_API_KEY: WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih
      QDRANT_URL: http://qdrant:6333
      QDRANT_API_KEY: difyai123456
      QDRANT_CLIENT_TIMEOUT: 20
      QDRANT_GRPC_ENABLED: 'false'
      QDRANT_GRPC_PORT: 6334
      MILVUS_HOST: 127.0.0.1
      MILVUS_PORT: 19530
      MILVUS_USER: root
      MILVUS_PASSWORD: Milvus
      MILVUS_SECURE: 'false'
      MAIL_TYPE: ''
      MAIL_DEFAULT_SEND_FROM: 'YOUR EMAIL FROM (eg: no-reply <no-reply@dify.ai>)'
      SMTP_SERVER: ''
      SMTP_PORT: 465
      SMTP_USERNAME: ''
      SMTP_PASSWORD: ''
      SMTP_USE_TLS: 'true'
      SMTP_OPPORTUNISTIC_TLS: 'false'
      RESEND_API_KEY: ''
      RESEND_API_URL: https://api.resend.com
      RELYT_HOST: db
      RELYT_PORT: 5432
      RELYT_USER: postgres
      RELYT_PASSWORD: difyai123456
      RELYT_DATABASE: postgres
      PGVECTOR_HOST: pgvector
      PGVECTOR_PORT: 5432
      PGVECTOR_USER: postgres
      PGVECTOR_PASSWORD: difyai123456
      PGVECTOR_DATABASE: dify
      NOTION_INTEGRATION_TYPE: public
      NOTION_CLIENT_SECRET: you-client-secret
      NOTION_CLIENT_ID: you-client-id
      NOTION_INTERNAL_SECRET: you-internal-secret
      INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH: 1000
    depends_on:
      - db
      - redis
    volumes:
      - ./volumes/app/storage:/app/api/storage
    networks:
      dify_ssrf_proxy_network:
        ipv4_address: 172.20.0.3
      dify_default:
        ipv4_address: 172.20.1.3

  web:
    image: langgenius/dify-web:0.6.9
    restart: always
    environment:
      CONSOLE_API_URL: ''
      APP_API_URL: ''
      SENTRY_DSN: ''
    networks:
      dify_default:
        ipv4_address: 172.20.1.4

  db:
    image: postgres:15-alpine
    restart: always
    environment:
      PGUSER: postgres
      POSTGRES_PASSWORD: difyai123456
      POSTGRES_DB: dify
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - ./volumes/db/data:/var/lib/postgresql/data
    healthcheck:
      test: [ "CMD", "pg_isready" ]
      interval: 1s
      timeout: 3s
      retries: 30
    networks:
      dify_default:
        ipv4_address: 172.20.1.5

  redis:
    image: redis:6-alpine
    restart: always
    volumes:
      - ./volumes/redis/data:/data
    command: redis-server --requirepass difyai123456
    healthcheck:
      test: [ "CMD", "redis-cli", "ping" ]
    networks:
      dify_default:
        ipv4_address: 172.20.1.6

  weaviate:
    image: semitechnologies/weaviate:1.19.0
    restart: always
    volumes:
      - ./volumes/weaviate:/var/lib/weaviate
    environment:
      QUERY_DEFAULTS_LIMIT: 25
      AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED: 'false'
      PERSISTENCE_DATA_PATH: '/var/lib/weaviate'
      DEFAULT_VECTORIZER_MODULE: 'none'
      CLUSTER_HOSTNAME: 'node1'
      # 添加显式的广告地址
      # CLUSTER_ADVERTISE_ADDR: '172.20.1.7'
      AUTHENTICATION_APIKEY_ENABLED: 'true'
      AUTHENTICATION_APIKEY_ALLOWED_KEYS: 'WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih'
      AUTHENTICATION_APIKEY_USERS: 'hello@dify.ai'
      AUTHORIZATION_ADMINLIST_ENABLED: 'true'
      AUTHORIZATION_ADMINLIST_USERS: 'hello@dify.ai'
    networks:
      dify_default:
        ipv4_address: 172.20.1.7

  sandbox:
    image: langgenius/dify-sandbox:0.2.0
    restart: always
    environment:
      API_KEY: dify-sandbox
      GIN_MODE: 'release'
      WORKER_TIMEOUT: 15
      ENABLE_NETWORK: 'true'
      HTTP_PROXY: 'http://ssrf_proxy:3128'
      HTTPS_PROXY: 'http://ssrf_proxy:3128'
    volumes:
      - ./volumes/sandbox/dependencies:/dependencies
    networks:
      dify_ssrf_proxy_network:
        ipv4_address: 172.20.0.4

  ssrf_proxy:
    image: ubuntu/squid:latest
    restart: always
    volumes:
      - ./volumes/ssrf_proxy/squid.conf:/etc/squid/squid.conf
    networks:
      dify_ssrf_proxy_network:
        ipv4_address: 172.20.0.5
      dify_default:
        ipv4_address: 172.20.1.8

  nginx:
    image: nginx:latest
    restart: always
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/proxy.conf:/etc/nginx/proxy.conf
      - ./nginx/conf.d:/etc/nginx/conf.d
    depends_on:     
      - api
      - web
    ports:
      - "80:80"
    networks:
      dify_default:
        ipv4_address: 172.20.1.9

networks:
  dify_ssrf_proxy_network:
    name: dify_ssrf_proxy_network
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/24
          gateway: 172.20.0.1
    internal: true
  dify_default:
    name: dify_default
    ipam:
      driver: default
      config:
        - subnet: 172.20.1.0/24
          gateway: 172.20.1.1
```

### 1.版本

- `version`：指定了 Docker Compose 文件的版本，这里使用的是版本 3。

### 2.api服务

- `image`：使用langgenius/dify-api:0.6.9镜像。
- `restart：总是重启容器。
- `environment`：定义了许多环境变量，如数据库连接信息、Redis连接信息、存储配置等。
- `depends_on`：表示此服务依赖于`db`和`redis`服务。
- `volumes`：映射主机的`./volumes/app/storage`目录到容器内的`/app/api/storage`目录。
- `networks`：配置该服务所连接的网络及其IP地址。

### 3.worker服务

- `image：使用相同的API镜像。
- `restart：总是重启容器。
- `environment`：定义了许多环境变量，与`api`服务类似，但模式为`worker`。
- `depends_on`：表示此服务依赖于`db`和`redis`服务。
- `volumes`：映射主机的`./volumes/app/storage`目录到容器内的`/app/api/storage`目录。
- `networks`：配置该服务所连接的网络及其IP地址。

### 4.web服务

- `image`：使用langgenius/dify-web:0.6.9镜像。
- `restart：总是重启容器。
- `environment`：定义了几个环境变量。
- `networks`：配置该服务所连接的网络及其IP地址。

### 5.db服务

- `image：使用Postgres 15的轻量级镜像。
- `restart：总是重启容器。
- `environment`：定义了Postgres数据库的用户、密码和数据库名称。
- `volumes`：映射主机的`./volumes/db/data`目录到容器内的`/var/lib/postgresql/data`目录。
- `healthcheck`：配置了一个健康检查命令，确保数据库服务启动并运行。
- `networks`：配置该服务所连接的网络及其IP地址。

### 6.redis服务

- `image`：使用Redis 6的轻量级镜像。
- `restart：总是重启容器。
- `volumes`：映射主机的`./volumes/redis/data`目录到容器内的`/data`目录。
- `command`：运行Redis服务器并设置密码。
- `healthcheck`：配置了一个健康检查命令，确保Redis服务启动并运行。
- `networks`：配置该服务所连接的网络及其IP地址。

### 7.weaviate服务

- `image`：使用Weaviate 1.19.0镜像。
- `restart：总是重启容器。
- `volumes`：映射主机的`./volumes/weaviate`目录到容器内的`/var/lib/weaviate`目录。
- `environment`：定义了多个环境变量来配置Weaviate，包括身份验证、持久性和集群设置。
- `networks`：配置该服务所连接的网络及其IP地址。

### 8.sandbox服务

- `image：使用langgenius/dify-sandbox:0.2.0镜像。
- `restart：总是重启容器。
- `environment`：定义了几个环境变量。
- `volumes`：映射主机的`./volumes/sandbox/dependencies`目录到容器内的`/dependencies`目录。
- `networks`：配置该服务所连接的网络及其IP地址。

### 9.ssrf_proxy服务

- `image`：使用最新版本的Squid代理镜像。
- `restart`：总是重启容器。
- `volumes`：映射主机的`./volumes/ssrf_proxy/squid.conf`配置文件到容器内的`/etc/squid/squid.conf`文件。
- `networks`：配置该服务所连接的网络及其IP地址。

### 10.nginx服务

- `image: `：使用最新版本的Nginx镜像。
- `restart：总是重启容器。
- `volumes`：映射主机的Nginx配置文件目录到容器内的相应目录。
- `depends_on`：表示此服务依赖于`api`和`web`服务。
- `ports`：映射主机的80端口到容器的80端口。
- `networks`：配置该服务所连接的网络及其IP地址。

### 11.网络定义

- `dify_ssrf_proxy_network`：定义了一个名为 `dify_ssrf_proxy_network` 的自定义网络，供 `api` 、`work`、`sandbox`、`ssrf_proxy`服务使用。
  - `name`：设置自定义网络名称，这里定义为`dify_ssrf_proxy_network`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `docker_dify_ssrf_proxy_network`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config`: IP地址管理的配置列表项。
    - `- subnet`：设置子网为 `172.20.0.0/24`；
    - `gateway`：设置网关为`172.20.0.1`。
- `dify_default`：定义了一个名为 `dify_default` 的自定义网络，供 `api` 、`work`、`web`、`db`、`redis`、`weaviate`、`ssra_proxy`、`nginx`服务使用。
  - `name`：设置自定义网络名称，这里定义为`dify_default`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `docker_dify_default`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config`: IP地址管理的配置列表项。
    - `- subnet`：设置子网为 `172.21.0.0/24`；
    - `gateway`：设置网关为`172.21.0.1`。



## 九、typecho的yml参数说明

```bash
version: '3'

services:
  typecho:
    image: fukoy/nginx-php-fpm:php7.4
    container_name: typecho2
    networks:
      - typecho_network
    ports:
      - '8090:80'  #开放端口8090
    restart: always
    volumes:
      - /data/typecho/www:/usr/share/nginx/typecho/   #typecho网站文件
      - /data/typecho/nginx/conf.d:/etc/nginx/conf.d   #nginx配置文件夹
      - /data/typecho/nginx/nginx.conf:/etc/nginx/nginx.conf  #nginx配置文件
    depends_on:
      - mysql

  typechdb:
    image: mysql:5.7
    container_name: typechodb2
    networks:
      - typecho_network
    ports:
      - '3306:3306'
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=123456   # 替换为你的MySQL root密码
      - MYSQL_DATABASE=typecho       # 替换为你的数据库名称
      - MYSQL_USER=typecho           # 替换为你的数据库用户
      - MYSQL_PASSWORD=typecho       # 替换为你的数据库用户密码
    volumes:
      - /data/typecho/mysql/data:/var/lib/mysql
      - /data/typecho/mysql/logs:/var/log/mysql
      - /data/typecho/mysql/conf:/etc/mysql/conf.d

networks:
  typecho_network:
    name: typecho_network
    ipam:
      driver: default
      config:
        - subnet: 172.190.0.0/16
```

### 1.版本

- `version`：指定了 Docker Compose 文件的版本，这里使用的是版本 3。

### 2.typecho服务

- `image`: 指定容器使用 `fukoy/nginx-php-fpm:php7.4` 镜像。
- `container_name`: 为该服务指定容器名称为 `typecho2`。
- `networks`: 将该容器连接到名为 `typecho_network` 的网络。
- `ports`: 将宿主机的 8090 端口映射到容器的 80 端口，允许通过宿主机的 8090 端口访问容器内的服务。
- `restart`: 设置容器在停止后自动重启。
- `volumes`: 定义了挂载卷，将宿主机目录映射到容器内对应的目录。
  - `/data/typecho/www:/usr/share/nginx/typecho/`: 将宿主机的 `/data/typecho/www` 目录映射到容器的 `/usr/share/nginx/typecho/`，用于存储 Typecho 网站文件。
  - `/data/typecho/nginx/conf.d:/etc/nginx/conf.d`: 将宿主机的 `/data/typecho/nginx/conf.d` 目录映射到容器的 `/etc/nginx/conf.d`，用于存储 Nginx 配置文件。
  - `/data/typecho/nginx/nginx.conf:/etc/nginx/nginx.conf`: 将宿主机的 `/data/typecho/nginx/nginx.conf` 文件映射到容器的 `/etc/nginx/nginx.conf`，用于存储 Nginx 主配置文件。
- `depends_on`: 指定该服务依赖 `mysql` 服务，即在启动该服务前先启动 `mysql` 服务。

### 3.typechdb服务

- `image`: 指定容器使用 `mysql:5.7` 镜像。
- `container_name`: 为该服务指定容器名称为 `typechodb2`。
- `networks`: 将该容器连接到名为 `typecho_network` 的网络。
- `ports`: 将宿主机的 3306 端口映射到容器的 3306 端口，允许通过宿主机的 3306 端口访问容器内的 MySQL 数据库。
- `restart: 设置容器在停止后自动重启。
- `environment`: 定义环境变量来配置 MySQL 数据库。
  - `MYSQL_ROOT_PASSWORD`: 设置 MySQL root 用户的密码为 `123456`。
  - `MYSQL_DATABASE: 创建名为 `typecho` 的数据库。
  - `MYSQL_USER: 创建名为 `typecho` 的数据库用户。
  - `MYSQL_PASSWORD: 设置 `typecho` 用户的密码为 `typecho`。
- `volumes`: 定义了挂载卷，将宿主机目录映射到容器内对应的目录。
  - `/data/typecho/mysql/data:/var/lib/mysql`: 将宿主机的 `/data/typecho/mysql/data` 目录映射到容器的 `/var/lib/mysql`，用于存储 MySQL 数据。
  - `/data/typecho/mysql/logs:/var/log/mysql`: 将宿主机的 `/data/typecho/mysql/logs` 目录映射到容器的 `/var/log/mysql`，用于存储 MySQL 日志。
  - `/data/typecho/mysql/conf:/etc/mysql/conf.d`: 将宿主机的 `/data/typecho/mysql/conf` 目录映射到容器的 `/etc/mysql/conf.d`，用于存储 MySQL 配置文件。

### 4.网络定义

- `typecho_network`：定义了一个名为 `typecho_network` 的自定义网络，供 `typecho` 和 `typechodb` 服务使用。
  - `name`：设置自定义网络名称，这里定义为`typecho_network`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `typecho_typecho_network`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config: - subnet`：设置子网为 `172.190.0.0/16`。



## 十、reader的yml参数说明

```bash
version: '3.1'

services:
# 多用户版
  read_all:
    image: hectorqin/reader
    container_name: reader   #容器名,可自行修改
    networks:
      - reader_network
    restart: always
    ports:
      - 4396:8080   #4396端口映射可自行修改
    volumes:
      - /data/reader/logs:/logs   #log映射目录 /root/data/docker_data/reader/logs 映射目录可自行修改
      - /data/reader/storage:/storage   #数据映射目录 /root/data/docker_data/reader/storage 映射目录可自行修改
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - READER_APP_SECURE=true   #开启登录鉴权，开启后将支持多用户模式
      - READER_APP_CACHECHAPTERCONTENT=true   #是否开启缓存章节内容 V2.0
      - READER_APP_SECUREKEY=Sunline@2024   #管理员密码  可自行修改
# 自动更新docker
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    networks:
      - reader_network
    restart: always
    # 环境变量,设置为上海时区
    environment:
        - TZ=Asia/Shanghai
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: reader watchtower --cleanup --schedule "0 0 4 * * *"

networks:
  reader_network:
    name: reader_network
    ipam:
      driver: default
      config:
        - subnet: 172.100.0.0/16
```

### 1.版本

- `version`：指定了 Docker Compose 文件的版本，这里使用的是版本 3.1。

### 2.read_all服务

- `image`: 指定容器使用 `hectorqin/reader` 镜像。
- `container_name`: 为该服务指定容器名称为 `reader`。
- `networks`: 将该容器连接到名为 `reader_network` 的网络。
- `restart`: 设置容器在停止后自动重启。
- `ports`: 将宿主机的 4396 端口映射到容器的 8080 端口，允许通过宿主机的 4396 端口访问容器内的服务。
- `volumes`: 定义了挂载卷，将宿主机目录映射到容器内对应的目录。
  - `/data/reader/logs:/logs`: 将宿主机的 `/data/reader/logs` 目录映射到容器的 `/logs`，用于存储 Reader 日志文件。
  - `/data/reader/storage:/storage`: 将宿主机的 `/data/reader/storage` 目录映射到容器的 `/storage`，用于存储 Reader 数据。
- `environment`: 环境变量设置。
  - `SPRING_PROFILES_ACTIVE=prod`: 设置 Spring Boot 的运行环境为生产环境。
  - `READER_APP_SECURE=true`: 开启登录鉴权，开启后将支持多用户模式。
  - `READER_APP_CACHECHAPTERCONTENT=true`: 开启缓存章节内容（V2.0 版）。
  - `READER_APP_SECUREKEY=Sunline@2024`: 管理员密码。

### 3.watchtower服务

- `image`: 指定容器使用 `containrrr/watchtower` 镜像。
- `container_name`: 为该服务指定容器名称为 `watchtower`。
- `networks`: 将该容器连接到名为 `reader_network` 的网络。
- `restart`: 设置容器在停止后自动重启。
- `environment`: 环境变量设置。
  - `TZ=Asia/Shanghai`: 设置时区为上海时区。
- `volumes`: 定义了挂载卷，将宿主机目录映射到容器内对应的目录。
  - `/var/run/docker.sock:/var/run/docker.sock`：映射宿主机的 `/var/run/docker.sock` 到容器的 `/var/run/docker.sock`，使 Watchtower 能够管理 Docker 容器。
- `command: reader watchtower --cleanup --schedule "0 0 4 * * *"`：执行 Watchtower 命令，自动更新 `reader` 容器，并清理旧版本，按照计划任务（每天凌晨 4 点）进行。

### 4.网络定义

- `reader_network`：定义了一个名为 `reader_network` 的自定义网络，供 `reader_all` 和 `watchtower` 服务使用。
  - `name`：设置自定义网络名称，这里定义为`reader_network`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `reader_reader_network`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config: - subnet`：设置子网为 `172.100.0.0/16`。



## 十一、navidrome的yml参数说明

```bash
version: "3"
services:
  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    networks:
      - music_network
    restart: unless-stopped
    ports:
      - "4533:4533"
    environment:
      ND_ENABLETRANSCODINGCONFIG: true
      ND_TRANSCODINGCACHESIZE: 0
      ND_SCANSCHEDULE: 1h
      ND_LOGLEVEL: info  
      ND_SESSIONTIMEOUT: 24h
      ND_BASEURL: ""
      LANG: C.UTF-8
      LC_ALL: C.UTF-8
    volumes:
      - "/data/navidrome/data:/data"
      - "/data/navidrome/music:/music:ro"

  miniserve:
    image: svenstaro/miniserve:latest
    container_name: miniserve
    networks:
      - music_network
    restart: unless-stopped
    depends_on:
      - navidrome
    ports:
      - "4534:8080"
    environment:
      LANG: C.UTF-8
      LC_ALL: C.UTF-8
    volumes:
      - "/data/navidrome/music:/downloads"    # 上传文件的目标目录
    command: "-r -z -u -q -p 8080 -a admin:dream13889 /downloads"

networks:
  music_network:
    name: music_network
    ipam:
      driver: default
      config:
        - subnet: 172.101.0.0/16
```

### 1.版本

- `version`：指定了 Docker Compose 文件的版本，这里使用的是版本 3。

### 2.navidrome服务

- `image`: 指定容器使用 `deluan/navidrome:latest` 镜像。
- `container_name`: 为该服务指定容器名称为 `navidrome`。
- `networks`: 将该容器连接到名为 `music_network` 的网络。
- `restart`: 容器将在失败时重启，除非手动停止。
- `ports`: 将宿主机的 4533 端口映射到容器的 4533 端口，允许通过宿主机的 4533 端口访问容器内的服务。
- `environment`：设置环境变量。
  - `ND_ENABLETRANSCODINGCONFIG=true`: 启用转码配置。
  - `ND_TRANSCODINGCACHESIZE=0`: 设置转码缓存大小为 0。
  - `ND_SCANSCHEDULE=1h`: 每小时扫描一次。
  - `ND_LOGLEVEL=info`: 设置日志级别为 `info`。
  - `ND_SESSIONTIMEOUT=24h`: 会话超时时间为 24 小时。
  - `ND_BASEURL=""`: 基本 URL（空字符串表示没有特定的基 URL）。
  - `LANG=C.UTF-8` 和 `LC_ALL=C.UTF-8`: 设置语言环境为 `C.UTF-8`。
- `volumes`: 定义了挂载卷，将宿主机目录映射到容器内对应的目录。
  - `/data/navidrome/data:/data`: 映射宿主机的 `/data/navidrome/data` 目录到容器的 `/data` 目录，用于存储 Navidrome 的数据。
  - `/data/navidrome/music:/music:ro`: 映射宿主机的 `/data/navidrome/music` 目录到容器的 `/music` 目录（只读），用于存储音乐文件。

### 3.miniserve服务

- `image`: 指定容器使用 `svenstaro/miniserve:latest` 镜像。
- `container_name`: 为该服务指定容器名称为 `miniserve`。
- `networks`: 将该容器连接到名为 `music_network` 的网络。
- `restart`: 容器将在失败时重启，除非手动停止。
- `depends_on`：表示 `miniserve` 服务依赖于 `navidrome` 服务。Docker Compose 将确保 `navidrome` 服务先启动。
- `ports`: 将宿主机的 4534 端口映射到容器的 8080 端口，允许通过宿主机的 4534 端口访问容器内的服务。
- `environment`: 环境变量设置。
  - `LANG=C.UTF-8` 和 `LC_ALL=C.UTF-8`: 设置语言环境为 `C.UTF-8`。
- `volumes`: 定义了挂载卷，将宿主机目录映射到容器内对应的目录。
  - `/data/navidrome/music:/downloads`：映射宿主机的 `/data/navidrome/music` 目录到容器的 `/downloads` 目录。
- `command: "-r -z -u -q -p 8080 -a admin:dream13889 /downloads"`：运行 `miniserve` 命令。
  - `-r`: 递归显示目录。
  - `-z`: 启用压缩下载。
  - `-u`: 显示上传按钮。
  - `-q`: 启用安静模式，减少日志输出。
  - `-p 8080`: 指定端口为 8080。
  - `-a admin:dream13889`: 设置基本身份验证，用户名为 `admin`，密码为 `dream13889`。
  - `/downloads`: 指定要共享的目录。


### 4.网络定义

- `music_network`：定义了一个名为 `music_network` 的自定义网络，供 `navidrome` 和 `miniserve` 服务使用。
  - `name`：设置自定义网络名称，这里定义为`music_network`，如果不配置`name`参数，只指定了自定义网络，Docker Compose 会将该名称与项目名称（project name）结合起来作为实际创建的网络的名称，项目名称通常是当前目录的名称，比如上面的配置文件中如果不添加`name`参数后，最终创建的网络名称会是 `music_music_network`。
- `ipam`：IP 地址管理。
  - `driver: default`：使用默认驱动`bridge`。
  - `config: - subnet`：设置子网为 `172.101.0.0/16`。
