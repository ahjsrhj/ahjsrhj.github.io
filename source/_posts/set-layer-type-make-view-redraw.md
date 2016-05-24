---
title: 自定义View setLayerType()方法会引起View重绘
date: 2016-05-24 21:43:13
categories:
- 技术
  tags:
- Android
- Java
- View
---

![](https://o5iqfmxl6.qnssl.com/md/1464097728554.png)

在开发一个检测体温的APP时，采用了自定义View控件作为温度显示模块，之后由于需要给背景添加阴影层，调用了`Paint.setShadowLayer()`方法，然而添加这个方法之后`View`没有任何反应，`Google`说需要给View设置软渲染，具体做法为调用`View`的`setLayerType(LAYER_TYPE_SOFTWARE, null)`方法，在开启它时，之后进行的绘制都会绘制到一张`Bitmap(software layer)`上，绘制完成后再渲染到`hardware layer`上。

> 官网介绍[如下](https://developer.android.com/reference/android/view/View.html#LAYER_TYPE_SOFTWARE)

然而在使用过程中，我发现View开始不停的重绘，开始以为是`LAYER_TYPE_SOFTWARE`的特性，因为将其换成`LAYER_TYPE_HARDWARE`就不会发生重绘，~~当然这样做以后上图中的阴影也没有了。。~~然后发现`setLayerType`方法被我放在了onDraw方法里。。才发现这个方法会引起View重绘，View重绘又再次调用这个方法，于是

# Boom！！！！！！！！！！！！！

