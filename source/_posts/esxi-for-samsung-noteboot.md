---
title: 在闲置笔记本上安装ESXi的坑
date: 2017-11-25 15:36:41
categories:
- 技术
tags:
- ESXi
---
# 0x00
大学时用的笔记本是爆炸星的**370R5E**,3代i3的处理器，显卡 8750m，性能还不错~在寝室的时候就靠它打游戏了。不过从工作了之后（事实上从大三常年泡在学校网络中心之后），这台本子基本处于闲置状态，前段时间突发奇想，把它拎出来装了个群晖当做NAS ~~(其实只是用来备份MBP)~~，结果才发现免费撸的K2 LAN 口都是百兆的。百兆的局域网备份。。我还不如用移动硬盘呢。再加上K2上跑了一堆东西，性能已经是不太够了，趁着换掉它。于是入了洋垃圾**R6300V2**。

咳，说了一堆目前跟文章没什么关联，前段时间双十一忽悠基友上车买了PS4 slim，这段时间一直跟他开黑。坑爹的小米插座插满了，ps4没地方插了，于是打游戏的时候就把 NAS 电源拔了，~~于是就忘了插，~~所以 NAS 罢工很多天了。今天突(xian)发(de)奇(dan)想(teng)，把群晖系统干掉了(~~其实就是把引导U盘给格式化了~~)，然后打算装个ESXi玩玩。碰到了几个坑，记录如下:

# 0X01 nfs41client failed to load
这个问题Google了一下，官方论坛说的是需要**10/100/1000M**有线网卡才可以，具体搜索是 **RTL8111** 网卡不支持。
详细解决方案在[这里](https://opoo.org/2015/install-vmware-esxi-6.0-with-88se9230-and-rtl8111e/)

- 下载工具 [ESXi-Customizer](http://www.v-front.de/p/esxi-customizer.html#download)
- 下载 [Realtek RTL8111e 驱动](http://vibsdepot.v-front.de/depot/vft/net51-drivers-1.0/net51-drivers-1.0.0-1vft.510.0.0.799733.x86_64.vib)
- 解压并打开 **ESXi-Customizer**，运行后弹出软件窗口第一个选择ESXi安装镜像，我的是6.5，第二个选择下载的网卡驱动。这里注意如果看不到 .vib 驱动文件，需要在弹出选择文件窗口中选择文件类型。之后生成即可。


> 需要注意的是，这款软件不支持Win10，用记事本打开脚本，搜索 **unsupport**，在那一行前面添加**REM **即可![](https://o5iqfmxl6.qnssl.com/ESXi-Customizer-Win10_2-2.png)
生成后建议使用[rufus](http://rufus.akeo.ie/?locale=zh_CN)进行u盘的烧录。




# 0x02 Failed to Validate Acceptance Level. Failed to Check Acceptance Level: None

这个问题比较好解决，重启笔记本，进入BIOS，将系统安全引导([Secure Boot](http://www.ruanyifeng.com/blog/2013/01/secure_boot.html)）关掉即可。