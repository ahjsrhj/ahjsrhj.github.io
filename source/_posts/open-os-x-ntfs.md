---
title: 打开Mac OS X原生NTFS功能
date: 2016/04/08 10:48:43
thumbnail: https://i.loli.net/2018/09/30/5bb06d997154b.png
categories:
- 技巧
tags:
- OS X
- NTFS
---
# 简介
>在使用OS X时，很多人都遇到了NTFS格式分区写入问题。
>第一种方法是使用第三方工具，诸如Paragon NTFS for MAC.虽然使用起来很简单，但是这个工具是收费的，而且用起来感觉不太稳定。
>其实在10.5的时候，OS X就支持直接写入NTFS分区的，只是后来由于微软限制，这个功能被屏蔽了。
>现在我们通过命令手动打开它

# 第一步
打开**磁盘工具**，找到你的NTFS分区，点击简介，记录下该盘的**UUID**。
![](https://i.loli.net/2019/06/14/5d035d21eec7517228.png)

可以看到，我的磁盘的**UUID**是`7AFE520E-E3A3-46CA-A971-7AC7D5B55331`

# 第二步
编辑/etc/fstab文件
`sudo vim /etc/fstab`
写入以下内容
``` Bash
UUID=7AFE520E-E3A3-46CA-A971-7AC7D5B55331 none ntfs rw,auto,nobrowse
```
最后一个**unbrowse*很重要，因为这个代表了在finder里不显示这个分区，这个选项非常重要，如果不打开的话挂载是不会成功的。
之后重启电脑就能识别，如果是移动硬盘，重新拔插就可以了。
但是有个很大的问题，这个分区在finder中不显示了，这里建议使用软连接将/Values目录链接到用户目录下。

``` Bash
$ ln -s /Volumes ~/Volumes
```

之后点开用户目录就能找到磁盘了。

~~用这种方法打开的是系统原生的ntfs功能，稳定实用，比第三方工具要好用的多了。~~
