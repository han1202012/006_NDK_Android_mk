**CSDN 博客地址 :** [【Android NDK 开发】Android.mk 配置动态库 ( Android Studio 配置动态库 | 动态库加载版本限制 | 本章仅做参考推荐使用 CMake 配置动态库 )](https://hanshuliang.blog.csdn.net/article/details/104288881)

**博客资源下载地址 :** [https://download.csdn.net/download/han1202012/12157107](https://download.csdn.net/download/han1202012/12157107)

**示例代码 GitHub 地址 :** [https://github.com/han1202012/006_NDK_Android_mk](https://github.com/han1202012/006_NDK_Android_mk)


<br>
<br>

#### I . Android Studio 中使用 Android.mk 配置动态库库 总结

---

<br>

**Android Studio 中使用 Android.mk 配置第三方 动态库 或 静态库 :** 

<br>

**① Android.mk 脚本路径设置 :** <font color=red>在 Module 级别的 build.gradle 脚本中配置 Android.mk 构建脚本的路径 ; 

```java
    externalNativeBuild {
        ndkBuild{
            path "src/main/ndkBuild_Shared/Android.mk"
        }
    }
```

<br>

**② 预编译第三方动态库 :** <font color=blue>在 Android.mk 中预编译动态库 , 注意动态库与静态库使用的配置不同 , 这里以动态库举例 : 

```shell
include $(CLEAR_VARS)
LOCAL_MODULE := add
LOCAL_SRC_FILES := libadd.so
include $(PREBUILT_SHARED_LIBRARY)
```

<br>

**③ 链接动态库 :** <font color=purple>在 Android.mk 中预链接动态库或静态库 , 注意动态库与静态库使用的配置不同 , 这里以动态库举例 : 

```shell
LOCAL_SHARED_LIBRARIES := add
```

<br>

**④ Java 代码实现 :** <font color=green>声明 native 方法 , 加载编译的动态库 ; 

<br>

**⑤ C 代码实现 :** <font color=blue>声明函数库中的函数 , 调用动态库中的函数 ; 



<br>
<br>

#### II . 第三方动态库来源

---

<br>

**1 . 第三方动态库源码 :** <font color=blue>add.c ; 

```c
#include <stdio.h>

int add(int a, int b){
	return a + b;
}
```

<br>

**2 . Ubuntu 交叉编译过程 :** <font color=red>参考 [【Android NDK 开发】Ubuntu 函数库交叉编译 ( Android 动态库交叉编译 | Android 静态库交叉编译 )](https://hanshuliang.blog.csdn.net/article/details/104322352) , 最终编译出 libadd.so 动态库 , 和 libadd.a 静态库 ; 



<br>
<br>

#### III . 配置 Android.mk 构建脚本路径

---

<br>

**1 . 源码 编译 / 打包 配置 原理 :** [【Android NDK 开发】Android Studio 的 NDK 配置 ( 源码编译配置 | 构建脚本配置 | 打包配置 | CMake 配置 | ndkBuild 配置 ) : I . 源码编译配置](https://hanshuliang.blog.csdn.net/article/details/104272170#I___6)

<br>

**2 . 构建脚本路径配置 原理 :** [【Android NDK 开发】Android Studio 的 NDK 配置 ( 源码编译配置 | 构建脚本配置 | 打包配置 | CMake 配置 | ndkBuild 配置 ) : II . 构建脚本配置](https://hanshuliang.blog.csdn.net/article/details/104272170#II___79)

<br>

**3 . 这里直接设置 Android.mk 构建脚本路径 :** <font color=red>省略无关配置 , 只保留 NDK 相关配置 ; 

```java
apply plugin: 'com.android.application'

android {
    ...
    defaultConfig {
     	...
        // 配置 AS 工程中的 C/C++ 源文件的编译
        //     defaultConfig 内部的 externalNativeBuild 配置的是配置 AS 工程的 C/C++ 源文件编译参数
        //     defaultConfig 外部的 externalNativeBuild 配置的是 CMakeList.txt 或 Android1.mk 构建脚本的路径
        externalNativeBuild {
            /*cmake {
                cppFlags ""

                //配置编译 C/C++ 源文件为哪几个 CPU 指令集的函数库 (arm , x86 等)
                abiFilters "armeabi-v7a"
            }*/
            ndkBuild{
                abiFilters "armeabi-v7a" , "arm64-v8a", "x86", "x86_64"
            }
        }

        //配置 APK 打包 哪些动态库
        //  示例 : 如在工程中集成了第三方库 , 其提供了 arm, x86, mips 等指令集的动态库
        //        那么为了控制打包后的应用大小, 可以选择性打包一些库 , 此处就是进行该配置
        ndk{
            // 打包生成的 APK 文件指挥包含 ARM 指令集的动态库
            abiFilters "armeabi-v7a" , "arm64-v8a", "x86", "x86_64"
        }

    }

    // 配置 NDK 的编译脚本路径
    // 编译脚本有两种 ① CMakeList.txt ② Android1.mk
    //     defaultConfig 内部的 externalNativeBuild 配置的是配置 AS 工程的 C/C++ 源文件编译参数
    //     defaultConfig 外部的 externalNativeBuild 配置的是 CMakeList.txt 或 Android1.mk 构建脚本的路径
    externalNativeBuild {

        // 配置 CMake 构建脚本 CMakeLists.txt 脚本路径
        /*cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.10.2"
        }*/

        // 配置 Android1.mk 构建脚本路径
        ndkBuild{
            path "src/main/ndkBuild_Shared/Android.mk"
            //path "src/main/ndkBuild_Static/Android.mk"
        }
    }
 	...
}
...
```








<br>
<br>

#### IV . 预编译 第三方 动态库 ( Android.mk )

---

<br>

**1 . 清除变量 :** <font color=red>**( add 模块配置开始 )**

<br>

**① 作用 :** <font color=purple>配置新的模块之前都要先清除 LOCAL_XXX 变量 ; 
	
**② 例外情况 :** <font color=blue>有一个例外 , 就是不会清除 LOCAL_PATH 变量 ; 

**③ 模块开始标识 :** <font color=green>include $(CLEAR_VARS) , 一般作为一个模块配置的起始标志 ; 
 
**④ 模块结尾 :** <font color=orange>include $(XXX_STATIC_LIBRARY) / include $(XXX_SHARED_LIBRARY) 一般作为模块配置结束标志 ; 



```shell
include $(CLEAR_VARS)
```

<br>

**2 . 配置动态库名称 :** 

<br>

**① 自动生成函数库名称前提 :** <font color=blue>没有 LOCAL_MODULE_FILENAME 配置 , 就会自动生成函数库名称 ; 

**② 动态库命名规则 :** <font color=red>在 LOCAL_MODULE 名称基础上 , 添加 lib 前缀 和 .so 后缀 ; 

**③ 生成动态库名称 :** <font color=brown>libadd.so ; 

```shell
LOCAL_MODULE := add
```

<br>

**3 . 设置预编译的动态库路径 :** 

```shell
LOCAL_SRC_FILES := libadd.so
```

<br>

**4 . 设置预编译动态库 :** <font color=red>**( add 模块配置结束 )**

```shell
include $(PREBUILT_SHARED_LIBRARY)
```

<br>

**5 . 完整的第三方动态库预编译模块配置 :** 

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200215021314975.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hhbjEyMDIwMTI=,size_16,color_FFFFFF,t_70)

```shell
# II . 预编译第三方动态库


# 1 . 清除变量 ( add 模块配置开始 )
#	① 作用 : 配置新的模块之前都要先清除 LOCAL_XXX 变量
#	② 例外情况 : 但是不会清除 LOCAL_PATH 变量
#	③ 模块开始 : include $(CLEAR_VARS)
#  	④ 模块结尾 : include $(XXX_STATIC_LIBRARY) / include $(XXX_SHARED_LIBRARY)
include $(CLEAR_VARS)

# 2 . 配置动态库名称
#	① 自动生成函数库名称前提 : 没有 LOCAL_MODULE_FILENAME 配置 , 就会自动生成函数库名称
# 	② 动态库命名规则 : 在 LOCAL_MODULE 名称基础上 , 添加 lib 前缀 和 .so 后缀
# 	③ 生成动态库名称 : libadd.so
LOCAL_MODULE := add

# 3 . 预编译的动态库路径
LOCAL_SRC_FILES := libadd.so

# 4 . 设置预编译动态库 ( add 模块配置结束 )
include $(PREBUILT_SHARED_LIBRARY)
```


<br>
<br>

#### V . 链接动态库 ( 设置动态库依赖 )

---

<br>

**设置动态依赖库 :** 
	
<br>

**① 依赖库 :** <font color=blue>编译 native-lib 模块 , 需要链接 add 静态库 ; 

**② add 动态库 :** <font color=red>add 模块是一个预编译库 , 预编译内容是引入的第三方动态库 ; 


```shell
LOCAL_SHARED_LIBRARIES := add
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200215021211423.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hhbjEyMDIwMTI=,size_16,color_FFFFFF,t_70)

```shell
# IV . 配置动态库模块


# 1 . 清除变量 ( native-lib 模块配置开始 )
#	① 作用 : 配置新的模块之前都要先清除 LOCAL_XXX 变量
#	② 例外情况 : 但是不会清除 LOCAL_PATH 变量
include $(CLEAR_VARS)


# 2 . 配置动态库名称
#	① 自动生成函数库名称前提 : 没有 LOCAL_MODULE_FILENAME 配置 , 就会自动生成函数库名称
# 	② 动态库命名规则 : 在 LOCAL_MODULE 名称基础上 , 添加 lib 前缀 和 .so 后缀
# 	③ 生成动态库名称 : libnative-lib.so
LOCAL_MODULE := native-lib


# 3 . 编译的源文件
LOCAL_SRC_FILES := native-lib.c

# 4 . 设置动态依赖库
#	① 依赖库 : 编译 native-lib 模块 , 需要链接 add 静态库
#	② add 动态库 : add 模块是一个预编译库 , 预编译内容是引入的第三方动态库
LOCAL_SHARED_LIBRARIES := add

# 5 . 链接日志库
LOCAL_LDLIBS := -llog

# 6 . 设置预编译动态库 ( native-lib 模块配置结束 )
include $(BUILD_SHARED_LIBRARY)
```


<br>
<br>

#### VI . Java 代码定义 native 方法并加载动态库

---

<br>


**1 . 声明 并使用 native 方法 :** 

```java
public native String stringFromJNI();
```

<br>

**2 . 加载动态库 :** <font color=blue>这里要加载两个动态库 ; 

```java
        System.loadLibrary("add");
        System.loadLibrary("native-lib");
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200215021533559.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hhbjEyMDIwMTI=,size_16,color_FFFFFF,t_70)


<br>
<br>

#### VII . C 代码调用动态库函数

---

<br>

**1 . 声明动态库外部方法 :** 

```c
//声明 libadd.so 动态库中的方法
extern int add(int a, int b);
```

**2 . 调用动态库的方法 :** 

```c
//调用动态库中的函数
int sum = add(1, 2);
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200215021711770.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hhbjEyMDIwMTI=,size_16,color_FFFFFF,t_70)






<br>
<br>

#### VIII . 动态库加载版本限制 ( 6.0 以上 不能使用 Android.mk 配置动态库 ) 

---

<br>

**1 . 问题描述 :** 

 <font color=red>6.0 版本开始 , 使用 Android.mk 构建脚本预编译第三方的动态库 , 如果程序中使用 System.loadLibrary 加载该预编译库 , 就会报错 ; 

 <font color=blue>6.0 以下的手机版本 ( 不包括 6.0 版本 ) , System.loadLibrary 需要手动加载依赖的动态库 ; 

 <font color=magenta>6.0 及以上的手机版本 , System.loadLibrary 会自动加载依赖的动态库 , 此时不能加载依赖的动态库 , 否则会出错 ; 

<br>

**2 . 报错信息 :**  <font color=purple>6.0 以上的手机 不能使用 Android.mk 加载动态库 , 一旦加载崩溃 ; 报以下错误 ; 

```java
2020-02-13 01:58:38.044 23033-23033/kim.hsl.mk E/AndroidRuntime: FATAL EXCEPTION: main
    Process: kim.hsl.mk, PID: 23033
    java.lang.UnsatisfiedLinkError: dlopen failed: library "Y:/002_WorkSpace/001_AS/006_NDK_Android_mk/app/build/intermediates/ndkBuild/debug/obj/local/armeabi-v7a/libadd.so" not found
        at java.lang.Runtime.loadLibrary0(Runtime.java:977)
        at java.lang.System.loadLibrary(System.java:1567)
        at kim.hsl.mk.MainActivity.<clinit>(MainActivity.java:19)
        ...
```

<br>

**3 . 解决方案 :**  <font color=red>6.0 以上的手机 , 只能使用 CMake 配置动态库 , 或者使用静态库 ; 

<br>

**4 . CMake 配置方案参考 :** [【Android NDK 开发】NDK 交叉编译 ( Ubuntu 中交叉编译动态库 | Android Studio 中配置使用第三方动态库 )](https://blog.csdn.net/shulianghan/article/details/104255990)



<br>
<br>

#### IX . 完整代码示例

---

<br>


<br>
<br>

##### 1 . build.gradle 配置示例

---

<br>

```java
apply plugin: 'com.android.application'

android {
    compileSdkVersion 29
    buildToolsVersion "29.0.0"
    defaultConfig {
        applicationId "kim.hsl.mk"
        minSdkVersion 15
        targetSdkVersion 29
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"

        // 配置 AS 工程中的 C/C++ 源文件的编译
        //     defaultConfig 内部的 externalNativeBuild 配置的是配置 AS 工程的 C/C++ 源文件编译参数
        //     defaultConfig 外部的 externalNativeBuild 配置的是 CMakeList.txt 或 Android1.mk 构建脚本的路径
        externalNativeBuild {
            /*cmake {
                cppFlags ""

                //配置编译 C/C++ 源文件为哪几个 CPU 指令集的函数库 (arm , x86 等)
                abiFilters "armeabi-v7a"
            }*/
            ndkBuild{
                abiFilters "armeabi-v7a" , "arm64-v8a", "x86", "x86_64"
            }
        }

        //配置 APK 打包 哪些动态库
        //  示例 : 如在工程中集成了第三方库 , 其提供了 arm, x86, mips 等指令集的动态库
        //        那么为了控制打包后的应用大小, 可以选择性打包一些库 , 此处就是进行该配置
        ndk{
            // 打包生成的 APK 文件指挥包含 ARM 指令集的动态库
            abiFilters "armeabi-v7a" , "arm64-v8a", "x86", "x86_64"
        }

    }

    // 配置 NDK 的编译脚本路径
    // 编译脚本有两种 ① CMakeList.txt ② Android1.mk
    //     defaultConfig 内部的 externalNativeBuild 配置的是配置 AS 工程的 C/C++ 源文件编译参数
    //     defaultConfig 外部的 externalNativeBuild 配置的是 CMakeList.txt 或 Android1.mk 构建脚本的路径
    externalNativeBuild {

        // 配置 CMake 构建脚本 CMakeLists.txt 脚本路径
        /*cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.10.2"
        }*/

        // 配置 Android1.mk 构建脚本路径
        ndkBuild{
            path "src/main/ndkBuild_Shared/Android.mk"
            //path "src/main/ndkBuild_Static/Android.mk"
        }
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    implementation 'androidx.appcompat:appcompat:1.1.0'
    implementation 'androidx.constraintlayout:constraintlayout:1.1.3'
    testImplementation 'junit:junit:4.12'
    androidTestImplementation 'androidx.test:runner:1.2.0'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.2.0'
}

```


<br>
<br>

##### 2 . Android.mk 配置示例

---

<br>



```shell
# I . 保存构建脚本的路径 , 并赋值给 LOCAL_PATH 变量


#   ① 内置函数 : my-dir 是 NDK 内置的函数 , 获取当前的目录路径
#	在该案例中就是 Android.mk 文件所在的目录的绝对路径 , 工程根目录/app/src/main/cpp
#	将该目录赋值给 LOCAL_PATH 变量
#	所有的 Android1.mk 的第一行配置都是该语句

LOCAL_PATH := $(call my-dir)



# II . 预编译第三方动态库


# 1 . 清除变量 ( add 模块配置开始 )
#	① 作用 : 配置新的模块之前都要先清除 LOCAL_XXX 变量
#	② 例外情况 : 但是不会清除 LOCAL_PATH 变量
#	③ 模块开始 : include $(CLEAR_VARS)
#  	④ 模块结尾 : include $(XXX_STATIC_LIBRARY) / include $(XXX_SHARED_LIBRARY)
include $(CLEAR_VARS)

# 2 . 配置动态库名称
#	① 自动生成函数库名称前提 : 没有 LOCAL_MODULE_FILENAME 配置 , 就会自动生成函数库名称
# 	② 动态库命名规则 : 在 LOCAL_MODULE 名称基础上 , 添加 lib 前缀 和 .so 后缀
# 	③ 生成动态库名称 : libadd.so
LOCAL_MODULE := add

# 3 . 预编译的动态库路径
LOCAL_SRC_FILES := libadd.so

# 4 . 设置预编译动态库 ( add 模块配置结束 )
include $(PREBUILT_SHARED_LIBRARY)



# III . 打印变量值


# 打印 LOCAL_PATH 值
# Build 打印内容 : LOCAL_PATH : Y:/002_WorkSpace/001_AS/005_NDK_Compile/app/src/main/cpp
# 编译 APK 时会在 Build 中打印
$(info LOCAL_PATH : $(LOCAL_PATH))



# IV . 配置动态库模块


# 1 . 清除变量 ( native-lib 模块配置开始 )
#	① 作用 : 配置新的模块之前都要先清除 LOCAL_XXX 变量
#	② 例外情况 : 但是不会清除 LOCAL_PATH 变量
include $(CLEAR_VARS)


# 2 . 配置动态库名称
#	① 自动生成函数库名称前提 : 没有 LOCAL_MODULE_FILENAME 配置 , 就会自动生成函数库名称
# 	② 动态库命名规则 : 在 LOCAL_MODULE 名称基础上 , 添加 lib 前缀 和 .so 后缀
# 	③ 生成动态库名称 : libnative-lib.so
LOCAL_MODULE := native-lib


# 3 . 编译的源文件
LOCAL_SRC_FILES := native-lib.c

# 4 . 设置静态依赖库
#	① 依赖库 : 编译 native-lib 模块 , 需要链接 add 静态库
#	② add 静态库 : add 模块是一个预编译库 , 预编译内容是引入的第三方动态库
LOCAL_SHARED_LIBRARIES := add

# 5 . 链接日志库
LOCAL_LDLIBS := -llog

# 6 . 设置预编译动态库 ( native-lib 模块配置结束 )
include $(BUILD_SHARED_LIBRARY)



# V . 配置动态库与静态库区别


#	1 . 预编译时的路径不一致 :
#		① 动态库路径 : libadd.so
#		② 静态库路径 : libadd.a

#	2 . 预编译时结束配置不一致 :
#		① 动态库配置 : include $(PREBUILT_SHARED_LIBRARY)
#		② 静态库配置 : include $(PREBUILT_STATIC_LIBRARY)

#	3 . 链接依赖库时配置不一致 :
#		① 动态库依赖配置 : LOCAL_SHARED_LIBRARIES
#		② 静态库依赖配置 : LOCAL_STATIC_LIBRARIES
```


<br>
<br>

##### 3 . Java 代码示例

---

<br>

```java
package kim.hsl.mk;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    static {

        // 1 . 加载动态库的情况 : ( 必须不能注释下面的代码 )
        //      ① 6.0 以下的版本 : 需要手动加载依赖库 libadd.so
        //      ② 6.0 以上的版本 : 无法使用 Android.mk 构建脚本加载第三方动态库
        //                         此情况下, 无论是否手动加载 libadd.so 都会报错
        //
        // 2 . 加载静态库的情况 : ( 必须注释掉下面的这行代码 )
        System.loadLibrary("add");

        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView tv = findViewById(R.id.sample_text);
        tv.setText(stringFromJNI());
    }

    public native String stringFromJNI();
}

```


<br>
<br>

##### 4 . C 代码示例

---

<br>


```c
#include <jni.h>

#include <stdio.h>
#include <stdlib.h>

#include <android/log.h>


//调用 libadd.so 动态库中的方法
extern int add(int a, int b);

JNIEXPORT jstring JNICALL
Java_kim_hsl_mk_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject obj) {

    //调用动态库中的函数
    int sum = add(1, 2);

    // Logcat 打印计算结果
    __android_log_print(ANDROID_LOG_INFO, "JNI_TAG", "Native Caculate : %d + %d = %d", 1, 2, sum);

    //将加法运算转为字符串
    char str[50] = "0";
    //字符串格式化
    sprintf(str, "Native Caculate : Static Library : %d + %d = %d", 1, 2, sum);

    return (*env)->NewStringUTF(env, str);
}

```


<br>
<br>

##### 5 . 运行结果 ( Android 4.3 手机 | 6.0 以上系统无法运行 )

---

<br>

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200215022348679.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hhbjEyMDIwMTI=,size_16,color_FFFFFF,t_70)




<br>
<br>

#### X . 博客资源

---

<br>

**CSDN 博客地址 :** [【Android NDK 开发】Android.mk 配置动态库 ( Android Studio 配置动态库 | 动态库加载版本限制 | 本章仅做参考推荐使用 CMake 配置动态库 )](https://hanshuliang.blog.csdn.net/article/details/104288881)

**博客资源下载地址 :** [https://download.csdn.net/download/han1202012/12157107](https://download.csdn.net/download/han1202012/12157107)

**示例代码 GitHub 地址 :** [https://github.com/han1202012/006_NDK_Android_mk](https://github.com/han1202012/006_NDK_Android_mk)
