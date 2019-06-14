---
title: ReactNative WebView 高度自适应网页
date: 2017-04-01 15:39:37
thumbnail: https://i.loli.net/2018/09/30/5bb06dadca1eb.png
categories:
- 技术
tags:
- React Native
- WebView
---
![](https://i.loli.net/2019/06/14/5d035d4578e9031465.png)

# 0x01 前言

在使用 `React Native` 的时候碰到一个需求，即将 `WebView` 与其他 `View` 进行混排，但是 `React Native` 本身并不像 `Android` 那样有类似 `wrap_content` 的属性进行高度控制，只能将高度写死。但是不同的页面高度肯定不一样的，这样就带来了一个问题: 怎么动态获取渲染后的网页高度并给 `WebView` 设置?

<!-- more -->

# 0x02 思路

根据之前搞 `Android` 的 `WebView` 的经验来看，方法有两种:

1.  动态注入 js 代码来获取页面高度
2.  找前端兄弟让他在页面里面提前嵌入 js 代码，我在展示时调用

经过查阅文档以及求助于水稻哥，发现别人的方法基本上都是属于动态注入来进行工作的，依赖于以下两个 API
1. [injectedJavaScript?: string](http://facebook.github.io/react-native/releases/0.42/docs/webview.html#injectedjavascript)

   > Set this to provide JavaScript that will be injected into the web page when the view loads.

2. [onNavigationStateChange?: function](http://facebook.github.io/react-native/releases/0.42/docs/webview.html#onnavigationstatechange)

   > Function that is invoked when the `WebView` loading starts or ends.

第一个函数即是注入 js 代码的，第二个是用来接受回调的，接下来只要在回调函数里拿到页面的高度即可。而当使用 `injectedJavaScrpit` 方法进行 js 注入时，`onNavigationStateChange` 的回调函数会多一个参数 : `jsEvaluationValue`, 这个参数里面存放的是 js 执行的结果。

进行测试的代码如下：

``` javascript
<WebView
	source={{uri: url}}
	automaticallyAdjustContentInsets={false}
	scrollEnabled={false}
	injectedJavaScript={'888'}
	onNavigationStateChange={(navState) => {
		console.log('- - - - - - rhjlog navState ' + JSON.stringify(navState));
}}
```

打出来的 log 如下:

``` verilog
- - - - - - rhjlog navState {"target":90,"canGoBack":false,"loading":false,"title":"","canGoForward":false,"navigationType":"other","url":"https://h5.117sport.com/share/article.html?id=259"}
- - - - - - rhjlog navState {"target":90,"canGoBack":false,"loading":false,"title":"蜂潮运动","canGoForward":false,"jsEvaluationValue":"888","url":"https://h5.117sport.com/share/article.html?id=259"}
```

我仿佛看到了成功在向我招手，加上高度控制代码:

``` javascript
class GoodsWebView extends BaseComp {
    constructor(props) {
        super(props)
        this.state= {
            height: 100
        }
    }
    render() {
        let url = 'https://h5.117sport.com/share/article.html?id=259'
        return (
                <WebView
                    style={{height: this.state.height}}
                    source={{uri: url}}
                    automaticallyAdjustContentInsets={false}
                    scrollEnabled={false}
                    injectedJavaScript={'document.body.clientHeight'}
                    onNavigationStateChange={(navState) => {
                        let height = parseInt(navState.jsEvaluationValue)
                        if (height > 0) {
                            this.setState({ height })
                        }
                    }}
                 />
        )
    }
}
```



然而，随着继续搜索，发现许多人都表明在 `Android` 平台上，回调函数返回的结果没有 `jsEvaluationValue` 这个字段！！ （经过测试，确实木有..）并且公司的页面使用这种方法，有一定的失败的概率，好像与渲染时间有关？

那么就只能换一种思路了，查看一下 `onNavigationStateChange` 方法的回调，字段如下:

``` json
{
    "canGoForward":false,
    "canGoBack":false,
    "loading":false,
    "title":"",
    "url":"https://h5.117sport.com/share/article.html?id=259",
    "target":89
}
```

这里 `title` 这个字段是用不到的，因此可以在 `js` 代码里将 `title` 设为高度，然后读取 `title`