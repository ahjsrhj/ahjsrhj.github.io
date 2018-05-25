---
title: 解决 Only fullscreen opaque activities can request orientation
date: 2018-05-25 11:49:36
categories:
- 技术
tags:
- Android
- Java
- Android O
- BUG!!
description: "Only fullscreen opaque activities can request orientation Android O 引入的BUG"
---

![1527220441406.png](https://i.loli.net/2018/05/25/5b0788dd673ed.png)

这段时间把App的`targetSDKVersion`升级到了27，昨晚上线之后今早看到后台一堆崩溃，全是 Android 8.0 的设备，因为手头设备有限，测试的时候只测了Android 8.1的设备，没想到还有一个这个坑埋在这里，记录一下处理办法。

<!-- more -->

# 问题分析

当`targetSDKVersion`为26或者27时，在 Android 8.0 的设备上，一些设置了`windowIsTranslucent`标志，将背景设为透明，同事将屏幕方向锁定的`Activity`，会崩溃并抛出这个异常:

```
 Caused by: java.lang.IllegalStateException: Only fullscreen opaque activities can request orientation
        at android.app.Activity.onCreate(Activity.java:1007)
        at android.support.v4.app.SupportActivity.onCreate(SupportActivity.java:66)
        at android.support.v4.app.FragmentActivity.onCreate(FragmentActivity.java:321)
        at android.support.v7.app.AppCompatActivity.onCreate(AppCompatActivity.java:84)
        at ...
```

这个问题网上有很多讨论以及解决方法，问题的原因出自[这里](https://github.com/aosp-mirror/platform_frameworks_base/commit/39791594560b2326625b663ed6796882900c220f#diff-960c6fdd4a4b336d98b785268b2a78ffR2183)

```Java
if (ActivityInfo.isFixedOrientation(requestedOrientation) && !fullscreen 
	&& appInfo.targetSdkVersion >= O) {
	throw new IllegalStateException("Only fullscreen activities can request orientation");
}
```

这里做了当屏幕方向锁定了并且不为全屏并且 App 的`targetSdkVersion` 大于 `Android O`的话，就会抛出这个异常。

是否为全屏的判定如下:

```Java
public static boolean isTranslucentOrFloating(TypedArray attributes) {
	final boolean isTranslucent = attributes.getBoolean(
		com.android.internal.R.styleable.Window_windowIsTranslucent, false);
	final boolean isSwipeToDismiss = 
        !attributes.hasValue(com.android.internal.R.styleable.Window_windowIsTranslucent) 
		&& attributes.getBoolean(com.android.internal.R.styleable.Window_windowSwipeToDismiss, false);
	final boolean isFloating = 
        attributes.getBoolean(com.android.internal.R.styleable.Window_windowIsFloating, false);
	return isFloating || isTranslucent || isSwipeToDismiss;
}
```

手头的 Android 8.1 的机器并没有触发这个问题，是因为这个问题在 8.1 里已经[修复](https://github.com/aosp-mirror/platform_frameworks_base/commit/a4ceea026d6373e9be4b1daf3aa4ed93de4157cf#diff-960c6fdd4a4b336d98b785268b2a78ffL2197)了。

![1527229499937.png](https://i.loli.net/2018/05/25/5b07ac68bcb4a.png)

# 解决方案

解决方法有如下几种:

1. 降级`targetSDKVersion`到26以下 ~~(废话！！)~~

2. 移除`mainfest`文件里的`screenOrientation`属性

3. 取消Activity主题里的`windowIsTranslucent`属性或者`windowSwipeToDismiss`属性或者`windowIsFloating`属性（根据你设置了什么属性来具体分析）

4. （推荐）移除`manifest`文件里的`screenOrientation`属性，并在`Activity`的`onCreate`方法里设置屏幕方向

   ```Java
   if (Build.VERSION.SDK_INT != Build.VERSION_CODES.O) {
   	setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
   }
   ```

   