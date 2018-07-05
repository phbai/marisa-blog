---
title: Ubuntu开启HTTPS和HTTP2
date: 2017-03-06 22:47:52
tags:
from: https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-with-http-2-support-on-ubuntu-16-04
---

本文主要记录一下从无到开启HTTPS和HTTP2的过程。

<!-- more -->

### 运行环境

- Ubuntu 16.04 LTS
- Nging 1.10.0
- OpenSSL 1.0.2g

### 一、安装最新版本 Nginx

**首先更新下 apt-get**

```
sudo apt-get update
```

**安装 nginx**

```
sudo apt-get install nginx
```

安装结束后，通过如下命令查看 Nginx 版本。

```
sudo nginx -v
```
应该返回如下结果

```
Ouput of sudo nginx -v
nginx version: nginx/1.10.0 (Ubuntu)
```
### 二、更改 Nginx 监听端口并开启 HTTP2
```
sudo vim /etc/nginx/sites-available/default
```
找到下列几行。
```
listen 80 default_server;
listen [::]:80 default_server;
```
更改为
```
listen 443 ssl http2 default_server;
listen [::]:443 ssl http2 default_server;
```
### 三、更改服务器名
还是在default文件中，更改server_name
```
server_name example.com;
```
到此这一步，可以通过如下命令测试Nginx服务配置是否正确。
```
sudo nginx -t
```
如果你上述步骤都没有问题，应该得到如下的返回结果。
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
### 四、添加SSL证书
因为HTTP2建议开启HTTPS，所以我们需要一个免费的HTTPS证书，这里推荐letsencrypt。
可通过如下命令安装 letsencrypt。
```
sudo apt-get install letsencrypt
```
安装完成后，执行如下指令生成SSL证书。
```
letsencrypt certonly
```
生成过程第一步是让你填写邮箱地址。
第二步是让你填写域名地址。填写格式为 example.com
证书生成完毕后，会得到如下结果。
```
Output:
IMPORTANT NOTES:
 - If you lose your account credentials, you can recover through
   e-mails sent to sammy@digitalocean.com
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/example.com/fullchain.pem. Your
   cert will expire on 2016-03-15. To obtain a new version of the
   certificate in the future, simply run Let's Encrypt again.
 - Your account credentials have been saved in your Let's Encrypt
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Let's
   Encrypt so making regular backups of this folder is ideal.
 - If like Let's Encrypt, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```
证书保存路径为 /etc/letsencrypt/example.com/live/

再次编辑default
```
sudo vim /etc/nginx/sites-available/default
```
添加如下SSL配置。
```
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
```

### 五、为SSL连接提高加密安全系数
```
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
```
然后在 /etc/nginx/sites-available/default 加入
```
ssl_dhparam  /etc/nginx/ssl/dhparam.pem;
```

### 六、重定向HTTP流量到HTTPS
在 default 下重开一个 server
```
server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    // other settings
}
server {
       listen         80;
       listen    [::]:80;
       server_name    example.com;
       return         301 https://$server_name$request_uri;
}
```

### 七、重启 Nginx 服务
至此，Nginx服务都配置完成了。你的配置应该如下所示。
```
server {
        listen 443 ssl http2 default_server;
        listen [::]:443 ssl http2 default_server;

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name example.com;

        location / {
                try_files $uri $uri/ =404;
        }

        ssl_certificate /etc/nginx/ssl/example.com.crt;
        ssl_certificate_key /etc/nginx/ssl/example.com.key;
        ssl_dhparam /etc/nginx/ssl/dhparam.pem;
}


server {
       listen         80;
       listen    [::]:80;
       server_name    example.com;
       return         301 https://$server_name$request_uri;
}
```
为了保存至此的修改，重启Nginx服务。
```
sudo service nginx restart
```
### 八、大功告成
你的服务器已经开启了HTTP2和HTTPS，那么怎么检查网站是否开启HTTP2协议呢。
打开Chrome开发工具，右键表头开启协议显示如下图所示。
![开启协议显示](https://assets.digitalocean.com/articles/nginx_http2/http2_check.png)
现在我们看到，所有的请求都是HTTP2请求。


