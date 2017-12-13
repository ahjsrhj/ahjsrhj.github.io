---
title: Android TextInputLayout 使用时的坑
date: 2017-11-25 15:36:41
categories:
- 技术
tags:
- ESXi
---
![](https://o5iqfmxl6.qnssl.com//blog/gif/Untitled.mov.gif)
在使用 `TextInputLayout` 编写一个登录界面时，发现一个深坑，记录下来。
简单的布局文件如下所示
``` xml
<android.support.design.widget.TextInputLayout
  android:layout_width="match_parent"
  android:layout_height="wrap_content"
  android:layout_marginEnd="50dp"
  android:layout_marginStart="50dp"
  android:layout_marginTop="20dp">   <EditText  android:id="@+id/etMail"
  android:layout_width="match_parent"
  android:layout_height="wrap_content"
  android:hint="@string/mail"
  android:imeOptions="actionNext"
  android:inputType="textEmailAddress"
  android:lines="1"
  android:singleLine="true"
  android:textColor="@android:color/white"
  android:textSize="14sp" /> </android.support.design.widget.TextInputLayout>
```
然而，此时 `TextInputLayout` 的未激活状态下hint的文字颜色为黑色，无法调整，查找[资料](https://stackoverflow.com/questions/30546430/how-to-change-the-floating-label-color-of-textinputlayout)得知，需要在style里添加一个theme，并复写`textColorHint`属性，如下
``` xml
 <style name="TextLabel" parent="TextAppearance.AppCompat">
    <!-- Hint color and label color in FALSE state -->
    <item name="android:textColorHint">@color/Color Name</item> 
    <item name="android:textSize">20sp</item>
    <!-- Label color in TRUE state and bar color FALSE and TRUE State -->
    <item name="colorAccent">@color/Color Name</item>
    <item name="colorControlNormal">@color/Color Name</item>
    <item name="colorControlActivated">@color/Color Name</item>
 </style>
```
然后将该theme添加到`TextInputLayout`中，然而我这样做之后，颜色样式确实改变了，但是在尝试添加error提示的时候崩溃了，
报错`java.lang.UnsupportedOperationException: Failed to resolve attribute at index 4: TypedValue{t=0x2/d=0x1010099 a=1}`。
Google一番找到的解决方案对我无效。
猜测是Android Design库升级之后部分行为发生了变更。
尝试更换`TextLabel` Theme 的 parent 主题为Material包下的主题，失败。
搜索之后，发现正确应该继承`Widget.Design.TextInputLayout`。之后一切表现正常
完整Theme主题如下:
``` xml
<style name="TextLabel" parent="Widget.Design.TextInputLayout" >
 <item name="android:textColorHint">@color/colorWhite5</item>
 <item name="android:textSize">14sp</item>
 <item name="colorAccent">@color/colorRedAccept</item>
 <item name="android:colorControlNormal">@color/colorWhite3</item>
 <item name="android:colorControlActivated">@color/colorRedText</item> </style>
```