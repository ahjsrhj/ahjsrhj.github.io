---
title: Retrofit2学习笔记
date: 2016/04/16 15:56:44
thumbnail: https://o5iqfmxl6.qnssl.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-04-16%20%E4%B8%8B%E5%8D%883.05.14.png
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

比如添加 Gson，需要在 Gradle 里添加`compile 'com.squareup.retrofit2:converter-gson:2.0.2'`

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

# 0x3 注解说明

## 1. @GET

向目的URL发送GET请求，其中可以包含String类型参数，该参数附加到主URL后面。

``` java
@GET("/api/data/Android/500/1")
```

当参数中有`{}`花括号包含的字符串，表示需要使用`@Path`进行替换。

``` java
@GET("/api/data/{type}/500/1")
Call<Model> get(@Path String type);
//之后在代码中使用如下调用
 Call<Model> call = api.get("Android");
 //即 /api/data/Android/500/1
```

当目标URL形如`http://www.exapmle.com/list?page=1`时，这里就不能使用`@Path`了，需要使用查询参数`@Query`

``` java
 @GET("/list")
 Call<ResponseBody> list(@Query("page") int page);
 //之后在代码中使用如下调用
 Call<ResponseBody> call = api.list(1);
 //即 /list?page=1

 //当查询为多个时
 @GET("/list")
 Call<ResponseBody> list(@Query("category") String.. categories);
 //之后在代码中使用如下调用
 Call<ResponseBody> call = api.list("bar", "baz");
 //即 /list?category=bar&category=baz
 
//当为多组时
@GET("/list")
Call<ResponseBody> list(@Query("username") String username, @Query("password") String password);
//之后在代码中
Call<ResponseBody> call = api.list("admin", "123456");
//即 /list?username=admin&password=123456
```

当需要查询多个参数时，也可以使用`@QueryMap`

``` java
GET("/search")
Call<ResponseBody> list(@QueryMap Map<String, String> filters);
//---
Call<ResponseBody> call = api.list(ImmutableMap.of("foo", "bar", "kit", "kat"));
//即 /serach?foo=bar&kit=kat
```







# 0x04 Tips

## 1. 开启okhttp的log功能

首先在APP的`build.gradle`中配置依赖:

``` java
compile 'com.squareup.okhttp3:logging-interceptor:3.2.0'
```

代码中做如下改动即可:

```java
HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor();
interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
OkHttpClient client = new OkHttpClient.Builder().addInterceptor(interceptor).build();

Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(URL)
                .client(client)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
```

Logcat如下：

```
04-30 19:18:05.284 6638-6707/cn.imrhj.mydemo D/OkHttp: --> GET http://www.games-cube.com/combat/api/login?username=xxxx&password=xxxxx http/1.1
04-30 19:18:05.284 6638-6707/cn.imrhj.mydemo D/OkHttp: --> END GET
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: <-- 200 OK http://www.games-cube.com/combat/api/login?username=xxxx&password=xxxx (58ms)
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: Cache-Control: private
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: Transfer-Encoding: chunked
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: Content-Type: application/json; charset=utf-8
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: Server: Microsoft-IIS/8.0
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: Set-Cookie: ASP.NET_SessionId=e301ckyfpbzfbajkcepvnnu3; path=/; HttpOnly
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: X-AspNetMvc-Version: 5.2
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: X-AspNet-Version: 4.0.30319
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: X-Powered-By: ASP.NET
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: Date: Sat, 30 Apr 2016 11:18:05 GMT
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: OkHttp-Sent-Millis: 1462015085317
04-30 19:18:05.342 6638-6707/cn.imrhj.mydemo D/OkHttp: OkHttp-Received-Millis: 1462015085339
04-30 19:18:05.343 6638-6707/cn.imrhj.mydemo D/OkHttp: {"key":"f8716ab6-712a-4622-be5b-fd950326acb2","code":"1"}
04-30 19:18:05.343 6638-6707/cn.imrhj.mydemo D/OkHttp: <-- END HTTP (57-byte body)
04-30 19:18:05.350 6638-6638/cn.imrhj.mydemo D/MainAcitivty: onResponse: key:f8716ab6-712a-4622-be5b-fd950326acb2, code:1
```
