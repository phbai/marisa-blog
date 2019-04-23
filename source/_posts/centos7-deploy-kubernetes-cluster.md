---
title: centos7 部署Kubernetes集群
date: 2019-04-16 11:09:15
tags: [centos7,kubernetes]
published: true
hideInList: false
feature: https://cdn-images-1.medium.com/max/1600/1*2fbCZovS7I1gye1PREqkVQ.png
---
## 准备工作
1. 禁用selinux
```bash
setenforce 0 # 临时禁用selinux
vi /etc/selinux/config

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled  # 改为disabled
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```
		
2. 将主机名写入hosts文件中`vi /etc/hosts`
```bash
[root@VM_0_11_centos ~]# vi /etc/hosts
127.0.0.1 VM_0_11_centos VM_0_11_centos # 加入这行
::1 VM_0_11_centos VM_0_11_centos # 加入这行
```
		
3. 禁用swap分区
```bash
swapoff -a # 临时禁用swap分区
vi /etc/fstab 注释掉swap的项 # 永久禁用swap分区

# 关闭swap之后可以 free -m 检验 如果Swap这行都是 0 则说明swap被关闭
[root@VM_0_11_centos ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:            991         182          69           0         739         625
Swap:             0           0           0
```

4. 重启服务器
```bash
reboot
```

## 步骤
### 1. 加入yum repo
```bash
cat <<EOF > /etc/yum.repos.d/centos.repo
[centos]
name=CentOS-7
baseurl=http://ftp.heanet.ie/pub/centos/7/os/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://ftp.heanet.ie/pub/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7
#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=http://ftp.heanet.ie/pub/centos/7/extras/x86_64/
enabled=1
gpgcheck=0
EOF
```

### 2.安装docker
```bash
yum -y update 
yum -y install docker
systemctl enable docker
systemctl start docker
```

### 3. 安装kubelet、kubeadm
```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# 安装kubelet kubeadm kubectl
yum -y install kubelet kubeadm kubectl

# 启动kubelet
systemctl start kubelet

# 设置kubelet开机自启动
systemctl enable kubelet
```

### 4. 额外的配置
```bash
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
echo 1 > /proc/sys/net/ipv4/ip_forward
```

### 5. 初始化集群
```bash
kubeadm init --pod-network-cidr=10.244.0.0/16
```

### 6. 做好备份
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 7.额外的操作
```bash
sysctl net.bridge.bridge-nf-call-iptables=1

# 安装flannel网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
```

### 8.检验是否部署成功
```bash
kubectl get nodes

[root@VM_0_11_centos ~]# kubectl get nodes
NAME             STATUS   ROLES    AGE   VERSION
VM_0_11_centos   Ready    master   14d   v1.14.0

# 默认master节点是不能调度pod 使用以下命令解除限制
kubectl taint nodes --all node-role.kubernetes.io/master-
```