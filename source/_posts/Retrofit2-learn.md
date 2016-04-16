---
title: Retrofit2学习笔记
date: 2016/04/16 15:56:44
categories:
- 技术
tags:
- Android
- Retrofit
- Java
- 网络请求
---
![](https://o5iqfmxl6.qnssl.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-04-16%20%E4%B8%8B%E5%8D%883.05.14.png)

平时在进行 Android 开发的时候，如果需要进行网络请求，一般都会选择使用**HttpURLConnection** 和 **HttpClient**。但是这两个用起来实在太过繁琐，需要设置一大堆，如果不封装的话，代码的复用率太低，所以就有了Android 的网络通信框架，比如 [**AsyncHttpClient**](https://github.com/AsyncHttpClient/async-http-client),这是一个异步的网络请求框架，使用它不必考虑线程的问题，其网络请求都在非 UI 线程中执行。还有就是 [**Volley**](http://developer.android.com/intl/zh-cn/training/volley/index.html)，其优点在于处理小文件的 http 请求，在下载大文件的时候性能就比较糟糕了。最后是[**okhttp**](https://github.com/square/okhttp)，它是Android版Http客户端。非常高效，支持SPDY、连接池、GZIP和 HTTP 缓存。还有今天的主角，[**Retrofit**](http://square.github.io/retrofit/)。
<!-- more -->
# 0x0 简介
>A type-safe HTTP client for Android and Java

 它是一个Square开发的类型安全的REST安卓客户端请求库。这个库为网络认证、API请求以及用OkHttp发送网络请求提供了强大的框架。


# 0x1 设置
在 module 的 Gradle 里添加`compile 'com.squareup.retrofit2:retrofit:2.0.2'`，之后点击*Sync Now*同步即可。 如果你想让接收的字符串自动解析成自己想要的结果，还需要添加Converter。有如下可选:
- [Gson](https://github.com/google/gson): com.squareup.retrofit2:converter-gson
- [Jackson](http://wiki.fasterxml.com/JacksonHome): com.squareup.retrofit2:converter-jackson
- [Moshi](https://github.com/square/moshi/): com.squareup.retrofit2:converter-moshi
- [Protobuf](https://developers.google.com/protocol-buffers/): com.squareup.retrofit2:converter-protobuf
- [Wire](https://github.com/square/wire): com.squareup.retrofit2:converter-wire
- [Simple XML](http://simple.sourceforge.net/): com.squareup.retrofit2:converter-simplexml
- Scalars (primitives, boxed, and String): com.squareup.retrofit2:converter-scalars

比如添加 Gson，需要在 Gradle 里添加`compile ''com.squareup.retrofit2:converter-gson:2.0.2'`

# 0x2 使用
我们以[干货集中营](http://gank.io)的 API 接口为例。比如获取10张~~福利~~照片的 api :`http://gank.io/api/data/福利/10/1`

## 1. 配置
在 module 的 Gradle 里添加依赖:
``` gradle
compile 'com.squareup.retrofit2:retrofit:2.0.2'
compile 'com.squareup.retrofit2:converter-gson:2.0.2'
```
还要确定你在 **AndroidMainfest.xml** 中请求了网络权限:
``` xml
<uses-permission android:name="android.permission.INTERNET" />
```
## 2. 根据 json 生成 model
在这里安利一款 Android Studio 插件：[GsonFormat](https://github.com/zzz40500/GsonFormat)，它能够根据JSONObject格式的字符串,自动生成实体类参数.

打开API 的地址，能够看到 json 如下:
``` json
{
  "error": false,
  "results": [
    {
      "_id": "57105d6e67765974fbfcf8f4",
      "createdAt": "2016-04-15T11:18:06.529Z",
      "desc": "4.15",
      "publishedAt": "2016-04-15T13:04:43.738Z",
      "source": "chrome",
      "type": "\u798f\u5229",
      "url": "http://ww3.sinaimg.cn/large/7a8aed7bjw1f2x7vxkj0uj20d10mi42r.jpg",
      "used": true,
      "who": "\u5f20\u6db5\u5b87"
    }
  ]
}
```
使用它生成的实体类如下:
``` java
public class Model {
    private List<ResultsBean> results;
    public boolean isError() {
        return error;
    }
    public void setError(boolean error) {
        this.error = error;
    }
    public List<ResultsBean> getResults() {
        return results;
    }
    public void setResults(List<ResultsBean> results) {
        this.results = results;
    }
    public static class ResultsBean {
        private String _id;
        private String createdAt;
        private String desc;
        private String publishedAt;
        private String source;
        private String type;
        private String url;
        private boolean used;
        private String who;

        public String get_id() {
            return _id;
        }
        public void set_id(String _id) {
            this._id = _id;
        }
        public String getCreatedAt() {
            return createdAt;
        }
        public void setCreatedAt(String createdAt) {
            this.createdAt = createdAt;
        }
        public String getDesc() {
            return desc;
        }
        public void setDesc(String desc) {
            this.desc = desc;
        }
        public String getPublishedAt() {
            return publishedAt;
        }
        public void setPublishedAt(String publishedAt) {
            this.publishedAt = publishedAt;
        }
        public String getSource() {
            return source;
        }
        public void setSource(String source) {
            this.source = source;
        }
        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }
        public String getUrl() {
            return url;
        }
        public void setUrl(String url) {
            this.url = url;
        }
        public boolean isUsed() {
            return used;
        }
        public void setUsed(boolean used) {
            this.used = used;
        }
        public String getWho() {
            return who;
        }
        public void setWho(String who) {
            this.who = who;
        }
    }
}
```
## 3. 新建一个接口
``` java
public interface GankIO {
    @GET("/api/data/{type}/500/1")
    Call<Model> get(@Path("type") String type);
}
```
在这里@GET 使用 JAVA 注解，在运行时使用 JAVA的反射机制进行处理。

`{type}` 为要获取的类型，可以在代码中指定为别的类型，具体可以查看 干货集中营的 api 文档说明。

## 4. 新建 Retrofit对象并进行网络请求
``` java
public static final String URL = "http://gank.io";

Retrofit retrofit = new Retrofit.Builder()
           .baseUrl(URL)
           .addConverterFactory(GsonConverterFactory.create())
           .build();
```
之后根据 `retrofit` 创建一个 `GankIO` 对象:
``` java
GankIO gankIO = retrofit.create(GankIO.class);
Call<Model> call = gankIO.get("福利");
```
然后可以进行网络请求了:
``` java
call.enqueue(new Callback<Model>() {
    @Override
    public void onResponse(Call<Model> call, Response<Model> response) {
        Model model = response.body();
        if (!model.isError()) {
            for (Model.ResultsBean url : model.getResults()) {
                Log.d(TAG, "onResponse: " + url);
            }
        }
    }
    @Override
    public void onFailure(Call<Model> call, Throwable t) {
    }
});
```
就是这么简单轻松有木有！！！












j
