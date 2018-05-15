---
title: Android O 隐式广播的变更
date: 2018-05-15 15:49:06
categories:
- 技术
tags:
- Android
- BroadcastReceiver
---

![](https://o5iqfmxl6.qnssl.com/blog/img/20180515174131_PRL9BV_android-o-hero.1913b82c89274bfa9e3072ee0f1add4d.png)

今天来说一下 Android O 中对于隐式广播的变更，完整的变更在[**这里**](https://developer.android.com/about/versions/oreo/android-8.0-changes)可以看到。

<!-- more -->

在 Android N 中，Google移除了三项隐式广播`(CONNECTIVITY_ACTION, ACTION_NEW_PICTURE, ACTION_NEW_VIDEO)`，而 Android O 中砍的更多，除了[**这里**](https://developer.android.com/guide/components/broadcast-exceptions)列出来的，其余的都被移除了。

除了移除一些广播之外，Android O 进行了更为严格的广播监听限制，[**这里**](https://developer.android.com/about/versions/oreo/background#broadcasts)可以看到具体的限制措施，总得来说静态注册的隐式广播接收器基本上都失效了，动态注册的不受影响，但是 App 被杀掉之后就无法生效了。官方推荐使用 [**JobScheduler**](https://developer.android.com/reference/android/app/job/JobScheduler.html) 来完成之前依赖隐私广播完成的操作。

并且除了这些由系统发出的隐式广播之外，由自己的应用自行发出的隐式广播也也无法被静态注册的广播接收器接收到。因此针对自己发出自己接收的隐式广播，成本最低的迁移方法是改为显式广播，只需要添加包名即可。

```java
Intent intent = new Intent("cn.imrhj.test_action");
intent.setPackage(getPackageName());
sendBroadcast(intent);
```

另一种方式是动态注册广播接收器，在一个运行中的 Activity 或者 Service 中进行动态注册即可。根据不同的场景自行选择。

如果你依赖某个隐式广播来唤醒 App 执行任务，那么你可能需要考虑使用 **JobScheduler** 了。

```java
Component service = new ComponentName(this,TestService.class);
JobInfo info = new JobInfo.Builder(service)
                  .setRequiresCharging(true)  // 是否充电
                  .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY) // 网络类型
                  .setPersisted(true) // 设备重启后是否继续
                  .build();
JobScheduler jobScheduler = (JobScheduler) getSystemService(Context.JOB_SCHEDULER_SERVICE);
jobScheduler.schedule(info);
```

JobScheduler 只支持 Android Lollipop 及以上的 Android 版本，因此如果你的项目 minSdkVersion 小于21,则需要考虑使用 [Android-Job](https://github.com/evernote/android-job) 这个第三方库，它能根据系统版本自动选择使用`JobScheduler`, `GcmNetworkManager` 或者 `AlarmManager`。