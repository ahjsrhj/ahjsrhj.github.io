---
title: Retrofit2 + RxJava用法浅析
date: 2016/05/06 20:49:52
categories:
- 技术
tags:
- Android
- Retrofit
- Java
- RxJava
- RxAndroid
- 网络请求
---



![](https://o5iqfmxl6.qnssl.com/md/1462539342893.png)





本文以在一个demo中使用rxjava + retrofit2进行网络请求进行说明。



首先在`app`的`gradle`文件中配置依赖，添加如下项:

``` gradle
    compile 'com.squareup.retrofit2:adapter-rxjava:2.0.2'
    compile 'io.reactivex:rxandroid:1.2.0'
    compile 'io.reactivex:rxjava:1.1.4'
```



根据将要处理的json数据信息生成`javabean`如下:

``` json
public class TokenInfo {
    private String key;
    private String msg;
    private int code;
    public String getKey() {
        return key;
    }
    public void setKey(String key) {
        this.key = key;
    }
    public String getMsg() {
        return msg;
    }
    public void setMsg(String msg) {
        this.msg = msg;
    }
    public int getCode() {
        return code;
    }
    public void setCode(int code) {
        this.code = code;
    }
}
```

之后创建一个接口，让其返回`Observable<TokenInfo>`，
