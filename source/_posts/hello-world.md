---
title: 将博客从WordPress迁移到Hexo
---
一直想去学习markdown的使用，最近发现了一个静态博客[Hexo](https://hexo.io/zh-cn/)很好用，趁着最近清闲下来，学着将博客转移到hexo上,使用静态页面。
# 安装教程

~~请参照[官方教程](https://hexo.io/zh-cn/docs/)~~

# 使用Travis CI自动部署
首先使用 ```ssh-keygen```创建一个ssh key,以供*Github*使用。
```
$ ssh-keygen -t rsa -C "aha199277@qq.com"
```

```
$ gem install travis
$ travis login --auto
```
