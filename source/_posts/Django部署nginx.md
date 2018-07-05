---
title: Django部署nginx
date: 2016-04-27 22:52:19
tags: [django, nginx, python]
description: Django自带的 python manage.py runserver只提供测试用，到了实际生产环境中，需要使用nginx要做请求转发
---

Django自带的 python manage.py runserver只提供测试用，到了实际生产环境中，需要使用nginx要做请求转发。

<!-- more -->

### 运行环境

- Ubuntu 14.1
- Python 2.7.10
- Django 1.9.5


### 搭建准备

**首先更新下 apt-get**

```
sudo apt-get update
```

**安装 nginx**

```
sudo apt-get install nginx
```

**修改 nginx配置文件信息，下面以 baidu.com 举例。**

```
vim /etc/nginx/sites-available/baidu
```

**修改信息为如下**

```
# the nginx server instance
server {
    listen 0.0.0.0:80;

    server_name baidu.com baidu;
    access_log /var/log/nginx/baidu.log;

    location / {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

      proxy_pass http://127.0.0.1:8000/;
      proxy_redirect off;
    }
 }
```

**配置好网站信息后，接着在nginx启用该站点**

```
cd /etc/nginx/sites-enabled/ 
ln -s /etc/nginx/sites-available/baidu baidu
```

**重启nginx**

```
sudo /etc/init.d/nginx restart
```

**进入Django所在目录**

```
cd /path/to/django_dir
python manage.py runserver
```

**但是此方法一旦SSH断开连接 服务器也会关闭，可以使用 screen来保持服务器一直开启。**

```
sudo apt-get install screen
screen python manage.py runserver
```