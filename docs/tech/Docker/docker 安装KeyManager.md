服务器IP：10.22.51.65

http://10.22.51.65:8201/ui/vault/dashboard





帮助文档

https://docs.certcloud.cn/docs/cert-tools/keymanager/



#### （4）[安装KeyManager](https://keymanager.org/)

```
mkdir -p /etc/vault/config

#创建配置文件 vault.hcl：
vi /etc/vault/config/vault.hcl

添加以下内容：
storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8201"
  tls_disable = 1
}

#启动容器（添加 --cap-add IPC_LOCK 参数来启用 IPC_LOCK 权限）
docker run -d --name=vault \
  --cap-add IPC_LOCK \
  -e 'VAULT_ADDR=http://127.0.0.1:8201' \
  -e 'VAULT_LOCAL_CONFIG={"backend": {"file": {"path": "/vault/data"}}, "listener": {"tcp": {"address": "0.0.0.0:8201", "tls_disable": 1}}, "ui": true}' \
  -v /etc/vault/config:/vault/config \
  -v /etc/vault/data:/vault/data \
  -p 8201:8201 \
  hashicorp/vault server
  
  
docker exec -it vault /bin/sh






```



```
#初始化 Vault  命令：vault operator init


/ # vault operator init
Unseal Key 1: 4+PfzWlhYD9zBD9zRMVP8pj+8qMfV2iLjYtLGUImqeVA
Unseal Key 2: blyOYOJUbdfGWJt4XsGGdgujOaoS9/2qzkabhsGplAd0
Unseal Key 3: 27lCWdfQnWurNtAKe2bwKxfmkR6n8VW47JvGjnJR9Kj7
Unseal Key 4: yhmybMr7Hf2cCppI9S0w/yuh+ctvnJwyOYJ6kZkgG3T/
Unseal Key 5: o3YvYA6z961RAEswnCs6MqH48K/IrfuPxgzededdqm05

Initial Root Token: hvs.fjs7SDom4gcpivKcj0pnyy0M

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 3 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```



初始化输出将包含 5 个密钥片段和一个初始的 Root Token。请妥善保存这些信息。







解封 Vault

Vault 需要至少 3 个密钥片段来解封。使用以下命令解封 Vault（重复三次，每次使用一个不同的密钥片段）：

```
vault operator unseal <密钥片段1>
vault operator unseal <密钥片段2>
vault operator unseal <密钥片段3>

如下：
/ # vault operator unseal 4+PfzWlhYD9zBD9zRMVP8pj+8qMfV2iLjYtLGUImqeVA
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       d758c1d5-f78e-b7d9-32e7-8abfa60fa5dc
Version            1.16.2
Build Date         2024-04-22T16:25:54Z
Storage Type       file
HA Enabled         false
/ # vault operator unseal blyOYOJUbdfGWJt4XsGGdgujOaoS9/2qzkabhsGplAd0
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       d758c1d5-f78e-b7d9-32e7-8abfa60fa5dc
Version            1.16.2
Build Date         2024-04-22T16:25:54Z
Storage Type       file
HA Enabled         false
/ # vault operator unseal 27lCWdfQnWurNtAKe2bwKxfmkR6n8VW47JvGjnJR9Kj7
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.16.2
Build Date      2024-04-22T16:25:54Z
Storage Type    file
Cluster Name    vault-cluster-f0a7e1ef
Cluster ID      caf98291-72c1-6797-9cbd-ae46ce0db609
HA Enabled      false

```





###### <4>登录 Vault

使用初始化过程中提供的 Root Token 登录 Vault：

```
/ # vault login hvs.fjs7SDom4gcpivKcj0pnyy0M
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.fjs7SDom4gcpivKcj0pnyy0M
token_accessor       iwZJyB2nA331ZcmBL2TPa1n6
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

或者通过网页登录