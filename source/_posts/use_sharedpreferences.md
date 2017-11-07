---
title: 使用SharedPreferences遇到的一些问题
date: 2016-07-22 13:15:53
thumbnail: https://o5iqfmxl6.qnssl.com/2016-07-25_2c29dd5f0724b916044cbb7e410b7338.jpg-700
categories:
- 技术
tags:
- Android
- Java
- 网络请求
- Xposed
---
![](https://o5iqfmxl6.qnssl.com/2016-07-25_2c29dd5f0724b916044cbb7e410b7338.jpg-700)

# 0x0 背景

自从参加实习工作后，博客也没怎么更新了。。。（就是懒了）

<!-- more -->

最近在空闲时间撸了一个 **Xposed** 模块，用来修改**Pokémon GO**的定位坐标的。这个模块的思路来源于[这篇文章](http://drops.wooyun.org/tips/17840) ,因为乌云平台炸了，不知道何时恢复，因此可能暂时访问不了。这个模块有用户界面用于存储配置信息，但是在读取时使用 **Xposed** 自带的`XSharedPreferences`却出现读取不了的问题。今天写一记录一下在使用XSharedPreferences读取数据时遇到的坑点。

# 0x1 过程

最开始的时候我在写配置的时候使用的是`PreferenceManager.getDefaultSharedPreferences()`,在 **Xposed** 的`handleLoadPackage()`方法中hook本程序的`getApplicationContext()`方法去拿到 context,再使用`context.getSharedPreferences(BuildConfig.APPLICATION_ID, Context.MODE_WORLD_READABLE)`方法拿到`Preferences`，但是在使用它读取时无法读取到。而且这种方法即使可以也有个缺陷，就是每次使用前都要打开这个应用进行初始化，身为一个 xp 模块怎么能这么不中用呢！

转去 Google 发现，`XposedBridge`本身提供了一个类 : **XSharedPreferences**针对这种情况进行配置文件读取~

好咧，开工写代码 `XSharedPreferences preferences = new XSharedPreferences(BuildConfig.APPLICATION_ID);` 然而。。。。

仍然获取不到数据。。。

继续翻文档，我发现好像忽略了点什么，点开`getDefaultSharedPreferences()`方法的源码得知，它最后调用了`getSharedPreferences(name, Content.MODE_PRIVATE)`这个方法，也就是说生成的文件是私有的，而 Xposed 模块里的代码是hook 到 Andrioid 虚拟机那里，在目标 app 打开时调用的，所以`MODE_PRIVATE`肯定不能读取到，应该改为`MODE_WORLD_READABLE`。

OK,继续尝试，界面上的 Preferences 获取方法改成了`preferences = getSharedPreferences(BuildConfig.APPLICATION_ID, Context.MODE_WORLD_READABLE)`，再次运行，还是不行！！！

WTF！！！

`adb shell` ，cd 到安装目录找到配置文件，文件名称是`包名.xml`，运行目标程序之后，当前目录下又多了个`包名_prefs.xml`文件。。

<center>![2016-07-25_2016548158703.jpg](https://o5iqfmxl6.qnssl.com/2016-07-25_2016548158703.jpg)</center>

# 0x2 总结

所以说，原因就是两边的文件名不同。

- PACKAGE_NAME_prefs.xml:

  ``` java
  PreferenceManager.getDefaultSharedPreferences(context);
  XSharedPreferences(PACKAGE_NAME);
  ```

- name.xml:

  ```java
  context.getSharedPreferences(name, MODE);
  XSharedPreferences(PACKAGE_NAME, name);
  ```

以上~