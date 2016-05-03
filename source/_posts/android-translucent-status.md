---
title: Android透明状态栏实践
date: 2016-05-03 21:26:19
categories:
- 技术
tags:
- Android
- Java
- StatusBar
---

<center>![](https://o5iqfmxl6.qnssl.com/md/1462285906609.png)</center>

```
<!--more-->
```



关于透明状态栏~~(沉浸式状态栏)~~大家应该都有用过，从Android 4.4开始新加入的`windowTranslucentStatus`属性可以将`StatusBar`设置为透明，即在`v19`的`style.xml`中添加

``` xml
<item name="android:windowTranslucentStatus">true</item>
```

之后布局的内容会顶到顶栏。但是这种情况下`ActionBar`也会被顶栏遮挡，如图:

<center>![](https://o5iqfmxl6.qnssl.com/md/1462282804958.png)</center>

此时有两种解决方法，一是给根布局添加`android:fitsSystemWindows="true"`属性，将`StatusBar`空出来。但是。。。

<center>![](https://o5iqfmxl6.qnssl.com/md/1462283156106.png)</center>

咳，大概是打开的方式不对，换种方式再来。

----

# 0x0 开启透明

新建一个`styles.xml(v19)`，添加`windowTranslucentStatus`属性，这条属性即开启状态栏透明。

``` xml
<?xml version="1.0" encoding="utf-8"?>
<resources>

        <style name="AppTheme" parent="Theme.AppCompat.Light.NoActionBar">
                <!-- Customize your theme here. -->
                <item name="colorPrimary">@color/colorPrimary</item>
                <item name="colorPrimaryDark">@color/colorPrimaryDark</item>
                <item name="colorAccent">@color/colorAccent</item>
                <item name="android:windowTranslucentStatus">true</item>
        </style>
</resources>
```

# 0x1 添加一个statusView

在根布局的顶部添加一个`View`,高度为`25dp`

``` xml
    <View
        android:id="@+id/status_bar"
        android:layout_width="match_parent"
        android:layout_height="25dp"/>
```

# 0x2 代码中判断版本

当目标版本不低于v19时，将view隐藏，防止在低版本出现重复

``` java
@Override
protected void onCreate(Bundle savedInstanceState) {
	super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_test);
	View statusBar = findViewById(R.id.status_bar);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        statusBar.setVisibility(View.VISIBLE);
    }else{
    	statusBar.setVisibility(View.GONE);
    }
}
```



- Android 4.4：

<center>![](https://o5iqfmxl6.qnssl.com/md/1462284534931.png)</center>

- Android 4.1:

<center>![](https://o5iqfmxl6.qnssl.com/md/1462284770585.png)</center>


