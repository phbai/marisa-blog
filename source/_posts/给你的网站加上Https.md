---
title: 给你的网站加上Https
date: 2016-05-07 16:44:48
tags: [nginx, let's encrypt, https]
from: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04
---

无论是手机还是PC上网的时候，如果网站采用的是普通的Http网站，可能会被运营商劫持，并在相应页面加上广告。

<!-- more -->

### 使用Https的好处

以前用http协议的时候，等于互联网公司给用户寄货，但随便选个包装然后让运营商配送给用户。运营商公司为了自己的利益，把包装拆开，在里面塞满了各种广告。甚至有可能，用户就买本书，结果包装里被运营商塞了整整一箱传单或者小卡片送了过去。甚至可能是下面的这种卡片。

![enter image description here](http://r6.loli.io/BjMR7b.png)

现在开始使用https协议了，互联网公司给用户寄货，不过这次选了一个保险箱给与用户寄货，开箱密码通过另外的渠道告诉用户，然后让运营商给用户配送过去。虽然这样成本高了很多，但是终于安全了。

### 搭建准备

- Nginx
- Git

**安装 nginx**

```
sudo apt-get install nginx
```

**安装 Git**

```
sudo apt-get install git
```

### 开始搭建

```
git clone https://github.com/letsencrypt/letsencrypt
```

进入相应文件夹，执行如下命令

```
./letsencrypt-auto certonly
```

会有一段时间的下载，完成后出现下图
![enter image description here](https://scarletmu.b0.upaiyun.com/blog/7524c1924522dcdf47190ebef0db5afc.png)

这里选择第二项，输入域名
![enter image description here](https://scarletmu.b0.upaiyun.com/blog/67aa65fd8990649bf5a251494a53e33c.png)

然后输入要绑定的域名,域名检测完毕之后同意他的协议即可,然后就会结束图形界面,提示成功啦!

到这里我们的Let’s Encrypt证书就创建完成了

为了提升安全性,我们需要建立Diffie-Hellman密钥,这里根据CPU性能不同要花不少时间

```
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

**完成后进入nginx.conf进行配置**

```
server{
    listen 443 ssl;
    
    server_name 域名;
    // 引入证书,提示成功时会给你证书的位置
    ssl_certificate /etc/letsencrypt/live/使用的域名/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/使用的域名/privkey.pem;
        
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security max-age=15768000;
    location / {
        // 反代信息
    }
}
// 80端口重定向至443端口
server {
    listen 80;
    server_name 域名;
    return 301 https://$host$request_uri;
}
```

### 重启nginx服务器

```
sudo service nginx restart
```

至此https已经搭建好了，你可以去 [ssllab](https://www.ssllabs.com/ssltest/analyze.html) 测试自己网站的https强度。一般通过Let's encrypt提供的SSL证书都是A+级别。
