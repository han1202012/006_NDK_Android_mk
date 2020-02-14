# I . 保存构建脚本的路径 , 并赋值给 LOCAL_PATH 变量


#   ① 内置函数 : my-dir 是 NDK 内置的函数 , 获取当前的目录路径
#	在该案例中就是 Android.mk 文件所在的目录的绝对路径 , 工程根目录/app/src/main/cpp
#	将该目录赋值给 LOCAL_PATH 变量
#	所有的 Android1.mk 的第一行配置都是该语句

LOCAL_PATH := $(call my-dir)








# II . 预编译第三方动态库


# 1 . 配置新的模块之前都要先清除 LOCAL_XXX 变量 ( 模块开始 )
#	① 作用 : 开启新模块前 , 要清除上一个模块的临时变量
#	② 例外情况 : 但是不会清除 LOCAL_PATH 变量
#	③ 模块开始 : include $(CLEAR_VARS)
#  	④ 模块结尾 : include $(BUILD_STATIC_LIBRARY) / include $(BUILD_SHARED_LIBRARY)
include $(CLEAR_VARS)


# 2 . 配置动态库名称
#	① 自动生成函数库名称前提 : 没有 LOCAL_MODULE_FILENAME 配置 , 就会自动生成函数库名称
# 	② 动态库命名规则 : 在 LOCAL_MODULE 名称基础上 , 添加 lib 前缀 和 .so 后缀
# 	③ 生成动态库名称 : libadd.so
LOCAL_MODULE := add


# 预编译的动态库
LOCAL_SRC_FILES := libadd.so


# 预编译动态库
include $(PREBUILT_SHARED_LIBRARY)






# III . 构建动态库


# 打印 LOCAL_PATH 值
# Build 打印内容 : LOCAL_PATH : Y:/002_WorkSpace/001_AS/005_NDK_Compile/app/src/main/cpp
# 编译 APK 时会在 Build 中打印
$(info LOCAL_PATH : $(LOCAL_PATH))


# 配置新的模块之前都要先清除 LOCAL_XXX 变量
#	LOCAL_PATH 变量会保留
include $(CLEAR_VARS)


# 配置动态库名称
# 动态库命名规则 : 在 LOCAL_MODULE 基础上 , 添加 lib 前缀 和 .so 后缀
# 生成动态库名称 : libnative-lib.so
LOCAL_MODULE := native-lib


# 编译的源文件
LOCAL_SRC_FILES := native-lib.c

# 编译 native-lib 模块 , 需要链接 add 模块 , add 模块是一个预编译库 , 预编译内容是引入的第三方动态库
LOCAL_SHARED_LIBRARIES := add

# 链接日志库
LOCAL_LDLIBS := -llog

# 构建动态库
include $(BUILD_SHARED_LIBRARY)