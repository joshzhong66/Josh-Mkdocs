

### 1.创建安装dashboard

```shell
#创建pods
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml


#查看运行的dashboard pod
kubectl get pods -n kubernetes-dashboard

#删除运行的dashboard pod
kubectl delete pods -n kubernetes-dashboard  <pod-name>


#查看运行的dashboard services
kubectl get services -n kubernetes-dashboard

#查看运行的dashboard services
kubectl delete service <services-name> --namespace=kubernetes-dashboard


```

### 2.修改NodePort类型

如果你的Service类型是`ClusterIP`，尝试更改为`NodePort`类型。这将使得Dashboard可以通过节点的IP地址和指定的端口进行访问。

将type: ClusterIP   改为   type: NodePort

```shell
[root@k8s-master01 kubernetes_file]# kubectl edit service kubernetes-dashboard -n kubernetes-dashboard
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
  creationTimestamp: "2023-11-21T00:44:43Z"
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  resourceVersion: "374070"
  uid: acb66186-6e42-4b80-8087-ed84bf01211e
spec:
  clusterIP: 10.107.169.51
  clusterIPs:
  - 10.107.169.51
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: NodePort
status:
```



**检查 `dashboard` 服务状态：**

- 运行以下命令检查 `dashboard 服务的状态：

```shell
[root@k8s-master01 kubernetes_file]# kubectl get services -n kubernetes-dashboard
NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
dashboard-metrics-scraper   ClusterIP   10.108.113.165   <none>        8000/TCP        6m49s
kubernetes-dashboard        NodePort    10.107.169.51    <none>        443:30368/TCP   7m2s
```

### 3.访问dashboard web后台



查询到对应的服务与端口，通过https://ip+端口，进行访问，如：https://192.168.31.150:30368/

![image-20231121085520110](C:\Users\Josh\AppData\Roaming\Typora\typora-user-images\image-20231121085520110.png)



### 4.获取dashboard的token

参考官方文档

https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md



**创建服务账户**

vim  dashboard-adminuser.yaml

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```

通过命令`kubectl apply -f dashboard-adminuser.yaml`创建它





**创建 ClusterRoleBinding**

`kops`在大多数情况下，使用`kubeadm`或任何其他流行工具配置集群后，`ClusterRole` `cluster-admin`集群中已经存在。我们可以使用它并为`ClusterRoleBinding`我们的`ServiceAccount`. 如果不存在，那么您需要先创建该角色并手动授予所需的权限。

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```



**获取 ServiceAccount 的不记名令牌**

现在我们需要找到可用于登录的令牌。执行以下命令：

```shell
[root@k8s-master01 kubernetes_file]# kubectl -n kubernetes-dashboard create token admin-user
```

可以将生成的token复制到web即可登录

```
eyJhbGciOiJSUzI1NiIsImtpZCI6IlgtbmMwN1hQY01SVmU4bUpFS19rVmZSN2ZmQW1sQ05ibzJmc2ZhS0NtTEkifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzAwNTMzOTY4LCJpYXQiOjE3MDA1MzAzNjgsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiZjY1YWYyMDktY2NhYy00OWY2LWFlNzMtMTI1Mzk1OTNlYTZhIn19LCJuYmYiOjE3MDA1MzAzNjgsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.cv2oqAxqPvHKt_QwW_9igHsGeW_WOfnucZiNSdPow_2IqCcboNgIqoThxzllEROBd-9-WohZszignVAPpHtyA03geX5tlKYFdRI5S6HG7g1K3eE8Li_2QvUAi3tlCuIXYnZOGClcHKQFSyEGU3KoTctD0uLiAuwmoLnszGVfJZB2NmVJPxw0C95TWwp2cPNVyVOOJxBWJG5UImDjzAqrthJNERP-3RjySGYgDsklWrar-saWrUrrVGXkm_viX-OCXzjkrPS2mEhHvAP2AUg8Dwp2nUHKlAU7zLgGP9D4nIs0DUyXOTPCj5BUmrcQKrGqqK6F57GRFMH6GHIXyvtazQ
```

**为 ServiceAccount 获取长期持有者令牌**

我们还可以使用绑定服务帐户的 Secret 创建一个令牌，该令牌将保存在 Secret 中：

```
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token  
```

创建Secret后，我们可以执行以下命令来获取Secret中保存的token：

```
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

复制token登录

```
eyJhbGciOiJSUzI1NiIsImtpZCI6IlgtbmMwN1hQY01SVmU4bUpFS19rVmZSN2ZmQW1sQ05ibzJmc2ZhS0NtTEkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJmNjVhZjIwOS1jY2FjLTQ5ZjYtYWU3My0xMjUzOTU5M2VhNmEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.WyrSX__DpMdd8PLxhe4Cf0Uwa9fK9i-6hhGC2qyOYxmqv8zJ0qN0JDOE_4WXO1Vr6MC7CJdJVBaRepA9YmR9E88IX2eAoS7O7B14BuNUqsrgG7STCIv4AgIgI29HDTtHvXh2VHcoGO1GWPsItdkgzn19V9U5jswKxXlftJ-mwZyd4_LiRwdurKfzcJLV39oWWezxLM3AjQlwdgkxty7EaOicMtZ6ttYUsPvQl9iHDDcDH8C0wMXnyGhgxjUHVX8kIysMwwdXlMgKtiQ1GhYzC785UtI4S9_nXyaA1QCS-UgPeoMbCmWAhziIugVjimndIVfD-XjCsok1BGfE1FfJhQ
```



### 5.登入dashboard

![image-20231121094346167](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/17/59e8b1b4e3562c3c97aa431673986e75-image-20231121094346167-b99fa9.png)

![image-20231121093913745](C:\Users\Josh\AppData\Roaming\Typora\typora-user-images\image-20231121093913745.png)



单击`Sign in`按钮即可。您现在已以管理员身份登录。



![image-20231121094808902](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/17/06d8feabdedc58f0d6cc741eb9a6b18a-image-20231121094808902-b829c0.png)



### 删除管理员

删除管理员`ServiceAccount`和`ClusterRoleBinding`.

```
kubectl -n kubernetes-dashboard delete serviceaccount admin-user
kubectl -n kubernetes-dashboard delete clusterrolebinding admin-user
```

