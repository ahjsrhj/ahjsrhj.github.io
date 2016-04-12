---
title: 将网站转到vps上做镜像存储
date: 2016-04-9 16:55:29
categories:
- 技术
tags:
- Hexo
- vps
- Github webhook
---



>由于Github Page这两天间歇性抽风，因此打算将Hexo在我的腾讯云服务器上做一份镜像存储。考虑到每次更新博文都要手动传上去太麻烦，最开始打算使用Travis CI在自动部署的时候同时向我的VPS上传输一份文件镜像，但是这样的话需要使用ftps,Travis CI上还要为私匙加密。折腾起来太麻烦。

>google一番发现了[Github Webhook](https://developer.github.com/webhooks/)，我可以设定当每次执行gitpush的时候，github向指定服务器发送请求，然后我在服务器端监听这个请求，来判断如果push来自master分支，那么就在服务器端调用`git fetch origin master`来进行更新服务器端代码，以此实现镜像存储的自动部署。
<!-- more -->

![](http://7xsomm.com2.z0.glb.clouddn.com/16-4-11/71857159.jpg-700)

# 1. 在github上设置webhook
打开你的项目，选择Settings->Webhooks & services->Add webhook，在这个页面添加一个webhook。如图所示。
![](http://7xsomm.com2.z0.glb.clouddn.com/16-4-11/52379394.jpg-700)
- **Payload URL**: 在此输入服务器地址，比如我的是http://imrhj.tk:7777
- **Content type**: 这一项保持默认不要动，因为我们接下来要用到`github-webhook-handler`去监听Gtihub发送到服务器上的请求，而`github-webhook-handler`智能解析json数据。~~当然如果你要自己实现服务端监听的话，当我没说~~
- **Secret**: 密匙信息，建议输入一段随机字符串。用来进行身份鉴别，防止别人恶意向你的服务器发送请求。在接下来服务器端要用到。

点击**Update webhook**即可添加。添加完成后Github会发送一条请求检测配置是否成功，因为服务器端还未配置，所以请求会失败。接下来配置完服务器端刷新即可。

# 2. 服务器端配置
在这里如果不想~~其实是懒~~自己撸一个轮子，可以使用[github-webhook-handler](https://github.com/rvagg/github-webhook-handler)来进行服务端的处理。
``` bash
$ npm install -g github-webhook-handler
```
接下来是监听程序listener.js *这里就用到了刚刚设置的Secret*

``` js
var http = require('http')
var createHandler = require('github-webhook-handler')
var handler = createHandler({ path: '/', secret: '我刚刚设置的secret' })

function run_cmd(cmd, args, callback) {
  var spawn = require('child_process').spawn;
  var child = spawn(cmd, args);
  var resp = "";

  child.stdout.on('data', function(buffer) { resp += buffer.toString(); });
  child.stdout.on('end', function() { callback (resp) });
}

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    res.statusCode = 404
    res.end('no such location')
  })
}).listen(7777)

handler.on('error', function (err) {
  console.error('Error:', err.message);
})

handler.on('push', function (event) {
  console.log('Received a push event for %s to %s',
    event.payload.repository.name,
    event.payload.ref);
  if (event.payload.ref == 'refs/heads/master') {
    run_cmd('sh', ['./git.sh'], function(text){ console.log(text) });
  }
})

```
在这里当收到github发送来的请求，检测头里包含的信息是否为`refs/heads/master`，匹配上之后，执行同目录下的`git.sh`更新网站信息。
下面是`git.sh`:
``` bash
cd /usr/share/nginx/html
git fetch origin master
git reset --hard origin/master
```
enjoy it~
