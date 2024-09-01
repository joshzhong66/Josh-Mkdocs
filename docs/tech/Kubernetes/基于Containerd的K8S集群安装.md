# 1 K8S集群安装



## **前言**

**Kubeadm-Containerd集群安装**

基于containerd容器运行时部署k8s 1.28集群



## **一 硬件和系统**

| 操作系统版本 | Centos7.9 |
| ------------ | --------- |

| CPU  | 内存 | 硬盘 | 角色         | 主机名       |
| ---- | ---- | ---- | ------------ | ------------ |
| 2c   | 4G   | 30G  | master       | k8s-master01 |
| 1c   | 4G   | 30G  | worker(node) | k8s-worker01 |
| 1c   | 4G   | 30G  | worker(node) | k8s-worker02 |



## **二 基础配置**

​		由于本次使用3台主机完成kubernetes集群部署，其中1台为master节点,名称为k8s-master01;其中2台为worker节点，名称分别为：k8s-worker01及k8s-worker02。

### **2.1 配置主机名**

| master节点   | hostnamectl set-hostname k8s-master01 | 192.168.31.150 |
| ------------ | ------------------------------------- | -------------- |
| worker01节点 | hostnamectl set-hostname k8s-worker01 | 192.168.31.151 |
| worker02节点 | hostnamectl set-hostname k8s-worker02 | 192.168.31.152 |

三台对应的设备分别执行：

```
master节点
# hostnamectl set-hostname k8s-master01

worker01节点
# hostnamectl set-hostname k8s-worker01

worker02节点
# hostnamectl set-hostname k8s-worker02
```

### **2.2 主机名与IP地址解析**

所有集群主机均需要进行配置。

```shell
# cat >> /etc/hosts << EOF
192.168.31.150 k8s-master01
192.168.31.151 k8s-worker01
192.168.31.152 k8s-worker02
EOF
```

### **2.3 防火墙 & selinux**

所有主机均需要操作。修改SELinux配置需要重启操作系统。

```
#关闭防火墙
# systemctl disable firewalld && systemctl stop firewalld && firewall-cmd --state

#关闭selinux
# sed -ri 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config        && getenforce 0
```

### **2.4 时间同步配置**

所有主机均需要操作。最小化安装系统需要安装ntpdate软件。

```
#安装ntp
# yum install -y ntpdate 

#配置ntp自动更新时间

# crontab -e
0 */1 * * * /usr/sbin/ntpdate time1.aliyun.com
```

### **2.5 升级操作系统内核**

```
#导入elrepo gpg key
# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org



#安装elrepo YUM源仓库
# yum -y install https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm



#安装kernel-ml版本，ml为最新稳定版本，lt为长期维护版本
# yum --enablerepo="elrepo-kernel" -y install kernel-lt.x86_64

  
#设置grub2默认引导为0
# echo 'GRUB_DEFAULT="0"' | tee -a /etc/default/grub


#重新生成grub2引导文件
# grub2-mkconfig -o /boot/grub2/grub.cfg


重启系统
# reboot

重启后，需要验证内核是否为更新对应的版本
# uname -r
5.4.260-1.el7.elrepo.x86_64
```

### **2.6 配置内核转发及网桥过滤**

```
所有主机均需要操作。

添加网桥过滤及内核转发配置文件
# cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
EOF


加载br_netfilter模块
# modprobe br_netfilter


查看是否加载
# lsmod | grep br_netfilter
br_netfilter           22256  0
bridge                151336  1 br_netfilter
```

### **2.7 安装ipset及ipvsadm**

所有主机都需要操作

```
安装ipset及ipvsadm
# yum -y install ipset ipvsadm


配置ipvsadm模块加载方式
添加需要加载的模块
# cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF


授权、运行、检查是否加载
# chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack
```

### 2.8 关闭SWAP分区

```
修改完成后需要重启操作系统，如不重启，可临时关闭，命令为
# swapoff -a

永远关闭swap分区，需要重启操作系统
sed -ri 's/.*swap.*/#&/' /etc/fstab

重启系统
# reboot
```



## **三 容器运行时 Containerd准备**

### **3.1 Containerd获取**

Containerd获取部署文件，访问github

![image-20240424171750167](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/a88782be3941c39cfbfc27ba2079e0a7-image-20240424171750167-5d9b81.png)

![image-20240424171754208](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/c69fedb434ae698e1e592e702abadfc9-image-20240424171754208-258d03.png)

![image-20240424171758669](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/de84b760fb59e9ee58f15eaf3cfe5399-image-20240424171758669-fb10a5.png)

![image-20240424172120464](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/0d5908dd8272b3f1fa66894e87d0b93d-image-20240424172120464-8ce5a8.png)

下载解压：

```
下载
# wget https://github.com/containerd/containerd/releases/download/v1.7.3/cri-containerd-1.7.3-linux-amd64.tar.gz

解压
# tar zxvf cri-containerd-1.7.3-linux-amd64.tar.gz -C /
```

### **3.2 Containerd配置文件生成并修改**

```
# mkdir /etc/containerd

# containerd config default > /etc/containerd/config.toml

# vim /etc/containerd/config.toml
sandbox_image = "registry.k8s.io/pause:3.9" 由3.8修改为3.9
```

### **3.3 Containerd启动及开机自启动**

```
# systemctl enable --now containerd

验证其版本
# containerd --version
```

### **3.4 runc准备**

![image-20240424172212688](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/f997cee12b1d2d863ebf65acec1c8653-image-20240424172212688-45c20c.png)

![image-20240424172216113](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/7e0dedf872d6df880de9d5d3ffdcaa7e-image-20240424172216113-77bfed.png)

![image-20240424172219779](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/f8221ef1800ffabdf2494aff6ad59bde-image-20240424172219779-81e23a.png)

### **3.5 ibseccomp准备**

![image-20240424172230719](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/1d2bdee071b9d3570e40db76fbee4f72-image-20240424172230719-7afd24.png)

```
安装 gcc,编译需要
# yum install gcc -y

# wget https://github.com/opencontainers/runc/releases/download/v1.1.5/libseccomp-2.5.4.tar.gz

# tar xf libseccomp-2.5.4.tar.gz

# cd libseccomp-2.5.4/

# yum install gperf -y

# ./configure

# make && make install

# find / -name "libseccomp.so"
```

### **3.6 runc安装**

![image-20240424172246854](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/8348ac0f28fcdddbf76d56dd5d0d45cb-image-20240424172246854-86d49f.png)

```
# wget https://github.com/opencontainers/runc/releases/download/v1.1.9/runc.amd64

# chmod +x runc.amd64

查找containerd安装时已安装的runc所在的位置，然后替换
# which runc

替换containerd安装已安装的runc
# mv runc.amd64 /usr/local/sbin/runc

执行runc命令，如果有命令帮助则为正常
# runc
```

​		如果运行runc命令时提示：runc: error while loading shared libraries: libseccomp.so.2: cannot open shared object file: No such file or directory，则表明runc没有找到libseccomp，需要检查libseccomp是否安装，本次安装默认就可以查询到。



## **四 K8S集群部署**

### **4.1 K8S集群软件YUM源准备**

google提供YUM源：

```
# cat > /etc/yum.repos.d/k8s.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```

阿里云提供YUM源：

```
# cat > /etc/yum.repos.d/k8s.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

### **4.2 K8S集群软件安装**

```
默认安装
# yum -y install  kubeadm  kubelet kubectl


查看指定版本
# yum list kubeadm.x86_64 --showduplicates | sort -r
# yum list kubelet.x86_64 --showduplicates | sort -r
# yum list kubectl.x86_64 --showduplicates | sort -r

安装指定版本
# yum -y install  kubeadm-1.28.X-0  kubelet-1.28.X-0 kubectl-1.28.X-0
```

### **4.3 配置kubelet**

​		为了实现docker使用的cgroupdriver与kubelet使用的cgroup的一致性，建议修改如下文件内容。

```
# vim /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS="--cgroup-driver=systemd"


设置kubelet为开机自启动即可，由于没有生成配置文件，集群初始化后自动启动
# systemctl enable kubelet
```

### **4.4 集群初始化**

#### **4.4.1 替换100年证书kubeadm**

```
# which kubeadm
/usr/bin/kubeadm
```

![image-20240424172346875](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/3d3d8b6fc39f0c06e0d5a40f8b96d0ef-image-20240424172346875-5fe805.png)

![image-20240424172349698](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/5ca4a89117b4e8ef043124bf4d190938-image-20240424172349698-173586.png)

![image-20240424172354152](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/e7252003f99cd2883001f13c8198a19e-image-20240424172354152-b5ad4f.png)

![image-20240424172400130](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/0f46ade817a28ccb9573f0a6b431fdda-image-20240424172400130-4cad06.png)

```
下载
# wget https://github.com/kubernetes/kubernetes/archive/refs/tags/v1.28.0.tar.gz

# ls
v1.28.0.tar.gz

解压
# tar zxvf v1.28.0.tar.gz

# ls
kubernetes-1.28.0
```

修改kubernetes源码

修改CA证书为100年有效期（默认为10年）

```
[root@k8s-master01 ~]# vim kubernetes-1.28.0/staging/src/k8s.io/client-go/util/cert/cert.go

 72         tmpl := x509.Certificate{
 73                 SerialNumber: serial,
 74                 Subject: pkix.Name{
 75                         CommonName:   cfg.CommonName,
 76                         Organization: cfg.Organization,
 77                 },
 78                 DNSNames:              []string{cfg.CommonName},
 79                 NotBefore:             notBefore,
 80                 NotAfter:              now.Add(duration365d * 100).UTC(),
 81                 KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
 82                 BasicConstraintsValid: true,
 83                 IsCA:                  true,
 84         }
```

> 修改说明：
>
> 把文件中80行，10修改为100即可 。

修改kubeadm证书有效期为100年（默认为1年）

```
[root@k8s-master01 ~]# vim kubernetes-1.28.0/cmd/kubeadm/app/constants/constants.go
 ......
 37 const (
 38         // KubernetesDir is the directory Kubernetes owns for storing various configuration files
 39         KubernetesDir = "/etc/kubernetes"
 40         // ManifestsSubDirName defines directory name to store manifests
 41         ManifestsSubDirName = "manifests"
 42         // TempDirForKubeadm defines temporary directory for kubeadm
 43         // should be joined with KubernetesDir.
 44         TempDirForKubeadm = "tmp"
 45
 46         // CertificateBackdate defines the offset applied to notBefore for CA certificates generated by kubeadm
 47         CertificateBackdate = time.Minute * 5
 48         // CertificateValidity defines the validity for all the signed certificates generated by kubeadm
 49         CertificateValidity = time.Hour * 24 * 365 * 100
```

> 修改说明：
>
> 把CertificateValidity = time.Hour * 24 * 365 修改为：CertificateValidity = time.Hour * 24 * 365 * 100

#### **4.4.2 安装go**

![image-20240424172454833](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/15443260bafaa6ddd6e8535f0b890014-image-20240424172454833-a35bb4.png)

![image-20240424172501682](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/9e866e539f7b2a27881cd76d9bef5ec4-image-20240424172501682-751d0d.png)

```
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz

[root@k8s-master01 ~]# tar xf go1.21.0.linux-amd64.tar.gz

[root@k8s-master01 ~]# mv go /usr/local/go

[root@k8s-master01 ~]# vim /etc/profile
[root@k8s-master01 ~]# cat /etc/profile
export PATH=$PATH:/usr/local/go/bin

[root@k8s-master01 ~]# source /etc/profile

[root@k8s-master01 ~]# go version
go version go1.21.0 linux/amd64
```

#### **4.4.3 kubernetes源码编译**

```
安装rsync,编译要用
yum install rsync -y  


[root@k8s-master01 ~]# cd kubernetes-1.28.0/
[root@k8s-master01 kubernetes-1.28.0]# make all WHAT=cmd/kubeadm GOFLAGS=-v


[root@k8s-master01 kubernetes-1.28.0]# ls
_output


[root@k8s-master01 kubernetes-1.28.0]# ls _output/
bin  local
[root@k8s-master01 kubernetes-1.28.0]# ls _output/bin/
kubeadm  ncpu
```

#### **4.4.4 校验两个kubeadm 文件md5值（可以不校验）**

```
[root@k8s-master01 bin]# md5sum kubeadm 
1d4728a043de707093644ffbd949bca9  kubeadm
```

#### **4.4.5 替换所有集群主机kubeadm**

```
[root@k8s-master01 kubernetes-1.28.0]# which kubeadm
/usr/bin/kubeadm
[root@k8s-master01 kubernetes-1.28.0]# rm -rf `which kubeadm`
[root@k8s-master01 kubernetes-1.28.0]# cp _output/bin/kubeadm /usr/bin/kubeadm
[root@k8s-master01 kubernetes-1.28.0]# which kubeadm
/usr/bin/kubeadm

worker01和worker02删除
[root@k8s-worker01 ~]# rm -rf `which kubeadm`
[root@k8s-worker02 ~]# rm -rf `which kubeadm`


复制文件到worker
[root@k8s-master01 kubernetes-1.28.0]# scp _output/bin/kubeadm 192.168.31.151:/usr/bin/kubeadm
[root@k8s-master01 kubernetes-1.28.0]# scp _output/bin/kubeadm 192.168.31.152:/usr/bin/kubeadm
```

#### **4.4.6 获取kubernetes 1.28组件容器镜像**

```
# kubeadm config images list
registry.k8s.io/kube-apiserver:v1.28.0
registry.k8s.io/kube-controller-manager:v1.28.0
registry.k8s.io/kube-scheduler:v1.28.0
registry.k8s.io/kube-proxy:v1.28.0
registry.k8s.io/pause:3.9
registry.k8s.io/etcd:3.5.9-0
registry.k8s.io/coredns/coredns:v1.10.1



拉取镜像
# kubeadm config images pull
[config/images] Pulled registry.k8s.io/kube-apiserver:v1.28.3
[config/images] Pulled registry.k8s.io/kube-controller-manager:v1.28.3
[config/images] Pulled registry.k8s.io/kube-scheduler:v1.28.3
[config/images] Pulled registry.k8s.io/kube-proxy:v1.28.3
[config/images] Pulled registry.k8s.io/pause:3.9
[config/images] Pulled registry.k8s.io/etcd:3.5.9-0
[config/images] Pulled registry.k8s.io/coredns/coredns:v1.10.1
```

#### **4.4.7 集群初始化**

```
初始化
# kubeadm init --kubernetes-version=v1.28.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.31.150  --cri-socket unix:///var/run/containerd/containerd.sock
```

如果只用Containerd，不用docker，可以不加--cri-socket unix:///var/run/containerd/containerd.sock

> 在Kubernetes（通常简称为K8s）中，**--cri-socket** 参数用于指定容器运行时（Container Runtime Interface，CRI）的套接字地址。CRI是Kubernetes与容器运行时之间的接口，允许Kubernetes与不同的容器运行时进行通信，如Docker、containerd等。

```

[root@k8s-master01 ~]# kubeadm init --kubernetes-version=v1.28.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.31.150  --cri-socket unix:///var/run/containerd/containerd.sock
[init] Using Kubernetes version: v1.28.0
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.31.150]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master01 localhost] and IPs [192.168.31.150 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master01 localhost] and IPs [192.168.31.150 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[kubelet-check] Initial timeout of 40s passed.
[apiclient] All control plane components are healthy after 103.502051 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-master01 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 2n0t62.gvuu8x3zui9o8xnc
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.31.150:6443 --token 2n0t62.gvuu8x3zui9o8xnc \
        --discovery-token-ca-cert-hash sha256:d294c082cc7e0d5f620fb10e527a8a7cb4cb6ccd8dc45ffaf2cddd9bd3016695
```



## **五 工作节点加入集群**

### **5.1 worker节点执行命令加入**

```
kubeadm join 192.168.31.150:6443 --token 2n0t62.gvuu8x3zui9o8xnc \
        --discovery-token-ca-cert-hash sha256:d294c082cc7e0d5f620fb10e527a8a7cb4cb6
```

kubectl get nodes使用报错

![image-20240424172827474](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/b340487bf8065f781e19e03755e0d98c-image-20240424172827474-f95632.png)

报错需要如下配置：

```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

### **5.2 验证K8S集群节点是否可用**

```
[root@k8s-master01 ~]# kubectl get nodes
NAME           STATUS     ROLES           AGE   VERSION
k8s-master01   NotReady   control-plane   30m   v1.28.2
k8s-worker01   NotReady   <none>          19m   v1.28.2
k8s-worker02   NotReady   <none>          18m   v1.28.2
```

### **5.3 验证证书有效期**

```
[root@k8s-master01 ~]# openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep ' Not '
            Not Before: Nov 14 08:10:42 2023 GMT
            Not After : Oct 21 08:15:42 2123 GMT
            

[root@k8s-master01 ~]# kubeadm certs check-expiration
[check-expiration] Reading configuration from the cluster...
[check-expiration] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'

CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Oct 21, 2123 08:15 UTC   99y             ca                      no      
apiserver                  Oct 21, 2123 08:15 UTC   99y             ca                      no      
apiserver-etcd-client      Oct 21, 2123 08:15 UTC   99y             etcd-ca                 no      
apiserver-kubelet-client   Oct 21, 2123 08:15 UTC   99y             ca                      no      
controller-manager.conf    Oct 21, 2123 08:15 UTC   99y             ca                      no      
etcd-healthcheck-client    Oct 21, 2123 08:15 UTC   99y             etcd-ca                 no      
etcd-peer                  Oct 21, 2123 08:15 UTC   99y             etcd-ca                 no      
etcd-server                Oct 21, 2123 08:15 UTC   99y             etcd-ca                 no      
front-proxy-client         Oct 21, 2123 08:15 UTC   99y             front-proxy-ca          no      
scheduler.conf             Oct 21, 2123 08:15 UTC   99y             ca                      no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Oct 21, 2123 08:15 UTC   99y             no      
etcd-ca                 Oct 21, 2123 08:15 UTC   99y             no      
front-proxy-ca          Oct 21, 2123 08:15 UTC   99y             no 
```



## **六 网络插件calico部署**

calico访问链接：https://projectcalico.docs.tigera.io/about/about-calico

![image-20240424172859041](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/564c3e6325621b5ea8799863e63483e0-image-20240424172859041-90e388.png)

![image-20240424172903411](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/2bbd8d6f7888baac03f511879de3881e-image-20240424172903411-1a5bbc.png)

```python
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

# wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml


# vim custom-resources.yaml


# cat custom-resources.yaml


# This section includes base Calico installation configuration.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 10.244.0.0/16 修改此行内容为初始化时定义的pod network cidr
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
      

---

# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}


# kubectl create -f custom-resources.yaml

installation.operator.tigera.io/default created
apiserver.operator.tigera.io/default created





[root@k8s-master01 ~]# kubectl get pods -n calico-system
NAME                                       READY   STATUS    RESTARTS       AGE
calico-kube-controllers-7dbdcfcfcb-gv74j   1/1     Running   0              120m
calico-node-7k2dq                          1/1     Running   7 (107m ago)   120m
calico-node-bf8kk                          1/1     Running   7 (108m ago)   120m
calico-node-xbh6b                          1/1     Running   7 (107m ago)   120m
calico-typha-9477d4bb6-lcv9f               1/1     Running   0              120m
calico-typha-9477d4bb6-wf4hn               1/1     Running   0              120m
csi-node-driver-44vt4                      2/2     Running   0              120m
csi-node-driver-6867q                      2/2     Running   0              120m
csi-node-driver-x96sz                      2/2     Running   0              120m
```