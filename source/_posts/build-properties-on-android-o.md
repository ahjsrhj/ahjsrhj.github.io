---
title: 在Android O中获取BuildProperties文件信息
date: 2018-05-09 17:17:38
categories:
- 技术
tags:
- Android
- BuildProperties
- adb
- Android O
description: "在Android O中获取BuildProperties文件信息"
---
<!-- more -->


# 0x00 起因

升级App的 `targetSdkVersion`至27之后，发现原有的一个获取 Android 系统 `BuildProperties`信息的类无法正常工作了，初始化时会抛出异常

```Log
java.io.FileNotFoundException: /system/build.prop (Permission denied)
        at java.io.FileInputStream.open0(Native Method)
        at java.io.FileInputStream.open(FileInputStream.java:200)
        at java.io.FileInputStream.<init>(FileInputStream.java:150)
        at java.io.FileInputStream.<init>(FileInputStream.java:103)
        at java.io.FileReader.<init>(FileReader.java:58)
```

在初始化`BuildProperties`时，会去读取`/system/build.prop`的文件信息，相关代码如下:

```Java

    private BuildProperties() {
        mProperties = new Properties();
        try {

            mProperties.load(new FileInputStream(new File(Environment.getRootDirectory(), "build.prop")));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
```

因为在 Android O 开始，`/system/build.prop`的读取权限不再对非root用户开放，通过查看文件权限可以确认这个问题

- Android 8.1手机

```shell
$ adb shell ls -l /system/build.prop
-rw-------  1 root root      4699 2009-01-01 08:00 build.prop
```

可以看到`build.props`的文件权限变成了600

- Android 6.0手机

```shell
$ adb shell ls -l /system/build.prop
-rw-r--r-- root     root         9018 2017-12-16 01:51 build.prop
```

此时的文件权限是644，非root用户也有读取权限。

所以这段代码之前可以正常工作，在Android O上就会抛异常。

# 0x01 解决方法

## 1. getprop

通过`adb shell`命令进入到Android手机的shell环境中，可以执行内置的命令getprop，这条命令返回的是Android property的一个合计，其相关说明为`get property via the android property service`，这些属性从多个文件中加载，包括`/system/build.prop`、`/default.prop`，因此可以在代码中调用这条命令以此获取。

这样做有两个问题: 1是比直接读取`/system/build.prop`文件会多几个属性，因为getprop命令里还包含了`default.prop`文件中的信息，这个问题不大。2是终端输出的信息是形如:

```
[sys.lineage_settings_system_version]: [3]
[sys.logbootcomplete]: [1]
[sys.oem_unlock_allowed]: [1]
[sys.rescue_boot_count]: [1]
[sys.retaildemo.enabled]: [0]
[sys.sysctl.extra_free_kbytes]: [43200]
```

这样的信息，与直接读取文件相比，key 和 value 上被包裹了中括号，因此需要使用正则对结果进行处理之后才能使用。

相关代码如下:~~不完整~~

``` java
public static BuildProperties getInstance() {
    return InstanceHolder.mInstance;
}

private final Properties mProperties;
private final Pattern regex = Pattern.compile("\\[(.+)]: \\[(.+)]");
private BuildProperties() {
    mProperties = new Properties();
    try {
        Process p = Runtime.getRuntime().exec("getprop");
        BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String line;
        while ((line = in.readLine()) != null && !line.equals("null")) {
            this.parseLine(line);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
private void parseLine(String line) {
    if (StringUtil.isNotBlank(line)) {
        Matcher m = regex.matcher(line);
        if (m.find()) {
            mProperties.setProperty(m.group(1), m.group(2));
        }
    }
}
```



## 2. 通过反射调用 SystemProperties 进行获取

Android系统源码中大量使用了`android.os.SystemProperties`进行系统属性的获取与设置，我们可以通过反射来获取这个类进行调用。

相关代码如下:

```Java
public class SystemProperty {
    private final Context mContext;

    public SystemProperty(Context mContext) {
        this.mContext = mContext;
    }

    public String getOrThrow(String key) throws NoSuchPropertyException {
        try {
            ClassLoader classLoader = mContext.getClassLoader();
            Class SystemProperties = classLoader.loadClass("android.os.SystemProperties");
            Method methodGet = SystemProperties.getMethod("get", String.class);
            return (String) methodGet.invoke(SystemProperties, key);
        } catch (ClassNotFoundException e) {
            throw new NoSuchPropertyException(e);
        } catch (NoSuchMethodException e) {
            throw new NoSuchPropertyException(e);
        } catch (InvocationTargetException e) {
            throw new NoSuchPropertyException(e);
        } catch (IllegalAccessException e) {
            throw new NoSuchPropertyException(e);
        }
    }

    public String get(String key) {
        try {
            return getOrThrow(key);
        } catch (NoSuchPropertyException e) {
            return null;
        }
    }

}
```

代码来自项目[android-getprop](https://github.com/thuxnder/android-getprop)

