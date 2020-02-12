#include <jni.h>
//#include <android/log.h>


//调用 libadd.so 动态库中的方法
//extern int add(int a, int b);


/*extern "C" JNIEXPORT jstring JNICALL
Java_kim_hsl_mk_MainActivity_stringFromJNI(
        JNIEnv* env,
        jobject ) {
    std::string hello = "Hello from C++";

    //调用动态库中的函数
    int sum = add(1, 2);
    //打印计算结果
    __android_log_print(ANDROID_LOG_INFO, "JNI_TAG", "libadd.so : sum = %d", sum);

    return env->NewStringUTF(hello.c_str());
}*/

JNIEXPORT jstring JNICALL
Java_kim_hsl_mk_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject obj) {

    //__android_log_print(ANDROID_LOG_INFO, "JNI_TAG", "Hello from C");

    //调用动态库中的函数
    int sum = 3;//add(1, 2);
    //打印计算结果
    //__android_log_print(ANDROID_LOG_INFO, "JNI_TAG", "libadd.so : sum = %d", sum);

    return (*env)->NewStringUTF(env, "Hello from C");
}
