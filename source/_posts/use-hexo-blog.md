---
title: 将博客从WordPress迁移到Hexo
date: 2016/04/06 20:44:25
categories:
- 技术
tags:
- Hexo
- Travis CI
---
![](http://7xsomm.com2.z0.glb.clouddn.com/16-4-7/22905034.jpg-700)

一直想去学习markdown的使用，最近发现了一个静态博客[Hexo](https://hexo.io/zh-cn/)很好用，趁着最近清闲下来，学着将博客转移到hexo上,使用静态页面。

<!-- more -->
# 安装教程

~~请参照[官方教程](https://hexo.io/zh-cn/docs/)~~


# 使用Travis CI自动部署

在使用的时候，发现每次写完文章都要手动推送到github,之后在使用hexo g -d进行部署，比较繁琐，因此发现了一个用于~~装逼~~自动构建的网站[Travis CI](https://travis-ci.org/)，这个网站是免费网站，目前Github上的绝大多数项目都已经移入到Travis CI的构建队列中。

## 准备
> 一个github帐号

> 一台电脑~~(Linux/Uinx更佳)~~

> 一个Travis CI帐号

## 建立.travis.yml文件
- 什么是.travis.yml文件？
- 简单来说，Travis CI通过Docker自动部署一个虚拟化平台，在上面安装一系列软件环境来模拟你的编译环境，这个文件就是来高数Travis CI怎么去构建这个环境。直接贴出来我的

``` bash
 language: node_js
sudo: false
node_js:
- stable
before_install:
- openssl aes-256-cbc -K $encrypted_8926b8c4a31e_key -iv $encrypted_8926b8c4a31e_iv
  -in ssh_key.enc -out ~/.ssh/id_rsa -d
- chmod 600 ~/.ssh/id_rsa
- eval $(ssh-agent)
- ssh-add ~/.ssh/id_rsa
- cp ssh_config ~/.ssh/config
- npm install hexo-cli -g
script:
- hexo clean
- hexo generate
- cd public
- git init
- git config user.name "ahjsrhj"
- git config user.email aha199277@qq.com
- git add .
- git commit -m "Update docs"
- git remote add origin git@github.com:ahjsrhj/ahjsrhj.github.io.git
- git push -f origin master

branches:
  only:
    - blog
```

注意其中的`openssl aes-256-cbc -K $encrypted_8926b8c4a31e_key -iv $encrypted_8926b8c4a31e_iv`这一行不要套用，应替换为自己的。在使用的时候先删除这一行和下面一行，其中部分信息修改为自己的。

## 生成Deploy Key
1. 使用`ssh-key`制作一个 SSH key
	``` bash
    $ ssh-keygen -t rsa -C "your_email@example.com"
    ```
生成过程中把passphrase留空。
2. 添加Key 到repo中

    生成之后把public key里的信息复制到你的repo的`Deploy keys`那里，如下。

![](http://7xsomm.com2.z0.glb.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-04-06%20%E4%B8%8B%E5%8D%888.03.38-f.png-hex)
    不应该添加到账户的`SSH and GPG keys`，这样能够限制key的权限只在当前项目。
## 加密Deploy Key
1. 安装Travis命令行工具，并登录
``` bash
$ gem install travis
$ travis login --auto
```
在登录时可能需要你的github帐号信息。
2. 加密
将刚刚生成的ssh_key复制到hexo blog根目录,在blog目录下执行
``` bash
$ travis encrypt-file ssh_key --add
```
若是提示找不到repo,使用`r`指令手动指定repo
``` bash
$ travis encrypt-file ssh_key --add -r ahjsrhj/ahjsrhj.github.io
```

之后Travis CI网站上对应repo设置里能看到两个值，同时你的.travis.yml文件中应该自动出现了一句类似这样的代码
``` bash
- openssl aes-256-cbc -K $encrypted_8926b8c4a31e_key -iv $encrypted_8926b8c4a31e_iv
  -in ssh_key.enc -out ~/.ssh/id_rsa -d
```
确保能将解密获得的key命名为id_rsa并放在`~/.ssh/`下面。之后将**ssh_key**删除

## 设置SSH并同步
再根目录建立`ssh_config`文件，设置Travis上的SSH
``` bash
Host github.com
  User git
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
```
之后设定便结束了,将代码同步到github，静等一分钟，enjoy it~
