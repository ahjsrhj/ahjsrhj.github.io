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
这个问题Google了一下，官方论坛说的是需要**10/100/1000M**有线网卡才可以，具体搜索实际的原因是网卡未被识别， **RTL8111** 网卡驱动未被包含在 ESXi 5.5 的包里面，所以需要解包安装镜像，将驱动打入然后重新打包。
详细解决方案在[这里](https://opoo.org/2015/install-vmware-esxi-6.0-with-88se9230-and-rtl8111e/)

- 下载工具 [ESXi-Customizer](http://www.v-front.de/p/esxi-customizer.html#download)
- 下载 [Realtek RTL8111e 驱动](http://vibsdepot.v-front.de/depot/vft/net51-drivers-1.0/net51-drivers-1.0.0-1vft.510.0.0.799733.x86_64.vib)
- 解压并打开 **ESXi-Customizer**，运行后弹出软件窗口第一个选择ESXi安装镜像，我的是5.5，第二个选择下载的网卡驱动。这里注意如果看不到 .vib 驱动文件，需要在弹出选择文件窗口中选择文件类型。之后生成即可。


> 需要注意的是，这款软件不支持Win10，用记事本打开脚本，搜索 **unsupport**，在那一行前面添加**REM **即可![](https://i.loli.net/2019/06/14/5d035cfa8b92226127.png)
生成后建议使用[rufus](http://rufus.akeo.ie/?locale=zh_CN)进行u盘的烧录。




# 0x02 Failed to Validate Acceptance Level. Failed to Check Acceptance Level: None

这个问题比较好解决，重启笔记本，进入BIOS，将系统安全引导([Secure Boot](http://www.ruanyifeng.com/blog/2013/01/secure_boot.html)）关掉即可。


# 0x03 PCPU 0 locked up. failed to ack TLB invalidate

之后就是碰到了这个问题，搜索一番没有任何[收获](https://kb.vmware.com/s/article/2091670)，猜测是因为我安装的系统版本为 ESXi 6.5, 而在**0x01**中附加网卡驱动所用到的打包工具所支持的最高版本为 ESXi5.5，重新下载5.5版的镜像并把驱动打入即可。

# 0x04 尝试升级至 ESXi 6.5

先说一下结果，以失败告终。
1. 下载6.5镜像使用**ESXi-Customizer**将驱动打入，全新安装
结果:
> 安装无法继续，进度条还没读完就报错#0x03
2. 下载6.5镜像使用[**ESXi-Customizer-PS**](http://www.v-front.de/p/esxi-customizer-ps.html)将驱动打入，全新安装
结果:
> 因为开始用的**ESXi-Customizer**是不支持win10以及6.5版的系统的，猜测上一次安装失败是因为打出来的安装镜像有问题导致的，因此使用最新版本支持win10以及6.5版本ESXi的工具重新打包安装，结果仍然失败，报错#0x03
3. 安装5.5版本系统成功后，下载6.5升级包，在终端进行系统升级
结果:
> 失败。启动时报错#0x03。

*经过尝试发现这台机器以我现有的技术手段无法安装最新版ESXi，因此还是老老实实使用5.5版的系统吧。以上~*
